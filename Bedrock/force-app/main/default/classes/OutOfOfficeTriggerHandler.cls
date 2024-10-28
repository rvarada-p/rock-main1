/*******************************************************************
Name  : OutOfOfficeTriggerHandler
Author: Ravitej Varada
Date  : Oct 19, 2020
Description: Handler class for the Trigger OutOfOfficeTrigger. It should simply delegate based on business.

Revision History :

Ravitej Varada -   04/30/2021 -     S-51220     Coach Out of office functionality isn't working
 *************************************************************************/
//28110- Coach Out of office Trigger Logic Created
public with sharing class OutOfOfficeTriggerHandler {
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public static boolean firstRun = true;

    public OutOfOfficeTriggerHandler(boolean isExecuting, integer size) {
        isExecuting = isExecuting;
        batchSize = size;
    }

    public void afterInsert(list<Out_of_Office__c> newOutOfOffice) {
        //28110
        list<Out_of_Office__c> outOfOfficeLst = new list<Out_of_Office__c>();
        Map<id, Out_of_Office__c> usedWithOooMap = new Map<id, Out_of_Office__c>();

        for (Out_of_Office__c ooo : newOutOfOffice) {
            date todayDate = system.today();
            If (todayDate >= ooo.Absence_Start_Date__c && todayDate <= ooo.Absence_End_Date__c) {
                outOfOfficeLst.add(ooo);
                usedWithOooMap.put(ooo.User__c, ooo);
            }
        }

        list<Coach_Assignment__c> updateCoachAssignment = new list<Coach_Assignment__c>();
        if (!outOfOfficeLst.isEmpty()) {
            For (Coach_Assignment__c coachAsg : [SELECT Id,Name, Coach__c,Status__c FROM coach_Assignment__c WHERE Coach__c IN:usedWithOooMap.keySet()]) {
                if (usedWithOooMap.get(coachAsg.coach__c).status__c == 'Active') {
                    coachAsg.Status__c = 'Active';
                } else If (usedWithOooMap.get(coachAsg.coach__c).status__c == 'Inactive') {
                    coachAsg.Status__c = 'Inactive';
                }
                updateCoachAssignment.add(coachAsg);
            }
        }

        if (!updateCoachAssignment.isEmpty()) {
            Update updateCoachAssignment;
        }
    }

    public void afterUpdate(list<Out_of_Office__c> newOutOfOffice, map<ID, Out_of_Office__c> oldMap) {

    }
    public void beforeUpdate(list<Out_of_Office__c> newOutOfOffice, map<ID, Out_of_Office__c> oldMap) {
        list<Out_of_Office__c> outOfOfficeLst = new list<Out_of_Office__c>();
        Map<id, Out_of_Office__c> usedWithOooMap = new Map<id, Out_of_Office__c>();

        for (Out_of_Office__c ooo : newOutOfOffice) {
            Out_of_Office__c oldOutOfOfficeValue = oldMap.get(ooo.id);
            If (ooo.Status__c != oldOutOfOfficeValue.status__c) {
                outOfOfficeLst.add(ooo);
                usedWithOooMap.put(ooo.User__c, ooo);
            }
        }
        list<Coach_Assignment__c> updateCoachAssignment = new list<Coach_Assignment__c>();
        if (!outOfOfficeLst.isEmpty()) {
            For (Coach_Assignment__c coachAsg : [SELECT Id,Name, Coach__c,Status__c FROM coach_Assignment__c WHERE Coach__c IN:usedWithOooMap.keySet()]) {
                if (usedWithOooMap.get(coachAsg.coach__c).status__c == 'Active') {
                    coachAsg.Status__c = 'Active';
                } else If (usedWithOooMap.get(coachAsg.coach__c).status__c == 'Inactive') {
                    coachAsg.Status__c = 'Inactive';
                }
                updateCoachAssignment.add(coachAsg);
            }
        }

        if (!updateCoachAssignment.isEmpty()) {
            Update updateCoachAssignment;
        }
    }

    public void beforeInsert(list<Out_of_Office__c> newOutOfOffice) {
        Map<id, id> coachWithCoachAssignmenMap = new Map<Id, Id>();
        For (coach_Assignment__c coach : [SELECT id,name,coach__c FROM Coach_Assignment__c]) {
            coachWithCoachAssignmenMap.put(coach.id, coach.coach__c);
        }
        for (Out_of_Office__c ooo : newOutOfOffice) {
            If (ooo.Coach_Assignment__c != null) {
                ooo.User__c = coachWithCoachAssignmenMap.get(ooo.Coach_Assignment__c);
            }
            //S-51220
            If(ooo.Absence_Start_Date__c == System.TODAY()){
                ooo.Status__c = 'Inactive';
            }else If(ooo.Absence_Start_Date__c > System.TODAY()){
                ooo.Status__c = 'Active';
            }else If(ooo.Absence_Start_Date__c < System.TODAY()){
                ooo.addError('Absence Start Date cannot be less than today');
            } 
            //S-51220
        }
    }


}