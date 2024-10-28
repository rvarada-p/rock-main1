/**
Name  : BursarHoldHelper_Test
Author: Sarah Khalid, Laureate
Date  : August 15, 2017
Description: Test class for batch Apex Rule Engine: Remove Bursar Hold and BursarHoldHelper
 
 */
@isTest
private class BursarHoldHelper_Test {

    static list<Student_Program__c> lstSprogram;
    static list<Student_Subscription__c> lstStudentSubscription;
    
    static void setupTestData() {

       RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Competency', 'Student_Competency__c','Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        Id standardPricebookId = Test.getStandardPricebookId();
        Pricebook2 pb = new Pricebook2(ID=standardPricebookId,Subscription_Duration_in_Months__c = 0);
        update pb;
        Date dtLastDaydate = Date.today().addDays(-1);
        system.debug('pb.Subscription_Duration_in_Months__c::::::::'+pb.Subscription_Duration_in_Months__c);
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c = product2.id;
        insert opty;      
        PricebookEntry pbEntery = TestDataGenerator.createPricebookEntry(parentProduct.id,standardPricebookId, 200, false,false);
        pbEntery.Available_for_Existing_Students__c = true;
        insert pbEntery;

        Date sDate = Date.today().addDays(-200);
        lstSprogram = new list<Student_Program__c>();
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false); 
        sProg.IsStudentProgramActive__c = true;
        sprog.Program__c = product2.ID;
        sprog.Student_Enrollment_Status_Code__c = 'EL';
        lstSprogram.add(sProg);  
        Student_Program__c sProg1 = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false); 
        sProg1.IsStudentProgramActive__c = true;
        sprog1.Program__c = product2.ID;
        sprog1.Student_Enrollment_Status_Code__c = 'EL';
        lstSprogram.add(sProg1);         
        Student_Program__c sProg2 = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false); 
        sProg2.IsStudentProgramActive__c = true;
        sprog2.Student_Enrollment_Status_Code__c = 'EL';
        sprog2.Program__c = product2.ID;
        lstSprogram.add(sProg2);               
        insert lstSprogram;    
        
        lstStudentSubscription = new list<Student_Subscription__c>();
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pb, 'Walden', false);
        stuSub.Start_Date__c = Date.today().addDays(-40);
        stuSub.Subscription_Status__c = 'RE = Registered';
        stuSub.End_Date__c = Date.today().addDays(50);
        stuSub.List_Price__c = 3500;
        stuSub.Future_Term__c = false;
        lstStudentSubscription.add(stuSub);    
        
        Student_Subscription__c stuSub2 = TestDataGenerator.createStudentSubscription(sProg1, pb, 'Walden', false);
        stuSub2.Start_Date__c = Date.today().addDays(-10);
        stuSub2.Subscription_Status__c = 'RE = Registered';
        stuSub2.End_Date__c = Date.today().addDays(70);
        stuSub2.List_Price__c = 1500;
        stuSub2.Future_Term__c = false;
        
        sprog2.Current_Student_Subscription__c = stuSub2.ID;
        update sprog2;
        
        lstStudentSubscription.add(stuSub2);     
         
        insert lstStudentSubscription;

        Institution__c ins = TestDataGenerator.createInstitution('testInst', true); 
        
        Hold_codes__c bursarHoldCode = new Hold_codes__c();
        bursarHoldCode.Institution__c = ins.Id;
        bursarHoldCode.Name = 'BH';
        bursarHoldCode.Description__c = 'Test';
        insert bursarHoldCode;
        
        Student_Hold_Code__c bursarHold = new Student_Hold_Code__c();
        bursarHold.Hold_Code__c = bursarHoldCode.Id;
        bursarHold.Student_Program__c = sprog2.Id;
        bursarHold.Hold_Close_Date__c = null;
        insert bursarHold;
        
    }
        
    static void setupTestDataRemove() {

        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Competency', 'Student_Competency__c','Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        Id standardPricebookId = Test.getStandardPricebookId();
        Pricebook2 pb = new Pricebook2(ID=standardPricebookId,Subscription_Duration_in_Months__c = 0);
        update pb;
        Date dtLastDaydate = Date.today().addDays(-1);
        system.debug('pb.Subscription_Duration_in_Months__c::::::::'+pb.Subscription_Duration_in_Months__c);
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c = product2.id;
        insert opty;      
        PricebookEntry pbEntery = TestDataGenerator.createPricebookEntry(parentProduct.id,standardPricebookId, 200, false,false);
        pbEntery.Available_for_Existing_Students__c = true;
        insert pbEntery;
      
        Date sDate = Date.today().addDays(-200);
        lstSprogram = new list<Student_Program__c>();
        
        Student_Program__c sProg2 = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false); 
        sProg2.IsStudentProgramActive__c = true;
        sprog2.Student_Enrollment_Status_Code__c = 'EL';
        sprog2.Program__c = product2.ID;
        lstSprogram.add(sProg2);               
        insert lstSprogram;    
        
        lstStudentSubscription = new list<Student_Subscription__c>();
   
        Student_Subscription__c stuSub2 = TestDataGenerator.createStudentSubscription(sProg2, pb, 'Walden', false);
        stuSub2.Start_Date__c = Date.today().addDays(-10);
        stuSub2.Subscription_Status__c = 'RE = Registered';
        stuSub2.End_Date__c = Date.today().addDays(70);
        stuSub2.List_Price__c = 1500;
        stuSub2.Future_Term__c = false;  
        
        lstStudentSubscription.add(stuSub2);     
         
        insert lstStudentSubscription;

        sprog2.Current_Student_Subscription__c = stuSub2.ID;
        update sProg2;

        Institution__c ins = TestDataGenerator.createInstitution('testInst', true); 
        
        Hold_codes__c bursarHoldCode = new Hold_codes__c();
        bursarHoldCode.Institution__c = ins.Id;
        bursarHoldCode.Name = 'BH';
        bursarHoldCode.Description__c = 'Test';
        insert bursarHoldCode;
        
        
        List<Student_Hold_Code__c> shcList = new List<Student_Hold_Code__c>();
        Student_Hold_Code__c bursarHold = new Student_Hold_Code__c();
        bursarHold.Hold_Code__c = bursarHoldCode.Id;
        bursarHold.Student_Program__c = sprog2.Id;
        bursarHold.Hold_Close_Date__c = null;
        shcList.add(bursarHold);
        
        Student_Hold_Code__c bursarHold1 = new Student_Hold_Code__c();
        bursarHold1.Hold_Code__c = 'a0Eo00000027LVj';
        bursarHold1.Student_Program__c = sprog2.Id;
        bursarHold1.Hold_Close_Date__c = null;
        shcList.add(bursarHold1);
        
        Student_Hold_Code__c bursarHold2 = new Student_Hold_Code__c();
        bursarHold2.Hold_Code__c = 'a0Eo00000027LVj';
        bursarHold2.Student_Program__c = sprog2.Id;
        bursarHold2.Hold_Close_Date__c = null;
        shcList.add(bursarHold2);
        
        insert shcList;
        
    }        
     static testMethod void applyBursarHoldTest() {
        setupTestData();
        Test.startTest();
        BatchApplyBursarHold objBatch = new BatchApplyBursarHold();
        ID batchprocessid = Database.executeBatch(objBatch,10);                   
        objBatch.execute(null);
        Test.stopTest();
    
    }
     
    static testMethod void applyBursarHoldHelperTest() {
        setupTestData();
        String waldenRecordType = Schema.SObjectType.Student_Program__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();

        String SOQL = 'SELECT Name, IsStudentProgramActive__c '
            + ' FROM Student_Program__c'  
            + ' WHERE RecordTypeId =: waldenRecordType'
            + ' AND Open_Bursar_Hold__c = 0'
            + ' AND Outstanding_Balance_Minus_Future__c >=2000'
            + ' AND Oldest_Debt_Age__c>30';
        List<Student_Program__c> lstStudentProgram = new List<Student_Program__c>();
        lstStudentProgram = Database.query(SOQL);
        
        BursarHoldHelper helper = new BursarHoldHelper();
        helper.applyBusarHolds(lstSprogram);
    } 
    
     @isTest(SeeAllData=true)
     static  void removeBursarHoldTest() {
        setupTestDataRemove();
        BatchRemoveBursarHold objBatch = new BatchRemoveBursarHold();
        objBatch.SOQL = 'SELECT Name, IsStudentProgramActive__c '
            + ' FROM Student_Program__c'  
            + ' WHERE RecordTypeId =: waldenRecordType'
            + ' AND Open_Bursar_Hold__c >= 1'
            + ' AND (Outstanding_Balance_Minus_Future__c <2000 OR Oldest_Debt_Age__c < 30) LIMIT 200';
        Test.startTest();   
        ID batchprocessid = Database.executeBatch(objBatch,200);                   
        
        Test.stopTest();
    }    

    static testMethod void removeBursarHoldHelperTest() {
        setupTestData();
        String waldenRecordType = Schema.SObjectType.Student_Program__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        String SOQL = 'SELECT Name, IsStudentProgramActive__c,Outstanding_Balance_Minus_Future__c, Oldest_Debt_Age__c, Open_Bursar_Hold__c '
            + ' FROM Student_Program__c'  
            + ' WHERE RecordTypeId =: waldenRecordType'
            + ' AND (Outstanding_Balance_Minus_Future__c <2000 OR Oldest_Debt_Age__c < 30)';

        List<Student_Program__c> lstStudentProgram = new List<Student_Program__c>();
        lstStudentProgram = Database.query(SOQL);
        BatchRemoveBursarHold objBatch = new BatchRemoveBursarHold();
        objBatch.execute(null);
        
        BursarHoldHelper helper = new BursarHoldHelper();
        helper.removeBursarHolds(lstStudentProgram);
        

    }     
    
}