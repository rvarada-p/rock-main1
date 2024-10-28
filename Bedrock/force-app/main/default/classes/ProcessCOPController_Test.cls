/*******************************************************************
Name  : ProcessCOPController_Test
Author: Sarah Khalid - Laureate
Date  : March 30, 2016
Description: Test Class for the Handler class ProcessCOPController and 
			 Visualforce page ProcessCOP
*************************************************************************/
@isTest (seeAllData=true)
private class ProcessCOPController_Test {
    private static testmethod void testProcessCOP() {
        // create test data
        Account testAcc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(testAcc, false); 
        testCon.Email = 'test12@test12345.Com';
        insert testCon;
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
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
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);
        opportunity testOpty1 = TestDataGenerator.createOpportunity(testAcc.id, testCon.id, 'Walden', false);
        testOpty1.Brand_Profile__c = testProfile1.id;
        insert testOpty1;
        testOpty1.Admissions_Status__c = 'AD Admitted';
        testOpty1.Admissions_Status_Code__c = 'AD';
        testOpty1.StageName = 'Recommend Admit';
        testOpty1.opportunity_status_auto_values__c = 'Admitted';
        testOpty1.Initial_Price_Book__c = pb.id;
        testOpty1.Program_Start_Date__c = psd.Id;
        testOpty1.Contact__c = testCon.id;
        update testOpty1;
    	Product2 newProductParent = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 productnew = TestDataGenerator.createProduct('test', 'Walden', false);
        productnew.Parent_Program__c = newProductParent.id;
        insert productnew;
        Program_Start_Date__c psd2 = TestDataGenerator.createProgramStartDate(false);
        psd2.Program__c = productnew.Id;
        psd2.Start_Date__c = TestDataGenerator.getFirstMondayOfMonth(Date.today()+31);
        psd2.Accepting_New_Students__c = true;
        insert psd2;


		PageReference pageRef = Page.ProcessCOP;

    	Test.setCurrentPage(pageRef);    

        ApexPages.StandardController sc = new ApexPages.standardController(testOpty1);
        
        ProcessCOPController generateTCtrl = new ProcessCOPController(sc);

		    	
    	testProfile1.Primary_Program_of_Interest__c = productnew.Id;
    	update testProfile1;
		
		generateTCtrl.getAllPrograms();
		//generateTCtrl.MethodOne();
		generateTCtrl.fromProgram = product2.Name;
		generateTCtrl.toProgram = productnew.Name;
		generateTCtrl.applicantToProgram = productnew.Id;
		generateTCtrl.selectedValue = 'applicant';
		generateTCtrl.processApplicantCOP();

    	
    }
}