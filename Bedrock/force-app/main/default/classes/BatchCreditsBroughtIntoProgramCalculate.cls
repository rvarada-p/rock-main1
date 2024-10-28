/************************************************************************
Name  : BatchCreditsBroughtIntoProgramCalculate 
Author: Ravitej Varada, Laureate
Date  : Jan 28, 2019
Description: batch class to handle Credits Brought into Program Rollup on SP  
             (One Time Run)
*************************************************************************/

global class BatchCreditsBroughtIntoProgramCalculate implements Database.Batchable<sObject> {
    global integer totalrecordsProcess;
    global String soql;
   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        totalrecordsProcess = 0;
        Date todayDate = System.today();
       // soql = 'SELECT Id FROM Student_Program__c where ID = \'a0R3F000000uy8C\'';
       soql = 'SELECT Id FROM Student_Program__c';
        return Database.getQueryLocator(soql);
     }

         
     global void execute(Database.BatchableContext BC, list<Student_Program__c> scope ) { 
      
        Set<Id> studentProgramsIDSet = new Set<Id>();
         for(Student_Program__c sp:  scope){
             studentProgramsIDSet.add(sp.id);
         }
         
         StudentCompetencyHelper objStudentCompetencyHelper = new StudentCompetencyHelper();
         objStudentCompetencyHelper.rollUpNumberOfCompetenciesOnStudentProgram(studentProgramsIDSet);
         
         
         //StudentExpertiseHelper.calculateUGProgramTransferredFulfilledCE(studentProgramsIDSet);
     }
    
    global void finish(Database.BatchableContext BC){ 
         
     }

}