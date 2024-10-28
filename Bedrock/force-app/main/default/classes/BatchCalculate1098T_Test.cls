/************************************************************************************** 
Apex Class Name     : BatchCalculate1098T_Test
Created Date        : 27th Sep 2019
Function            : Test class for BatchCalculate1098T class
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                  
* Ravitej Varada            09/27/2019                Original Version
*************************************************************************************/
@isTest
public class BatchCalculate1098T_Test{
    
    Public static Student_Program__c sProg;
    Public static Pricebook2 pBook;    
    
    static void setup() {
        
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, false);
        testCon.Carry_Over_Amount__c = 77;
        insert testCon;
        
        Product2 parentProd = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', false);
        prod.Parent_Program__c = parentProd.id;
        insert prod;
        
        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = prod.Id;
        psd.Accepting_New_Students__c = true;
        insert psd;
        
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = prod.Id;
        opp.Program_Start_Date__c = psd.Id;
        insert opp;
        
        sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.Program__c =prod.id;
        insert sProg;
        
        Id standardPricebookId = Test.getStandardPricebookId();
        PricebookEntry stdEntry = new PricebookEntry();
        stdEntry.IsActive = true;
        stdEntry.Product2Id = parentProd.Id;
        stdEntry.Pricebook2Id = standardPricebookId;
        stdEntry.UnitPrice = 5555.00;
        insert stdEntry;
        pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        
        
    }
    
    static testMethod void testMethodOne() {
        setup();
        
        Script_Settings__c setting = new Script_Settings__c();
        setting.Name = 'Current Settings';
        setting.disableSubEndDateValidation__c = true;
        setting.disableSubMondayValidation__c = true;
        setting.X1098T_Cut_Of_Date__c = Date.newInstance(2019, 1, 06);
        insert setting;
        
        
        List<Student_Transaction__c> stuTranLst = new List<Student_Transaction__c>();
        
        Student_Subscription__c oldStuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        oldStuSub.Start_Date__c =  Date.Today().addYears(-1);
        oldStuSub.Subscription_Status__c = 'RE = Registered';
        oldStuSub.List_Price__c = 400;
        insert oldStuSub;
        
          
        Student_Transaction__c stuTranP1 = new Student_Transaction__c();
        stuTranP1.Payment_Amount__c = -800;
        stuTranP1.Transaction_Date__c = system.today();
        stuTranP1.Transaction_Type__c = 'Payment - CC';
        stuTranP1.Student_Subscription__c = oldStuSub.id;
        stuTranLst.add(stuTranP1);
        
        Student_Transaction__c stuTranP2 = new Student_Transaction__c();
        stuTranP2.Grant_Scholarship_Amount__c = -100;
        stuTranP2.Student_Subscription__c = oldStuSub.id;
        stuTranP2.Transaction_Date__c = system.today();
        stuTranP2.Transaction_Type__c = 'Scholarship';
        stuTranLst.add(stuTranP2);
        
         Student_Transaction__c stuTranP3 = new Student_Transaction__c();
        stuTranP3.Refund_Amount__c = -200;
        stuTranP3.Student_Subscription__c = oldStuSub.id;
        stuTranP3.Transaction_Date__c = system.today();
        stuTranP3.Transaction_Type__c = 'Refund to Third Party';
        stuTranLst.add(stuTranP3);
        
        Student_Transaction__c stuTranP4 = new Student_Transaction__c();
        stuTranP4.Payment_Amount__c = 100;
        stuTranP4.Transaction_Date__c = system.today();
        stuTranP4.Transaction_Type__c = 'Payment - Payment Plan';
        stuTranP4.Student_Subscription__c = oldStuSub.id;
        stuTranLst.add(stuTranP4);
        
         
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        stuSub.Start_Date__c = Date.Today();
        stuSub.List_Price__c = 400;
        stuSub.Subscription_Status__c = 'RE = Registered';
        insert stuSub;
        
        
        Student_Transaction__c stuTran = new Student_Transaction__c();
        stuTran.Payment_Amount__c = 600;
        stuTran.Transaction_Date__c = system.today();
        stuTran.Transaction_Type__c = 'Payment - Payment Plan';
        stuTran.Student_Subscription__c = stuSub.id;
        stuTranLst.add(stuTran);
        
        Student_Transaction__c stuTran1 = new Student_Transaction__c();
        stuTran1.Refund_Amount__c = 100;
        stuTran1.Transaction_Date__c = system.today();
        stuTran1.Transaction_Type__c = 'Refund to Third Party';
        stuTran1.Student_Subscription__c = stuSub.id;

        stuTranLst.add(stuTran1);
        
        Student_Transaction__c stuTran2 = new Student_Transaction__c();
        stuTran2.Grant_Scholarship_Amount__c = 100;
        stuTran2.Student_Subscription__c = stuSub.id;
        
        stuTran2.Transaction_Date__c = system.today();
        stuTran2.Transaction_Type__c = 'Scholarship';
        stuTranLst.add(stuTran2);
        
        Student_Transaction__c stuTran3 = new Student_Transaction__c();
        stuTran3.Payment_Amount__c = 700;
        stuTran3.Transaction_Date__c = system.today();
        stuTran3.Transaction_Type__c = 'FinAid Payment';
        stuTran3.Student_Subscription__c = stuSub.id;
        stuTranLst.add(stuTran3);
        
        insert stuTranLst;
         
          Test.startTest();
        BatchCalculate1098T objB = new BatchCalculate1098T();   
        database.executeBatch(objB);
        
        Test.stopTest();
    }
    
    static testMethod void testMethodTwo() {
        setup();
        
        Script_Settings__c setting = new Script_Settings__c();
        setting.Name = 'Current Settings';
        setting.disableSubEndDateValidation__c = true;
        setting.disableSubMondayValidation__c = true;
        setting.X1098T_Cut_Of_Date__c = date.today();  
        insert setting;
        
        
        List<Student_Transaction__c> stuTranLst = new List<Student_Transaction__c>();
        
        Student_Subscription__c oldStuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        oldStuSub.Start_Date__c =  Date.Today().addYears(-1);
        oldStuSub.Subscription_Status__c = 'RE = Registered';
        oldStuSub.List_Price__c = 400;
        insert oldStuSub;
        
          
        Student_Transaction__c stuTranP1 = new Student_Transaction__c();
        stuTranP1.Payment_Amount__c = -800;
        stuTranP1.Transaction_Date__c = system.today().addYears(-1);
        stuTranP1.Transaction_Type__c = 'Payment - CC';
        stuTranP1.Student_Subscription__c = oldStuSub.id;
        stuTranLst.add(stuTranP1);
        
        Student_Transaction__c stuTranP2 = new Student_Transaction__c();
        stuTranP2.Grant_Scholarship_Amount__c = -100;
        stuTranP2.Student_Subscription__c = oldStuSub.id;
        stuTranP2.Transaction_Date__c = system.today().addYears(-1);
        stuTranP2.Transaction_Type__c = 'Scholarship';
        stuTranLst.add(stuTranP2);
        
         Student_Transaction__c stuTranP3 = new Student_Transaction__c();
        stuTranP3.Refund_Amount__c = -200;
        stuTranP3.Student_Subscription__c = oldStuSub.id;
        stuTranP3.Transaction_Date__c = system.today().addYears(-1);
        stuTranP3.Transaction_Type__c = 'Refund to Third Party';
        stuTranLst.add(stuTranP3);
        
        Student_Transaction__c stuTranP4 = new Student_Transaction__c();
        stuTranP4.Payment_Amount__c = 100;
        stuTranP4.Transaction_Date__c = system.today().addYears(-1);
        stuTranP4.Transaction_Type__c = 'Payment - Payment Plan';
        stuTranP4.Student_Subscription__c = oldStuSub.id;
        stuTranLst.add(stuTranP4);
        
         
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        stuSub.Start_Date__c = Date.Today();
        stuSub.List_Price__c = 400;
        stuSub.Subscription_Status__c = 'RE = Registered';
        insert stuSub;
        
        
        Student_Transaction__c stuTran = new Student_Transaction__c();
        stuTran.Payment_Amount__c = 600;
        stuTran.Transaction_Date__c = system.today().addYears(-1);
        stuTran.Transaction_Type__c = 'Payment - Payment Plan';
        stuTran.Student_Subscription__c = stuSub.id;
        stuTranLst.add(stuTran);
        
        Student_Transaction__c stuTran1 = new Student_Transaction__c();
        stuTran1.Refund_Amount__c = 100;
        stuTran1.Transaction_Date__c = system.today().addYears(-1);
        stuTran1.Transaction_Type__c = 'Refund to Third Party';
        stuTran1.Student_Subscription__c = stuSub.id;

        stuTranLst.add(stuTran1);
        
        Student_Transaction__c stuTran2 = new Student_Transaction__c();
        stuTran2.Grant_Scholarship_Amount__c = 100;
        stuTran2.Student_Subscription__c = stuSub.id;
        
        stuTran2.Transaction_Date__c = system.today().addYears(-1);
        stuTran2.Transaction_Type__c = 'Scholarship';
        stuTranLst.add(stuTran2);
        
        Student_Transaction__c stuTran3 = new Student_Transaction__c();
        stuTran3.Payment_Amount__c = 700;
        stuTran3.Transaction_Date__c = system.today().addYears(-1);
        stuTran3.Transaction_Type__c = 'FinAid Payment';
        stuTran3.Student_Subscription__c = stuSub.id;
        stuTranLst.add(stuTran3);
        
        insert stuTranLst;
        
        Test.startTest();
        Database.executeBatch(new BatchCalculate1098T());
        String CRON_EXP = '0 0 0 15 3 ? *';
        
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new BatchCalculate1098T());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
         
    }
}