/*******************************************************************
Name  : LeadTriggerHandler
Author: Vinod (Appirio)
Date  : September 19, 2014
Description: Handler class for the Lead trigger
*************************************************************************/
public with sharing class LeadTriggerHandler {
  private set<ID> setCBLRecordTypes;
  private boolean isExecuting = false;
  private integer batchSize = 0;
  public static boolean isLeadCreatedFromBrandProfileTrigger = false;
  public LeadTriggerHandler(boolean isExecuting, integer size){
    isExecuting = isExecuting;
    batchSize = size;
    setCBLRecordTypes = Utility.getRecordTypeFromCBLCustomSetting(Lead.sObjectType.getDescribe());
  }

  public void onBeforeInsert(list<Lead> newLeads){
    // use to populate Program Of Interest from the key populated (currently for Web2Lead for Tempo)
    list<Lead> selectedCBL_Leads = new list<Lead>();
    LeadHelper objLeadHelper = new LeadHelper();
    set<string> setProgramOfInterestKey = new set<string>();
    for(Lead newLead : newLeads){
      if(newLead.Program_of_Interest__c == null && newLead.Program_of_Interest_Key__c != null){
        selectedCBL_Leads.add(newLead);
        setProgramOfInterestKey.add(newLead.Program_of_Interest_Key__c);
      } 
    }
    // convert lead
    if(!selectedCBL_Leads.isEmpty()){
      objLeadHelper.populateProgramOfInterest(selectedCBL_Leads,setProgramOfInterestKey);
      set<Id> progIdSet = new set<Id>();
      for(Lead newLead: newLeads){
        progIdSet.add(newLead.Program_of_Interest__c);
      }
      map<Id,Product2> mapProg = new map<Id,Product2>([SELECT Id, Institution_Name__c FROM Product2 WHERE Id IN :progIdSet]);
      for(Lead newLead: newLeads){
        if(newLead.Program_of_Interest__c!=null){
          if(mapProg.containsKey(newLead.Program_of_Interest__c)){
            SObjectType objTypeForInstitution = Schema.getGlobalDescribe().get('Lead');
            newLead.RecordTypeId = objTypeForInstitution.getDescribe().getRecordTypeinfosByName().get( mapProg.get(newLead.Program_of_Interest__c).Institution_Name__c ).getRecordTypeId();
          }
        }
      }
    }
  }

  public void onAfterInsert(list<Lead> newLeads,map<ID,Lead> oldMap){
    // use to convert lead
    list<Lead> selectedCBL_Leads = new list<Lead>();
    set<ID> programId = new set<ID>();
    // get lead recordtyes
    LeadHelper objLeadHelper = new LeadHelper();
    for(Lead newLead : newLeads){
      if(  setCBLRecordTypes.contains(newLead.RecordTypeId) && !isLeadCreatedFromBrandProfileTrigger 
        && newLead.IsConverted == false && newLead.Program_of_Interest__c != null ){
        selectedCBL_Leads.add(newLead);
        programId.add(newLead.Program_of_Interest__c);
      } 
    } 
    // convert lead
    if(!selectedCBL_Leads.isEmpty()){
      objLeadHelper.convertCBLLeads(selectedCBL_Leads,programId); 
    }
  }

}