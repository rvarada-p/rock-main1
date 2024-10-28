/*******************************************************************
Name  : StudentCompetencyTriggerHandler
Author: Vinod (Appirio)
Date  : September 22, 2014
Description: Handler class for the trigger StudentCompetencyTrigger

Revision History
* Horacio Sanchez    01/25/2021     User Story 40038: L2: TOC tool and guest user access update
* Horacio Sanchez     01/27/2021      S-38826: Tempo: Add Preliminary Transfer Credits on Grad and UG degree audit
*************************************************************************/
public without sharing class StudentCompetencyTriggerHandler {
    private set<ID> setCBLRecordTypes;
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public static boolean firstRun = true;
    public static boolean firstRunAfterUpdate = true;

    public StudentCompetencyTriggerHandler(boolean isExecuting, integer size) {
        isExecuting = isExecuting;
        batchSize = size;
        setCBLRecordTypes = Utility.getRecordTypeFromCBLCustomSetting(Student_Competency__c.sObjectType.getDescribe());
    }

    public void onAfterInsert(list<Student_Competency__c > newStudentCompetency) {
        StudentCompetencyHelper objStudentCompetencyHelper = new StudentCompetencyHelper();
        // set to store all the parent Student_Program__c id
        // Used to Roll Up Number Of Competencies
        // related task : T-324637
        set<ID> setStudentProgramID = new set<ID>();
        // set to store all the parent Student_Expertise__c id
        // Used to Roll Up Number Of Completed Competencies and mark as Achieved if all completed
        // related task : T-322650,T-324525
        set<ID> setStudentExpertiseID = new set<ID>();
        set<ID> studentCompetencySkillCheckID = new set<Id>();
        Set<Id> competencyIdSet = new Set<Id>();
        Set<Id> scompIdSet = new Set<Id>();
        for (Student_Competency__c sComp : newStudentCompetency) {
            if (setCBLRecordTypes.contains(sComp.RecordTypeId)) {
                if (sComp.Student_Program__c != null) {
                    setStudentProgramID.add(sComp.Student_Program__c);
                }
                if (sComp.Student_Expertise__c != null) {
                    setStudentExpertiseID.add(sComp.Student_Expertise__c);
                }
                if (sComp.IsCompleted__c) {
                    studentCompetencySkillCheckID.add(scomp.contact__c);
                }
            }
            scompIdSet.add(sComp.Id);
            competencyIdSet.add(sComp.Competency__c);
        }
        List<Student_Competency__c> newsCompList = new List<Student_Competency__c>();
        newsCompList = [Select id, Competency__c from Student_Competency__c where id IN :scompIdSet];
        Map<Id, Id> compVrsnMap = new Map<Id, Id>();
        List<Competency_Version__c> comVsnList = new List<Competency_Version__c>();
        if (!competencyIdSet.isEmpty()) {
            comVsnList = [Select id, Active__c, Competency__c from Competency_Version__c where Competency__c IN :competencyIdSet AND Active__c = true];
            if (!comVsnList.isEmpty()) {
                for (Competency_Version__c comVrObj : comVsnList) {
                    compVrsnMap.put(comVrObj.Competency__c, comVrObj.Id);
                }
                if (!compVrsnMap.isEmpty()) {
                    for (Student_Competency__c sComp : newsCompList) {
                        if (compVrsnMap.containsKey(sComp.Competency__c)) {
                            sComp.Competency_Version__c = compVrsnMap.get(sComp.Competency__c);
                        }
                    }
                    update newsCompList;
                }
            }
        }

        if (!setStudentProgramID.isEmpty()) {
            objStudentCompetencyHelper.rollUpNumberOfCompetenciesOnStudentProgram(setStudentProgramID);
        }
        if (!setStudentExpertiseID.isEmpty()) {
            objStudentCompetencyHelper.rollUpNumberOfCompletedCompetenciesOnStudentExpertise(setStudentExpertiseID);
        }
        if (!studentCompetencySkillCheckID.isEmpty()) {
            objStudentCompetencyHelper.assessSkillCompetencyCompletion(studentCompetencySkillCheckID);
        }
    }

    public void onBeforeInsert(list<Student_Competency__c > newStudentCompetency) {


        StudentCompetencyHelper objStudentCompetencyHelper = new StudentCompetencyHelper();

        List<Student_Competency__c> compsToPopulateSubs = new List<Student_Competency__c >();
        Set<Id> studntPrgmIdSet = new Set<Id>();

        //set RecordType based on related Program
        for (Student_Competency__c sComp : newStudentCompetency) {
            if (sComp.Opportunity__c == null) {
                studntPrgmIdSet.add(sComp.Student_Program__c);
            }
            if (sComp.Program_Competency__c != null) {
                SObjectType objTypeForInstitution = Schema.getGlobalDescribe().get('Student_Competency__c');
                sComp.RecordTypeId = objTypeForInstitution.getDescribe().getRecordTypeinfosByName().get(sComp.Program_Institution__c).getRecordTypeId();
            }

            if (sComp.Completed_Date__c != null && sComp.Student_Program__c != null) {
                compsToPopulateSubs.add(sComp);
            }
        }

        Map<Id, Student_Program__c> stdntPrmMap = new Map<Id, Student_Program__c>([Select id, Application__c from Student_Program__c where id in :studntPrgmIdSet]);

        //list to use fro the task T-321152 work
        list<Student_Competency__c> selectedCompetency = new list<Student_Competency__c>();
        set<ID> setProgramCometency = new set<ID>();
        // get Student_Competency__c recordtyes

        for (Student_Competency__c sCompetency : newStudentCompetency) {
            if (sCompetency.Opportunity__c == null && stdntPrmMap.containsKey(sCompetency.Student_Program__c)) {
                sCompetency.Opportunity__c = stdntPrmMap.get(sCompetency.Student_Program__c).Application__c;
            }

            //Task: T-321152
            // IF RecordType is in the CBLProcessesRecordTypeIds for CBL Processes Custom Setting 
            // Student_Expertise__c is null and Program_Competency__c is not null.
            if (setCBLRecordTypes.contains(sCompetency.RecordTypeId) && sCompetency.Student_Expertise__c == null && sCompetency.Program_Competency__c != null && sCompetency.Contact__c != null) {
                selectedCompetency.add(sCompetency);
                setProgramCometency.add(sCompetency.Program_Competency__c);
            }
        }
        if (!selectedCompetency.isEmpty()) {
            // populate  Student_Expertise__c
            // Relate task: T-321152
            objStudentCompetencyHelper.populateStudentExpertise(selectedCompetency, setProgramCometency);
        }

        if (compsToPopulateSubs != null && compsToPopulateSubs.size() > 0) {
            objStudentCompetencyHelper.populateStudentSubscription(compsToPopulateSubs);
        }

    }

    public void onBeforeUpdate(list<Student_Competency__c > newStudentCompetency, map<ID, Student_Competency__c>oldMap) {
        List<Student_Competency__c> compsToPopulateSubs = new List<Student_Competency__c >();
        StudentCompetencyHelper objStudentCompetencyHelper = new StudentCompetencyHelper();
        System.debug('Comp Size: ' + newStudentCompetency.size() + ' Student Comps ' + newStudentCompetency);
        //check for recursion and only run the update once
        if (StudentCompetencyTriggerHandler.firstRun) {
            StudentCompetencyTriggerHandler.firstRun = false;
            //WebSolo RR assignment code - this only runs in non-bulk mode
            if (newStudentCompetency.size() == 1) {
                Student_Competency__c sc = newStudentCompetency[0];
                System.debug(' SME ' + sc.SME__c + ' Assessment Submitted ' + sc.Assessment_Submitted__c + ' Old Self Assessment ' + oldMap.get(sc.id).Assessment_Submitted__c + ' TBYB ' + sc.Available_for_Try_Before_You_Buy__c + ' sc.CLP_Active__c ' + ' SME__c ' + sc.SME__c);

                if ((sc.Assessment_Submitted__c && !oldMap.get(sc.id).Assessment_Submitted__c) && sc.SME__c == null) {

                    Id groupAssig = null;

                    Integer timeNow, timeStart, timeEnd;
                    timeNow = Integer.ValueOf(System.now().hour());
                    if (Integer.ValueOf(System.now().minute()) != 0) {
                        timeNow = timeNow + 1;
                        if (timeNow == 24) {
                            timeNow = 0;
                        }
                    }

                    List<Competency__c> compList = [SELECT Assignment_Group_CST__c,Assignment_Group_CST__r.Start_Assignment_Time__c,Assignment_Group_CST__r.End_Assignment_Time__c FROM Competency__c WHERE id = :newStudentCompetency[0].Competency__c AND Assignment_Group_CST__r.Status__c = 'Active'];
                    if (compList.size() != 0) {
                        timeStart = (compList[0].Assignment_Group_CST__r.Start_Assignment_Time__c == '12AM' ? 0 : (compList[0].Assignment_Group_CST__r.Start_Assignment_Time__c == '12PM' ? 12 : compList[0].Assignment_Group_CST__r.Start_Assignment_Time__c.contains('AM') ? Integer.valueOf(compList[0].Assignment_Group_CST__r.Start_Assignment_Time__c.substring(0, compList[0].Assignment_Group_CST__r.Start_Assignment_Time__c.length() - 2)) : Integer.valueOf(compList[0].Assignment_Group_CST__r.Start_Assignment_Time__c.substring(0, compList[0].Assignment_Group_CST__r.Start_Assignment_Time__c.length() - 2)) + 12));
                        timeEnd = (compList[0].Assignment_Group_CST__r.End_Assignment_Time__c == '12AM' ? 0 : (compList[0].Assignment_Group_CST__r.End_Assignment_Time__c == '12PM' ? 12 : compList[0].Assignment_Group_CST__r.End_Assignment_Time__c.contains('AM') ? Integer.valueOf(compList[0].Assignment_Group_CST__r.End_Assignment_Time__c.substring(0, compList[0].Assignment_Group_CST__r.End_Assignment_Time__c.length() - 2)) : Integer.valueOf(compList[0].Assignment_Group_CST__r.End_Assignment_Time__c.substring(0, compList[0].Assignment_Group_CST__r.End_Assignment_Time__c.length() - 2)) + 12));
                        if (timeStart < timeEnd) {
                            if (timeNow <= timeEnd && timeNow > timeStart) {
                                groupAssig = compList[0].Assignment_Group_CST__c;
                            }
                        } else if (timeStart > timeEnd) {
                            if ((timeNow > timeEnd && timeNow > timeStart) || (timeNow <= timeEnd && timeNow < timeStart)) {
                                groupAssig = compList[0].Assignment_Group_CST__c;
                            }
                        } else if (timeStart == timeEnd) {
                            groupAssig = compList[0].Assignment_Group_CST__c;
                        }
                    }
                    objStudentCompetencyHelper.groupAssignment(newStudentCompetency, groupAssig);
                }
            }
        }


        //Populate the FWK links and Student Subscription achieved in lookup    
        for (Student_Competency__c sCompetency : newStudentCompetency) {


            if (sCompetency.Status__c != oldMap.get(sCompetency.id).Status__c && sCompetency.Assessment_Submitted_Date__c != null &&
                    (sCompetency.Status__c == 'Achieved' || sCompetency.Status__c == 'Mastered')) {

                sCompetency.Completed_Date__c = sCompetency.Assessment_Submitted_Date__c ;
                sCompetency.IsCompleted__c = True;

            }

            if ((sCompetency.Completed_Date__c != oldMap.get(sCompetency.id).Completed_Date__c || sCompetency.Student_Program__c != oldMap.get(sCompetency.id).Student_Program__c)
                    && sCompetency.Completed_Date__c != null && sCompetency.Student_Program__c != null) {
                compsToPopulateSubs.add(sCompetency);
            } else if (sCompetency.Completed_Date__c == null || sCompetency.Student_Program__c == null) {
                sCompetency.Student_Subscription_Achieved_In__c = null;
            }
            //To populate the Resume Competency Date when the Pause Competency is un-checked
            if (sCompetency.Pause_Competency__c != oldMap.get(sCompetency.id).Pause_Competency__c && sCompetency.Pause_Competency__c != true) {
                sCompetency.Resume_Competency_Date__c = System.today();
            }

            if (sCompetency.Pause_Competency__c != oldMap.get(sCompetency.id).Pause_Competency__c && sCompetency.Pause_Competency__c != true) {
                sCompetency.Resume_Competency_Date__c = System.today();
            }

        }


        if (compsToPopulateSubs != null && compsToPopulateSubs.size() > 0) {
            objStudentCompetencyHelper.populateStudentSubscription(compsToPopulateSubs);
        }


    }

    public void onAfterUpdate(list<Student_Competency__c > newStudentCompetency, map<ID, Student_Competency__c>oldMap) {

        System.debug('newStudentCompetency' + newStudentCompetency.size());

        StudentCompetencyHelper objStudentCompetencyHelper = new StudentCompetencyHelper();
        StudentProgramHelper stuProgHelper = new StudentProgramHelper();

        // set to store all the parent Student_Expertise__c id
        // Used to Roll Up Number Of Completed Competencies
        // related task : T-322650
        set<ID> setStudentExpertiseID = new set<ID>();

        // set to store all the parent Student_Program__c id
        // Used to Roll Up Number Of Completed Competencies
        // related task : T-324637
        set<ID> setCBLStudentProgramID = new set<ID>();
        set<ID> setStudentProgramID = new set<ID>();
        map<ID, list<Student_Competency__c>>selectedStudentprogramWithStudentCompetency = new map<ID, list<Student_Competency__c>>();
        set<ID> setSelectedStudentProgramID = new set<ID>();
        set<id> studentCompetencySkillCheckID = new set<id>();
        //Related task: T-337411
        set<ID> setOpportunityIds = new set<ID>();

        // Set - Related User Story: 19654. Sprint 2020.3.4
        // Tempo: Convert first competency completed process flow to trigger
        Set<Id> setUpdateFirstCompetencyStartedCount = new Set<Id>();

        //Related Task: T-398060
        Map<Id, Integer> competencyStatusChangedForProgram = new Map<Id, Integer>();

        List<Id> stuCompEngagementUpdatedPlan = new List<Id>();
        for (Student_Competency__c sCompetency : newStudentCompetency) {
            Student_Competency__c oldComp = oldMap.get(sCompetency.ID);
            if (setCBLRecordTypes.contains(sCompetency.RecordTypeId)) {

                // S-38826: Tempo: Add Preliminary Transfer Credits on Grad and UG degree audit
                // Added Status check to include Preliminary Transfer credits
                if (sCompetency.Student_Program__c != null && (sCompetency.IsCompleted__c != oldComp.IsCompleted__c || sCompetency.Pseudo_CE__c != oldComp.Pseudo_CE__c || sCompetency.Status__c != oldComp.Status__c)) {
                    setCBLStudentProgramID.add(sCompetency.Student_Program__c);
                }

                if (sCompetency.Pseudo_CE__c != oldComp.Pseudo_CE__c) {
                    if (sCompetency.Student_Expertise__c != null) {
                        setStudentExpertiseID.add(sCompetency.Student_Expertise__c);
                    }
                }

                // TBD: also look for status change or Completed date change - in all these cases, rollups should be recalculated
                if (sCompetency.IsCompleted__c != oldComp.IsCompleted__c) {
                    //Task: T-322650
                    if (sCompetency.Student_Expertise__c != null) {
                        setStudentExpertiseID.add(sCompetency.Student_Expertise__c);
                    }
                    // T-324637 
                    if (sCompetency.Student_Program__c != null) {
                        setStudentProgramID.add(sCompetency.Student_Program__c);
                    }

                    //T-398060 
                    if (sCompetency.Competency_Type__c != 'Academic' && sCompetency.IsCompleted__c == true) {
                        if (!competencyStatusChangedForProgram.containsKey(sCompetency.Student_Program__c)) {
                            competencyStatusChangedForProgram.put(sCompetency.Student_Program__c, 1);
                        } else {
                            Integer noOfComp = competencyStatusChangedForProgram.get(sCompetency.Student_Program__c) + 1;
                            competencyStatusChangedForProgram.put(sCompetency.Student_Program__c, noOfComp);
                        }

                    } else if (sCompetency.Competency_Type__c != 'Academic' && sCompetency.IsCompleted__c == false) {
                        if (!competencyStatusChangedForProgram.containsKey(sCompetency.Student_Program__c)) {
                            competencyStatusChangedForProgram.put(sCompetency.Student_Program__c, -1);
                        } else {
                            Integer noOfComp = competencyStatusChangedForProgram.get(sCompetency.Student_Program__c) - 1;
                            competencyStatusChangedForProgram.put(sCompetency.Student_Program__c, noOfComp);
                        }
                    }

                    studentCompetencySkillCheckID.add(sCompetency.contact__c);
                }

            }
            if (setCBLRecordTypes.contains(sCompetency.RecordTypeId)) {
                //Related task: T-337411
                system.debug('sCompetency.Opportunity__c:::::::::' + sCompetency.Opportunity__c);
                system.debug('sCompetency.Competency_Type__c:::::::::' + sCompetency.Competency_Type__c);
                system.debug('sCompetency.Status__c:::::::::' + sCompetency.Status__c);
                system.debug('oldComp.Status__c:::::::::' + oldComp.Status__c);

                //Sarah - Changed to include non-academic in Query sCompetency.Competency_Type__c == 'Academic' 
                if (sCompetency.Opportunity__c != null && (sCompetency.Competency_Type__c == 'Non-Academic' || sCompetency.Competency_Type__c == 'Academic') &&
                        (sCompetency.Status__c != oldComp.Status__c
                                && (sCompetency.Status__c == 'Mastered' || sCompetency.Status__c == 'Achieved'
                                || oldComp.Status__c == 'Mastered' || oldComp.Status__c == 'Achieved'))) {

                    setOpportunityIds.add(sCompetency.Opportunity__c);

                }
            }
            if (sCompetency.Start_Date__c != oldMap.get(sCompetency.id).Start_Date__c || sCompetency.Target_Date__c != oldMap.get(sCompetency.id).Target_Date__c) {
                if (sCompetency.Student_Program__c != null) {
                    stuCompEngagementUpdatedPlan.add(sCompetency.Student_Program__c);
                }
            }

            // Set - Related User Story: 19654. Sprint 2020.3.4
            // Tempo: Convert first competency completed process flow to trigger
            if (oldComp.Status__c != sCompetency.Status__c &&
                    (sCompetency.Status__c == 'Achieved' || sCompetency.Status__c == 'Mastered' || sCompetency.Status__c == 'Not Achieved')) {
                setUpdateFirstCompetencyStartedCount.add(sCompetency.Id);
            }
        }


        //check for recursion and only run the update once
        if (StudentCompetencyTriggerHandler.firstRunAfterUpdate) {
            StudentCompetencyTriggerHandler.firstRunAfterUpdate = false ;
            if (!studentCompetencySkillCheckID.isEmpty()) {
                objStudentCompetencyHelper.assessSkillCompetencyCompletion(studentCompetencySkillCheckID);//SC update
            }
            if (!setCBLStudentProgramID.isEmpty()) {
                objStudentCompetencyHelper.rollUpNumberOfCompetenciesOnStudentProgram(setCBLStudentProgramID); //SP update
            }

            if (!setStudentProgramID.isEmpty()) {
                objStudentCompetencyHelper.rollUpCompletedCompetenciesOnCurrentAndPriorSubscription(setStudentProgramID);// SUB update
            }

        }



        //  Roll Up Number Of Completed Competencies on selected StudentExpertise
        if (!setStudentExpertiseID.isEmpty()) {
            objStudentCompetencyHelper.rollUpNumberOfCompletedCompetenciesOnStudentExpertise(setStudentExpertiseID); // SE update
        }

        //T-398060
        if (!competencyStatusChangedForProgram.isEmpty()) {
            //objStudentCompetencyHelper.updateNonAcedemicCompletedCompOnStuProg(competencyStatusChangedForProgram);//SP Update
        }

        system.debug('setOpportunityIds::::::::' + setOpportunityIds);
        if (!setOpportunityIds.isEmpty()) {
            // objStudentCompetencyHelper.rollUpNumberOfCompletedCompetenciesInTrial(setOpportunityIds); //Opp Update 
        }


        if (!stuCompEngagementUpdatedPlan.isEmpty()) {
            stuProgHelper.logStudentEngagementByType(stuCompEngagementUpdatedPlan, 'Submitted or Updated Plan', null); // Eng Rule Update
        }

        // Set - Related User Story: 19654. Sprint 2020.3.4
        // Tempo: Convert first competency completed process flow to trigger
        if (!setUpdateFirstCompetencyStartedCount.isEmpty()) {
            objStudentCompetencyHelper.updateFirstCompetencyStartedCount(setUpdateFirstCompetencyStartedCount);
        }

    }

    public void onAfterDelete(list<Student_Competency__c > newStudentCompetency) {
        StudentCompetencyHelper objStudentCompetencyHelper = new StudentCompetencyHelper();
        // set to store all the parent Student_Program__c id
        // Used to Roll Up Number Of Competencies
        // related task : T-324637
        set<ID> setStudentProgramID = new set<ID>();
        // set to store all the parent Student_Expertise__c id
        // Used to Roll Up Number Of Completed Competencies
        // related task : T-322650
        set<ID> setStudentExpertiseID = new set<ID>();
        set<id> studentCompetencySkillCheckID = new set<id>();
        //Related task: T-337411
        set<ID> setOpportunityIds = new set<ID>();
        for (Student_Competency__c sComp : newStudentCompetency) {
            if (setCBLRecordTypes.contains(sComp.RecordTypeId)) {
                system.debug('sComp.Opportunity__c:::::::::' + sComp.Opportunity__c);
                system.debug('sComp.Competency_Type__c:::::::::' + sComp.Competency_Type__c);
                system.debug('sComp.Status__c:::::::::' + sComp.Status__c);

                if (sComp.Student_Program__c != null) {
                    setStudentProgramID.add(sComp.Student_Program__c);
                }
                if (sComp.Student_Expertise__c != null) {
                    setStudentExpertiseID.add(sComp.Student_Expertise__c);
                }
                if (sComp.IsCompleted__c) {
                    studentCompetencySkillCheckID.add(sComp.contact__c);
                }
                //Related task: T-337411
                if (sComp.Opportunity__c != null && (sComp.Competency_Type__c == 'Non-Academic' || sComp.Competency_Type__c == 'Academic') &&
                        (sComp.Status__c == 'Mastered' || sComp.Status__c == 'Achieved')) {
                    // roll up the total competency on oppertunity
                    setOpportunityIds.add(sComp.Opportunity__c);
                }
            }
        }
        if (!setStudentProgramID.isEmpty()) {
            objStudentCompetencyHelper.rollUpNumberOfCompetenciesOnStudentProgram(setStudentProgramID);
            //  T-324627
            //objStudentCompetencyHelper.rollUpNumberOfCompletedCompetenciesOnCurrentStudentSubscription(setStudentProgramID);
            objStudentCompetencyHelper.rollUpCompletedCompetenciesOnCurrentAndPriorSubscription(setStudentProgramID);

        }
        if (!setStudentExpertiseID.isEmpty()) {
            //  T-322650,T-324525
            objStudentCompetencyHelper.rollUpNumberOfCompletedCompetenciesOnStudentExpertise(setStudentExpertiseID);
        }
        if (!studentCompetencySkillCheckID.isEmpty()) {
            objStudentCompetencyHelper.assessSkillCompetencyCompletion(studentCompetencySkillCheckID);
        }
        if (!setOpportunityIds.isEmpty()) {
            // objStudentCompetencyHelper.rollUpNumberOfCompletedCompetenciesInTrial(setOpportunityIds);
        }

    }

    public void onAfterUnDelete(list<Student_Competency__c > newStudentCompetency) {
        StudentCompetencyHelper objStudentCompetencyHelper = new StudentCompetencyHelper();
        // set to store all the parent Student_Program__c id
        // Used to Roll Up Number Of Competencies
        // related task : T-324637
        set<ID> setStudentProgramID = new set<ID>();
        // set to store all the parent Student_Expertise__c id
        // Used to Roll Up Number Of Completed Competencies
        // related task : T-322650
        set<ID> setStudentExpertiseID = new set<ID>();
        set<id> studentCompetencySkillCheckID = new set<id>();
        //Related task: T-337411
        set<ID> setOpportunityIds = new set<ID>();
        for (Student_Competency__c sComp : newStudentCompetency) {
            if (setCBLRecordTypes.contains(sComp.RecordTypeId)) {
                if (sComp.Student_Program__c != null) {
                    setStudentProgramID.add(sComp.Student_Program__c);
                }
                if (sComp.Student_Expertise__c != null) {
                    setStudentExpertiseID.add(sComp.Student_Expertise__c);
                }
                if (sComp.IsCompleted__c) {
                    studentCompetencySkillCheckID.add(sComp.contact__c);
                }
                //Related task: T-337411
                if (sComp.Opportunity__c != null && (sComp.Competency_Type__c == 'Non-Academic' || sComp.Competency_Type__c == 'Academic') &&
                        (sComp.Status__c == 'Mastered' || sComp.Status__c == 'Achieved')) {
                    // roll up the total competency on oppertunity
                    setOpportunityIds.add(sComp.Opportunity__c);
                }
            }
        }
        if (!setStudentProgramID.isEmpty()) {
            objStudentCompetencyHelper.rollUpNumberOfCompetenciesOnStudentProgram(setStudentProgramID);
            //  T-324627
            //objStudentCompetencyHelper.rollUpNumberOfCompletedCompetenciesOnCurrentStudentSubscription(setStudentProgramID);
            objStudentCompetencyHelper.rollUpCompletedCompetenciesOnCurrentAndPriorSubscription(setStudentProgramID);

        }
        if (!setStudentExpertiseID.isEmpty()) {
            //  T-322650,T-324525
            objStudentCompetencyHelper.rollUpNumberOfCompletedCompetenciesOnStudentExpertise(setStudentExpertiseID);
        }
        if (!studentCompetencySkillCheckID.isEmpty()) {
            objStudentCompetencyHelper.assessSkillCompetencyCompletion(studentCompetencySkillCheckID);
        }
        if (!setOpportunityIds.isEmpty()) {
            //objStudentCompetencyHelper.rollUpNumberOfCompletedCompetenciesInTrial(setOpportunityIds);
        }
    }

}