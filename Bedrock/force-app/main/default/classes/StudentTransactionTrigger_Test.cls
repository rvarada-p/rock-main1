/*******************************************************************
Name  : StudentSubscriptionHelper_Test
Author: Tom (Appirio)
Date  : October 02, 2014
Description: Test Class for StudentTransactionTriggerHelper and StudentTransactionTriggerHandler 

Revision History
Horacio Sanchez - 05/11/2021 - S-48505: L2: Automatically create new Transaction for Grant Special Credit
*************************************************************************/
@isTest
private with sharing class StudentTransactionTrigger_Test {
	static testMethod void testTriggerHandler() {
       RecordTypes_For_CBL_Processes__c objCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Subscription', 'Student_Subscription__c','Walden', true);
        //TriggerSettings__c objTrgSetting = TestDataGenerator.createTriggerSettings('StudentSubscriptionTrigger', true, true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProd = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', false);
        prod.Parent_Program__c = parentProd.Id;
        insert prod;
        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = prod.Id;
        psd.Accepting_New_Students__c = true;
        insert psd;
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = prod.Id;
        opp.Program_Start_Date__c = psd.Id;
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
        setting.x1098T_cut_of_date__c = Date.today();
		
		insert setting;
        
        Test.startTest();
        
        Account sponsorAccount = TestDataGenerator.createSponsorAccount('Sponsor', true);
               
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
        
        Exemption__c exmp = TestDataGenerator.createExemption(100, 0, true);
        Student_Discount__c stuDiscount = TestDataGenerator.createStudentDiscount(opp, sProg, exmp, true);

        /*Student_Subscription__c oldStuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        oldStuSub.Start_Date__c = Date.newInstance(1960, 2, 1);
        oldStuSub.Subscription_Status__c = 'RE = Registered';
        insert oldStuSub;*/
        
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        stuSub.Start_Date__c = Date.newInstance(2014, 10, 6);
        insert stuSub;
		
		Student_Sponsorship__c stuSponsorhsip = TestDataGenerator.createStudentSponsorship(stuSub.Id,sponsorAccount.Id, 500, System.today()+10, true);
		
		Student_Transaction__c stuTransaction = TestDataGenerator.createStudentTransaction(stuSub.Id,sponsorAccount.Id, 100, 'Sponsor Payment', System.today(), true);
		stuTransaction.Grant_Scholarship_Amount__c = 150;
        stuTransaction.Transaction_Type__c = 'Grant';
        stuTransaction.Transaction_Date__c = Date.newInstance(System.today().year() + 1, System.today().month(), System.today().day());
		update stuTransaction;
        
        stuTransaction.Transaction_Date__c = Date.newInstance(System.today().year() - 1, System.today().month(), System.today().day());
		update stuTransaction;
        
		delete stuTransaction;
	}
    
    // Test method for S-48505: L2: Automatically create new Transaction for Grant Special Credit
    // Will insert a Student Transaction of type Grant Special Credit; Total Payments and Charges for Student Subscription should be 0
    static testMethod void testGrantSpecialCreditTransactionInsert() {
       RecordTypes_For_CBL_Processes__c objCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Subscription', 'Student_Subscription__c','Walden', true);
        //TriggerSettings__c objTrgSetting = TestDataGenerator.createTriggerSettings('StudentSubscriptionTrigger', true, true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProd = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', false);
        prod.Parent_Program__c = parentProd.Id;
        insert prod;
        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = prod.Id;
        psd.Accepting_New_Students__c = true;
        insert psd;
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = prod.Id;
        opp.Program_Start_Date__c = psd.Id;
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
        setting.x1098T_cut_of_date__c = Date.today();
		
		insert setting;
        
        Account sponsorAccount = TestDataGenerator.createSponsorAccount('Sponsor', true);
               
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
        
        Exemption__c exmp = TestDataGenerator.createExemption(100, 0, true);
        Student_Discount__c stuDiscount = TestDataGenerator.createStudentDiscount(opp, sProg, exmp, true);

        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        stuSub.Start_Date__c = Date.newInstance(2014, 10, 6);
        insert stuSub;
		
		Student_Sponsorship__c stuSponsorhsip = TestDataGenerator.createStudentSponsorship(stuSub.Id,sponsorAccount.Id, 500, System.today()+10, true);
        
        Test.startTest();
        
        Student_Subscription__c qStudentSubscription = [SELECT Id, Total_Payments_and_Charges__c FROM Student_Subscription__c WHERE Id = :stuSub.Id LIMIT 1];
        System.assertEquals(null, qStudentSubscription.Total_Payments_and_Charges__c);
		
		Student_Transaction__c stuTransaction = TestDataGenerator.createStudentTransaction(stuSub.Id,sponsorAccount.Id, 100, 'Grant Special Credit', System.today(), false);
        stuTransaction.Transaction_Note__c = 'Note';
        insert stuTransaction;
        
        qStudentSubscription = [SELECT Id, Total_Payments_and_Charges__c FROM Student_Subscription__c WHERE Id = :stuSub.Id LIMIT 1];
        System.assertEquals(null, qStudentSubscription.Total_Payments_and_Charges__c);
		
        Test.stopTest();
	}
}