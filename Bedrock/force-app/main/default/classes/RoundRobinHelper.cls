/*******************************************************************
Name  : RoundRobinHelper
Author: Dirk (Appirio)
Date  : Jan, 2015
Description: General Purpose Round Robin Queue Manager, using native SFDC Queues or Groups, callable from anywhere.
Input Parameters:
	* a List of Queue names (these must exist as a SFDC Group or Queue AND must be an entry in the Round_Robin_Queue__c table)
Output Parameters:
	* a List of User IDs to assign (in the same order as the input queue names)

To Set Up:
1. Create 1 (or more) SFDC Queues (or Groups, both will work exactly the same)
2. Assign users to these groups
3. Add the group name(s) to the Round_Robin_Queue__c table
4. Pass a list of valid group names to RoundRobinHelper.getNextRRUsers.
   Returns: List of equal size as input containing the next subsequent user (User Id) in the given group(s).

Example:
1) Create 1 or more SFDC Groups or Queues, make sure to assign at least 1 user:
	* Accounting_Group: JoeId, FredId, MaryId
	* Sales_Group: AlexId, BettyId

2) optional: test getNextRRUsers in Execute Anonymous Window:

    RoundRobinHelper RRH = new RoundRobinHelper();
    List<String> listRRGroupNames = new List<String>{'Accounting_Group', 'Accounting_Group', 'Sales_Group',
        'Sales_Group', 'Sales_Group', 'A'ccounting_Group', 'Accounting_Group'};
    RRH.getNextRRUsers(listRRGroupNames);

3) view debug log and confirm that getNextRRUsers returns the User Ids in this order:
	JoeId, FredId, AlexId, BettyId, AlexId, MaryId, JoeId



Revision History :
Ravitej Varada      - oct 12th 2020 -  S-23002 - Coach Assignment Logic change from program to stand alone(Enhancement)
Horacio Sanchez     - Apr 27th 2022 -  S-84371: L2: Keep Tempo Student Assigned to Same Coach if Coach is Part of New Program's Assignment Group

 *************************************************************************/

