/*******************************************************************
Name  : ProgramStartDateTriggerHandler
Author: Vinod Kumar (Appirio)
Date  : November 7, 2014
Description: Helper class for the trigger ProgramStartDateTrigger
Related task: T-331867
*************************************************************************/
public with sharing class ProgramStartDateTriggerHandler {
	private set<ID> setCBLRecordTypes;	
	private boolean isExecuting = false;
	private integer batchSize = 0;
	    
	public ProgramStartDateTriggerHandler( boolean isExecuting, integer size ) {
		isExecuting = isExecuting;
		batchSize = size;
		setCBLRecordTypes = Utility.getRecordTypeFromCBLCustomSetting(Program_Start_Date__c.sObjectType.getDescribe());
	}

	public void onBeforeInsert(list<Program_Start_Date__c > newProgramStartDate){
		
		// populate the RT, Name fields
		ProgramStartDateHelper objHelper = new ProgramStartDateHelper();
		list<Program_Start_Date__c>selectedProgramStartDate = new list<Program_Start_Date__c >();
		for(Program_Start_Date__c psDate: newProgramStartDate){     
      //set RecordType based on related Program
      if(psDate.Program__c!=null){
        SObjectType objTypeForInstitution = Schema.getGlobalDescribe().get('Program_Start_Date__c');
        psDate.RecordTypeId = objTypeForInstitution.getDescribe().getRecordTypeinfosByName().get( psDate.Program_Institution__c ).getRecordTypeId();
      }

			if(setCBLRecordTypes.contains(psDate.RecordTypeId) && psDate.Start_Date__c != null){
				selectedProgramStartDate.add(psDate);
			}
		}
		if(!selectedProgramStartDate.isEmpty()){
			objHelper.calculateName(selectedProgramStartDate);
		}
	}
	/*******************************************************************
	Before update method
	Related task: T-331867
	********************************************************************/
	public void onBeforeUpdate(list<Program_Start_Date__c > newProgramStartDate,map<ID,Program_Start_Date__c> oldMap){
		// populate the name field
		ProgramStartDateHelper objHelper = new ProgramStartDateHelper();
		list<Program_Start_Date__c>selectedProgramStartDate = new list<Program_Start_Date__c >();
		for(Program_Start_Date__c psDate: newProgramStartDate){
			if(setCBLRecordTypes.contains(psDate.RecordTypeId) && psDate.Start_Date__c != null && psDate.Start_Date__c != oldMap.get(psDate.id).Start_Date__c){
				selectedProgramStartDate.add(psDate);
			}
		}
		if(!selectedProgramStartDate.isEmpty()){
			objHelper.calculateName(selectedProgramStartDate);
		}
	}
}