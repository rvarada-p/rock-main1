/*******************************************************************
Name  : StudentEnrollmentStepsList_Test
Author: Virendra (Appirio)
Date  : October 10, 2014
Description: Test Class for TestStudentEnrollmentStepsList_Controller
*************************************************************************/
@isTest
private class StudentEnrollmentStepsList_Test {
    
    static testMethod void testCourseDetais() {
        // Create Test Data
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProd = TestDataGenerator.createProduct('parent', 'Walden', true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', false);
        prod.Parent_Program__c = parentProd.id;
        insert prod;
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = prod.Id;
        insert opp;
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', true);
   
        list<Student_Enrollment_Steps__c> stdEnrollSteps = new list<Student_Enrollment_Steps__c>();
        Student_Enrollment_Steps__c stdEnrollmentSp1 = TestDataGenerator.createStudentEnrollmentSteps(sProg.Id, false);
        Student_Enrollment_Steps__c stdEnrollmentSp2 = TestDataGenerator.createStudentEnrollmentSteps(sProg.Id, false);
        Student_Enrollment_Steps__c stdEnrollmentSp3 = TestDataGenerator.createStudentEnrollmentSteps(sProg.Id, false);
        Student_Enrollment_Steps__c stdEnrollmentSp4 = TestDataGenerator.createStudentEnrollmentSteps(sProg.Id, false);
        stdEnrollSteps.add(stdEnrollmentSp1);
        stdEnrollSteps.add(stdEnrollmentSp2);
        stdEnrollSteps.add(stdEnrollmentSp3);
        stdEnrollSteps.add(stdEnrollmentSp4);
        insert stdEnrollSteps;
        
         test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(sProg);
            PageReference pageRef = Page.StudentEnrollmentStepsList;
            Test.setCurrentPage(pageRef);
         
            StudentEnrollmentStepsList_Controller cExtensions  = new StudentEnrollmentStepsList_Controller(sc);
            cExtensions.appSfId = stdEnrollmentSp4.Id;
           
            cExtensions.updateStudentEnrollmentSteps();
         test.stopTest();
         
    }
        
        
}