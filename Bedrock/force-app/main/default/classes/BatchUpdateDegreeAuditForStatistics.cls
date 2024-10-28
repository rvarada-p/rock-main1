/************************************************************************************** 
Apex Class Name     : BatchUpdateDegreeAuditForStatistics
Created Date        : February 4, 2021
Function            : One time batch run to update Degree Audit to include Statistics as Subject Area Expertise,
					  making them to change from Mathematics/Natural Science to Statistics as Outcome Subject Area Expertise
					  S-39033: Tempo: Statistics Category: Update Existing Students Degree Audit (Step 3)
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                  
* Horacio Sanchez            02/04/2021                Original Version
*************************************************************************************/
global class BatchUpdateDegreeAuditForStatistics implements Database.Batchable<sObject>, Database.Stateful {    
    global String query;
    global Set<Id> successfullyUpdatedSPIdSet = new Set<Id>();
    global Set<Id> failedUpdatedSPIdSet = new Set<Id>();
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'SELECT Id, Student_Program__c '
              + 'FROM Student_Expertise__c '
             /* + 'WHERE Student_Program__c = \'a0R170000073IiB\'';*/
              + ' WHERE (Area_of_Expertise_Name__c = \'Statistical Methods and Applications (STAT 3001)\''
              + ' OR (Area_of_Expertise_Name__c = \'Introduction to Basic Statistics(PSYC 3002)\' AND Program_Expertise__c = null))'
              + ' AND isAchieved__c = true'
              + ' AND Student_Program__r.Program__r.Name LIKE \'%B.S. in Nursing%\''
              + ' AND Student_Program__r.Degree_Status__c = \'In Progress\'';
              //+ ' LIMIT 1';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Student_Expertise__c> scope){
        Set<Id> studentProgramIdSet = new Set<Id>();
        for (Student_Expertise__c se : scope) {
            studentProgramIdSet.add(se.Student_Program__c);
        }
        List<Student_Program__c> spList = new List<Student_Program__c> ();
        spList = [SELECT id,
                         (SELECT id, Outcome_Subject_Area_Expertise__c, Outcome_Category__c, Is_Audit_History_Created__c, Total_Applied_Earned_CE_Outcome__c, Student_Program__c
                          FROM Student_Expertise__r 
                          WHERE IsAchieved__c = TRUE),
                         (SELECT Id 
                          FROM Student_Audit_Historys__r) 
                  FROM Student_Program__c 
                  WHERE id IN :studentProgramIdSet];
                
        List<Student_Expertise__c> SEToUpdate = new List<Student_Expertise__c>();
        List<Student_Audit_History__c> SAHToDelete = new List<Student_Audit_History__c>();
        Map<Id, Id> SEIdSPIdMap = new Map<Id, Id>();
        
        for (Student_Program__c sp : spList) {
            for (Student_Audit_History__c sah: sp.Student_Audit_Historys__r) {
                SAHToDelete.add(sah);
            }
        
            for (Student_Expertise__c se: sp.Student_Expertise__r) {
                se.Outcome_Category__c = '';
                se.Outcome_Subject_Area_Expertise__c = '';
                se.Total_Applied_Earned_CE_Outcome__c = null;
                se.Is_Audit_History_Created__c= False;
                SEToUpdate.add(se);
                
                //
                if (!SEIdSPIdMap.containsKey(se.Id)) {
                    SEIdSPIdMap.put(se.Id, sp.Id);
                }
            }
        }
        
        Database.SaveResult[] updateSEResult = Database.update(SEToUpdate, false);
        for (Integer i = 0; i < updateSEResult.size(); i++) {
            if (updateSEResult.get(i).isSuccess()) {
                successfullyUpdatedSPIdSet.add(SEIdSPIdMap.get(updateSEResult.get(i).Id));
            } else {
                Database.Error errors =  updateSEResult.get(i).getErrors().get(0);
                System.debug('Error processing record: ' + errors.getMessage());
                failedUpdatedSPIdSet.add(SEIdSPIdMap.get(updateSEResult.get(i).Id));
            }
        }
        
        if (!SAHToDelete.isEmpty()) {
            Delete SAHToDelete;
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        System.debug('**Batch finished**');
        System.debug('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
        System.debug('Successfully Updated SP Ids: ');
        System.debug(successfullyUpdatedSPIdSet);
        System.debug('Failed Updated SP Ids: ');
        System.debug(failedUpdatedSPIdSet);
    }

}