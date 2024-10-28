/*******************************************************************
Name  : TestProgramCompetencyTriggerHandler
Author: Vinod (Appirio)
Date  : September 23, 2014
Description: Test Class for the Handler class ProgramCompetencyTriggerHandler and trigger ProgramCompetencyTrigger.
            Also Covering the test coverage of the helper class ProgramCompetencyTriggerHelper
*************************************************************************/
@isTest
private class ProgramCompetencyTriggerHandler_Test {
     static RecordTypes_For_CBL_Processes__c recordtye = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Program Expertise', 'Program_Expertise__c','Walden', true);
     static RecordTypes_For_CBL_Processes__c recordtye2 = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Program Competency', 'Program_Competency__c','Walden', true);
    static testMethod void testOnAfterInsert() {
        // create test data       
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);        
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Competency_Expertise__c comExper = TestDataGenerator.createCompetencyExpertise(aExper.Id,testComp.id,'Walden', true);
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper.Id,product2.id,true,4.0, false);     
        pExper.Number_of_Competencies__c = null;
        insert pExper;
        /*Program_Competency__c pComp = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,5, false);
        pComp.Program_Expertise__c = pExper.ID;
        insert pComp;*/
        // check umber_of_Competencies__c of the Program_Expertise__c is updated or not
        Program_Expertise__c updatepexpertise = [Select ID,Number_of_Competencies__c from Program_Expertise__c where id =: pExper.ID];
        list<Program_Competency__c> allProgramCompetency = [Select ID from Program_Competency__c where Program_Expertise__c =: pExper.ID];
        system.assertEquals(updatepexpertise.Number_of_Competencies__c,allProgramCompetency.size());
    }
    static testMethod void testOnBeforeInsert() {
        // create test data       
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);        
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Competency_Expertise__c comExper = TestDataGenerator.createCompetencyExpertise(aExper.Id,testComp.id,'Walden', true);
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper.Id,product2.id,true,4.0, false);     
        pExper.Number_of_Competencies__c = null;
        insert pExper;
        /*Program_Competency__c pComp = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,5, false);
        pComp.Program_Expertise__c = pExper.ID;
        insert pComp;*/
        try{
            Program_Competency__c pComp2 = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,5, false);
            pComp2.Program_Expertise__c = pExper.ID;
            insert pComp2;
            
        }
        catch(exception ex){
            system.assert(ex.getMessage().contains('A Program Competency already exists for this Program Expertise.'));
        }
    }
    static testMethod void testOnBeforeUpdate() {
        // create test data       
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);        
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Competency_Expertise__c comExper = TestDataGenerator.createCompetencyExpertise(aExper.Id,testComp.id,'Walden', true);
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper.Id,product2.id,true,4.0, false);     
        pExper.Number_of_Competencies__c = null;
        insert pExper;
        /*Program_Competency__c pComp = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,5, false);
        pComp.Program_Expertise__c = pExper.ID;
        insert pComp;*/
        Program_Competency__c pComp2 = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,5, true);
        try{
            pComp2.Program_Expertise__c = pExper.ID;
            update pComp2;
            
        }
        catch(exception ex){
            system.assert(ex.getMessage().contains('A Program Competency already exists for this Program Expertise.'));
        }
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
        
        // check umber_of_Competencies__c of the Program_Expertise__c is updated or not
        Program_Expertise__c updatepexpertise = [Select ID,Number_of_Competencies__c from Program_Expertise__c where id =: pExper.ID];
        list<Program_Competency__c> allProgramCompetency = [Select ID,Program_Expertise__c from Program_Competency__c where Program_Expertise__c =: pExper.ID];
        system.assertEquals(updatepexpertise.Number_of_Competencies__c,allProgramCompetency.size());
        Program_Expertise__c  pExper2 = TestDataGenerator.createProgramExpertise(aExper.Id,product2.id,true,4.0, false);
        Program_Competency__c pComp = allProgramCompetency[0];
        pComp.Program_Expertise__c = pExper2.ID;
        update pComp;
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
        // check umber_of_Competencies__c of the Program_Expertise__c is updated or not
        Program_Expertise__c updatepexpertise = [Select ID,Number_of_Competencies__c from Program_Expertise__c where id =: pExper.ID];
        list<Program_Competency__c> allProgramCompetency = [Select ID from Program_Competency__c where Program_Expertise__c =: pExper.ID];
        system.assertEquals(updatepexpertise.Number_of_Competencies__c,allProgramCompetency.size());
        delete pComp;
        Program_Expertise__c updatepexpertise2 = [Select ID,Number_of_Competencies__c from Program_Expertise__c where id =: pExper.ID];
        list<Program_Competency__c> allProgramCompetency2 = [Select ID from Program_Competency__c where Program_Expertise__c =: pExper.ID];
        system.assertEquals(updatepexpertise2.Number_of_Competencies__c,allProgramCompetency2.size());
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
        delete pComp;
        Database.UndeleteResult result = Database.Undelete(pComp, false);
    }
}