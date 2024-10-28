/************************************************************************
Name  : BatchApplyBursarHolds
Author: Sarah Khalid (Laureate)
Date  : March 16, 2016
Description: batch scheduled class for automatically sending notifications
			 to the academic coach if Days Since LDE is 18, 25 and/or 30 
Test class: SendLDEWarnings_Test
*************************************************************************/

global with sharing class BatchSendLDEWarnings  implements Database.Batchable<sObject>, Database.Stateful,Schedulable {

	global integer totalSuccess;
	global integer totalFailure;
	global list<string> groupemails;
	
	/*****************************************************************************
  	* Use the start method to collect the records or objects to be passed to 
      the method execute
  	*****************************************************************************/ 
	global Database.QueryLocator start( Database.BatchableContext bc ) {  
		totalSuccess = 0;
		totalFailure = 0;
 		groupemails = new list<String>();
 		
  	    String SOQL; 	   
	   	// get walden recordtype 
	    string waldenRecordType = Schema.SObjectType.Student_Program__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
	    system.debug('Walden Record Type ' + waldenRecordType);
	    SOQL = 'SELECT ID,Name, Days_Since_LDE__c, CoachEmail__c, Student__r.Id, Coach__r.Id  '
	    	   + ' FROM Student_Program__c ' 
	    	   + ' WHERE RecordTypeId =: waldenRecordType '
	    	   + ' AND Days_Since_LDE__c = 31';
	    System.debug('SOQL ' + SOQL);
	    return Database.getQueryLocator( SOQL );
 	}	

	global void execute(SchedulableContext SC){  
	  	BatchSendLDEWarnings objBatch = new BatchSendLDEWarnings(); 
	    ID batchprocessid = Database.executeBatch(objBatch,20);     
	} 
 	
 	/*****************************************************************************
      excute 
   ****************************************************************************/
	global void execute( Database.BatchableContext bc, list<SObject> scope ){
		System.debug('In Execute method');
		List<Student_Program__c> lstStudentPrograms =  (List<Student_Program__c>) scope;
		
		//Populate the emails for the coach public group 
		List<String> idList = new List<String>();
		Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE DeveloperName = 'Walden_Coach'];
		for (GroupMember gm : g.groupMembers) {
			idList.add(gm.userOrGroupId); 
			User[] usr = [SELECT email FROM user WHERE id IN :idList];
			for(User u : usr) {
				groupemails.add(u.email);
			}
		} 
		System.debug('GROUP EMAIL ' + groupemails);

 
		SendLDEWarningsHelper objHelper = new SendLDEWarningsHelper();
		objHelper.sendWarnings(lstStudentPrograms, groupemails); 
		totalSuccess += objHelper.totalNumberOfSuccess;
 		totalFailure += objHelper.totalNumberOfFailure;
		
	}

	global void finish(Database.BatchableContext BC){
		// create apex loger
 		apexLogHandler.apexLog log;
 		// create apex loger for the number of successfull and failure 	
	
	 		if(totalSuccess > 0){
	 			string strMessage = 'Total number of Successfull LDE Warnings Sent = ('+string.valueOf(totalSuccess)+')';
	 			log = new apexLogHandler.apexLog('BatchSendLDEWarnings','finish', strMessage);
	 		}
	 		if(totalFailure > 0){
	 			string strMessage = 'Total number of LDE Warning Failures = ('+string.valueOf(totalFailure)+')';
	 			log = new apexLogHandler.apexLog('BatchSendLDEWarnings','finish', strMessage);
	 		}
	 		if(log != null){
	 			log.saveLogs();
	 		}
 		
 	}  		        
}