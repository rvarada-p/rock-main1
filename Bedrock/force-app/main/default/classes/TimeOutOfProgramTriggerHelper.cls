/*******************************************************************
Name  : TimeOutOfProgramTriggerHelper
Author: Horacio Sanchez
Date  : October 15, 2020
Description: Helper class for the Trigger TimeOutOfProgramTrigger
Created for User Story S-27538, Sprint 2020.5.1
*************************************************************************/
public class TimeOutOfProgramTriggerHelper {
    
    /*******************************************************************
    Method to update Total Gap Months field (LOA_Gap_Months__c) on SP
    Related Story : S-27538
    Created By: Horacio Sanchez
	Date: October 15, 2020
    Event : After Insert
    ********************************************************************/
    public static void updateGapMonthsInSP(List<Time_out_of_Program__c> toopList) {
        List<Student_Program__c> spToUpdateList = new List<Student_Program__c>();
        
        Set<Id> spIds = new Set<Id>();
        for (Time_out_of_Program__c toop : toopList) {
            spIds.add(toop.student_program__c);
        }
        
        for (Student_Program__c sp : [SELECT Id, loa_gap_months__c FROM Student_Program__c WHERE Id IN :spIds]) {
            for (Time_out_of_Program__c toop : toopList) {
                if (toop.Student_Program__c == sp.id) {
                    if (sp.LOA_Gap_Months__c == null) {
                        sp.LOA_Gap_Months__c = 0;
                    }
                    sp.LOA_Gap_Months__c += toop.Months_on_Time_out__c;
                }
            }
            spToUpdateList.add(sp);
        }
        
        if (!spToUpdateList.isEmpty()) {
            update spToUpdateList;
        }
    }
    
    /*******************************************************************
    Method to update Total Gap Months field (LOA_Gap_Months__c) on SP
    Related Story : S-27538
    Created By: Horacio Sanchez
	Date: October 15, 2020
    Event : After Update
    ********************************************************************/
    public static void updateGapMonthsInSP(List<Time_out_of_Program__c> updatedTimeOutOfProgram, map<ID,Time_out_of_Program__c> mapOld) {
        List<Student_Program__c> spToUpdateList = new List<Student_Program__c>();
        
        Set<Id> spIds = new Set<Id>();
        for (Time_out_of_Program__c toop : updatedTimeOutOfProgram) {
            spIds.add(toop.student_program__c);
        }
        for (Student_Program__c sp : [SELECT Id, loa_gap_months__c FROM Student_Program__c WHERE Id IN :spIds]) {
            for (Time_out_of_Program__c toop : updatedTimeOutOfProgram) {
                Decimal newLoaMonths = toop.Months_on_Time_out__c;
                Decimal oldLoaMonths = mapOld.get(toop.id).Months_on_Time_out__c;
                if (newLoaMonths != oldLoaMonths) {
                    sp.LOA_Gap_Months__c = sp.LOA_Gap_Months__c + (newLoaMonths - oldLoaMonths);
                }
            }
            spToUpdateList.add(sp);
        }
        
        if (!spToUpdateList.isEmpty()) {
            update spToUpdateList;
        }
    }

}