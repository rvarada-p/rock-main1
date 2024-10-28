global with sharing class BatchApplyDocumentHold implements Database.Batchable<sObject>, Database.Stateful,Schedulable {

    global integer totalrecordsProcess;
    global integer totalSuccess;
    global integer totalFailure;
  
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        String SOQL;
        totalrecordsProcess = 0; 
        totalSuccess = 0;
        totalFailure = 0;
      
        string waldenRecordType = Schema.SObjectType.Student_Program__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        SOQL = 'SELECT Name'
                + ' FROM Student_Program__c'  
                + ' WHERE RecordTypeId =: waldenRecordType'
                + ' AND Open_Document_Hold__c = 0'
            	+ ' AND Open_C2_Hold__c = 0'
            	+ ' AND Open_BK_Hold__c = 0' 
                + ' AND Outstanding_Balance_Minus_Future__c > 0';
      
        return Database.getQueryLocator(SOQL);
    } 
    
    global void execute(SchedulableContext SC) { 
        BatchApplyDocumentHold objBatch = new BatchApplyDocumentHold(); 
        ID batchprocessid = Database.executeBatch(objBatch, 20);
    }
  
  
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Student_Program__c> lstStudentProgram = (List<Student_Program__c>)scope;
        totalrecordsProcess += lstStudentProgram.size();
        DocumentHoldHelper objHelper = new DocumentHoldHelper();
        objHelper.applyDocumentHolds(lstStudentProgram);
        totalSuccess += objHelper.totalNumberOfSuccess;
        totalFailure += objHelper.totalNumberOfFailure;
    }
  
    global void finish(Database.BatchableContext BC) {
        
        // create apex loger
        ApexLogHandler.ApexLog log;
        
        // create apex loger for the number of successfull and failure
        String strMessage;
        
        if (totalSuccess > 0) {
            strMessage = 'Total number of Success in Applying Document Holds = ('+string.valueOf(totalSuccess)+')';
            log = new ApexLogHandler.ApexLog('BatchApplyDocumentHold','finish', strMessage);
        }
        if (totalFailure > 0) {
            strMessage = 'Total number of Failure in Applying Document Holds = ('+string.valueOf(totalFailure)+')';
            log = new ApexLogHandler.ApexLog('BatchApplyDocumentHold','finish', strMessage);
        }
        if (totalrecordsProcess > 0) {
            strMessage = 'Number records processed = ('+string.valueOf(totalrecordsProcess)+')';
            log = new ApexLogHandler.ApexLog('BatchApplyDocumentHold','finish', strMessage);
        }
        if (log != null) {
            log.saveLogs();
        }     
    }
              
}