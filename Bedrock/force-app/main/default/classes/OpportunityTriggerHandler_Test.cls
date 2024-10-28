/*******************************************************************
Name  : TestOpportunityTriggerHandler
Author: Vinod (Appirio)
Date  : October 6, 2014
Description: Test Class for the Handler class OpportunityTriggerHandler and trigger OpportunityTrigger.
            Also coverin g the other related classes
*************************************************************************/
@isTest(seeAllData=true)
private class OpportunityTriggerHandler_Test {

    // test method to test createFullCBLStudentProgram method of StudentFactory class
    static testMethod void testCreateFullCBLStudentProgram() {
        // test method to test onBeforeInsert function
        // create test data
        Account testAcc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(testAcc, false); 
        testCon.FirstName = 'Test';
        testCon.Email = 'test12@test12345.Com';
        insert testCon;
        Product2 parentProgram = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProgram.Id;
        product2.ProductCode = 'RNMSN';
        insert product2;
        Product2 product3 = TestDataGenerator.createProduct('test', 'Walden', false);
        product3.Parent_Program__c = parentProgram.Id;
        product3.ProductCode = 'RNMSN';
        insert product3;
        Program_Application_Requirement__c testProgApp = TestDataGenerator.createProgramApplicationRequirement(false);
        testProgApp.Program__c = product2.Id;
        insert testProgApp;
        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = product2.Id;
        psd.Start_Date__c = TestDataGenerator.getFirstMondayOfMonth(Date.today()+31);
        psd.Accepting_New_Students__c = true;
        insert psd;
        Program_Start_Date__c psd2 = TestDataGenerator.createProgramStartDate(false);
        psd2.Program__c = product2.Id;
        psd2.Start_Date__c = TestDataGenerator.getFirstMondayOfMonth(Date.today()+91);
        psd2.Accepting_New_Students__c = true;
        insert psd2;        
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper.Id,product2.id,true,4.0, true);
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Program_Competency__c testPComo = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0,true);
        Program_Competency__c testPComo1 = TestDataGenerator.createProgramCompetency(testComp.Id,product3.Id,true,4.0,true);

        Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile1.Primary_Program_of_Interest__c = product2.id;
        testProfile1.Email__c = 'test12@test12345.Com';
        testProfile1.LMS_ID__c = 103;
        insert testProfile1;
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);
        system.debug('@@@@@@@@@@@@@@testProfile1+  '+ testProfile1);
        opportunity testOpty1 = TestDataGenerator.createOpportunity(testAcc.id, testCon.id, 'Walden', false);
        testOpty1.Brand_Profile__c = testProfile1.id;
        testOpty1.Primary_Program__c = product3.Id;
        insert testOpty1;
        testPComo.Product__c = product2.Id;
		testPComo.IsTryBeforeYouBuy__c = true;
        update testPComo;
		Student_Competency__c sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency.Contact__c = testCon.id;
        sCometency.Program_Competency__c = testPComo.ID;
		sCometency.Opportunity__c = testOpty1.Id;        
        insert sCometency;
        Student_Competency__c sCometency1 = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency1.Contact__c = testCon.id;
        sCometency1.Program_Competency__c = testPComo1.ID;
		sCometency1.Opportunity__c = testOpty1.Id;        
        insert sCometency1;
        Student_Assessment__c sa1 = TestDataGenerator.createNewStudentAssessment(sCometency.Id,'A','Walden','Mastered',true);        
        Student_Assessment__c sa2 = TestDataGenerator.createNewStudentAssessment(sCometency1.Id,'A','Walden','Mastered',true);        
        //Opportunity testOpty1 = lstOpportunity[0];
        testOpty1.Admissions_Status__c = 'AD Admitted';
        testOpty1.Admissions_Status_Code__c = 'AD';
        testOpty1.StageName = 'Recommend Admit';
        testOpty1.opportunity_status_auto_values__c = 'Admitted';
        testOpty1.Initial_Price_Book__c = pb.id;
        testOpty1.Program_Start_Date__c = psd.Id;
        testOpty1.Contact__c = testCon.id;
        update testOpty1;
        test.startTest(); 
        testOpty1.Program_Start_Date__c = psd2.Id;
        update testOpty1;
        
        testOpty1.Primary_Program__c = product3.Id;
        //testOpty1.StageName = 'Student';
        update testOpty1;
        
        student_program__c sProg = TestDataGenerator.createStudentProgram(testOpty1, testCon.id, 'Walden', false);
        sProg.Brand_Profile__c = testProfile1.id;
        insert sProg;
        
        testOpty1.Student_Program__c = sProg.id;
        update testOpty1;

        testOpty1.Change_of_Specialization__c = TRUE ;
        testOpty1.StageName = 'Admitted';
        testOpty1.Primary_Program__c = product2.id;
        update testOpty1;
        test.stopTest(); 

        //Add in mock http callout to BS for CBL Student ID update
        JsonWrapper jsonGenerator = new JsonWrapper();
        String json = jsonGenerator.updateUser('CBL-4545454',  testCon.FirstName, testCon.LastName, testCon.Email);
            
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_BSUpdateUser());
        HttpResponse  response = New HttpResponse();
        
        BrightSpaceCalls.updateUser(json, '103', testCon.Id);               

    }
    // test method to test populateListPriceOnOpprtunity method of StudentFactory class
    static testMethod void testPopulateListPriceOnOpprtunity() {
        // test method to test onBeforeInsert function
        // create test data
        Account testAcc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(testAcc, false); 
        testCon.Email = 'test12@test12345.Com';
        insert testCon;
        Product2 parentProgram = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProgram.id;
        product2.ProductCode = 'RNMSN';
        insert product2;
        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = product2.Id;
        psd.Start_Date__c = TestDataGenerator.getFirstMondayOfMonth(Date.today()+31);
        psd.Accepting_New_Students__c = true;
        insert psd;
        Pricebook2 pbook = [select id from Pricebook2 where IsStandard = true limit 1];
        //PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);
        PricebookEntry pbEntry = TestDataGenerator.createPricebookEntry(parentProgram.Id,pbook.Id, 500, false, false); 
        pbEntry.Available_for_Existing_Students__c = true;
        insert pbEntry;
        Opportunity opty = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, 'Walden', false);
        opty.Initial_Price_Book__c = pbook.ID;
        opty.Primary_Program__c = product2.ID;
        opty.Program_Start_Date__c = psd.Id;
        insert opty;
        Opportunity updatedOpportunity =  [Select ID, Amount from Opportunity where ID =:opty.ID];
        system.assertEquals(updatedOpportunity.Amount,pbEntry.UnitPrice);
        Opportunity opty2 = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, 'Walden', true);
        opty2.Initial_Price_Book__c = pbook.ID;
        //opty2.Primary_Program__c = product2.ID;
        update opty2;
        Opportunity updatedOpportunity2 =  [Select ID, Amount from Opportunity where ID =:opty2.ID];
        //system.assertEquals(updatedOpportunity2.Amount,pbEntry.UnitPrice);
    }
    
       static testMethod void testCreateFullCBLStudentProgram_NegativeCondition() {
        // test method to test onBeforeInsert function
        // create test data
        Account testAcc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(testAcc, false); 
        testCon.FirstName = 'Test';
        testCon.Email = 'test12@test12345.Com';
        insert testCon;
        Product2 parentProgram = TestDataGenerator.createProduct('test', 'Walden', true); 
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProgram.Id;
        product2.ProductCode = 'RNMSN';   
        insert product2;
        Product2 product3 = TestDataGenerator.createProduct('test', 'Walden', false);
        product3.Parent_Program__c = parentProgram.Id;
        product3.ProductCode = 'RNMSN';   
        insert product3;
        Program_Application_Requirement__c testProgApp = TestDataGenerator.createProgramApplicationRequirement(false);
        testProgApp.Program__c = product2.Id;
        insert testProgApp;
        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = product2.Id;
        psd.Start_Date__c = TestDataGenerator.getFirstMondayOfMonth(Date.today()+31);
        psd.Accepting_New_Students__c = true;
        insert psd;
        Program_Start_Date__c psd2 = TestDataGenerator.createProgramStartDate(false);
        psd2.Program__c = product2.Id;
        psd2.Start_Date__c = TestDataGenerator.getFirstMondayOfMonth(Date.today()+91);
        psd2.Accepting_New_Students__c = true;
        insert psd2;        
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper.Id,product2.id,true,4.0, true);
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Program_Competency__c testPComo = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0,true);
        Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile1.Primary_Program_of_Interest__c = product2.id;
        testProfile1.Email__c = 'test12@test12345.Com';
        testProfile1.LMS_ID__c = 103;
        insert testProfile1;
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);
        opportunity testOpty1 = TestDataGenerator.createOpportunity(testAcc.id, testCon.id, 'Walden', false);
        testOpty1.Brand_Profile__c = testProfile1.id;
        insert testOpty1;
        testOpty1.Change_of_Specialization__c = true;
        testOpty1.StageName = 'Admitted' ;
   		testOpty1.Admissions_Status__c = 'AD Admitted';
        testOpty1.Admissions_Status_Code__c = 'AD';
        testOpty1.StageName = 'Recommend Admit';
        testOpty1.opportunity_status_auto_values__c = 'Admitted';
        testOpty1.Initial_Price_Book__c = pb.id;
        testOpty1.Program_Start_Date__c = psd.Id;
        testOpty1.Contact__c = testCon.id;
    	update testOpty1;
        testOpty1.Initial_Price_Book__c = pb.id;
        testOpty1.Primary_Program__c = product3.Id;
        testOpty1.StageName = 'Student' ;
        update testOpty1;

     
         
        testOpty1.Program_Start_Date__c = psd2.Id;
        update testOpty1;
        
        student_program__c sProg = TestDataGenerator.createStudentProgram(testOpty1, testCon.id, 'Walden', false);
        sProg.Brand_Profile__c = testProfile1.id;
        insert sProg;
        
        testOpty1.Student_Program__c = sProg.id;
        update testOpty1;
        list<Student_Program__c> lstStudentPrograms = [Select ID, Application__c, Brand_Profile__c from Student_Program__c where Application__c =:testOpty1.ID];
        system.assertEquals(lstStudentPrograms.size(), 1);  
        Opportunity updatedOpportunity =  [Select ID, Student_Program__c from Opportunity where ID =:testOpty1.ID];
        system.assertEquals(updatedOpportunity.Student_Program__c,lstStudentPrograms[0].ID);

    //Add in mock http callout to BS for CBL Student ID update
      JsonWrapper jsonGenerator = new JsonWrapper();
      String json = jsonGenerator.updateUser('CBL-4545454',  testCon.FirstName, testCon.LastName, testCon.Email);
      
      Test.setMock(HttpCalloutMock.class, new MockHttpResponse_BSNegative());
      HttpResponse  response = New HttpResponse();
      
      BrightSpaceCalls.updateUser(json, '103', testCon.Id);          

    }
    
}