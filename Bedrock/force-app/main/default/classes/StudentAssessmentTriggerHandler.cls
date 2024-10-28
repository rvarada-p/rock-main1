/*******************************************************************
Name  : StudentAssessmentTriggerHandler
Author: Vinod (Appirio)
Date  : October 9, 2014
Description: Handler class for the Student Assessment trigger
*************************************************************************/
public with sharing class StudentAssessmentTriggerHandler {
	private set<ID> setCBLRecordTypes;
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public StudentAssessmentTriggerHandler(boolean isExecuting, integer size){
        isExecuting = isExecuting;
        batchSize = size;
        setCBLRecordTypes = Utility.getRecordTypeFromCBLCustomSetting(Student_Assessment__c.sObjectType.getDescribe());
    }

    public void onBeforeInsert(list<Student_Assessment__c> newStudentAssessments) {
        //set RecordType based on related Program
        for(Student_Assessment__c sAssmt: newStudentAssessments){
          if(sAssmt.Student_Competency__c!=null){
            SObjectType objTypeForInstitution = Schema.getGlobalDescribe().get('Student_Assessment__c');
            sAssmt.RecordTypeId = objTypeForInstitution.getDescribe().getRecordTypeinfosByName().get( sAssmt.Program_Institution__c ).getRecordTypeId();
          }
        }
    }

    public void onAfterInsert(list<Student_Assessment__c> newStudentAssessment){
    	StudentAssessmentHelper objHelper = new StudentAssessmentHelper();   	
    	
    	// set used to store student competency id to roll up total number of assessment attempt
    	// related task: T-324881
    	set<ID>setStudentCompetencyIds = new set<ID>();
    	// used to marke student competency as completed
    	map<ID,Student_Assessment__c>mapStudentCompetencyWithStudentAssessment = new map<ID,Student_Assessment__c>();
    	for(Student_Assessment__c sa: newStudentAssessment){
    		if(setCBLRecordTypes.contains(sa.RecordTypeId) && sa.Student_Competency__c != null){
    			setStudentCompetencyIds.add(sa.Student_Competency__c);
    			mapStudentCompetencyWithStudentAssessment.put(sa.Student_Competency__c,sa);
    		}
    	}
    	if(!setStudentCompetencyIds.isEmpty()){
    		objHelper.rollUpNumberOfStudentAssessmentAttemptOnStudentCompetency(setStudentCompetencyIds);
    	}
    	if(!mapStudentCompetencyWithStudentAssessment.isEmpty()){
    		objHelper.markParentStudentCompetencyAsCompleted(mapStudentCompetencyWithStudentAssessment);
    	}
    }

    public void onAfterUpdate(list<Student_Assessment__c> newStudentAssessment,map<ID,Student_Assessment__c>oldMap){
    	StudentAssessmentHelper objHelper = new StudentAssessmentHelper();    	
    	// set used to store student competency id to roll up total number of assessment attempt
    	// related task: T-324881
    	set<ID>setStudentCompetencyIds = new set<ID>();
    	// used to marke student competency as completed
    	map<ID,Student_Assessment__c>mapStudentCompetencyWithStudentAssessment = new map<ID,Student_Assessment__c>();
    	for(Student_Assessment__c sa: newStudentAssessment){
    		Student_Assessment__c oldSa = oldMap.get(sa.ID);
    		if(setCBLRecordTypes.contains(sa.RecordTypeId) && sa.Student_Competency__c != null){
    			setStudentCompetencyIds.add(sa.Student_Competency__c);
    		    if( sa.Status__c != oldSa.Status__c  || sa.Grade__c != oldsa.Grade__c){
    		    	mapStudentCompetencyWithStudentAssessment.put(sa.Student_Competency__c,sa);
    		    }    			
    		}
    	}
    	system.debug('setStudentCompetencyIds::::::::::::;'+setStudentCompetencyIds);
    	if(!setStudentCompetencyIds.isEmpty()){
    		objHelper.rollUpNumberOfStudentAssessmentAttemptOnStudentCompetency(setStudentCompetencyIds);
    	}
    	if(!mapStudentCompetencyWithStudentAssessment.isEmpty()){
    		objHelper.markParentStudentCompetencyAsCompleted(mapStudentCompetencyWithStudentAssessment);
    	}
    }

    public void onAfterDelete(list<Student_Assessment__c> newStudentAssessment){
    	StudentAssessmentHelper objHelper = new StudentAssessmentHelper();    	
    	// set used to store student competency id to roll up total number of assessment attempt
    	// related task: T-324881
    	set<ID>setStudentCompetencyIds = new set<ID>();
    	for(Student_Assessment__c sa: newStudentAssessment){
    		if(setCBLRecordTypes.contains(sa.RecordTypeId) && sa.Student_Competency__c != null){
    			setStudentCompetencyIds.add(sa.Student_Competency__c);
    		}
    	}
    	if(!setStudentCompetencyIds.isEmpty()){
    		objHelper.rollUpNumberOfStudentAssessmentAttemptOnStudentCompetency(setStudentCompetencyIds);
    		objHelper.changeParentStudentCompetencyStatusOnChildAssessmentDelete(setStudentCompetencyIds);
    	}
    }

    public void onAfterUnDelete(list<Student_Assessment__c> newStudentAssessment){
    	StudentAssessmentHelper objHelper = new StudentAssessmentHelper();    	
    	// set used to store student competency id to roll up total number of assessment attempt
    	// related task: T-324881
    	set<ID>setStudentCompetencyIds = new set<ID>();
    	// used to marke student competency as completed
    	map<ID,Student_Assessment__c>mapStudentCompetencyWithStudentAssessment = new map<ID,Student_Assessment__c>();
    	system.debug('setCBLRecordTypes::::11111::::::::::;;'+setCBLRecordTypes);
    	system.debug('newStudentAssessment::::11111::::::::::;;'+newStudentAssessment);
    	system.debug('newStudentAssessment::::22222::::::::::;;'+trigger.new);
    	for(Student_Assessment__c sa: newStudentAssessment){
    		system.debug('sa.RecordTypeId::::11111::::::::::;;'+sa.RecordTypeId);
    		system.debug('sa.Student_Competency__c::::11111::::::::::;;'+sa.Student_Competency__c);
    		if(setCBLRecordTypes.contains(sa.RecordTypeId) && sa.Student_Competency__c != null){
    			setStudentCompetencyIds.add(sa.Student_Competency__c);
    			mapStudentCompetencyWithStudentAssessment.put(sa.Student_Competency__c,sa);
    		}
    	}
    	if(!setStudentCompetencyIds.isEmpty()){
    		objHelper.rollUpNumberOfStudentAssessmentAttemptOnStudentCompetency(setStudentCompetencyIds);
    	}
    	if(!mapStudentCompetencyWithStudentAssessment.isEmpty()){
    		objHelper.markParentStudentCompetencyAsCompleted(mapStudentCompetencyWithStudentAssessment);
    	}
    }

}