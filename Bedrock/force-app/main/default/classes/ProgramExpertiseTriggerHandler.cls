/*******************************************************************
Name  : ProgramExpertiseTriggerHandler
Author: Virendra (Appirio)
Date  : September 17, 2014
Description: Handler class for the Trigger ProgramExpertiseTrigger
*************************************************************************/
public with sharing class ProgramExpertiseTriggerHandler {
	
	private set<ID> setCBLRecordTypes;
    private boolean isExecuting = false;
    private integer batchSize = 0;
    private ProgramExpertiseHelper programExptsHelper;
    public ProgramExpertiseTriggerHandler(boolean isExecuting, integer size){
        programExptsHelper = new ProgramExpertiseHelper();
        isExecuting = isExecuting;
        batchSize = size;
        setCBLRecordTypes = Utility.getRecordTypeFromCBLCustomSetting(Program_Expertise__c.sObjectType.getDescribe());
    }
    
    public void onBeforeInsert(list<Program_Expertise__c > newProgramExpertise){
        //set RecordType based on related Program
        for(Program_Expertise__c programExpertise: newProgramExpertise){
          if(programExpertise.Program__c!=null){
            SObjectType objTypeForInstitution = Schema.getGlobalDescribe().get('Program_Expertise__c');
            programExpertise.RecordTypeId = objTypeForInstitution.getDescribe().getRecordTypeinfosByName().get( programExpertise.Program_Institution__c ).getRecordTypeId();
          }
        }

        List<Program_Expertise__c> checkUniqueness = new List<Program_Expertise__c>();
        for(Program_Expertise__c pe : newProgramExpertise){
            if(setCBLRecordTypes.contains(pe.recordtypeid)){
                checkUniqueness.add(pe);
            }
        }
        programExptsHelper.verifyProgramExpertiseUniqueness(checkUniqueness);
    }

    public void onBeforeUpdate(list<Program_Expertise__c > newProgramExpertises, map<ID,Program_Expertise__c> oldProgramExpertises){
        List<Program_Expertise__c> learningOrderUpdates = new List<Program_Expertise__c>();
        for(Program_Expertise__c programExpertise : newProgramExpertises){
            Program_Expertise__c oldProgramExpertise = oldProgramExpertises.get(programExpertise.id);
            if(setCBLRecordTypes.contains(programExpertise.recordtypeid) &&
                programExpertise.Learning_Order__c <> null &&
                programExpertise.Learning_Order__c <> oldProgramExpertise.learning_order__c)
            {
                learningOrderUpdates.add(programExpertise);
            }
        }
        programExptsHelper.verifyProgramExpertiseUniqueness(learningOrderUpdates);
    }
    public void onAfterInsert(list<Program_Expertise__c > newProgramExpertise,map<ID,Program_Expertise__c> oldProgramExpertise){    	
    	// Execute method for Build Program AOE Comp Structure
    	List<Program_Expertise__c> selectedPExper = new List<Program_Expertise__c>();
        for(Program_Expertise__c programExpertise : newProgramExpertise){
            if(setCBLRecordTypes.contains(programExpertise.recordtypeid)){
                selectedPExper.add(programExpertise);
            }
        }
    	programExptsHelper.buildProgramAoECompsStructure(selectedPExper);
    }
    public void onAfterUpdate(list<Program_Expertise__c > newProgramExpertises, map<ID,Program_Expertise__c> oldProgramExpertises){
    	// Mark all child Program Competency IsTryBeforeYouBuy__c as false if the Program_Expertise__c.Program_Expertise__c is false
		//Related task: T-337183
        set<id> setProgramExpertiseID = new set<id>();
        for(Program_Expertise__c programExpertise : newProgramExpertises){
            if(setCBLRecordTypes.contains(programExpertise.recordtypeid) &&
                programExpertise.IsTryBeforeYouBuy__c == false){
                setProgramExpertiseID.add(programExpertise.ID);
            }
        }
        //Related task: T-337183
        if(!setProgramExpertiseID.isEmpty()){
        	programExptsHelper.removeChildProgramCompetencyTBYB(setProgramExpertiseID);
        }
    }
  
}