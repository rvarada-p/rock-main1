global with sharing class BatchToUpdateEmailPostRefresh implements Database.Batchable<sObject>, Database.Stateful {
    
    
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        String SOQL;
        SOQL = 'SELECT Email,Walden_Email__c FROM Contact where (not Walden_Email__c like \'%.zzz\')';
         return Database.getQueryLocator(SOQL);
    } 
    
    
    
    global void execute(Database.BatchableContext bc, List<Contact> scope) {
        list<Contact> conToUpdate = new list<Contact> ();
        list<Student_program__c> spToUpdate = new list<Student_program__c> ();
        for (Contact con : scope){
            if(con.Email!=null){
                   con.Email = con.Email+ '.zzz';
               }
            if( con.Walden_Email__c != null){
                   con.Walden_Email__c = con.Walden_Email__c+ '.zzz';
               }  
             conToUpdate.add(con);
        }
          
        Database.SaveResult[] srList = Database.update(conToUpdate, false);
      }
    global void finish(Database.BatchableContext BC) {
        
        
    }
    
}