/*******************************************************************
Name  : StudentHoldCodeTriggerHandler
Author: Horacio Sanchez
Date  : May 28, 2020
Description: Handler class for the StudentHoldCodeTrigger
*************************************************************************/
public with sharing class StudentHoldCodeTriggerHandler {
    
    public void onAfterInsert(List<Student_Hold_Code__c> newStudentHoldCodesList) {
        Set<Id> studentHoldCodeIdSet = new Set<id>();
        for (Student_Hold_Code__c studentHoldCode : newStudentHoldCodesList) {
            studentHoldCodeIdSet.add(studentHoldCode.Id);
        }
        
        StudentHoldCodeTriggerHelper helper = new StudentHoldCodeTriggerHelper();
        Set<Id> bkStudentProgramIdSet = new Set<id>();
        Set<Id> c2StudentProgramIdSet = new Set<id>();
        for (Student_Hold_Code__c studentHoldCode : [SELECT Id, Student_Program__c, Hold_Code__r.Name FROM Student_Hold_Code__c WHERE Id IN :studentHoldCodeIdSet AND Hold_Close_Date__c = NULL]) {
            if (studentHoldCode.Hold_Code__r.Name == 'BK') {
                bkStudentProgramIdSet.add(studentHoldCode.Student_Program__c);
            } else if (studentHoldCode.Hold_Code__r.Name == 'C2') {
                c2StudentProgramIdSet.add(studentHoldCode.Student_Program__c);
            }
        }
        
        if (!bkStudentProgramIdSet.isEmpty()) {
            helper.processBKHoldCodeInsert(bkStudentProgramIdSet);
        }
        
        if (!c2StudentProgramIdSet.isEmpty()) {
            helper.processC2HoldCodeInsert(c2StudentProgramIdSet);
        }        
    }
}