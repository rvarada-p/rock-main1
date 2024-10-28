public with sharing class LeaveOfAbsenceTriggerHandler {
	private set<ID> setCBLRecordTypes;
    private boolean isExecuting = false;
    private integer batchSize = 0;
    

    public LeaveOfAbsenceTriggerHandler(boolean isExecuting, integer size){
        isExecuting = isExecuting;
        batchSize = size;
        setCBLRecordTypes = Utility.getRecordTypeFromCBLCustomSetting(Leave_of_Absence__c.sObjectType.getDescribe());
    }
    
    public void onBeforeInsert(List<Leave_of_Absence__c> newLOAList) {
        LeaveOfAbsenceTriggerHelper.populateLOAMonthsRemainingWithin12MonthPeriod(newLOAList, true);        
    }
    
    public void onAfterInsert(List<Leave_of_Absence__c> newLOAList) {
        LeaveOfAbsenceTriggerHelper.populateToAndFromDatesOnSP(newLOAList);
        LeaveOfAbsenceTriggerHelper.updateGapMonthsInSP(newLOAList);
    }
    
    public void onBeforeUpdate(List<Leave_of_Absence__c> updatedLeavesOfAbsence, map<ID,Leave_of_Absence__c> mapOld) {
        List<Leave_of_Absence__c> oldLoaList = new List<Leave_of_Absence__c>();
        for (Id key : mapOld.keySet()) {
            oldLoaList.add(mapOld.get(key));
        }
        LeaveOfAbsenceTriggerHelper.populateLOAMonthsRemainingWithin12MonthPeriod(oldLoaList, false);
        LeaveOfAbsenceTriggerHelper.populateLOAMonthsRemainingWithin12MonthPeriod(updatedLeavesOfAbsence, true);
        
        LeaveOfAbsenceTriggerHelper.updateGapMonthsInSP(updatedLeavesOfAbsence, mapOld);
    }
    
    public void onAfterUpdate(List<Leave_of_Absence__c> updatedLeavesOfAbsence, map<ID,Leave_of_Absence__c> mapOld) {
        LeaveOfAbsenceTriggerHelper.populateToAndFromDatesOnSP(updatedLeavesOfAbsence);
    }
}