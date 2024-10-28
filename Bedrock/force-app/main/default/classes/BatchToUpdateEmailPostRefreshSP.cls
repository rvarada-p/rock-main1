global with sharing class BatchToUpdateEmailPostRefreshSP implements Database.Batchable<sObject>, Database.Stateful {
    
    
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        String SOQL;
        SOQL = 'Select id, Student_s_Walden_Email__c from Student_Program__c where (not Student_s_Walden_Email__c like \'%.zzz\') and Student_s_Walden_Email__c <> null';

        return Database.getQueryLocator(SOQL);
    } 
    
    
    
    global void execute(Database.BatchableContext bc, List<Student_Program__c> scope) {
         list<Student_program__c> spToUpdate = new list<Student_program__c> ();
          for(Student_program__c sp: scope){
                if(sp.Student_s_Walden_Email__c != null){
                    sp.Student_s_Walden_Email__c = sp.Student_s_Walden_Email__c+'.zzz';
                    spToUpdate.add(sp); 
                }
            }
        
      
        
      update spToUpdate;
        
    }
    global void finish(Database.BatchableContext BC) {
        
        
    }
    
}