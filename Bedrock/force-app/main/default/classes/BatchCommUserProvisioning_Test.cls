@istest
private  class BatchCommUserProvisioning_Test {    
  

    static testMethod void testMethod1(){
     
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, false);
        testCon.CBL_Student_ID__c = 'CBL12345';
        insert testCon;
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', true);
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        insert opp;        
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.IsStudentProgramActive__c = false;
        sProg.Date_Student_De_activated__c = System.today();
        sProg.Student_Enrollment_Status__c  = 'Eligible to Register (EL)';
        insert sProg;
      
        Test.StartTest();
        	BatchCommUserProvisioning bc = new BatchCommUserProvisioning();
        	Database.executeBatch(bc);
			
        Test.StopTest();   
        
    }
  

}