/*******************************************************************
Name  : TaskTriggerHandler
Author: Dirk (Appirio)
Date  : Jan, 2015
Description: Handler class for the Task trigger
    1. on BeforeInsert: filter out tasks that have Assign_Round_Robin_Queue__c assigned
    2. send the names of the queue/groups to objRRHelper.getNextRRUsers
    3. get back a list of User IDs to assign to task list
*************************************************************************/
public with sharing class TaskTriggerHandler {

    private set<ID> setCBLRecordTypes;
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public static boolean isTaskCreatedFromBrandProfileTrigger = false;

    public TaskTriggerHandler(boolean isExecuting, integer size) {
        isExecuting = isExecuting;
        batchSize = size;
        setCBLRecordTypes = Utility.getRecordTypeFromCBLCustomSetting(Task.sObjectType.getDescribe());
    }

    /*******************************************************************
    Method to handle the before insert trigger
    ********************************************************************/
   public void onBeforeInsert(List<Task> newTasks) {

        if(!newTasks.isEmpty()){
            TaskTriggerHelper  helper = new TaskTriggerHelper();
            helper.createOBMForTasksRelatedToL1(newTasks);
        /*
            // Build List of tasks that have Round Robin Queues assigned
            List<Task> listTaskswRRGroup = new List<Task>();
            
            for (Task myTask : newTasks) {
                if (myTask.Assign_Round_Robin_Queue__c <> null) {
                    listTaskswRRGroup.add(myTask);
                }
            }
            
            if(!listTaskswRRGroup.isEmpty()){
                TaskTriggerHelper objTaskHelper = new TaskTriggerHelper();
                objTaskHelper.assignRRTask(newTasks);
            }
            
        }
        */

            //Load MAP of Round_Robin_Queue__c table: ID - Queue Name
            /* Commented out 2/6/18
            Map<Id, String> mapRRId_RRName = new Map<Id, String>();
          
            for (Round_Robin_Queue__c myTQ : [Select Id, Name from Round_Robin_Queue__c] )
            {
                mapRRId_RRName.put(myTQ.Id, myTQ.Name);
            }
            system.debug('>>> Handler: size of mapRRId_RRName ' + mapRRId_RRName.size());

            // Create List of Round Robin Group Names (from RR Ids, Assign_Round_Robin_Queue__c)
            List<String> listRRNames = new List<String>();
            for (Task myTask : newTasks) {
                system.debug('>>> Handler: myTask.Assign_Round_Robin_Queue__c  ' + myTask.Assign_Round_Robin_Queue__c);
                if (myTask.Assign_Round_Robin_Queue__c <> null) {
                    listRRNames.add(mapRRId_RRName.get(myTask.Assign_Round_Robin_Queue__c));
                }
            }
            system.debug('>>> Handler: size of listRRNames ' + listRRNames.size());
            

            // Call the RoundRobinHelper, pass in List of RR Names, returns List of 'next' User IDs
            List<Id> listUserIds = new List<Id>();
            if(!listRRNames.isEmpty()) {
                RoundRobinHelper objRRHelper = new RoundRobinHelper();
                listUserIds = objRRHelper.getNextRRUsers(listRRNames);
                system.debug('>>> Handler: size of returned: listUserIds ' + listUserIds.size());

                // Assign 'next' User IDs as the Task owners
                Integer index=0;
                if(!listUserIds.isEmpty()){   
                    for (Task myTask : newTasks) {
                        if (myTask.Assign_Round_Robin_Queue__c <> null) {
                            myTask.OwnerID = listUserIds[index];
                            if( index == listUserIds.size()-1 ) {
                              index = 0;
                            } else {
                              index++;
                            }
                        }
                    }
                }
            }
        */

        }
    }
}