/*******************************************************************
Name  : SendSubInvoiceController
Author: Tom (Appirio)
Date  : Feb 18, 2015
Description: Controller for button on Student Subscription for Invoice emailing
Sufia : 07/20/2021 : - S-685961 : update to use util code and remove code repetition
Sufia - 09/24/2021 - I-423645
*************************************************************************/ 
public with sharing class SendSubInvoiceController {

  private Student_Subscription__c stuSub {get;set;}
  public EmailTemplate sendTemplate {get;set;}
  public Boolean isMainEmail {get;set;}
  public Boolean isWaldenEmail {get;set;}

  public SendSubInvoiceController(ApexPages.StandardController stdController) {
    stuSub = (Student_Subscription__c)stdController.getRecord();
    stuSub = [SELECT Id, Write_Off__c, Total_Grant_special_refund_to_student__c,Days_Past_Due__c, Student_Program__c,Student_Program__r.Sponsor_Billing__c, Student_Program__r.Learner_Outcome__c,Student_Program__r.Student__c, Student_Program__r.Student__r.Email, Student_Program__r.Student__r.Walden_Email__c
              FROM Student_Subscription__c WHERE Id = :stuSub.Id ];
 
    if(!stuSub.Write_Off__c){
    if((stuSub.Student_Program__r.Learner_Outcome__c == 0 && stuSub.Student_Program__r.Sponsor_Billing__c!=true) || (stuSub.Student_Program__r.Learner_Outcome__c != 0 && stuSub.Days_Past_Due__c >0 && stuSub.Student_Program__r.Sponsor_Billing__c!=true)) {       
        sendTemplate = setSendTemplate();
        isMainEmail = true;
        isWaldenEmail = stuSub.Student_Program__r.Student__r.Walden_Email__c!=null ? true : false;
    }
    
    else if (stuSub.Student_Program__r.Sponsor_Billing__c==true && stuSub.Days_Past_Due__c>60)    {
        sendTemplate = setSendTemplate();
        isMainEmail = true;
        isWaldenEmail = stuSub.Student_Program__r.Student__r.Walden_Email__c!=null ? true : false;      
    }
    else if(stuSub.Student_Program__r.Learner_Outcome__c !=0 && stuSub.Days_Past_Due__c <=0) {
        ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.FATAL
            ,'Student is pending Graduation. Future billing suppressed.'
            ));     
    }
    }else  {
        ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.FATAL
            ,'Write Off should be false'
            ));     
    }   
  }

  public EmailTemplate setSendTemplate() {
    try {
      return [SELECT Id,DeveloperName,HtmlValue FROM EmailTemplate 
              WHERE DeveloperName = 'Invoice_Email_Walden' LIMIT 1];
    } catch (Exception ex) {
      ApexPages.addMessage(new ApexPages.Message(
        ApexPages.Severity.FATAL
        ,'No email template was found for sending student invoices. '
        +'Please contact your manager or system administrator.'
        ));
      return null;
    }

  }

  public void sendEmail() {
    List<SendEmail.InvokeSendEmail> lstEmailRequests = new List<SendEmail.InvokeSendEmail>();  
    SendEmail.InvokeSendEmail request = new SendEmail.InvokeSendEmail();
    request.ContactOrLeadID = stuSub.Student_Program__r.Student__c;
    request.EmailTemplateName=sendTemplate.DeveloperName;
    request.RelatedToId= stuSub.Id;
    request.OrgWideEmailAddress='cblbilling@waldenu.edu';
    request.ToAddresses = String.join(new List<String>{ stuSub.Student_Program__r.Student__r.Email },',');  
    if(isWaldenEmail) {
        request.CcAddresses = String.join(new List<String>{ stuSub.Student_Program__r.Student__r.Walden_Email__c },',');
    }
   
    // bcc-ing our custom email service which Email Alerts for Workflow also implement
    // dev1 org
    //request.BccAddresses = String.join(new List<String>{'walden@e-19h3ikgsr1ntp2xmfrric3ukt7w23lju4ax4d89guz082jjbzy.17-8uumeai.cs22.apex.sandbox.salesforce.com'},',');  
    
    // qa1 org
    //request.BccAddresses = String.join(new List<String>{'inboundsubscriptionemail@p9ta9h2osncb5qz87mk29izdx8qy1vpym9lzmuh4gqrgx6ciw.q-arvreaw.cs21.apex.sandbox.salesforce.com'},',');  
    
    // test org (stage full)
    //request.BccAddresses = String.join(new List<String>{'waldencblsubscriptionemail@n-1uitqqa3gkm28ioibpx5ep466igzrpy8ir0ny72sgie79sztc.q-anafeac.cs21.apex.sandbox.salesforce.com'},',');  
    
    // prod org 
    request.BccAddresses = String.join(new List<String>{'waldencbl_inboundsubscriptionemail@p-2m36udkdqkvmnusk4vb2ulbxoc439qi7by3ittzcpgoqvyedb9.o-aeszeam.na17.apex.salesforce.com'},',');   
    request.TreatTargetObjectAsRecipient=false;
    request.SaveAsActivity=true; 
    lstEmailRequests.add(request);
    List<SendEmail.OutputResult> outputs = SendEmail.SendEmail(lstEmailRequests);
    if(outputs[0].isSuccess){   
        List<sObject> sObjUpdates = new List<sObject>();
        sObjUpdates.add(new Student_Subscription__c(Id=stuSub.Id,Invoice_Sent__c=true,Last_Invoice_Sent_Date__c=System.now()));
        sObjUpdates.add(new Student_Program__c(Id=stuSub.Student_Program__c,Last_Invoice_Sent_Date__c=System.now())); 
        update sObjUpdates;
    }
  }
}