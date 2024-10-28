/*******************************************************************
Name  : StudentProgramTriggerHelper_Test
Author: Samarth Mathur (Appirio)
Modified By: Vinod Kumar
Date  : October 07 , 2014
Related task : (Maybe) : 320076
Discription: Test Class for the Handler class StudentProgramTriggerHandler and trigger StudentProgramTrigger.
Also Covering the test coverage of the helper class StudentProgramHelper

Revision History

Ravitej Varada      - oct 12th 2020 -  S-23002 - Coach Assignment Logic change from program to stand alone(Enhancement)

*************************************************************************/

@isTest
private class StudentProgramTriggerHelper_Test {
    // test after insert triggger and createStudentEnrollmentSteps method from StudentProgramHelper class
    static void testCreateStudentEnrollmentSteps() {
        //Create Test Data    
        //Create Institutions to make enrollment steps
        Institution__c insti1 = new Institution__c();
        insti1.Name = 'Walden';
        insert insti1;
        list<Enrollment_Steps__c> lstEnrollmentSteps = new list<Enrollment_Steps__c>();
        Enrollment_Steps__c es1 = new Enrollment_Steps__c ();
        es1.Enrollment_Step_Name__c = 'I1 Step1';
        es1.Institution__c = insti1.id;
        lstEnrollmentSteps.add(es1);
        Enrollment_Steps__c es3 = new Enrollment_Steps__c ();
        es3.Enrollment_Step_Name__c = 'I1 Step2';
        es3.Institution__c = insti1.id;
        lstEnrollmentSteps.add(es3);
        insert lstEnrollmentSteps;
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c', 'Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProd = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProd.id;
        product2.Institution__c = insti1.id;
        product2.ProductCode = 'RNMSN';
        insert product2;
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c = product2.id;
        insert opty;
        Student_Program__c sp1 = TestDataGenerator.createStudentProgram(opty, testCon.ID, null, true);
        // test Student_Enrollment_Steps__c is created or not
        List<Student_Enrollment_Steps__c> newSES1 = [Select id, Name from Student_Enrollment_Steps__c where Student_Program__c = :sp1.ID];
        system.assertEquals(newSES1.size(), 2);
    }
    // test after insert triggger and bindStudentDiscountWithStudentProgram method from StudentProgramHelper class
    static void testBindStudentDiscountWithStudentProgram() {
        //Create Test Data    
        //Create Institutions to make enrollment steps
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c', 'Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_program__c = parentProduct.id;
        product2.ProductCode = 'RNMSN';
        
        insert product2;
        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = product2.Id;
        psd.Start_Date__c = TestDataGenerator.getFirstMondayOfMonth(Date.today() + 31);
        psd.Accepting_New_Students__c = true;
        insert psd;
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c = product2.id;
        opty.Program_Start_Date__c = psd.Id;
        insert opty;
        opty.Admissions_Status__c = 'AD Admitted';
        opty.Admissions_Status_Code__c = 'AD';
        opty.StageName = 'Recommend Admit';
        opty.opportunity_status_auto_values__c = 'Admitted';
        update opty;
        Exemption__c exc = new Exemption__c();
        exc.Name = 'Discount 1';
        exc.Flat_Rate_Amount__c = 300.50;
        exc.Institution__c = TestDataGenerator.createInstitution('Walden', true).Id;
        insert exc;
        // create student discount
        Student_Discount__c sdc = TestDataGenerator.createStudentDiscount(opty, null, exc, true);
        Student_Discount__c sdc2 = TestDataGenerator.createStudentDiscount(opty, null, exc, true);

        Student_Program__c sp1 = TestDataGenerator.createStudentProgram(opty, testCon.ID, null, true);
        List<Student_Discount__c> SD1 = [Select id, Name from Student_Discount__c where Student_Program__c = :sp1.ID];
        System.assertEquals(SD1.size(), 2);

    }
    // test after update triggger and updatesToStudentProgramUponOpportunityWin method from StudentProgramHelper class
    static void testUpdatesToStudentProgramUponOpportunityWin() {
        //Create Test Data    
        //Create Institutions to make enrollment steps


        Script_Settings__c settings = new Script_Settings__c();
        settings.name = 'Current Settings';
        settings.Coach_Assignment_Limit__c = 100;
        insert settings;

        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c', 'Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity', 'Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        product2.ProductCode = 'RNMSN';
        
        insert product2;
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, 'Walden', false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c = product2.id;
        insert opty;
        Student_Program__c sp1 = TestDataGenerator.createStudentProgram(opty, testCon.ID, 'Walden', true);
        opty.StageName = 'Student';
        opty.Student_Program__c = sp1.id;
        update opty;
        Student_Program__c updatedProgram = [Select id,Student_Enrollment_Status__c from Student_Program__c where id = :sp1.ID];
        System.assertEquals(updatedProgram.Student_Enrollment_Status__c, 'Eligible to Register (EL)');
    }
    // testpopulateProgramStartDateOfRelatedOpportunity
    /*static testMethod void testPopulateProgramStartDateOfRelatedOpportunity(){
//Create Test Data    
//Create Institutions to make enrollment steps
PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  
RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c','Walden', true);
RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity','Walden', true);
Account acc = TestDataGenerator.createAccount(true);
Contact testCon = TestDataGenerator.createContact(acc, true);
Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
Program_Start_Date__c psDate = TestDataGenerator.createProgramStartDate(false); 
psDate.Accepting_New_Students__c = true;
psDate.Program__c = product2.ID;
insert psDate;
Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, 'Walden', false);
opty.Initial_Price_Book__c = pb.id;
opty.Primary_Program__c = product2.id;       
insert opty;
Student_Program__c sp1 = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false);
sp1.Program__c = product2.id;   
sp1.Program_Start_Date__c =  psDate.ID;            
insert sp1;
Opportunity updatedOpty =[Select id,Program_Start_Date__c from Opportunity where id =: opty.ID]; 
System.assertEquals(updatedOpty.Program_Start_Date__c,psDate.Id);       
}*/
    static void testPopulateStartDateOnStudentSubScription() {
        //Create Test Data    
        //Create Institutions to make enrollment steps
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c', 'Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity', 'Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        product2.ProductCode = 'RNMSN';
        insert product2;
        Program_Start_Date__c psDate = TestDataGenerator.createProgramStartDate(false);
        psDate.Accepting_New_Students__c = true;
        psDate.Program__c = product2.ID;
        insert psDate;
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, 'Walden', false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c = product2.id;
        insert opty;
        Student_Program__c sp1 = TestDataGenerator.createStudentProgram(opty, testCon.ID, 'Walden', false);
        sp1.Program__c = product2.id;
        insert sp1;
        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        Double cost = 3000.00;
        PricebookEntry entry = TestDataGenerator.createPricebookEntry(parentProduct.Id, pBook.Id, cost, false, false);
        entry.Available_for_Existing_Students__c = true;
        //insert entry;        
        Student_Subscription__c oldStuSub = TestDataGenerator.createStudentSubscription(sp1, pBook, 'Walden', false);
        oldStuSub.Start_Date__c = Date.today().addDays(-10);
        oldStuSub.Number_of_Credits_Completed__c = 50;
        insert oldStuSub;
        sp1.Program_Start_Date__c = psDate.ID;
        sp1.Next_SAP_Date__c = system.today().addDays(60);
        sp1.LOA_Gap_Months__c = 5;
        update sp1;
        sp1.LOA_Gap_Months__c = 3;
        update sp1;
    }


