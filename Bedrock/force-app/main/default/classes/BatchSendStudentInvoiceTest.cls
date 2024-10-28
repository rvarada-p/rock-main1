/*******************************************************************
Name  : BatchSendStudentInvoiceTest
Author: Sufia
Date  : July 20, 2021
Description: Test class for BatchSendStudentInvoice
*************************************************************************/

@isTest
public class BatchSendStudentInvoiceTest {
  static testMethod void testInvoiceProcessorBatch() {
        Institution__c inst = new Institution__c();
        inst.Name = 'Walden';
        insert inst;
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        product2.Institution__c = inst.id;
        product2.ProductCode='RNMSN';
        insert product2;
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  
        Opportunity oppty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false);
        oppty.Initial_Price_Book__c = pb.id;
        oppty.Primary_Program__c =product2.id;
        insert oppty;
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(oppty,testCon.ID, null, false);
        sProg.Student_s_Walden_Email__c ='test@mail.com';
        insert sProg;
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pb, 'Walden', false);
        stuSub.Start_Date__c = Date.today().addDays(20);
        //stuSub.Future_Term__c = true;
        stuSub.Subscription_Status__c = 'RE = Registered';
        stuSub.List_Price__c  = 200;
        insert stuSub;
        System.assertEquals(0,[select count() from Task]);
        Test.startTest();
        Database.executeBatch(new BatchSendStudentInvoice());
        String sch = '0 0 12 20 1/1 ? *';
		system.schedule('Test status Check', sch, new BatchSendStudentInvoice() );
        Test.stopTest();
        //System.assertEquals(1,[select count() from Task]);
     }
}