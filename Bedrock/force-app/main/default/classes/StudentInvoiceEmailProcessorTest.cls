/************************************************************************
Name  : StudentInvoiceEmailProcessorTest
Author: Sufia
Date  : 07/21/2021
Description: Test class for code coverage
Sufia : 07/21/2021 : - S-685961 : Test class for code coverage
*************************************************************************/
@isTest
public class StudentInvoiceEmailProcessorTest {
    static testMethod void testInvoiceFromLatestSub() {
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
        stuSub.Future_Term__c = true;
        stuSub.Subscription_Status__c = 'RE = Registered';
        stuSub.List_Price__c  = 200;
        insert stuSub;
        System.assertEquals(0,[select count() from Task]);
        Test.startTest();
        StudentInvoiceEmailProcessor.processStuProgramsAndSendInvoice(new Set<Id>{sProg.Id});
        Test.stopTest();
        //System.assertEquals(1,[select count() from Task]);
     }
    static testMethod void testInvoiceFromSecondLatestSub() {
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
        stuSub.Start_Date__c = Date.today().addDays(-2);
        stuSub.Future_Term__c = false;
        stuSub.Subscription_Status__c = 'RE = Registered';
        stuSub.List_Price__c  = 200;
        insert stuSub;
        System.assertEquals(0,[select count() from Task]);
        Test.startTest();
        StudentInvoiceEmailProcessor.processStuProgramsAndSendInvoice(new Set<Id>{sProg.Id});
        Test.stopTest();
        //System.assertEquals(1,[select count() from Task]);
     }
}