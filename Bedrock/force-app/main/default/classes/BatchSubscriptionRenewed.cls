/************************************************************************
Name  : BatchSubscriptionRenewed
Author: Vinod (Appirio)
Date  : October 14, 2014
Task  : T-325358
Description: batch class for Subscription Renewed

Revision History 
Horacio Sanchez - 10/21/2020 - S-29566 Move Existing Pre-req functionality from AoE to PE
*************************************************************************/
global with sharing class BatchSubscriptionRenewed implements Database.Batchable<sObject>, Database.Stateful,Schedulable{	
	
	global ID studentProgramID; 
	global integer totalSuccess;
	global integer totalFailure;
	
	global void execute(SchedulableContext SC){ 
  	BatchSubscriptionRenewed objBatch = new BatchSubscriptionRenewed();
    ID batchprocessid = Database.executeBatch(objBatch,20);     
  } 
 
	/*****************************************************************************
  	* Use the start method to collect the records or objects to be passed to 
      the method execute
  	*****************************************************************************/ 
	global Database.QueryLocator start( Database.BatchableContext bc ){ 
		totalSuccess = 0;
		totalFailure = 0;
		Date yesterday = Date.today().addDays(-1);
	    String SOQL; 	   
	   	// get walden recordtype
	    string studentEnrollmentStatusCode ='EL'; 
	    string waldenRecordType = Schema.SObjectType.Student_Program__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
	    SOQL = 'SELECT ID, Name, Current_Student_Subscription__c, Program__c, IsStudentProgramActive__c, Leave_of_Absence_LOA_To__c, Leave_of_Absence_LOA_From__c, '
	    	   + ' Current_Student_Subscription__r.Subscription_Status__c,Current_Student_Subscription__r.End_Date__c, Open_Bursar_Hold__c'
	    	   + ' FROM Student_Program__c'
	    	   + ' WHERE Student_Enrollment_Status_Code__c = :studentEnrollmentStatusCode'
	    	   + ' AND RecordTypeId =: waldenRecordType'
	    	   + ' AND (Current_Student_Subscription__c = \'\''
	    	   + ' OR Current_Student_Subscription__r.End_Date__c = :yesterday)';

	    return Database.getQueryLocator( SOQL );
 	}

 	/*****************************************************************************
      excute 
   ****************************************************************************/
	global void execute( Database.BatchableContext bc, list<SObject> scope ){
		List<Student_Program__c> lstStudentProgram = (list<Student_Program__c>)scope;
        Set<Id> spIdSet = new Set<Id>();
		SubscriptionRenewer objHelper = new SubscriptionRenewer();
		objHelper.subscriptionRenew(lstStudentProgram);
        
        Set<Id> studentProgramIdSet = new Set<Id>();
        for (Student_Program__c sp : lstStudentProgram) {
            studentProgramIdSet.add(sp.Id);
        }
        
        Date yesterday = Date.today().addDays(-1);
        List<Student_Program__c> studentProgramList = new List<Student_Program__c>();
        studentProgramList = [SELECT Id, Open_Bursar_Hold__c FROM Student_Program__c 
                              WHERE Open_Bursar_Hold__c > 0
                              AND Current_Student_Subscription__r.End_Date__c = :yesterday
                              AND Id IN :studentProgramIdSet];        
        
        for (Student_Program__c sp : studentProgramList) {
            spIdSet.add(sp.id);            
        }
        objHelper.auotmateFinancialHoldLogic(spIdSet);
		totalSuccess += objHelper.totalNumberOfSuccess;
 		totalFailure += objHelper.totalNumberOfFailure;
	}

	global void finish(Database.BatchableContext BC){
		// create apex loger
 		apexLogHandler.apexLog log;
 		// create apex loger for the number of successfull and failure 		
 		if(totalSuccess > 0){
 			string strMessage = 'Total number of Successfull Subscription Renewed = ('+string.valueOf(totalSuccess)+')';
 			log = new apexLogHandler.apexLog('BatchSubscriptionRenewed','finish', strMessage);
 		}
 		if(totalFailure > 0){
 			string strMessage = 'Total number of Failure Subscription Renewed = ('+string.valueOf(totalFailure)+')';
 			log = new apexLogHandler.apexLog('BatchSubscriptionRenewed','finish', strMessage);
 		}
 		if(log != null){
 			log.saveLogs();
 		}
 		
 	} 
	
}