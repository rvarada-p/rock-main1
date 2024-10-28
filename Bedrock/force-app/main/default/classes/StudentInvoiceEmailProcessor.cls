/*******************************************************************
Name  : StudentInvoiceEmailProcessor
Author: Sufia
Date  : July 20, 2021
Description: Service class that processes subscription records and send email
Sufia - 09/24/2021 - I-423645

Revision History:
Ravitej Varada      - 10-14-2021 -  70735 - Invoice fix for Write Off - Current Subscription Balance >0
*************************************************************************/

public without sharing class StudentInvoiceEmailProcessor {
    public static void processStuProgramsAndSendInvoice(Set<Id> setStudentProgramIds) {
        List<SendEmail.InvokeSendEmail> lstEmailRequests = new List<SendEmail.InvokeSendEmail>();
        Map<Id,Id> mapContextStuSubIdToStuProgramId = new Map<Id,Id>();
        Set<Id> studentProgramsWithFutureTermSub = new Set<Id>();
        for( Student_Program__c stuProgram : [select Id,Student__c,Student_s_Walden_Email__c,Student__r.Walden_Email__c,Student__r.Email,
                                             (select Id from Subscriptions__r WHERE  Write_Off__c = FALSE AND Current_Subscription_Balance__c >0 AND Future_Term__c = true AND Start_Date__c<=NEXT_N_DAYS:30 AND Subscription_Status__c NOT IN ('DD = Subscription Drop/Delete','DW = Web Drop' ,'RW = Web Registered') AND Write_Off__c =false order by LastModifiedDate DESC LIMIT 1) FROM Student_Program__c WHERE
                                              ID IN :setStudentProgramIds AND Student__c!=NULL AND Total_Outstanding_Balance__c>0 AND Open_BK_Hold__c = 0 AND Sponsor_Billing__c = false AND Student_Sponsor_Name__c = NULL AND (Last_Invoice_Sent_Date__c=NULL OR (Last_Invoice_Sent_Date__c!=NULL AND Last_Invoice_Sent_Date__c < LAST_N_DAYS:7))]) {
            if( stuProgram.Subscriptions__r!=NULL && stuProgram.Subscriptions__r.size()>0 ){
                 studentProgramsWithFutureTermSub.add(stuProgram.Id);
                 Set<String> emails = new Set<String>(); 
                 if(String.isNotBlank(stuProgram.Student_s_Walden_Email__c))
                     emails.add(stuProgram.Student_s_Walden_Email__c);
                 if(String.isNotBlank(stuProgram.Student__r.Walden_Email__c))
                     emails.add(stuProgram.Student__r.Walden_Email__c); 
                 if(String.isNotBlank(stuProgram.Student__r.Email))
                     emails.add(stuProgram.Student__r.Email);
                  if(emails.size()>0) {
                     SendEmail.InvokeSendEmail request = new SendEmail.InvokeSendEmail();
                     request.ContactOrLeadID =  stuProgram.Student__c;
                     request.EmailTemplateName='Invoice_Email_Walden';
                     request.RelatedToId= stuProgram.Subscriptions__r[0].Id;
                     request.OrgWideEmailAddress='cblbilling@waldenu.edu';
                     request.ToAddresses = String.join(new List<String>(emails),',');
                     request.TreatTargetObjectAsRecipient=false;
                     request.SaveAsActivity=true; 
                     lstEmailRequests.add(request);
                     mapContextStuSubIdToStuProgramId.put(stuProgram.Subscriptions__r[0].Id,stuProgram.Id); 
                  } 
             }                
        }
        for( Student_Program__c stuProgram : [select Id,Student__c,Student_s_Walden_Email__c,Student__r.Walden_Email__c,Student__r.Email,
                                              (select Id from Subscriptions__r WHERE Write_Off__c = FALSE AND Current_Subscription_Balance__c >0 AND Future_Term__c = false AND Start_Date__c <=:Date.today() AND Subscription_Status__c NOT IN ('DD = Subscription Drop/Delete','DW = Web Drop' ,'RW = Web Registered') order by LastModifiedDate DESC LIMIT 1) FROM Student_Program__c WHERE
                                              (ID IN :setStudentProgramIds AND ID NOT IN :studentProgramsWithFutureTermSub) AND Student__c!=NULL AND Outstanding_Balance_Minus_Future__c>0 AND Open_BK_Hold__c = 0 AND Sponsor_Billing__c = false AND Student_Sponsor_Name__c = NULL AND (Last_Invoice_Sent_Date__c=NULL OR (Last_Invoice_Sent_Date__c!=NULL AND Last_Invoice_Sent_Date__c < LAST_N_DAYS:7))]) {
        	if( stuProgram.Subscriptions__r!=NULL && stuProgram.Subscriptions__r.size()>0 ){
                     Set<String> emails = new Set<String>(); 
                     if(String.isNotBlank(stuProgram.Student_s_Walden_Email__c))
                         emails.add(stuProgram.Student_s_Walden_Email__c);
                     if(String.isNotBlank(stuProgram.Student__r.Walden_Email__c))
                         emails.add(stuProgram.Student__r.Walden_Email__c); 
                     if(String.isNotBlank(stuProgram.Student__r.Email))
                         emails.add(stuProgram.Student__r.Email);
                      if(emails.size()>0) {
                         SendEmail.InvokeSendEmail request = new SendEmail.InvokeSendEmail();
                         request.ContactOrLeadID =  stuProgram.Student__c;
                         request.EmailTemplateName='Invoice_Email_Walden';
                         request.RelatedToId= stuProgram.Subscriptions__r[0].Id;
                         request.OrgWideEmailAddress='cblbilling@waldenu.edu';
                         request.ToAddresses = String.join(new List<String>(emails),',');
                         request.TreatTargetObjectAsRecipient=false;
                         request.SaveAsActivity=true; 
                         lstEmailRequests.add(request);
                         mapContextStuSubIdToStuProgramId.put(stuProgram.Subscriptions__r[0].Id,stuProgram.Id); 
                     } 
               }                
        }
        if(lstEmailRequests.size()>0){
            List<sObject> sObjUpdates = new List<sObject>(); 
            for(SendEmail.OutputResult output : SendEmail.SendEmail(lstEmailRequests)) {
                if(output.isSuccess){
                   sObjUpdates.add(new Student_Subscription__c(Id=output.relatedToId,Invoice_Sent__c=true,Last_Invoice_Sent_Date__c=System.now())); 
                   sObjUpdates.add(new Student_Program__c(Id=mapContextStuSubIdToStuProgramId.get(output.relatedToId),Last_Invoice_Sent_Date__c=System.now())); 
                }else{
                   sObjUpdates.add(new Student_Subscription__c(Id=output.relatedToId,Invoice_Sent__c=false)); 
                }
            }
            update Utility.getsObjectListChunkSafe(sObjUpdates);
        }
    }
}