/************************************************************************ 
Name  : BatchRemoveBursarHold
Author: Sarah Khalid, Laureate
Date  : August 15, 2017
Description: batch class for Apex Rule Engine: Remove Bursar Hold
*************************************************************************/

global with sharing class BatchRemoveBursarHold  implements Database.Batchable<sObject>, Database.Stateful,Schedulable {

    global integer totalrecordsProcess;
    global integer totalSuccess;
    global integer totalFailure;
    global String SOQL;
    
    global Database.QueryLocator start( Database.BatchableContext bc ){ 
        
        totalrecordsProcess = 0;
        totalSuccess = 0;
        totalFailure = 0;
        
        string waldenRecordType = Schema.SObjectType.Student_Program__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        SOQL = 'SELECT Name, IsStudentProgramActive__c '
            + ' FROM Student_Program__c'  
            + ' WHERE RecordTypeId =: waldenRecordType'
            + ' AND Open_Bursar_Hold__c >= 1'
            + ' AND (Outstanding_Balance_Minus_Future__c <1000 OR Oldest_Debt_Age__c < 18)';
        
        return Database.getQueryLocator( SOQL );
    }

    global void execute(SchedulableContext SC){ 
        BatchRemoveBursarHold objBatch = new BatchRemoveBursarHold(); 
        ID batchprocessid = Database.executeBatch(objBatch,20);     
    } 
    
    global void execute( Database.BatchableContext bc, list<SObject> scope ){
        list<Student_Program__c> lstStudentProgram = (list<Student_Program__c>)scope;
        totalrecordsProcess+= lstStudentProgram.size();
        BursarHoldHelper objHelper = new BursarHoldHelper();
        objHelper.removeBursarHolds(lstStudentProgram);
        totalSuccess += objHelper.totalNumberOfSuccess;
        totalFailure += objHelper.totalNumberOfFailure;
    }
    
    global void finish(Database.BatchableContext BC){
        // create apex loger
        apexLogHandler.apexLog log;
        // create apex loger for the number of successfull and failure
        string strMessage;
        if(totalSuccess > 0){
            strMessage = 'Total number of Success in Removing Bursar Holds = ('+string.valueOf(totalSuccess)+')';
            log = new apexLogHandler.apexLog('BatchRemoveBursarHold','finish', strMessage);
        }
        if(totalFailure > 0){
            strMessage = 'Total number of Failure in Removing Bursar Holds = ('+string.valueOf(totalFailure)+')';
            log = new apexLogHandler.apexLog('BatchRemoveBursarHold','finish', strMessage);
        }
        if(totalrecordsProcess > 0){
            strMessage = 'Number records processed = ('+string.valueOf(totalrecordsProcess)+')';
            log = new apexLogHandler.apexLog('BatchRemoveBursarHold','finish', strMessage);
        }
        if(log != null){
            log.saveLogs();
        }       
    }
    
}