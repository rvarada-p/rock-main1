/************************************************************************
Name  : BatchProcessCoachAssignment
Author: Ravitej Varada
Date  : September 24, 2020
Description: Batch Class to Calculate the Coach Assignment Rollups

Revision History:
Ravitej Varada      - oct 12th 2020 -  S-23002 - Coach Assignment Logic change from program to stand alone(Enhancement)

*************************************************************************/

global class BatchProcessCoachAssignment implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String SOQL;
        SOQL = 'SELECT id,To_be_Assigned__c,coach__r.Name,Program_Names__c, Active_Students__c,Total_Assignments__c,Coach__c FROM Coach_Assignment__c';
        return Database.getQueryLocator(SOQL);
    }

    global void execute(SchedulableContext SC) {
        BatchProcessCoachAssignment objBatch = new BatchProcessCoachAssignment();
        ID batchprocessid = Database.executeBatch(objBatch, 200);
    }

    global void execute(Database.BatchableContext BC, List<Coach_Assignment__c> scope) {
        system.debug('spLst' + scope);
        map<string, integer> programIdWithCoachWithActiveMap = new map<string, integer>();

        for (Student_Program__c stuProg : [
                SELECT Id,Application__r.Name,Time_Status__c,Coach__r.Name,Application__r.StageName, Student_Status__c, Student__c,Parent_Program__c,Student_Full_Name__c, IsStudentProgramActive__c
                FROM Student_Program__c
                WHERE Coach__c <> Null
                AND (IsStudentProgramActive__c = TRUE OR Application__r.StageName = 'Student' )
                AND Coach__r.Name <> 'Walden Coach' AND (NOT Student_Full_Name__c LIKE 'zz__%')
                AND (NOT Student_Full_Name__c LIKE '%Test%') AND (NOT Student_Full_Name__c LIKE '%bannertest%')
                AND (NOT Student_Full_Name__c LIKE '%zz smoke%') and (NOT Student_Full_Name__c LIKE '%demolaureate%')
                AND (NOT Student_Full_Name__c LIKE '%smoketest%') AND Time_Status__c = 'Full-Time'
        ]) {
            if (stuProg.IsStudentProgramActive__c) {
                if (!programIdWithCoachWithActiveMap.containsKey(stuProg.Coach__r.Name + 'Active')) {
                    programIdWithCoachWithActiveMap.put(stuProg.Coach__r.Name + 'Active', 0);
                }
                programIdWithCoachWithActiveMap.put(stuProg.Coach__r.Name + 'Active', programIdWithCoachWithActiveMap.get(stuProg.Coach__r.Name + 'Active') + 1);
            }
            if (!stuProg.IsStudentProgramActive__c && stuProg.Application__r.StageName == 'Student' && stuProg.Time_Status__c == 'Full-Time') {
                if (!programIdWithCoachWithActiveMap.containsKey(stuProg.Coach__r.Name + 'InActive')) {
                    programIdWithCoachWithActiveMap.put(stuProg.Coach__r.Name + 'InActive', 0);
                }
                programIdWithCoachWithActiveMap.put(stuProg.Coach__r.Name + 'InActive', programIdWithCoachWithActiveMap.get(stuProg.Coach__r.Name + 'InActive') + 1);
            }
        }

        System.debug(programIdWithCoachWithActiveMap);

        List<Coach_Assignment__c> coachAssignmentsToUpdate = new List<Coach_Assignment__c>();

        for (Coach_Assignment__c coach : scope) {
            Coach_Assignment__c coachAssignment = new Coach_Assignment__c();
            coachAssignment.id = coach.id;

            if (programIdWithCoachWithActiveMap.containsKey(coach.Coach__r.Name + 'Active')) {
                system.debug('******' + coach.Coach__r.Name + 'Active');
                coachAssignment.Active_Students__c = programIdWithCoachWithActiveMap.get(coach.Coach__r.Name + 'Active');
            } else {
                coachAssignment.Active_Students__c = 0;

            }
            if (programIdWithCoachWithActiveMap.containsKey(coach.Coach__r.Name + 'InActive')) {
                system.debug('******' + coach.Coach__r.Name + 'InActive');
                coachAssignment.To_be_Assigned__c = programIdWithCoachWithActiveMap.get(coach.Coach__r.Name + 'InActive');
            } else {
                coachAssignment.To_be_Assigned__c = 0;
            }
            coachAssignmentsToUpdate.add(coachAssignment);
        }

        system.debug(coachAssignmentsToUpdate);
        if (!coachAssignmentsToUpdate.isEmpty()) {
            update coachAssignmentsToUpdate;
        }

    }

    global void finish(Database.BatchableContext BC) {

    }


}