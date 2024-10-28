/************************************************************************
Name  : BatchSendEmailToNonEngagement
Author: Ravitej Varada, Laureate
Date  : Feb 01, 2020
Description: batch class  To send Email to Students for Non - Engagement

* Revision History
* Horacio Sanchez - December 15, 2021 - User Story 75087: L2: Update LDE emails and View CLP Page
*************************************************************************/
public with sharing class BatchSendEmailToNonEngagement implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
    
    public integer totalNumberOfSuccess;
    public integer totalNumberOfFailure;
    
    
    public Database.QueryLocator start( Database.BatchableContext bc){ 
        
        String SOQL; 
        SOQL = 'SELECT id,Name, Days_Not_Engaged__c,Student_s_Walden_Email__c,Student__c,Student__r.Walden_Email__c,Student__r.Email, Program__r.Program_director__r.Name FROM Student_Program__c '
            + ' WHERE IsStudentProgramActive__c = TRUE AND (Days_Not_Engaged__c = 18 OR Days_Not_Engaged__c = 25)' ;        	
        return Database.getQueryLocator( SOQL );
    }  
    
    public void execute(SchedulableContext SC){ 
        BatchSendEmailToNonEngagement objBatch = new BatchSendEmailToNonEngagement(); 
        ID batchprocessid = Database.executeBatch(objBatch,25);
    }
    
    
    public void execute( Database.BatchableContext bc, list<Student_Program__c> scope ){
        
        totalNumberOfSuccess = 0;
        totalNumberOfFailure = 0;
        EmailTemplate templateId_18 = [Select Id from EmailTemplate where DeveloperName  = 'Classroom_Engagement_in_Tempo_18_Days'];
        EmailTemplate templateId_25 = [Select Id from EmailTemplate where DeveloperName  = 'Classroom_Engagement_in_Tempo_25_Days'];
        OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress WHERE DisplayName = 'Walden Coach Team [DO NOT REPLY]' limit 1];
        
        List<Apex_Log__c> logs = new List<Apex_Log__c>();
        Map<Id, String> spIdMessageMap = new Map<Id, String>();
        
        List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
        for (Student_Program__c sp: scope) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(sp.Student__c);
            List<String> sendTo = new List<String>();
            sendTo.add(sp.student__r.Email);
            sendTo.add(sp.student__r.Walden_Email__c);
            mail.setToAddresses(sendTo);
            mail.setOrgWideEmailAddressId(owa.id);
            //mail.setSenderDisplayName(sp.Program__r.Program_director__r.Name + ' [DO NOT REPLY]');
            if (sp.Days_Not_Engaged__c == 18) {
                mail.setTemplateId(templateId_18.id);
            } else if(sp.Days_Not_Engaged__c == 25) {
                mail.setTemplateId(templateId_25.id);
            }
            mail.setSaveAsActivity(false);
            mail.setWhatid(sp.id);
            msgListToBeSend.add(mail);
            
            logs.add(new Apex_Log__c(class_name__c ='BatchSendEmailToNonEngagement', method_name__c ='BatchSendEmailToNonEngagement', Status_Message__c ='Success',
                                     Message__c ='Email Sent to '+sp.Student_s_Walden_Email__c+', '+sp.Student__r.Email+ ' on '+integer.valueOF(sp.Days_Not_Engaged__c)+'th Day of Non Enagement.('+sp.Name+')'));
            if (!spIdMessageMap.containsKey(sp.id)) {
                spIdMessageMap.put(sp.id, 'Email Sent to ' + sp.student__r.Email + ', ' + sp.Student__r.Walden_Email__c + ' on '+integer.valueOF(sp.Days_Not_Engaged__c)+'th Day of Non Enagement.('+sp.Name+')');
            }
        }
        
        try {            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(msgListToBeSend,false);
            System.debug('---'+results.size());
            
            List<Task> taskList = new List<Task>();
            for (Integer i = 0; i < results.size(); i++) {
                Task tk = new Task();
                tk.Subject = 'Non-Engagement Email Sent';
                tk.WhatId = msgListToBeSend[i].getWhatid();
                tk.Description = spIdMessageMap.get(msgListToBeSend[i].getWhatid());
                tk.ActivityDate = Date.today();
                if (results[i].success) {
                    totalNumberOfSuccess++;
                    tk.Status = 'Completed';                    
                    System.debug('The email was sent successfully.');
                } else {
                    totalNumberOfFailure++;
                    tk.Status = 'In Progress' + + results[0].errors[0].message;
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                }
                taskList.add(tk);
            }
            if (!taskList.isEmpty()) {
                insert taskList;
            }
            /*for (Messaging.SendEmailResult rr : results) {
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
            }*/
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