/************************************************************************
Name  : BatchAutoSubscriptionCreation
Author: Vinod (Appirio) 
Date  : October 14, 2014
Related Task: T-325099
Description: batch class for AutoS ubscription Creation
Test class: SubscriptionAutoCreator_Test
*************************************************************************/
global with sharing class BatchAutoSubscriptionCreation implements Database.Batchable<sObject>, Database.Stateful,Schedulable{

    global integer totalSuccess;
    global integer totalFailure;
    global void execute(SchedulableContext SC){ 
    BatchAutoSubscriptionCreation objBatch = new BatchAutoSubscriptionCreation();
    ID batchprocessid = Database.executeBatch(objBatch,20);    
  } 
    
    /*****************************************************************************
    * Use the start method to collect the records or objects to be passed to 
      the method execute
    *****************************************************************************/ 
    global Database.QueryLocator start( Database.BatchableContext bc ){ 
        totalSuccess = 0;
        totalFailure = 0;

    String SOQL; 
    Date dtNextThirtyFiveDayDate = Date.today().addDays(35);       
  
    
    // get walden recordtype
    string currentStudentSubscriptionStatus ='RE = Registered';
    string wladenRecordType = Schema.SObjectType.Student_Program__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
    SOQL = 'Select ID,Name, Current_Student_Subscription__c,Program__c,Program_Start_Date__r.Start_Date__c, '
            + 'Current_Student_Subscription__r.Subscription_Status__c,Current_Student_Subscription__r.End_Date__c, Parent_Program__c, '
            + 'Current_Student_Subscription__r.Term_Price_Book__c, Leave_of_Absence_LOA_From__c, Leave_of_Absence_LOA_To__c'
            + ' FROM Student_Program__c '
              + ' WHERE IsStudentProgramActive__c = true'
              + ' AND Current_Student_Subscription__r.Subscription_Status__c = :currentStudentSubscriptionStatus'
            + ' AND RecordTypeId =: wladenRecordType'
            + ' AND Current_Student_Subscription__c != null'
            + ' AND Open_Bursar_Hold__c = 0 AND Open_Contingency_Hold__c  = 0 AND Open_BK_Hold__c = 0 AND Open_C2_Hold__c = 0'
            + ' AND Current_Student_Subscription__r.End_Date__c < :dtNextThirtyFiveDayDate';
       System.debug('SOQL : ' + SOQL);
            
       return Database.getQueryLocator( SOQL );
    }

    /*****************************************************************************
      excute 
    ****************************************************************************/
    global void execute( Database.BatchableContext bc, list<SObject> scope ){
        system.debug('Scope'+Scope);
        system.debug('Scope'+Scope.size());

        list<Student_Program__c> lstStudentProgram = (list<Student_Program__c>)scope;
        SubscriptionAutoCreator objHelper = new SubscriptionAutoCreator();
        objHelper.createSubscription(lstStudentProgram);
        totalSuccess += objHelper.totalNumberOfSuccess; 
        totalFailure += objHelper.totalNumberOfFailure; 
    }

    global void finish(Database.BatchableContext BC){       
        // create apex loger
        apexLogHandler.apexLog log;
        // create apex loger for the number of successfull and failure
        system.debug('totalFailure:::::::::::::'+totalFailure);
        system.debug('totalFailure:::::::::::::'+totalFailure);
        if(totalSuccess > 0){
            string strMessage = 'Total number of auto Student Subscriptions created = ('+string.valueOf(totalSuccess)+')';
            log = new apexLogHandler.apexLog('BatchAutoSubscriptionCreation','finish', strMessage);
        }
        if(totalFailure > 0){
            string strMessage = 'Total number of auto Student Subscriptions failed = ('+string.valueOf(totalFailure)+')';
            log = new apexLogHandler.apexLog('BatchAutoSubscriptionCreation','finish', strMessage);
        }
        if(log != null){
            log.saveLogs();
        } 

    } 


}