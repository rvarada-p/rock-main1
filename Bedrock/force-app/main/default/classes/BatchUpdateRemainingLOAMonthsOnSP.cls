global class BatchUpdateRemainingLOAMonthsOnSP implements Database.Batchable<sObject>, Database.Stateful,Schedulable  {
	global String query;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        query = 'SELECT id, months_on_loa__c, Student_Program__c, student_program__r.Total_LOA_Months_Available__c, Anniversary_Date__c FROM Leave_of_absence__c';
        return Database.getQueryLocator(query);
	}
	global void execute(SchedulableContext SC) { 
        BatchUpdateRemainingLOAMonthsOnSP objBatch = new BatchUpdateRemainingLOAMonthsOnSP(); 
        ID batchprocessid = Database.executeBatch(objBatch, 20);   
    }     
    global void execute(Database.BatchableContext bc, List<Leave_Of_Absence__c> loaList) {
		List<Student_program__c> spToUpdateList = new List<Student_program__c>();
        Map<Id, Decimal> spIdMonthsOnLoaMap = new Map<Id, Decimal>();
        
        System.debug('****' + loaList);
        
        for (Leave_of_Absence__c loa : loaList) {
            System.debug('****' + loa.Anniversary_Date__c);
            if (System.today() == loa.Anniversary_Date__c) {
                spIdMonthsOnLoaMap.put(loa.student_Program__c, loa.student_program__r.Total_LOA_Months_Available__c + loa.months_on_loa__c);
            }
        }
		
        for (Id spId : spIdMonthsOnLoaMap.keySet()) {
            Student_Program__c sp = new Student_program__c();
            sp.id = spId;
            sp.Total_LOA_Months_Available__c = spIdMonthsOnLoaMap.get(spId);
            spToUpdateList.add(sp);
        }
        
        if (!spToUpdateList.isEmpty()) {
            update(spToUpdateList);
        }
    }

    global void finish(Database.BatchableContext bc) {
        
    }
}