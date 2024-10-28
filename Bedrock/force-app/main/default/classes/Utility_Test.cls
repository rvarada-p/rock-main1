/*******************************************************************
Name  : Utility_Test
Author: Bryan (Appirio)
Date  : October 15, 2014
Discription: Test for the Utility class
*************************************************************************/  
@isTest
private class Utility_Test {

  private static void setup(){
    List<RecordTypes_For_CBL_Processes__c> rts = new List<RecordTypes_For_CBL_Processes__c>();
    rts.add(TestDataGenerator.createRecordTypesForCBLProcesses('student discount', 'Student_Discount__c', 'Walden', false));
    rts.add(TestDataGenerator.createRecordTypesForCBLProcesses('opportunity', 'Opportunity', 'Walden', false));
    insert rts;

  }

  @isTest static void testIsFirstMondayOfMonth(){
    Date inputDate = Date.newInstance(2014,10,05);
    // the above date is not on first monday it was on first sunday
    system.assert(!Utility.isFirstMondayOfMonth(inputDate));
    inputDate = Date.newInstance(2014,11,03);
    // the above date is on first monday
    system.assert(Utility.isFirstMondayOfMonth(inputDate));
    inputDate = Date.newInstance(1960,02,01);
    // the above date is on first monday
    system.assert(Utility.isFirstMondayOfMonth(inputDate));
    inputDate = Date.newInstance(2015,11,02);
    // the above date is on first monday
    system.assert(Utility.isFirstMondayOfMonth(inputDate));
    inputDate = Date.newInstance(2015,11,09);
    // the above date is not on first monday it was on second monday
    system.assert(!Utility.isFirstMondayOfMonth(inputDate));
  }
  
  @isTest static void testGetSundayEndDateForStudentSubscription(){
    Date endDate = Utility.getSundayEndDateForStudentSubscription( 1, Date.newInstance(2014,10,05) );
    Date resultDate = Date.newInstance(2014,11,02);
    system.assertEquals(endDate,resultDate);
    endDate = Utility.getSundayEndDateForStudentSubscription( 3, Date.newInstance(2015,03,02) );
    resultDate = Date.newInstance(2015,05,31);
    system.assertEquals(endDate,resultDate);
  }

  @isTest static void testGetRecordTypes() {
    setup();
    RecordType oppRt = [select id from recordtype where sobjecttype = 'Opportunity' and name ='Walden' limit 1];
    RecordType sdRt = [select id from recordtype where sobjecttype = 'Student_Discount__c' and name ='Walden' limit 1];


    Set<Id> oppRtIds = Utility.getRecordTypeFromCBLCustomSetting(Opportunity.sObjectType.getDescribe());
    Set<Id> sdRtIds = Utility.getRecordTypeFromCBLCustomSetting(Student_Discount__c.sObjectType.getDescribe());
    Set<Id> accRtIds = Utility.getRecordTypeFromCBLCustomSetting(Account.sObjectType.getDescribe());

    System.assertEquals(1, oppRtIds.size());
    System.assert(oppRtIds.contains(oppRt.id));

    System.assertEquals(1, sdRtIds.size());
    System.assert(sdRtIds.contains(sdRt.id));

    System.assertEquals(0, accRtIds.size());

  }

  @isTest static void testWithout() {
    List<Account> accs = TestDataGenerator.createAccounts(10, null, false);
    accs.get(0).name = 'removeme';
    accs.get(3).name = 'removeme';
    accs.get(9).name = 'removeme';


    List<Account> removed = Utility.without(accs, 'Name', 'removeme');

    System.assertEquals(7, removed.size());

    for(Account acc : removed){
      System.assertNotEquals('removeme', acc.name);
    }


  }
  @isTest static void testUnique() {
    List<Account> accs = TestDataGenerator.createAccounts(2, null, true);
    List<Contact> contacts = TestDataGenerator.createContacts(accs, 10, null, true);

    Map<id, account> accountMap = new Map<id, account>([
        select id, (select id, name from contacts)
        from account 
        where id in: accs
      ]);

    for(Id accId : accountMap.keySet()){
      Account acc = accountMap.get(accId);
      Integer idx = 0;
      for(Contact c : acc.contacts){
        c.lastname = 'Test '+idx;
      }
    }

    //test new dupe
    List<Contact> newcontacts = new List<Contact>();
    Contact c = TestDataGenerator.createContact(accs.get(0), false);
    c.lastname = 'Test 0';
    newcontacts.add(c);
    Contact cDupe = (Contact) Utility.unique(newcontacts,accountMap,'LastName', 'AccountId', 'Contacts');
    System.assertEquals('Test 0', cdupe.lastname);

    //test no dupe
    newcontacts.clear();
    c.lastname = 'InDupe';
    newcontacts.add(c);
    cDupe = (Contact) Utility.unique(newcontacts,accountMap,'LastName', 'AccountId', 'Contacts');
    System.assertEquals(null, cDupe);

    //test dupe in set
    Contact c1 =  TestDataGenerator.createContact(accs.get(0), false);
    c1.lastname = 'InDupe';
    newcontacts.add(c1);
    cDupe =  (Contact) Utility.unique(newcontacts,accountMap,'LastName', 'AccountId', 'Contacts');
    System.assertEquals('InDupe', cDupe.lastname);

    //test no children
    newcontacts.clear();
    Account acc =  TestDataGenerator.createAccount(null, true);
    accountMap = new Map<id, account>([
        select id, (select id, name from contacts)
        from account 
        where id =: acc.id
      ]);

    Contact c2 =  TestDataGenerator.createContact(acc, false);
    c2.lastname = 'NoDupe';
    newcontacts.add(c2);
    cDupe =  (Contact) Utility.unique(newcontacts,accountMap,'LastName', 'AccountId', 'Contacts');
    System.assertEquals(null, cDupe);
  }
  @isTest static void testContains() {
    List<Account> testAccounts = new List<Account>();
    for(Integer i = 0; i < 10; i++){
      testAccounts.add(new Account(name = 'test'+i));
    }
    System.assert(Utility.contains(testAccounts, 'Name', 'test2'));

    System.assert(Utility.contains(testAccounts, 'Name', 'test3'));

    System.assert(!Utility.contains(testAccounts, 'Name', 'nottest'));

    System.assert(!Utility.contains(new List<Account>(), 'Name', 'test2'));

  }
  @isTest static void testAll() {
    List<Account> testAccounts = new List<Account>();
    List<String> testNames = new List<String>();
    for(Integer i = 0; i < 10; i++){
      testAccounts.add(new Account(name = 'test'+i));
      testNames.add('test'+i);
    }
    System.assert(Utility.all(testAccounts, 'Name', testNames));

    testNames.add('nottest');

    System.assert(!Utility.all(testAccounts, 'Name', testNames));

    System.assert(Utility.all(Utility.getsObjectListChunkSafe(testAccounts), 'Name', new List<String>()));
    
  }


}