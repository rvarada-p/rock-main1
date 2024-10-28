/*******************************************************************
Name  : ProgramReconciliation
Author: Sarah - Laureate
Date  : June 23, 2016
Description: Apex code logic for program Reconciliation used for
             COP and COS

Revision History 
Horacio Sanchez - 11/03/2020 - Prod Defect 30210: Duplicate Student Expertise when COS is processed; duplicates are now not created
*************************************************************************/
public with sharing class ProgramReconciliation {


    //Runs the Reconcilation process for COP for TBYB competencies
    public void reconcileCOPTbybComps(List<BrandProfilesTriggerHandler.BrandProfileHistory> bpHistory) {
    	System.debug('In reconcileCOPTbybComps');
    	
		list<String> oldProgramIDs = new List<String>();
		list<String> newProgramIDs = new list<String>(); 
		list<Id> contactIds = new list<Id>();
		
		//loop through the BrandProfileHistory and get the old and new Student Competencies
		for(BrandProfilesTriggerHandler.BrandProfileHistory bp: bpHistory) {
			oldProgramIDs.add(bp.oldProgramID);	 
			newProgramIDs.add(bp.newProgramID);
			contactIds.add(bp.ContactID);
		}
		 
		System.debug('Old Program IDs ::: ' + oldProgramIDs);
		System.debug('New Program IDs ::: ' + newProgramIDs);
		System.debug('Contact IDs ::: ' + contactIds);
		  
        List<Student_Competency__c> newStudentComps = new List<Student_Competency__c>([SELECT Id, Status__c, IsCompleted__c, Completed_Date__c, Student_Subscription_Achieved_In__c, Number_of_Assessment_Attempts__c, Start_Date__c, Target_Date__c, Flat_World_Knowledge_Link__c, Transferring_Institution__c, CLP_Active__c, Competency_Code__c, PC_FWK_ID__c, FWK_Id__c FROM Student_Competency__c WHERE Program__c IN :newProgramIDs AND Contact__c IN :contactIds AND Available_for_Try_Before_You_Buy__c = true]);
        List<Student_Competency__c> oldStudentComps = new List<Student_Competency__c>([SELECT Id, Status__c, IsCompleted__c, Completed_Date__c, Student_Subscription_Achieved_In__c, Number_of_Assessment_Attempts__c, Start_Date__c, Target_Date__c, Flat_World_Knowledge_Link__c, Transferring_Institution__c, CLP_Active__c, Competency_Code__c, PC_FWK_ID__c, FWK_Id__c FROM Student_Competency__c WHERE Program__c IN :oldProgramIDs AND Contact__c IN :contactIds AND Available_for_Try_Before_You_Buy__c = true]);
	
		reconcileCOPCompetencies(oldStudentComps, newStudentComps);
            	
    }
 
   //Runs the Reconcilation process for COP for TBYB competencies
    public void reconcileCOPNonTbybComps(List<Opportunity> newOpportunities) {
    	System.debug('In reconcileCOPNonTbybComps');
    	    	

		list<String> oldOppIDs = new List<String>();
		list<String> newOppIDs = new list<String>(); 
		
		for(Opportunity opp: newOpportunities) {

			System.debug('Current Opp :: ' + opp);
			if(opp.COP_Related_Opportunity__c!=null) {
				oldOppIDs.add(opp.COP_Related_Opportunity__c);	
			}
			
			newOppIDs.add(opp.Id);
			
		}

		System.debug('Old SP IDs ::: ' + oldOppIDs);
		System.debug('New SP IDs ::: ' + newOppIDs);
		
		//Only run reconcilation if there is an old SP associated with the previous opportunity
		if(!oldOppIDs.isEmpty()) {
	        List<Student_Competency__c> newStudentComps = new List<Student_Competency__c>([SELECT IsCompleted__c, Is_Enrolled__c, Completed_Date__c, Student_Subscription_Achieved_In__c, Number_of_Assessment_Attempts__c, Start_Date__c, Target_Date__c, Flat_World_Knowledge_Link__c, Transferring_Institution__c, Id, Status__c, CLP_Active__c, Competency_Code__c, PC_FWK_ID__c, FWK_Id__c, Name FROM Student_Competency__c WHERE Opportunity__c IN :newOppIDs AND Available_for_Try_Before_You_Buy__c = false]);
	        List<Student_Competency__c> oldStudentComps = new List<Student_Competency__c>([SELECT IsCompleted__c, Is_Enrolled__c, Completed_Date__c, Student_Subscription_Achieved_In__c, Number_of_Assessment_Attempts__c, Start_Date__c, Target_Date__c, Flat_World_Knowledge_Link__c, Transferring_Institution__c, Id, Status__c, CLP_Active__c, Competency_Code__c, PC_FWK_ID__c, FWK_Id__c, Name FROM Student_Competency__c WHERE Opportunity__c IN :oldOppIDs AND Available_for_Try_Before_You_Buy__c = false]);
			
			reconcileCOPCompetencies(oldStudentComps, newStudentComps);
			
		}
    }    
    public void reconcileCOPCompetencies(List<Student_Competency__c> oldStudentComps, List<Student_Competency__c> newStudentComps) {
               
        map<String, Student_Competency__c> mapProgramCompetencies = new map<String,Student_Competency__c>();
        map<String, Student_Competency__c> mapOldProgramCompetencies = new map<String,Student_Competency__c>();
		
        System.debug('New Student Comps ::: ' + newStudentComps + ' Count of Comps ::: ' + newStudentComps.size());
        System.debug('Old Student Comps ::: ' + oldStudentComps + ' Count of Comps ::: ' + oldStudentComps.size());

        //Create a map of the Program Comp FWK ID against corresponding new Student Competencies 
        for(Student_Competency__c sc : newStudentComps) {
                if(!mapProgramCompetencies.containsKey(sc.PC_FWK_ID__c)) {
                    mapProgramCompetencies.put(sc.PC_FWK_ID__c, sc);
                }           
        }
        //Create a map of the Program Comp FWK ID against corresponding old Program Student Competencies
        for(Student_Competency__c sc : oldStudentComps) {
                if(!mapOldProgramCompetencies.containsKey(sc.PC_FWK_ID__c)) {   
                    mapOldProgramCompetencies.put(sc.PC_FWK_ID__c, sc); 
                }
                            
        }       
 				
 		//Create a list of the shared competencies, from old and new program
        list<Student_Competency__c> compsToUpdate = new list<Student_Competency__c>();
        List<Student_Competency_Enrollment__c> studentCompsToEnroll = new List<Student_Competency_Enrollment__c>();
        List<Student_Competency_Enrollment__c> studentCompsToUnEnroll = new List<Student_Competency_Enrollment__c>();
		
		//Create a list of ID's for the old and new Shared Student Competency ID's, used for getting assessment data
		list<Id> newStudentCompetencyIds = new list<Id>();
		list<Id> oldStudentCompetencyIds = new list<Id>();
		
		try {
		
	        for(String fwkId : mapProgramCompetencies.keySet()) {
	            //shared comps, need to move over CLP active and FWK ID from SC level to new program from old
	            if(mapOldProgramCompetencies.containsKey(fwkId)) {
	                Student_Competency__c oldStudentComp = mapOldProgramCompetencies.get(fwkId);
	                Student_Competency__c newStudentComp = mapProgramCompetencies.get(fwkId);
	                newStudentComp.FWK_Id__c = oldStudentComp.FWK_Id__c;
	                newStudentComp.CLP_Active__c = oldStudentComp.CLP_Active__c;
	                newStudentComp.Status__c = oldStudentComp.Status__c;
	                newStudentComp.IsCompleted__c = oldStudentComp.IsCompleted__c;
	                newStudentComp.Description__c = 'Identified as a Shared Competency; existing Student Competency data added to this record';
	                newStudentComp.Completed_Date__c = oldStudentComp.Completed_Date__c!=null?oldStudentComp.Completed_Date__c:null;
	                newStudentComp.Student_Subscription_Achieved_In__c = oldStudentComp.Student_Subscription_Achieved_In__c!=null?oldStudentComp.Student_Subscription_Achieved_In__c:null;
	                newStudentComp.Number_of_Assessment_Attempts__c = oldStudentComp.Number_of_Assessment_Attempts__c!=null?oldStudentComp.Number_of_Assessment_Attempts__c:null;
	                newStudentComp.Start_Date__c = oldStudentComp.Start_Date__c!=null?oldStudentComp.Start_Date__c:null;
	                newStudentComp.Target_Date__c = oldStudentComp.Target_Date__c!=null?oldStudentComp.Target_Date__c:null;
	                newStudentComp.Flat_World_Knowledge_Link__c = oldStudentComp.Flat_World_Knowledge_Link__c!=null? oldStudentComp.Flat_World_Knowledge_Link__c:null;
	                newStudentComp.Transferring_Institution__c = oldStudentComp.Transferring_Institution__c!=null ? oldStudentComp.Transferring_Institution__c:null;
	                newStudentCompetencyIds.add(newStudentComp.Id);
	                compsToUpdate.add(newStudentComp);
	                oldStudentComp.Target_Date__c = null;
	                oldStudentComp.Completed_Date__c = null;
	                oldStudentComp.Start_Date__c = null;
	                oldStudentComp.Transferring_Institution__c = null;
	                oldStudentComp.Flat_World_Knowledge_Link__c = null;
	                oldStudentComp.Student_Subscription_Achieved_In__c = null;
		            oldStudentComp.FWK_Id__c = '';
	                oldStudentComp.CLP_Active__c = false;
	                oldStudentComp.Is_Enrolled__c = false;
	                oldStudentComp.IsCompleted__c = false;
	                oldStudentComp.Status__c = '';
	                oldStudentComp.Description__c = 'Identified as a Shared Competency; Student Competency data moved to the new programs Student Competency record';
	                oldStudentCompetencyIds.add(oldStudentComp.Id);
	                compsToUpdate.add(oldStudentComp); 
	                 				
	            }
	            //non-shared competencies, these should be the new enrollments
	            else {
	                Student_Competency__c newEnrollment = mapProgramCompetencies.get(fwkId);
					Student_Competency_Enrollment__c sce = new Student_Competency_Enrollment__c();
					sce.Student_Competency__c = newEnrollment.Id;
					sce.Action__c = 'Enroll';
					studentCompsToEnroll.add(sce);
	            }
				
	        }
	               
	        
	        System.debug('Shared Comps :: ' + compsToUpdate + ' Size :: ' + compsToUpdate.size());
	        
	        if(compsToUpdate.size() > 0) {
	        	upsert compsToUpdate;
	        }
	
	        //Get all the Student Assessment records for the old Program
	        list<Student_Assessment__c> oldStudentAssessments = new list<Student_Assessment__c>([SELECT Id, Description__c, Program_Competency_FWK_ID__c, Student_Competency__c FROM Student_Assessment__c WHERE Student_Competency__c IN :oldStudentCompetencyIds]);
	        System.debug('Old Student Assessment Records ::: ' + oldStudentAssessments);
	        
	        //Create a map of the Student Assessments for the old Program with the PC FWK ID
	        map<String, list<Student_Assessment__c>> mapAssessmentsWithFWKId = new map<String, list<Student_Assessment__c>>();
	        for(Student_Assessment__c sa : oldStudentAssessments) {
	        	if(mapAssessmentsWithFWKId.containsKey(sa.Program_Competency_FWK_ID__c)) {
					mapAssessmentsWithFWKId.get(sa.Program_Competency_FWK_ID__c).add(sa);					  		
	        	}
	        	else {
	        		mapAssessmentsWithFWKId.put(sa.Program_Competency_FWK_ID__c, new List <Student_Assessment__c> { sa });
	        	}
	        }
	        
	        system.debug('Map of Assessments with FWK ID ' + mapAssessmentsWithFWKId);
	        
	        //List of Student Assessments to be updated
	        list<Student_Assessment__c> studentAssessmentsToUpdate = new list<Student_Assessment__c>();
	        //Now loop through the Assessments maps and assign the Assessments to the new Student Competency
	        for(String fwkId :  mapAssessmentsWithFWKId.keySet()) {
	        	if(mapProgramCompetencies.containsKey(fwkId)) {
	        		Student_Competency__c sc = mapProgramCompetencies.get(fwkId);
	        		for(Student_Assessment__c sa : mapAssessmentsWithFWKId.get(fwkId)) {
	        			Student_Assessment__c assessment = new Student_Assessment__c (Id = sa.Id, Student_Competency__c = sc.Id, Description__c = 'Identified as a Shared Competency; existing Assessment Record moved to this record, old SC ID : ' + sa.Id);
	        			studentAssessmentsToUpdate.add(assessment);
	        		}
	        	}
	        }
	        
	        system.debug('Student Assessment records to update ' + studentAssessmentsToUpdate);
	        //Update the Student Assessment records
	        if(!studentAssessmentsToUpdate.isEmpty()){
	        	update studentAssessmentsToUpdate;
	        } 
	        
	        System.debug('New Enrollments :: ' + studentCompsToEnroll + ' Size :: ' + studentCompsToEnroll.size());
	        if(studentCompsToEnroll.size() > 0) {
	        	upsert studentCompsToEnroll;
	        } 
	        
	        //Now get the list of old Student Competencies to be Un-Enrolled
	        list<Student_Competency__c> unenrollComps = new list<Student_Competency__c>();
	    	//Loop through the old program competencies and un-enroll the non-shared ones
	        for(String fwkId : mapOldProgramCompetencies.keySet()) {
	            //shared comps, need to move over CLP active and FWK ID from SC level to new program from old
	            if(!mapProgramCompetencies.containsKey(fwkId)) {
	                Student_Competency__c oldEnrollment = mapOldProgramCompetencies.get(fwkId);
	                System.debug('Old Enrollment :: ' + oldEnrollment + ' ID :: ' + oldEnrollment.Id);
	                
	                oldEnrollment.Is_Enrolled__c = false;
	                unenrollComps.add(oldEnrollment);
					Student_Competency_Enrollment__c sce = new Student_Competency_Enrollment__c();
					sce.Student_Competency__c = oldEnrollment.Id;
					sce.Action__c = 'Un-Enroll';
					studentCompsToUnEnroll.add(sce);
	            }			
	        }
	        System.debug('SCs to Un-Enroll :: ' + unenrollComps + ' size :: ' + unenrollComps.size());
	        System.debug('Un-Enrollments :: ' + studentCompsToUnEnroll + ' Size :: '  + studentCompsToUnEnroll.size());    
	        
	        if(!unenrollComps.isEmpty()) {
	        	upsert unenrollComps;
	        }
	        
	        if(!studentCompsToUnEnroll.isEmpty()) {
	        	insert studentCompsToUnEnroll;
	        }
	        
	        //Blank out data to clear up memoery
	        mapProgramCompetencies = null;
	        mapOldProgramCompetencies = null;
	        studentCompsToEnroll = null;
	        studentCompsToUnEnroll = null;
	        oldStudentAssessments = null;
	        compsToUpdate = null;
		}
		catch(Exception exp) {
			System.debug(exp.getMessage());
		}	
    }
 	
 	//Reconcile the shared TBYB comps for a COS processed before Admitted once the Opp goes to Admitted and SC's are available
 	public void reconcileCOSBeforeAdmitted(List<Opportunity> opportunities, map<ID,Opportunity> oldMap) {
 		
 		system.debug('Reonciling TBYB Competencies');
 		
 		list<ID> newProgramIDs = new list<ID>();
 		list<ID> oppIDs = new list<ID>();
 		list<Opportunity> oppsToUpdate = new list<Opportunity>();
 		
 		for(Opportunity opp : opportunities) {
 			newProgramIDs.add(opp.Primary_Program__c);
 			oppIDs.add(opp.Id);
 			oppsToUpdate.add(new Opportunity(Id = opp.Id, Change_of_Specialization__c = false));
 		}
 		
 		if(!newProgramIDs.isEmpty()) {
	 		list<Student_Competency__c> newStudentComps = new list<Student_Competency__c>([SELECT IsCompleted__c, Is_Enrolled__c, Completed_Date__c, Student_Subscription_Achieved_In__c, Number_of_Assessment_Attempts__c, Start_Date__c, Target_Date__c, Flat_World_Knowledge_Link__c, Transferring_Institution__c, Id, Status__c, CLP_Active__c, Competency_Code__c, PC_FWK_ID__c, FWK_Id__c, Name FROM Student_Competency__c WHERE Program__c IN :newProgramIDs AND Opportunity__c IN :oppIDs AND Available_for_Try_Before_You_Buy__c = true]);
	 		list<Student_Competency__c> oldStudentComps = new list<Student_Competency__c>([SELECT IsCompleted__c, Is_Enrolled__c, Completed_Date__c, Student_Subscription_Achieved_In__c, Number_of_Assessment_Attempts__c, Start_Date__c, Target_Date__c, Flat_World_Knowledge_Link__c, Transferring_Institution__c, Id, Status__c, CLP_Active__c, Competency_Code__c, PC_FWK_ID__c, FWK_Id__c, Name FROM Student_Competency__c WHERE Program__c NOT IN :newProgramIDs AND Opportunity__c IN :oppIDs AND Available_for_Try_Before_You_Buy__c = true]);
	 		
	 		system.debug('Program IDs ::: '  + newProgramIDs);
	 		system.debug('New Student Competencies ::: ' + newStudentComps);
	 		system.debug('Old Student Competencies ::: ' + oldStudentComps);
	 		
	 		//Get all the SC's related to the new Primary Program
	        map<String, Student_Competency__c> mapProgramCompetencies = new map<String,Student_Competency__c>();
	        map<String, Student_Competency__c> mapOldProgramCompetencies = new map<String,Student_Competency__c>();
			
	        //Create a map of the Program Comp FWK ID against corresponding new Student Competencies 
	        for(Student_Competency__c sc : newStudentComps) {
	                if(!mapProgramCompetencies.containsKey(sc.PC_FWK_ID__c)) {
	                    mapProgramCompetencies.put(sc.PC_FWK_ID__c, sc);
	                }           
	        }
	        //Create a map of the Program Comp FWK ID against corresponding old Program Student Competencies
	        for(Student_Competency__c sc : oldStudentComps) {
	                if(!mapOldProgramCompetencies.containsKey(sc.PC_FWK_ID__c)) {   
	                    mapOldProgramCompetencies.put(sc.PC_FWK_ID__c, sc); 
	                }
	                            
	        }
	        
	        //Loop through the shared comps and move over data from old shared comps as necessary    
	 		boolean isSuccess = true;
	        list<Student_Competency__c> compsToUpdate = new list<Student_Competency__c>();
			
			//Create a list of ID's for the old and new Shared Student Competency ID's, used for getting assessment data
			list<Id> newStudentCompetencyIds = new list<Id>();
			list<Id> oldStudentCompetencyIds = new list<Id>();
			
			try {
			
		        for(String fwkId : mapProgramCompetencies.keySet()) {
		            //shared comps, need to move over CLP active and FWK ID from SC level to new program from old
		            if(mapOldProgramCompetencies.containsKey(fwkId)) {
		                Student_Competency__c oldStudentComp = mapOldProgramCompetencies.get(fwkId);
		                Student_Competency__c newStudentComp = mapProgramCompetencies.get(fwkId);
		                newStudentComp.FWK_Id__c = oldStudentComp.FWK_Id__c;
		                newStudentComp.CLP_Active__c = oldStudentComp.CLP_Active__c;
		                newStudentComp.Status__c = oldStudentComp.Status__c;
		                newStudentComp.IsCompleted__c = oldStudentComp.IsCompleted__c;
		                newStudentComp.Description__c = 'Identified as a Shared Competency; existing Student Competency data added to this record';
		                newStudentComp.Completed_Date__c = oldStudentComp.Completed_Date__c!=null?oldStudentComp.Completed_Date__c:null;
		                newStudentComp.Student_Subscription_Achieved_In__c = oldStudentComp.Student_Subscription_Achieved_In__c!=null?oldStudentComp.Student_Subscription_Achieved_In__c:null;
		                newStudentComp.Number_of_Assessment_Attempts__c = oldStudentComp.Number_of_Assessment_Attempts__c!=null?oldStudentComp.Number_of_Assessment_Attempts__c:null;
		                newStudentComp.Start_Date__c = oldStudentComp.Start_Date__c!=null?oldStudentComp.Start_Date__c:null;
		                newStudentComp.Target_Date__c = oldStudentComp.Target_Date__c!=null?oldStudentComp.Target_Date__c:null;
		                newStudentComp.Flat_World_Knowledge_Link__c = oldStudentComp.Flat_World_Knowledge_Link__c!=null? oldStudentComp.Flat_World_Knowledge_Link__c:null;
		                newStudentComp.Transferring_Institution__c = oldStudentComp.Transferring_Institution__c!=null ? oldStudentComp.Transferring_Institution__c:null;
		                newStudentCompetencyIds.add(newStudentComp.Id);
		                compsToUpdate.add(newStudentComp);
		                oldStudentComp.Target_Date__c = null;
		                oldStudentComp.Completed_Date__c = null;
		                oldStudentComp.Start_Date__c = null;
		                oldStudentComp.Transferring_Institution__c = null;
		                oldStudentComp.Flat_World_Knowledge_Link__c = null;
		                oldStudentComp.Student_Subscription_Achieved_In__c = null;
			            oldStudentComp.FWK_Id__c = '';
		                oldStudentComp.CLP_Active__c = false;
		                oldStudentComp.Is_Enrolled__c = false;
		                oldStudentComp.IsCompleted__c = false;
		                oldStudentComp.Status__c = '';
		                oldStudentComp.Description__c = 'Identified as a Shared Competency; Student Competency data moved to the new programs Student Competency record';
		                oldStudentCompetencyIds.add(oldStudentComp.Id);
		                compsToUpdate.add(oldStudentComp); 
		                 				
		            }
		        }
		        if(!compsToUpdate.isEmpty()) {
		        	upsert compsToUpdate;
		        }
		        //Get all the Student Assessment records for the old Program
		        list<Student_Assessment__c> oldStudentAssessments = new list<Student_Assessment__c>([SELECT Id, Description__c, Program_Competency_FWK_ID__c, Student_Competency__c FROM Student_Assessment__c WHERE Student_Competency__c IN :oldStudentCompetencyIds]);
		        System.debug('Old Student Assessment Records ::: ' + oldStudentAssessments);
		        
		        //Create a map of the Student Assessments for the old Program with the PC FWK ID
		        map<String, list<Student_Assessment__c>> mapAssessmentsWithFWKId = new map<String, list<Student_Assessment__c>>();
		        for(Student_Assessment__c sa : oldStudentAssessments) {
		        	if(mapAssessmentsWithFWKId.containsKey(sa.Program_Competency_FWK_ID__c)) {
						mapAssessmentsWithFWKId.get(sa.Program_Competency_FWK_ID__c).add(sa);					  		
		        	}
		        	else {
		        		mapAssessmentsWithFWKId.put(sa.Program_Competency_FWK_ID__c, new List <Student_Assessment__c> { sa });
		        	}
		        }
		        
		        system.debug('Map of Assessments with FWK ID ' + mapAssessmentsWithFWKId);
		        
		        //List of Student Assessments to be updated
		        list<Student_Assessment__c> studentAssessmentsToUpdate = new list<Student_Assessment__c>();
		        //Now loop through the Assessments maps and assign the Assessments to the new Student Competency
		        for(String fwkId :  mapAssessmentsWithFWKId.keySet()) {
		        	if(mapProgramCompetencies.containsKey(fwkId)) {
		        		Student_Competency__c sc = mapProgramCompetencies.get(fwkId);
		        		for(Student_Assessment__c sa : mapAssessmentsWithFWKId.get(fwkId)) {
		        			Student_Assessment__c assessment = new Student_Assessment__c (Id = sa.Id, Student_Competency__c = sc.Id, Description__c = 'Identified as a Shared Competency; existing Assessment Record moved to this record, old SC ID : ' + sa.Id);
		        			studentAssessmentsToUpdate.add(assessment);
		        		}
		        	}
		        }
		        if(!studentAssessmentsToUpdate.isEmpty()) {
		        	update studentAssessmentsToUpdate;
		        }
		        
			}
			catch(Exception e) {
				isSuccess = false;
			}
			
			if(isSuccess && !oppsToUpdate.isEmpty()) {
				//update oppsToUpdate;
			}
        	
 		}    		
 		
 	}

    //Runs the Reconcilation process at the Student Level or when a Prospect is Admitted
    public void reoncileCOSStudent(list<Student_Program__c> selectedStudentPrograms,map<ID,Student_Program__c> oldMap) {
        system.debug('In Reconciliation logic');
        
        boolean isSuccess = true;
		//List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<ID> newProgramIDs = new List<Id>();
        List<Id> oldProgramIDs = new List<Id>();
        List<Id> spIDs = new List<Id>();
        
        Map<String, Student_Program__c> mapSPToProductId = new Map<String, Student_Program__c>();
        
        // Opportunity oldOpty = oldMap.get(opty.ID);
        for(Student_Program__c o : selectedStudentPrograms) {
        	//oppsToUpdate.add(new Opportunity(Id = o.Application__c, Change_of_Specialization__c = false));
            newProgramIDs.add(o.Program__c);
            Student_Program__c oldStudentProgram = oldMap.get(o.Id);
            if(!mapSPToProductId.containsKey(o.Program__c)) {
                mapSPToProductId.put(o.Program__c, o);
            }            
            Id oldProgramId = oldStudentProgram.Program__c;
            oldProgramIDs.add(oldProgramId);
            spIDs.add(o.Id);
        }
        
        try {
	        map<String,List<Program_Competency__c>> mapNewProgCompetencies = new map<String, List<Program_Competency__c>>();
	        for(Program_Competency__c programCompetency:[SELECT Id, Program_Expertise__c, Area_of_Expertise__c, Competency__c, Product__c, Program_Competency_Type__c, Competency_Code__c, FWK_Id__c FROM Program_Competency__c WHERE Product__c IN :newProgramIDs AND Program_Competency_Type__c = 'Specialization']){
	            if(mapNewProgCompetencies.containsKey(programCompetency.Product__c)) {
	                mapNewProgCompetencies.get(programCompetency.Product__c).add(programCompetency);
	            }
	            else {
	            	mapNewProgCompetencies.put(programCompetency.Product__c, new  List <Program_Competency__c> { programCompetency });
	            }
	        }
	
	        System.debug('New Student Comps ::: ' + mapNewProgCompetencies + ' Count of Comps ::: ' + mapNewProgCompetencies.size());
	 
			//Loop through the old competencies and create Student Competency Enrollment records to remove the enrollments
	 		List<Student_Competency__c> oldStudentComps = new List<Student_Competency__c>([SELECT Id, FWK_Id__c, Program__c FROM Student_Competency__c WHERE Student_Program__c IN :spIDs AND Program_Competency_Type__c = 'Specialization']);
			List<Student_Competency__c> oldStudentCompsToUpdate = new List<Student_Competency__c>();
			if(oldStudentComps.size()> 0) {
				List<Student_Competency_Enrollment__c> studentCompsToRemove = new List<Student_Competency_Enrollment__c>();
				for(Student_Competency__c sc : oldStudentComps) {
					//Also mark the SC's as not enrolled so tempo doesn't display them on the UI
					sc.Is_Enrolled__c = false;
					oldStudentCompsToUpdate.add(sc);
					Student_Competency_Enrollment__c sce = new Student_Competency_Enrollment__c();
					sce.Student_Competency__c = sc.Id;
					sce.Action__c = 'Un-Enroll';
					studentCompsToRemove.add(sce);
				}
		 		System.debug('Student Comps to remove ::: ' + oldStudentComps);
		 		
		 		if(!studentCompsToRemove.isEmpty()) {
		 			upsert studentCompsToRemove;
		 		}
		 		if(!oldStudentCompsToUpdate.isEmpty()) {
		 		   update oldStudentComps;
		 		}
			}	 		 
	 		 		
	        List<Student_Competency__c> newCompetencies = new List<Student_Competency__c>();
	        List<Student_Expertise__c> newStudentExpertise = new List<Student_Expertise__c>();            
	        //Loop through the new Programs and create the new SC's
	        //Prod Defect 30210 - Added pcIdPc to not duplicate program competencies and thus do not duplicate SEs
	        for(String programId : mapNewProgCompetencies.keySet()) {
	            List<Program_Competency__c> programCompetencies = mapNewProgCompetencies.get(programId);
                Map<Id, Program_Competency__c> pcIdPc = new Map<Id, Program_Competency__c>();
	            for(Program_Competency__c pc : programCompetencies) {
                    if(mapSPToProductId.containsKey(programId)) {
                        if (!pcIdPc.containsKey(pc.Program_Expertise__c)) {
                            pcIdPc.put(pc.Program_Expertise__c, pc);
                        	Student_Program__c sp = mapSPToProductId.get(programId);
                            Student_Expertise__c se = new Student_Expertise__c();
                            se.Program_Expertise__c = pc.Program_Expertise__c;
                            se.Student_Program__c = sp.Id;
                            se.IsAchieved__c = false;
                            se.Contact__c = sp.Student__c;
                            se.Opportunity__c = sp.Application__c;
                            se.Area_of_Expertise__c = pc.Area_of_Expertise__c;
                            newStudentExpertise.add(se);
                        }	                	
	                }
	            }
	        }
	        
		    if(newStudentExpertise.size()>0) {
		    	insert newStudentExpertise;
		    } 
		     
	        //Create a map of Student Expertise with Program Expertise
            Map<String, Student_Expertise__c> mapStudentProgramToExpertise = new Map<String, Student_Expertise__c>();
            for(Student_Expertise__c se : newStudentExpertise) {
                if(!mapStudentProgramToExpertise.containsKey(se.Program_Expertise__c)) {
                    mapStudentProgramToExpertise.put(se.Program_Expertise__c, se);
                }
            }
	
	        //Loop through the new Programs and create the new SC's
	        for(String programId : mapNewProgCompetencies.keySet()) {
	            List<Program_Competency__c> programCompetencies = mapNewProgCompetencies.get(programId);
	            for(Program_Competency__c pc : programCompetencies) {
	                if(mapSPToProductId.containsKey(programId)) {
	                	Student_Program__c sp = mapSPToProductId.get(programId);
	                	Student_Expertise__c se = mapStudentProgramToExpertise.get(pc.Program_Expertise__c);
	                			                	
	                    Student_Program__c o = mapSPToProductId.get(programId);
	                    Student_Competency__c sc = new Student_Competency__c();
	                    sc.Competency__c = pc.Competency__c;
	                    sc.Contact__c =  o.Student__c;
	                    sc.Program_Competency__c = pc.Id;
	                    sc.Opportunity__c = sp.Application__c;
	                    sc.Student_Program__c = o.Id;
	                    sc.Student_Expertise__c = se.Id;
	                    sc.Status__c = 'Registered';
	                    newCompetencies.add(sc);
	                 
	                }
	            } 
	                      
	        }
	            
            System.debug('New student Competencies to be inserted ::: ' + newCompetencies);
            if (newCompetencies.size() > 0) {
                List<Student_Competency_Enrollment__c> studentCompsToEnroll = new  List<Student_Competency_Enrollment__c>();
                Database.Saveresult[] saveResult = Database.insert(newCompetencies,false);
                // Iterate through each returned result
                integer index = 0;
                for (Database.SaveResult sr : saveResult) {
                    if (sr.isSuccess()) {
                        // Operation was successful
                        // get newly created SC to create SCE record
                        Student_Competency__c sc = newCompetencies[index];
                        Student_Competency_Enrollment__c sce = new Student_Competency_Enrollment__c();
                        sce.Student_Competency__c = sc.Id;
                        sce.Action__c = 'Enroll';
                        studentCompsToEnroll.add(sce);
                        
                        index++;
                    }               
                }
                if (studentCompsToEnroll.size() > 0) {
                    insert studentCompsToEnroll;
                }         
	         }
        }
        catch(Exception exp) {
        	isSuccess = false;
        }        
    }
}