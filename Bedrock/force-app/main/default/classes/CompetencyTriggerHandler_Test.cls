/*******************************************************************
Name  : CompetencyTriggerHandler_Test
Author: Virendra (Appirio)
Date  : November 03, 2014
Description: Test class for the test coverage of the trigger CompetencyTrigger and class 'CompetencyTriggerHandler'
*************************************************************************/
@isTest
private class CompetencyTriggerHandler_Test {
    static RecordTypes_For_CBL_Processes__c recordtye = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Program Expertise', 'Program_Expertise__c','Walden', true);
    static RecordTypes_For_CBL_Processes__c recordtye2 = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Program Competency', 'Program_Competency__c','Walden', true);
    static RecordTypes_For_CBL_Processes__c recordtye3 = TestDataGenerator.createRecordTypesForCBLProcesses('Competency', 'Competency__c','Walden', true);    
    
    static testMethod void testOnBeforeUpdate() {
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);        
        Competency__c testComp = TestDataGenerator.createCompetency(false);
        testComp.Program_LMS_ID__c = '6984';
        testComp.AoE_LMS_ID__c = '7033';
        insert testComp;
        Competency_Expertise__c comExper = TestDataGenerator.createCompetencyExpertise(aExper.Id,testComp.id,'Walden', true);
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper.Id,product2.id,true,4.0, false);     
         
        //Insert the custom settings for D2L
        D2L__c setting = new D2L__c();
        setting.Name = 'D2L';
        setting.Org_Unit_ID__c = 6606;      
        setting.AoE_Type__c = 101;
        setting.LP_Version__c = 1.50;
        setting.Create_Course_Template__c = '/d2l/api/lp/1.5/coursetemplates/';
        setting.Create_Competency_Shell__c = '/d2l/api/lp/1.5/courses/';
        insert setting; 
        
        testComp.Publish_to_LMS__c = true;
        update testComp;                        
    }
    
    static testmethod void testHttpCallout() {
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);        
        Competency__c testComp = TestDataGenerator.createCompetency(false);
        testComp.Program_LMS_ID__c = '6984';
        testComp.AoE_LMS_ID__c = '7033';
        testComp.Code__c = 'TEST';
        testComp.Name = 'Test comp';
        insert testComp;
        Competency_Expertise__c comExper = TestDataGenerator.createCompetencyExpertise(aExper.Id,testComp.id,'Walden', true);
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper.Id,product2.id,true,4.0, false);     
         
        //Insert the custom settings for D2L
        D2L__c setting = new D2L__c();
        setting.Name = 'D2L';
        setting.Org_Unit_ID__c = 6606;      
        setting.AoE_Type__c = 101;
        setting.LP_Version__c = 1.50;
        setting.Create_Course_Template__c = '/d2l/api/lp/1.5/coursetemplates/';
        setting.Create_Competency_Shell__c = '/d2l/api/lp/1.5/courses/';
        insert setting; 
        
        Decimal programId = Decimal.valueOf(testComp.Program_LMS_ID__c);
        Decimal aoeId =  Decimal.valueOf(testComp.AoE_LMS_ID__c);                    
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_BSCourseTemplate());
        //HttpResponse  response = New HttpResponse();
        
        BrightSpaceCalls.createCompetencyTemplateAndShell(testComp.Id, testComp.Name, testComp.Code__c, new list<Decimal>{programId, aoeId});
        
        
    }    
    static testMethod void testOnAfterUpdate() {
        // create test data       
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);        
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Competency_Expertise__c comExper = TestDataGenerator.createCompetencyExpertise(aExper.Id,testComp.id,'Walden', true);
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper.Id,product2.id,true,4.0, false);     
        pExper.Number_of_Competencies__c = null;
        insert pExper;    
        testComp.Average_Time_in_hours__c = 4;
        update testComp;        
    }
    static testMethod void testOnAfterDelete() {
        // create test data       
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);        
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Competency__c testComp2 = TestDataGenerator.createCompetency(true);
        Competency_Expertise__c comExper = TestDataGenerator.createCompetencyExpertise(aExper.Id,testComp.id,'Walden', true);
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper.Id,product2.id,true,4.0, false);     
        pExper.Number_of_Competencies__c = null;
        insert pExper;
        Program_Competency__c pComp = TestDataGenerator.createProgramCompetency(testComp2.Id,product2.Id,true,5, false);
        pComp.Program_Expertise__c = pExper.ID;
        insert pComp;
        delete testComp;        
    }
    static testMethod void testOnAfterUnDelete() {
        // create test data       
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);        
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Competency__c testComp2 = TestDataGenerator.createCompetency(true);
        Competency_Expertise__c comExper = TestDataGenerator.createCompetencyExpertise(aExper.Id,testComp.id,'Walden', true);
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper.Id,product2.id,true,4.0, false);     
        pExper.Number_of_Competencies__c = null;
        insert pExper;
        Program_Competency__c pComp = TestDataGenerator.createProgramCompetency(testComp2.Id,product2.Id,true,5, false);
        pComp.Program_Expertise__c = pExper.ID;
        insert pComp;
        delete testComp;     
        Database.UndeleteResult result = Database.Undelete(testComp, false);   
    }
    
    static testmethod void testHttpCallout_NegativeCondition() {
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);        
        Competency__c testComp = TestDataGenerator.createCompetency(false);
        testComp.Program_LMS_ID__c = '6984';
        testComp.AoE_LMS_ID__c = '7033';
        testComp.Code__c = 'TEST';
        testComp.Name = 'Test comp';
        insert testComp;
        Competency_Expertise__c comExper = TestDataGenerator.createCompetencyExpertise(aExper.Id,testComp.id,'Walden', true);
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper.Id,product2.id,true,4.0, false);     
         
        //Insert the custom settings for D2L
        D2L__c setting = new D2L__c();
        setting.Name = 'D2L';
        setting.Org_Unit_ID__c = 6606;      
        setting.AoE_Type__c = 101;
        setting.LP_Version__c = 1.50;
        setting.Create_Course_Template__c = '/d2l/api/lp/1.5/coursetemplates/';
        setting.Create_Competency_Shell__c = '/d2l/api/lp/1.5/courses/';
        insert setting; 
        
        Decimal programId = Decimal.valueOf(testComp.Program_LMS_ID__c);
        Decimal aoeId =  Decimal.valueOf(testComp.AoE_LMS_ID__c);                    
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_BSNegative());
        //HttpResponse  response = New HttpResponse();
        
        BrightSpaceCalls.createCompetencyTemplateAndShell(testComp.Id, testComp.Name, testComp.Code__c, new list<Decimal>{programId, aoeId});
        
        
    }    
}