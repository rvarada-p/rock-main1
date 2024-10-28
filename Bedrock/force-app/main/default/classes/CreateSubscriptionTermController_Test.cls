/*******************************************************************
Name  : CreateSubscriptionTermController_Test
Author: Vinod Kumar (Appirio)
Modified By: 
Date  : October 13 , 2014
Description: test class for the test coverage of the controller calss CreateSubscriptionTermController

* Revision History
* Horacio Sanchez   -   Jan 28, 2022    -   User Story 78073: L2: Pricebook: Update manual subscription creation process
*************************************************************************/
@isTest
private class CreateSubscriptionTermController_Test {
    
    static testMethod void myUnitTest() {
        
        // create test data
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);
        
        Id standardPricebookId = Test.getStandardPricebookId();
        
        PriceBook2 pb2 = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity 2', 6, null, true);
        
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Competency', 'Student_Competency__c','Walden', true);
        
        Account acc = TestDataGenerator.createAccount(true);
        
        Contact testCon = TestDataGenerator.createContact(acc, true);
	    
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);        
	    Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
	    product2.Parent_Program__c = parentProduct.Id;
	    insert product2;    
        
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c =product2.id;
        insert opty;
        
        // First insert a price for the standard price book
		Pricebook2 standardPB = new Pricebook2();
        standardPB.Name = 'Standard Pricebook';
        standardPB.Id = Test.getStandardPricebookId();
        
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = parentProduct.Id, UnitPrice = 1000, IsActive = false);
    	insert standardPBE;
        
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = parentProduct.Id, UnitPrice = 1000, IsActive = true);
    	insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb2.Id, Product2Id = parentProduct.Id, UnitPrice = 1000, IsActive = false, Available_for_Existing_Students__c = true);
    	insert pbe2;
                
        Date sDate = Date.newInstance(1960, 2, 17);
        
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opty,testCon.ID, null, true);        
        
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pb, 'Walden', false);
        stuSub.Start_Date__c = sDate;
        insert stuSub;
        
        test.startTest();
        PageReference pageRef = Page.Create_Subscription_Term;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(sProg);
        CreateSubscriptionTermController objController  = new CreateSubscriptionTermController(sc);        
        system.assert(objController.isStudentSubscriptionExisting);
        objController.newStudentSubscription.Start_Date__c = Date.today().adddays(1);
        //objController.newStudentSubscription.Term_Price_Book__c = pb.id;
        objController.save();
        list<Student_Subscription__c> lstStudentSubscription = [select id from Student_Subscription__c where Student_Program__c =: sProg.ID];
        system.assertEquals(lstStudentSubscription.size(), 2);
        objController.cancel();
        test.stopTest();
        
        Student_Program__c sProg2 = TestDataGenerator.createStudentProgram(opty,testCon.ID, null, true);   
        ApexPages.StandardController sc2 = new ApexPages.StandardController(sProg2);
        CreateSubscriptionTermController objController2  = new CreateSubscriptionTermController(sc2);
    }
    
    static testMethod void myUnitTest2() {
        
        // create test data
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);
        
        Id standardPricebookId = Test.getStandardPricebookId();
        
        PriceBook2 pb2 = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity 2', 6, null, true);
        PriceBook2 pb3 = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity 3', 6, null, true);
        
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Competency', 'Student_Competency__c','Walden', true);
        
        Account acc = TestDataGenerator.createAccount(true);
        
        Contact testCon = TestDataGenerator.createContact(acc, true);
	    
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);        
	    Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
	    product2.Parent_Program__c = parentProduct.Id;
	    insert product2;    
        
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c =product2.id;
        insert opty;
        
        // First insert a price for the standard price book
		Pricebook2 standardPB = new Pricebook2();
        standardPB.Name = 'Standard Pricebook';
        standardPB.Id = Test.getStandardPricebookId();
        
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = parentProduct.Id, UnitPrice = 1000, IsActive = false);
    	insert standardPBE;
        
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = parentProduct.Id, UnitPrice = 1000, IsActive = true);
    	insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb2.Id, Product2Id = parentProduct.Id, UnitPrice = 1000, IsActive = false, Available_for_Existing_Students__c = true);
    	insert pbe2;
        
        PricebookEntry pbe3 = new PricebookEntry(Pricebook2Id = pb3.Id, Product2Id = parentProduct.Id, UnitPrice = 1000, IsActive = true);
    	insert pbe3;
                
        Date sDate = Date.newInstance(1960, 2, 17);
        
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opty,testCon.ID, null, true);        
        
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pb, 'Walden', false);
        stuSub.Start_Date__c = sDate;
        insert stuSub;
        
        test.startTest();
        PageReference pageRef = Page.Create_Subscription_Term;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(sProg);
        CreateSubscriptionTermController objController  = new CreateSubscriptionTermController(sc);        
        system.assert(objController.isStudentSubscriptionExisting);
        objController.newStudentSubscription.Start_Date__c = Date.today().adddays(1);
        //objController.newStudentSubscription.Term_Price_Book__c = pb.id;
        objController.save();
        list<Student_Subscription__c> lstStudentSubscription = [select id from Student_Subscription__c where Student_Program__c =: sProg.ID];
        system.assertEquals(lstStudentSubscription.size(), 2);
        objController.cancel();
        test.stopTest();
        
        Student_Program__c sProg2 = TestDataGenerator.createStudentProgram(opty,testCon.ID, null, true);   
        ApexPages.StandardController sc2 = new ApexPages.StandardController(sProg2);
        CreateSubscriptionTermController objController2  = new CreateSubscriptionTermController(sc2);
    }    
    
}