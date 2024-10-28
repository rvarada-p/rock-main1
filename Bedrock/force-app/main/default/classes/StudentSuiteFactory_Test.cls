/*******************************************************************
Name  : StudentSuiteFactory_Test
Author: Vinod (Appirio)
Date  : Oct 28, 2014
Description: Test Class for the  StudentSuiteFactory class
*************************************************************************/
@isTest (seeAllData=true)
private class StudentSuiteFactory_Test {

    /*Commenting as we don't have TBYB Competencies anymore
    // test method to test function createTrialStudentCompetencyAndStudentExpertise
    static testMethod void testCreateTrialStudentCompetencyAndStudentExpertise() {
        // create test data
        // create test data
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
        
        list<Student_Competency__c> lstStudentCompetency = [Select ID from Student_Competency__c where Contact__c =: testUpdatedProfile1.Contact__c];
        system.assertEquals(lstStudentCompetency.size(), 1);
        
        list<Student_Expertise__c> lstStudentExpertise = [Select ID from Student_Expertise__c where Contact__c =: testUpdatedProfile1.Contact__c];
        system.assertEquals(lstStudentExpertise.size(), 1);
    }
    */

     // test method to test function createOpportunityOnPrimaryProgramOfInterestChanged
    static testMethod void testcreateStudentCompetencyAndStudentExpertise() {
        // create test data
        TriggerSettings__c triggerSettings = new TriggerSettings__c();
        triggerSettings.Name = 'ContactTrigger';
        triggerSettings.isActive__c = false;
        triggerSettings.isTestMode__c = true;
        //insert triggerSettings;
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('BrandbProfile', 'Brand_Profile__c','Tempo', true);
        RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity','Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb3 = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c','Walden', true);          
        Account testAcc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(testAcc, false);
        testCon.Email = 'test123@test12345.Com';
        insert testCon; 
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.Id;
        insert product2;
               Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile1.Email__c = 'test123@test12345.Com';
        testProfile1.Contact__c = testCon.id;
        insert testProfile1;
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  

        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = product2.Id;
        psd.Start_Date__c = TestDataGenerator.getFirstMondayOfMonth(Date.today()+31);
        psd.Accepting_New_Students__c = true;
        insert psd;
        Opportunity opp = new Opportunity();
        opp.Contact__c = testCon.id;
        //opp.Brand_Profile__c = testPro.id;
        opp.Admissions_Status__c = 'AD Admitted';
        opp.Admissions_Status_Code__c = 'AD';
        opp.StageName = 'Recommend Admit';
        opp.Program_Start_Date__c = psd.Id;
         opp.Name = 'Test Opp';
        opp.CloseDate = System.today().addDays(-5);
        opp.Brand_Profile__c = testProfile1.id;
        opp.Initial_Price_Book__c = pb.id;
        insert opp;        
        
        
 
        testProfile1.Primary_Program_of_Interest__c = product2.id;
        update testProfile1;
        list<Opportunity> lstOpportunity = [Select ID,Brand_Profile__c from Opportunity where Brand_Profile__c =: testProfile1.ID];
        system.assert(lstOpportunity.size() > 0);        
        
    }
     // test method to test createFullCBLStudentProgram method of StudentFactory class
    static testMethod void testCreateFullCBLStudentProgram() {
        // test method to test onBeforeInsert function
        // create test data
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('BrandbProfile', 'Brand_Profile__c','Tempo', true);
        RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity','Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb3 = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c','Walden', true);
        Account testAcc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(testAcc, false); 
        testCon.Email = 'test12@test12345.Com1';
        insert testCon;
        Account testAcc1 = TestDataGenerator.createAccount(true);
        Contact testCon1 = TestDataGenerator.createContact(testAcc1, false); 
        testCon1.Email = 'test12@test12345.Com1';
        insert testCon1;
        Product2 parentProgram = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProgram.Id;
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
        List<Brand_Profile__c> bpList = new List<Brand_Profile__c>();
        Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile1.Primary_Program_of_Interest__c = product2.id;
        testProfile1.Email__c = 'test12@test12345.Com1';
        testProfile1.Contact__c = testCon.id;
        insert testProfile1;
        bpList.add(testProfile1);
        //list<Opportunity> lstOpportunity = [Select ID, StageName, Brand_Profile__c from Opportunity where Brand_Profile__c =:testProfile1.ID];    
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  
        //Opportunity testOpty1 = lstOpportunity[0];
        Opportunity testOpty1 = new Opportunity();
        testOpty1.Name = 'Test Opp';
        testOpty1.CloseDate = System.today().addDays(-5);
        testOpty1.Admissions_Status__c = 'AD Admitted';
        testOpty1.Admissions_Status_Code__c = 'AD';
        testOpty1.StageName = 'Recommend Admit';
        testOpty1.Program_Start_Date__c = psd.Id;
        testOpty1.opportunity_status_auto_values__c = 'Admitted';
        testOpty1.Initial_Price_Book__c = pb.id;
        testOpty1.Contact__c = testCon.Id;
        upsert testOpty1;
        list<Opportunity> oppList = new  list<Opportunity>();
        list<Student_Program__c> lstStudentPrograms = [Select ID, Application__c, Brand_Profile__c from Student_Program__c where Application__c =:testOpty1.ID];
        //system.assertEquals(lstStudentPrograms.size(), 1); 
        oppList.add(testOpty1);        
        
        Opportunity opp = new Opportunity();
        opp.Contact__c = testCon1.id;
        //opp.Brand_Profile__c = testPro.id;
        opp.Admissions_Status__c = 'AD Admitted';
        opp.Admissions_Status_Code__c = 'AD';
        opp.StageName = 'Recommend Admit';
        opp.Program_Start_Date__c = psd.Id;
        opp.Initial_Price_Book__c = pb.id;
        opp.Name = 'Test Opp';
        opp.CloseDate = System.today().addDays(-5);
        
        insert opp;
        StudentSuiteFactory objSFactory = new StudentSuiteFactory(); 
        objSFactory.createBrandProfile(oppList);
        objSFactory.createTBYBStudentCompetencyAndStudentExpertiseForBrandProfile(bpList);

    }  
     // test method to test populateListPriceOnOpprtunity method of StudentFactory class
    static testMethod void testPopulateListPriceOnOpprtunity() {
        // test method to test onBeforeInsert function
        // create test data
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('BrandbProfile', 'Brand_Profile__c','Tempo', true);
        RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity','Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb3 = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c','Walden', true);
        
        Account testAcc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(testAcc, false); 
        testCon.Email = 'test12@test12345.Com2';
        insert testCon;
        Product2 parentProgram = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProgram.Id;
        insert product2;
        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = product2.Id;
        psd.Start_Date__c = TestDataGenerator.getFirstMondayOfMonth(Date.today()+31);
        psd.Accepting_New_Students__c = true;
        insert psd;
        Pricebook2 pbook = [select id from Pricebook2 where IsStandard = true limit 1];
        //PriceBook2 pbook = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, false);
        //pbook.IsStandard = true;
        PricebookEntry pbEntry = TestDataGenerator.createPricebookEntry(parentProgram.Id,pbook.Id, 500, false, false); 
        pbEntry.Available_for_Existing_Students__c = true;
        insert pbEntry;
        testCon.FirstName = 'Tempo123';
        testCon.LastName = 'TEst123';
        testCon.Email = 'test12@test12345.Com2';
        update testCon;
        //list<Opportunity> oppList = new  list<Opportunity>();
        Opportunity opty = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, 'Walden', false);
        opty.Initial_Price_Book__c = pbook.ID;
        opty.Primary_Program__c = product2.ID;
        opty.Program_Start_Date__c = psd.Id;
        opty.Contact__c =testCon.id; 
        //opty.Email__c = 'tempoTest@walden.edu';
        insert opty;
        //oppList.add(opty);        
        Opportunity updatedOpportunity =  [Select ID, Amount from Opportunity where ID =:opty.ID];
        system.assertEquals(updatedOpportunity.Amount,pbEntry.UnitPrice);
        Opportunity opty2 = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, 'Walden', true);
        opty2.Initial_Price_Book__c = pbook.ID;
        opty2.Contact__c =testCon.id; 
        //opty2.Primary_Program__c = product2.ID; 
        update opty2;
        
        list<Opportunity> oppList = new list<Opportunity>([Select Brand_Profile__c, Program_Start_Date__c, 
                                                                  Parent_Program__c, id,name, Student_First_Name__c,
                                                                  Student_Last_Name__c,Email__c,Primary_Program__c,
                                                                  Contact__r.name, Change_of_Program__c, 
                                                                  COP_Related_Opportunity__c, Student_Type__c 
                                                                  from Opportunity 
                                                                  //where id =: opty.id
                                                                  ]);

        Opportunity updatedOpportunity2 =  [Select ID, Amount from Opportunity where ID =:opty2.ID];
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper.Id,product2.id,true,4.0, true);
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Program_Competency__c testPComo = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0,true);
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', true); 
        StudentSuiteFactory objSFactory = new StudentSuiteFactory();
        objSFactory.createStudentExpertise(sProg,pExper);
        Student_Competency__c pcomp2 =  objSFactory.createStudentCompetency(sProg,testPComo);
        objSFactory.createBrandProfile(oppList);
    }
    static testMethod void testPopulateListPriceOnOpprtunity2() {
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('BrandbProfile', 'Brand_Profile__c','Tempo', true);
        RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity','Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb3 = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c','Walden', true);
        
        Account testAcc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(testAcc, false); 
        testCon.Email = 'test12@test12345.Com2';
        insert testCon;
        Product2 parentProgram = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProgram.Id;
        insert product2;
        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = product2.Id;
        psd.Start_Date__c = TestDataGenerator.getFirstMondayOfMonth(Date.today()+31);
        psd.Accepting_New_Students__c = true;
        insert psd;
        Pricebook2 pbook = [select id from Pricebook2 where IsStandard = true limit 1];
        //PriceBook2 pbook = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, false);
        //pbook.IsStandard = true;
        PricebookEntry pbEntry = TestDataGenerator.createPricebookEntry(parentProgram.Id,pbook.Id, 500, false, false); 
        pbEntry.Available_for_Existing_Students__c = true;
        insert pbEntry;
        testCon.FirstName = 'Tempo123';
        testCon.LastName = 'TEst123';
        testCon.Email = 'test12@test12345.Com2';
        update testCon;
        //list<Opportunity> oppList = new  list<Opportunity>();
        Opportunity opty = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, 'Walden', false);
        opty.Initial_Price_Book__c = pbook.ID;
        opty.Primary_Program__c = product2.ID;
        opty.Program_Start_Date__c = psd.Id;
        opty.Contact__c =testCon.id; 
        //opty.Email__c = 'tempoTest@walden.edu';
        opty.Brand_Profile__c = null;
        insert opty;
        //oppList.add(opty);        
        Opportunity updatedOpportunity =  [Select ID, Amount from Opportunity where ID =:opty.ID];
        system.assertEquals(updatedOpportunity.Amount,pbEntry.UnitPrice);
        Opportunity opty2 = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, 'Walden', true);
        opty2.Initial_Price_Book__c = pbook.ID;
        opty2.Contact__c =testCon.id; 
        //opty2.Primary_Program__c = product2.ID; 
        update opty2;
        
        list<Opportunity> oppList = new list<Opportunity>([Select Brand_Profile__c, Program_Start_Date__c, 
                                                                  Parent_Program__c, id,name, Student_First_Name__c,
                                                                  Student_Last_Name__c,Email__c,Primary_Program__c,
                                                                  Contact__r.name, Change_of_Program__c, 
                                                                  COP_Related_Opportunity__c, Student_Type__c 
                                                                  from Opportunity
                                                                  where id =: opty.id
                                                                  ]);

        Opportunity updatedOpportunity2 =  [Select ID, Amount from Opportunity where ID =:opty2.ID];
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper.Id,product2.id,true,4.0, true);
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Program_Competency__c testPComo = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0,true);
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', true); 
        StudentSuiteFactory objSFactory = new StudentSuiteFactory();
        
        Pre_requisite_Rules__c preReqRulsObj = new Pre_requisite_Rules__c(Course_Name__c = aExper.Id, 
                                                                          Area_of_Expertise__c = aExper.Id);
        insert preReqRulsObj;
 
        
        Test.startTest();
        try{
            objSFactory.createFullCBLStudentProgram(oppList);
        }catch(Exception e){}
        objSFactory.createStudentProgram(oppList[0]);
        objSFactory.createBrandProfile(oppList);
        Test.stopTest();
    }
}