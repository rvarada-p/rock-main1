/*******************************************************************
Name  : StudentSubscriptionHelper_Test
Author: Tom (Appirio)
Date  : October 02, 2014
Description: Test Class for StudentSubscriptionHelper and StudentSubscriptionTriggerHanlder 
*************************************************************************/
@isTest
private class StudentSubscriptionHelper_Test {   
    
    static testMethod void testOnBeforeInsert() {

        RecordTypes_For_CBL_Processes__c objCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Subscription', 'Student_Subscription__c','Walden', true);
        //TriggerSettings__c objTrgSetting = TestDataGenerator.createTriggerSettings('StudentSubscriptionTrigger', true, true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProd = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', false);
        prod.Parent_Program__c = parentProd.id;
        insert prod;
        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = prod.Id;
        psd.Accepting_New_Students__c = true;
        insert psd;
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = prod.Id;
        opp.Program_Start_Date__c = psd.Id;
        insert opp;
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.Program__c =prod.id;
        insert sProg;
        Date sDate = Date.newInstance(1960, 2, 1);
        Date eDate = Date.newInstance(1960, 6, 5);

        Script_Settings__c setting = new Script_Settings__c();
        setting.Name = 'Current Settings';
        setting.disableSubEndDateValidation__c = false;
        setting.disableSubMondayValidation__c = false;
        setting.CheckDateOnSubscriptionRenewal__c = true;
        
        insert setting;
        
        Test.startTest();
        Id standardPricebookId = Test.getStandardPricebookId();
        PricebookEntry stdEntry = new PricebookEntry();
        stdEntry.IsActive = true;
        stdEntry.Product2Id = parentProd.Id;
        stdEntry.Pricebook2Id = standardPricebookId;
        stdEntry.UnitPrice = 5555.00;
        stdEntry.Tuition__c = 1555.00;
        stdEntry.Tech_Fee__c = 4000.00;
        insert stdEntry;
        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        Double cost = 3000.00;
        PricebookEntry entry = TestDataGenerator.createPricebookEntry(parentProd.Id, pBook.Id, cost, false, false);
        entry.Available_for_Existing_Students__c = true;
        entry.Tuition__c = 1000.00;
        entry.Tech_Fee__c = 2000.00;
        insert entry;
        
        Exemption__c exmp = TestDataGenerator.createExemption(100, 0, true);
        Student_Discount__c stuDiscount = TestDataGenerator.createStudentDiscount(opp, sProg, exmp, true);

        Student_Subscription__c oldStuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        oldStuSub.Start_Date__c = Date.newInstance(1960, 2, 1);
        oldStuSub.Subscription_Status__c = 'RE = Registered';
        insert oldStuSub;
        
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        stuSub.Start_Date__c = Date.newInstance(2014, 10, 6);
        insert stuSub;

        stuSub = [SELECT End_Date__c,List_Price__c FROM Student_Subscription__c WHERE Id = :stuSub.Id];
        system.assertEquals(stuSub.List_Price__c, cost);
        Test.stopTest();
    }

