/*******************************************************************
Name  : StudentAuditHistoryTriggerHandler
Author: Ravitej Varada
Date  : November 26th, 2018
Description: trigger handler class for  StudentAuditHistoryTrigger
Revision History :

Ravitej Varada      - Jan 18th 2021 -  S-39026 -  Handle 'Statistics' subject area expetise in Gen Ed rollup.

*************************************************************************/
public class StudentAuditHistoryTriggerHandler {
    private set<ID> setCBLRecordTypes;
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public static  boolean firstRun = true;
    
    
    public StudentAuditHistoryTriggerHandler(boolean isExecuting, integer size){
        isExecuting = isExecuting;
        batchSize = size;
        setCBLRecordTypes = Utility.getRecordTypeFromCBLCustomSetting(Student_Audit_History__c.sObjectType.getDescribe());
    }
    
    //On After Insert Event
    public void onAfterInsert(List<Student_Audit_History__c > newstudentAuditHistory) {
        Set<Id> updatedStudentProgram = new Set<Id>();
        for (Student_Audit_History__c sah : newstudentAuditHistory) {
            updatedStudentProgram.add(sah.student_program__c);
        }
        StudentAuditHistoryTriggerHelper.mapUGTotalEarnedCredits(updatedStudentProgram);        
    }
    
    //On Before Insert  Event
    public void onBeforeInsert(list<Student_Audit_History__c > newstudentAuditHistory){
    
        map<ID,List<Student_Audit_History__c>> mapStudentProgramWithStudentAuditHistory = new map<ID,List<Student_Audit_History__c>>();
       
        set<id> updatedStudentProgram = new set<id>();            
        for(Student_Audit_History__c  audHis : newstudentAuditHistory){
            system.debug('########audHis'+audHis);
            updatedStudentProgram.add(audHis.Student_Program__c);
            if(!mapStudentProgramWithStudentAuditHistory.containsKey(audHis.Student_Program__c)){
                mapStudentProgramWithStudentAuditHistory.put(audHis.Student_Program__c, new list<Student_Audit_History__c>());
            }
            mapStudentProgramWithStudentAuditHistory.get(audHis.Student_Program__c).add(audHis);
        }
        system.debug('**********'+mapStudentProgramWithStudentAuditHistory);
        for(id  sp : updatedStudentProgram){
            
            for(Student_Audit_History__c  audHis : mapStudentProgramWithStudentAuditHistory.get(sp)){
                decimal subjectAreaExpertiseRollup = 0;
                system.debug('audHisaudHis'+audHis.id);
                system.debug('******'+ audHis.Earned_CE_Arts_and_Humanities__c +'******'+ audHis.Earned_CE_Written_and_Oral_Communication__c  +'******'+ audHis.Earned_CE_Mathematics_Natural_Science__c  +'******'+ audHis.Earned_CE_Social_Science__c  +'******'+ audHis.Earned_CE_Any_Category__c  );

                //S-39026
                if(audHis.Earned_CE_Arts_and_Humanities__c != null){
                    subjectAreaExpertiseRollup +=audHis.Earned_CE_Arts_and_Humanities__c;
                }
                if(audHis.Earned_CE_Written_and_Oral_Communication__c != null){
                    subjectAreaExpertiseRollup +=audHis.Earned_CE_Written_and_Oral_Communication__c;
                }
                if(audHis.Earned_CE_Social_Science__c != null){
                    subjectAreaExpertiseRollup +=audHis.Earned_CE_Social_Science__c;
                }
                if(audHis.Earned_CE_Any_Category__c != null){
                    subjectAreaExpertiseRollup +=audHis.Earned_CE_Any_Category__c;
                }
                if(audHis.Earned_CE_Statistics__c != null){
                    subjectAreaExpertiseRollup +=audHis.Earned_CE_Statistics__c;
                }
  				if(audHis.Earned_CE_Mathematics_Natural_Science__c  != null){
                    subjectAreaExpertiseRollup +=audHis.Earned_CE_Mathematics_Natural_Science__c ;
                }
                 audHis.Earned_CE_General_Education__c = subjectAreaExpertiseRollup;
            }
        }
    }
     
    
    
      //On Before Update Event
    public void onBeforeUpdate(list<Student_Audit_History__c > newstudentAuditHistory,map<ID,Student_Audit_History__c>oldMap){
    }
    
    //On After Update Event
    public void onAfterUpdate(list<Student_Audit_History__c > newstudentAuditHistory,map<ID,Student_Audit_History__c>oldMap){ 
        
        
    }
    
}