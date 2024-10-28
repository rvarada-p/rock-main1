/*******************************************************************
Name  : StudentCompetencyTriggerHandler
Author: (Appirio)
Date  : September 30, 2014
***************************************************************/
@isTest
private class StudentDiscountTriggerHandler_Test {
    private static list<Student_Discount__c> studentDiscounts;
    private static list<Opportunity> opps;
    private static List<Exemption__c> exemptions;
    private static void setup(){
    	Test.startTest();
        RecordTypes_For_CBL_Processes__c objCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Subscription', 'Student_Subscription__c','Walden', true);
        TestDataGenerator.createRecordTypesForCBLProcesses('opportunity', 'Opportunity', 'Walden', true);

        //TriggerSettings__c objTrgSetting = TestDataGenerator.createTriggerSettings('StudentSubscriptionTrigger', true, true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);

        List<Product2> products = new List<Product2>();
        Product2 parentProduct = TestDataGenerator.createProduct('parent', 'Walden', true);
        Product2 test0 = TestDataGenerator.createProduct('test0', 'Walden', false);
        test0.Parent_Program__c = parentProduct.id;
        products.add(test0);
        Product2 test1 = TestDataGenerator.createProduct('test1', 'Walden', false);
        test1.Parent_Program__c = parentProduct.id;
        products.add(test1);
        Product2 test2 = TestDataGenerator.createProduct('test2', 'Walden', false);
        test2.Parent_Program__c = parentProduct.id;
        products.add(test2);
        Product2 test3 = TestDataGenerator.createProduct('test3', 'Walden', false);
        test3.Parent_Program__c = parentProduct.id;
        products.add(test3);
        insert products;

        opps = new List<Opportunity>();
        Opportunity opp0 = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp0.Primary_Program__c = products.get(0).Id;
        opps.add(opp0);
        Opportunity opp1 = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp1.Primary_Program__c = products.get(1).Id;
        opps.add(opp1);
        Opportunity opp2 = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp2.Primary_Program__c = products.get(2).Id;
        opps.add(opp2);
        insert opps;
        

        //create standard pricebook
        Id standardPricebookId = Test.getStandardPricebookId();
		
        //create standard prices
        List<PriceBookEntry> standardEntries = new List<PricebookEntry>();
        standardEntries.add(TestDataGenerator.createPricebookEntry(parentProduct.id, standardPricebookId, 100, false, false));
        //standardEntries.add(TestDataGenerator.createPricebookEntry(products.get(1).id, standardPricebookId, 100, false, false));
        //standardEntries.add(TestDataGenerator.createPricebookEntry(products.get(2).id, standardPricebookId, 100, false, false));
        //standardEntries.add(TestDataGenerator.createPricebookEntry(products.get(3).id, standardPricebookId, 100, false, false));
        insert standardEntries;

        List<PriceBookEntry> pricebookentries = new List<PricebookEntry>();
        pricebookentries.add(TestDataGenerator.createPricebookEntry(parentProduct.id, opps.get(0).Initial_Price_Book__c, 1000, false, false));
        //pricebookentries.add(TestDataGenerator.createPricebookEntry(products.get(1).id, opps.get(0).Initial_Price_Book__c, 2000, false, false));
        //pricebookentries.add(TestDataGenerator.createPricebookEntry(products.get(1).id, opps.get(1).Initial_Price_Book__c, 3000, false, false));
        //pricebookentries.add(TestDataGenerator.createPricebookEntry(products.get(3).id, opps.get(1).Initial_Price_Book__c, 4000, false, false));
        //pricebookentries.add(TestDataGenerator.createPricebookEntry(products.get(2).id, opps.get(2).Initial_Price_Book__c, 5000, false, false));
        insert pricebookentries;

        //now setup exemptions
        exemptions = new List<Exemption__c>();
        exemptions.add(TestDataGenerator.createExemption(0,1,false));
        exemptions.add(TestDataGenerator.createExemption(100,0,false));
        exemptions.add(TestDataGenerator.createExemption(0,2,false));
        insert exemptions;


        //now setup student discounts
        studentDiscounts = new List<Student_Discount__c>();
        studentDiscounts.add(TestDataGenerator.createStudentDiscount(opps.get(0), null, exemptions.get(0), false));
        studentDiscounts.add(TestDataGenerator.createStudentDiscount(opps.get(0), null, exemptions.get(1), false));
        studentDiscounts.add(TestDataGenerator.createStudentDiscount(opps.get(1), null, exemptions.get(2), false));
        insert studentDiscounts;
        Test.stopTest();
    }
    