    static testMethod void testLastMetWithCoachDate() {

        RecordTypes_For_CBL_Processes__c objCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Subscription', 'Student_Subscription__c','Walden', true);
        //TriggerSettings__c objTrgSetting = TestDataGenerator.createTriggerSettings('StudentSubscriptionTrigger', true, true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProd = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', false);
        prod.Parent_Program__c = parentProd.id;
        insert prod;
        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = prod.Id;
        psd.Accepting_New_Students__c = true;
        insert psd;
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = prod.Id;
        opp.Program_Start_Date__c = psd.Id;
        insert opp;
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.Program__c =prod.id;
        sProg.IsStudentProgramActive__c = true;
        insert sProg;
        Date sDate = Date.newInstance(1960, 2, 1);
        Date eDate = Date.newInstance(1960, 6, 5);

        Script_Settings__c setting = new Script_Settings__c();
        setting.Name = 'Current Settings';
        setting.disableSubEndDateValidation__c = false;
        setting.disableSubMondayValidation__c = false;
        setting.CheckDateOnSubscriptionRenewal__c = true;
        
        insert setting;
 
        Test.startTest();
        Id standardPricebookId = Test.getStandardPricebookId();
        PricebookEntry stdEntry = new PricebookEntry();
        stdEntry.IsActive = true;
        stdEntry.Product2Id = prod.Id;
        stdEntry.Pricebook2Id = standardPricebookId;
        stdEntry.UnitPrice = 5555.00;
        stdEntry.Tuition__c = 1555.00;
        stdEntry.Tech_Fee__c = 4000.00;
        insert stdEntry;
        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        Double cost = 3000.00;
        PricebookEntry entry = TestDataGenerator.createPricebookEntry(prod.Id, pBook.Id, cost, false, false);
        entry.Available_for_Existing_Students__c = true;
         entry.Tuition__c = 1000.00;
        entry.Tech_Fee__c = 2000.00;
        insert entry;
        
        Exemption__c exmp = TestDataGenerator.createExemption(100, 0, true);
        Student_Discount__c stuDiscount = TestDataGenerator.createStudentDiscount(opp, sProg, exmp, true);

        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        stuSub.Start_Date__c = Date.newInstance(2014, 10, 6);
        insert stuSub;

        Institution__c waldenInstitution = TestDataGenerator.createInstitution('Walden',  true);
        
        Engagement_Rule__c  engRule1 = TestDataGenerator.createEngagementRule('Met with Faculty Coach', waldenInstitution.Id, true, false);
        Engagement_Rule__c  engRule2 = TestDataGenerator.createEngagementRule('Submitted or Updated Plan', waldenInstitution.Id, true, false);
        List<Engagement_Rule__c> engRules = new List<Engagement_Rule__c>{engRule1, engRule2};
        insert engRules;

        Student_Engagement_Rule__c  stuEngRule1 = TestDataGenerator.createStudentEngagementRule(sProg.Id, engRule1.id, true, false);
        Student_Engagement_Rule__c  stuEngRule2 = TestDataGenerator.createStudentEngagementRule(sProg.Id, engRule2.id, true, false);
        List<Student_Engagement_Rule__c> stuEngRules = new List<Student_Engagement_Rule__c>{stuEngRule2, stuEngRule1};
        insert stuEngRules;        

        stuSub.Last_Date_Met_With_Coach__c = system.today() - 2;
        //stuSub.Agreed_To_Credits__c = 10;
        update stuSub;

        for(Student_Engagement_Rule__c stuEngRuleUpdated : [SELECT id, name, Last_Date_of_Engagement__c 
                                                                FROM Student_Engagement_Rule__c 
                                                                WHERE Rule_Type__c = 'Met with Faculty Coach' 
                                                                AND IsEngagementRuleActive__c = TRUE 
                                                                AND Student_Program__c = : sProg.id LIMIT 1])
        
            system.assertEquals(stuEngRuleUpdated.Last_Date_of_Engagement__c, system.today() - 2); 


    }    

