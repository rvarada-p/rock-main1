/************************************************************************
Name  : SendInvoice
Author: Sarah Khalid (Laureate)
Date  : March 1, 2016
Description: worker class for batch class BatchSendInvoice
Test class: BatchSendInvoice_Test
*************************************************************************/

public with sharing class SendInvoice {
  public  integer totalNumberOfSuccess;
  public  integer totalNumberOfFailure;
  public  integer totalUpdated;
  
  public SendInvoice(){
  }
	
  //This method sends out the invoice emails to students and also updates the Subscription to mark that the invoice has been sent
  //This method logs the output of successes and failures to apex logger	
  public void sendInvoices(list<Student_Subscription__c> lstSubscriptions) {

    totalNumberOfSuccess = 0;
    totalNumberOfFailure = 0;
    totalUpdated = 0;


  	List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
  	
  	//mail.setTemplateId(templates[0].Id);
  	
  	for(Student_Subscription__c s: lstSubscriptions) {
  		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
  		String[] toAddresses = new String[] { s.Student_Program__r.Student_s_Walden_Email_Address__c, s.Student_Program__r.Student_Primary_Email__c };
  		mail.setToAddresses(toAddresses);
  		mail.setReplyTo('cblbilling@waldenu.edu');
  		mail.setSenderDisplayName('Invoice emails');
  		mail.setWhatId(s.Id);
  		mail.setTemplateId([select id from EmailTemplate where DeveloperName = 'Invoice_Email_Walden'].id);  		
  		mail.setTargetObjectId(s.Student_ID__c); 
  		mail.setSaveAsActivity(false);
  		mails.add(mail);
  		s.Invoice_Sent__c = true; 
  		//System.debug('Walden Email Address ' + s.Student_Program__r.Student_s_Walden_Email_Address__c);
  	}
  	if(mails.size()>0) {
  		if(!Test.isRunningTest()) {
  			Messaging.SendEmailResult [] r = Messaging.sendEmail(mails);
  			for(Messaging.SendEmailResult rr:r){
  				if(rr.IsSuccess())
  					totalNumberOfSuccess++;
  				else
  					totalNumberOfFailure++;
  			}
  		}
  	} 
  	if(lstSubscriptions.size()>0) {
  		update lstSubscriptions; 
  		totalUpdated = lstSubscriptions.size();
  	}
  }
     
}