@istest
public class StudentLedgerController_Test {
    Public static Student_Program__c sProg;
    Public static opportunity opp;
    Public static contact testCon;
    Public static Product2 prod;
    Public static Pricebook2 pBook;    
    
    static void setup() {
        
        Account acc = TestDataGenerator.createAccount(true);
        testCon = TestDataGenerator.createContact(acc, false);
        testCon.Carry_Over_Amount__c = 77;
        testCon.SSN__c = '238328923';
        insert testCon;
        
        Product2 parentProd = TestDataGenerator.createProduct('test', 'Walden', true);
        prod = TestDataGenerator.createProduct('test', 'Walden', false);
        prod.Parent_Program__c = parentProd.id;
        insert prod;
        
        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = prod.Id;
        psd.Accepting_New_Students__c = true;
        insert psd;
        
        opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
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
        
        List<Student_Transaction__c> stuTranLst = new List<Student_Transaction__c>();
        
        Student_Subscription__c oldStuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        oldStuSub.Start_Date__c =  Date.Today().addYears(-1);
        oldStuSub.Subscription_Status__c = 'RE = Registered';
        
        oldStuSub.Tuition__c= 325;
        oldStuSub.Tech_Fee__c = 75 ;
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
        stuSub.Tuition__c= 325;
        stuSub.Tech_Fee__c = 75 ;
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
        
        Student_Transaction__c stuTran4 = new Student_Transaction__c();
        stuTran4.Discount_Amount__c = 700;
        stuTran4.Transaction_Date__c = system.today();
        stuTran4.Transaction_Type__c = 'Subscription Reduction';
        stuTran4.Student_Subscription__c = stuSub.id;
        stuTranLst.add(stuTran4);
        
        Student_Transaction__c stuTran5 = new Student_Transaction__c();
        stuTran5.Miscellaneous_Adjustment__c = 700;
        stuTran5.Transaction_Date__c = system.today();
        stuTran5.Transaction_Type__c = 'Tuition Adjustment';
        stuTran5.Student_Subscription__c = stuSub.id;
        stuTranLst.add(stuTran5);
        Student_Transaction__c stuTran6 = new Student_Transaction__c();
        stuTran6.Miscellaneous_Adjustment__c = 700;
        stuTran6.Transaction_Date__c = system.today();
        stuTran6.Transaction_Type__c = 'Adjustment – Waiver';
        stuTran6.Student_Subscription__c = stuSub.id;
        stuTranLst.add(stuTran6);
        
        
        Student_Transaction__c stuTran7 = new Student_Transaction__c();
        stuTran7.Grant_Scholarship_Amount__c = 700;
        stuTran7.Transaction_Date__c = system.today();
        stuTran7.Transaction_Type__c = 'Scholarship';
        stuTran7.Student_Subscription__c = stuSub.id;
        stuTranLst.add(stuTran7);
        
        insert stuTranLst;
        
        
        Test.startTest();
        StudentLedgerController.getStudentTrans (testCon.id,null,null,null,null,null);
        StudentLedgerController.getStudentTrans (testCon.id,system.today(),system.today().addDays(4),'SUB-90988',prod.name,'Scholarship');
        StudentLedgerController.getStudentTrans (testCon.id,null,null,null,prod.name,null);
        StudentLedgerController.getContactDetails (testCon.id);
        Test.stopTest();
    }
    
    
    
    
}