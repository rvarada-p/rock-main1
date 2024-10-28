/************************************************************************
Name  : BatchApplyBursarHold
Author: Sarah Khalid, Laureate
Date  : August 15, 2017
Description: batch class for Apex Rule Engine: Apply Bursar Hold


01/17/2021  :   Sufia - S-679860 
*************************************************************************/

global with sharing class BatchApplyBursarHold implements Database.Batchable<sObject>, Database.Stateful,Schedulable {

    global integer totalrecordsProcess;
    global integer totalSuccess;
    global integer totalFailure;
    
    global Database.QueryLocator start( Database.BatchableContext bc ){ 
        String SOQL;
        totalrecordsProcess = 0; 
        totalSuccess = 0;
        totalFailure = 0;
        
        string waldenRecordType = Schema.SObjectType.Student_Program__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        //S-679860
        SOQL = 'SELECT Id, Name, IsStudentProgramActive__c,Sponsor_Billing__c,Student_Sponsor_Name__r.Name '
            + ' FROM Student_Program__c'  
            + ' WHERE RecordTypeId =: waldenRecordType'
            + ' AND Open_Bursar_Hold__c = 0'
            + ' AND Open_BK_Hold__c = 0' 
            + ' AND Open_C2_Hold__c = 0'
            + ' AND Outstanding_Balance_Minus_Future__c >=1000'
            + ' AND Oldest_Debt_Age__c>18';
        
        return Database.getQueryLocator( SOQL );
    }
    
    global void execute(SchedulableContext SC){ 
        BatchApplyBursarHold objBatch = new BatchApplyBursarHold();
        ID batchprocessid = Database.executeBatch(objBatch,20);         
    }
    
    
    global void execute( Database.BatchableContext bc, list<SObject> scope ){
        list<Student_Program__c> lstStudentProgram = (list<Student_Program__c>)scope;
        totalrecordsProcess+= lstStudentProgram.size();
        BursarHoldHelper objHelper = new BursarHoldHelper();
        objHelper.applyBusarHolds(lstStudentProgram);
        totalSuccess += objHelper.totalNumberOfSuccess;
        totalFailure += objHelper.totalNumberOfFailure;
    }
    
    global void finish(Database.BatchableContext BC){
        // create apex loger
        apexLogHandler.apexLog log;
        // create apex loger for the number of successfull and failure
        string strMessage;
        if(totalSuccess > 0){
            strMessage = 'Total number of Success in Applying Bursar Holds = ('+string.valueOf(totalSuccess)+')';
            log = new apexLogHandler.apexLog('BatchStudentRetention','finish', strMessage);
        }
        if(totalFailure > 0){
            strMessage = 'Total number of Failure in Applying Bursar Holds = ('+string.valueOf(totalFailure)+')';
            log = new apexLogHandler.apexLog('BatchStudentRetention','finish', strMessage);
        }
        if(totalrecordsProcess > 0){
            strMessage = 'Number records processed = ('+string.valueOf(totalrecordsProcess)+')';
            log = new apexLogHandler.apexLog('BatchStudentRetention','finish', strMessage);
        }
        if(log != null){
            log.saveLogs();
        }       
    }
                    
}