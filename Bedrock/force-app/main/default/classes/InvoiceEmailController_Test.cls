/*******************************************************************
Name  : InvoiceEmailController_Test
Author: Ravitej Varada - Laureate
Date  : November 29, 2017
Description: Test Class for the class InvoiceEmailController .
Covering the test coverage of the InvoiceEmailController.
*************************************************************************/
@istest
public class InvoiceEmailController_Test { 
    
    static Account acc;
    static Contact cont;    
    static Opportunity opp;
    static Student_Program__c studentProgram;

    
    static testmethod void test1()
        
    {
        
        acc = TestDataGenerator.createAccount(true);
        cont = TestDataGenerator.createContact(acc, true);
        
        Product2 parentProgram = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProgram.Id;
        product2.ProductCode = 'RNMSN';
        insert product2;
        opp = TestDataGenerator.createOpportunity(acc.Id, cont.Id, 'Walden', false);
        opp.Primary_Program__c = product2.id;
        insert opp;
        studentProgram = TestDataGenerator.createStudentProgram(opp, cont.Id, 'Walden', false);
        studentprogram.Sponsor_Billing__c =true;
        studentprogram.BK_Hold_Code__c=true;
        insert studentprogram ;
       
        Student_Subscription__c studentsub = new Student_Subscription__c();
        studentsub.Start_Date__c=date.today();
        studentsub.Student_Program__c=studentprogram.id;
        insert studentsub;
        
        Student_Transaction__c studenttransaction = new Student_Transaction__c();
        studenttransaction.Student_Subscription__c=studentsub .id;
        insert  studenttransaction;
        Learner_Outcome__c learneroutcome = new Learner_Outcome__c();
        learneroutcome.Student_Program__c=studentprogram.id;
        insert learneroutcome;
        Test.setCurrentPage(Page.CBL_Invoice);
        ApexPages.currentPage().getParameters().put('Id', studentsub.id);
        InvoiceEmailController invoice = new InvoiceEmailController();
        Student_Subscription__c stuSub  = invoice.stuSub;
        List<Student_Transaction__c> stuTrans = invoice.stuTrans;
    } 
}