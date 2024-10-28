/************************************************************************
Name  : BatchProcessCoachAssignment_Test
Author: Ravitej Varada, Walden University
Date  : August 15, 2017
Description: Test class for BatchProcessCoachAssignment


Revision History

Ravitej Varada      - oct 12th 2020 -  S-23002 - Coach Assignment Logic change from program to stand alone(Enhancement)

*************************************************************************/
//S-23002
@IsTest
public with sharing class BatchProcessCoachAssignment_Test {
    static testMethod void testCoachAssignmentActive() {
        Script_Settings__c setting = new Script_Settings__c();
        setting.Name = 'Current Settings';
        setting.Coach_Assignment_Limit__c = 100;
        insert setting;

        Profile coachProfile = [SELECT Id FROM Profile WHERE Name = 'CBL Coach'];
        User coachUser = new User(Alias = 'stdCL', Email = 'standardcoachuser@laurate.net',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = coachProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standardcoachuser@laurate.net', LMS_Id__c = 500);
        insert coachUser;
        //Create Test Data
        //Create Institutions to make enrollment steps
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c', 'Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity', 'Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, false);
        testCon.FirstName = 'Smith';
        testCon.LastName = 'Bob';
        insert testCon;


        testCon.Banner_Id__c = 'HA92828';
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        product2.Total_Credits_in_Program__c = 50;
        insert product2;

        Coach_Assignment__c coachAss = new Coach_Assignment__c();
        coachAss.Status__C = 'Active';
         coachAss.Coach__C = coachUser.id;
        insert coachAss;


        Program_Start_Date__c psDate = TestDataGenerator.createProgramStartDate(false);
        psDate.Accepting_New_Students__c = true;
        psDate.Program__c = product2.ID;
        insert psDate;


        Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile1.Email__c = 'test12@test12345.Com';
        testProfile1.LMS_ID__c = 250;
        insert testProfile1;

        opportunity testOpty1 = TestDataGenerator.createOpportunity(acc.id, testCon.id, 'Walden', false);
        testOpty1.Brand_Profile__c = testProfile1.id;
        insert testOpty1;
        testOpty1.Change_of_Specialization__c = true;
        testOpty1.StageName = 'Admitted' ;
        testOpty1.Admissions_Status__c = 'AD Admitted';
        testOpty1.Admissions_Status_Code__c = 'AD';
        testOpty1.StageName = 'Recommend Admit';
        testOpty1.opportunity_status_auto_values__c = 'Admitted';
        testOpty1.Initial_Price_Book__c = pb.id;
        testOpty1.Program_Start_Date__c = psDate.Id;
        testOpty1.Contact__c = testCon.id;
        update testOpty1;
        testOpty1.Initial_Price_Book__c = pb.id;
        //testOpty1.Primary_Program__c = product3.Id;
        testOpty1.StageName = 'Student' ;
        update testOpty1;


        Student_Program__c sp1 = TestDataGenerator.createStudentProgram(testOpty1, testCon.ID, 'Walden', false);
        sp1.Program__c = product2.id;
        sp1.Program_Start_Date__c = psDate.Id;
        sp1.Coach__c = coachUser.id;
        insert sp1;
        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;


        test.startTest();
         BatchProcessCoachAssignment objBatch = new BatchProcessCoachAssignment();
        ID batchprocessid = Database.executeBatch(objBatch, 200);
        test.stopTest();


    }
    //S-23002

    static testMethod void testCoachAssignmentInActive() {
        Script_Settings__c setting = new Script_Settings__c();
        setting.Name = 'Current Settings';
        setting.Coach_Assignment_Limit__c = 100;
        insert setting;

        Profile coachProfile = [SELECT Id FROM Profile WHERE Name = 'CBL Coach'];
        User coachUser = new User(Alias = 'stdCL', Email = 'standardcoachuser@laurate.net',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = coachProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standardcoachuser@laurate.net', LMS_Id__c = 500);
        insert coachUser;
        //Create Test Data
        //Create Institutions to make enrollment steps
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c', 'Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity', 'Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, false);
        testCon.FirstName = 'Smith';
        testCon.LastName = 'Bob';
        insert testCon;

        testCon.Banner_Id__c = 'HA92828';
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        product2.Total_Credits_in_Program__c = 50;
        insert product2;

        Coach_Assignment__c coachAss = new Coach_Assignment__c();
        coachAss.Status__C = 'Active';
         coachAss.Coach__C = coachUser.id;
        insert coachAss;


        Program_Start_Date__c psDate = TestDataGenerator.createProgramStartDate(false);
        psDate.Accepting_New_Students__c = true;
        psDate.Program__c = product2.ID;
        insert psDate;


        Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile1.Email__c = 'test12@test12345.Com';
        testProfile1.LMS_ID__c = 250;
        insert testProfile1;

        opportunity testOpty1 = TestDataGenerator.createOpportunity(acc.id, testCon.id, 'Walden', false);
        testOpty1.Brand_Profile__c = testProfile1.id;
        insert testOpty1;
        testOpty1.Change_of_Specialization__c = true;
        testOpty1.StageName = 'Admitted' ;
        testOpty1.Admissions_Status__c = 'AD Admitted';
        testOpty1.Admissions_Status_Code__c = 'AD';
        testOpty1.StageName = 'Recommend Admit';
        testOpty1.opportunity_status_auto_values__c = 'Admitted';
        testOpty1.Initial_Price_Book__c = pb.id;
        testOpty1.Program_Start_Date__c = psDate.Id;
        testOpty1.Contact__c = testCon.id;
        update testOpty1;
        testOpty1.Initial_Price_Book__c = pb.id;
        //testOpty1.Primary_Program__c = product3.Id;
        testOpty1.StageName = 'Student' ;
        update testOpty1;


        Student_Program__c sp1 = TestDataGenerator.createStudentProgram(testOpty1, testCon.ID, 'Walden', false);
        sp1.Program__c = product2.id;
        sp1.Program_Start_Date__c = psDate.Id;
        sp1.Coach__c = coachUser.id;
        sp1.IsStudentProgramActive__c = TRUE;
        insert sp1;
        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;

        test.startTest();
         Database.executeBatch(new BatchProcessCoachAssignment());
        String CRON_EXP = '0 0 0 15 3 ? *';

        String jobId = System.schedule('BatchProcessCoachAssignment',  CRON_EXP, new BatchProcessCoachAssignment());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        test.stopTest();

    }
}