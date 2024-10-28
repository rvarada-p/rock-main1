/*******************************************************************
Name  : SubscriptionRenewalVerificationHelperTes
Author: Vinod Kumar (Appirio)
Modified By: 
Date  : january 22 , 2015
Description: test class for the test coverage of the calss SubscriptionRenewalVerificationHelper
*************************************************************************/
@isTest
private class SubscriptionRenewalVerificationHelperTes {
    
    static Program_Start_Date__c progStartDate;
    static PriceBook2 pb;
    static Contact testCon;
    static Opportunity opty;
    static Hold_Codes__c hCode1;
    static String SOQL1; 
    static Date toDay;
    static Date fourDayAgoDate;
    static string wladenRecordType;
    static Student_Program__c sProg;
    static list<Student_Subscription__c> lstStudentSubscription;
    static boolean renewalDenied;

    static void createTestData(Date startDate) {

        Date sDate = Date.today().adddays(-1);
        progStartDate = new Program_Start_Date__c();
        progStartDate.Name = 'Test';
        progStartDate.Start_Date__c = startDate;
        progStartDate.Accepting_New_Students__c = true;
        insert progStartDate;

        pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  
        
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Competency', 'Student_Competency__c','Walden', true);
        
        Account acc = TestDataGenerator.createAccount(true);
        testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.Id;
product2.Degree_Level__c = 'Graduate';
        insert product2;
        opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c =product2.id;
        insert opty;
        
        toDay = Date.today();
        // date four day ago        
        fourDayAgoDate = toDay.addDays(-4); // most recent subscription started at least 4 days ago
        
        // get walden recordtype 
        wladenRecordType = Schema.SObjectType.Student_Program__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        
        sProg = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false, 'Academic Warning (AW)', true, progStartDate.id); 
        sProg.Credits_Brought_into_Program__c = 2;
        insert sProg;
        
