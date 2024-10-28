/*******************************************************************
Name  : ProgramCompetencyHelper
Author: Vinod (Appirio)
Date  : September 23, 2014
Description: helper class for the object Program_Competency__c
*************************************************************************/
public with sharing class ProgramCompetencyHelper{
    /*******************************************************************
    Method to populate Number_of_Competencies__c of the selected ProgramExpertise
    Related task: T-321239
    ********************************************************************/
    public void updateProgramExpertiseNumberOfCompetencies(set<ID> setProgramExpertiseIds){
        map<ID,decimal> mapProgramExpertiseWithNumberOfCompetencies = new map<ID,decimal>();
        // get all child Program Competency for the selected ProgramExpertise
        for(Program_Competency__c pCom:[Select id,Program_Expertise__c from Program_Competency__c where Program_Expertise__c in: setProgramExpertiseIds]){
            if(!mapProgramExpertiseWithNumberOfCompetencies.containsKey(pCom.Program_Expertise__c)){
                mapProgramExpertiseWithNumberOfCompetencies.put(pCom.Program_Expertise__c,0);
            }
            decimal totalCompetency = mapProgramExpertiseWithNumberOfCompetencies.get(pCom.Program_Expertise__c);
            totalCompetency++;
            mapProgramExpertiseWithNumberOfCompetencies.put(pCom.Program_Expertise__c,totalCompetency);
        }
        list<Program_Expertise__c> lstProgramExpertise = new list<Program_Expertise__c>();
        for(ID programExpertiseID: setProgramExpertiseIds){
            if(mapProgramExpertiseWithNumberOfCompetencies.ContainsKey(programExpertiseID)){
                decimal totalCompetency = mapProgramExpertiseWithNumberOfCompetencies.get(programExpertiseID);
                lstProgramExpertise.add(new Program_Expertise__c(ID = programExpertiseID,Number_of_Competencies__c = totalCompetency));
            }else{
                // no Program_Competency__c
                lstProgramExpertise.add(new Program_Expertise__c(ID = programExpertiseID,Number_of_Competencies__c = null));
            }
        }
        if(!lstProgramExpertise.isEmpty()){
            update lstProgramExpertise;
        }
    }
    /*******************************************************************
    Method to validate if Program Competency from being created if its related Program Expertise 
    already has a child Program Competency with same Competency Id
    Related task: T-323386
    ********************************************************************/
    public void validateIfProgramCompetencyIsAlreadyExist(list<Program_Competency__c> selectedProgramCompetency,set<ID> setProgramExpertiseIds,set<ID> setCompetencyIds){
        // get all existing Program Competency with same ProgramExpertise and Competency as the newly created Program_Competency__c
        map<string,Program_Competency__c> mapProgramExpertiseAndCompetencyIDWithProgramCompetency = new map<string,Program_Competency__c>();
        for(Program_Competency__c pComp:[Select ID,Program_Expertise__c, Competency__c 
                                         From Program_Competency__c
                                         where Program_Expertise__c in: setProgramExpertiseIds and Competency__c in: setCompetencyIds]){
            string strKey = pComp.Program_Expertise__c + '$' + pComp.Competency__c;
            mapProgramExpertiseAndCompetencyIDWithProgramCompetency.put(strKey,pComp);
        }
        // validate the newly created Program_Competency__c
        for(Program_Competency__c pComp: selectedProgramCompetency){
            string strKey = pComp.Program_Expertise__c + '$' + pComp.Competency__c;
            if(mapProgramExpertiseAndCompetencyIDWithProgramCompetency.containsKey(strKey)){
                // competency already exist with same ProgramExpertise and Competency
                pComp.addError('A Program Competency already exists for this Program Expertise.');
            }
        }
    }
    
    /******************************************************************************
    Check if a Program Competency is marked as "Available for Try Before You Buy" 
    and the related Program Expertise is NOT marked "Available for Try Before You Buy".
    Then through an error
    Related task: T-337183
    Create By : Vinod Kumar
    *******************************************************************************/
    public void verifyProgramExpertiseISAvailableTBYB(list<Program_Competency__c> programCompetencies, set<ID> setProgramExpertiseID){
    	// check the selected patrent Program Expertise is "Available for Try Before You Buy" 
    	set<ID> setTBYBProgramExpertise = new set<ID>();
    	for(Program_Expertise__c pex:[select id from Program_Expertise__c where id in:setProgramExpertiseID and IsTryBeforeYouBuy__c = true]){
    		setTBYBProgramExpertise.add(pex.id);
    	}
    	for(Program_Competency__c pComp: programCompetencies){
    		if(!setTBYBProgramExpertise.contains(pComp.Program_Expertise__c)){
    			// parent Program Expertise is NOT marked "Available for Try Before You Buy".
    			pComp.addError('Parent Program Expertise is is NOT marked as "Available for Try Before You Buy"');
    		}
    	}
    }
}