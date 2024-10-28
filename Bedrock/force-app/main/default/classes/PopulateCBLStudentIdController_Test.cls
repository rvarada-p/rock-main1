/*******************************************************************
Name  : PopulateCBLStudentIdController_Test
Author: Vinod (Appirio)
Date  : December 12, 2014
Description: test class for the controller class PopulateCBLStudentIdController
*************************************************************************/
@isTest
private class PopulateCBLStudentIdController_Test {
	 // test method for thes coverage of populateCBLStudentId function
    static testMethod void testPopulateCBLStudentId() {
        // Create test data
        Account testAcc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(testAcc,'Custom Person Account Contact', true);
        test.startTest();
        PageReference pageRef = Page.PopulateCBLStudentId;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(testCon);
        PopulateCBLStudentIdController objController  = new PopulateCBLStudentIdController(sc); 
        objController.populateCBLStudentId();
        Contact testUpdatedContact = [select ID,CBL_Student_ID__c from Contact where id=: testCon.id];
        system.assert(testUpdatedContact.CBL_Student_ID__c != null);            
       
    }
}