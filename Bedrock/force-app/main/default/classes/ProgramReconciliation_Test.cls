/*******************************************************************
Name  : ProgramReconciliation_Test
Author: Sarah - Laureate
Date  : June 29, 2016
Description: Test class for ProgramReconciliation class
*************************************************************************/
@isTest
private class ProgramReconciliation_Test {
    @isTest static void testReconcileCOS() {
         // create test data
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
        Program_Competency__c testPComo = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,pExper.Id,true,4.0, false);
        testPComo.Program_Competency_Type__c = 'Core';
        insert testPComo;
        Program_Competency__c testPComo2 = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,pExper.Id,false,2.0,false);
        testPComo2.Program_Competency_Type__c = 'Specialization';
        insert testPComo2;
        Student_Competency__c sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency.Contact__c = testCon.id;
        sCometency.Program_Competency__c = testPComo.ID;
        insert sCometency;
        // create Student_Assessment__c
        Student_Assessment__c sa1 = TestDataGenerator.createNewStudentAssessment(sCometency.Id,'A','Walden','Mastered',true);        
        Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile1.Primary_Program_of_Interest__c = product2.id;
        testProfile1.Email__c = 'test12@test12345.Com';
        insert testProfile1;
 	    PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  
        opportunity testOpty1 = TestDataGenerator.createOpportunity(testAcc.id, testCon.id, 'Walden', false);
        testOpty1.Brand_Profile__c = testProfile1.id;
        insert testOpty1;
        testOpty1.Admissions_Status__c = 'AD Admitted';
        testOpty1.Admissions_Status_Code__c = 'AD';
        testOpty1.StageName = 'Recommend Admit';
        testOpty1.Program_Start_Date__c = psd.Id;
        testOpty1.opportunity_status_auto_values__c = 'Admitted';
        testOpty1.Initial_Price_Book__c = pb.id;
        testOpty1.Contact__c = testCon.id;
        update testOpty1;
    	//Now change the specilaization on the SP
        Product2 product3 = TestDataGenerator.createProduct('test', 'Walden', false);
        product3.Parent_Program__c = parentProduct.Id;
        insert product3;

        Area_of_Expertise__c aExper2 = TestDataGenerator.createAreaOfExpertise(true);
        Program_Expertise__c  pExper2 = TestDataGenerator.createProgramExpertise(aExper2.Id,product3.id,true,4.0, true);
        Competency__c testComp2 = TestDataGenerator.createCompetency(true);
        Program_Competency__c testPComo3 = TestDataGenerator.createProgramCompetency(testComp2.Id,product3.Id,pExper2.Id,true,4.0, false);
        testPComo3.Program_Competency_Type__c = 'Core';
        insert testPComo3;
        Program_Competency__c testPComo4 = TestDataGenerator.createProgramCompetency(testComp2.Id,product3.Id,pExper2.Id,false,2.0,false);
        testPComo4.Program_Competency_Type__c = 'Specialization';
        insert testPComo4;
 
        testOpty1.Primary_Program__c = product3.Id;
        testOpty1.Change_of_Specialization__c = true;
        testOpty1.StageName = 'Admitted' ;
    	update testOpty1;
    }
    
    @isTest static void testReconcileCOPTbyb() {
         // create test data
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
        Program_Competency__c testPComo = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,pExper.Id,true,4.0, false);
        testPComo.Program_Competency_Type__c = 'Core';
        testPComo.FWK_Id__c = '123';
        testPComo.IsTryBeforeYouBuy__c = true;        
        insert testPComo;
        Program_Competency__c testPComo2 = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,pExper.Id,false,2.0,false);
        testPComo2.Program_Competency_Type__c = 'Specialization';
        testPComo2.FWK_Id__c = '124';
        testPComo2.IsTryBeforeYouBuy__c = false; 
        insert testPComo2;
        Student_Competency__c sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency.Program_Competency__c = testPComo.Id;
        sCometency.Contact__c = testCon.id;
        insert sCometency;

        Student_Competency__c sCometency2 = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
		sCometency2.Contact__c = testCon.id;
		sCometency2.Program_Competency__c = testPComo2.Id;
		insert sCometency2;
		
        // create Student_Assessment__c
        Student_Assessment__c sa1 = TestDataGenerator.createNewStudentAssessment(sCometency.Id,'A','Walden','Mastered',true);        
        Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile1.Primary_Program_of_Interest__c = product2.id;
        testProfile1.Email__c = 'test12@test12345.Com';
        insert testProfile1;
        //list<Opportunity> lstOpportunity = [Select ID, StageName, Brand_Profile__c from Opportunity where Brand_Profile__c =:testProfile1.ID];    
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  
        Opportunity testOpty1 = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, null, false);        
        //Opportunity testOpty1 = lstOpportunity[0];
        testOpty1.Admissions_Status__c = 'AD Admitted';
        testOpty1.Admissions_Status_Code__c = 'AD';
        testOpty1.StageName = 'Recommend Admit';
        testOpty1.Program_Start_Date__c = psd.Id;
        testOpty1.Brand_Profile__c = testProfile1.Id;
        testOpty1.opportunity_status_auto_values__c = 'Admitted';
        testOpty1.Initial_Price_Book__c = pb.id;
        testOpty1.Contact__c = testCon.id;
        insert testOpty1;
        list<Student_Program__c> lstStudentPrograms = [Select ID, Application__c, Brand_Profile__c from Student_Program__c where Application__c =:testOpty1.ID];
    	//Now change the second program with different parent
 		Product2 parentProduct2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product3 = TestDataGenerator.createProduct('test', 'Walden', false);
        product3.Parent_Program__c = parentProduct2.Id;
        insert product3;

        Program_Start_Date__c psd2 = TestDataGenerator.createProgramStartDate(false);
        psd2.Program__c = product3.Id;
        psd2.Start_Date__c = TestDataGenerator.getFirstMondayOfMonth(Date.today()+31);
        psd2.Accepting_New_Students__c = true;
        insert psd2;

        Area_of_Expertise__c aExper2 = TestDataGenerator.createAreaOfExpertise(true);
        Program_Expertise__c  pExper2 = TestDataGenerator.createProgramExpertise(aExper2.Id,product3.id,true,4.0, true);
        Competency__c testComp2 = TestDataGenerator.createCompetency(true);
        Program_Competency__c testPComo3 = TestDataGenerator.createProgramCompetency(testComp2.Id,product3.Id,pExper2.Id,true,4.0, false);
        testPComo3.FWK_Id__c = '123';
        testPComo3.IsTryBeforeYouBuy__c = true;  
        testPComo3.Program_Competency_Type__c = 'Core';
        insert testPComo3;
        
        Program_Competency__c testPComo4 = TestDataGenerator.createProgramCompetency(testComp2.Id,product3.Id,pExper2.Id,false,2.0,false);
        testPComo4.Program_Competency_Type__c = 'Specialization';
        testPComo4.FWK_Id__c = '444';
        testPComo4.IsTryBeforeYouBuy__c = false;  
        insert testPComo4;
 		
 		Student_Competency__c sCometency3 = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
		sCometency3.Contact__c = testCon.id;
		sCometency3.Program_Competency__c = testPComo3.Id;
		insert sCometency3;
		
 		Student_Competency__c sCometency4 = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
		sCometency4.Contact__c = testCon.id;
		sCometency4.Program_Competency__c = testPComo4.Id;
		insert sCometency4;
		 		
 		testProfile1.Primary_Program_of_Interest__c = product3.id;
 		update testProfile1;
 		
 		//list<Opportunity> lstOpportunity2 = [Select ID, StageName, Brand_Profile__c from Opportunity where Brand_Profile__c =:testProfile1.ID and StageName = 'New'];    
        /*
        PriceBook2 pb2 = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 7, null, true);  
        Opportunity copOpty = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, null, false);
        copOpty.Program_Start_Date__c = psd2.Id;
        copOpty.Initial_Price_Book__c = pb2.id;
        copOpty.Change_of_Program__c = true;
        copOpty.Primary_Program__c = product3.Id;
        copOpty.StageName = 'New';
        copOpty.Brand_Profile__c = testProfile1.Id;
        copOpty.COP_Related_Opportunity__c = testOpty1.Id; 
 		insert copOpty;
 		*/
 		
    }     
    @isTest static void testReconcileCOPNonTbyb() {
         // create test data
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
        Program_Competency__c testPComo = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,pExper.Id,true,4.0, false);
        testPComo.Program_Competency_Type__c = 'Core';
        insert testPComo;
        Program_Competency__c testPComo2 = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,pExper.Id,false,2.0,false);
        testPComo2.Program_Competency_Type__c = 'Specialization';
        testPComo2.FWK_Id__c = '124';
        insert testPComo2;
        Student_Competency__c sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency.Contact__c = testCon.id;
        sCometency.Program_Competency__c = testPComo.ID;
        insert sCometency;
		        
        // create Student_Assessment__c
        Student_Assessment__c sa1 = TestDataGenerator.createNewStudentAssessment(sCometency.Id,'A','Walden','Mastered',true);        
        Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile1.Primary_Program_of_Interest__c = product2.id;
        testProfile1.Email__c = 'test12@test12345.Com';
        insert testProfile1;
        //list<Opportunity> lstOpportunity = [Select ID, StageName, Brand_Profile__c from Opportunity where Brand_Profile__c =:testProfile1.ID];    
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  
        Opportunity testOpty1 = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, null, false);        
        //Opportunity testOpty1 = lstOpportunity[0];
        testOpty1.Admissions_Status__c = 'AD Admitted';
        testOpty1.Admissions_Status_Code__c = 'AD';
        testOpty1.StageName = 'Recommend Admit';
        testOpty1.Program_Start_Date__c = psd.Id;
        testOpty1.Brand_Profile__c = testProfile1.Id;
        testOpty1.opportunity_status_auto_values__c = 'Admitted';
        testOpty1.Initial_Price_Book__c = pb.id;
        testOpty1.Contact__c = testCon.id;
        insert testOpty1;
        list<Student_Program__c> lstStudentPrograms = [Select ID, Application__c, Brand_Profile__c from Student_Program__c where Application__c =:testOpty1.ID];
    	//Now change the second program with different parent
 		Product2 parentProduct2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product3 = TestDataGenerator.createProduct('test', 'Walden', false);
        product3.Parent_Program__c = parentProduct2.Id;
        insert product3;

        Program_Start_Date__c psd2 = TestDataGenerator.createProgramStartDate(false);
        psd2.Program__c = product3.Id;
        psd2.Start_Date__c = TestDataGenerator.getFirstMondayOfMonth(Date.today()+31);
        psd2.Accepting_New_Students__c = true;
        insert psd2;

        Area_of_Expertise__c aExper2 = TestDataGenerator.createAreaOfExpertise(true);
        Program_Expertise__c  pExper2 = TestDataGenerator.createProgramExpertise(aExper2.Id,product3.id,true,4.0, true);
        Competency__c testComp2 = TestDataGenerator.createCompetency(true);
        Program_Competency__c testPComo3 = TestDataGenerator.createProgramCompetency(testComp2.Id,product3.Id,pExper2.Id,true,4.0, false);
        testPComo3.Program_Competency_Type__c = 'Core';
        insert testPComo3;
        Program_Competency__c testPComo4 = TestDataGenerator.createProgramCompetency(testComp2.Id,product3.Id,pExper2.Id,false,2.0,false);
        testPComo4.Program_Competency_Type__c = 'Specialization';
        testPComo4.Product__c = product2.Id;
        testPComo4.FWK_Id__c = '444';
        insert testPComo4;
 		Student_Competency__c sCometency2 = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
		sCometency2.Contact__c = testCon.id;
		sCometency2.Program_Competency__c = testPComo4.Id;
        insert sCometency2; 
		
 		testProfile1.Primary_Program_of_Interest__c = product3.id;
 		update testProfile1;
 		
 		//list<Opportunity> lstOpportunity2 = [Select ID, StageName, Brand_Profile__c from Opportunity where Brand_Profile__c =:testProfile1.ID and StageName = 'New'];    
        PriceBook2 pb2 = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 7, null, true);  
        Opportunity copOpty = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, null, false);
        copOpty.Program_Start_Date__c = psd2.Id;
        copOpty.Initial_Price_Book__c = pb2.id;
        copOpty.Change_of_Program__c = true;
        copOpty.Primary_Program__c = product3.Id;
        copOpty.StageName = 'New';
        copOpty.Brand_Profile__c = testProfile1.Id;
        copOpty.COP_Related_Opportunity__c = testOpty1.Id;
        copOpty.Contact__c = testCon.id;
 		insert copOpty;
		
        testPComo4.IsTryBeforeYouBuy__c = true;
        update testPComo4;
        sCometency2.Opportunity__c = copOpty.Id;
		update sCometency2;
        
        /*copOpty.opportunity_status_auto_values__c = 'Admitted'; 		
 		copOpty.Admissions_Status__c = 'AD Admitted';
        copOpty.Admissions_Status_Code__c = 'AD';
        copOpty.StageName = 'Recommend Admit';
		copOpty.Change_of_Specialization__c = TRUE ;
        update copOpty;*/
        
    }    
    
        @isTest static void reoncileCOSStudent() {
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
            Program_Competency__c testPComo = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,pExper.Id,true,4.0, false);
            testPComo.Program_Competency_Type__c = 'Core';
            insert testPComo;
            Program_Competency__c testPComo2 = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,pExper.Id,false,2.0,false);
            testPComo2.Program_Competency_Type__c = 'Specialization';
            testPComo2.FWK_Id__c = '124';
            testPComo2.Product__c = product2.id;
            insert testPComo2;
            Student_Competency__c sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
            sCometency.Contact__c = testCon.id;
            sCometency.Program_Competency__c = testPComo.ID;
            insert sCometency;
       		 PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  
            Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
            testProfile1.Primary_Program_of_Interest__c = product2.id;
            testProfile1.Email__c = 'test12@test12345.Com';
            insert testProfile1;
             Opportunity testOpty1 = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, null, false);        
            testOpty1.Admissions_Status__c = 'AD Admitted';
            testOpty1.Admissions_Status_Code__c = 'AD';
            testOpty1.StageName = 'Recommend Admit';
            testOpty1.Program_Start_Date__c = psd.Id;
            testOpty1.Brand_Profile__c = testProfile1.Id;
            testOpty1.opportunity_status_auto_values__c = 'Admitted';
            testOpty1.Initial_Price_Book__c = pb.id;
            testOpty1.Contact__c = testCon.id;
            insert testOpty1;  
            Student_Program__c sProg = TestDataGenerator.createStudentProgram(testOpty1, testCon.Id, 'Walden', false);
            sProg.IsStudentProgramActive__c = true;
            insert sProg;
          
           
            sCometency.Student_Program__c = sProg.ID;
            update sCometency;
            sProg.Program__c =  product2.id;
            update sProg;
	 		List<Student_Competency__c> oldStudentComps = new List<Student_Competency__c>([SELECT Id, FWK_Id__c, Program__c FROM Student_Competency__c WHERE Student_Program__c =:sProg.id AND Program_Competency_Type__c = 'Specialization']);
            system.debug('%%%%%%%%oldStudentComps'+oldStudentComps);
        }
    

    
}