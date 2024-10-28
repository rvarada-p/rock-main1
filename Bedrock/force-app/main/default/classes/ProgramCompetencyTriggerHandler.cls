/*******************************************************************
Name  : ProgramCompetencyTriggerHandler
Author: Vinod (Appirio)
Date  : September 23, 2014
Description: handler class for the trigger ProgramCompetencyTriggerHandler
*************************************************************************/
    
public with sharing class ProgramCompetencyTriggerHandler{
    private set<ID> setCBLRecordTypes;
    private boolean isExecuting = false;
    private integer batchSize = 0;
    
    public ProgramCompetencyTriggerHandler(boolean isExecuting, integer size){
        isExecuting = isExecuting;
        batchSize = size;
        setCBLRecordTypes = Utility.getRecordTypeFromCBLCustomSetting(Program_Competency__c.sObjectType.getDescribe());
    }

    public void onBeforeInsert(list<Program_Competency__c > newProgramCompetency){
        //set RecordType based on related Program
        for(Program_Competency__c pCom: newProgramCompetency){
          if(pCom.Product__c!=null){
            SObjectType objTypeForInstitution = Schema.getGlobalDescribe().get('Program_Competency__c');
            pCom.RecordTypeId = objTypeForInstitution.getDescribe().getRecordTypeinfosByName().get( pCom.Program_Institution__c ).getRecordTypeId();
          }
        }

        // validate if Program Competency with same ProgramExpertise and Competency is already exist
        // related task: T-323386
        set<ID>setProgramExpertiseIds = new set<ID>();
        set<ID>setCompetencyIds = new set<ID>();
        list<Program_Competency__c > selectedProgramCompetency = new list<Program_Competency__c >();
        // verify the selected patrent Program Expertise is "Available for Try Before You Buy"
        // if the Program Competency is marked As "Available for Try Before You Buy"
        // related task: T-337183
        set<ID>setPExpertiseIdsToCheckTBYB = new set<ID>();
        list<Program_Competency__c>lstProgramCompetency = new list<Program_Competency__c>();
        
        for(Program_Competency__c pCom:newProgramCompetency){
            if(setCBLRecordTypes.contains(pCom.RecordTypeId) && pCom.Program_Expertise__c != null ){
                setProgramExpertiseIds.add(pCom.Program_Expertise__c);
                setCompetencyIds.add(pCom.Competency__c);
                selectedProgramCompetency.add(pCom);
                // T-337183
                if(pCom.IsTryBeforeYouBuy__c){
                	setPExpertiseIdsToCheckTBYB.add(pCom.Program_Expertise__c);
                	lstProgramCompetency.add(pCom);
                }
            }
            
        }
        ProgramCompetencyHelper objHelper = new ProgramCompetencyHelper();
        // validate newly created Program Competency 
        if(!setProgramExpertiseIds.isEmpty()){
            objHelper.validateIfProgramCompetencyIsAlreadyExist(selectedProgramCompetency,setProgramExpertiseIds,setCompetencyIds);
            //objHelper.verifyProgramCompetencyUniqueness(selectedProgramCompetency);
        }
        //  T-337183
        if(!setPExpertiseIdsToCheckTBYB.isEmpty()){
            objHelper.verifyProgramExpertiseISAvailableTBYB(lstProgramCompetency,setPExpertiseIdsToCheckTBYB);
        }
    }

    public void onAfterInsert(list<Program_Competency__c > newProgramCompetency){
        // set used to update Number_of_Competencies__c of the selected ProgramExpertise
        // related task:T-321239
        set<ID>setProgramExpertiseIds = new set<ID>();
        for(Program_Competency__c pCom:newProgramCompetency){
            if(setCBLRecordTypes.contains(pCom.RecordTypeId) && pCom.Program_Expertise__c != null ){
                setProgramExpertiseIds.add(pCom.Program_Expertise__c);
            }
        }
        ProgramCompetencyHelper objHelper = new ProgramCompetencyHelper();
        // update Number_of_Competencies__c of the selected ProgramExpertise
        if(!setProgramExpertiseIds.isEmpty()){
            objHelper.updateProgramExpertiseNumberOfCompetencies(setProgramExpertiseIds);
        }
    }

    public void onBeforeUpdate(list<Program_Competency__c > newProgramCompetency,map<ID,Program_Competency__c> oldMap){
        // validate if Program Competency with same ProgramExpertise and Competency is already exist
        // related task: T-323386
        set<ID>setProgramExpertiseIds = new set<ID>();
        set<ID>setCompetencyIds = new set<ID>();
        list<Program_Competency__c > selectedProgramCompetency = new list<Program_Competency__c >();
        list<Program_Competency__c > learningOrderUniqueness = new list<Program_Competency__c >();
		// verify the selected patrent Program Expertise is "Available for Try Before You Buy"
        // if the Program Competency is marked As "Available for Try Before You Buy"
        // related task: T-337183
        set<ID>setPExpertiseIdsToCheckTBYB = new set<ID>();
        list<Program_Competency__c>lstProgramCompetency = new list<Program_Competency__c>();
		
        for(Program_Competency__c pCom:newProgramCompetency){
            if(setCBLRecordTypes.contains(pCom.RecordTypeId) && pCom.Program_Expertise__c != null){
                if(pCom.Program_Expertise__c != oldMap.get(pCom.ID).Program_Expertise__c){
                    setProgramExpertiseIds.add(pCom.Program_Expertise__c);
                    setCompetencyIds.add(pCom.Competency__c);
                    selectedProgramCompetency.add(pCom);
                }
                learningOrderUniqueness.add(pCom);
                // T-337183
                if(pCom.IsTryBeforeYouBuy__c && oldMap.get(pCom.ID).IsTryBeforeYouBuy__c == false){
                	setPExpertiseIdsToCheckTBYB.add(pCom.Program_Expertise__c);
                	lstProgramCompetency.add(pCom);
                }
            }
        }
        ProgramCompetencyHelper objHelper = new ProgramCompetencyHelper();
        // validate newly created Program Competency 
        if(!setProgramExpertiseIds.isEmpty()){
            objHelper.validateIfProgramCompetencyIsAlreadyExist(selectedProgramCompetency,setProgramExpertiseIds,setCompetencyIds);
        }
        if(!learningOrderUniqueness.isEmpty()){
            //objHelper.verifyProgramCompetencyUniqueness(learningOrderUniqueness);
        }
        //  T-337183
        if(!setPExpertiseIdsToCheckTBYB.isEmpty()){
            objHelper.verifyProgramExpertiseISAvailableTBYB(lstProgramCompetency,setPExpertiseIdsToCheckTBYB);
        }
    }

    public void onAfterUpdate(list<Program_Competency__c > newProgramCompetency,map<ID,Program_Competency__c> oldMap){
        // set used to update Number_of_Competencies__c of the selected ProgramExpertise
        // related task:T-321239
        set<ID>setProgramExpertiseIds = new set<ID>();
        for(Program_Competency__c pCom:newProgramCompetency){
            Program_Competency__c oldComp = oldMap.get(pCom.id);
            // check Program_Expertise__c is changed
            system.debug('pCom.Program_Expertise__c:::'+pCom.Program_Expertise__c);
            system.debug('oldComp.Program_Expertise__c:::'+oldComp.Program_Expertise__c);
            if(setCBLRecordTypes.contains(pCom.RecordTypeId) && pCom.Program_Expertise__c != oldComp.Program_Expertise__c){
                //  Program_Expertise__c is changed with new value and old value is null
                if(pCom.Program_Expertise__c != null && oldComp.Program_Expertise__c == null){
                    setProgramExpertiseIds.add(pCom.Program_Expertise__c);
                }else if(pCom.Program_Expertise__c == null && oldComp.Program_Expertise__c != null){
                    // Program_Expertise__c is removed
                    setProgramExpertiseIds.add(oldComp.Program_Expertise__c);
                }else if(pCom.Program_Expertise__c != null && oldComp.Program_Expertise__c != null){
                    // Program_Expertise__c is changed with new value and old value is not null
                    setProgramExpertiseIds.add(pCom.Program_Expertise__c);
                    setProgramExpertiseIds.add(oldComp.Program_Expertise__c);                   
                }
            }
        }
        system.debug('setProgramExpertiseIds:::'+setProgramExpertiseIds);
        ProgramCompetencyHelper objHelper = new ProgramCompetencyHelper();
        // update Number_of_Competencies__c of the selected ProgramExpertise
        if(!setProgramExpertiseIds.isEmpty()){
            objHelper.updateProgramExpertiseNumberOfCompetencies(setProgramExpertiseIds);
        }
    }

    public void onAfterDelete(list<Program_Competency__c > newProgramCompetency){
        // set used to update Number_of_Competencies__c of the selected ProgramExpertise
        // related task:T-321239
        set<ID>setProgramExpertiseIds = new set<ID>();
        for(Program_Competency__c pCom:newProgramCompetency){
            if(setCBLRecordTypes.contains(pCom.RecordTypeId) && pCom.Program_Expertise__c != null ){
                setProgramExpertiseIds.add(pCom.Program_Expertise__c);
            }
        }
        ProgramCompetencyHelper objHelper = new ProgramCompetencyHelper();
        // update Number_of_Competencies__c of the selected ProgramExpertise
        if(!setProgramExpertiseIds.isEmpty()){
            objHelper.updateProgramExpertiseNumberOfCompetencies(setProgramExpertiseIds);
            ProgramExpertiseHelper handler = new ProgramExpertiseHelper();
            //Trigger to populate rogram Expertise's Total_hours_to_Complete_All_Competencies__c
            //Related task: T-320974
            handler.rollUpProgramExpertiseTotalHours(setProgramExpertiseIds);
        }
    }

    public void onAfterUnDelete(list<Program_Competency__c > newProgramCompetency){
        // set used to update Number_of_Competencies__c of the selected ProgramExpertise
        // related task:T-321239
        set<ID>setProgramExpertiseIds = new set<ID>();
        for(Program_Competency__c pCom:newProgramCompetency){
            if(setCBLRecordTypes.contains(pCom.RecordTypeId) && pCom.Program_Expertise__c != null ){
                setProgramExpertiseIds.add(pCom.Program_Expertise__c);
            }
        }
        ProgramCompetencyHelper objHelper = new ProgramCompetencyHelper();
        // update Number_of_Competencies__c of the selected ProgramExpertise
        if(!setProgramExpertiseIds.isEmpty()){
            objHelper.updateProgramExpertiseNumberOfCompetencies(setProgramExpertiseIds);            
            ProgramExpertiseHelper handler = new ProgramExpertiseHelper();
            //Trigger to populate rogram Expertise's Total_hours_to_Complete_All_Competencies__c
            //Related task: T-320974
            handler.rollUpProgramExpertiseTotalHours(setProgramExpertiseIds);
        }
    }
}