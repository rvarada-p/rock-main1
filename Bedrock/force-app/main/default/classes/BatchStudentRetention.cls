/************************************************************************
Name  : BatchStudentRetention
Author: Sarah Khalid, Laureate
Date  : May 30, 2017
Description: batch class for Apex Rule Engine: Student Retention
*************************************************************************/

global with sharing class BatchStudentRetention implements Database.Batchable<sObject>, Database.Stateful,Schedulable {

	global integer totalrecordsProcess;
	global integer totalSuccess;
 	global integer totalFailure;
	
    global Database.QueryLocator start( Database.BatchableContext bc ){ 
    	String SOQL;
    	totalrecordsProcess = 0;
    	totalSuccess = 0;
    	totalFailure = 0;
    	
	    string wladenRecordType = Schema.SObjectType.Student_Program__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
	    SOQL = 'SELECT Name, IsStudentProgramActive__c '
	        + ' FROM Student_Program__c'  
	        + ' WHERE RecordTypeId =: wladenRecordType';
    	
    	return Database.getQueryLocator( SOQL );
    }
	global void execute(SchedulableContext SC){ 
	    BatchStudentRetention objBatch = new BatchStudentRetention(); 
	    ID batchprocessid = Database.executeBatch(objBatch,20); 		
	}
	
	global void execute( Database.BatchableContext bc, list<SObject> scope ){
		list<Student_Program__c> lstStudentProgram = (list<Student_Program__c>)scope;
		totalrecordsProcess+= lstStudentProgram.size();
    	StudentRetentionHelper objHelper = new StudentRetentionHelper();
		objHelper.StudentRetentionHelper(lstStudentProgram);
		totalSuccess += objHelper.totalNumberOfSuccess;
 		totalFailure += objHelper.totalNumberOfFailure;
	}
	
 	global void finish(Database.BatchableContext BC){
 		// create apex loger
 		apexLogHandler.apexLog log;
 		// create apex loger for the number of successfull and failure
 		string strMessage;
 		if(totalSuccess > 0){
 			strMessage = 'Total number of Success in Student Retention = ('+string.valueOf(totalSuccess)+')';
 			log = new apexLogHandler.apexLog('BatchStudentRetention','finish', strMessage);
 		}
 		if(totalFailure > 0){
 			strMessage = 'Total number of Failure in Student Retention = ('+string.valueOf(totalFailure)+')';
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