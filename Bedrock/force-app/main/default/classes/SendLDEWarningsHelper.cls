/************************************************************************
Name  : SendLDEWarningsHelper
Author: Sarah Khalid (Laureate)
Date  : March 16, 2016
Description: worker class for batch class BatchSendLDEWarnings
Test class: SendLDEWarnings_Test
*************************************************************************/


public with sharing class SendLDEWarningsHelper {
  public  integer totalNumberOfSuccess;
  public  integer totalNumberOfFailure;
 
    public void sendWarnings(list<Student_Program__c> lstStudentPrograms, list<String> toaddresses) {

		apexLogHandler.apexLog log;
	    totalNumberOfSuccess = 0;
	    totalNumberOfFailure = 0;
		
		List<Student_Program__c> lst30days = new List<Student_Program__c>();
		
		//Loop through the Student Program records and figure out what warning category they fit into
		for(Student_Program__c sp : lstStudentPrograms) {
			 if(sp.Days_Since_LDE__c >= 31) {
				lst30days.add(sp);
			}
		}
		
		if(lst30days.size()>0)
			sendFinalWarning(lst30days, toaddresses);
							 
    }
    
  
    
    //If "Days Since LDE" = 30, notify Academic Coach with an action email that includes the list of students who have not engaged for more than 30 days.
    public void sendFinalWarning(List<Student_Program__c> lst30days, list<string> toaddresses) {
 	List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
  	
 	  	for(Student_Program__c s: lst30days) {
	  		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	  		//String[] toAddresses = new String[] { s.CoachEmail__c };
	  		mail.setToAddresses(toaddresses);
	  		mail.setWhatId(s.Id);
	  		mail.setTemplateId([select id from EmailTemplate where DeveloperName = 'X30_Days_Notification_Action_Needed_for_Coaches_Related_to_Student_Engagement'].id);  		
	  		mail.setTargetObjectId(s.Student__r.Id); 
	  		mail.setSaveAsActivity(false);
	  		mails.add(mail);
	  	}

	  	// Send the emails in a transaction, then roll it back
	  	Savepoint sp = Database.setSavepoint();
	  	Messaging.sendEmail(mails);
	  	Database.rollback(sp);
	  	
	  	// For each SingleEmailMessage that was just populated by the sendEmail() method, copy its contents to a new SingleEmailMessage. Then send those new messages.
	  	List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
	  	for (Messaging.SingleEmailMessage email : mails) {
	  		Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
	  		emailToSend.setToAddresses(email.getToAddresses());
	  		emailToSend.setPlainTextBody(email.getPlainTextBody());
	  		emailToSend.setHTMLBody(email.getHTMLBody());
	  		emailToSend.setSubject(email.getSubject());
	  		lstMsgsToSend.add(emailToSend); 
	  	}
	  	
	  	if(lstMsgsToSend.size()>0) {
	  		if(!Test.isRunningTest()) {
	  			Messaging.SendEmailResult [] r = Messaging.sendEmail(lstMsgsToSend);
	  			for(Messaging.SendEmailResult rr:r){
	  				if(rr.IsSuccess()) 
	  					totalNumberOfSuccess++;
	  				else
	  					totalNumberOfFailure++;
	  			}
	  		}
	  	}  
    	    	
    }
}