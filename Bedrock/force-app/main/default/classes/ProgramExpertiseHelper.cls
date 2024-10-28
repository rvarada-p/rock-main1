/*******************************************************************
Name  : ProgramExpertiseHelper
Author: Virendra (Appirio)
Date  : September 18, 2014
Description: Helper  class for the  Program Expertise Process
*************************************************************************/
public with sharing class ProgramExpertiseHelper {
	
	//Constructor
	public ProgramExpertiseHelper(){
		
	}
	
	public void buildProgramAoECompsStructure(list<Program_Expertise__c > newProgramExpertise){
  	Set<Program_Expertise__c>	buildProgramAoE = new Set<Program_Expertise__c>();
  	Set<id> programExpertiseProducts = new Set<id>(); 
  	Set<id> programAreaofExpertise = new Set<id>(); 
  	
    for(Program_Expertise__c pExpertise:newProgramExpertise){
      if(pExpertise.Program__c != null && pExpertise.Area_of_Expertise__c !=null){
        buildProgramAoE.add(pExpertise);
        programAreaofExpertise.add(pExpertise.Area_of_Expertise__c);
        programExpertiseProducts.add(pExpertise.Program__c);
      }
    }
  	
  	if(!buildProgramAoE.isEmpty()){
  		//Get Record Types Infor for Products 
  		set<String> productRecordTypeNames = new set<String>();
  		//Get all record type name of associated Product to find out the Competency Expertise records 
  		for(Product2  product: [select id,recordtypeId,RecordType.Name from Product2 where id in:programExpertiseProducts]){
			  productRecordTypeNames.add(product.RecordType.Name);
		  }
		
  		/*
  		  Then find all the Competency_Expertise__c records associated to the Program_Expertise__r.Area_of_Expertise__c 
  		  where the Competency_Expertise__r.RecordTypeName equals the Product2.RecordTypeName OR the 
  		  Competency_Expertise__r.RecordTypeName equals "Laureate"
  		*/
  	  Map<Id,List<Competency_Expertise__c>>  matchedCompentencyExpertise = new Map<Id,List<Competency_Expertise__c>>();
  		for(Competency_Expertise__c compExpertise:[Select Id,RecordTypeId,RecordType.Name, Name, Competency__c, Area_of_Expertise__c
  		                                           From Competency_Expertise__c
  		                                           where Area_of_Expertise__c in:programAreaofExpertise
  		                                           and (RecordType.Name in:productRecordTypeNames or RecordType.Name = 'Laureate')]){
  		                                           	
        if(!matchedCompentencyExpertise.containsKey(compExpertise.Area_of_Expertise__c)){
        	 matchedCompentencyExpertise.put(compExpertise.Area_of_Expertise__c,new List<Competency_Expertise__c>());
        }        

        matchedCompentencyExpertise.get(compExpertise.Area_of_Expertise__c).add(compExpertise);                           	
  		}
  		
  		/*
  		 With the found set, create a set of Program_Competency__c records. 
  		 Each Program_Competency__c record should have the following fields populated:
  		*/
  		if(!matchedCompentencyExpertise.isEmpty()){
  			list<Program_Competency__c> newProgramCompetency = new list<Program_Competency__c>();
  		
  			for(Program_Expertise__c proExpertise:buildProgramAoE){
  				for(Competency_Expertise__c compExpertise:matchedCompentencyExpertise.get(proExpertise.Area_of_Expertise__c)){
  					system.debug('compExpertise.RecordType.Name:::::::::::'+compExpertise.RecordType.Name);
  					newProgramCompetency.add(new Program_Competency__c(
  				                         Competency__c = compExpertise.Competency__c,
  										 Product__c = proExpertise.Program__c,
  										 Program_Expertise__c = proExpertise.id,
  									     RecordTypeId =Schema.SObjectType.Program_Competency__c.RecordTypeInfosByName.get(compExpertise.RecordType.Name).RecordTypeId));
  				}
  			}			
  			// Create New records if List is not empty
  			if(!newProgramCompetency.isEmpty()){
  				insert newProgramCompetency;
  			}
  		}		
  	}	
  	
  }
  
  //Method to publish the Competency Template and Competency Shell to BrightSpace LMS
  public void publishCompToLMS(list<Competency__c> selectedCompetency) {
	for(Competency__c comp: selectedCompetency) {
		Decimal programId;
		Decimal aoeId;
		if(comp.Program_LMS_ID__c!=null && comp.Program_LMS_ID__c!='') {
			programId = Decimal.valueOf(comp.Program_LMS_ID__c);
		}
		if(comp.AoE_LMS_ID__c!=null && comp.AoE_LMS_ID__c!='') {
			aoeId = Decimal.valueOf(comp.AoE_LMS_ID__c);
		}
		if(programId!=null && aoeId!=null) {	
			BrightSpaceCalls.createCompetencyTemplateAndShell(comp.Id, comp.Name, comp.Code__c.trim(), new list<Decimal>{programId, aoeId});
		} 
	}	  	 
  }
  
  /*******************************************************************************************
  Method to calculate Program Expertise's Total_hours_to_Complete_All_Competencies__c
  Related task: T-320974
  Created date: 26 September 2014
  *******************************************************************************************/
	public void rollUpProgramExpertiseTotalHoursToCompleteAllCompetencies(list<Competency__c> selectedCompetency){
		// get all
		// first get all program expertise
		set<ID>setProgramExpertise = new set<ID>();
		for(Program_Competency__c pComp:[Select Program_Expertise__c, Id from Program_Competency__c
										where Competency__c in:selectedCompetency and  Program_Expertise__c != null]){
			setProgramExpertise.add(pComp.Program_Expertise__c);								
		}
		if(!setProgramExpertise.isEmpty()){
			rollUpProgramExpertiseTotalHours(setProgramExpertise);
		}
	}
	public void rollUpProgramExpertiseTotalHours(set<ID>setProgramExpertise){
		System.debug('In rollupExpertiseTotalHours');
		map<ID,list<Program_Competency__c>> mapProgramExpertiseWithProgramCompetency = new map<ID,list<Program_Competency__c>>();
		Date dtToday = Date.today();
		for(Program_Competency__c pComp:[Select Program_Expertise__c, Product__r.Effective_To_Date__c, Product__c, Id, 
										Competency__r.Average_Time_in_hours__c, Competency__c From Program_Competency__c
										where Program_Expertise__c in : setProgramExpertise
										and Product__r.Effective_To_Date__c >: dtToday ]){
			//
			if(!mapProgramExpertiseWithProgramCompetency.containsKey(pComp.Program_Expertise__c)){
				mapProgramExpertiseWithProgramCompetency.put(pComp.Program_Expertise__c, new list<Program_Competency__c>());
			}
			mapProgramExpertiseWithProgramCompetency.get(pComp.Program_Expertise__c).add(pComp);
		}
		system.debug('mapProgramExpertiseWithProgramCompetency:::'+mapProgramExpertiseWithProgramCompetency);
		system.debug('mapProgramExpertiseWithProgramCompetency size:::'+mapProgramExpertiseWithProgramCompetency.size());
		if(!mapProgramExpertiseWithProgramCompetency.isEmpty()){
			list<Program_Expertise__c> lstProgramExpertise = new list<Program_Expertise__c>();
			for(ID programExpertiseId: mapProgramExpertiseWithProgramCompetency.keySet()){
				//
				double competencyAverageTimeInHours = 0;
				for(Program_Competency__c pComp:mapProgramExpertiseWithProgramCompetency.get(programExpertiseId)){
					if(pComp.Competency__r.Average_Time_in_hours__c !=  null){
						competencyAverageTimeInHours+= pComp.Competency__r.Average_Time_in_hours__c;
					}
				}
				// populate Program Expertise's Total_hours_to_Complete_All_Competencies__c
				if(competencyAverageTimeInHours != 0){
					Program_Expertise__c pExpert = new Program_Expertise__c(ID= programExpertiseId,Total_hours_to_Complete_All_Competencies__c = competencyAverageTimeInHours);
					lstProgramExpertise.add(pExpert);
				}
			}
			if(!lstProgramExpertise.isEmpty()){
				update lstProgramExpertise;
			}
		}
	}
	/******************************************************************************
	verify learning order unique within program  set
	Related task: T-325643
	Create By : Bryan Leboff
	*******************************************************************************/
	public void verifyProgramExpertiseUniqueness(List<Program_Expertise__c> programExpertises){

		Set<Id> programIds = new Set<Id>();
		for(Program_Expertise__c programExpertise : programExpertises ){
			programIds.add(programExpertise.program__c);
		}

		//get all of the program expertises for their programs
		Map<Id, Product2> programMap = new Map<Id, Product2>([
				select id, (select id, learning_order__c from Program_Expertise__r)
				from Product2
				where id in: programIds
			]);
		
		Program_Expertise__c programExpertise = (Program_Expertise__c) Utility.unique(programExpertises, programMap, 'learning_order__c', 'program__c', 'Program_Expertise__r');

		if(programExpertise != null){
			programExpertise.Learning_Order__c.addError(Label.Program_Expertise_Duplicate_Learning_Order_Error);
		}

	}
	/******************************************************************************
	Mark all child Program Competency IsTryBeforeYouBuy__c as false if the Program_Expertise__c.Program_Expertise__c is false
	Related task: T-337183
	Create By : Vinod Kumar
	*******************************************************************************/
	public void removeChildProgramCompetencyTBYB(set<id> programExpertisesId){
		list<Program_Competency__c> lstProgramCompetency = new list<Program_Competency__c>();
		for(Program_Competency__c pComp:[select id,IsTryBeforeYouBuy__c 
										from Program_Competency__c 
										where Program_Expertise__c in: programExpertisesId
										and IsTryBeforeYouBuy__c = true]){
			pComp.IsTryBeforeYouBuy__c = false;
			lstProgramCompetency.add(pComp);
		}
		if(!lstProgramCompetency.isEmpty()){
			update lstProgramCompetency;
		}
	}	
}