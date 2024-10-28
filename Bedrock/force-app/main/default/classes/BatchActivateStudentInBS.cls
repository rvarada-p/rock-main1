/************************************************************************
Name  : BatchActivateStudentInBS 
Author: Sarah Khalid, Laureate
Date  : May 16, 2018
Description: batch class for BS API Integration to Activate/De-activate a 
             student in BS
*************************************************************************/

global class BatchActivateStudentInBS implements Database.Batchable<sObject>, Database.AllowsCallouts,  Database.Stateful,Schedulable  {
    global integer totalrecordsProcess;
    global String soql;
   

    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        totalrecordsProcess = 0;
        Date todayDate = System.today();
              soql = 'SELECT CBL_Id__c, Student_LMS_ID__c, IsStudentProgramActive__c , Student_First_Name__c ,Student_Last_Name__c,Student_Primary_Email__c' +
               ' FROM Student_Program__c WHERE  Date_Student_Activated__c  = : todayDate AND (Date_Activated_in_LMS__c   <>: todayDate OR Date_Activated_in_LMS__c   = null) LIMIT 500';
        return Database.getQueryLocator(soql);
     }

     global void execute(SchedulableContext SC){ 
          BatchActivateStudentInBS objBatch = new BatchActivateStudentInBS(); 
          ID batchprocessid = Database.executeBatch(objBatch,10);   
      } 
     
     global void execute(Database.BatchableContext BC, list<SObject> scope ) { 
      
         system.debug('scope'+scope.size());
        list<Student_Program__c> lstStudentPrograms = (list<Student_Program__c>)scope;
        BrightSpaceCalls.updateUserIsActive(lstStudentPrograms);
        totalrecordsProcess+= lstStudentPrograms.size();  
         system.debug('totalrecordsProcess'+totalrecordsProcess);
        
     }
     
     global void finish(Database.BatchableContext BC){ 
         
     }

}