/*******************************************************************
Name  : SectionTriggerHandler
Author: Ravitej Varada
Date  : October 5th, 2018
Description: trigger handler class for  SectionTrigger
*************************************************************************/
public class SectionTriggerHandler {
    private set<ID> setCBLRecordTypes;
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public static  boolean firstRun = true;
    
    
    public SectionTriggerHandler(boolean isExecuting, integer size){
        isExecuting = isExecuting;
        batchSize = size;
        setCBLRecordTypes = Utility.getRecordTypeFromCBLCustomSetting(Sections__c.sObjectType.getDescribe());
    }
    
    //On After Insert Event
    public void onAfterInsert(Map<Id, Sections__c> newSectionsMap){  
        system.debug('****test');
        List<Sections__c> sectionList = new List<Sections__c>();
        sectionList = [Select id, Competency__c from Sections__c where id IN : newSectionsMap.keySet()];
        Set<Id> compIDSet = new Set<Id>();
        for(Sections__c sctnObj : sectionList){
            compIDSet.add(sctnObj.Competency__c);
        }
        Map<Id,Id> compVrsnMap = new Map<Id,Id>();
        List<Competency_Version__c> comVsnList = new List<Competency_Version__c>(); 
        if(!compIDSet.isEmpty()){
            comVsnList = [Select id, Active__c, Competency__c from Competency_Version__c where Competency__c IN :compIDSet AND Active__c = true];
            if(!comVsnList.isEmpty()){
                for(Competency_Version__c comVrObj : comVsnList){
                    compVrsnMap.put(comVrObj.Competency__c,comVrObj.Id);
                }
                if(!compVrsnMap.isEmpty()){
                    for(Sections__c secObj : sectionList){
                        if(compVrsnMap.containsKey(secObj.Competency__c)){
                            secObj.Competency_Version__c = compVrsnMap.get(secObj.Competency__c);
                        }         
                    }
                    update sectionList;
                }
            }
        }
    }
    
   //On Before Insert  Event
    public void onBeforeInsert(list<Sections__c > newSections){
    }

    //On Before Update Event
    public void onBeforeUpdate(list<Sections__c > newSections,map<ID,Sections__c>oldMap){
    }
    
    //On After Update Event
    public void onAfterUpdate(list<Sections__c > newSections,map<ID,Sections__c>oldMap){ 
       
    }
 
}