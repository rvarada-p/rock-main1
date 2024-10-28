/************************************************************************
Name  : WaldenOLAController
Author: Vinod (Appirio)
Date  : November 13, 2014
Description: Extension class for the pg OLAInternalView
*************************************************************************/
public with sharing class WaldenOLAController {
    public ID opportunityId;
    public Opportunity currentOpportunity{get;set;}
    public Contact opportunityContact{get;set;}
    public ID contactID;
    public list<Academic_History__c> lstAcademicHistory{get;set;}
    public list<Employment_History__c> lstEmploymentHistory{get;set;}
    public list<Student_Application_Requirement__c> lstStudentApplicationRequirement{get;set;}
    public boolean isHispanic{get;set;}
    public WaldenOLAController(ApexPages.StandardController controller){
        opportunityId = controller.getId();
        currentOpportunity= [Select Program_Start_Date__c, Primary_Program__r.Name, Primary_Program__r.Display_Name__c, Primary_Program__c, Name, Id, 
                            Have_you_previously_attended_Walden_Univ__c, Contact__c 
                            From Opportunity
                            where id =: opportunityId];
        contactID = currentOpportunity.Contact__c;
        getContactDetails();
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'All data below is LIVE! This is not necessarily a snapshot of what the applicant entered at the time of OLA submission.'));
    }
    public void getContactDetails(){
        opportunityContact = new Contact();
        lstAcademicHistory = new list<Academic_History__c>();
        lstEmploymentHistory = new list<Employment_History__c>();
        isHispanic = false;
        lstStudentApplicationRequirement = new list<Student_Application_Requirement__c>();
        if(contactID != null){
            for(Contact con:[Select Walden_Email__c, US_Citizen__c, SSN__c, Racial_Categories__c, Phone, Permanent_US_Resident__c, OtherPhone, Name, Are_you_Hispanic_or_Latino__c,
                            Middle_Name__c, MailingStreet, MailingState, Mailing_Non_US_State__c, MailingPostalCode, MailingLatitude, MailingCountry, MailingCountryCode, MailingCity, Maiden_Name__c,
                            Id, FirstName, English_Primary_Language__c, Email, Birthdate, Currently_Serving_in_US_Military__c ,LastName 
                            From Contact
                            where ID =: contactID]){
                opportunityContact = con;
            }
            //
            if(opportunityContact.Racial_Categories__c != null && opportunityContact.Racial_Categories__c.contains('Hispanic')){
                isHispanic =true;
            }

            // get all the Academic History
            lstAcademicHistory = [Select Zip__c, Name, Major__c, Institution_Name__c, Id, GPA__c, Degree_Earned__c, CreatedById,
                                Contact__c, City__c, State__c, Non_US_State__c, Country__c
                                From Academic_History__c
                                where Contact__c =: contactID];
            // get all Employment History
            lstEmploymentHistory = [Select Zip__c, Start_Month_Year__c, Name, LastModifiedDate, Id, End_Month_Year__c, 
                                    Contact__c, Company_Name__c, City__c,State__c, Non_US_State__c,Country__c
                                    From Employment_History__c 
                                    where Contact__c =:contactID];
            //
            lstStudentApplicationRequirement = [Select Requirement_Ordering__c, Requirement_Name__c, Requirement_Met__c, 
                                                Program_Application_Requirement__c, Opportunity__c, Name, Id,
                                                (Select Id From Attachments order by CreatedDate  asc limit 1)
                                                From Student_Application_Requirement__c
                                                where Opportunity__c = :opportunityId];
        }
    }
}