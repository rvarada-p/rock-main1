/*******************************************************************
Name  : ProgramTriggerHandler
Author: Ravitej Varada - Laureate
Date  : Feb 27, 2020
Description: Trigger handler class for Program trigger
*************************************************************************/
public with sharing class ProgramTriggerHandler {
    public void onBeforeUpdate(list<product2> updatedProgs, map<ID,product2> oldMap){
        ID waldenRecordTypeId = Schema.SObjectType.product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        list<product2> progList = new list<product2>();
        ProgramHelper objHelper = new ProgramHelper();
        for(product2 prog: updatedProgs){
            
                System.debug('publishing to LMS');
            if(prog.RecordTypeId == waldenRecordTypeId && (prog.Parent_Program__c != null && prog.Publish_to_LMS__c==true && oldMap.get(prog.id).Publish_to_LMS__c!=true)){
                System.debug('publishing to LMS');
                progList.add(prog);
            }
        }
        if(!progList.isEmpty()){
           objHelper.createProgramInBS(progList); 
        }
    }
    
    
    public void onAfterInsert(list<product2> updatedProgs ){
        ID waldenRecordTypeId = Schema.SObjectType.product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        list<product2> progList = new list<product2>();
        ProgramHelper objHelper = new ProgramHelper();
        for(product2 prog: updatedProgs){
                System.debug('publishing to LMS');
            if(prog.RecordTypeId == waldenRecordTypeId && (prog.Parent_Program__c  != null && prog.Publish_to_LMS__c==true)){
                System.debug('publishing to LMS');
                progList.add(prog);
            }
        }
        if(!progList.isEmpty()){
           objHelper.createProgramInBS(progList); 
        }
    }
    
     
}