    @isTest static void testAfterInsertDiscountApplied() {
        setup();

        Map<Id, Opportunity> updatedOpps = new Map<Id, Opportunity>([select id, amount from opportunity where id in: opps]);

        Opportunity opp0 = updatedOpps.get(studentDiscounts.get(0).opportunity__c);
        Opportunity opp1 = updatedOpps.get(studentDiscounts.get(2).opportunity__c);

        //System.assertEquals(990, opp0.amount);
        //System.assertEquals(900, opp1.amount);

    }
    @isTest static void testAfterUpdateDiscountApplied() {
        setup();

        studentDiscounts.get(0).opportunity__c = null;
        studentDiscounts.get(1).opportunity__c = opps.get(1).id;
        studentDiscounts.get(2).opportunity__c = opps.get(2).id;

        update studentDiscounts;

        Map<Id, Opportunity> updatedOpps = new Map<Id, Opportunity>([select id, amount from opportunity where id in: opps]);

        Opportunity opp1 = updatedOpps.get(studentDiscounts.get(1).opportunity__c);
        Opportunity opp2 = updatedOpps.get(studentDiscounts.get(2).opportunity__c);

        //System.assertEquals(2900, opp1.amount);
        //System.assertEquals(4900, opp2.amount);

    }
    @isTest static void testAfterDeleteDiscountApplied() {
        setup();

        //delete the 100$ discount
        delete studentDiscounts.get(1);

        Map<Id, Opportunity> updatedOpps = new Map<Id, Opportunity>([select id, amount from opportunity where id in: opps]);

        Opportunity opp0 = updatedOpps.get(studentDiscounts.get(0).opportunity__c);
        Opportunity opp1 = updatedOpps.get(studentDiscounts.get(2).opportunity__c);

        //System.assertEquals(990, opp0.amount);
        //System.assertEquals(2940, opp1.amount);

    }
    // method test synsStudentDiscountOnOpportunityAndStudentProgram method
	@isTest static void testSynsStudentDiscountOnOpportunityAndStudentProgram() {
       RecordTypes_For_CBL_Processes__c objCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Subscription', 'Student_Subscription__c','Walden', true);
       TestDataGenerator.createRecordTypesForCBLProcesses('opportunity', 'Opportunity', 'Walden', true);
       //TriggerSettings__c objTrgSetting = TestDataGenerator.createTriggerSettings('StudentSubscriptionTrigger', true, true);
       Account acc = TestDataGenerator.createAccount(true);
       Contact testCon = TestDataGenerator.createContact(acc, true);
       Product2 parentProduct = TestDataGenerator.createProduct('parent', 'Walden', true); 
       Product2 products = TestDataGenerator.createProduct('test0', 'Walden', false); 
       products.Parent_Program__c = parentProduct.id;
       insert products;
       Opportunity opp1 = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
       opp1.Primary_Program__c = products.Id;
       insert opp1;
       Student_Program__c sp1 = TestDataGenerator.createStudentProgram(opp1,testCon.ID, 'Walden', false);
       sp1.Application__c = opp1.ID;
       insert sp1;
       Student_Program__c sp2 = TestDataGenerator.createStudentProgram(opp1,testCon.ID, 'Walden', false);
       sp2.Application__c = null;
       insert sp2;
       Opportunity opp2 = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
       opp2.Primary_Program__c = products.Id;
       opp2.Student_Program__c = sp2.ID;
       insert opp2;
       Exemption__c exc = new Exemption__c();
       exc.Name= 'Discount 1';
       exc.Fee_Type__c = 'Tech Fee';
       exc.Flat_Rate_Amount__c=300.50;
       exc.Institution__c = TestDataGenerator.createInstitution('Walden', true).Id;
       exc.Life_of_Program__c = true;
       exc.Active__c = true;
       exc.Exemption_Category__c = 'Standard Reduction';
       insert exc; 
       // create student discount
       list<Student_Discount__c> lstStudentDiscount = new list<Student_Discount__c>();
       Student_Discount__c sdc = TestDataGenerator.createStudentDiscount(opp2,null,exc, false );    
       lstStudentDiscount.add(sdc);
       Student_Discount__c sdc2 = TestDataGenerator.createStudentDiscount(opp1,null,exc, false );   
       sdc2.Opportunity__c = null;
       sdc2.Student_Program__c = sp1.id;
       lstStudentDiscount.add(sdc2);      
       insert  lstStudentDiscount;
       sdc = [Select ID,Student_Program__c,Opportunity__c from Student_Discount__c where id=:sdc.ID];
       System.assertEquals(sdc.Student_Program__c, sp2.ID);
       sdc2 = [Select ID,Opportunity__c,Student_Program__c from Student_Discount__c where id=:sdc2.ID];
       System.assertEquals(sdc2.Opportunity__c, opp1.ID);

    }
    
}