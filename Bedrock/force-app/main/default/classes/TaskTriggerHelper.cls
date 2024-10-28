/*******************************************************************
Name  : TaskTriggerHelper
Author: Sarah Khalid - Laureate
Date  : Feb 6, 2018
Description: Handler class for the Trigger TaskTrigger
*************************************************************************/

public with sharing class TaskTriggerHelper {

    public void createOBMForTasksRelatedToL1(list<Task> selectedTasks){
        list<Id> relatedSPs = new list<Id>();
        list<Task> relatedTasks = new list<Task>();

        for(Task t : selectedTasks) {
            //System.debug('What: ' + t.WhatId.getSObjectType());
            if (t.WhatId!=null && t.WhatId.getSObjectType() == Student_Program__c.sObjectType) {
               relatedSPs.add(t.whatid);
               relatedTasks.add(t);
            }            
        }
                
        map<String,Student_Program__c> mapStudentProgram_Task = new map<String,Student_Program__c>();
        list<OBM_Event_Notification__c> lstOBMs = new list<OBM_Event_Notification__c>();

        for(Student_Program__c sp: [SELECT Id, Application__r.LeadSource FROM Student_Program__c WHERE Id IN : relatedSPs]){
            mapStudentProgram_Task.put(sp.Id, sp);
        }
        System.debug('Related SP: ' + relatedSPs);
        System.debug('Map: ' + mapStudentProgram_Task);

        for(Task currentTask : selectedTasks) {
            if(mapStudentProgram_Task.containsKey(currentTask.whatid)) {
                Student_Program__c currentSP = mapStudentProgram_Task.get(currentTask.whatid);
                if(currentSP.Application__r.LeadSource == 'L1 Transfer') {
                    currentTask.Sync_with_L1__c = true;
                }
            }    
        }
    }
}