/************************************************************************
Name  : BatchSendLOAEmailReminder
Author: Horacio Sanchez
Date  : December 8, 2020
Description: batch class that sends reminder Email 14 days before returning from LOA
			 User Story 28147: Tempo: Automated LOAR email reminder
*************************************************************************/
public with sharing class BatchSendLOAEmailReminder implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
    
    public integer totalNumberOfSuccess;
    public integer totalNumberOfFailure;    
    
    public Database.QueryLocator start( Database.BatchableContext bc){ 
        
        String SOQL; 
        SOQL = 'SELECT Id, Name, From_Date__c, To_Date__c, Student_s_Walden_Email__c, Student_Program__c, Student_Program__r.Name, Student_Program__r.Student__r.Email, Student_Program__r.Student__c FROM Leave_of_Absence__c '
            + ' WHERE On_LOA__c = True' ;
        return Database.getQueryLocator( SOQL );
    }  
    
    public void execute(SchedulableContext SC){ 
        BatchSendLOAEmailReminder objBatch = new BatchSendLOAEmailReminder(); 
        ID batchprocessid = Database.executeBatch(objBatch,25);
    }    
    
    public void execute(Database.BatchableContext bc, List<Leave_of_Absence__c> scope ){
        
        totalNumberOfSuccess = 0;
        totalNumberOfFailure = 0;
        EmailTemplate LOAREmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName  = 'Automated_LOA_email_reminder'];
        OrgWideEmailAddress owa = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Walden Coach Team [DO NOT REPLY]' limit 1];
        
        List<Apex_Log__c> logs = new List<Apex_Log__c>();
        Map<Id, String> spIdMessageMap = new Map<Id, String>();
           
        List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
        for (Leave_of_Absence__c loa: scope) {
            if (Date.today().daysBetween(loa.To_Date__c) == 14) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(loa.Student_Program__r.Student__c);
                List<String> sendTo = new List<String>();
                sendTo.add(loa.Student_Program__r.student__r.Email);
                sendTo.add(loa.Student_s_Walden_Email__c);
                mail.setToAddresses(sendTo);
                mail.setOrgWideEmailAddressId(owa.id);
                mail.setTemplateId(LOAREmailTemplate.Id);
                mail.setSaveAsActivity(false);
                mail.setWhatid(loa.Id);
                msgListToBeSend.add(mail);
                
                logs.add(new Apex_Log__c(class_name__c ='BatchSendLOAEmailReminder', method_name__c ='BatchSendLOAEmailReminder', Status_Message__c ='Success',
                                         Message__c ='Email Sent to '+loa.Student_s_Walden_Email__c+', '+loa.Student_Program__r.student__r.Email+ '. ('+loa.Student_Program__r.Name+')'));
                if (!spIdMessageMap.containsKey(loa.Id)) {
                    spIdMessageMap.put(loa.id, 'Email Sent to ' + loa.Student_Program__r.student__r.Email + ', ' + loa.Student_s_Walden_Email__c + '. ('+loa.Student_Program__r.Name+')');
                }
            }
        }
        
        try {            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(msgListToBeSend,false);
            System.debug('---'+results.size());
            
            for (Messaging.SendEmailResult rr : results) {
                system.debug('---'+rr);
                if (rr.success) 
                {
                    totalNumberOfSuccess++;
                    System.debug('The email was sent successfully.');
                } else 
                {
                    totalNumberOfFailure++;
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                }
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        
        if(logs.size()>0) {
            database.insert(logs);
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
        
    }
}