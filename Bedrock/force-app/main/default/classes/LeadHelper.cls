/*******************************************************************
Name  : LeadHelper
Author: Vinod (Appirio)
Date  : September 19, 2014
Description: Helper class for the class LeadTriggerHandler
*************************************************************************/
public with sharing class LeadHelper {

  public void convertCBLLeads(list<Lead> newLeads,set<ID> programId ){  
    map<ID,String>programIdWithName = new map<ID,String>();
    for(Product2 prod:[Select ID,Name from Product2 where id in: programId]){
      programIdWithName.put(prod.ID,prod.Name);
    }

    // find and map any matching Contacts
    map<Lead,Contact> mapNewLead_ExistingContact = new map<Lead,Contact>();
    ContactHelper helper = new ContactHelper();
    mapNewLead_ExistingContact = helper.getExistingContactMap(newLeads);


    list<Opportunity> oppsToUpdate = new list<Opportunity>();
    list<Database.LeadConvert> leadConverts = new list<Database.LeadConvert>();
    for(Lead newLead : newLeads){
      Database.LeadConvert lc = new database.LeadConvert();
      lc.setLeadId(newLead.Id);
	    lc.convertedStatus = 'Qualified';
      lc.setOverWriteLeadSource(true);
      boolean opportunityExist = false;
      if(mapNewLead_ExistingContact.containsKey(newLead)){
        Contact con = mapNewLead_ExistingContact.get(newLead);
      	lc.setContactId(con.id);
      	lc.setAccountId(con.AccountId);
        System.debug('L1 Opp ID: ' + newLead.L1OppID__c);
      	// check opportunity is exist with same Program_of_Interest__c or Program of Interest Key
      	if(con.Opportunities__r != null){
	      	for(Opportunity opty :con.Opportunities__r){
	      		if(opty.Primary_Program__c == newLead.Program_of_Interest__c){
              opty.L1OppID__c = newLead.L1OppID__c;
              oppsToUpdate.add(opty);
              System.debug('Found matching opportunity with same program');
	      			opportunityExist = true;
	      		}
	      	}
      	}      	
      }
      if(opportunityExist){		      
	      // not create opportunity
	      lc.setDoNotCreateOpportunity(true);
      }
      leadConverts.add(lc);
    }
    // convert the newly created lead
    list<Database.LeadConvertResult> results = Database.convertLead(leadConverts); 
    // populate opportunity.Contact__c with newly created contact id
    list<Opportunity> lstOpportunity = new list<Opportunity>(); 
    for (integer j = 0; j < results.size(); j++) {				
     	if (results[j].isSuccess()) {
            system.debug('Lead converted successfully!');
            string contactId = results[j].getContactId();
            if(results[j].getOpportunityId() != null) {
              string optyID = results[j].getOpportunityId();	
              lstOpportunity.add(new Opportunity(ID=optyID,Contact__c=contactId));	 
            }           
         }
  	}  
    if(!oppsToUpdate.isEmpty()) {
      update oppsToUpdate;
    }
  	if(!lstOpportunity.isEmpty()){
  		update lstOpportunity;
  	} 
  } 
  
  public void populateProgramOfInterest(list<Lead> newLeads,set<string> setProgramOfInterestKey){
    map<string,Product2> mapProduct = new map<string,Product2>();
    for(Product2 prod: [Select Name, Id From Product2 where Id in: setProgramOfInterestKey]){
      mapProduct.put(prod.ID,prod);
    }
    system.debug('mapProduct::::::::'+mapProduct);
    system.debug('setProgramOfInterestKey::::::::'+setProgramOfInterestKey);
    for(Lead newLead : newLeads){
      if(mapProduct.containsKey(newLead.Program_of_Interest_Key__c)){
        newLead.Program_of_Interest__c = mapProduct.get(newLead.Program_of_Interest_Key__c).id;
      }
    }    
  }

}