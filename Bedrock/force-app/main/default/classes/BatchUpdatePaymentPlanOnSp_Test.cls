@isTest

public class BatchUpdatePaymentPlanOnSp_Test {

    
    static testMethod void testmethodOne() {
        Account acc = TestDataGenerator.createAccount(true);
        
        Contact testCon = TestDataGenerator.createContact(acc, true);
        
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.Id;
        insert product2;
        
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', true);
        
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = Product2.Id;
        insert opp;
      
        
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.IsStudentProgramActive__c = true; 
        insert sProg;
        
     
        Test.startTest();
        Database.executeBatch(new BatchUpdatePaymentPlanOnSp());
        
          BatchUpdatePaymentPlanOnSp objB = new BatchUpdatePaymentPlanOnSp();    
        String sch = '3 4 2 5 6 ?'; 
        system.schedule('BatchUpdatePaymentPlanOnSp', sch, objB); 
        Test.stopTest();   
    }
     
}