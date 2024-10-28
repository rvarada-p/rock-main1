/*******************************************************************
Name  : CaseTriggerHandler_Test
Author: Vinay Joshi (Appirio)
Modified By: 
Date  : May 21 , 2015
Description: Test class for the test coverage of the calss CaseTriggerHandler
*************************************************************************/

@isTest
private class CaseTriggerHandler_Test{
    
  static Program_Start_Date__c progStartDate;
  static Contact testCon;
  static Opportunity opty;
  static Id wladenRecordType;
  static Student_Program__c sProg;

  public static void createTestData() {
	
	Account acc = TestDataGenerator.createAccount(true);
    
    testCon = TestDataGenerator.createContact(acc, true);
    
    Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);        
    Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
    product2.Parent_Program__c = parentProduct.Id;
    insert product2;    
         
    opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false); 
    opty.Primary_Program__c = product2.Id;
    insert opty;
    
    Date sDate = Date.today().adddays(-1);
    
    progStartDate = new Program_Start_Date__c();
    progStartDate.Name = 'Test';
    progStartDate.Start_Date__c = sDate;
    progStartDate.Accepting_New_Students__c = true;
    insert progStartDate;
    
    

    sProg = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false, 'Academic Warning (AW)', true, progStartDate.id); 
    sProg.Application__c = opty.Id;
    insert sProg;

	Institution__c ins = [SELECT Id FROM Institution__c WHERE Name = 'Walden' Limit 1];
    
    opty.Student_Program__c = sProg.Id;
    
    update opty;  
    
    wladenRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
  }

  static testMethod void caseWithOppty() {
  	
	createTestData();

  	Case ca1 = new Case();
  	ca1.Subject = 'Test1';
  	ca1.Opportunity__c = opty.Id;
 	ca1.Type ='Change of Modality';
    ca1.Case_Topic__c ='Course-Based to Tempo';
      
  	Case ca2 = new Case();
  	ca2.Subject = 'Test2';
  	ca2.Opportunity__c = opty.Id;
    ca2.Type ='Change of Modality';
    ca2.Case_Topic__c ='Course-Based to Tempo';

  	List<Case> cases = new List<Case> {ca1, ca2};
  	insert cases;

  	List<Case> casesAfterInsert = [SELECT Id, RecordTypeId FROM Case];

  	system.assertEquals(casesAfterInsert[0].RecordTypeId, wladenRecordType);
  	system.assertEquals(casesAfterInsert[1].RecordTypeId, wladenRecordType);

  }

  static testMethod void caseWithStuProg() {
  	
  	createTestData();
  	Case ca1 = new Case();
  	ca1.Subject = 'Test1';
  	ca1.RecordTypeId = wladenRecordType;
  	ca1.Student_Program__c = sProg.Id;
	ca1.Type ='Change of Modality';
    ca1.Case_Topic__c ='Course-Based to Tempo';
      
  	
  	Case ca2 = new Case();
  	ca2.Subject = 'Test2';
  	ca2.RecordTypeId = wladenRecordType;
  	ca2.Student_Program__c = sProg.Id;
  	ca2.Type ='Change of Modality';
    ca2.Case_Topic__c ='Course-Based to Tempo';
  	
  	List<Case> cases = new List<Case> {ca1, ca2};
  	insert cases;
    
    
	
    
    //update ca1;
    //update ca2;

  	List<Case> casesAfterInsert = [SELECT Id, RecordTypeId FROM Case];

  	system.assertEquals(casesAfterInsert[0].RecordTypeId, wladenRecordType);
  	system.assertEquals(casesAfterInsert[1].RecordTypeId, wladenRecordType);

  }

  static testMethod void caseWithoutStuProgWithoutOppty() {
  	
  	Case ca1 = new Case();
  	ca1.Subject = 'Test2';
  	ca1.Type ='Change of Modality';
    ca1.Case_Topic__c ='Course-Based to Tempo';
  	//ca1.Student_Program__c = sProg.Id;

  	Case ca2 = new Case();
  	ca2.Subject = 'Test2';
    ca2.Type ='Change of Modality';
    ca2.Case_Topic__c ='Course-Based to Tempo';
  	//ca2.Student_Program__c = sProg.Id;

  	List<Case> cases = new List<Case> {ca1, ca2};
  	insert cases;

  	List<Case> casesAfterInsert = [SELECT Id, RecordTypeId FROM Case];

  	system.assertNotEquals(casesAfterInsert[0].RecordTypeId, wladenRecordType);
  	system.assertNotEquals(casesAfterInsert[1].RecordTypeId, wladenRecordType);

  }  

}