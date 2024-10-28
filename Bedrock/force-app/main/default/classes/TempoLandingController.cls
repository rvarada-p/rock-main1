/*******************************************************************
Name  : TempoLandingController 
Author: Ravitej Varada (Laureate)
Date  : February 22, 2018
Description: Controller extension class for TempoLanding VisualForce

Revision History
* Horacio Sanchez	-	Aug 02, 2021	-	S-59669 Update Videos on Tempo Landing page and Get Started page
* Horacio Sanchez   -   May 09, 2022    -   S-90888 Portal to present the CLP edit page on the first day of a new subscription term
*************************************************************************/

public with sharing class TempoLandingController {

    public String currentUserId {get;set;}
    public String contactId {get;set;}
    public String programName {get;set;}
    public String programGuideLink {get;set;}
    public String waldenEmail { get; set; }
    public String waldenEmailHash { get; set; }
    public String studentName { get; set; }
    public String intercomAppId { get; set; }
    public String degreeLevel {get;set;}

    public TempoLandingController(){
        
    }
    
    //Method to route landing page on pageload to Myterm for Grad and MyTermUnderGrad for UnderGrad Or inactive Layout
    public pagereference router(){
        PageReference p;  
        currentUserId = UserInfo.getUserId();
        degreeLevel = '';
        User user = [ SELECT Id, ContactId FROM User WHERE Id = :currentUserId ];
        Contact contact = [SELECT Id,Name,walden_email__c,CBL_Student_ID__c, Email,
                           (SELECT Id, IsStudentProgramActive__c, Program__r.Display_Name__c, Program__r.Degree_Level__c, 
                                   Current_Student_Subscription__c, Current_Student_Subscription__r.Start_Date__c, Program__r.Automate_Agree_to_Credit__c, 
                                   Current_Student_Subscription__r.Agreed_To_Credits__c, Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c
                            FROM Student_Programs__r 
                            WHERE IsStudentProgramActive__c = true LIMIT 1) 
                           FROM CONTACT 
                           WHERE Id = :user.ContactId ];
        contactId = contact.Id;
        waldenEmail = contact.Email;
        waldenEmailHash = HmacSHA256Encryption.generateHmacSHA256Signature(waldenEmail); 
        studentName =  contact.Name;
        Contact inactiveStudentProgramContact = [ SELECT Id,Name,walden_email__c,CBL_Student_ID__c, Email,(SELECT Id,IsStudentProgramActive__c,Program__r.Display_Name__c,Program__r.Degree_Level__c  
                                                                          FROM Student_Programs__r 
                                                                          WHERE IsStudentProgramActive__c = false LIMIT 1) 
                           FROM CONTACT 
                           WHERE Id = :user.ContactId ];
        
        try {
            degreeLevel = inactiveStudentProgramContact.Student_Programs__r[0].program__r.Degree_Level__c;
        } catch(Exception e) {
            System.debug(e.getMessage());
        }        
        
        //Custom Settings to retrive Brand Conf Record ID to display Header and Body for Model Window
        Community_Site_Settings__c defaultCustomSetngs = Community_Site_Settings__c.getValues('Default Settings');
        if( defaultCustomSetngs != null ) {
            intercomAppId = defaultCustomSetngs.Intercom_App_Id__c ;
        }
        
        Brand_Profile__C brandProfile = [SELECT Primary_Program_of_Interest__r.display_name__c, Primary_Program_of_Interest_Parent__c, Primary_Program_of_Interest__r.parent_program__r.Program_Guide_Link__c 
                                         FROM Brand_Profile__C 
                                         WHERE CBL_Student_ID__c = :contact.CBL_Student_ID__c 
                                         LIMIT 1 ];
        programName = brandProfile.Primary_Program_of_Interest__r.display_name__c;
        programGuideLink = brandProfile.Primary_Program_of_Interest__r.parent_program__r.Program_Guide_Link__c;
        
        if(contact.Student_Programs__r.isempty()){
            return Null;
        } else if (!contact.Student_Programs__r.isempty()) {
            if (contact.Student_Programs__r[0].Current_Student_Subscription__c != null 
            	&& (contact.Student_Programs__r[0].Current_Student_Subscription__r.Agreed_To_Credits__c == null || contact.Student_Programs__r[0].Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c == null) 
            	&& contact.Student_Programs__r[0].Program__r.Automate_Agree_to_Credit__c
            	&& contact.Student_Programs__r[0].Current_Student_Subscription__r.Start_Date__c.daysBetween(Date.today()) < 15
                && contact.Student_Programs__r[0].program__r.Degree_Level__c == 'Graduate') {
                p = new PageReference('/apex/EditBuild');
                return p;
            } else if (contact.Student_Programs__r[0].Current_Student_Subscription__c != null 
            	&& (contact.Student_Programs__r[0].Current_Student_Subscription__r.Agreed_To_Credits__c == null || contact.Student_Programs__r[0].Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c == null) 
            	&& contact.Student_Programs__r[0].Program__r.Automate_Agree_to_Credit__c
            	&& contact.Student_Programs__r[0].Current_Student_Subscription__r.Start_Date__c.daysBetween(Date.today()) < 15
                && contact.Student_Programs__r[0].program__r.Degree_Level__c == 'Undergrad') {
                p = new PageReference('/apex/EditBuildUndergrad');
                return p;
            }
            if (contact.Student_Programs__r[0].program__r.Degree_Level__c == 'Graduate') {
                p = new PageReference('/apex/MyTerm');
                degreeLevel = 'Graduate';
                return p ;
            } else if(contact.Student_Programs__r[0].program__r.Degree_Level__c == 'Undergrad') {
                p = new PageReference('/apex/MyTermUndergrad');
                degreeLevel = 'Undergrad';
                return p;
            }
        }
    	
        return null;
    }
}