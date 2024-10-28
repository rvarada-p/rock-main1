/*******************************************************************
Name  : PreRequisiteRuleTriggerHandler
Author: Ravitej Varada
Date  : October 5th, 2018
Description: trigger handler class for  PreRequisiteRuleTrigger
*************************************************************************/
public class PreRequisiteRuleTriggerHandler {
    private set<ID> setCBLRecordTypes;
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public static  boolean firstRun = true;
    
    
    public PreRequisiteRuleTriggerHandler(boolean isExecuting, integer size){
        isExecuting = isExecuting;
        batchSize = size;
        setCBLRecordTypes = Utility.getRecordTypeFromCBLCustomSetting(Pre_requisite_Rules__c.sObjectType.getDescribe());
    }
    
    //On After Insert Event
    public void onAfterInsert(list<Pre_requisite_Rules__c > newStudentCompetency){  
    }
    
   //On Before Insert  Event
    public void onBeforeInsert(list<Pre_requisite_Rules__c > newPreRequisiteRules){
    }

    //On Before Update Event
    public void onBeforeUpdate(list<Pre_requisite_Rules__c > newPreRequisiteRules,map<ID,Pre_requisite_Rules__c>oldMap){
    }
    
    //On After Update Event
    public void onAfterUpdate(list<Pre_requisite_Rules__c > newPreRequisiteRules,map<ID,Pre_requisite_Rules__c>oldMap){ 
        List<Student_Expertise__c> seList = new List<Student_Expertise__c>();
        Set<Id> seIDSet = new Set<Id>();
        for(Pre_requisite_Rules__c  prrObj : newPreRequisiteRules){
            if(prrObj.IsAchieved__c !=  oldMap.get(prrObj.Id).IsAchieved__c){
                seIDSet.add(prrObj.Student_Expertise__c);
            }
        }
        
        seList = [Select id, Area_of_Expertise__r.Condition_Rule__c, 
                  (Select id, IsAchieved__c from Pre_requisite_Rules__r) 
                  from Student_Expertise__c 
                  where id in :seIDSet];
        if(!seList.isEmpty()){
            for(Student_Expertise__c seObj : seList){
                Boolean lockBool = false;
                if(seObj.Area_of_Expertise__r.Condition_Rule__c == 'AND'){
                    lockBool = false;
                    for(Pre_requisite_Rules__c prrObj : seObj.Pre_requisite_Rules__r){
                        if(prrObj.IsAchieved__c == false)
                            lockBool = true;
                    }           
                }
                else if(seObj.Area_of_Expertise__r.Condition_Rule__c == 'OR'){
                    lockBool = true;
                    for(Pre_requisite_Rules__c prrObj : seObj.Pre_requisite_Rules__r){
                        if(prrObj.IsAchieved__c == true)
                            lockBool = false;
                    }
                }
                if(lockBool)
                    seObj.Is_Pre_Req_Lock__c = true;
                else
                    seObj.Is_Pre_Req_Lock__c = false;
            }    
            update seList;   
        }       
        
        
    }
 
}