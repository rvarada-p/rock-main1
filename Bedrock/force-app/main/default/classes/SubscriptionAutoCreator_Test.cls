/************************************************************************
Name  : SubscriptionAutoCreator_Test 
Author: Vinod (Appirio)
Date  : October 14, 2014
Description: test class for SubscriptionAutoCreator and batch class BatchAutoSubscriptionCreation
TODO: This class could be refactored to really just test SubscriptionAutoCreator 
      and another class should be created to just test BatchAutoSubscriptionCreation


Revision History 
Ravitej Varada - 02/04/2022 - S-78405  L2: Pricebook: Update Auto Batch Test class
*************************************************************************/
@isTest(seeAllData=false)
private class SubscriptionAutoCreator_Test {

    static testMethod void testCreateSubscription() {
        
        List<Sub_Price_Book_Rule__c> priceBookRules = new List<Sub_Price_Book_Rule__c> ();
        
        Sub_Price_Book_Rule__c rule1= new Sub_Price_Book_Rule__c();
        
        rule1.Name = 'Rule 1';
        rule1.From_Date__c  = Date.newInstance(2012, 12, 31);
        rule1.Get_Price_Book__c  = 'Old';
        rule1.To_Date__c  = Date.newInstance(2019, 12, 31);
        priceBookRules.add(rule1);
        
              Sub_Price_Book_Rule__c rule2= new Sub_Price_Book_Rule__c();
        
        rule2.Name = 'Rule 2';
        rule2.From_Date__c  = Date.newInstance(2020, 01, 01);
        rule2.Get_Price_Book__c  = 'New';
        rule2.To_Date__c  = Date.newInstance(2022, 03, 30);
        priceBookRules.add(rule2);
        insert priceBookRules;
         
        
        
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Competency', 'Student_Competency__c','Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Student  Subscription', 'Student_Subscription__c','Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb3 = TestDataGenerator.createRecordTypesForCBLProcesses('Student  Program', 'Student_Program__c','Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb4 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity','Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = product2.Id;
        psd.Accepting_New_Students__c = true;
        insert psd;
        
          Program_Start_Date__c psd1 = TestDataGenerator.createProgramStartDate(false);
        psd1.Program__c = product2.Id;
        psd1.Accepting_New_Students__c = true;
        psd1.Start_Date__c = Date.newInstance(2019, 03, 30);
        insert psd1;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbEntryStd = TestDataGenerator.createPricebookEntry(parentProduct.id, pricebookId, 100, false,false);
        pbEntryStd.Available_for_Existing_Students__c = true;
        insert pbEntryStd;
        Pricebook2 pb = TestDataGenerator.createSubscrptPricebook('testpb', 0, 'Walden', true);
        PricebookEntry pbEntry = TestDataGenerator.createPricebookEntry(parentProduct.id, pb.id, 200, false,false);
        pbEntry.Available_for_Existing_Students__c = true;
        insert pbEntry;
 
        system.debug('pb.Subscription_Duration_in_Months__c::::::::'+pb.Subscription_Duration_in_Months__c);
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c = product2.id;
        opty.Program_Start_Date__c = psd.Id;
        insert opty;      

        Test.StartTest();
        Date sDate = Date.newInstance(1960, 2, 1);
        list<Student_Program__c> lstSprogram = new list<Student_Program__c>();
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false); 
        sProg.IsStudentProgramActive__c = true;
        sprog.Program__c = product2.ID;
        sProg.Program_Start_Date__c = psd1.id;
        lstSprogram.add(sProg);   
        Student_Program__c sProg1 = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false); 
        sProg1.IsStudentProgramActive__c = true;
        sprog1.Program__c = product2.ID;
        sProg.Program_Start_Date__c = psd1.id;

        lstSprogram.add(sProg1);  
        Student_Program__c sProg2 = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false); 
        sProg2.IsStudentProgramActive__c = true;
        sprog2.Program__c = product2.ID;
        sProg.Program_Start_Date__c = psd1.id;

        lstSprogram.add(sProg2); 
        insert lstSprogram;
        list<Student_Subscription__c> lstStudentSubscription = new list<Student_Subscription__c>();
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pb, 'Walden', false);
        stuSub.Start_Date__c = sDate;
        stuSub.Subscription_Status__c = 'RE = Registered';
        stuSub.End_Date__c = Date.today().addDays(-10);
        lstStudentSubscription.add(stuSub);     
        Student_Subscription__c stuSub1 = TestDataGenerator.createStudentSubscription(sProg2, pb, 'Walden', false);
        stuSub1.Start_Date__c = sDate;
        stuSub1.Subscription_Status__c = 'RE = Registered';
        stuSub1.End_Date__c = Date.today().addDays(10);
        lstStudentSubscription.add(stuSub1);
        Student_Subscription__c stuSub2 = TestDataGenerator.createStudentSubscription(sProg2, pb, 'Walden', false);
        stuSub2.Start_Date__c = Date.newInstance(1960, 6, 6);//Date.today().addDays(15);
        stuSub2.Subscription_Status__c = 'RE = Registered';
        stuSub2.End_Date__c = Date.today().addDays(20);
        lstStudentSubscription.add(stuSub2);
        Student_Subscription__c stuSub3 = TestDataGenerator.createStudentSubscription(sProg2, pb, 'Walden', false);
        stuSub3.Start_Date__c = sDate;
        stuSub3.Subscription_Status__c = 'RE = Registered';
        lstStudentSubscription.add(stuSub3);  
        //stuSub.Start_Date__c > sProg.Current_Student_Subscription__r.End_Date__c
        insert lstStudentSubscription;
        sProg.Current_Student_Subscription__c = stuSub.ID;
        sProg.IsStudentProgramActive__c = true;
        sProg.Leave_of_Absence_LOA_To__c = Date.today().addDays(-15);
        update sProg;
        
        sProg2.Current_Student_Subscription__c = stuSub1.ID;
        sProg2.IsStudentProgramActive__c = true;
        
        update sProg2;
        BatchAutoSubscriptionCreation objBatch = new BatchAutoSubscriptionCreation();
        ID batchprocessid = Database.executeBatch(objBatch,10);   
        Student_Program__c updatedSprog = [select IsStudentProgramActive__c, Leave_of_Absence_LOA_To__c, Current_Student_Subscription__r.Subscription_Status__c ,               
                                            Current_Student_Subscription__c , Current_Student_Subscription__r.End_Date__c, Current_Student_Subscription__r.Start_Date__c 
                                            from Student_Program__c where id =:sProg.id];
        system.debug('updatedSprog:::::::::'+updatedSprog);    
        objBatch.execute(null);
        Test.stopTest();
        updatedSProg =[select id,Leave_of_Absence_LOA_To__c, Current_Student_Subscription__c, Current_Student_Subscription__r.End_Date__c, Current_Student_Subscription__r.Start_Date__c 
                        from Student_Program__c where id =:sProg.id];
        system.debug('updatedSprog111111111111:::::::::'+updatedSprog);
        system.debug('stuSub.111111111111:::::::::'+stuSub.ID);
        //system.assert(updatedSProg.Current_Student_Subscription__r.End_Date__c >= Date.today() );
        system.assert(updatedSProg.Current_Student_Subscription__r.End_Date__c != null );
    }
    
    

}