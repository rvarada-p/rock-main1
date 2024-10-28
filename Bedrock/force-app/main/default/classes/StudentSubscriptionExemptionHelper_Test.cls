/*******************************************************************
Name  : StudentSubscriptionExemptionHelper_Test
Author: Sarah Khalid
Date  : April 14, 2016
Description: Test code coverage class for
			 StudentSubscriptionExemptionTrigger and 
			 StudentSubscriptionExemptionHelper
*************************************************************************/


@isTest
private class StudentSubscriptionExemptionHelper_Test {
	
	@isTest static void testStandardReduction() {
    	RecordTypes_For_CBL_Processes__c objCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Subscription', 'Student_Subscription__c','Walden', true);
        //TriggerSettings__c objTrgSetting = TestDataGenerator.createTriggerSettings('StudentSubscriptionTrigger', true, true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProgram = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', false);
        prod.Parent_Program__c = parentProgram.id;
        insert prod;
        Program_Start_Date__c psdStart = TestDataGenerator.createProgramStartDate(false);
        psdStart.Program__c = prod.Id;
        psdStart.Accepting_New_Students__c = true;
        insert psdStart;
 	     
 	    Program_Start_Date__c psdEnd = TestDataGenerator.createProgramStartDate(false);
        psdEnd.Program__c = prod.Id;
        psdEnd.Accepting_New_Students__c = true;
        insert psdEnd;

        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = prod.Id;
        opp.Program_Start_Date__c = psdStart.Id;
        insert opp;
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.Program__c =prod.id;
        insert sProg;
        Date sDate = Date.newInstance(1960, 2, 1);
        Date eDate = Date.newInstance(1960, 6, 5);

		Script_Settings__c setting = new Script_Settings__c();
		setting.Name = 'Current Settings';
		setting.disableSubEndDateValidation__c = false;
		setting.disableSubMondayValidation__c = false;
		setting.CheckDateOnSubscriptionRenewal__c = true;
		
		insert setting;
        
        Test.startTest();
        Id standardPricebookId = Test.getStandardPricebookId();
        PricebookEntry stdEntry = new PricebookEntry();
        stdEntry.IsActive = true;
        stdEntry.Product2Id = prod.Id;
        stdEntry.Pricebook2Id = standardPricebookId;
        stdEntry.UnitPrice = 5555.00;
        insert stdEntry;
        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        Double cost = 3000.00;
        PricebookEntry entry = TestDataGenerator.createPricebookEntry(prod.Id, pBook.Id, cost, false, false);
        entry.Available_for_Existing_Students__c = true;
        insert entry;
        
    	Exemption__c exmp = TestDataGenerator.createExemption('Standard Reduction', 'Military', false, 2, prod, true, 100, 0, true, psdStart, psdEnd);
        Student_Discount__c stuDiscount = TestDataGenerator.createStudentDiscount(opp, sProg, exmp, true);

        Student_Subscription__c oldStuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        oldStuSub.Start_Date__c = Date.newInstance(1960, 2, 1);
        oldStuSub.Subscription_Status__c = 'RE = Registered';
        insert oldStuSub;
        
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        stuSub.Start_Date__c = Date.newInstance(2014, 10, 6);
        insert stuSub;	

        Student_Subscription_Exemptions__c stuSubExemption = TestDataGenerator.createStudentSubscriptionExemption(stuDiscount, stuSub, 'Walden', true);
  
    }
	
	@isTest static void testLimitedTime() {
    	RecordTypes_For_CBL_Processes__c objCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Subscription', 'Student_Subscription__c','Walden', true);
        //TriggerSettings__c objTrgSetting = TestDataGenerator.createTriggerSettings('StudentSubscriptionTrigger', true, true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProgram = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', false);
        prod.Parent_Program__c = parentProgram.Id;
        insert prod;
        Program_Start_Date__c psdStart = TestDataGenerator.createProgramStartDate(false);
        psdStart.Program__c = prod.Id;
        psdStart.Accepting_New_Students__c = true;
        insert psdStart;
 	     
 	    Program_Start_Date__c psdEnd = TestDataGenerator.createProgramStartDate(false);
        psdEnd.Program__c = prod.Id;
        psdEnd.Accepting_New_Students__c = true;
        insert psdEnd;

        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = prod.Id;
        opp.Program_Start_Date__c = psdStart.Id;
        insert opp;
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.Program__c =prod.id;
        insert sProg;
        Date sDate = Date.newInstance(1960, 2, 1);
        Date eDate = Date.newInstance(1960, 6, 5);

		Script_Settings__c setting = new Script_Settings__c();
		setting.Name = 'Current Settings';
		setting.disableSubEndDateValidation__c = false;
		setting.disableSubMondayValidation__c = false;
		setting.CheckDateOnSubscriptionRenewal__c = true;
		
		insert setting;
        
        Test.startTest();
        Id standardPricebookId = Test.getStandardPricebookId();
        PricebookEntry stdEntry = new PricebookEntry();
        stdEntry.IsActive = true;
        stdEntry.Product2Id = prod.Id;
        stdEntry.Pricebook2Id = standardPricebookId;
        stdEntry.UnitPrice = 5555.00;
        insert stdEntry;
        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        Double cost = 3000.00;
        PricebookEntry entry = TestDataGenerator.createPricebookEntry(prod.Id, pBook.Id, cost, false, false);
        entry.Available_for_Existing_Students__c = true;
        insert entry;
        
    	Exemption__c exmp = TestDataGenerator.createExemption('Limited-Time Savings', 'Grant', true, 0, prod, true, null, 15, true, psdStart, psdEnd);
        Student_Discount__c stuDiscount = TestDataGenerator.createStudentDiscount(opp, sProg, exmp, true);

        Student_Subscription__c oldStuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        oldStuSub.Start_Date__c = Date.newInstance(1960, 2, 1);
        oldStuSub.Subscription_Status__c = 'RE = Registered';
        insert oldStuSub;
        
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        stuSub.Start_Date__c = Date.newInstance(2014, 10, 6);
        insert stuSub;	

        Student_Subscription_Exemptions__c stuSubExemption = TestDataGenerator.createStudentSubscriptionExemption(stuDiscount, stuSub, 'Walden', true);
  		// Implement test code
	}
	
}