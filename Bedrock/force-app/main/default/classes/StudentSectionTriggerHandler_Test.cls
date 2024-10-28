/*******************************************************************
Name  : StudentSectionTriggerHandler_Test
Author: Sarah Khalid - Laureate
Date  : October 16, 2017
Description: Test Class for the Handler class StudentSectionTriggerHandler and trigger StudentSectionTrigger.
             Covering the test coverage of the helper class StudentSectionHelper
*************************************************************************/

@isTest (SeeAllData=true)
private class StudentSectionTriggerHandler_Test {

    private static Student_Competency__c sCometency;
    private static User smeUser;
    private static Sections__c section;
    
    public static void setup() {

        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Competency', 'Student_Competency__c','Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);        
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.Id;
        insert product2;    
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);  
        Competency__c testComp = [SELECT Id FROM Competency__c LIMIT 1];
        Program_Expertise__c pExperise = TestDataGenerator.createProgramExpertise(aExper.ID,product2.ID,true,5.0,true);
        Program_Competency__c pCompetemcy = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0, false);
        pCompetemcy.Program_Expertise__c = pExperise.ID;
        insert pCompetemcy;
        Student_Expertise__c sExpertise = TestDataGenerator.createCompetencyExpertise(aExper.Id,null, false);
        sExpertise.Contact__c = testCon.id;
        sExpertise.Program_Expertise__c = pExperise.ID;
        insert sExpertise;
        // create strudent competency
        sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency.Contact__c = testCon.id;
        sCometency.Program_Competency__c = pCompetemcy.ID;
        insert sCometency;
        
        
        smeUser = [SELECT Id FROM User WHERE Profile.Name = 'CBL SME Chatter Only' LIMIT 1];
        section = new Sections__c();
        section.SME__c = smeUser.id;
        section.Competency__c = sCometency.Competency__c;
        section.LMS_Section_ID__c = 4343;
        insert section;
        
 
    }


    static testMethod void testOnAfterInsert() {
       setup();
       sCometency.Assessment_Submitted__c = true;
       Student_Sections__c studentSection;
       update sCometency;
       list<Student_Sections__c> studentSections = new list<Student_Sections__c>([SELECT Id FROM Student_Sections__c WHERE Student_Competency__c = :sCometency.Id LIMIT 1]);
       if(studentSections.size()>0) {
	       studentSection = [SELECT Id FROM Student_Sections__c WHERE Student_Competency__c = :sCometency.Id LIMIT 1];
       }
       else {
       		studentSection = new Student_Sections__c();
			studentSection.Section__c = section.Id;
       		studentSection.Student_Competency__c = sCometency.Id;
       		insert studentSection;
       }
       System.debug('Student Section: ' + studentSection);
       System.assert(studentSection!=null);
    }
    
    static testmethod void testHttpCallout() {
        setup();
         
        Decimal smeRoleId = D2L__c.getValues('D2L').SME_Role_ID__c;
        smeUser = [SELECT Id FROM User WHERE Profile.Name = 'CBL SME Chatter Only' LIMIT 1];
        section = new Sections__c();
        section.SME__c = smeUser.id;
        section.Competency__c = sCometency.Competency__c;
        section.LMS_Section_ID__c = 4343;
        insert section;  
        
        Student_Sections__c stuSec = new Student_Sections__c ();
        stuSec.Section__c = section.id;                    
        JsonWrapper jsonGenerator = new JsonWrapper();
        String json = jsonGenerator.createEnrollmentData(4343.0, 433, smeRoleId);
            
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_BSEnrollments());
        HttpResponse  response = New HttpResponse();
        
        //BrightSpaceCalls.createEnrollment(json, sCometency.Id);
        BrightSpaceCalls.createEnrollment(json,stuSec.Id ,4343.0,433,smeRoleId ,sCometency.Id);
        System.assert(response!=null);
    }    
    
    static testmethod void testHttpCallout_NegativeCondition() {
        setup();
         
        Decimal smeRoleId = D2L__c.getValues('D2L').SME_Role_ID__c;
        smeUser = [SELECT Id FROM User WHERE Profile.Name = 'CBL SME Chatter Only' LIMIT 1];
        section = new Sections__c();
        section.SME__c = smeUser.id;
        section.Competency__c = sCometency.Competency__c;
        section.LMS_Section_ID__c = 4343;
        insert section;  
        
        Student_Sections__c stuSec = new Student_Sections__c ();
        stuSec.Section__c = section.id;
        JsonWrapper jsonGenerator = new JsonWrapper();
        String json = jsonGenerator.createEnrollmentData(4343.0, 433, smeRoleId);
            
    	Test.setMock(HttpCalloutMock.class, new MockHttpResponse_BSNegative());
        HttpResponse  response = New HttpResponse();
        
        //BrightSpaceCalls.createEnrollment(json, sCometency.Id);
        BrightSpaceCalls.createEnrollment(json,stuSec.Id ,4343.0,433,smeRoleId ,sCometency.Id);
        System.assert(response!=null);
    }    
    
}