/************************************************************************
Name  : BatchSendInvoice
Author: Sarah Khalid (Laureate)
Date  : March 1, 2016
Description: batch scheduled class for emailing out student invoices 
*************************************************************************/


global with sharing class BatchSendInvoice implements Database.Batchable<sObject>, Database.Stateful,Schedulable {

	global integer totalSuccess;
	global integer totalFailure;

	
	global void execute(SchedulableContext SC){ 
	  	BatchSendInvoice objBatch = new BatchSendInvoice();
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
	   	// get walden recordtype 
	    string wladenRecordType = Schema.SObjectType.Student_Subscription__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
	    SOQL = 'SELECT ID,Name, Student_Program__c, Student_Program__r.Student_s_Walden_Email_Address__c, Student_Program__r.Student_Primary_Email__c, Student_ID__c  '
	    	   + ' FROM Student_Subscription__c '
	    	   + ' WHERE RecordTypeId =: wladenRecordType'
	    	   + ' AND Invoice_Sent__c = false '
	    	   + ' AND Student_Program__r.Student_s_Walden_Email_Address__c <> \'\'';
	    return Database.getQueryLocator( SOQL );
 	}	
 	
 	/*****************************************************************************
      excute 
   ****************************************************************************/
	global void execute( Database.BatchableContext bc, list<SObject> scope ){
		List<Student_Subscription__c> lstSubscriptions =  (List<Student_Subscription__c>) scope;
		SendInvoice helper = new SendInvoice();
		helper.sendInvoices(lstSubscriptions);
		totalSuccess += helper.totalNumberOfSuccess;
 		totalFailure += helper.totalNumberOfFailure;
		
	}

	global void finish(Database.BatchableContext BC){
		// create apex loger
 		apexLogHandler.apexLog log;
 		// create apex loger for the number of successfull and failure 	
 		if(!Test.isRunningTest()) {	
	 		if(totalSuccess > 0){
	 			string strMessage = 'Total number of Successfull Invoices Sent = ('+string.valueOf(totalSuccess)+')';
	 			log = new apexLogHandler.apexLog('BatchSendInvoice','finish', strMessage);
	 		}
	 		if(totalFailure > 0){
	 			string strMessage = 'Total number of Invoice Sent Failures = ('+string.valueOf(totalFailure)+')';
	 			log = new apexLogHandler.apexLog('BatchSendInvoice','finish', strMessage);
	 		}
	 		if(log != null){
	 			log.saveLogs();
	 		}
 		}
 	}  	
}