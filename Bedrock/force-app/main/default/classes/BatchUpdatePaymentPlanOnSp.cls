/************************************************************************
Name  : BatchUpdatePaymentPlanOnSp
Author: Ravitej Varada, Laureate
Date  : Feb 01, 2020
Description: batch class for To Update the payment plan flag on SP
*************************************************************************/
global with sharing class BatchUpdatePaymentPlanOnSp implements Database.Batchable<sObject>,Schedulable  {
    
        
    global Database.QueryLocator start( Database.BatchableContext bc){ 
        String SOQL;
        
         SOQL = 'SELECT id,Name, Open_C2_Hold__c,Payment_Plan__c'
            + ' FROM Student_Program__c' ; 
         
        return Database.getQueryLocator( SOQL );
    }  
    
    global void execute(SchedulableContext SC){ 
        BatchUpdatePaymentPlanOnSp objBatch = new BatchUpdatePaymentPlanOnSp(); 
        ID batchprocessid = Database.executeBatch(objBatch,200);         
    }
    
    
    global void execute( Database.BatchableContext bc, list<SObject> scope ){
        list<Student_Program__c> lstStudentProgram = (list<Student_Program__c>)scope;
           
        StudentProgramHelper.UpdatePaymentPlan(lstStudentProgram,False);
     }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
}