public with sharing class RoundRobinHelper {
    public RoundRobinHelper() {
    }

    public class MyException extends Exception {
    }

    public List<Id> getNextRRUsers(List<String> listRRGroupNames, set<string> coachList) {

        List<Id> listNextUserIds = new List<Id>();
        system.debug('>>> RoundRobinHelper: size of incoming name list:' + listRRGroupNames.size());

        // Create Map of Round_Robin_Queue__c object
        Map< String, Round_Robin_Queue__c> mapRRName_TQ = new Map< String, Round_Robin_Queue__c>();
        for (Round_Robin_Queue__c myRRQ : [Select Id, Name, Queue_Position__c from Round_Robin_Queue__c where Name in :listRRGroupNames]) {
            mapRRName_TQ.put(myRRQ.Name, myRRQ);
        }
        system.debug('>>> RoundRobinHelper: number of queues/groups pulled from Round_Robin_Queue__c:' + mapRRName_TQ.size());

        // Create Map of < GroupId, Group Names >
        Map<Id, String> mapGrpId_GrpName = new Map<Id, String>();
        for (Group gp : [Select Id, Name from Group where name in :listRRGroupNames]) {
            mapGrpId_GrpName.put(gp.Id, gp.name);
        }
        system.debug('>>> RoundRobinHelper: number of SFDC Queues/Groups pulled from:' + mapGrpId_GrpName.size());

        // Create Map of < Group Name, List of Member IDs>
        Map< String, List<Id> > mapGrpName_listMemberIds = new Map< String, List<Id> >();
        for (GroupMember myGM : [Select GroupId, UserOrGroupId From GroupMember Where GroupId = :mapGrpId_GrpName.keySet() order by UserOrGroupId]) {
            system.debug(myGM.UserOrGroupId);
            //S-23002
            if (coachList != null && !coachList.contains(myGM.UserOrGroupId)) {
                continue;
            }

            String myGrpName = mapGrpId_GrpName.get(myGM.GroupId);
            if (!mapGrpName_listMemberIds.containsKey(myGrpName)) {
                mapGrpName_listMemberIds.put(myGrpName, new List<Id>{
                        myGM.UserOrGroupId
                });
                //system.debug('>>> RoundRobinHelper: new mapGrpName_listMemberIds mapping for:'+myGrpName);
            } else {
                List<Id> listMemberIds = mapGrpName_listMemberIds.get(myGrpName);
                //system.debug('>>> RoundRobinHelper: adding group member to group:' + myGrpName);
                listMemberIds.add(myGM.UserOrGroupId);
                mapGrpName_listMemberIds.put(myGrpName, listMemberIds);
            }
        }
        system.debug('>>> RoundRobinHelper: size of mapGrpName_listMemberIds' + mapGrpName_listMemberIds.size());
        system.debug('>>> RoundRobinHelper: size of mapGrpName_listMemberIds' + listRRGroupNames.size());


        for (String RRGroupName : listRRGroupNames) {
            //system.debug('>>> RoundRobinHelper: Processing Group: ' + RRGroupName);

            if (!mapRRName_TQ.containsKey(RRGroupName)) {
                listNextUserIds.add(null);
                // throw exception in Helper.  As an alternative, comment out throw new MyException
                //   and look for null return values and apply .addError exception in your Handler.
                throw new MyException('No Queue or Public Group ' + RRGroupName + ' defined in Round Robin table.');
                // continue;
            }

            Round_Robin_Queue__c myRRQ = mapRRName_TQ.get(RRGroupName);
            Integer myQueuePosition = (integer) myRRQ.Queue_Position__c;
            //system.debug('>>> RoundRobinHelper: Queue_Position__c for this group: ' + myQueuePosition);
            //S-23002
            if (!mapGrpName_listMemberIds.containsKey(RRGroupName)) {
                continue;
            }
            List<Id> myUserGroups = mapGrpName_listMemberIds.get(RRGroupName);

            // Group may have changed, check if count exceeds # of group members
            if (myQueuePosition >= myUserGroups.size())
                myQueuePosition = 0;

            system.debug('>>> RoundRobinHelper: RESULT Group:' + RRGroupName + '  Size:' + myUserGroups.size() +
                    '  Queue position:' + myQueuePosition + '  Id:' + myUserGroups[myQueuePosition]);

            listNextUserIds.add((Id) myUserGroups[myQueuePosition]);

            // Increment Queue counter
            myQueuePosition++;

            myRRQ.Queue_Position__c = myQueuePosition;
            mapRRName_TQ.put(RRGroupName, myRRQ);

        }
        if (!mapRRName_TQ.isEmpty()) {
            update mapRRName_TQ.values();
        }


        return listNextUserIds;
    }
    public List<Id> getNextRRUsersAssignmentGroup(List<String> listRRGroupNames, set<string> coachList) {

        List<Id> listNextUserIds = new List<Id>();
        system.debug('>>> RoundRobinHelper: size of incoming name list:' + listRRGroupNames.size());

        // Create Map of Assignment_Group_Name__c object
        Map< String, Assignment_Group_Name__c> mapRRName_TQ = new Map< String, Assignment_Group_Name__c>();
        for (Assignment_Group_Name__c myRRQ : [Select Id, Name, Queue_Position__c from Assignment_Group_Name__c where Name in :listRRGroupNames]) {
            mapRRName_TQ.put(myRRQ.Name, myRRQ);
        }
        system.debug('>>> RoundRobinHelper: number of queues/groups pulled from Assignment_Group_Name__c:' + mapRRName_TQ.size());

        // Create Map of < GroupId, Group Names >
        Map<Id, String> mapGrpId_GrpName = new Map<Id, String>();
        for (Assignment_Group_Name__c gp : [Select Id, Name from Assignment_Group_Name__c where name in :listRRGroupNames]) {
            mapGrpId_GrpName.put(gp.Id, gp.name);
        }
        system.debug('>>> RoundRobinHelper: number of SFDC Queues/Groups pulled from:' + mapGrpId_GrpName.size());

        // Create Map of < Group Name, List of Member IDs>
        Map< String, List<Id> > mapGrpName_listMemberIds = new Map< String, List<Id> >();
        for (Assignment_Groups__c myGM : [Select Group_Name__c, User__c From Assignment_Groups__c Where Group_Name__c = :mapGrpId_GrpName.keySet() AND Active__c = 'TRUE' order by createdDate ASC]) {
            system.debug(myGM.User__c);
            //S-23002
            if (coachList != null && !coachList.contains(myGM.User__c)) {
                continue;
            }

            String myGrpName = mapGrpId_GrpName.get(myGM.Group_Name__c);
            if (!mapGrpName_listMemberIds.containsKey(myGrpName)) {
                mapGrpName_listMemberIds.put(myGrpName, new List<Id>{
                        myGM.User__c
                });
                //system.debug('>>> RoundRobinHelper: new mapGrpName_listMemberIds mapping for:'+myGrpName);
            } else {
                List<Id> listMemberIds = mapGrpName_listMemberIds.get(myGrpName);
                //system.debug('>>> RoundRobinHelper: adding group member to group:' + myGrpName);
                listMemberIds.add(myGM.User__c);
                mapGrpName_listMemberIds.put(myGrpName, listMemberIds);
            }
        }
        system.debug('>>> RoundRobinHelper: size of mapGrpName_listMemberIds' + mapGrpName_listMemberIds.size());
        system.debug('>>> RoundRobinHelper: size of mapGrpName_listMemberIds' + listRRGroupNames.size());


        for (String RRGroupName : listRRGroupNames) {
            //system.debug('>>> RoundRobinHelper: Processing Group: ' + RRGroupName);

            if (!mapRRName_TQ.containsKey(RRGroupName)) {
                listNextUserIds.add(null);
                // throw exception in Helper.  As an alternative, comment out throw new MyException
                //   and look for null return values and apply .addError exception in your Handler.
                throw new MyException('No Queue or Public Group ' + RRGroupName + ' defined in Round Robin table.');
                // continue;
            }

            Assignment_Group_Name__c myRRQ = mapRRName_TQ.get(RRGroupName);
            Integer myQueuePosition = (integer) myRRQ.Queue_Position__c;
            //system.debug('>>> RoundRobinHelper: Queue_Position__c for this group: ' + myQueuePosition);
            //S-23002
            if (!mapGrpName_listMemberIds.containsKey(RRGroupName)) {
                continue;
            }
            List<Id> myUserGroups = mapGrpName_listMemberIds.get(RRGroupName);

            // Group may have changed, check if count exceeds # of group members
            if (myQueuePosition >= myUserGroups.size())
                myQueuePosition = 0;

            system.debug('>>> RoundRobinHelper: RESULT Group:' + RRGroupName + '  Size:' + myUserGroups.size() +
                    '  Queue position:' + myQueuePosition + '  Id:' + myUserGroups[myQueuePosition]);

            listNextUserIds.add((Id) myUserGroups[myQueuePosition]);

            // Increment Queue counter
            myQueuePosition++;

            myRRQ.Queue_Position__c = myQueuePosition;
            mapRRName_TQ.put(RRGroupName, myRRQ);

        }
        if (!mapRRName_TQ.isEmpty()) {
            update mapRRName_TQ.values();
        }


        return listNextUserIds;
    }
    
    /*
     * Method to verify if existing coach is in new SP's Program Assignment group; if it is, then the same coach will be assigned to new SP
     * Author: Horacio Sanchez
     * Related Story: S-84371: L2: Keep Tempo Student Assigned to Same Coach if Coach is Part of New Program's Assignment Group
     */
    public Boolean isCoachInNewSPAssignmentGroup(List<String> listRRGroupNames, String previousCoachId) {
        
        // Create Map of < GroupId, Group Names >
        Map<Id, String> mapGrpId_GrpName = new Map<Id, String>();
        for (Assignment_Group_Name__c gp : [SELECT Id, Name FROM Assignment_Group_Name__c WHERE name in :listRRGroupNames]) {
            mapGrpId_GrpName.put(gp.Id, gp.name);
        }
        
        // Getting the group members and comparing if previous coach is one of them
        for (Assignment_Groups__c myGM : [SELECT Group_Name__c, User__c FROM Assignment_Groups__c WHERE Group_Name__c = :mapGrpId_GrpName.keySet() AND Active__c = 'TRUE']) {
            if (myGM.User__c.equals(previousCoachId)) {
                System.debug('*****Previous Coach is in new SP\'s program assignment group: ' + myGM.User__c + ' - ' + previousCoachId);
                return true;
            }
        }
        return false;
    }

}