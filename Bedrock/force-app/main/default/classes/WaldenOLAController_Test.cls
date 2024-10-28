/*******************************************************************
Name  : WaldenOLAController_Test
Author: Vinod Kumar (Appirio)
Modified By: 
Date  : November 13 , 2014
Description: test class for the test coverage of the controller calss WaldenOLAController
*************************************************************************/
@isTest
private class WaldenOLAController_Test {

    static testMethod void myUnitTest() {
        // create test data
        Account testAcc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(testAcc, false); 
        testCon.Email = 'test12@test12345.Com';
        testCon.Racial_Categories__c = 'Hispanic or Latino';
        insert testCon;
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        Opportunity opty = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, 'Walden', false);
        opty.Primary_Program__c = product2.ID;
        opty.Contact__c = testCon.ID;
        insert opty;
        Academic_History__c testAH =   TestDataGenerator.createAcademicHistory(testCon.ID,true);
        Employment_History__c testEH =   TestDataGenerator.createEmploymentHistory(testCon.ID,true);
        Program_Application_Requirement__c objPA =  TestDataGenerator.createProgramApplicationRequirement(true);
        Student_Application_Requirement__c  objSA = TestDataGenerator.createStudentApplicationRequirement(opty.id, objPA.id ,true);
        test.startTest();
        PageReference pageRef = Page.OLAInternalView;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(opty);
        WaldenOLAController objController  = new WaldenOLAController(sc);   
        system.assert(objController.opportunityContact != null);
        system.assert(objController.lstEmploymentHistory.size() > 0);  
    }
}