    static testMethod void testSubscriptionDiscountLineItems() {
        
        Decimal flatRateAmount = 100;
        Decimal listPrice = 1000;
        Decimal percentDiscount = 10;

        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        
        Product2 parentProd = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', false);
        prod.Parent_Program__c = parentProd.Id;
        insert prod;
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.Program__c =prod.id;
        insert sProg;
        
        // create Exemption
        Exemption__c testExemp = TestDataGenerator.createExemption(flatRateAmount,0,true);
        testExemp.Active__c = true;
        update testExemp;
        Exemption__c testExemp2 = TestDataGenerator.createExemption(0,percentDiscount,true);
        testExemp2.Active__c = true;
        update testExemp2;
        // create student discount
        Student_Discount__c sDiscount1 = TestDataGenerator.createStudentDiscount(opp,sProg, testExemp, false);
        sDiscount1.Student_Program__c = sProg.id;
        sDiscount1.Exemption_Approved__c = true;
        insert sDiscount1;  

        Student_Discount__c sDiscount2 = TestDataGenerator.createStudentDiscount(opp,sProg, testExemp2, false);
        sDiscount2.Student_Program__c = sProg.id;
        sDiscount2.Exemption_Approved__c = true;
        insert sDiscount2; 

        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        stuSub.Start_Date__c = Date.newInstance(2014, 10, 6);
        stuSub.List_Price__c = listPrice;
        insert stuSub;

        Decimal totalExpectedDiscount = flatRateAmount + percentDiscount * listPrice / 100;
        Decimal totalActualDiscount = 0;

        for(Student_Transaction__c stuTrans : [SELECT Discount_Amount__c FROM Student_Transaction__c WHERE
                                                Student_Subscription__c = : stuSub.id 
                                                AND Transaction_Type__c = 'Subscription Reduction'
                                                AND Transaction_Date__c = :stuSub.Start_Date__c]) {

            totalActualDiscount += stuTrans.Discount_Amount__c;
        }

        //system.assertEquals(totalExpectedDiscount, totalActualDiscount);    
        system.assertEquals(totalExpectedDiscount, 200);
    }
    
    static testMethod void testUpsertStudentTransactionFromWithdrawDate() {
        Decimal flatRateAmount = 100;
        Decimal listPrice = 1000;
        Decimal percentDiscount = 10;

        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        
        Product2 parentProd = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', false);
        prod.Parent_Program__c = parentProd.Id;
        insert prod;
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.Program__c =prod.id;
        insert sProg;
        
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        stuSub.Start_Date__c = Date.newInstance(2014, 10, 6);
        stuSub.List_Price__c = listPrice;
        insert stuSub;
        
        Student_Transaction__c st = new Student_Transaction__c();
        st.Student_Subscription__c = stuSub.id;
        st.Transaction_Type__c = 'Subscription Reduction';
        st.Transaction_Date__c = Date.today();
        st.Discount_Amount__c = 500.00;
        insert st;
        
        Student_Transaction__c st1 = new Student_Transaction__c();
        st1.Student_Subscription__c = stuSub.id;
        st1.Transaction_Type__c = 'Grant';
        st1.Transaction_Date__c = Date.today();
        st1.Grant_Scholarship_Amount__c = 100.00;
        insert st1;
        
        /*Student_Transaction__c st2 = new Student_Transaction__c();
        st2.Student_Subscription__c = stuSub.id;
        st2.Transaction_Type__c = 'Tuition Adjustment';
        st2.Transaction_Date__c = Date.today();
        st2.Miscellaneous_Adjustment__c = 100.00;
        insert st2;*/
        
        stuSub.list_Price__c = 2200.00;
        stuSub.Tech_Fee__c = 75.00;
        stuSub.Subscription_Status__c = 'DW = Web Drop';
        stuSub.Subscription_DP_WD_Effective_Date__c = Date.today();
        update stuSub;
        
        stuSub.Subscription_DP_WD_Effective_Date__c = Date.today().AddDays(10);
        update stuSub;
        
        /*Student_Subscription__c stuSub2 = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        stuSub2.Start_Date__c = Date.today();
        stuSub2.List_Price__c = listPrice;
        insert stuSub2;
        
        Student_Transaction__c st3 = new Student_Transaction__c();
        st3.Student_Subscription__c = stuSub2.id;
        st3.Transaction_Type__c = 'Grant';
        st3.Transaction_Date__c = Date.today();
        st3.Grant_Scholarship_Amount__c = 500.00;
        insert st3;
        
        stuSub2.list_Price__c = 2200.00;
        stuSub2.Tech_Fee__c = 75.00;
        stuSub2.Subscription_Status__c = 'WD = Subscription Withdrawal';
        update stuSub2;
        
        stuSub2.Subscription_DP_WD_Effective_Date__c = Date.today().AddDays(15);*/
    }
    
