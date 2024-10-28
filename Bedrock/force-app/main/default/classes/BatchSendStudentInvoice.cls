/*******************************************************************
Name  : BatchSendStudentInvoice
Author: Sufia
Date  : July 20, 2021
Description: Batch class that processes subscription records and send email

Sufia - 09/24/2021 - I-423645
*************************************************************************/


public without sharing class BatchSendStudentInvoice implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
	public Database.QueryLocator start( Database.BatchableContext BC){ 
        return Database.getQueryLocator([select Id,Student_Program__c from Student_Subscription__c WHERE 
                                        Write_Off__c = FALSE AND Subscription_Status__c NOT IN ('DD = Subscription Drop/Delete','DW = Web Drop' ,'RW = Web Registered') AND
                                        ((Future_Term__c = true AND Start_Date__c <=NEXT_N_DAYS:30 AND Student_Program__r.Total_Outstanding_Balance__c>0) OR  
                                        (Future_Term__c = false AND Start_Date__c <=:Date.today()  AND Student_Program__r.Outstanding_Balance_Minus_Future__c>0)) AND  
                                        Student_Program__r.Open_BK_Hold__c=0 AND 
                                        Student_Program__r.Sponsor_Billing__c=false AND 
                                        Student_Program__r.Student_Sponsor_Name__c=NULL AND
                                        (Student_Program__r.Last_Invoice_Sent_Date__c =NULL OR 
                                        (Student_Program__r.Last_Invoice_Sent_Date__c!=NULL AND Student_Program__r.Last_Invoice_Sent_Date__c < LAST_N_DAYS:7)) AND
                                        (Student_Program__r.Student_s_Walden_Email__c!=NULL OR Student_Program__r.Student__r.Walden_Email__c!=NULL OR Student_Program__r.Student__r.Email!=NULL)]);
                                        
    
    }  
    
    public void execute(SchedulableContext SC){ 
        Database.executeBatch(new BatchSendStudentInvoice());
    }    
    
    public void execute(Database.BatchableContext BC, List<Student_Subscription__c> scope ){
        Set<Id> setStudentProgramIDs = new Set<Id>();
        for(Student_Subscription__c subscription : scope){
            setStudentProgramIDs.add(subscription.Student_Program__c);
        }
        StudentInvoiceEmailProcessor.processStuProgramsAndSendInvoice(setStudentProgramIDs);
    }
    
    public void finish(Database.BatchableContext BC){  
    }
}