/*******************************************************************
Name  : TempoProfileHelper_Test
Author: Vinod (Appirio)
Date  : October 28, 2014
Description: Test Class for the  class TempoProfileHelper
*************************************************************************/
@isTest
private class TempoProfileHelper_Test {

    // test method to test function associateBrandProfileWithContact
    static testMethod void testAssociateBrandProfileWithContact() {
        // create test data
        TriggerSettings__c triggerSettings = new TriggerSettings__c();
        triggerSettings.Name = 'ContactTrigger';
        triggerSettings.isActive__c = false;
        triggerSettings.isTestMode__c = true;
        insert triggerSettings;
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('BrandbProfile', 'Brand_Profile__c','Tempo', true);
        RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity','Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb3 = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c','Walden', true);          
        Account testAcc = TestDataGenerator.createAccount(true);
        List<Contact> conLst = new List<Contact>();
        Contact testCon = TestDataGenerator.createContact(testAcc, false);
        testCon.Email = 'test12@test12345.Com';
        conLst.add(testCon);
        insert conLst;
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        Opportunity opty = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, null, false);
        opty.Contact__c = testCon.ID;
        opty.Primary_Program__c = product2.id;
        insert opty;      
        Profile p = [SELECT id, Name FROM Profile where name = 'Chatter Free User' ].get(0);
        User u = new User(firstname= 'Tempo',
        lastname='TestL',
        Alias='TtesT',
        email = 'test12@test12345.Com.tempowalden',
        username= 'test12@test12345.Com.tempowalden', 
        profileId= p.id, 
        emailencodingkey='UTF-8',
        languagelocalekey='en_US',
        localesidkey='en_US',
        timezonesidkey='America/Los_Angeles');
        insert u;    
		u = [select usertype from user where id =:u.id];
        List<Brand_Profile__c> bpList = new  List<Brand_Profile__c>();
        Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile1.Email__c = 'test12@test12345.Com';
        testProfile1.ChatterFreeUserId__c = u.id;
        insert testProfile1;
        Brand_Profile__c testUpdatedProfile1 = [Select ID,Contact__c from Brand_Profile__c where id =: testProfile1.ID];
        system.assertEquals(testUpdatedProfile1.Contact__c, testCon.ID);         
        Brand_Profile__c testProfile2 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile2.Email__c = 'test12123456@test12345.Com';
        insert testProfile2;
        bpList.add(testProfile1);
        bpList.add(testProfile2);
        TempoProfileHelper tempoHlpr = new TempoProfileHelper();
        tempoHlpr.createChatterFreeAccount(conLst, bpList);
        tempoHlpr.syncBrandProfileEmailAndChatterInformation(bpList);
        
    }
    // test method to test function associateBrandProfileWithContact
    static testMethod void testAssociateContactOpportunityWithBrandProfile() {
        // create test data
        TriggerSettings__c triggerSettings = new TriggerSettings__c();
        triggerSettings.Name = 'ContactTrigger';
        triggerSettings.isActive__c = false;
        triggerSettings.isTestMode__c = true;
        insert triggerSettings;
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('BrandbProfile', 'Brand_Profile__c','Tempo', true);
        RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity','Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb3 = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c','Walden', true);          
        Account testAcc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(testAcc, false);
        testCon.Email = 'test12@test12345.Com';
        insert testCon;
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        Opportunity opty = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, null, false);
        opty.Contact__c = testCon.ID;
        opty.Primary_Program__c = product2.id;
        insert opty;      
        Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile1.Email__c = 'test12@test412345.Com';
        testProfile1.Contact__c = testCon.id;
        insert testProfile1;
		opportunity testOpty1 = TestDataGenerator.createOpportunity(testAcc.id, testCon.id, 'Walden', false);
        testOpty1.Brand_Profile__c = testProfile1.id;
        insert testOpty1;
        list<Opportunity> lstOpportunity = [Select ID,Brand_Profile__c from Opportunity where Brand_Profile__c =: testProfile1.ID];
        system.assert(lstOpportunity.size() > 0);        
        
    }
    // test method to test function createOpportunityOnPrimaryProgramOfInterestChanged
    static testMethod void testCreateOpportunityOnPrimaryProgramOfInterestChanged() {
        // create test data
        TriggerSettings__c triggerSettings = new TriggerSettings__c();
        triggerSettings.Name = 'ContactTrigger';
        triggerSettings.isActive__c = false;
        triggerSettings.isTestMode__c = true;
        insert triggerSettings;
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('BrandbProfile', 'Brand_Profile__c','Tempo', true);
        RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity','Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb3 = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c','Walden', true);          
        Account testAcc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(testAcc, false);
        testCon.Email = 'test12@test12345.Com';
        insert testCon;
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile1.Email__c = 'test12@test12345.Com';
        testProfile1.Contact__c = testCon.id;
        insert testProfile1;
        testProfile1.Primary_Program_of_Interest__c = product2.id;
        update testProfile1;
        list<Opportunity> lstOpportunity = [Select ID,Brand_Profile__c from Opportunity where Brand_Profile__c =: testProfile1.ID];
        system.assert(lstOpportunity.size() > 0);        
        
    }
}