/*******************************************************************
Name  : ContactHelper_Test
Author: Vinod (Appirio)
Date  : December 09, 2014
Description: test class for the Helper class ContactHelper and Handler class 
ContactTriggerHandler
*************************************************************************/
@isTest
private class ContactHelper_Test {
  // test method for thes coverage of populateCBLStudentId function
 /* static testMethod void testValidateContactOnEdit() {
      // Create test data
    RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity','Walden', true);
    Account testAcc = TestDataGenerator.createAccount(true);
    Contact testCon = TestDataGenerator.createContact(testAcc,'Custom Person Account Contact', true);         
    Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
    Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
    product2.Parent_Program__c = parentProduct.Id;
    insert product2;
    Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
    psd.Program__c = product2.Id;
    psd.Start_Date__c = TestDataGenerator.getFirstMondayOfMonth(Date.today()+31);
    psd.Accepting_New_Students__c = true;
    insert psd;
    PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  
  
    Opportunity opty = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, null, false);
    opty.Contact__c = testCon.ID;
    opty.Primary_Program__c = product2.id;    
    insert opty;  
    
    opty.Admissions_Status__c = 'AD Admitted';
    opty.Admissions_Status_Code__c = 'AD';
    opty.StageName = 'Recommend Admit';
    opty.opportunity_status_auto_values__c = 'Admitted';
    opty.Initial_Price_Book__c = pb.id;
    opty.Program_Start_Date__c = psd.Id;
    //update opty;
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
    User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
    LocaleSidKey='en_US', ProfileId = p.Id, 
    TimeZoneSidKey='America/Los_Angeles', UserName='yyyywwwwwqqqqqqqoooooddddd@testorg.com');
    System.runAs(u) {
      // The following code runs as user 'u' 
      try{
        testCon.Maiden_Name__c = 'test';
        update testCon;
      }
      catch(exception ex){
        system.assert(ex.getMessage().contains('You do not have the permission to edit'));
      }
    }
  }*/
  // test method for thes coverage of populateCBLStudentId function
  static testMethod void testPopulateCBLStudentId() {
    // Create test data
    Account testAcc = TestDataGenerator.createAccount(true);
    set<ID> selectedContactIds = new set<Id>();
    Contact testCon = TestDataGenerator.createContact(testAcc,'Custom Person Account Contact', true);
    selectedContactIds.add(testCon.ID);
    Contact testCon2 = TestDataGenerator.createContact(testAcc,'Custom Person Account Contact', true); 
    selectedContactIds.add(testCon2.ID);    
    ContactHelper objHelper = new ContactHelper();        
    objHelper.populateCBLStudentId(selectedContactIds);
    Contact testUpdatedContact = [select ID,CBL_Student_ID__c from Contact where id=: testCon.id];
    system.assert(testUpdatedContact.CBL_Student_ID__c != null);            
    Contact testUpdatedContact2 = [select ID,CBL_Student_ID__c from Contact where id=: testCon2.id];
    system.debug('testUpdatedContact2:::::::::::'+testUpdatedContact2);
    system.assert(testUpdatedContact2.CBL_Student_ID__c != null);
  }
     static testMethod void testfailPopulateCBLStudentId() {
    // Create test data
    Account testAcc = TestDataGenerator.createAccount(true);
    set<ID> selectedContactIds = new set<Id>();
    Contact testCon = TestDataGenerator.createContact(testAcc,'Custom Person Account Contact', true);
  
    selectedContactIds.add(testCon.ID);
         contact testcon3 = new contact();
          ID cCustomPersonAccountContactId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Custom Person Account Contact').getRecordTypeId();
         testcon3.AccountId=testacc.id;
         testcon3.firstname ='test';
         testcon3.RecordTypeId=cCustomPersonAccountContactId;
             testcon3.lastname='last';
         testcon3.MailingCity='atlanta';
         testcon3.MailingCountry='Bulgaria';
         insert testcon3;
         
         testcon3.firstname='test2';
         testcon3.MailingCity='denver';
         testcon3.MailingCountry='Benin';
         update testcon3;
    Contact testCon2 = TestDataGenerator.createContact(testAcc,'Custom Person Account Contact', true); 
    selectedContactIds.add(testCon2.ID);    
    ContactHelper objHelper = new ContactHelper();        
    objHelper.populateCBLStudentId(selectedContactIds);
    Contact testUpdatedContact = [select ID,CBL_Student_ID__c from Contact where id=: testCon.id];
    system.assert(testUpdatedContact.CBL_Student_ID__c != null);            
    Contact testUpdatedContact2 = [select ID,CBL_Student_ID__c from Contact where id=: testCon2.id];
    system.debug('testUpdatedContact2:::::::::::'+testUpdatedContact2);
    system.assert(testUpdatedContact2.CBL_Student_ID__c != null);
  }
  // test method for thes coverage of PopulateCBLStudentIdOnAccount function
  static testMethod void testPopulateCBLStudentIdOnAccount() {
    // Create test data
    Account testAcc = TestDataGenerator.createAccount(true);
    Contact testCon = TestDataGenerator.createContact(testAcc,'Custom Person Account Contact', false);
    testCon.CBL_Student_ID__c = 'CBL000001';
    insert testCon;
    Account testUpdatedAccount = [select ID,CBL_Student_ID__c from Account where id=: testAcc.id];
    system.assertEquals(testUpdatedAccount.CBL_Student_ID__c,testCon.CBL_Student_ID__c);    
    Account testAcc2 = TestDataGenerator.createAccount(true);
    Contact testCon2 = TestDataGenerator.createContact(testAcc2,'Custom Person Account Contact', true);
    testCon2.CBL_Student_ID__c = 'CBL000002';
    update testCon2;
    Account testUpdatedAccount2 = [select ID,CBL_Student_ID__c from Account where id=: testAcc2.id];
    system.assertEquals(testUpdatedAccount2.CBL_Student_ID__c,testCon2.CBL_Student_ID__c); 
  }

