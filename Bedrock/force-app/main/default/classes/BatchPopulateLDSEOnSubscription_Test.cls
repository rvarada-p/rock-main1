@isTest
private class BatchPopulateLDSEOnSubscription_Test {
    
    static Account acc;
    static Contact cont;    
    static Opportunity opp;
    static Student_Program__c studentProgram;
    
    static void setup() {
        acc = TestDataGenerator.createAccount(true);
        cont = TestDataGenerator.createContact(acc, true);
        opp = TestDataGenerator.createOpportunity(acc.Id, cont.Id, 'Walden', true);
        studentProgram = TestDataGenerator.createStudentProgram(opp, cont.Id, 'Walden', true);
        opp.Student_Program__c = studentProgram.Id;
        update(opp);
        Product2 parentProd = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', false);
        prod.Parent_Program__c = parentProd.id;
        insert prod;
        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        Double cost = 3000.00;
    
          date todayMinusFiveDays  = date.today()-5;
        date todayAddFiveDays  = date.today()+5;

        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(studentProgram, pBook, 'Walden', false);
        stuSub.Start_Date__c = todayMinusFiveDays;
        stuSub.End_Date__c = todayAddFiveDays;
        insert stuSub;
        
        
        studentProgram.Current_Student_Subscription__c = stuSub.id;
        update studentProgram;
        
      system.debug('stuSub'+stuSub);
        Institution__c waldenInstitution = TestDataGenerator.createInstitution('Walden',  true);
        Engagement_Rule__c  engRule1 = TestDataGenerator.createEngagementRule('Met with Faculty Coach', waldenInstitution.Id, true, false);
        Engagement_Rule__c  engRule2 = TestDataGenerator.createEngagementRule('Submitted or Updated Plan', waldenInstitution.Id, true, false);
        List<Engagement_Rule__c> engRules = new List<Engagement_Rule__c>{engRule1, engRule2};
            insert engRules;
        user u = [Select id,name from User where name = 'BI User'];
        Student_Engagement_Rule__c  stuEngRule1 = TestDataGenerator.createStudentEngagementRule(studentProgram.Id, engRule1.id, true, false);
        Student_Engagement_Rule__c  stuEngRule2 = TestDataGenerator.createStudentEngagementRule(studentProgram.Id, engRule2.id, true, false);
        system.runAs(u){
            List<Student_Engagement_Rule__c> stuEngRules = new List<Student_Engagement_Rule__c>{stuEngRule2, stuEngRule1};
                insert stuEngRules;   
            stuEngRules[0].Last_Date_of_Engagement__c = date.today();
            stuEngRules[1].Last_Date_of_Engagement__c = date.today();
            update stuEngRules;
            system.debug('stuEngRules'+stuEngRules);
        }
        
        
        
    }
    
    
    static testMethod void testUpdateRemainingLOAMonthsOnSP() {
        setup();
        Test.startTest();
        Database.executeBatch(new BatchPopulateLDSEOnSubscription());
        String CRON_EXP = '0 0 0 15 3 ? *';
        
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new BatchPopulateLDSEOnSubscription());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
        
    }
   

}