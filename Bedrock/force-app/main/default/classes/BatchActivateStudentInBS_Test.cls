@istest
public class BatchActivateStudentInBS_Test {
    
    private static D2L__c D2L;
    public static void setup() {
        //Insert the custom settings for D2L
        D2L__c  D2L = new D2L__c ();
        D2L.Name = 'D2L';
        D2L.LP_Version__c = 1.0;
        D2L.Update_User__c = '/d2l/api/lp/(version)/users/(userId)';
        insert D2L;      
    }
    static testMethod void testMethod1(){
       setup() ;
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.Id;
        insert product2;

        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, false);
        testCon.CBL_Student_ID__c = 'CBL12345';
        insert testCon;
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', true);
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = product2.Id;
        insert opp;
        Area_of_Expertise__c aoe= TestDataGenerator.createAreaOfExpertise(TRUE);
        update aoe;
        Student_Expertise__c stuExpert = TestDataGenerator.createCompetencyExpertise(aoe.id,'Walden', TRUE);
        Brand_Profile__c bp = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        bp.Primary_Program_of_Interest__c = product2.id;
        bp.Email__c = 'test12@test12345.Com';
        bp.LMS_ID__c = 12345;
        insert BP;

        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.IsStudentProgramActive__c = true;
        sProg.Date_Student_Activated__c = System.today();
        sProg.Brand_Profile__c = bp.Id;
        insert sProg;
        
        String CRON_EXP = '0 0 0 15 3 ? *';
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_ActiveInactiveBS());
        BatchActivateStudentInBS bc = new BatchActivateStudentInBS();
        Database.executeBatch(bc);
		String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new BatchActivateStudentInBS());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
        Test.StopTest();   
        
    }
  

}