  static testMethod void testGetExistingContactMap(){
    list<Account> accsToInsert = new list<Account>();
    list<Contact> consToInsert = new list<Contact>();
    Account testAcc1 = TestDataGenerator.createAccount(false);
    testAcc1.Name = 'Test1';
    accsToInsert.add(testAcc1);
    Account testAcc2 = TestDataGenerator.createAccount(false);
    testAcc2.Name = 'Test2';
    accsToInsert.add(testAcc2);
    Account testAcc3 = TestDataGenerator.createAccount(false);
    testAcc3.Name = 'Test3';
    accsToInsert.add(testAcc3);
    Account testAcc4 = TestDataGenerator.createAccount(false);
    testAcc4.Name = 'Test4';
    accsToInsert.add(testAcc4);
    insert accsToInsert;
    Contact testCon1 = TestDataGenerator.createContact(testAcc1,'Custom Person Account Contact', false);
    testCon1.FirstName = 'Chuck';
    testCon1.LastName = 'Smith';
    testCon1.Email = 'Test1@test.com';
    testCon1.Phone = '123-123-1234';
    consToInsert.add(testCon1);
    Contact testCon2 = TestDataGenerator.createContact(testAcc1,'Custom Person Account Contact', false);
    testCon2.FirstName = 'Eddy';
    testCon2.LastName = 'Test2';
    testCon2.Email = 'Test2@test.com';
    testCon2.Phone = '+11 98123-1234';
    consToInsert.add(testCon2);
    Contact testCon3 = TestDataGenerator.createContact(testAcc1,'Custom Person Account Contact', false);
    testCon3.FirstName = 'Bill';
    testCon3.LastName = 'Bank';
    testCon3.Email = 'banker@test.com';
    testCon3.Phone = '333-123-1233';
    consToInsert.add(testCon3);
    Contact testCon4 = TestDataGenerator.createContact(testAcc1,'Custom Person Account Contact', false);
    testCon4.FirstName = 'Test4';
    testCon4.LastName = 'Test4';
    testCon4.Email = 'Test4@test.com';
    testCon4.Phone = '123-123-1234';
    consToInsert.add(testCon4);
    insert consToInsert;
    list<Lead> newLeadList = new list<Lead>();
    Lead newLead1 = new Lead(FirstName='Chuck', LastName='Smith',Email='Test1@test.com');
    newLeadList.add(newLead1);
    Lead newLead2 = new Lead(FirstName='Eddy', LastName='Test2',Email='bogus@test.com',Phone='11981231234--');
    newLeadList.add(newLead2);
    Lead newLead3 = new Lead(FirstName='Bill', LastName='Bank',Email='notbanker@test.com',Phone='333123198761345');
    newLeadList.add(newLead3);
    Lead newLead4 = new Lead(FirstName='Frank', LastName='Jones',Email='fjones@test.com',Phone='123-123-1234');
    newLeadList.add(newLead4);
    Lead newLead5 = new Lead(FirstName='Mister', LastName='Null',Email='nuller@nuller.com');
    newLeadList.add(newLead5);

    map<Lead,Contact> mapNewLead_ExistingContact = new map<Lead,Contact>();
    ContactHelper helper = new ContactHelper();
    mapNewLead_ExistingContact = helper.getExistingContactMap(newLeadList);

   // system.assertEquals(2, mapNewLead_ExistingContact.size());

  }
    
    static testMethod void testValidationContact() {
    // Create test data
    Account testAcc = TestDataGenerator.createAccount(true);
    set<ID> selectedContactIds = new set<Id>();
    Contact testCon = TestDataGenerator.createContact(testAcc,'Custom Person Account Contact', true);
    selectedContactIds.add(testCon.ID);
    Contact testCon2 = TestDataGenerator.createContact(testAcc,'Custom Person Account Contact', true); 
    selectedContactIds.add(testCon2.ID);    
    ContactHelper objHelper = new ContactHelper();        
    objHelper.populateCBLStudentId(selectedContactIds);
    Contact testUpdatedContact = [select ID,CBL_Student_ID__c,email,name from Contact where id=: testCon.id];
    system.assert(testUpdatedContact.CBL_Student_ID__c != null);            
    Contact testUpdatedContact2 = [select ID,CBL_Student_ID__c,email,name from Contact where id=: testCon2.id];
    system.debug('testUpdatedContact2:::::::::::'+testUpdatedContact2);
    system.assert(testUpdatedContact2.CBL_Student_ID__c != null);
    contact testcon3 = new contact();
	ID cCustomPersonAccountContactId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Custom Person Account Contact').getRecordTypeId();
         testcon3.AccountId=testacc.id;
         testcon3.firstname ='test';
         testcon3.RecordTypeId=cCustomPersonAccountContactId;
         testcon3.lastname='last';
         testcon3.MailingCity='atlanta';
         testcon3.MailingCountry='Bulgaria';
         insert testcon3;
         testcon3.email = 'test';
         List<contact> conLst = new list<contact>();
       	conLst.add(testcon3);
         objHelper.populateCBLStudentId(conLst);
  }
    



}