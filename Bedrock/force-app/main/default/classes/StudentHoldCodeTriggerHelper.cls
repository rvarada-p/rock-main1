/*******************************************************************
Name  : StudentHoldCodeTriggerHandler
Author: Horacio Sanchez
Date  : May 29, 2020
Description: Handler class for the StudentHoldCodeTrigger
*************************************************************************/
public class StudentHoldCodeTriggerHelper {
    
    public void processBKHoldCodeInsert(Set<Id> studentProgramIdSet) {
        List<Student_Hold_Code__c> studentHoldCodesToUpdateList = new List<Student_Hold_Code__c>();
        for (Student_Hold_Code__c shc : [SELECT Id, Name FROM Student_Hold_Code__c WHERE Student_Program__c IN :studentProgramIdSet AND 
                                                     Hold_Close_Date__c = NULL AND 
                                                     (Hold_Code__r.Name='DH' OR Hold_Code__r.Name='BH' OR Hold_Code__r.Name='C2')]) {
            Student_Hold_Code__c studentHoldCode = new Student_Hold_Code__c();
            studentHoldCode.Id = shc.Id;
            studentHoldCode.Hold_Close_Date__c = Date.today();
            studentHoldCodesToUpdateList.add(studentHoldCode);
        }
        
        if (!studentHoldCodesToUpdateList.isEmpty()) {
            update studentHoldCodesToUpdateList;
        }
    }
    
    public void processC2HoldCodeInsert(Set<Id> studentProgramIdSet) {
        List<Student_Hold_Code__c> studentHoldCodesToUpdateList = new List<Student_Hold_Code__c>();
        for (Student_Hold_Code__c shc : [SELECT Id, Name FROM Student_Hold_Code__c WHERE Student_Program__c IN :studentProgramIdSet AND 
                                                     Hold_Close_Date__c = NULL AND 
                                                     (Hold_Code__r.Name='DH' OR Hold_Code__r.Name='BH')]) {
            Student_Hold_Code__c studentHoldCode = new Student_Hold_Code__c();
            studentHoldCode.Id = shc.Id;
            studentHoldCode.Hold_Close_Date__c = Date.today();
            studentHoldCodesToUpdateList.add(studentHoldCode);
        }
        
        if (!studentHoldCodesToUpdateList.isEmpty()) {
            update studentHoldCodesToUpdateList;
        }
    }

}