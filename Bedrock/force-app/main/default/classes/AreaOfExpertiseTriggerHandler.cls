/*******************************************************************
Name  : AreaOfExpertiseTriggerHandler
Author: Sarah Khalid - Laureate
Date  : September 14, 2017
Description: Trigger handler class for Area of Expertise trigger
*************************************************************************/
public with sharing class AreaOfExpertiseTriggerHandler {
  public void onBeforeUpdate(list<Area_of_Expertise__c> updatedAoEs, map<ID,Area_of_Expertise__c> oldMap){
    ID waldenRecordTypeId = Schema.SObjectType.Area_of_Expertise__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
    list<Area_of_Expertise__c> aoEList = new list<Area_of_Expertise__c>();
    AreaOfExpertiseHelper objHelper = new AreaOfExpertiseHelper();
    for(Area_of_Expertise__c aoe: updatedAoEs){
 	  //make sure the AoE is ready to be published to the LMS  	
 	  System.debug('Walden Record Type: ' + waldenRecordTypeId +  ' publish ' + aoe.Publish_to_LMS__c + ' old publish : ' + oldMap.get(aoe.id).Publish_to_LMS__c + ' record type: ' + waldenRecordTypeId);
      if(aoe.RecordTypeId == waldenRecordTypeId && (aoe.Publish_to_LMS__c==true && oldMap.get(aoe.id).Publish_to_LMS__c!=true)){
      	System.debug('publishing to LMS');
        aoEList.add(aoe);
      }
    }
    if(!aoEList.isEmpty()){
      objHelper.createAreaOfExpertiseInBS(aoEList); 
    }
  }   
    
    
    public void onAfterInsert(list<Area_of_Expertise__c> updatedAoEs ){
    ID waldenRecordTypeId = Schema.SObjectType.Area_of_Expertise__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
    list<Area_of_Expertise__c> aoEList = new list<Area_of_Expertise__c>();
    AreaOfExpertiseHelper objHelper = new AreaOfExpertiseHelper();
    for(Area_of_Expertise__c aoe: updatedAoEs){
 	  //make sure the AoE is ready to be published to the LMS  	
 	  System.debug('Walden Record Type: ' + waldenRecordTypeId +  ' publish ' + aoe.Publish_to_LMS__c + ' old publish : ' +  ' record type: ' + waldenRecordTypeId);
      if(aoe.RecordTypeId == waldenRecordTypeId && (aoe.Publish_to_LMS__c==true)){
      	System.debug('publishing to LMS');
        aoEList.add(aoe);
      }
    }
    if(!aoEList.isEmpty()){
      objHelper.createAreaOfExpertiseInBS(aoEList); 
    }
  }    
}