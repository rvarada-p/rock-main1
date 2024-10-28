/************************************************************************
Name  : BatchSendLOAEmailReminder_Test
Author: Horacio Sanchez
Date  : December 8, 2020
Description: batch class to test BatchSendLOAEmailReminder class
			 User Story 28147: Tempo: Automated LOAR email reminder
*************************************************************************/
@isTest
public class BatchSendLOAEmailReminder_Test {
	
    static testMethod void testmethodOne() {
        Account acc = TestDataGenerator.createAccount(true);
        
        Contact testCon = TestDataGenerator.createContact(acc, true);
        testCon.Email = 'test@test.com';
        testCon.Walden_Email__c = 'test@test.com';
        update testCon;
        
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.Id;
        insert product2;
        
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', true);
         
        Id standardPricebookId = Test.getStandardPricebookId();
        PricebookEntry stdEntry = new PricebookEntry();
        stdEntry.IsActive = true;
        stdEntry.Product2Id = parentProduct.Id;
        stdEntry.Pricebook2Id = standardPricebookId;
        stdEntry.UnitPrice = 5555.00;
        stdEntry.Tuition__c = 1555.00;
        stdEntry.Tech_Fee__c = 4000.00;
        insert stdEntry;
        
        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        
        Double cost = 3000.00;
        PricebookEntry entry = TestDataGenerator.createPricebookEntry(parentProduct.Id, pBook.Id, cost, false, false);
        entry.Available_for_Existing_Students__c = true;
        entry.Tuition__c = 1000.00;
        entry.Tech_Fee__c = 2000.00;
        insert entry;
        
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = Product2.Id;
        insert opp;
        
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.IsStudentProgramActive__c = true; 
        insert sProg;
        
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        stuSub.Start_Date__c = System.today().addDays(-25);
        insert stuSub;
        
        sProg.Current_Student_Subscription__c = stuSub.id;
        update sprog;
        
        Leave_of_Absence__c loa = new Leave_of_Absence__c();
        loa.From_Date__c = Date.today();
        loa.To_Date__c = (Date.today().addDays(14));
        loa.Student_s_Walden_Email__c = 'test@test.com';
        loa.Reason__c = 'P Personal';
        loa.Student_Program__c = sProg.Id;
        insert loa;
        
        Test.startTest();
        Database.executeBatch(new BatchSendLOAEmailReminder());
        
        BatchSendLOAEmailReminder objB = new BatchSendLOAEmailReminder();    
        String sch = '3 4 2 5 6 ?'; 
        system.schedule('BatchSendLOAEmailReminder', sch, objB); 
        Test.stopTest();   
    }
}