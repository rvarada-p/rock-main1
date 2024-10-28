@isTest
private class DocumentHoldHelper_Test {

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
        
        Hold_codes__c documentHoldCode = new Hold_codes__c();
        documentHoldCode.Institution__c = ins.Id;
        documentHoldCode.Name = 'DH';
        documentHoldCode.Description__c = 'Test';
        insert documentHoldCode;
        
        Student_Hold_Code__c documentHold = new Student_Hold_Code__c();
        documentHold.Hold_Code__c = documentHoldCode.Id;
        documentHold.Student_Program__c = sprog2.Id;
        documentHold.Hold_Close_Date__c = null;
        insert documentHold;
        
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
        PricebookEntry pbEntery = TestDataGenerator.createPricebookEntry(parentProduct.id,standardPricebookId, 0, false,false);
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
        stuSub2.List_Price__c = 0;
        stuSub2.Future_Term__c = false;
        
        lstStudentSubscription.add(stuSub2);     
         
        insert lstStudentSubscription;

        sprog2.Current_Student_Subscription__c = stuSub2.ID;
        update sProg2;

        Institution__c ins = TestDataGenerator.createInstitution('testInst', true); 
        
        Hold_codes__c documentHoldCode = new Hold_codes__c();
        documentHoldCode.Institution__c = ins.Id;
        documentHoldCode.Name = 'DH';
        documentHoldCode.Description__c = 'Test';
        insert documentHoldCode;
        
        
        List<Student_Hold_Code__c> shcList = new List<Student_Hold_Code__c>();
        Student_Hold_Code__c documentHold = new Student_Hold_Code__c();
        documentHold.Hold_Code__c = 'a0Eo00000027LVr';
        documentHold.Student_Program__c = sprog2.Id;
        documentHold.Hold_Close_Date__c = null;
        shcList.add(documentHold);
                
        insert shcList;
        
    }        
     static testMethod void applyDocumentHoldTest() {
        setupTestData();
        Test.startTest();
            BatchApplyDocumentHold objBatch = new BatchApplyDocumentHold();
            ID batchprocessid = Database.executeBatch(objBatch,10);                   
            objBatch.execute(null);
        Test.stopTest();
    
    }
     
   /* static testMethod void applyDocumentHoldHelperTest() {
        setupTestData();
        String waldenRecordType = Schema.SObjectType.Student_Program__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();

        String SOQL = 'SELECT Name'
                + ' FROM Student_Program__c'  
                + ' WHERE RecordTypeId =: waldenRecordType'
                + ' AND Open_Document_Hold__c = 0'
                + ' AND Outstanding_Balance_Minus_Future__c > 0';
        List<Student_Program__c> lstStudentProgram = new List<Student_Program__c>();
        lstStudentProgram = Database.query(SOQL);
        
        DocumentHoldHelper helper = new DocumentHoldHelper();
        helper.applyDocumentHolds(lstSprogram);
    } */
    
     static testMethod void removeDocumentHoldTest() {
        setupTestDataRemove();
        Test.startTest();
            BatchRemoveDocumentHold objBatch = new BatchRemoveDocumentHold();
            ID batchprocessid = Database.executeBatch(objBatch,10);                   
            objBatch.execute(null);
        Test.stopTest();
    }    

    /*static testMethod void removeDocumentHoldHelperTest() {
        setupTestData();
        String waldenRecordType = Schema.SObjectType.Student_Program__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        String SOQL = 'SELECT Name'
          + ' FROM Student_Program__c'  
          + ' WHERE RecordTypeId =: waldenRecordType'
          + ' AND Outstanding_Balance_Minus_Future__c <= 0';

        List<Student_Program__c> lstStudentProgram = new List<Student_Program__c>();
        lstStudentProgram = Database.query(SOQL);
        BatchRemoveDocumentHold objBatch = new BatchRemoveDocumentHold();
        objBatch.execute(null);
        DocumentHoldHelper helper = new DocumentHoldHelper();
        helper.removeDocumentHolds(lstStudentProgram);
        

    }     */
    
}