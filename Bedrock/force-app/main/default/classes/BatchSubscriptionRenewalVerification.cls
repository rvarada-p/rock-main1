/************************************************************************
Name  : BatchSubscriptionRenewalVerification
Author: Vinod (Appirio)
Date  : October 13, 2014
Task  : T-314515 
Description: batch class for Apex Rule Engine: Subscription Renewal Verification
*************************************************************************/
global with sharing class BatchSubscriptionRenewalVerification implements Database.Batchable<sObject>, Database.Stateful,Schedulable{
	
  global integer totalreordsProcess;
	global integer totalGoodStanding;
  global integer totalRenewalDeniles; 
  global integer totalSuccess;
 	global integer totalFailure;
	global ID studentProgramID;  

	global Database.QueryLocator start( Database.BatchableContext bc ){ 
    String SOQL; 
    totalreordsProcess = 0;
		totalGoodStanding = 0;
    totalRenewalDeniles  = 0;  
    totalSuccess = 0;
	 	totalFailure = 0;
    Date toDay = Date.today();
    // date four day ago	     
    Date fourDayAgoDate = toDay.addDays(-4); // most recent subscription started at least 4 days ago
    // get walden recordtype , 
    string wladenRecordType = Schema.SObjectType.Student_Program__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
    SOQL = 'SELECT Name, Renewal_Denied__c,Credits_Brought_into_Program__c, Renewal_Denied_Comment__c, Number_of_Enrolled_Terms__c,Competencies_Completed_in_Trial__c,' 
    		+ 'Number_of_Competencies_Completed__c, IsStudentProgramActive__c, Id, CurrentSubscriptionStartDate__c, CurrentSubscriptionEndDate__c,'
    		+ 'Current_Student_Subscription__c, Application__c, Number_of_Competencies_Transferred__c,Program__c,'
    		+ 'Number_of_Competencies__c,Application__r.Admissions_Contingency__c,'
    		+ 'Total_attempted_credits__c, Number_Credits_Completed_in_all_Terms__c,Program__r.Degree_Level__c,'
    		+ 'Number_of_Credits_Completed_in_Trial__c,Number_of_Credits_TransferredFulfilled__c,SAP_Code__c, Previous_SAP_Code__c,'
    		+ 'Current_Student_Subscription__r.Agreed_To_Credits__c,LOA_Gap_Months__c,UG_GR_Transferred_Fulfilled_CE__c, '
   			+ 'Current_Student_Subscription__r.Number_of_Credits_Completed__c,First_Start_Date__c, Modality_Switcher_chk__c, SAP_Date__c '
        + ' FROM Student_Program__c'  
        + ' WHERE IsStudentProgramActive__c = true'
//            + ' AND CurrentSubscriptionStartDate__c < : toDay'
//	    	  + ' AND CurrentSubscriptionStartDate__c >=: fourDayAgoDate'
        + ' AND RecordTypeId =: wladenRecordType   AND id = \'a0R8D0000005wnoUAA\'';

	    return Database.getQueryLocator( SOQL );
 	}
  
  global void execute(SchedulableContext SC){ 
    BatchSubscriptionRenewalVerification objBatch = new BatchSubscriptionRenewalVerification();
    ID batchprocessid = Database.executeBatch(objBatch,20);     
  }
	global void execute( Database.BatchableContext bc, list<SObject> scope ){
		list<Student_Program__c> lstStudentProgram = (list<Student_Program__c>)scope;
		totalreordsProcess+= lstStudentProgram.size();
    SubscriptionRenewalVerificationHelper objHelper = new SubscriptionRenewalVerificationHelper();
		objHelper.SubscriptionRenewalVerification(lstStudentProgram);
		totalSuccess += objHelper.totalNumberOfSuccess;
 		totalFailure += objHelper.totalNumberOfFailure;
 		totalRenewalDeniles  += objHelper.totalNumberOfRenewalDeniles;
 	}

 	global void finish(Database.BatchableContext BC){
 		// create apex loger
 		apexLogHandler.apexLog log;
 		// create apex loger for the number of successfull and failure
 		string strMessage;
 		if(totalSuccess > 0){
 			strMessage = 'Total number of Success in Subscription Renewal Verification = ('+string.valueOf(totalSuccess)+')';
 			log = new apexLogHandler.apexLog('BatchSubscriptionRenewalVerification','finish', strMessage);
 		}
 		if(totalFailure > 0){
 			strMessage = 'Total number of Failure in Subscription Renewal Verification = ('+string.valueOf(totalFailure)+')';
 			log = new apexLogHandler.apexLog('BatchSubscriptionRenewalVerification','finish', strMessage);
 		}
 		if(totalreordsProcess > 0){
 			strMessage = 'Number records processed = ('+string.valueOf(totalreordsProcess)+')';
 			log = new apexLogHandler.apexLog('BatchSubscriptionRenewalVerification','finish', strMessage);
 		}
 		if(totalRenewalDeniles > 0){
 			strMessage = 'Number of renewal deniles = ('+string.valueOf(totalRenewalDeniles)+')';
 			log = new apexLogHandler.apexLog('BatchSubscriptionRenewalVerification','finish', strMessage);
 		}
 		if(log != null){
 			log.saveLogs();
 		}
 	}   
}