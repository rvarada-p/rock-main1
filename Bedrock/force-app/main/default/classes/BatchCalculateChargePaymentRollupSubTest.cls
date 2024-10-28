@isTest
private class BatchCalculateChargePaymentRollupSubTest {
    static testMethod void testMethod_One() {
        RecordTypes_For_CBL_Processes__c objCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Subscription', 'Student_Subscription__c','Walden', true);
        //TriggerSettings__c objTrgSetting = TestDataGenerator.createTriggerSettings('StudentSubscriptionTrigger', true, true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProd = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', false);
        prod.Parent_Program__c = parentProd.Id;
        insert prod;
        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = prod.Id;
        psd.Accepting_New_Students__c = true;
        insert psd;
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = prod.Id;
        opp.Program_Start_Date__c = psd.Id;
        insert opp;
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.Program__c =prod.id;
        insert sProg;
        Date sDate = Date.newInstance(1960, 2, 1);
        Date eDate = Date.newInstance(1960, 6, 5);


        Test.startTest();

        Account sponsorAccount = TestDataGenerator.createSponsorAccount('Sponsor', true);

        Id standardPricebookId = Test.getStandardPricebookId();
        PricebookEntry stdEntry = new PricebookEntry();
        stdEntry.IsActive = true;
        stdEntry.Product2Id = prod.Id;
        stdEntry.Pricebook2Id = standardPricebookId;
        stdEntry.UnitPrice = 5555.00;
        insert stdEntry;
        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        Double cost = 3000.00;
        PricebookEntry entry = TestDataGenerator.createPricebookEntry(prod.Id, pBook.Id, cost, false, false);
        entry.Available_for_Existing_Students__c = true;
        insert entry;

        Exemption__c exmp = TestDataGenerator.createExemption(100, 0, true);
        Student_Discount__c stuDiscount = TestDataGenerator.createStudentDiscount(opp, sProg, exmp, true);



        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        stuSub.Start_Date__c = Date.newInstance(2014, 10, 6);
        insert stuSub;


        Student_Transaction__c stuTransaction = TestDataGenerator.createStudentTransaction(stuSub.Id,sponsorAccount.Id, 100, 'Sponsor Payment', System.today(), false);
        stuTransaction.Payment_Amount__c = 150;
        stuTransaction.Transaction_Type__c = 'Payment - Payment Plan';
        stuTransaction.Transaction_Date__c = Date.newInstance(System.today().year() + 1, System.today().month(), System.today().day());
        Insert stuTransaction;
         BatchCalculateChargePaymentRollupOnSub objBatch = new BatchCalculateChargePaymentRollupOnSub();
         Database.executeBatch(objBatch, 200);
    }

}