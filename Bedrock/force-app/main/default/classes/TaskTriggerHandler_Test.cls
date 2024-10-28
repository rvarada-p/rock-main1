/*******************************************************************
Name  : TaskTriggerHandler_Test  
Author: Tom (Appirio)
Date  : Jan, 2015
Description: Test Class for the  class TaskTriggerHandler and trigger TaskTrigger
*************************************************************************/
@isTest
private class TaskTriggerHandler_Test {
    /*
    Test method to test function assignRRTask
    */

    static testMethod void testAssignRRTask() {
      
        // create test data
        Group newGroup = new Group();
        newGroup.Name = 'Walden Registrar';
        newGroup.DoesIncludeBosses = false; 
        insert newGroup;
        string strRandom = string.valueOf( Math.random());
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User u1 = new User(Alias = 'standt', Email='standarduser'+strRandom+'@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='yyyywwwwwqq'+strRandom+'@testorg.com');

        string userID = system.Userinfo.getUserId();
        insert u1;

        strRandom = string.valueOf( Math.random());
        User u2 = new User(Alias = 'user02', Email='standarduser2'+strRandom+'@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='yyyywwwwwqq'+strRandom+'@testorg.com');
        insert u2;

        system.runAs(u1){
          GroupMember newMember=new GroupMember();
          newMember.GroupId = newGroup.ID;
          newMember.UserOrGroupId = userID;
          insert newMember;
          
          Account testAcc = new Account(Name = 'testtest');
          insert testAcc;
          Contact testCon = new Contact(LastName = 'testcon', Account = testAcc);
          insert testCon;

          Round_Robin_Queue__c newTaskQueue = new Round_Robin_Queue__c();
          newTaskQueue.Institution__c = TestDataGenerator.createInstitution('Walden', true).Id;
          newTaskQueue.Queue_Position__c = 1.0;
          newTaskQueue.Name ='Walden Registrar';
          insert newTaskQueue;
          Id newTaskQueueID = newTaskQueue.id;

          Task newTask = new Task();
          newTask.Subject = 'Send Letter';
          newTask.Status = 'In Progress';
          newTask.Priority = 'Normal';
          newTask.Assign_Round_Robin_Queue__c = newTaskQueueID;
          newTask.OwnerId = u2.Id;
          newTask.WhoId = testCon.Id;

          try{
              insert newTask;
          }
          catch(exception ex){
              system.debug( ex.getMessage() );
          } 
        }
        
    }

    static testmethod void testTaskL1Sync() {
  
       
        Script_Settings__c settings = new Script_Settings__c();
        settings.name = 'Current Settings';
        settings.Coach_Assignment_Limit__c = 100;
        insert settings;
        
        
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c','Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity','Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = product2.Id;
        psd.Start_Date__c = TestDataGenerator.getFirstMondayOfMonth(Date.today()+31);
        psd.Accepting_New_Students__c = true;
        insert psd;    
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, 'Walden', false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c =product2.id;   
        opty.Program_Start_Date__c = psd.Id;    
        opty.LeadSource = 'L1 Transfer';
        opty.Contact__c = testCon.Id;
        insert opty;
        Student_Program__c sp1 = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false);
        sp1.Next_SAP_Date__c = system.today();
        insert sp1;
        
        opty.StageName = 'Student';
        opty.Student_Program__c = sp1.id;
        update opty;

        string strRandom = string.valueOf( Math.random());
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User u1 = new User(Alias = 'standt', Email='standarduser'+strRandom+'@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='yyyywwwwwqq'+strRandom+'@testorg.com');

        string userID = system.Userinfo.getUserId();
        insert u1;
        
        Task newTask = new Task();
        newTask.Subject = 'Send Letter';
        newTask.Status = 'In Progress';
        newTask.OwnerId = u1.Id;
        newTask.WhoId = testCon.Id;      
        newTask.WhatId = sp1.Id;
        insert newTask;

        System.assertEquals(newTask.Sync_with_L1__c, false);
    }
  
}