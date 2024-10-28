/*******************************************************************
Name  : TestBrandProfilesTriggerHandler
Author: Vinod (Appirio)
Date  : September 18, 2014
Description: Test Class for the Handler class BrandProfilesTriggerHandler and trigger BrandProfilesTrigger
            Covering the test coverage of the helper class TempoProfileHelper anmd StudentSuiteFactory class
*************************************************************************/
@isTest
private class BrandProfilesTriggerHandler_Test {

    private static D2L__c settings;
    
    public static void setup() {
         
        //Insert the custom settings for D2L
        D2L__c setting = new D2L__c();
        setting.Name = 'D2L';
        setting.Org_Unit_ID__c = 6606;      
        setting.Student_Role_ID__c = 110;
        setting.LP_Version__c = 1.18;
        setting.Create_User_Endpoint__c = ' /d2l/api/lp/1.18/users/';
        
        insert setting; 
    }

    static testMethod void testOnBeforeInsert() {
        // test method to test onBeforeInsert function
        // create test data
        setup();
        TriggerSettings__c triggerSettings = new TriggerSettings__c();
        triggerSettings.Name = 'ContactTrigger';
        triggerSettings.isActive__c = false;
        triggerSettings.isTestMode__c = true;
        insert triggerSettings;
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('BrandbProfile', 'Brand_Profile__c','Tempo', true);
        RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity','Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb3 = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c','Walden', true);       
        Account testAcc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(testAcc, false);
        testCon.Email = 'test12@test12345.Com';
        insert testCon;
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);        
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.Id;
        insert product2;         
        Opportunity opty = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, null, false);
        opty.Contact__c = testCon.ID;
        opty.Primary_Program__c = product2.id;
        insert opty;      
        Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile1.Email__c = 'test12@test12345.Com';
        insert testProfile1;
        Brand_Profile__c testUpdatedProfile1 = [Select ID,Contact__c from Brand_Profile__c where id =: testProfile1.ID];
        system.assertEquals(testUpdatedProfile1.Contact__c, testCon.ID);
        
        Brand_Profile__c testProfile2 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile2.Email__c = 'test12123456@test12345.Com';
        insert testProfile2;
        
        Decimal studentRoleId = D2L__c.getValues('D2L').Student_Role_ID__c;
        Decimal parentId = D2L__c.getValues('D2L').Org_Unit_ID__c;
        JsonWrapper jsonGenerator = new JsonWrapper();
        
        String json = jsonGenerator.createUser('parentId', testProfile2.First_Name__c, testProfile2.Last_Name__c, testProfile2.Email__c, studentRoleId, false);
            
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_BSUser());
        HttpResponse  response = New HttpResponse();
        
        BrightSpaceCalls.createUser(json, testProfile2.Id);         
        
        
    }
    static testMethod void testStudentFactory() {
        // test method to test onBeforeInsert function
        // create test data
        setup();
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('BrandbProfile', 'Brand_Profile__c','Tempo', true);
        Account testAcc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(testAcc, false); 
        testCon.Email = 'test12@test12345.Com';
        insert testCon;
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);        
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.Id;
        insert product2;    
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper.Id,product2.id,true,4.0, true);
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Program_Competency__c testPComo = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0,true);
        Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile1.Primary_Program_of_Interest__c = product2.id;
        testProfile1.Email__c = 'test12@test12345.Com';
        insert testProfile1;
        Brand_Profile__c testUpdatedProfile1 = [Select ID,Contact__c from Brand_Profile__c where id =: testProfile1.ID];
        system.assertEquals(testUpdatedProfile1.Contact__c, testCon.ID);
        Opportunity testOpty1 = TestDataGenerator.createOpportunity(testAcc.id, testCon.id, 'Walden', false);
        testOpty1.Brand_Profile__c = testProfile1.id;
        insert testOpty1; 
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(testOpty1, testCon.id, 'Walden', false);
        sProg.Brand_Profile__c = testProfile1.id;
        insert sProg;
        Student_Expertise__c sExpertise = TestDataGenerator.createCompetencyExpertise(aExper.Id,null, false);
        sExpertise.Contact__c = testCon.Id;
        insert sExpertise;
        list<Student_Competency__c> lstStudentComp = new list<Student_Competency__c>();
        Student_Competency__c sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency.Contact__c = testCon.id;
        sCometency.Status__c = 'Achieved';
        sCometency.IsCompleted__c = true;
        sCometency.Student_Program__c = sProg.ID;
        lstStudentComp.add(sCometency);
        insert lstStudentComp;
        list<Student_Competency__c> lstStudentCompetency = [Select ID from Student_Competency__c where Contact__c =: testUpdatedProfile1.Contact__c];
        system.assertEquals(lstStudentCompetency.size(), 1);
        
        list<Student_Expertise__c> lstStudentExpertise = [Select ID from Student_Expertise__c where Contact__c =: testUpdatedProfile1.Contact__c];
        system.assertEquals(lstStudentExpertise.size(), 1);
        
    }
     // test method to test createFullCBLStudentProgram method of StudentFactory class
    static testMethod void testCreateFullCBLStudentProgram() {
        // test method to test onBeforeInsert function
        // create test data
        setup();
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('BrandbProfile', 'Brand_Profile__c','Tempo', true);
        RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity','Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb3 = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c','Walden', true);
        Account testAcc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(testAcc, false); 
        testCon.Email = 'test12@test12345.Com';
        insert testCon;
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.Id;
        insert product2;
        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = product2.Id;
        psd.Start_Date__c = TestDataGenerator.getFirstMondayOfMonth(Date.today()+31);
        psd.Accepting_New_Students__c = true;
        insert psd;
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper.Id,product2.id,true,4.0, true);
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Program_Competency__c testPComo = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0,true);
        Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile1.Primary_Program_of_Interest__c = product2.id;
        testProfile1.Email__c = 'test12@test12345.Com';
        insert testProfile1;
        opportunity testOpty1 = TestDataGenerator.createOpportunity(testAcc.id, testCon.id, 'Walden', false);
        testOpty1.Brand_Profile__c = testProfile1.id;
        testOpty1.Contact__c = testCon.id;
        insert testOpty1;        
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  
        //Opportunity testOpty1 = lstOpportunity[0]; 
        testOpty1.Admissions_Status__c = 'AD Admitted';
        testOpty1.Admissions_Status_Code__c = 'AD';
        testOpty1.StageName = 'Recommend Admit';
        testOpty1.opportunity_status_auto_values__c = 'Admitted';
        testOpty1.Initial_Price_Book__c = pb.id;
        testOpty1.Program_Start_Date__c = psd.Id;
        update testOpty1;
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(testOpty1, testCon.id, 'Walden', false);
        sProg.Brand_Profile__c = testProfile1.id;
        insert sProg;
        list<Student_Program__c> lstStudentPrograms = [Select ID, Application__c, Brand_Profile__c from Student_Program__c where Application__c =:testOpty1.ID];
        system.assertEquals(lstStudentPrograms.size(), 1);  
    }
    static testMethod void testOnBeforeUpdate() {
        setup();
        // test method to test onBeforeInsert function
        // create test data
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('BrandbProfile', 'Brand_Profile__c','Tempo', true);
        Account testAcc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(testAcc, false);
        testCon.Email = 'test12@test12345.Com';
        insert testCon;
        Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile1.Email__c = 'test12@test12345.Com';
        testProfile1.Contact__c = testCon.ID;
        insert testProfile1;
        
        Brand_Profile__c testProfile2 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', true);
        testProfile2.Contact__c = testCon.ID;
        //try{
          update testProfile2;          
        //}catch(exception ex){
          // temprary code is commented
          //system.assert(ex.getMessage().contains('A Tempo Brand Profile already exists for the contact Id: '+ testProfile2.Contact__c));  
        //}
    }
     static testMethod void testOnAfterUpdate() {
        setup();
        // test method to test onBeforeInsert function
        // create test data
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('BrandbProfile', 'Brand_Profile__c','Tempo', true);
        Account testAcc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(testAcc, false);
        testCon.Email = 'test12@test12345.Com';
        insert testCon;
        
        Product2 parentProgram = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProgram.Id;
        insert product2;        
        
        Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile1.Email__c = 'test12@test12345.Com';
        testProfile1.Contact__c = testCon.ID;
        testProfile1.Primary_Program_of_Interest__c = product2.ID;
        insert testProfile1;
        Product2 parentProgram2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product3 = TestDataGenerator.createProduct('test', 'Walden', false);
        product3.Parent_Program__c = parentProgram2.Id;
        insert product3;
                
        testProfile1.Primary_Program_of_Interest__c = product3.ID;
        update testProfile1;
    }
    
    
}