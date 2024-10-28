/*******************************************************************
Name  : StudentDiscountTrigger
Author: Bryan Leboff (Appirio)
Date  : October 14, 2014
Description: trigger on student discount, insert and update
*************************************************************************/
public with sharing class StudentDiscountTriggerHandler {
	private boolean isExecuting = false;
  private boolean allowDiscountDelete = false;
  private integer batchSize = 0;
  private set<id> sdRecordTypeIds;
  private set<id> oppRecordTypeIds;

  public StudentDiscountTriggerHandler(boolean isExecuting, integer size){
    isExecuting = isExecuting;
    batchSize = size;
    sdRecordTypeIds = Utility.getRecordTypeFromCBLCustomSetting(Student_Discount__c.sObjectType.getDescribe());
    oppRecordTypeIds = Utility.getRecordTypeFromCBLCustomSetting(Opportunity.sObjectType.getDescribe());
  }

  // (DK) Purpose: keep discounts on Opportunity and Student Program in sync
  // TBD: process in bulk (low pri. issue, however, discounts are applied manually 1x1, not in bulk)
  // Modiied by vinod: To work on bulk updates
  // Related Task: T-334357
  public void beforeInsert(list<Student_Discount__c> newStudentDiscounts){

    set<ID> setOpportunityID = new set<ID>();
    set<ID> setStudentProgramID = new set<ID>();
    list<Student_Discount__c> lstStudentDiscount = new list<Student_Discount__c>();

    for(Student_Discount__c sd : newStudentDiscounts){

     if(sd.Opportunity__c != null){ 

				//set RecordType based on related Program
				if(sd.Program_Institution__c != null){
          try{
            SObjectType objTypeForInstitution = Schema.getGlobalDescribe().get('Student_Discount__c');
            sd.RecordTypeId = objTypeForInstitution.getDescribe().getRecordTypeinfosByName().get( sd.Program_Institution__c ).getRecordTypeId();
            } catch (Exception ex) {
             system.debug('No RecordType exists for Student_Discount__c with the name: ' + sd.Program_Institution__c);
           }
         }

				// If: sd added to Opportunity, check if SP exists, if so, insert SP ID
       setOpportunityID.add(sd.Opportunity__c);
       lstStudentDiscount.add(sd);
       } else if(sd.Student_Program__c != null){ 
      	// If: sd added to Student Program, add Opp ID
      	setStudentProgramID.add(sd.Student_Program__c);
      	lstStudentDiscount.add(sd);
      }

    }
    if(!lstStudentDiscount.isEmpty()){
     synsStudentDiscountOnOpportunityAndStudentProgram(lstStudentDiscount,setOpportunityID,setStudentProgramID);
   }
  }

  public void synsStudentDiscountOnOpportunityAndStudentProgram(list<Student_Discount__c> lstStudentDiscount,set<ID> setOpportunityID,set<ID> setStudentProgramID){
		// get the selected opportunity details
		map<ID,Opportunity>mapOportunity = new map<ID,Opportunity>();
		for(Opportunity myOpp :[Select ID, Student_Program__c from Opportunity where Id in: setOpportunityID]){
			mapOportunity.put(myOpp.ID,myOpp);
		}
		// get the selected Student_Program__c details
		map<ID,Student_Program__c>mapStudentProgram = new map<ID,Student_Program__c>();
		for(Student_Program__c sp :[Select ID, Application__c from Student_Program__c where Id in: setStudentProgramID]){
			mapStudentProgram.put(sp.ID,sp);
		}
		// 
		for(Student_Discount__c sd : lstStudentDiscount){
			if(sd.opportunity__c != null && mapOportunity.containsKey(sd.opportunity__c)){  
				// If: sd added to Opportunity, check if SP exists, if so, insert SP ID
        sd.Student_Program__c = mapOportunity.get(sd.opportunity__c).Student_Program__c;
      } else if(sd.Student_Program__c != null && mapStudentProgram.containsKey(sd.Student_Program__c)){  
      	// If: sd added to Student Program, add Opp ID
      	sd.Opportunity__c  = mapStudentProgram.get(sd.Student_Program__c).Application__c;
      }
    }
  }

  public void afterInsert(list<Student_Discount__c> newStudentDiscounts){
    Set<Id> opportunityIds = new Set<Id>();
    for(Student_Discount__c sd : newStudentDiscounts){
			//if its new to an opportunity, and there is an exemption
			if(sd.opportunity__c <> null 
				&& sd.Exemption__c <> null ){
				//apply to the opportunity
				opportunityIds.add(sd.opportunity__c);
      }            
    }	
    updateOpportunityAmounts(opportunityIds);
  }

  public void beforeUpdate(list<Student_Discount__c> newStudentDiscounts){
    Profile userProfile = [Select Name from Profile where id =: userinfo.getProfileId()];
    String profileName = userProfile.Name;

    if(profileName == 'CBL Bursar' || profileName == 'CBL Administrator' || profileName == 'System Administrator'){
      return;
    }

    for(Student_Discount__c sd : newStudentDiscounts){
      
      if (sd.Exemption_Approved__c == true
        && !StudentProgramHelper.newStudentProgramIdSet.contains(sd.Student_Program__c) ) {
        sd.addError('User must be a Bursar or System Administrator to update or delete an approved discount.');
      }
    }
  }

  public void afterUpdate(list<Student_Discount__c> newStudentDiscounts, map<ID,Student_Discount__c> oldMap){
    Set<Id> opportunityIds = new Set<Id>();
    for(Student_Discount__c sd : newStudentDiscounts){
      Student_Discount__c oldSD = oldMap.get(sd.id);
			//if the opportunity changed and isnt null, we need to recalc both
			if(oldSD.opportunity__c <> sd.opportunity__c){
				if(sd.Opportunity__c <> null){
					opportunityIds.add(sd.Opportunity__c);
				}
				if(oldSD.Opportunity__c <> null){
					opportunityIds.add(oldSD.Opportunity__c);
				}
			}

			//if the exemption changed, we need to recalculate the opp
			//DK: added  Exemption_Approved__c check - once approved, recalculate
			if(oldSD.Exemption__c <> sd.Exemption__c || oldSD.Exemption_Approved__c <> sd.Exemption_Approved__c){
				opportunityIds.add(sd.Opportunity__c);
			}
		}
		updateOpportunityAmounts(opportunityIds);		
	}

  public void beforeDelete(list<Student_Discount__c> newStudentDiscounts){

    Profile userProfile = [Select Name from Profile where id =: userinfo.getProfileId()];
    String profileName = userProfile.Name;

    if(profileName == 'CBL Bursar' || profileName == 'CBL Administrator' || profileName == 'System Administrator'){
      return;
    }

    for(Student_Discount__c sd : newStudentDiscounts){
      if (sd.Exemption_Approved__c == true) {
       sd.addError('User must be a Bursar or System Administrator to update or delete an approved discount.');
     }
   }
 }

  public void afterDelete(list<Student_Discount__c> oldStudentDiscounts){
    Set<Id> opportunityIds = new Set<Id>();
    for(Student_Discount__c sd : oldStudentDiscounts){
     if(sd.Opportunity__c <> null && sd.Exemption__c <> null){
      opportunityIds.add(sd.Opportunity__c);
      }
    }
    updateOpportunityAmounts(opportunityIds);
  }

  private void updateOpportunityAmounts(Set<Id> opportunityIds){
    List<Opportunity> opportunitiesWithAmounts = [select id, amount,Initial_Price_Book__c, primary_program__c 
    from opportunity 
    where id in:(opportunityIds) 
    and recordtypeid in:(oppRecordTypeIds)
    and Initial_Price_Book__c <> null
    and primary_program__c <> null];
    OpportunityHelper.calculateAmountAfterDiscount(opportunitiesWithAmounts);
    update opportunitiesWithAmounts;
  }
}