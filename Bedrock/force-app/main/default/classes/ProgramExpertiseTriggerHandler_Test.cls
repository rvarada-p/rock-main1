/*******************************************************************
Name  : ProgramExpertiseTriggerHandler_Test
Author: Vinod (Appirio)
Date  : September 18, 2014
Description: Test Class for the Handler class ProgramExpertiseTriggerHandler and trigger ProgramExpertiseTrigger.
            Covering the test coverage of the helper class ProgramExpertiseHelper
*************************************************************************/
@isTest
private class ProgramExpertiseTriggerHandler_Test {

    static testMethod void testOnAfterInsert() {
        // create test data
        RecordTypes_For_CBL_Processes__c recordtye = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Program Expertise', 'Program_Expertise__c','Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);        
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Competency_Expertise__c comExper = TestDataGenerator.createCompetencyExpertise(aExper.Id,testComp.id,'Walden', true);
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper.Id,product2.id,true,4.0, true);     
        List<Program_Competency__c> createdProgramCompetencies = [Select ID,Competency__c,Program_Expertise__c from Program_Competency__c where Competency__c =:testComp.id];
        system.assert(createdProgramCompetencies.size() == 1);
        system.assertEquals(createdProgramCompetencies[0].Program_Expertise__c, pExper.ID);
    }
    
    static testMethod void testUpdates() {
        RecordTypes_For_CBL_Processes__c recordtye = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Program Expertise', 'Program_Expertise__c','Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);        
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Competency_Expertise__c comExper = TestDataGenerator.createCompetencyExpertise(aExper.Id,testComp.id,'Walden', true);
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper.Id,product2.id,true,4.0, true);     
        List<Program_Competency__c> createdProgramCompetencies = [Select ID,Competency__c,Program_Expertise__c from Program_Competency__c where Competency__c =:testComp.id];
        system.assert(createdProgramCompetencies.size() == 1);
        system.assertEquals(createdProgramCompetencies[0].Program_Expertise__c, pExper.ID);
        createdProgramCompetencies[0].IsTryBeforeYouBuy__c = true;
        update createdProgramCompetencies[0];
        
        pExper.Learning_Order__c = 5.0;
        pExper.IsTryBeforeYouBuy__c = false;
        update pExper;
        
        pExper.IsTryBeforeYouBuy__c = false;
        update pExper;
    }
}