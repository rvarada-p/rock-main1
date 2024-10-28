/************************************************************************
Name  : StudentRetention_Test
Author: Sarah Khalid
Date  : June 2, 2017
Description: test class for the  batch class BatchStudentRetention and StudentRetentionHelper
*************************************************************************/
@isTest
private class StudentRetention_Test {
   static testMethod void myUnitTest() {
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Competency', 'Student_Competency__c','Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
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
        insert lstSprogram;

		Script_Settings__c setting = new Script_Settings__c();
		setting.Name = 'Current Settings';
		setting.disableSubEndDateValidation__c = false;
		setting.disableSubMondayValidation__c = false;
		setting.CheckDateOnSubscriptionRenewal__c = true;
		setting.CheckDateOnStudentRetention__c = true;
		insert setting;
        
        BatchStudentRetention objBatch = new BatchStudentRetention();
        ID batchprocessid = Database.executeBatch(objBatch,10);   
        //Student_Retention__c studentRetentionRecord = [Select id from Student_Retention__c where Student_Program__c =:lstSprogram];
        //system.debug('Student Retention:::::::::'+studentRetentionRecord);    
        objBatch.execute(null);
        Test.stopTest();
        //updatedSProg =[select id,Current_Student_Subscription__c from Student_Program__c where id =:sProg.id];
    		
   }
}