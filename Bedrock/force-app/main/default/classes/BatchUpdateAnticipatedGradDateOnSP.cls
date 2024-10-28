/************************************************************************************** 
Apex Class Name     : BatchUpdateAnticipatedGradTimeOnSP
Created Date        : 15th January, 2021
Function            : One time batch run to update Anticipated Graduation Date on SP for existing records
					  S-38827: Tempo: Degree Audit: Max time completion update
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                  
* Horacio Sanchez            01/15/2021                Original Version
*************************************************************************************/
global class BatchUpdateAnticipatedGradDateOnSP implements Database.Batchable<sObject> {    
    global String Query;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'SELECT Id, Anticipated_Graduation_Date__c, Max_Time_to_Completion__c, First_Start_Date__c FROM Student_Program__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Student_Program__c> spList){
        List<Student_Program__c> spListToUpdate = new List<Student_Program__c>();
        
        for (Student_Program__c sp : spList) {
            if (sp.First_Start_Date__c != null && sp.Max_Time_to_Completion__c != null) {
                Student_Program__c studentProgram = new Student_Program__c();
                studentProgram.Id = sp.Id;
                studentProgram.Anticipated_Graduation_Date__c = sp.First_Start_Date__c.addMonths(Integer.valueOf(sp.Max_Time_to_Completion__c));
                spListToUpdate.add(studentProgram);
            }            
        }
        
        database.update(spListToUpdate, false);
        
    }
    
    global void finish(Database.BatchableContext BC){
    }

}