/************************************************************************
Name  : SendInvoice_Test
Author: Sarah Khalid - Laureate
Date  : March 1, 2016
Description: test class for the  batch class BatchSendInvoice and SendInvoice
*************************************************************************/
@isTest

private with sharing class SendInvoice_Test {
    static testMethod void myUnitTest() {

        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Competency', 'Student_Competency__c','Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        testCon.Walden_Email__c = 'test@test.com';
        update testCon;
	    Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);        
	    Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
	    product2.Parent_Program__c = parentProduct.Id;
	    insert product2;            
        Id standardPricebookId = Test.getStandardPricebookId();
        Pricebook2 pb = new Pricebook2(ID=standardPricebookId,Subscription_Duration_in_Months__c = 0);
        update pb;
        Date dtLastDaydate = Date.today().addDays(-1);
        system.debug('pb.Subscription_Duration_in_Months__c::::::::'+pb.Subscription_Duration_in_Months__c);
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c = product2.id;
        insert opty;      
        PricebookEntry pbEntery = TestDataGenerator.createPricebookEntry(parentProduct.id,standardPricebookId, 200, false,false);
        pbEntery.Available_for_Existing_Students__c = true;
        insert pbEntery;
        Test.StartTest();
        Date sDate = Date.today().addDays(-200);
        list<Student_Program__c> lstSprogram = new list<Student_Program__c>();
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false); 
        sProg.IsStudentProgramActive__c = true;
        sprog.Program__c = product2.ID;
        sprog.Student_Enrollment_Status_Code__c = 'EL';
        lstSprogram.add(sProg);  
        Student_Program__c sProg1 = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false); 
        sProg1.IsStudentProgramActive__c = true;
        sprog1.Program__c = product2.ID;
        sprog1.Student_Enrollment_Status_Code__c = 'EL';
        sprog1.Leave_of_Absence_LOA_From__c = Date.today().addDays(2);
        sprog1.LOA_Processed__c = Date.today();
        lstSprogram.add(sProg1);         
        Student_Program__c sProg2 = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false); 
        sProg2.IsStudentProgramActive__c = true;
        sprog2.Student_Enrollment_Status_Code__c = 'EL';
        sprog2.Program__c = product2.ID;
        sprog2.Leave_of_Absence_LOA_From__c = Date.today().addDays(2);
        sprog2.LOA_Processed__c = Date.today();
        lstSprogram.add(sProg2);               
        insert lstSprogram;
        list<Student_Subscription__c> lstStudentSubscription = new list<Student_Subscription__c>();
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pb, 'Walden', false);
        stuSub.Start_Date__c = Date.today();
        stuSub.Subscription_Status__c = 'RE = Registered';
        stuSub.End_Date__c = Date.today().addDays(2);
        lstStudentSubscription.add(stuSub);     
        insert lstStudentSubscription;
        sprog.Current_Student_Subscription__c = null;
        update sprog;
        Date yesterday = Date.today().addDays(-1);
        list<Student_Subscription__c> lstStudentSubscription2 = new list<Student_Subscription__c>();        
        Student_Subscription__c stuSub2 = TestDataGenerator.createStudentSubscription(sProg1, pb, 'Walden', false);
        stuSub2.Start_Date__c = Date.today().addDays(-2);
        stuSub2.Subscription_Status__c = 'RE = Registered';    
        stuSub2.End_Date__c = yesterday;    
        stuSub2.Invoice_Sent__c = false;
        lstStudentSubscription2.add(stuSub2);
        Student_Subscription__c stuSub3 = TestDataGenerator.createStudentSubscription(sProg1, pb, 'Walden', false);
        stuSub3.Start_Date__c = Date.today();
        stuSub3.End_Date__c = Date.today().addDays(4);
        stuSub3.Subscription_Status__c = 'RE = Registered'; 
        stuSub3.Invoice_Sent__c = false;
        lstStudentSubscription.add(stuSub3);   
        Student_Subscription__c stuSub4 = TestDataGenerator.createStudentSubscription(sProg2, pb, 'Walden', false);
        stuSub4.Start_Date__c =  Date.today().addDays(-2);
        stuSub4.End_Date__c = yesterday;
        stuSub4.Subscription_Status__c = 'RE = Registered';  
        stuSub4.Invoice_Sent__c = false;
        lstStudentSubscription2.add(stuSub4);
        Student_Subscription__c stuSub5 = TestDataGenerator.createStudentSubscription(sProg2, pb, 'Walden', false);
        stuSub5.Start_Date__c =  Date.today();
        stuSub5.End_Date__c = Date.today().addDays(4);
        stuSub5.Subscription_Status__c = 'RE = Registered';  
        stuSub5.Invoice_Sent__c = false;
        lstStudentSubscription2.add(stuSub5);
        insert lstStudentSubscription2;
        sProg1.Current_Student_Subscription__c = stuSub2.ID;
        sProg2.Current_Student_Subscription__c = stuSub4.ID;
        update sProg1;
        update sProg2;
        BatchSendInvoice objBatch = new BatchSendInvoice();
        ID batchprocessid = Database.executeBatch(objBatch,10);   
        Student_Subscription__c updatedStuSub = [Select id,End_Date__c,Subscription_Status__c from Student_Subscription__c where id =:stuSub.ID];
         system.debug('updatedStuSub:::::::::'+updatedStuSub);
         system.debug('dtLastDaydate:::::::::'+dtLastDaydate);
        Student_Program__c updatedSprog = [select IsStudentProgramActive__c, Current_Student_Subscription__r.Subscription_Status__c ,               
                 Current_Student_Subscription__c , Current_Student_Subscription__r.End_Date__c  from Student_Program__c where id =:sProg.id];
        system.debug('updatedSprog:::::::::'+updatedSprog);    
        objBatch.execute(null);
        Test.stopTest();
       // updatedSProg =[select id,Current_Student_Subscription__c from Student_Program__c where id =:sProg.id];
        //system.assert(updatedSProg.Current_Student_Subscription__c !=  null );
    }   
}