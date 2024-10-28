/*******************************************************************
Name  : SendLDEWarnings_Test
Author: Sarah Khalid (Laureate)
Date  : March 18, 2016
Description: Test Class for the SendLDEWarningsHelper and 
BatchSendLDEWarnings classes
*************************************************************************/
@isTest
private with sharing class SendLDEWarnings_Test {
    //Tests the execution of scheduled apex
    private static testmethod void testSendLDEWarning() {
        
        //Create Test Data    
        //Create Institutions to make enrollment steps
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c','Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity','Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProd = TestDataGenerator.createProduct('test', 'Walden', true); 
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProd.id;
        insert product2; 
        Institution__c waldenInstitution = [SELECT Id FROM Institution__c WHERE Name = 'Walden' LIMIT 1];
        
        
        Engagement_Rule__c engRule1 = TestDataGenerator.createEngagementRule('Met with Faculty Coach', waldenInstitution.Id, true, false);
        Engagement_Rule__c engRule2 = TestDataGenerator.createEngagementRule('Submitted or Updated Plan', waldenInstitution.Id,  true, false);
        Engagement_Rule__c engRule3 = TestDataGenerator.createEngagementRule('Raise My Hand to SME', waldenInstitution.Id,  true, false);
        Engagement_Rule__c engRule4 = TestDataGenerator.createEngagementRule('Test Eng Rule', waldenInstitution.Id,  true, false);
        List<Engagement_Rule__c> engRules = new List<Engagement_Rule__c>{engRule1, engRule2, engRule3, engRule4};
            insert engRules;
        
        
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, 'Walden', false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c =product2.id;    
        opty.StageName = 'Student';
        opty.Contact__c = testCon.ID;
        insert opty;
        
        
        
        Student_Program__c sp1 = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false);
        sp1.isstudentprogramactive__c = true;
        insert sp1;
        opty.Student_Program__c = sp1.id;  
        update opty;
        
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sp1, pb, 'Walden', false);
        stuSub.Start_Date__c = Date.today().addDays(-30);
        stuSub.Subscription_Status__c = 'RE = Registered';
        stuSub.End_Date__c = Date.today().addDays(10);
        insert stuSub;  
        
        
        sp1.Current_Student_Subscription__c = stuSub.Id;
        update sp1; 
        
        test.startTest();
        
        Student_Engagement_Rule__c stuEngRule = TestDataGenerator.createStudentEngagementRule(sp1.id, engRules[0].Id, true, true);
        stuEngRule.Last_Date_of_Engagement__c = System.today().addDays(-25);
        update stuEngRule;
        
        sp1 = [SELECT ID, Current_Student_Subscription__c,CurrentSubscriptionStartDate__c, isstudentprogramactive__c, Last_Date_of_Engagement__c,Days_Since_LDE__c FROM Student_Program__c WHERE ID = :sp1.Id];
        
        BatchSendLDEWarnings objBatch = new BatchSendLDEWarnings();      
        ID batchprocessid = Database.executeBatch(objBatch,10);   
        
        objBatch.execute(null);
        
        Test.stopTest();
    }
    
    //Tests the scenario for LDE equal to 18 and/or 25 days
    private static testmethod void testLDEWarningsLessThan30Days() {
        
        //Create Test Data    
        //Create Institutions to make enrollment steps
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c','Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity','Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProd = TestDataGenerator.createProduct('test', 'Walden', true); 
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProd.id;
        insert product2; 
        
        Institution__c waldenInstitution = [SELECT Id FROM Institution__c WHERE Name = 'Walden' LIMIT 1];
        
        Engagement_Rule__c engRule1 = TestDataGenerator.createEngagementRule('Met with Faculty Coach', waldenInstitution.Id, true, false);
        Engagement_Rule__c engRule2 = TestDataGenerator.createEngagementRule('Submitted or Updated Plan', waldenInstitution.Id,  true, false);
        Engagement_Rule__c engRule3 = TestDataGenerator.createEngagementRule('Raise My Hand to SME', waldenInstitution.Id,  true, false);
        Engagement_Rule__c engRule4 = TestDataGenerator.createEngagementRule('Test Eng Rule', waldenInstitution.Id,  true, false);
        List<Engagement_Rule__c> engRules = new List<Engagement_Rule__c>{engRule1, engRule2, engRule3, engRule4};
            insert engRules;
        
        
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, 'Walden', false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c =product2.id;    
        opty.StageName = 'Student';
        opty.Contact__c = testCon.ID;
        insert opty;
        
        Student_Program__c sp1 = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', true);
        opty.Student_Program__c = sp1.id;  
        update opty;
        
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sp1, pb, 'Walden', false);
        stuSub.Start_Date__c = Date.today().addDays(-30);
        stuSub.Subscription_Status__c = 'RE = Registered';
        stuSub.End_Date__c = Date.today().addDays(10);
        insert stuSub;  
        
        D2L__c d2L = new D2L__c();
        d2L.Name = 'D2L';
        d2L.Create_User_Endpoint__c = '/d2l/api/lp/(version)/users/';
        d2L.Student_Role_ID__c = 110;
        d2L.Create_Enrollment_Endpoint__c = '/d2l/api/lp/(version)/enrollments/';
        d2L.BS_LMS_URL__c = 'https://tempolearningtest.brightspace.com/d2l/home/';
        d2L.LP_Version__c = 1.18;
        d2L.Org_Unit_ID__c = 6606;
        d2L.Update_User__c = '/d2l/api/lp/(version)/users/(userId)';
        d2L.Unenrolled_Student_Role_ID__c = 116;
        d2L.Unenroll_Section_Endpoint__c = '/d2l/api/lp/(version)/enrollments/orgUnits/(orgUnitId)/users/(userId)';
        
        insert d2L;
        
        sp1.isstudentprogramactive__c = true;
        sp1.Current_Student_Subscription__c = stuSub.Id;
        update sp1; 
        
        Student_Engagement_Rule__c stuEngRule = TestDataGenerator.createStudentEngagementRule(sp1.id, engRules[0].Id, true, true);
        stuEngRule.Last_Date_of_Engagement__c = System.today().addDays(-25);
        update stuEngRule;
        
        sp1 = [SELECT ID, Current_Student_Subscription__c,CurrentSubscriptionStartDate__c, isstudentprogramactive__c, Last_Date_of_Engagement__c,Days_Since_LDE__c FROM Student_Program__c WHERE ID = :sp1.Id];
        
        list<string> groupemails = new list<String>();
        
        //Populate the emails for the coach public group 
        List<String> idList = new List<String>();
        Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE DeveloperName = 'Walden_Coach'];
        for (GroupMember gm : g.groupMembers) {
            idList.add(gm.userOrGroupId); 
        } 
        integer counter =0;
        User[] usr = [SELECT email FROM user WHERE id IN :idList];        
        for(User u : usr) {
            if(counter <=0){
            groupemails.add(u.email);
            counter++;
            }
        }
        
        test.startTest();
        
        String SOQL;     
        // get walden recordtype
        string waldenRecordType = Schema.SObjectType.Student_Program__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        SOQL = 'SELECT ID,Name, Days_Since_LDE__c, CoachEmail__c, Student__r.Id, Coach__r.Id  '
            + ' FROM Student_Program__c ' 
            + ' WHERE RecordTypeId =: waldenRecordType '
            + ' AND Days_Since_LDE__c in (18, 25, 31)';
        list<Student_Program__c> lst = (list<Student_Program__c>) Database.Query( SOQL );
        
        SendLDEWarningsHelper objbatch = new SendLDEWarningsHelper();
        objbatch.sendWarnings(lst, groupemails);        
        
        //objBatch.execute(null);
        Test.stopTest();
    }
    
    //Tests the scenario for LDE equal to or greater than 31 days 
    private static testmethod void testLDEWarningsMoreThan30Days() {
        
        //Create Test Data    
        //Create Institutions to make enrollment steps
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c','Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity','Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProd = TestDataGenerator.createProduct('test', 'Walden', true); 
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProd.id;
        insert product2; 
        
        Institution__c waldenInstitution = [SELECT Id FROM Institution__c WHERE Name = 'Walden' LIMIT 1];
        
        
        Engagement_Rule__c engRule1 = TestDataGenerator.createEngagementRule('Met with Faculty Coach', waldenInstitution.Id, true, false);
        Engagement_Rule__c engRule2 = TestDataGenerator.createEngagementRule('Submitted or Updated Plan', waldenInstitution.Id,  true, false);
        Engagement_Rule__c engRule3 = TestDataGenerator.createEngagementRule('Raise My Hand to SME', waldenInstitution.Id,  true, false);
        Engagement_Rule__c engRule4 = TestDataGenerator.createEngagementRule('Test Eng Rule', waldenInstitution.Id,  true, false);
        List<Engagement_Rule__c> engRules = new List<Engagement_Rule__c>{engRule1, engRule2, engRule3, engRule4};
            insert engRules;
        
        
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, 'Walden', false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c =product2.id;
        opty.StageName = 'Student';
        opty.Contact__c = testCon.ID;
        insert opty;
        
        
        Student_Program__c sp1 = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', true);
        opty.Student_Program__c = sp1.id;  
        update opty;
        
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sp1, pb, 'Walden', false);
        stuSub.Start_Date__c = Date.today().addDays(-31);
        stuSub.Subscription_Status__c = 'RE = Registered';
        stuSub.End_Date__c = Date.today().addDays(10);
        insert stuSub;  
        
        D2L__c d2L = new D2L__c();
        d2L.Name = 'D2L';
        d2L.Create_User_Endpoint__c = '/d2l/api/lp/(version)/users/';
        d2L.Student_Role_ID__c = 110;
        d2L.Create_Enrollment_Endpoint__c = '/d2l/api/lp/(version)/enrollments/';
        d2L.BS_LMS_URL__c = 'https://tempolearningtest.brightspace.com/d2l/home/';
        d2L.LP_Version__c = 1.18;
        d2L.Org_Unit_ID__c = 6606;
        d2L.Update_User__c = '/d2l/api/lp/(version)/users/(userId)';
        d2L.Unenrolled_Student_Role_ID__c = 116;
        d2L.Unenroll_Section_Endpoint__c = '/d2l/api/lp/(version)/enrollments/orgUnits/(orgUnitId)/users/(userId)';
        insert d2L;
        
        sp1.isstudentprogramactive__c = true;
        sp1.Current_Student_Subscription__c = stuSub.Id;
        update sp1; 
        
        Student_Engagement_Rule__c stuEngRule = TestDataGenerator.createStudentEngagementRule(sp1.id, engRules[0].Id, true, true);
        stuEngRule.Last_Date_of_Engagement__c = System.today().addDays(-31);
        update stuEngRule;
        
        sp1 = [SELECT ID, Current_Student_Subscription__c,CurrentSubscriptionStartDate__c, isstudentprogramactive__c, Last_Date_of_Engagement__c,Days_Since_LDE__c FROM Student_Program__c WHERE ID = :sp1.Id];
        
        list<string> groupemails = new list<String>();
        
        //Populate the emails for the coach public group 
        List<String> idList = new List<String>();
        Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE DeveloperName = 'Walden_Coach'];
        system.debug('ggroupMembersgroupMembers'+g.groupMembers.size());
        system.debug('ggroupMembersgroupMembers'+g.groupMembers);
        
        for (GroupMember gm : g.groupMembers) {
            idList.add(gm.userOrGroupId); 
            
        } 
        integer counter =0;
        User[] usr = [SELECT email FROM user WHERE id IN :idList];        
        for(User u : usr) {
            if(counter <=0){
            groupemails.add(u.email);
            counter++;
            }
        }
        
        
        
        test.startTest();
        
        String SOQL;     
        // get walden recordtype
        string waldenRecordType = Schema.SObjectType.Student_Program__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        SOQL = 'SELECT ID,Name, Days_Since_LDE__c, CoachEmail__c, Student__r.Id, Coach__r.Id  '
            + ' FROM Student_Program__c ' 
            + ' WHERE RecordTypeId =: waldenRecordType '
            + ' AND Days_Since_LDE__c in (18, 25, 31) LIMIT 2';
        list<Student_Program__c> lst = (list<Student_Program__c>) Database.Query( SOQL );
        system.debug('groupemails'+groupemails);
        system.debug('lst'+lst);
        SendLDEWarningsHelper objbatch = new SendLDEWarningsHelper();
        objbatch.sendWarnings(lst, groupemails);        
        //objBatch.execute(null);
        Test.stopTest();
    }     
}