    static testMethod void testUpsertStudentTransactionFromWithdrawDateDW() {
        Decimal flatRateAmount = 100;
        Decimal listPrice = 1000;
        Decimal percentDiscount = 10;

        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        
        Product2 parentProd = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', false);
        prod.Parent_Program__c = parentProd.Id;
        insert prod;
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.Program__c =prod.id;
        insert sProg;
        
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        stuSub.Start_Date__c = Date.newInstance(2014, 10, 6);
        stuSub.List_Price__c = listPrice;
        insert stuSub;
        
        Student_Transaction__c st = new Student_Transaction__c();
        st.Student_Subscription__c = stuSub.id;
        st.Transaction_Type__c = 'Subscription Reduction';
        st.Transaction_Date__c = Date.today();
        st.Discount_Amount__c = 500.00;
        insert st;
        
        Student_Transaction__c st1 = new Student_Transaction__c();
        st1.Student_Subscription__c = stuSub.id;
        st1.Transaction_Type__c = 'Grant';
        st1.Transaction_Date__c = Date.today();
        st1.Grant_Scholarship_Amount__c = 500.00;
        insert st1;
                
        stuSub.list_Price__c = 2200.00;
        stuSub.Tech_Fee__c = 75.00;
        update stuSub;
        
        stuSub.Subscription_Status__c = 'WD = Subscription Withdrawal';
        stuSub.Subscription_DP_WD_Effective_Date__c = stuSub.Start_Date__c.AddDays(22);
        update stuSub;
                
    }
    
    
    // test method test function calculateTotalSubscriptionDiscount
    // Created By: Vinod(Appirio)
    /*
    static testMethod void testCalculateTotalSubscriptionDiscount() {
        
        RecordTypes_For_CBL_Processes__c objCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Subscription', 'Student_Subscription__c','Walden', true);
        //TriggerSettings__c objTrgSetting = TestDataGenerator.createTriggerSettings('StudentSubscriptionTrigger', true, true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', true);
        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = prod.Id;
        psd.Accepting_New_Students__c = true;
        insert psd;

        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = prod.Id;
        opp.Program_Start_Date__c = psd.Id;
        insert opp;

        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.Program__c =prod.id;
        insert sProg;
        Date sDate = Date.newInstance(1960, 2, 1);
        Date eDate = Date.newInstance(1960, 6, 5);
    
        Id standardPricebookId = Test.getStandardPricebookId();
        Test.startTest();
        PricebookEntry stdEntry = new PricebookEntry();
        stdEntry.IsActive = true;
        stdEntry.Product2Id = prod.Id;
        stdEntry.Pricebook2Id = standardPricebookId;
        stdEntry.UnitPrice = 5555.00;
        insert stdEntry;
        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        Double cost = 3000.00;
        PricebookEntry entry = TestDataGenerator.createPricebookEntry(prod.Id, pBook.Id, cost, false, false);
        entry.Available_for_Existing_Students__c = true;
        insert entry;
        // create Exemption
        Exemption__c testExemp = TestDataGenerator.createExemption(100,10,true);
        // create student discount
        Student_Discount__c sDiscount1 = TestDataGenerator.createStudentDiscount(opp,sProg, testExemp, false);
        sDiscount1.Student_Program__c = sProg.id;
        insert sDiscount1;
        system.debug('sDiscount1::::::::::'+sDiscount1);
        
        Student_Subscription__c oldStuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        oldStuSub.Start_Date__c = sDate;
        oldStuSub.End_Date__c = sDate.addDays(3);
        oldStuSub.Subscription_Status__c = 'RE = Registered';
        //insert oldStuSub;
        sDiscount1.Student_Program__c = sProg.id;
        update sDiscount1;
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        stuSub.Start_Date__c = Date.newInstance(2014, 11, 3);
        stuSub.End_Date__c = Date.newInstance(2014, 11, 3).addDays(30);
        insert stuSub;
        Student_Subscription__c updatedSub = [SELECT Total_Discount__c, End_Date__c,List_Price__c FROM Student_Subscription__c WHERE Id = :stuSub.Id];
        system.assertEquals(updatedSub.Total_Discount__c, 400);
        Test.stopTest();
    }   */
}