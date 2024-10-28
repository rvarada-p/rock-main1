/*******************************************************************
Name  : LeadTriggerHelper_Test
Author: Vinod (Appirio)
Date  : September 19, 2014
Description: Test Class for the Handler class LeadTriggerHandler and trigger LeadTrigger
            Covering the test coverage of the helper class LeadTriggerHelper class
*************************************************************************/
@isTest
private class LeadTriggerHelper_Test {

    @isTest(SeeAllData=true)
    static void testConverLeadOnAfterInsert() {
    	Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, false);
        testCon.Email = 'test1@ConverLeadOnAfter.com';
        insert testCon;
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, 'Walden', false);
        opty.Primary_Program__c = product2.ID;
        opty.Contact__c = testCon.ID;
        insert opty;

        list<Lead> lstLead = new list<Lead>();
        Lead newLead = TestDataGenerator.createLead('Test', 'Lead','Test Comp', 'Walden', false);
        newLead.Program_of_Interest__c = product2.ID; 
        newLead.Email = 'test1@ConverLeadOnAfter.com';
        lstLead.add( newLead);
        Lead newLead2 = TestDataGenerator.createLead('Test2', 'Lead2','Test Comp2', 'Walden', false);
        newLead2.Program_of_Interest__c = product2.ID; 
        newLead2.Email = 'test2@ConverLeadOnAfter2.com';       
        lstLead.add( newLead2);
        insert lstLead;

        test.startTest();
        // test lead is converted or not
        list<Opportunity> lstOpty = [Select ID,Primary_Program__c from Opportunity where Primary_Program__c = :product2.ID];
        test.stopTest();
        system.assertEquals(lstOpty.size(),2);   
    }

    static testMethod void testPopulateProgramOfInterestOnBeforeInsert() {
        // Create Test Data
        LeadTriggerHandler.isLeadCreatedFromBrandProfileTrigger = true;
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 specialization = TestDataGenerator.createProduct('test', 'Walden', false);
        specialization.parent_program__c = product2.id;
        insert specialization;
        RecordTypes_For_CBL_Processes__c objCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Lead', 'Lead','Walden', true);
        Lead newLead = TestDataGenerator.createLead('Test', 'Hello','TestComp', 'Walden', false);
        newLead.Program_of_Interest_Key__c = specialization.ID; 
        newLead.Email = 'test@est.com';
        insert newLead;
        //  test ProgramOfInterest is populated on the lead or not
        Lead testLead = [Select ID,Program_of_Interest__c from Lead where id  =:newLead.ID];
        system.assert(testLead.Program_of_Interest__c != null);     
    }
    
}