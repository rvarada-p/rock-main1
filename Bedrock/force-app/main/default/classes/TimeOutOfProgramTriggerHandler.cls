/*******************************************************************
Name  : TimeOutOfProgramTriggerHandler
Author: Horacio Sanchez
Date  : October 15, 2020
Description: Handler class for the Trigger TimeOutOfProgramTrigger
Created for User Story S-27538, Sprint 2020.5.1
*************************************************************************/
public with sharing class TimeOutOfProgramTriggerHandler {
    private set<ID> setCBLRecordTypes;
    private boolean isExecuting = false;
    private integer batchSize = 0;
    

    public TimeOutOfProgramTriggerHandler(boolean isExecuting, integer size){
        isExecuting = isExecuting;
        batchSize = size;
        setCBLRecordTypes = Utility.getRecordTypeFromCBLCustomSetting(Time_out_of_Program__c.sObjectType.getDescribe());
    }
    
    public void onAfterInsert(List<Time_out_of_Program__c> newList) {
        TimeOutOfProgramTriggerHelper.updateGapMonthsInSP(newList);
    }
        
    public void onAfterUpdate(List<Time_out_of_Program__c> updatedList, Map<Id, Time_out_of_Program__c> mapOld) {
        TimeOutOfProgramTriggerHelper.updateGapMonthsInSP(updatedList, mapOld);
    }

}