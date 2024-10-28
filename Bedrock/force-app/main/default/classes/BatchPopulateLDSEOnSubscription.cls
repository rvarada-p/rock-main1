/************************************************************************************** 
Apex Class Name     : BatchPopulateLDSEOnSubscription
Created Date        : 13th June 2019
Function            : This Batch Class Handles to Update LDSE field on Current Student Subscription
                      record when the Student_Engagement_Rule__'s Last_Date_of_Engagement__c field and SP's 
                      Last_Date_of_Engagement__c date is between current stubscription start and end date
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ravitej Varada            06/13/2019                Original Version
*************************************************************************************/
global class BatchPopulateLDSEOnSubscription implements Database.Batchable<sObject>, Database.AllowsCallouts,Schedulable{
    
    global String Query; 
    public Exception[] errors = new Exception[0];
    public List<Apex_Log__c> logs = new List<Apex_Log__c>();
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'Select id, Student_Program__c from Student_Engagement_Rule__c where LastModifiedDate = Today AND LastModifiedBy.name= \'BI User\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(SchedulableContext SC){ 
        BatchPopulateLDSEOnSubscription objBatch = new BatchPopulateLDSEOnSubscription();
        ID batchprocessid = Database.executeBatch(objBatch,50);    
    } 
    
    global void execute(Database.BatchableContext BC, List<Student_Engagement_Rule__c> scope){
        try{             
            set<id> spId = new set<id>();
            for(Student_Engagement_Rule__c stueng : scope){
                spId.add(stueng.student_Program__c);
            }
            List<student_Program__c> spLst = new List<student_Program__c>();
            spLst = [SELECT id,Current_Student_Subscription__c,Last_Date_of_Engagement__c,CurrentSubscriptionStartDate__c,CurrentSubscriptionEndDate__c  FROM Student_Program__c  WHERE id in: spId];
            system.debug('spLst'+spLst +'scope'+scope);
            List<Student_Subscription__c> subToUpdate = new List<Student_Subscription__c>();
            for(Student_program__c sp : spLst){
                If(sp.Last_Date_of_Engagement__c >= sp.CurrentSubscriptionStartDate__c && sp.Last_Date_of_Engagement__c <= sp.CurrentSubscriptionEndDate__c){
                    subToUpdate.add(new Student_Subscription__c(id = sp.Current_Student_Subscription__c, LDSE__c = sp.Last_Date_of_Engagement__c ));
                }
            }
            system.debug('subToUpdate'+subToUpdate.size());
            if(!subToUpdate.isEmpty() && subToUpdate.size() >0 ){
                database.update(subToUpdate, false);
            }
        }catch(exception e){
            System.debug('An exception occurred: ' + e.getMessage());
            errors.add(e);
            system.debug('errors'+errors);
            system.debug('errors'+errors.size());
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        if (!errors.isEmpty() && errors.size()>0){
            for (Exception error: errors){
                 logs.add(new apex_log__c(class_name__c= 'BatchPopulateLDSEOnSubscription' ,Status_Message__c= 'Error Exception',message__c= error.getMessage()));
            }
            if(logs.size() > 0){
                system.debug('Logs'+logs.size());
                insert logs;
            }
        }
        
    }
}