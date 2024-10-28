global class BatchStudentCompleteAPI implements Database.Batchable<sObject>, Database.AllowsCallouts,  Database.Stateful,Schedulable   {
    
    global integer totalrecordsProcess;
    global String soql;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        totalrecordsProcess = 0;
        soql = 'SELECT Competency_Shell_ID__c, LMS_Section_ID__c, Unenroll_from_LMS__c, Section__c, Student_LMS_ID__c, Unenrolled_from_LMS__c ' +
               ' FROM Student_Sections__c WHERE Unenroll_from_LMS__c = true AND Unenrolled_from_LMS__c = false LIMIT 500';
        return Database.getQueryLocator(soql);
     }

     global void execute(SchedulableContext SC){ 
          BatchStudentCompleteAPI objBatch = new BatchStudentCompleteAPI(); 
          ID batchprocessid = Database.executeBatch(objBatch,10);   
      } 
     
     global void execute(Database.BatchableContext BC, list<SObject> scope ) { 
        list<Student_Sections__c> lstStudentSections = (list<Student_Sections__c>)scope;
         BrightSpaceCalls.markStudentCompleteInLMS(lstStudentSections);
        totalrecordsProcess+= lstStudentSections.size();         
     }
     
     global void finish(Database.BatchableContext BC){ 
         
     }
}