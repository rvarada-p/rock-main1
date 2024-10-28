@isTest

public class BatchSendEmailToNonEngagement_Test {
    
    
    static testMethod void testmethodOne() {
       Account acc = TestDataGenerator.createAccount(true);
        
        Contact testCon = TestDataGenerator.createContact(acc, true);
        
        
       
        
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.Id;
        insert product2;
        
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', true);
        
        
          Id standardPricebookId = Test.getStandardPricebookId();
        PricebookEntry stdEntry = new PricebookEntry();
        stdEntry.IsActive = true;
        stdEntry.Product2Id = parentProduct.Id;
        stdEntry.Pricebook2Id = standardPricebookId;
        stdEntry.UnitPrice = 5555.00;
        stdEntry.Tuition__c = 1555.00;
        stdEntry.Tech_Fee__c = 4000.00;
        insert stdEntry;
        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        Double cost = 3000.00;
        PricebookEntry entry = TestDataGenerator.createPricebookEntry(parentProduct.Id, pBook.Id, cost, false, false);
        entry.Available_for_Existing_Students__c = true;
        entry.Tuition__c = 1000.00;
        entry.Tech_Fee__c = 2000.00;
        insert entry;

        
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = Product2.Id;
        insert opp;
        
        
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.IsStudentProgramActive__c = true; 
        insert sProg;
        
        
        
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        stuSub.Start_Date__c = System.today().addDays(-25);
        insert stuSub;
        
        sProg.Current_Student_Subscription__c = stuSub.id;
        update sprog;
        
        Institution__c waldenInstitution = [SELECT Id FROM Institution__c WHERE Name = 'Walden' LIMIT 1];
        Engagement_Rule__c engRule1 = TestDataGenerator.createEngagementRule('Met with Faculty Coach', waldenInstitution.Id, true, false);
        insert engRule1;
        
        Student_Engagement_Rule__c stuEngRule = TestDataGenerator.createStudentEngagementRule(sProg.id, engRule1.Id, true, true);
        stuEngRule.Last_Date_of_Engagement__c = System.today().addDays(-18);
        update stuEngRule;
        system.debug('sProg'+sProg.Days_Not_Engaged__c);
        
        Test.startTest();
        Database.executeBatch(new BatchSendEmailToNonEngagement());
        
        BatchSendEmailToNonEngagement objB = new BatchSendEmailToNonEngagement();    
        String sch = '3 4 2 5 6 ?'; 
        system.schedule('BatchSendEmailToNonEngagement', sch, objB); 
        Test.stopTest();   
    }
    
    static testMethod void testmethodTwo() {
        Account acc = TestDataGenerator.createAccount(true);
        
        Contact testCon = TestDataGenerator.createContact(acc, true);
        
        
       
        
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.Id;
        insert product2;
        
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', true);
        
        
          Id standardPricebookId = Test.getStandardPricebookId();
        PricebookEntry stdEntry = new PricebookEntry();
        stdEntry.IsActive = true;
        stdEntry.Product2Id = parentProduct.Id;
        stdEntry.Pricebook2Id = standardPricebookId;
        stdEntry.UnitPrice = 5555.00;
        stdEntry.Tuition__c = 1555.00;
        stdEntry.Tech_Fee__c = 4000.00;
        insert stdEntry;
        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        Double cost = 3000.00;
        PricebookEntry entry = TestDataGenerator.createPricebookEntry(parentProduct.Id, pBook.Id, cost, false, false);
        entry.Available_for_Existing_Students__c = true;
        entry.Tuition__c = 1000.00;
        entry.Tech_Fee__c = 2000.00;
        insert entry;

        
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = Product2.Id;
        insert opp;
        
        
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.IsStudentProgramActive__c = true; 
        insert sProg;
        
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        stuSub.Start_Date__c = System.today().addDays(-25);
        insert stuSub;
        
        sProg.Current_Student_Subscription__c = stuSub.id;
        update sprog;
        
        Institution__c waldenInstitution = [SELECT Id FROM Institution__c WHERE Name = 'Walden' LIMIT 1];
        Engagement_Rule__c engRule1 = TestDataGenerator.createEngagementRule('Met with Faculty Coach', waldenInstitution.Id, true, false);
        insert engRule1;
        
        Student_Engagement_Rule__c stuEngRule = TestDataGenerator.createStudentEngagementRule(sProg.id, engRule1.Id, true, true);
        stuEngRule.Last_Date_of_Engagement__c = System.today().addDays(-25);
        update stuEngRule;
        system.debug('sProg'+sProg.Days_Not_Engaged__c);
        
        Test.startTest();
        Database.executeBatch(new BatchSendEmailToNonEngagement());
        
        BatchSendEmailToNonEngagement objB = new BatchSendEmailToNonEngagement();    
        String sch = '3 4 2 5 6 ?'; 
        system.schedule('BatchSendEmailToNonEngagement', sch, objB); 
        Test.stopTest();   
    }
    
}