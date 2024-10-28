/*******************************************************************
Name  : StudentAssessmentTriggerHandler_Test
Author: Vinod (Appirio)
Date  : October 9, 2014
Description: Test class for the test coverage of trigger StudentAssessmentTrigger, class StudentAssessmentTriggerHandler
             and class StudentAssessmentTriggerHelper
*************************************************************************/
@isTest
private class StudentAssessmentTriggerHandler_Test {
    /*******************************************************************
    Method to test ollUpNumberOfStudentAssessmentAttemptOnStudentCompetency method
    Related task: T-324881
    ********************************************************************/
    static testMethod void testRollUpNumberOfStudentAssessmentAttemptOnStudentCompetency() {
        // create test data
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Assessment', 'Student_Assessment__c','Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Program_Competency__c pCompetemcy = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0, true);
        // create student competency
        Student_Competency__c sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency.Contact__c = testCon.id;
        sCometency.Program_Competency__c = pCompetemcy.ID;
        insert sCometency;
        // create Student_Assessment__c
        Student_Assessment__c sa1 = TestDataGenerator.createNewStudentAssessment(sCometency.Id,'A','Walden','Mastered',true);
        Student_Competency__c spupdatedCometency = [Select id,Status__c,Number_of_Assessment_Attempts__c from Student_Competency__c where id =:sCometency.Id];
        system.assertEquals(spupdatedCometency.Number_of_Assessment_Attempts__c, 1);
        system.assertEquals(spupdatedCometency.Status__c, 'Mastered');
        Student_Assessment__c sa2 = TestDataGenerator.createNewStudentAssessment(sCometency.Id,'B','Walden','Achieved',true);
        update sa2;
        spupdatedCometency = [Select id,Status__c,Number_of_Assessment_Attempts__c from Student_Competency__c where id =:sCometency.Id];
        system.assertEquals(spupdatedCometency.Status__c, 'Achieved');
        delete sa2;
        spupdatedCometency = [Select id,Status__c,Number_of_Assessment_Attempts__c from Student_Competency__c where id =:sCometency.Id];
        system.assertEquals(spupdatedCometency.Number_of_Assessment_Attempts__c, 1);
        system.assertEquals(spupdatedCometency.Status__c, 'Mastered');
        delete sa1;
        spupdatedCometency = [Select id,Status__c,Number_of_Assessment_Attempts__c from Student_Competency__c where id =:sCometency.Id];
        system.assertEquals(spupdatedCometency.Number_of_Assessment_Attempts__c, 0);
        system.assertEquals(spupdatedCometency.Status__c, 'Not Achieved');

        Student_Assessment__c sa3 = TestDataGenerator.createNewStudentAssessment(sCometency.Id,'B','Walden','Submitted',true);
        update sa3;
        spupdatedCometency = [Select id,Status__c,Number_of_Assessment_Attempts__c from Student_Competency__c where id =:sCometency.Id];
        system.assertEquals(spupdatedCometency.Status__c, 'Assessment Submitted');
    }
    static testMethod void testOnAfterDelete() {
        // create test data
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Assessment', 'Student_Assessment__c','Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Program_Competency__c pCompetemcy = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0, true);
        // create student competency
        Student_Competency__c sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency.Contact__c = testCon.id;
        sCometency.Program_Competency__c = pCompetemcy.ID;
        insert sCometency;
        // create Student_Assessment__c
        Student_Assessment__c sa1 = TestDataGenerator.createNewStudentAssessment(sCometency.Id,'A','Walden','Mastered',true);
        Student_Competency__c spupdatedCometency = [Select id,Status__c,Number_of_Assessment_Attempts__c from Student_Competency__c where id =:sCometency.Id];
        system.assertEquals(spupdatedCometency.Number_of_Assessment_Attempts__c, 1);
        system.assertEquals(spupdatedCometency.Status__c, 'Mastered');
        Student_Assessment__c sa2 = TestDataGenerator.createNewStudentAssessment(sCometency.Id,'B','Walden','Achieved',true);
        update sa2;
        spupdatedCometency = [Select id,Status__c,Number_of_Assessment_Attempts__c from Student_Competency__c where id =:sCometency.Id];
        system.assertEquals(spupdatedCometency.Status__c, 'Achieved');
        delete sa2;
        spupdatedCometency = [Select id,Status__c,Number_of_Assessment_Attempts__c from Student_Competency__c where id =:sCometency.Id];
        system.assertEquals(spupdatedCometency.Number_of_Assessment_Attempts__c, 1);
        system.assertEquals(spupdatedCometency.Status__c, 'Mastered');
        Student_Assessment__c sa3 = TestDataGenerator.createNewStudentAssessment(sCometency.Id,'B','Walden','Achieved',true);
        delete sa1;        
        Database.UndeleteResult result = Database.Undelete(sa1, false);
        Student_Assessment__c sa4 = TestDataGenerator.createNewStudentAssessment(sCometency.Id,'B','Walden','Submitted',true);
        delete sa3;  
        
    }
}