/*******************************************************************
Name  : SendStudentAssessmentResult_Test
Author: Sarah Khalid - Laureate 
Date  : August 12, 2015
Description: Test class for the test coverage of class SendStudentAssessmentResult
*************************************************************************/
@isTest
private class SendStudentAssessmentResult_Test {
	
	static testmethod void copyEmailAddressToStudentAssessment()
	{	
	    RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Assessment', 'Student_Assessment__c','Walden', true);
	    Account acc = TestDataGenerator.createAccount(true);
	    Contact testCon = TestDataGenerator.createContact(acc, true);
	    Competency__c testComp = TestDataGenerator.createCompetency(true);
	    Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
	    Program_Competency__c pCompetemcy = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0, true);
	    // create student competency
	    Student_Competency__c sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
	  	sCometency.Contact__c = testCon.Id;
	    sCometency.Program_Competency__c = pCompetemcy.ID;
	    insert sCometency; 
	    // create Student_Assessment__c
	    Student_Assessment__c sa1 = TestDataGenerator.createNewStudentAssessment(sCometency.Id,'A','Walden','Mastered',true);
	    Student_Competency__c spupdatedCometency = [Select id,Status__c,Number_of_Assessment_Attempts__c from Student_Competency__c where id =:sCometency.Id];
	    system.assertEquals(spupdatedCometency.Number_of_Assessment_Attempts__c, 1);
	    //system.assertEquals(spupdatedCometency.Status__c, 'Mastered');
	    Student_Assessment__c sa2 = TestDataGenerator.createNewStudentAssessment(sCometency.Id,'B','Walden','Achieved',true);
	    update sa2;
	
		List<Id> assessmentIds = new List<Id>();
		assessmentIds.add(sa1.Id);
		assessmentIds.add(sa2.Id);
		
		SendStudentAssessmentResult.updateEmailAddress(assessmentIds);	

	}
}