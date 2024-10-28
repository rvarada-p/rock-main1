/*******************************************************************
Name  : CustomLookupCtrl_Test
Author: Ravitej Varada - Laureate
Date  : November 29, 2017
Description: Test Class for the class InvoiceEmailController .
Covering the test coverage of the InvoiceEmailController.
*************************************************************************/
@IsTest 
public class CustomLookupCtrl_Test {
    Public static Student_Program__c studentprogram;
    Public static opportunity opp;
    Public static contact testCon;
    Public static Product2 prod;
    Public static Pricebook2 pBook; 
    static testmethod void test1()
        
    {
        Account acc = TestDataGenerator.createAccount(true);
        testCon = TestDataGenerator.createContact(acc, false);
        testCon.Carry_Over_Amount__c = 77;
        testCon.SSN__c = '238328923';
        insert testCon;
        
        Product2 parentProd = TestDataGenerator.createProduct('test', 'Walden', true);
        prod = TestDataGenerator.createProduct('test', 'Walden', false);
        prod.Parent_Program__c = parentProd.id;
        insert prod;
        
        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = prod.Id;
        psd.Accepting_New_Students__c = true;
        insert psd;
        
        opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = prod.Id;
        opp.Program_Start_Date__c = psd.Id;
        insert opp;
        
        
        studentprogram = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        studentprogram.Program__c =prod.id;
        
        studentprogram.Sponsor_Billing__c =true;
        studentprogram.BK_Hold_Code__c=true;
        insert studentprogram ;
        
        Student_Subscription__c studentsub = new Student_Subscription__c();
        studentsub.Start_Date__c=date.today();
        studentsub.Student_Program__c=studentprogram.id;
        // studentsub.Name='Test student';
        insert studentsub;
        Student_Transaction__c studenttransaction = new Student_Transaction__c();
        //studenttransaction.Name='test trasaction';
        studenttransaction.Student_Subscription__c=studentsub .id;
        insert  studenttransaction;
        Learner_Outcome__c learneroutcome = new Learner_Outcome__c();
        learneroutcome.Student_Program__c=studentprogram.id;
        insert learneroutcome;
        // Test.setCurrentPage(Page.CBL_Invoice);
        // ApexPages.currentPage().getParameters().put('Id', studentsub.id);
        CustomLookupCtrl cusLookCtr = new CustomLookupCtrl();
        cusLookCtr.selectedId = studentprogram.id;
        cusLookCtr.fieldName = 'Name';
        cusLookCtr.objName = 'Student_Program__c';
        cusLookCtr.getSelectedRecord();
    }
    
}