        lstStudentSubscription = new list<Student_Subscription__c>();        

        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pb, 'Walden', false, sDate, 4, 3);
        lstStudentSubscription.add(stuSub);     

        Student_Subscription__c stuSub1 = TestDataGenerator.createStudentSubscription(sProg, pb, 'Walden', false, sDate, 4, 8);
        stuSub1.End_Date__c = Date.today().addDays(4);
        stuSub1.Start_Date__c = Date.today();
        lstStudentSubscription.add(stuSub1);
    }

    static testMethod void completed2OrMoreAcademicCompetenciesCurrentTerm() {
        
        createTestData(Date.today().adddays(-10));
        
        Test.StartTest();
        insert lstStudentSubscription;

        list<Student_Program__c> updatedStudentProgram = new list<Student_Program__c>();
        sProg.Current_Student_Subscription__c = lstStudentSubscription[1].id;
        updatedStudentProgram.add(sProg);

        update updatedStudentProgram;

        createHoldCodeRecord();

        list<Student_Program__c> lst = getStudentProgramData();    
        
        SubscriptionRenewalVerificationHelper objHelper = new SubscriptionRenewalVerificationHelper();
        objHelper.SubscriptionRenewalVerification(lst);

        //system.assertEquals('S � Satisfactory', getSapCode());
        system.debug(getSapCode());
        
        //To cover batch
        BatchSubscriptionRenewalVerification obj = new BatchSubscriptionRenewalVerification();
        Database.executeBatch(obj, 200);

        Test.stopTest();
    }

    static testMethod void completedLessThan2AcademicCompetenciesCurrentTerm() {
        
        createTestData(Date.today().adddays(-10));
        
        Test.StartTest();

        lstStudentSubscription[1].Number_of_Competencies_Completed__c = 1;
        lstStudentSubscription[0].Number_of_Competencies_Completed__c = 0;

        insert lstStudentSubscription;

        list<Student_Program__c> updatedStudentProgram = new list<Student_Program__c>();
        sProg.Current_Student_Subscription__c = lstStudentSubscription[1].id;
        updatedStudentProgram.add(sProg);

        update updatedStudentProgram;

        createHoldCodeRecord();

        list<Student_Program__c> lst = getStudentProgramData();      
        
        SubscriptionRenewalVerificationHelper objHelper = new SubscriptionRenewalVerificationHelper();
        objHelper.SubscriptionRenewalVerification(lst);

        //system.assertEquals('D - Denied', getSapCode());
		 system.debug(getSapCode());
		 
        Test.stopTest();
    }

    static testMethod void enrolledForSixMonthsEarnedHalfCredit() {
        
        createTestData(Date.today().addMonths(-6));
        Test.StartTest();

        lstStudentSubscription[1].Number_of_Credits_Completed__c = 4;
        lstStudentSubscription[0].Number_of_Credits_Completed__c = 8;

        lstStudentSubscription[1].Agreed_to_credits__c = 6;
        lstStudentSubscription[0].Agreed_to_credits__c = 8;

        lstStudentSubscription[1].Start_Date__c = Date.today().adddays(-35);
        

        insert lstStudentSubscription;

        list<Student_Program__c> updatedStudentProgram = new list<Student_Program__c>();
        sProg.Current_Student_Subscription__c = lstStudentSubscription[1].id;
        updatedStudentProgram.add(sProg);
        update updatedStudentProgram;

        createHoldCodeRecord();

        list<Student_Program__c> lst = getStudentProgramData();      
        
        SubscriptionRenewalVerificationHelper objHelper = new SubscriptionRenewalVerificationHelper();
        objHelper.SubscriptionRenewalVerification(lst);

        //system.assertEquals('S � Satisfactory', getSapCode());

        Test.stopTest();
    }

    static testMethod void enrolledForSixMonthsNotEarnedHalfCredit() {
        
        createTestData(Date.today().addMonths(-6));

        Test.StartTest();

        lstStudentSubscription[1].Number_of_Credits_Completed__c = 2;
        lstStudentSubscription[0].Number_of_Credits_Completed__c = 3;

        lstStudentSubscription[1].Agreed_to_credits__c = 6;
        lstStudentSubscription[0].Agreed_to_credits__c = 8;

        lstStudentSubscription[1].Start_Date__c = Date.today().adddays(-35);
        

        insert lstStudentSubscription;

        list<Student_Program__c> updatedStudentProgram = new list<Student_Program__c>();
        sProg.Current_Student_Subscription__c = lstStudentSubscription[1].id;
        updatedStudentProgram.add(sProg);

        update updatedStudentProgram;

        createHoldCodeRecord();

        list<Student_Program__c> lst = getStudentProgramData();   
        
        SubscriptionRenewalVerificationHelper objHelper = new SubscriptionRenewalVerificationHelper();
        objHelper.SubscriptionRenewalVerification(lst);

        //system.assertEquals('W - Warning', getSapCode());
		 system.debug(getSapCode());
		 
        Test.stopTest();
    }   

    static testMethod void enrolledForTwelveMonthsEarnedHalfCredit() {
        
        createTestData(Date.today().addMonths(-12));
        Test.StartTest();

        lstStudentSubscription[1].Number_of_Credits_Completed__c = 4;
        lstStudentSubscription[0].Number_of_Credits_Completed__c = 8;

        lstStudentSubscription[1].Agreed_to_credits__c = 6;
        lstStudentSubscription[0].Agreed_to_credits__c = 8;

        lstStudentSubscription[1].Start_Date__c = Date.today().adddays(-35);
        

        insert lstStudentSubscription;

        list<Student_Program__c> updatedStudentProgram = new list<Student_Program__c>();
        sProg.Current_Student_Subscription__c = lstStudentSubscription[1].id;
        updatedStudentProgram.add(sProg);

        update updatedStudentProgram;

        createHoldCodeRecord();

        list<Student_Program__c> lst = getStudentProgramData();     
        
        SubscriptionRenewalVerificationHelper objHelper = new SubscriptionRenewalVerificationHelper();
        objHelper.SubscriptionRenewalVerification(lst);

        //system.assertEquals('S � Satisfactory', getSapCode());
         system.debug(getSapCode());

        Test.stopTest();
    }    

    static testMethod void enrolledForTwelveMonthsNotEarnedHalfCredit1() {
        
        createTestData(Date.today().addMonths(-12));
        Test.StartTest();

        lstStudentSubscription[1].Number_of_Credits_Completed__c = 2;
        lstStudentSubscription[0].Number_of_Credits_Completed__c = 3;

        lstStudentSubscription[1].Agreed_to_credits__c = 6;
        lstStudentSubscription[0].Agreed_to_credits__c = 8;

        lstStudentSubscription[1].Start_Date__c = Date.today().adddays(-35);
        

        insert lstStudentSubscription;

        list<Student_Program__c> updatedStudentProgram = new list<Student_Program__c>();
        sProg.Current_Student_Subscription__c = lstStudentSubscription[1].id;
        sProg.SAP_Code__c = 'W - Warning';
        updatedStudentProgram.add(sProg);

        update updatedStudentProgram;

        createHoldCodeRecord();

        list<Student_Program__c> lst = getStudentProgramData();     
        
        SubscriptionRenewalVerificationHelper objHelper = new SubscriptionRenewalVerificationHelper();
        objHelper.SubscriptionRenewalVerification(lst);

        //system.assertEquals('D - Denied', getSapCode());
         system.debug(getSapCode());

        Test.stopTest();
    }    

    static testMethod void enrolledForTwelveMonthsNotEarnedHalfCredit2() {
        
        createTestData(Date.today().addMonths(-12));
        Test.StartTest();

        lstStudentSubscription[1].Number_of_Credits_Completed__c = 2;
        lstStudentSubscription[0].Number_of_Credits_Completed__c = 3;

        lstStudentSubscription[1].Agreed_to_credits__c = 6;
        lstStudentSubscription[0].Agreed_to_credits__c = 8;

        lstStudentSubscription[1].Start_Date__c = Date.today().adddays(-35);
        

        insert lstStudentSubscription;

        list<Student_Program__c> updatedStudentProgram = new list<Student_Program__c>();
        sProg.Current_Student_Subscription__c = lstStudentSubscription[1].id;
        sProg.SAP_Code__c = 'S � Satisfactory';
        updatedStudentProgram.add(sProg);

        update updatedStudentProgram;

        createHoldCodeRecord();

        list<Student_Program__c> lst = getStudentProgramData();    
        
        SubscriptionRenewalVerificationHelper objHelper = new SubscriptionRenewalVerificationHelper();
        objHelper.SubscriptionRenewalVerification(lst);

        //system.assertEquals('W - Warning', getSapCode());
         system.debug(getSapCode());

        Test.stopTest();
    }   

    static testMethod void misc() {

        createTestData(Date.today().adddays(-10));
        
        Test.StartTest();
        lstStudentSubscription[1].Start_Date__c = Date.today().adddays(-2);
        insert lstStudentSubscription;

        list<Student_Program__c> updatedStudentProgram = new list<Student_Program__c>();
        sProg.Current_Student_Subscription__c = lstStudentSubscription[1].id;
        sProg.Number_of_Competencies_Transferred__c = 2;
        sProg.Number_of_Competencies__c = 10;
        updatedStudentProgram.add(sProg);

        update updatedStudentProgram;

        createHoldCodeRecord();

        list<Student_Program__c> lst = getStudentProgramData();    
        
        SubscriptionRenewalVerificationHelper objHelper = new SubscriptionRenewalVerificationHelper();
        objHelper.SubscriptionRenewalVerification(lst);
        getSapCode();
        //system.assertEquals(renewalDenied, true);

        Test.stopTest();           
    }

    public static void createHoldCodeRecord() {
        hCode1 = TestDataGenerator.createHoldCode(true);
        Student_Hold_Code__c sHoldCode = TestDataGenerator.createStudentHoldCode(hCode1.id ,sProg.id ,false);
        sHoldCode.Hold_Close_Date__c = Date.today().addDays(2);
        insert sHoldCode;         
    }

    public static list<Student_Program__c> getStudentProgramData() {
        
        SOQL1 = 'SELECT Renewal_Denied__c, Renewal_Denied_Comment__c, Number_of_Enrolled_Terms__c,Competencies_Completed_in_Trial__c,' 
               + 'Number_of_Competencies_Completed__c, IsStudentProgramActive__c, Id, CurrentSubscriptionStartDate__c, CurrentSubscriptionEndDate__c,'
               + 'Current_Student_Subscription__c, Application__c,Number_of_Competencies_Transferred__c,Program__c,'
               + 'Number_of_Competencies__c,Application__r.Admissions_Contingency__c, SAP_Code__c,Program__r.Degree_Level__c,'
               + 'Name,Credits_Brought_into_Program__c, Number_Credits_Completed_in_all_Terms__c, Total_attempted_credits__c, First_Start_Date__c'
               + ' FROM Student_Program__c'
               + ' WHERE IsStudentProgramActive__c = true'
               //+ ' AND CurrentSubscriptionEndDate__c >=: toDay'
               //+ ' AND CurrentSubscriptionStartDate__c >=: fourDayAgoDate'
               + ' AND RecordTypeId =: wladenRecordType';

        return (list<Student_Program__c>) Database.query( SOQL1 );                
    }

    public static String getSapCode() {
        
        SOQL1 = 'SELECT SAP_Code__c, Renewal_Denied__c'
               + ' FROM Student_Program__c'
               + ' WHERE IsStudentProgramActive__c = true'
              // + ' AND CurrentSubscriptionEndDate__c >=: toDay'
              //+ ' AND CurrentSubscriptionStartDate__c >=: fourDayAgoDate'
               + ' AND RecordTypeId =: wladenRecordType';   

       list<Student_Program__c> lst = (list<Student_Program__c>) Database.query( SOQL1 ); 
       if(lst[0].Renewal_Denied__c != null) {
            renewalDenied = lst[0].Renewal_Denied__c;
       }
       return lst[0].SAP_Code__c;

    }    

    
}