/*******************************************************************
Name  : MyProgressController 
Author: Ravitej Varada (Laureate)
Date  : February 6, 2018
Description: Controller extension class for MyProgressTest Page

* Revision History
* Horacio Sanchez   10/27/2020     S-28150 Making My Progress page available for Inactive Students
* Ravitej Varada    05/03/2022     S-694767: L2: Modify the Existing ATC (old flow) to Work Only if Product.Automate_Agree_to_Credit__c is False
* Horacio Sanchez   05/04/2022     S-89059 Update Tempo Portal Navigation Menu if ATC Start Date is Today
*************************************************************************/
public with sharing class MyProgressController {

    public Integer totalCompetencies {get; set;}
    public string modalHeader { get; set; }
    public string modalBody { get; set; }
    public Boolean isModalWindow { get; set; }
    public Integer completeCompetenciesCount {get; set;}
    public Student_Program__c sProgram { get; set; }
    public String currentUserId {get;set;}
    public String studentProgramId {get;set;}
    public String contactId {get;set;}
    public String waldenEmail { get; set; }
    public String waldenEmailHash { get; set; }
    public String completionPercentage { get; set; }
    public Decimal creditsCompleted { get; set; }
    public Integer totalCreditsInProgramPlan { get; set; }
    public String intercomAppId { get; set; }
    public String studentName { get; set; }
    Public String degreeLevel { get; set; }
    public Double gpa {get;set;}
    //public String clrUrl {get;set;}
    public Boolean isApplyForGraduationBtnDisabled {get; set;}
    public Boolean isATCCompleted {get;set;}
    
    Boolean isCommunityUser() {
        if('Customer Community Login'.equals( ([ Select UserLicense.Name  FROM Profile WHERE Id =: userinfo.getProfileid()]).UserLicense.Name) ) {
            return true;
        } else {
            return false;
        }
    }
    
    public MyProgressController(ApexPages.StandardController stdController) {
        if (! isCommunityUser()) {
             studentProgramId = ApexPages.currentPage().getParameters().get('id');
        } else {
            currentUserId = UserInfo.getUserId();
            User user = [SELECT Id, ContactId FROM User WHERE Id = :currentUserId];
            Contact contact = [SELECT Id,Walden_Email__c,name ,Email, (SELECT Id, Program__r.Degree_Level__c, IsStudentProgramActive__c FROM Student_Programs__r ORDER BY CreatedDate DESC LIMIT 1) FROM CONTACT WHERE Id = :user.ContactId];
            contactId= contact.id;
            waldenEmail = contact.Email;
            waldenEmailHash = HmacSHA256Encryption.generateHmacSHA256Signature(waldenEmail);
            studentName = contact.name;
            ApexPages.currentPage().getParameters().put('id',contact.Student_Programs__r[0].id);
            ApexPages.currentPage().getParameters().get('id');
            studentProgramId = ApexPages.currentPage().getParameters().get('id');
            degreeLevel = contact.Student_Programs__r[0].Program__r.Degree_Level__c;
            String urlSource = Apexpages.currentPage().getUrl();
            if (urlSource.toLowerCase().contains('getstarted') && !contact.Student_Programs__r[0].IsStudentProgramActive__c) {
            	throw new InvalidPageException('Invalid Page');
            }
         
        }
        
        Student_Program__c studentProgram = (Student_Program__c) stdController.getRecord();
        isATCCompleted = true;

        this.sProgram = [
                SELECT Name,gpa__c,Program__r.Automate_Agree_to_Credit__c,program__r.Parent_Program__r.Program_Guide_Link__c,IsStudentProgramActive__c,
                       All_Credits_Completed__c ,Current_Student_Subscription__r.Agreed_To_Credits__c,Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c, 
                       Current_Student_Subscription__r.Start_Date__c, Program_Completion__c, Number_Credits_Completed_in_all_Terms__c, 
            		   program__r.Total_Credits_in_Program__c, Total_Credits_in_Program__c, Graduation_Application_Submitted__c, (
                        SELECT Id,competency__r.Description__c
                        FROM Student_Competencies__r
                        WHERE Is_Enrolled__c = true AND Competency_Code__c != 'TL000' AND Competency__r.Type__c = 'Academic'
                )
                FROM Student_Program__c
                WHERE Id = :studentProgramId
        ];
        
        completionPercentage = ''+sProgram.Program_Completion__c;
        creditsCompleted = sProgram.All_Credits_Completed__c;
        totalCreditsInProgramPlan = sProgram.Total_Credits_in_Program__c.intValue();
        gpa = sProgram.GPA__c;
        
        if (Double.valueOf(completionPercentage) > 85 && !sProgram.Graduation_Application_Submitted__c) {
            isApplyForGraduationBtnDisabled = false;
        } else {
            isApplyForGraduationBtnDisabled = true;
        }
                        
  		//Custom Settings to retrive Brand Conf Record ID to display Header and Body for Model Window
        Community_Site_Settings__c defaultCustomSetngs = Community_Site_Settings__c.getValues('Default Settings');
        if( defaultCustomSetngs != null ) {
            Brand_Configuration__c BC = [Select id,name,Sub_Type__c,Body__c from Brand_Configuration__c where id = :defaultCustomSetngs.RecordID__c];
            modalHeader = BC.Sub_Type__c;
            modalBody = BC.Body__c;
            intercomAppId = defaultCustomSetngs.Intercom_App_Id__c ;
            //clrUrl = defaultCustomSetngs.CLR_SSO_URL__c;
        }

        if (String.isNotBlank(studentProgramId)) {
            completeCompetenciesCount = 0;
            List<Student_Competency__c> studentCompetencies = [ SELECT Id, IsCompleted__c 
                                                                FROM Student_Competency__c
                                                                WHERE Student_Program__c = : studentProgramId 
                                                                LIMIT 50000 ];
            totalCompetencies = studentCompetencies.size();
            
            for(Student_Competency__c studentCompetency : studentCompetencies) {
                if( studentCompetency.IsCompleted__c ) {
                    completeCompetenciesCount++;
                }
            }
        }
       	// displayModalWindow();
       
        // S-89059: Update Tempo Portal Navigation Menu if ATC Start Date is Today
        // Checking if Agree to Credits process has been completed
        if (sProgram.Current_Student_Subscription__c != null 
            && (sProgram.Current_Student_Subscription__r.Agreed_To_Credits__c == null || sProgram.Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c == null) 
            && sProgram.Program__r.Automate_Agree_to_Credit__c
            && sProgram.Current_Student_Subscription__r.Start_Date__c.daysBetween(Date.today()) < 14) {
            isATCCompleted = false;
        }
    }
    
    // S-89059: Update Tempo Portal Navigation Menu if ATC Start Date is Today
    // Checking if Agree to Credits process has been completed
    public PageReference atcCompletedCheck() {
        if (!isATCCompleted) {
            PageReference myTermPage;
            if (degreeLevel == 'Undergrad') {
                myTermPage = new PageReference('/MyTermUndergrad');
            } else {
                myTermPage = new PageReference('/MyTerm');
            }
            myTermPage.setRedirect(true);
            return myTermPage;
        }
        return null;
    }


	//This method controlls the modal content window based on agreed to credits on SP 
    public void displayModalWindow() {
        system.debug('displayModalWindow');
        
        if (sProgram != null) {
            if (sProgram.Current_Student_Subscription__r.Agreed_To_Credits__c != null &&
                sProgram.Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c == null && sProgram.Program__r.Automate_Agree_to_Credit__c == False ) {
                    isModalWindow = true;
                } else {
                    isModalWindow = false;
                }
        }
        system.debug('isModalWindow' + isModalWindow);
    }

    //This method updates the Date_Student_Agreed_To_Credits__c field  when "Agreed to credit Equavalence" Button is clicked.
    public void updateAgreedToCreditsDate() {
        system.debug('displayModalWindow');
        Student_Subscription__c studentSubscription = new Student_Subscription__c( id = sProgram.Current_Student_Subscription__c );

        studentSubscription.Date_Student_Agreed_To_Credits__c = date.today();
        update studentSubscription;
        isModalWindow = false;
    }
    
    private class InvalidPageException extends Exception {}

}