    static testMethod void testPopulateAnticipatedGraduationDate() {
        //Create Test Data    
        //Create Institutions to make enrollment steps
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c', 'Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity', 'Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        product2.ProductCode = 'RNMSN';
        insert product2;
        Program_Start_Date__c psDate = TestDataGenerator.createProgramStartDate(false);
        psDate.Accepting_New_Students__c = true;
        psDate.Program__c = product2.ID;
        insert psDate;
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, 'Walden', false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c = product2.id;
        insert opty;
        Student_Program__c sp1 = TestDataGenerator.createStudentProgram(opty, testCon.ID, 'Walden', false);
        sp1.Program__c = product2.id;
        sp1.Program_Start_Date__c = psDate.Id;
        insert sp1;
        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        Double cost = 3000.00;
        PricebookEntry entry = TestDataGenerator.createPricebookEntry(product2.Id, pBook.Id, cost, false, false);
        entry.Available_for_Existing_Students__c = true;
        sp1.Program_Start_Date__c = psDate.ID;
        update sp1;
    }

    static testMethod void testCreatioOfEngagementRule() {
        //Create Test Data    
        //Create Institutions to make enrollment steps


        Script_Settings__c settings = new Script_Settings__c();
        settings.name = 'Current Settings';
        settings.Coach_Assignment_Limit__c = 100;
        insert settings;

        Profile coachProfile = [SELECT Id FROM Profile WHERE Name = 'CBL Coach'];
        User coachUser = new User(Alias = 'stdCL', Email = 'standardcoachuser@laurate.net',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = coachProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standardcoachuser@laurate.net', LMS_Id__c = 500);
        insert coachUser;

        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c', 'Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity', 'Walden', true);
        Account acc = TestDataGenerator.createAccount(true);

        Contact testCon = TestDataGenerator.createContact(acc, false);
        testCon.FirstName = 'Smith';
        testCon.LastName = 'Bob';
        insert testCon;


        Product2 parentProduct = TestDataGenerator.createProduct('B.S. in Nursing', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('B.S. in Nursing', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        product2.ProductCode = 'RNMSN';
        insert product2;


        Coach_Assignment__c coachAss = new Coach_Assignment__c();
        coachAss.Status__C = 'Active';
        coachAss.Program_names__c = 'B.S. in Nursing';
        coachAss.Coach__C = coachUser.id;
        insert coachAss;


        Institution__c waldenInstitution = [SELECT Id FROM Institution__c WHERE Name = 'Walden' LIMIT 1];

        Engagement_Rule__c engRule1 = TestDataGenerator.createEngagementRule('Met with Faculty Coach', waldenInstitution.Id, true, false);
        Engagement_Rule__c engRule2 = TestDataGenerator.createEngagementRule('Submitted or Updated Plan', waldenInstitution.Id, true, false);
        Engagement_Rule__c engRule3 = TestDataGenerator.createEngagementRule('Raise My Hand to SME', waldenInstitution.Id, true, false);
        Engagement_Rule__c engRule4 = TestDataGenerator.createEngagementRule('Test Eng Rule', waldenInstitution.Id, true, false);
        List<Engagement_Rule__c> engRules = new List<Engagement_Rule__c>{
                engRule1, engRule2, engRule3, engRule4
        };
        insert engRules;

        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, 'Walden', false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c = product2.id;
        opty.Contact__c = testCon.Id;
        insert opty;
        Student_Program__c sp1 = TestDataGenerator.createStudentProgram(opty, testCon.ID, 'Walden', false);
        sp1.Next_SAP_Date__c = system.today();
        insert sp1;

        opty.StageName = 'Student';
        opty.StageName = 'Student';
        opty.Student_Program__c = sp1.id;

        Student_Engagement_Rule__c stuEngRule = TestDataGenerator.createStudentEngagementRule(sp1.id, engRules[0].Id, true, true);

        update opty;

        Student_Program__c updatedProgram = [Select id,Student_Enrollment_Status__c from Student_Program__c where id = :sp1.ID];
        System.assertEquals(updatedProgram.Student_Enrollment_Status__c, 'Eligible to Register (EL)');

        sp1.IsStudentProgramActive__c = true;

        Update sp1;

    }

    static testMethod void testCoachAssignmentInBS() {
        D2L__c setting = new D2L__c();
        setting.Name = 'D2L';
        setting.LE_Version__c = 1.26;
        setting.Auditor_Auditee_End_Point__c = '/d2l/api/le/(version)/auditing/auditors/(auditorId)/auditees/';

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
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        product2.Total_Credits_in_Program__c = 50;
        product2.ProductCode = 'RNMSN';
        insert product2;
        Program_Start_Date__c psDate = TestDataGenerator.createProgramStartDate(false);
        psDate.Accepting_New_Students__c = true;
        psDate.Program__c = product2.ID;
        insert psDate;
        Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile1.Email__c = 'test12@test12345.Com';
        testProfile1.LMS_ID__c = 250;
        insert testProfile1;

        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, 'Walden', false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c = product2.id;
        insert opty;
        Student_Program__c sp1 = TestDataGenerator.createStudentProgram(opty, testCon.ID, 'Walden', false);
        sp1.Program__c = product2.id;
        sp1.Program_Start_Date__c = psDate.Id;
        sp1.Number_of_Credits_TransferredFulfilled__c = 25;
        sp1.Number_of_Credits_TransferredFulfilled__c = 50;
        insert sp1;
        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        Double cost = 3000.00;
        PricebookEntry entry = TestDataGenerator.createPricebookEntry(product2.Id, pBook.Id, cost, false, false);
        entry.Available_for_Existing_Students__c = true;
        sp1.Program_Start_Date__c = psDate.ID;
        sp1.Coach__c = coachUser.Id;
        sp1.Brand_Profile__c = testProfile1.Id;
        sp1.Next_SAP_Date__c = system.today().addDays(60);
        sp1.LOA_Gap_Months__c = 5;
        update sp1;
        sp1.LOA_Gap_Months__c = 3;
        update sp1;
        sp1.LOA_Gap_Months__c = 7;
        update sp1;
        sp1.LOA_Gap_Months__c = null;
        update sp1;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_BSAuditorAuditee());
        HttpResponse response = New HttpResponse();
        String json = '' + testProfile1.LMS_ID__c + '';
        BrightSpaceCalls.studentCoachEnrollment(json, sp1.Id, String.valueOf(coachUser.LMS_ID__c), '500');
        test.stopTest();

    }

    static testMethod void testCoachAssignmentInBS_NegativeCondition() {
        D2L__c setting = new D2L__c();
        setting.Name = 'D2L';
        setting.LE_Version__c = 1.26;
        setting.Auditor_Auditee_End_Point__c = '/d2l/api/le/(version)/auditing/auditors/(auditorId)/auditees/';

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
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        product2.Total_Credits_in_Program__c = 50;
        product2.ProductCode = 'RNMSN';
        insert product2;
        Program_Start_Date__c psDate = TestDataGenerator.createProgramStartDate(false);
        psDate.Accepting_New_Students__c = true;
        psDate.Program__c = product2.ID;
        insert psDate;
        Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile1.Email__c = 'test12@test12345.Com';
        testProfile1.LMS_ID__c = 250;
        insert testProfile1;

        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, 'Walden', false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c = product2.id;
        insert opty;
        Student_Program__c sp1 = TestDataGenerator.createStudentProgram(opty, testCon.ID, 'Walden', false);
        sp1.Program__c = product2.id;
        sp1.Program_Start_Date__c = psDate.Id;
        sp1.Number_of_Credits_TransferredFulfilled__c = 25;
        sp1.Number_of_Credits_TransferredFulfilled__c = 50;
        insert sp1;
        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        Double cost = 3000.00;
        PricebookEntry entry = TestDataGenerator.createPricebookEntry(product2.Id, pBook.Id, cost, false, false);
        entry.Available_for_Existing_Students__c = true;
        sp1.Program_Start_Date__c = psDate.ID;
        sp1.Coach__c = coachUser.Id;
        sp1.Brand_Profile__c = testProfile1.Id;
        update sp1;
        String json = '' + testProfile1.LMS_ID__c + '';
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_BSNegative());
        HttpResponse response = New HttpResponse();
        BrightSpaceCalls.studentCoachEnrollment(json, sp1.Id, String.valueOf(coachUser.LMS_ID__c), '500');
        test.stopTest();

    }

    static testMethod void testCoachAssignment() {
        D2L__c setting = new D2L__c();
        setting.Name = 'D2L';
        setting.LE_Version__c = 1.26;
        setting.Auditor_Auditee_End_Point__c = '/d2l/api/le/(version)/auditing/auditors/(auditorId)/auditees/';

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
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        product2.Total_Credits_in_Program__c = 50;
        product2.ProductCode = 'RNMSN';
        insert product2;
        Program_Start_Date__c psDate = TestDataGenerator.createProgramStartDate(false);
        psDate.Accepting_New_Students__c = true;
        psDate.Program__c = product2.ID;
        insert psDate;
        Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile1.Email__c = 'test12@test12345.Com';
        testProfile1.LMS_ID__c = 250;
        insert testProfile1;

        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, 'Walden', false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c = product2.id;
        insert opty;
        Student_Program__c sp1 = TestDataGenerator.createStudentProgram(opty, testCon.ID, 'Walden', false);
        sp1.Program__c = product2.id;
        sp1.Program_Start_Date__c = psDate.Id;
        sp1.Number_of_Credits_TransferredFulfilled__c = 25;
        sp1.Number_of_Credits_TransferredFulfilled__c = 50;
        insert sp1;
        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        Double cost = 3000.00;
        PricebookEntry entry = TestDataGenerator.createPricebookEntry(product2.Id, pBook.Id, cost, false, false);
        entry.Available_for_Existing_Students__c = true;
        sp1.Program_Start_Date__c = psDate.ID;
        sp1.Coach__c = coachUser.Id;
        sp1.Brand_Profile__c = testProfile1.Id;
        update sp1;
        String json = '' + testProfile1.LMS_ID__c + '';
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_BSNegative());
        HttpResponse response = New HttpResponse();
        BrightSpaceCalls.studentCoachEnrollment(json, sp1.Id, String.valueOf(coachUser.LMS_ID__c), '500');
        test.stopTest();

    }
}