/*******************************************************************
Name  : StudentExpertiseTriggerHandler
Author: Tom (Appirio)
Description: Handler class for the Trigger StudentExpertiseTrigger

Revision History 
Horacio Sanchez - 9/29/2020 - S-25237 Move Existing Pre-req functionality from AoE to PE
* Sufia                     6/23/2021                 S-685236 Update Existing Pre-requisite Logic for RN to MSN Programs
* Horacio Sanchez           3/10/2022                 Prod Defect 83329: Pre-reqs are breaking in L2 Prod
*************************************************************************/
public with sharing class StudentExpertiseTriggerHandler {

    private set<ID> setCBLRecordTypes;
    private boolean isExecuting = false;
    private integer batchSize = 0;
	public static Boolean skipAfterUpdateRecursion = false;
    
    public StudentExpertiseTriggerHandler(boolean isExecuting, integer size){
        isExecuting = isExecuting;
        batchSize = size;
        setCBLRecordTypes = Utility.getRecordTypeFromCBLCustomSetting(Student_Expertise__c.sObjectType.getDescribe());
    }

    public void onBeforeInsert(list<Student_Expertise__c > newStudentExps){
        Set<Id> studntPrgmIdSet = new Set<Id>();
        //set RecordType based on related Program
        for(Student_Expertise__c sExp: newStudentExps){
            if(sExp.Opportunity__c == null){
                studntPrgmIdSet.add(sExp.Student_Program__c);
            }
            if(sExp.Program_Expertise__c!=null){
                SObjectType objTypeForInstitution = Schema.getGlobalDescribe().get('Student_Expertise__c');
                sExp.RecordTypeId = objTypeForInstitution.getDescribe().getRecordTypeinfosByName().get( sExp.Program_Institution__c ).getRecordTypeId();
            }
        }
        Map<Id,Student_Program__c> stdntPrmMap = new Map<Id,Student_Program__c>([Select id, Application__c from Student_Program__c where id in :studntPrgmIdSet]);
        for(Student_Expertise__c sExp: newStudentExps){
            if(sExp.Opportunity__c == null && stdntPrmMap.containsKey(sExp.Student_Program__c)){
                sExp.Opportunity__c = stdntPrmMap.get(sExp.Student_Program__c).Application__c;
            }
        }
    }

    public void onBeforeUpdate(list<Student_Expertise__c > newStudentExps,map<ID,Student_Expertise__c>oldMap){
        List<Student_Expertise__c> listStudentExpGradeValue = new List<Student_Expertise__c>();

        for(Student_Expertise__c sExpertise :newStudentExps){

            //Calculates GPA on SE Logic
            if(sExpertise.IsAchieved__c == true && oldMap.get(sExpertise.id).IsAchieved__c == false){
                listStudentExpGradeValue.add(sExpertise);
            }else if(sExpertise.IsAchieved__c == false && oldMap.get(sExpertise.id).IsAchieved__c == true){
                sExpertise.Grade__c = null;
                sExpertise.Grade_Value__c = null;
            }

        }


        //Calculates GPA on SE
        if(!listStudentExpGradeValue.isEmpty()){
            StudentExpertiseHelper.calculateGradeValue(listStudentExpGradeValue);
        }

    }


    public void onAfterInsert( List<Student_Expertise__c> newStudentExps ) {

    }

    public void onAfterUpdate(list<Student_Expertise__c > newStudentExps, Map<Id, Student_Expertise__c> oldStudentExpsMap ) {
        if(skipAfterUpdateRecursion)return;
        StudentExpertiseHelper objStudentExpertiiseHelper = new StudentExpertiseHelper();
        Set<Id> stprgmSet = new Set<ID>();
        set<ID> setCBLStudentProgramID = new set<ID>();
        set<ID> setStudentProgramID = new set<ID>();
        system.debug('*********8newStudentExps'+newStudentExps);
        Set<Id> achievedSEIdSet = new Set<Id>();
        Set<Id> studentProgIdSet = new Set<Id>();
        for(Student_Expertise__c sExpertise :newStudentExps){

            /*Calculate GPA on SP
            if(sExpertise.Student_Program__c != null && sExpertise.Area_of_Expertise__r.Type__c != 'Non-Academic'
               && sExpertise.isAchieved__c == true
               && sExpertise.Grade_value__c != null && sExpertise.Grade__c != null
               && sExpertise.Fulfilled_Course_from_a_Conferred_Degree__c == FALSE ){
                   setStudentProgramID.add(sExpertise.Student_Program__c);
               }else if(sExpertise.isAchieved__c == false && sExpertise.Student_Program__c != null && sExpertise.Area_of_Expertise__r.Type__c != 'Non-Academic'){
                   setStudentProgramID.add(sExpertise.Student_Program__c);
               }*/

            If(sExpertise.Student_Program__c != null && sExpertise.Area_of_Expertise__r.Type__c != 'Non-Academic' &&
                     oldStudentExpsMap.get(sExpertise.Id).isAchieved__c != sExpertise.isAchieved__c && sExpertise.isAchieved__c == true && sExpertise.Grade_value__c != null &&
                    sExpertise.Grade__c != null && sExpertise.Fulfilled_Course_from_a_Conferred_Degree__c == False &&(
                    sExpertise.Degree_Level__c == 'Graduate' ||
                            (sExpertise.Degree_Level__c == 'UnderGrad' &&
                                    sExpertise.Outcome_Category__c != null) )){
                setStudentProgramID.add(sExpertise.Student_Program__c);
            }else if( oldStudentExpsMap.get(sExpertise.Id).isAchieved__c != sExpertise.isAchieved__c && sExpertise.isAchieved__c == false && sExpertise.Student_Program__c != null && sExpertise.Area_of_Expertise__r.Type__c != 'Non-Academic'){
                setStudentProgramID.add(sExpertise.Student_Program__c);
            }else if (sExpertise.Student_Program__c != null && sExpertise.Area_of_Expertise__r.Type__c != 'Non-Academic' &&
                     oldStudentExpsMap.get(sExpertise.Id).Outcome_Category__c != sExpertise.Outcome_Category__c && sExpertise.Outcome_Category__c != null && sExpertise.Grade_value__c != null
                      && sExpertise.Grade__c != null && sExpertise.Fulfilled_Course_from_a_Conferred_Degree__c == False && sExpertise.Degree_Level__c == 'UnderGrad'
                     ){
                                                setStudentProgramID.add(sExpertise.Student_Program__c);

                
            }


            //Calculate Transferred/Fulfilled Earned CE  &&  SP.GPA for UG
            if(sExpertise.Outcome_Category__c != oldStudentExpsMap.get(sExpertise.Id).Outcome_Category__c){
                stprgmSet.add(sExpertise.Student_Program__c);
            }
            
            //Logic For Pre-Requisite
            if (sExpertise.IsAchieved__c != oldStudentExpsMap.get(sExpertise.Id).IsAchieved__c) {
                achievedSEIdSet.add(sExpertise.Id);
                studentProgIdSet.add(sExpertise.Student_Program__c);

            }
        }


        //Calculate GPA on SP
        if(!setStudentProgramID.isEmpty()){
            StudentExpertiseHelper.calculateGrandGPAOnStudentProgram(setStudentProgramID);
        }

        //Logic for Student Audit History re-evaution when is_Achieved updated from True to False
        DeleteStudentAuditHistory.delAndcreateStudentAuditHistory(oldStudentExpsMap ,newStudentExps);

        //Calculate Transferred/Fulfilled Earned for UG
        if(!stprgmSet.isEmpty()){
            StudentExpertiseHelper.calculateUGProgramTransferredFulfilledCE(stprgmSet);
        }

        //Pre-Requisite
        
        // S-83329
        List<Student_Expertise__c> seList = new List<Student_Expertise__c>();
        seList = [SELECT Id, Name, Student_Program__c, Student_Program__r.Program__r.ProductCode FROM Student_Expertise__c WHERE Id IN :studentProgIdSet];
        Set<Id> rnToMSNSPsIdSet = new Set<Id>();
        for (Student_Expertise__c se : seList) {
            if (se.Student_Program__r.Program__r.ProductCode.contains('RNMSN')) {
                rnToMSNSPsIdSet.add(se.Student_Program__c);
            }
        }
        
        // S-25237
        if (!achievedSEIdSet.isEmpty()) {
            objStudentExpertiiseHelper.managePreRequisiteFunctionality(achievedSEIdSet); 
            //S-685236
            objStudentExpertiiseHelper.handleUnlockCourseFunctionality(rnToMSNSPsIdSet);
        }
    }

    public void onAfterDelete(List<Student_Expertise__c > newStudentExps){

    }

    public void onAfterUnDelete(List<Student_Expertise__c > newStudentExps){

    }
}