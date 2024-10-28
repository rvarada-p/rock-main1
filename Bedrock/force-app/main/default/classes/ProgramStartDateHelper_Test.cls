/*******************************************************************
Name  : ProgramStartDateHelper_Test
Author: Vinod Kumar (Appirio)
Date  : November 7, 2014
Description: test class for the trigger ProgramStartDateTrigger and class ProgramStartDateHelper,ProgramStartDateTriggerHandler
*************************************************************************/
@isTest
private class ProgramStartDateHelper_Test {
	static RecordTypes_For_CBL_Processes__c recordtye2 = TestDataGenerator.createRecordTypesForCBLProcesses('Program Start Date', 'Program_Start_Date__c','Walden', true);
    static testMethod void testCalculateName() {
        // create test data
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Program_Start_Date__c tstStartDate  = TestDataGenerator.createProgramStartDate(false);
        tstStartDate.Name = 'testProgramStartdate';
        tstStartDate.Program__c = product2.Id;
        insert tstStartDate;
        Program_Start_Date__c updatedStartdate = [Select id,name from Program_Start_Date__c where id=: tstStartDate.Id];
        system.assert(updatedStartdate.name != 'testProgramStartdate');
        tstStartDate.Start_Date__c = Date.today().addDays(5);
        update tstStartDate;
        Program_Start_Date__c updatedStartdate2 = [Select id,name from Program_Start_Date__c where id=: tstStartDate.Id];
        system.assert(updatedStartdate.name != updatedStartdate2.name);

        Date testDate = Date.newInstance(2014, 12, 01);
        tstStartDate  = TestDataGenerator.createProgramStartDate(false);
        tstStartDate.Name = 'testProgramStartdate';
        tstStartDate.Program__c = product2.Id;
        tstStartDate.Start_Date__c = testDate;
        insert tstStartDate;
        updatedStartdate2 = [Select id,name from Program_Start_Date__c where id=: tstStartDate.Id];
        system.assert(updatedStartdate2.name == 'December 1st, 2014');
        testDate = Date.newInstance(2014, 12, 02);
        updatedStartdate2.Start_Date__c = testDate;
        update updatedStartdate2;
        updatedStartdate2 = [Select id,name from Program_Start_Date__c where id=: tstStartDate.Id];
        system.assert(updatedStartdate2.name == 'December 2nd, 2014');
        
    }
}