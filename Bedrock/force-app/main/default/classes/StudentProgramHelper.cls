/************************************************************************
Name  : StudentProgramHelper
Author: Vinod, Tom, Vinay (Appirio)
Date  : September 24, 2014
Description: Helper class for the object Student Program

Declared WITHOUT SHARING to avoid Approval Process record locking

Revision History:
Ravitej Varada      - Aug 25th 2020 -  S-22933 - Program Level PreReq Logic to Unlock once the required Credits are completed
Ravitej Varada      - Sep 20th 2020 -  S-23002 - Coach Assignment when opp.Stage= Student
Ravitej Varada      - oct 12th 2020 -  S-23002 - Coach Assignment Logic change from program to stand alone(Enhancement)
Ravitej Varada      - Dec 02th 2020 -  S-28111- Tempo: Alumni and reinstatement student coach assignment
Horacio Sanchez     - Dec 14th 2020 -  Prod Defect 36816: Tempo: Coach Assignment in Bspace
Horacio Sanchez		- Jan 14th 2021 -  S-38827: Tempo: Degree Audit: Max time completion update
* Sufia                     6/23/2021                 S-685236 Update Existing Pre-requisite Logic for RN to MSN Programs
Horacio Sanchez     - Jun 23th 2021 -  Bug 56561: Without Admin Attributes Technical Difficulties error is displayed - Till Admin attributes created
Horacio Sanchez     - Apr 27th 2022 -  S-84371: L2: Keep Tempo Student Assigned to Same Coach if Coach is Part of New Program's Assignment Group
*************************************************************************/
public without sharing class StudentProgramHelper {

    public static set<Id> newStudentProgramIdSet = new set<Id>();

    public void createStudentEnrollmentSteps(list<Student_Program__c> newStudentProgram, set<ID> programeIds) { 
        // get selected program instition
        system.debug('in createStudentEnrollmentSteps');
        map<ID, ID> mapProgramIdwithInstitutionId = new map<ID, ID>();
        for (Product2 pro : [Select Institution__c, Id From Product2 where Id in:programeIds and Institution__c != null]) {
            mapProgramIdwithInstitutionId.put(pro.ID, pro.Institution__c);
        }
        if (!mapProgramIdwithInstitutionId.isEmpty()) {
            // get all Student_Enrollment_Steps__c for the selected Instition
            map<ID, list<Enrollment_Steps__c>> mapInstitutionWithAllEnrollmentSteps = new map<ID, list<Enrollment_Steps__c>>();
            for (Enrollment_Steps__c eStep : [Select Institution__c, Id, Enrollment_Step_Name__c From Enrollment_Steps__c where Institution__c in:mapProgramIdwithInstitutionId.values()]) {
                if (!mapInstitutionWithAllEnrollmentSteps.containsKey(eStep.Institution__c)) {
                    mapInstitutionWithAllEnrollmentSteps.put(eStep.Institution__c, new list<Enrollment_Steps__c>());
                }
                mapInstitutionWithAllEnrollmentSteps.get(eStep.Institution__c).add(eStep);
            }
            system.debug('Found EnrollmentSteps to become StudentEnrollmentSteps');
            if (!mapInstitutionWithAllEnrollmentSteps.isEmpty()) {
                // create Student_Enrollment_Steps__c record for the selected Student_Program__c
                list<Student_Enrollment_Steps__c> lstStudentEnrollmentSteps = new list<Student_Enrollment_Steps__c>();
                for (Student_Program__c sprog : newStudentProgram) {
                    system.debug('Iterating new SPs for creating StudentEnrollmentSteps');
                    if (mapProgramIdwithInstitutionId.containsKey(sprog.Program__c)) {
                        //
                        Id institutionId = mapProgramIdwithInstitutionId.get(sprog.Program__c);
                        if (mapInstitutionWithAllEnrollmentSteps.containsKey(institutionId)) {
                            // now create Student_Enrollment_Steps__c for all the Enrollment_Steps__c
                            for (Enrollment_Steps__c enrolStep : mapInstitutionWithAllEnrollmentSteps.get(institutionId)) {
                                // create Student_Enrollment_Steps__c record
                                Student_Enrollment_Steps__c newSES = new Student_Enrollment_Steps__c();
                                newSES.Student_Program__c = sprog.id;
                                newSES.Name = enrolStep.Enrollment_Step_Name__c;
                                newSES.Enrollment_Step_Name__c = enrolStep.Enrollment_Step_Name__c;
                                lstStudentEnrollmentSteps.add(newSES);
                                system.debug('Creating a StudentEnrollmentStep and adding to list for insert');
                            }
                        }
                    }
                }
                if (!lstStudentEnrollmentSteps.isEmpty()) {
                    system.debug('about to insert createStudentEnrollmentSteps');
                    insert lstStudentEnrollmentSteps;
                }
            }
        }

    }
    /*******************************************************************
Method to Update the Student Program lookup field to point at the new Student Program
Related Task: T-324358
********************************************************************/
    public void bindStudentDiscountWithStudentProgram(list<Student_Program__c> newStudentProgram, set<ID> setOpportunityID) {

        // now get all chile Student Discount of the Admitted Opportunity
        map<ID, list<Student_Discount__c>> mapOpportunityWithStudentDiscount = new map<ID, list<Student_Discount__c>>();
        for (Student_Discount__c sd : [
                Select id,Student_Program__c,Opportunity__c
                from Student_Discount__c
                where Opportunity__c in:setOpportunityID
                and Opportunity__r.StageName = 'Admitted'
        ]) {
            if (!mapOpportunityWithStudentDiscount.containsKey(sd.Opportunity__c)) {
                mapOpportunityWithStudentDiscount.put(sd.Opportunity__c, new list<Student_Discount__c>());
            }
            mapOpportunityWithStudentDiscount.get(sd.Opportunity__c).add(sd);
        }
        // map the selected Student Discount with newly created Student Program
        list<Student_Discount__c> lstStudenDiscounts = new list<Student_Discount__c>();
        for (Student_Program__c sProgram : newStudentProgram) {
            // check StudentProgram's opportunity is admitted and has  Student Discount
            if (mapOpportunityWithStudentDiscount.containsKey(sProgram.Application__c)) {
                // get all the discount
                for (Student_Discount__c sd : mapOpportunityWithStudentDiscount.get(sProgram.Application__c)) {
                    // populate the Student Program lookup
                    sd.Student_Program__c = sProgram.id;
                    lstStudenDiscounts.add(sd);
                    newStudentProgramIdSet.add(sProgram.Id);
                }
            }
        }
        if (!lstStudenDiscounts.isEmpty()) {
            update lstStudenDiscounts;
        }
    }

    /*******************************************************************
Method to populate Start Date on the child Student Subscription
when only one initial Student_Subscription__c record has been created.
The purpose of this is to keep the Sub Start Date in sync with the
Program Start Date declared on the Student Program (student's first start)
Related Task: T-331926
********************************************************************/
    public void populateStartDateOnStudentSubscription(set<ID>setContactIdrameID) {
        list<Student_Subscription__c> lstStudentSubscription = new list<Student_Subscription__c >();
        for (Student_Program__c sp : [
                Select Program_Start_Date__r.Start_Date__c, Program_Start_Date__c, Id, (Select Id,Start_Date__c,Change_Reason__c From Subscriptions__r limit 2)
                From Student_Program__c
                where ID in:setContactIdrameID
        ]) {
            // populate the child subscription start date if there is only one child
            if (sp.Subscriptions__r != null && sp.Subscriptions__r.size() == 1) {
                Student_Subscription__c ssb = sp.Subscriptions__r[0];
                ssb.Start_Date__c = sp.Program_Start_Date__r.Start_Date__c;
                ssb.Change_Reason__c = 'Other';
                lstStudentSubscription.add(ssb);
            }
        }
        if (!lstStudentSubscription.isEmpty()) {
            update lstStudentSubscription;
        }
    }

    /*
     * User Story 38827: Tempo: Degree Audit: Max time completion update
     * Changed Anticipated Graduation Date calculation from just adding 24 months to adding 
     * Max Time of Completion field on SP
     */ 
    public static void populateAnticipatedGraduationDate(List<Student_Program__c> spList) {
        System.debug('IN populateAnticipatedGraduationDate method ::: ' + spList);
        for (Student_Program__c sp : spList) {
            if (sp.First_Start_Date__c != null && sp.Max_Time_to_Completion__c != null) {
                sp.Anticipated_Graduation_Date__c = sp.First_Start_Date__c.addMonths((Integer.valueOf(sp.Max_Time_to_Completion__c)));
            }
        }
    }
    public static void populateStudentProgramDefaultFieldsForCBL(list<Student_Program__c> spList) {
        for (Student_Program__c sp : spList) {
            sp.Time_Status__c = 'Full-Time';
            sp.Degree_Status__c = 'In Progress';
        }
    }

    public void createInitialSubscriptions(list<Student_Program__c> eligibleStudentPrograms, map<ID, Student_Program__c>mapOld) {
        list<Student_Subscription__c> newSubsList = new list<Student_Subscription__c>();
        set<Id> stuProgIdSet = new set<Id>();
        for (Student_Program__c sProg : eligibleStudentPrograms) {
            Student_Program__c oldSP = mapOld.get(sProg.Id);
            if (sProg.Program__c != null && sProg.Program_Start_Date__c != null
                    && (sProg.Student_Enrollment_Status_Code__c == 'EL' && oldSP.Student_Enrollment_Status_Code__c == null)
                    && sProg.Number_of_Enrolled_Terms__c == 0) {
                stuProgIdSet.add(sProg.Id);
            }
        }
        if (stuProgIdSet.isEmpty()) {
            return;
        }
        // query to obtain Application__r.Initial_Price_Book__c
        list<Student_Program__c> sProgList = new list<Student_Program__c>([
                SELECT Id
                        , Application__r.Initial_Price_Book__c
                        , Program_Start_Date__r.Start_Date__c
                FROM Student_Program__c
                WHERE Id IN :stuProgIdSet
                AND Application__r.Initial_Price_Book__c != null
        ]);
        set<Id> pbookIdSet = new set<Id>();
        for (Student_Program__c sProg : sProgList) {
            pBookIdSet.add(sProg.Application__r.Initial_Price_Book__c);
        }
        if (!sProgList.isEmpty()) {
            // make sure Pricebook is valid
            map<Id, PricebookEntry> mapId_Pricebook = new map<Id, PricebookEntry>([
                    SELECT Available_for_Existing_Students__c
                    FROM PricebookEntry
                    WHERE Pricebook2Id IN :pBookIdSet
                    AND IsActive = TRUE
            ]);
            for (Student_Program__c sProg : sProgList) {
                // if valid Pricebook, create a Subscription record with it
                if (pbookIdSet.contains(sProg.Application__r.Initial_Price_Book__c)) {
                    Student_Subscription__c newSub = new Student_Subscription__c(Student_Program__c = sProg.Id
                            , Term_Price_Book__c = sProg.Application__r.Initial_Price_Book__c
                            , Start_Date__c = sProg.Program_Start_Date__r.Start_Date__c);
                    newSubsList.add(newSub);
                }
            }
        }
        // insert new Student Subscriptions
        if (!newSubsList.isEmpty()) {
            insert newSubsList;
        }

    }

    public void logStudentEngagementByType(List<Id> stuPrograms, String ruleType, Map<Id, Date> stuProgLastMetDate) {

        List<Student_Engagement_Rule__c> stuEngToUpdate = new List<Student_Engagement_Rule__c>();

        if (stuPrograms != null && stuPrograms.size() > 0) {
            for (Student_Engagement_Rule__c stuEngRule : [
                    SELECT id, name, Last_Date_of_Engagement__c, Student_Program__c
                    FROM Student_Engagement_Rule__c
                    WHERE Rule_Type__c = :ruleType
                    AND Student_Program__c IN :stuPrograms
            ]) {

                if (stuProgLastMetDate != null && stuProgLastMetDate.size() > 0
                        && stuProgLastMetDate.containsKey(stuEngRule.Student_Program__c)) {
                    stuEngRule.Last_Date_of_Engagement__c = stuProgLastMetDate.get(stuEngRule.Student_Program__c);
                } else {
                    stuEngRule.Last_Date_of_Engagement__c = System.today();
                }

                stuEngToUpdate.add(stuEngRule);
            }
        }

        if (stuEngToUpdate != null && stuEngToUpdate.size() > 0) {
            update stuEngToUpdate;
            system.debug('updated stuEngToUpdate ' + stuEngToUpdate);
        }

    }

    public void createStudentEngagementRules(List<Student_Program__c> stuProgsEligibleToRegister) {

        Set<Id> program = new Set<Id>();
        Map<Id, Id> progInstitutionMap = new Map<Id, Id>();
        Map<Id, Id> stuProgProdMap = new Map<Id, Id>();
        Map<Id, Id> stuProgInstitutionMap = new Map<Id, Id>();
        Map<Id, List<Engagement_Rule__c>> institutionEngagementRuleMap = new Map<Id, List<Engagement_Rule__c>>();
        Map<Id, List<Student_Engagement_Rule__c>> stuProgStuEngRuleMap = new Map<Id, List<Student_Engagement_Rule__c>>();
        List<Student_Engagement_Rule__c> stEngRuleToCreate = new List<Student_Engagement_Rule__c>();

        for (Student_Program__c stuProg : stuProgsEligibleToRegister) {
            //program.add(stuProg.Program__c);
            stuProgProdMap.put(stuProg.id, stuProg.Program__c);
        }

        for (Product2 prod : [SELECT id, Institution__c FROM Product2 WHERE Id IN :stuProgProdMap.values()]) {
            if (prod.Institution__c != null) {
                progInstitutionMap.put(prod.id, prod.Institution__c);
            }
        }

        for (Id stuProg : stuProgProdMap.keySet()) {
            if (stuProgProdMap.containsKey(stuProg) && progInstitutionMap.containsKey(stuProgProdMap.get(stuProg))) {
                stuProgInstitutionMap.put(stuProg, progInstitutionMap.get(stuProgProdMap.get(stuProg)));
            }
        }

        system.debug('stuProgInstitutionMap ' + stuProgInstitutionMap);

        if (progInstitutionMap != null && progInstitutionMap.size() > 0) {
            for (Engagement_Rule__c engRule : [SELECT id, Institution__c,Rule_Type__c FROM Engagement_Rule__c where IsActive__c = TRUE AND Institution__c IN :stuProgInstitutionMap.values()]) {
                if (!institutionEngagementRuleMap.containsKey(engRule.Institution__c)) {
                    institutionEngagementRuleMap.put(engRule.Institution__c, new List<Engagement_Rule__c>{
                            engRule
                    });
                } else {
                    institutionEngagementRuleMap.get(engRule.Institution__c).add(engRule);
                }
            }
        }

        system.debug('institutionEngagementRuleMap ' + institutionEngagementRuleMap);

        for (Student_Engagement_Rule__c stuEngRule : [SELECT Id, Rule_Type__c,Student_Program__c FROM Student_Engagement_Rule__c WHERE Student_Program__c IN :stuProgInstitutionMap.keySet()]) {
            if (!stuProgStuEngRuleMap.containsKey(stuEngRule.Student_Program__c)) {
                stuProgStuEngRuleMap.put(stuEngRule.Student_Program__c, new List<Student_Engagement_Rule__c>{
                        stuEngRule
                });
            } else {
                stuProgStuEngRuleMap.get(stuEngRule.Student_Program__c).add(stuEngRule);
            }
        }

        for (Id stuProg : stuProgInstitutionMap.keySet()) {
            Id instituteId = stuProgInstitutionMap.get(stuProg);
            List<Engagement_Rule__c> instituteEngagementRule = institutionEngagementRuleMap.get(instituteId);
            List<Student_Engagement_Rule__c> stuEngagementRule = stuProgStuEngRuleMap.get(stuProg);

            if (instituteEngagementRule != null && instituteEngagementRule.size() > 0) {
                for (Engagement_Rule__c engRule : instituteEngagementRule) {
                    boolean stuRuleTypeExists = false;
                    if (stuEngagementRule != null && stuEngagementRule.size() > 0) {
                        for (Student_Engagement_Rule__c stuEngRule : stuEngagementRule) {
                            if (engRule.Rule_Type__c == stuEngRule.Rule_Type__c) {
                                stuRuleTypeExists = true;
                            }
                        }
                    }

                    if (stuRuleTypeExists == false) {
                        Student_Engagement_Rule__c stEng = new Student_Engagement_Rule__c();
                        stEng.Student_Program__c = stuProg;
                        stEng.Engagement_Rule__c = engRule.id;
                        stEng.IsEngagementRuleActive__c = true;
                        stEngRuleToCreate.add(stEng);
                    }
                }
            }
        }
        if (stEngRuleToCreate != null && stEngRuleToCreate.size() > 0) {
            insert stEngRuleToCreate;
        }

    }

    //This method triggers the API call to BrightSpace to do coach assignment
    public static void assignCoachInBS(list<Student_Program__c> studentPrograms, map<ID, Student_Program__c>mapOld) {
        System.debug('In Coach Assignment Method in Helper class');
        Decimal studentLMSId;
        Decimal coachLMSId;
        JsonWrapper jsonGenerator = new JsonWrapper();
        for (Student_Program__c sp : studentPrograms) {
            coachLMSId = sp.Coach_LMS_Id__c != null ? sp.Coach_LMS_Id__c : null;
            studentLMSId = sp.Student_LMS_ID__c != null ? sp.Student_LMS_ID__c : null;
            if (coachLMSId != null && studentLMSId != null) {
                //String json = jsonGenerator.createAuditeeIdData(studentLMSId);
                String json = '' + studentLMSId + '';
                string lmsCoach;
                if (mapOld.get(sp.id).Is_Coach_Enrolled_in_BS__c == false && sp.Is_Coach_Enrolled_in_BS__c) {
                    lmsCoach = '';
                } else {
                    lmsCOach = string.ValueOf(mapOld.get(sp.id).Coach_LMS_Id__c);
                }                

                system.debug('lmsCOach' + lmsCOach);
                BrightSpaceCalls.studentCoachEnrollment(json, sp.Id, String.valueOf(coachLMSId), lmsCOach);
            }

        }
    }


    /*******************************************************************
   Method to roundrobin Coach Assignment on SP  based on program When Opp.Stage  = Student
   Related story: 23002
   Modified By: Ravitej Varada
   ********************************************************************/
    public static void cblCoachAssignment(list<Student_Program__c> cblStudentPrograms) {

        Integer coachAssignmentLimit = integer.valueOf(Script_Settings__c.getValues('Current Settings').Coach_Assignment_Limit__c) ;
        set<id> conIds = new Set<Id>();
        map<id, string> programCodeIdMap = new map<id, string>();
        map<id, string> spWithStudentNameMap = new map<id, string>();
        for (Student_Program__c stuProg : [SELECT id,Student__c, Student_Full_Name__c, Program__r.Parent_Program__r.ProductCode, Parent_Program__c FROM Student_Program__c WHERE Id IN :cblStudentPrograms]) {
            programCodeIdMap.put(stuProg.id, stuProg.Program__r.Parent_Program__r.ProductCode);
            spWithStudentNameMap.put(stuProg.id, stuProg.Student_Full_Name__c);
            conIds.add(stuProg.Student__c);
        }

        //S-28111- Tempo: Alumni and reinstatement student coach assignment
        map<id, Boolean> isContactAllumniMap = new map<id, Boolean>();
        map<id, id> previousCoachMap = new map<id, id>();
        for (Contact con : [SELECT Id,name, (SELECT id,Coach__c,Name,Student__c FROM Student_Programs__r WHERE Student_Enrollment_Status__c = 'Completed Program (CP)'  ORDER BY  CreatedDate desc LIMIT 1) FROm Contact WHERE ID In:conIds]) {
            if (con.Student_Programs__r.size() > 0) {
                isContactAllumniMap.put(con.id, true);
                previousCoachMap.put(con.id, con.Student_Programs__r[0].Coach__c);
            }
        }
        system.debug('TEST********************');
        system.debug(isContactAllumniMap.keySet());
        system.debug(isContactAllumniMap.values());
        system.debug(previousCoachMap.keySet());
        system.debug(previousCoachMap.values());

        Map<string, List<Coach_Assignment__c>> coachLst = new Map<string, List<Coach_Assignment__c>>();
        List<Coach_Assignment__c> coachAssignmentsToUpdate = new List<Coach_Assignment__c>();

        Set<string> coachList = new Set<String>();

        Map<Id, Coach_Assignment__c> coachWithCoachAssignment = new Map<id, Coach_Assignment__c>();
        Map<Id, Coach_Assignment__c> coachWithCoachAssignmentWithOutLimit = new Map<id, Coach_Assignment__c>();
        for (Coach_Assignment__c coach : [SELECT id, Status__c,To_be_Assigned__c,coach__r.IsActive, coach__r.Name, Program_Names__c, Active_Students__c, Total_Assignments__c, Coach__c FROM Coach_Assignment__c WHERE   coach__r.IsActive = TRUE]) {

            if(coach.Status__c == 'Active' && coach.Total_Assignments__c < coachAssignmentLimit ) {
                coachList.add(coach.coach__c);
                coachWithCoachAssignment.put(coach.coach__c, coach);
            } 
           coachWithCoachAssignmentWithOutLimit.put(coach.coach__c, coach);
            
        }
        RoundRobinHelper objRRHelper = new RoundRobinHelper();
        system.debug(coachList);
        system.debug(coachWithCoachAssignmentWithOutLimit);
        for (Student_Program__c stuProg : cblStudentPrograms) {

            system.debug(stuProg.Student__c);
            system.debug(isContactAllumniMap.containsKey(stuProg.Student__c));
            system.debug(isContactAllumniMap.get(stuProg.Student__c));
            system.debug(coachWithCoachAssignmentWithOutLimit.containsKey(previousCoachMap.get(stuProg.Student__c)));  
            system.debug(previousCoachMap.get(stuProg.Student__c));
            
            // S-84371: L2: Keep Tempo Student Assigned to Same Coach if Coach is Part of New Program's Assignment Group
            List<String> programCodeList = new List<String>();
            if (programCodeIdMap.containsKey(stuProg.id)) {
	            programCodeList.add(programCodeIdMap.get(stuProg.id));
            }
            
            // S-28111- Tempo: Alumni and reinstatement student coach assignment
            // S-84371: L2: Keep Tempo Student Assigned to Same Coach if Coach is Part of New Program's Assignment Group
            if (isContactAllumniMap.containsKey(stuProg.Student__c) 
                && isContactAllumniMap.get(stuProg.Student__c) 
                && coachWithCoachAssignmentWithOutLimit.containsKey(previousCoachMap.get(stuProg.Student__c))
                && objRRHelper.isCoachInNewSPAssignmentGroup(programCOdeList, previousCoachMap.get(stuProg.Student__c))
               ) {
                stuProg.Coach__c = previousCoachMap.get(stuProg.Student__c);
            } else {
                List<String> listRRNames = new List<String>();
                if (programCodeIdMap.containsKey(stuProg.id) && !test.isRunningTest()) {
                    listRRNames.add(programCodeIdMap.get(stuProg.id));
                    List<Id> RRIds = objRRHelper.getNextRRUsersAssignmentGroup(listRRNames, coachList);
                    string coachId = '';
                    system.debug(RRIds);
                    If (!RRIds.isEmpty() && RRIds != null) {
                        coachId = RRIds[0];
                        Coach_Assignment__c coachAss = new Coach_Assignment__c ();
                        coachAss = coachWithCoachAssignment.get(coachId);
                        if (!spWithStudentNameMap.get(stuProg.id).contains('Test') && !spWithStudentNameMap.get(stuProg.id).contains('zz smoke') && !spWithStudentNameMap.get(stuProg.id).contains('bannertest') && !spWithStudentNameMap.get(stuProg.id).contains('zz_') && !spWithStudentNameMap.get(stuProg.id).contains('demolaureate') && !spWithStudentNameMap.get(stuProg.id).contains('smoketest')) {
                            coachAss.To_be_Assigned__c = coachAss.To_be_Assigned__c + 1;
                        }
                        coachAssignmentsToUpdate.add(coachAss);
                        stuProg.Coach__c = coachId ;
                    } else {
                        system.debug(listRRNames);
                        listRRNames = new List<String>();
                        listRRNames.add('RR Walden Coaches');
                        if (!Test.isRunningTest()) {
                            stuProg.Coach__c = objRRHelper.getNextRRUsersAssignmentGroup(listRRNames, null)[0];
                        }
                        system.debug(stuProg.Coach__c);
                    }
                }
            }
        }

        if (!coachAssignmentsToUpdate.isEmpty()) {
            update coachAssignmentsToUpdate;
        }
    }

    /*******************************************************************
    Method to Update Coach Assignment Active or ToBeAssigned values on IsStudentProgramActive Flag
    Related story: 23002
    Created By: Ravitej Varada
    ********************************************************************/
    public static void coachAssignmentUpdate(list<Student_Program__c> cblStudentPrograms, Map<id, Student_Program__c> mapOld) {

        Map<string, Coach_Assignment__c> coachLst = new Map<string, Coach_Assignment__c>();
        List<Coach_Assignment__c> coachAssignmentsToUpdate = new List<Coach_Assignment__c>();

        for (Coach_Assignment__c coach : [SELECT id, To_be_Assigned__c, coach__r.Name, Program_Names__c, Active_Students__c, Total_Assignments__c, Coach__c FROM Coach_Assignment__c]) {
            coachLst.put(coach.coach__r.Name, coach);
        }
        system.debug('coachLst' + coachLst.keySet());
        for (Student_Program__c stuProg : [SELECT id, Date_Student_De_activated__c, IsStudentProgramActive__c, Time_Status__c, Coach__r.Name, Student_Full_Name__c, Parent_Program__c FROM Student_Program__c WHERE Id IN :cblStudentPrograms]) {
            system.debug(stuProg.Student_Full_Name__c);


            if (stuProg.Coach__c != null && coachLst.containsKey(stuProg.Coach__r.Name) && !stuProg.Student_Full_Name__c.contains('Test') && !stuProg.Student_Full_Name__c.contains('zz smoke') && !stuProg.Student_Full_Name__c.contains('bannertest') && !stuProg.Student_Full_Name__c.contains('zz_') && !stuProg.Student_Full_Name__c.contains('demolaureate') && !stuProg.Student_Full_Name__c.contains('smoketest')) {
                Coach_Assignment__c coachAss = coachLst.get(stuProg.Coach__r.Name);
                if (stuProg.IsStudentProgramActive__c && mapOld.get(stuProg.id).Time_Status__c != 'Dropped' && stuProg.Time_Status__c == 'Full-Time') {
                    coachAss.To_be_Assigned__c = coachAss.To_be_Assigned__c - 1;
                    coachAss.Active_Students__c = coachAss.Active_Students__c + 1;
                } else if (!stuProg.IsStudentProgramActive__c && mapOld.get(stuProg.id).Date_Student_De_activated__c == Null && stuProg.Date_Student_De_activated__c != null) {
                    coachAss.Active_Students__c = coachAss.Active_Students__c - 1;
                }
                coachAssignmentsToUpdate.add(coachAss);
                break;
            }
        }

        if (!coachAssignmentsToUpdate.isEmpty()) {
            update coachAssignmentsToUpdate;
        }
    }


    public void createDeferrals(List<Student_Program__c> newStudentProgramList, map<ID, Student_Program__c> mapOld) {
        List<Deferral__c> deferralList = new List<Deferral__c>();

        Set<Id> studentProgramIds = new Set<Id>();
        Set<Id> oldProgramStartDateIds = new Set<Id>();
        Set<Id> newProgramStartDateIds = new Set<Id>();
        for (Student_program__c sProg : newStudentProgramList) {
            studentProgramIds.add(sProg.id);
            newProgramStartDateIds.add(sProg.Program_Start_Date__c);
        }
        for (Id key : mapOld.keySet()) {
            oldProgramStartDateIds.add(mapOld.get(key).program_start_date__c);
        }

        Map<Id, Date> mapProgramStartDateStartDate = new Map<Id, Date>();
        for (Program_Start_Date__c programStartDate : [
                SELECT id, start_date__c
                FROM Program_Start_Date__c
                WHERE id IN :oldProgramStartDateIds OR id IN :newProgramStartDateIds
        ]) {
            if (!mapProgramStartDateStartDate.containsKey(programStartDate.id)) {
                mapProgramStartDateStartDate.put(programStartDate.id, programStartDate.Start_Date__c);
            }
        }

        Map<Id, List<Deferral__c>> mapStudentProgramDeferralList = new Map<Id, List<Deferral__c>>();
        for (Deferral__c deferral : [
                SELECT Previous_Start_Date__c, student_program__c
                FROM Deferral__c
                WHERE student_program__c in :studentProgramIds
                ORDER BY Previous_Start_Date__c DESC
        ]) {
            if (!mapStudentProgramDeferralList.containsKey(deferral.student_program__c)) {
                mapStudentProgramDeferralList.put(deferral.student_program__c, new List<Deferral__c>());
            }
            mapStudentProgramDeferralList.get(deferral.student_program__c).add(deferral);
        }

        for (Student_Program__c sProg : newStudentProgramList) {
            Date newDate = mapProgramStartDateStartDate.get(sProg.Program_Start_Date__c);
            System.debug('****n' + newDate);
            Date oldDate = mapProgramStartDateStartDate.get(mapOld.get(sProg.id).program_start_date__c);
            System.debug('****o' + oldDate);
            Date previousStartDate;
            if (mapStudentProgramDeferralList.containsKey(sProg.id)) {
                previousStartDate = mapStudentProgramDeferralList.get(sProg.id)[0].Previous_Start_Date__c ;
                for (Deferral__c def : mapStudentProgramDeferralList.get(sProg.id)) {
                    System.debug('++++' + def.Previous_Start_Date__c);
                }
            }
            if (previousStartDate == null) {
                if (System.today() > oldDate) {
                    Deferral__c deferral = new Deferral__c();
                    deferral.Previous_Start_Date__c = oldDate;
                    deferral.New_Start_Date__c = newDate;
                    deferral.Process_Date__c = System.today();
                    deferral.Student_Program__c = sProg.id;
                    deferralList.add(deferral);
                }
            } else {
                if (System.today() < oldDate) {
                    Deferral__c deferral = mapStudentProgramDeferralList.get(sProg.id)[0];
                    deferral.New_Start_Date__c = newDate;
                    deferral.Process_Date__c = System.today();
                    deferralList.add(deferral);
                } else {
                    Deferral__c deferral = new Deferral__c();
                    deferral.Previous_Start_Date__c = oldDate;
                    deferral.New_Start_Date__c = newDate;
                    deferral.Process_Date__c = System.today();
                    deferral.Student_Program__c = sProg.id;
                    deferralList.add(deferral);
                }
            }
        }

        if (!deferralList.isEmpty()) {
            upsert deferralList;
        }
    }

    public static void ProcessProgramCatRequirementOnSp(List<Student_program__c> spLst) {
        Set<Id> progrmIdSet = new Set<Id>();
        for (Student_program__c spObj : spLst) {
            progrmIdSet.add(spObj.Program__c);
        }
        Map<Id, Product2> productMap = new Map<Id, Product2>([Select id, (Select id, Category__c, Level__c, Subject_Area_Expertise__c, Total_CE__c from Degree_Requirements__r where Subject_Area_Expertise__c = null) from Product2 where id in:progrmIdSet]);
        for (Student_program__c spObj : spLst) {
            Product2 pObj = new Product2();
            pObj = productMap.get(spObj.Program__c);
            if (!pObj.Degree_Requirements__r.isEmpty()) {
                for (Program_Category_Requirement__c pcrObj : pObj.Degree_Requirements__r) {
                    if (pcrObj.Category__c == 'Core' && pcrObj.Level__c == 'Upper') {
                        spObj.Required_Core_Upper__c = pcrObj.Total_CE__c;
                    } else if (pcrObj.Category__c == 'Core' && pcrObj.Level__c == 'Lower') {
                        spObj.Required_Core_Lower__c = pcrObj.Total_CE__c;
                    } else if (pcrObj.Category__c == 'General Education') {
                        spObj.Required_General_Education__c = pcrObj.Total_CE__c;
                    } else if (pcrObj.Category__c == 'General Elective') {
                        spObj.Required_General_Elective__c = pcrObj.Total_CE__c;
                    } else if (pcrObj.Category__c == 'Concentration') {
                        spObj.Required_Concentration__c = pcrObj.Total_CE__c;
                    }
                }
            }
        }
    }

    /*******************************************************************
Method to Roll up number of student programs on the Related contact
Related story: S-59256
Created By: Ravitej Varada
********************************************************************/
    public void rollUpStudentProgramOnContact(set<ID> setContactId) {
        // get all the Student Programs
        map<ID, list<Student_Program__c>> mapContactWithStudentProg = new map<ID, list<Student_Program__c>>();
        for (Student_Program__c sComp : [
                Select ID, Student__c
                from Student_Program__c
                where Student__c in:setContactId
        ]) {
            if (!mapContactWithStudentProg.containsKey(sComp.Student__c)) {
                mapContactWithStudentProg.put(sComp.Student__c, new list<Student_Program__c>());
            }
            mapContactWithStudentProg.get(sComp.Student__c).add(sComp);
        }

        list<contact> updatedContact = new list<contact>();
        for (ID conId : setContactId) {
            integer totalSpCount = 0;
            if (mapContactWithStudentProg.containsKey(conId)) {
                totalSpCount = mapContactWithStudentProg.get(conId).Size();
                //for(Student_Program__c sp : mapContactWithStudentProg.get(conId)){-----}
            }
            contact con = new contact(ID = conId);
            con.Number_of_SPs__c = totalSpCount;
            updatedContact.add(con);
        }
        update updatedContact;
    }


    /*******************************************************************
Method to update payment plan picklist on SP
Related story: S-4856
Created By: Ravitej Varada
********************************************************************/
    public static void UpdatePaymentPlan(list<Student_Program__c> lstStudentProgram, Boolean isBeforeUpdate) {
        system.debug('------lstStudentProgram' + lstStudentProgram);

        Map<id, List<Student_subscription__c>> spWithLatestSub = new Map<id, List<Student_subscription__c>>();

        List<Student_Program__c> lstStudentProgramToUpdate = new List<Student_Program__c>();
        List<Student_Program__c> lstStudentProgramToProcess = new List<Student_Program__c>();

        lstStudentProgramToProcess = [
                SELECT id, Name, Open_C2_Hold__c, Payment_Plan__c, (
                        Select Id, Student_Program__r.Payment_Plan__c, Student_Program__r.Open_C2_Hold__c,
                                name, Start_Date__c, Student_Program__r.Total_Outstanding_Balance__c, Current_Subscription_Balance__c,
                                Future_Term__c, Subscription_Status__c
                        from Subscriptions__r
                        ORDER BY CreatedDate DESC
                        LIMIT 1
                )
                FROM Student_Program__c
                WHERE Id IN:lstStudentProgram
        ];

        system.debug('------lstStudentProgramToProcess' + lstStudentProgramToProcess);

        For (Student_program__c sp : lstStudentProgramToProcess) {
            If (!sp.Subscriptions__r.IsEmpty()) {
                If (spWithLatestSub.containsKey(sp.id)) {
                    spWithLatestSub.get(sp.id).add(sp.Subscriptions__r);
                } else {
                    spWithLatestSub.put(sp.id, sp.Subscriptions__r);
                }
            }
        }

        system.debug('------spWithLatestSub' + spWithLatestSub);


        For (Student_program__c sp : lstStudentProgram) {
            string paymentPlan = sp.Payment_Plan__c;
            system.debug('paymentPlan' + paymentPlan);
            system.debug('SUB RECORD' + spWithLatestSub.get(sp.id));


            If (spWithLatestSub.get(sp.id) != null && !spWithLatestSub.get(sp.id).isEmpty()) {
                For (Student_subscription__c sub : spWithLatestSub.get(sp.id)) {

                    system.debug('-----Start Date----' + sub.Start_Date__c + 'Start Date - 30---' + sub.Start_Date__c.addDays(-30) + '---Start Date+30----' + sub.Start_Date__c.addDays(+30));
                    system.debug('------Future Condition----' + (sub.Future_Term__c && (system.today() <= sub.Start_Date__c && system.today() >= sub.Start_Date__c.addDays(-30) && sp.Open_C2_Hold__c == 0)));
                    system.debug('------Current Condition----' + (!sub.Future_Term__c && (system.today() >= sub.Start_Date__c && system.today() <= sub.Start_Date__c.addDays(+30)) && sp.Open_C2_Hold__c == 0));

                    If (sub.Future_Term__c && (system.today() <= sub.Start_Date__c && system.today() >= sub.Start_Date__c.addDays(-30) && sp.Open_C2_Hold__c == 0 && sub.Subscription_Status__c == 'RE = Registered' && sub.Student_Program__r.Total_Outstanding_Balance__c > 0) || (
                            !sub.Future_Term__c && (system.today() >= sub.Start_Date__c && system.today() <= sub.Start_Date__c.addDays(+30)) && sp.Open_C2_Hold__c == 0 && sub.Subscription_Status__c == 'RE = Registered' && sub.Student_Program__r.Total_Outstanding_Balance__c > 0)) {
                        If (paymentPlan == 'N' || paymentPlan == Null) {
                            sp.Payment_Plan__c = 'Y';
                            lstStudentProgramToUpdate.add(sp);
                        }
                    } else {
                        If (paymentPlan == 'Y' || paymentPlan == Null) {
                            sp.Payment_Plan__c = 'N';
                            lstStudentProgramToUpdate.add(sp);
                        }
                    }
                }
            }
        }
        system.debug('lstStudentProgramToUpdate' + lstStudentProgramToUpdate);
        If (!lstStudentProgramToUpdate.isEmpty() && !isBeforeUpdate) {
            database.update(lstStudentProgramToUpdate);
        }
    }

    /*
* USER STORY 9121 - Tempo: Option to Select Capstone course for Student
*/
    public void createCapstoneProject(Set<Id> studentProgramIdSet) {

        try {
            // First get the Capstone AoEs and associated competencies. We'll need this to create corresponding SEs and SCs
            List<Area_of_Expertise__c> aoeList = [SELECT id, Course_Code__c FROM Area_of_Expertise__c WHERE course_code__c IN ('MHRM 6901', 'MHRM 6902') ORDER BY course_code__c];
            List<Competency_Expertise__c> competencyExpertiseList = [
                    SELECT area_of_expertise__r.id, area_of_expertise__r.course_code__c, competency__r.id
                    FROM Competency_Expertise__c
                    WHERE Area_of_Expertise__r.Course_Code__c IN ('MHRM 6901', 'MHRM 6902')
                    ORDER BY area_of_expertise__r.course_code__c
            ];
            Map<String, List<Competency__c>> genEdCodeCompetencyMap = new Map<String, List<Competency__c>>();
            for (Competency_Expertise__c competencyExpertise : competencyExpertiseList) {
                Competency__c competency = new Competency__c();
                competency.id = competencyExpertise.competency__r.id;
                if (!genEdCodeCompetencyMap.containsKey(competencyExpertise.area_of_expertise__r.course_code__c)) {
                    genEdCodeCompetencyMap.put(competencyExpertise.area_of_expertise__r.course_code__c, new List<Competency__c>{
                            competency
                    });
                } else {
                    genEdCodeCompetencyMap.get(competencyExpertise.area_of_expertise__r.course_code__c).add(competency);
                }
            }

            // Get the SEs and SCs for the given SPs;
            Map<Id, List<Student_Expertise__c>> spSEListMap = new Map<Id, List<Student_Expertise__c>>();
            for (Student_Expertise__c se : [
                    SELECT Id, area_of_expertise__r.course_code__c, Student_Program__c
                    FROM Student_Expertise__c
                    WHERE Student_program__c IN :studentProgramIdSet AND area_of_expertise__r.course_code__c IN ('MHRM 6901', 'MHRM 6902')
                    ORDER BY area_of_expertise__r.course_code__c
            ]) {
                if (!spSEListMap.containsKey(se.Student_Program__c)) {
                    spSEListMap.put(se.Student_program__c, new List<Student_Expertise__c>{
                            se
                    });
                } else {
                    spSEListMap.get(se.Student_program__c).add(se);
                }
            }
            Map<Id, List<Student_Competency__c>> spSCListMap = new Map<Id, List<Student_Competency__c>>();
            for (Student_Competency__c sc : [
                    SELECT Id, Student_Expertise__r.id, Student_Expertise__r.student_Program__c, Student_Expertise__r.area_of_expertise__r.course_code__c
                    FROM Student_Competency__c
                    WHERE Student_Program__c IN :studentProgramIdSet AND Student_Expertise__r.area_of_expertise__r.course_code__c IN ('MHRM 6901', 'MHRM 6902')
            ]) {
                if (!spSCListMap.containsKey(sc.Student_Expertise__r.student_Program__c)) {
                    spSCListMap.put(sc.Student_Expertise__r.student_Program__c, new List<Student_Competency__c>{
                            sc
                    });
                } else {
                    spSCListMap.get(sc.Student_Expertise__r.student_Program__c).add(sc);
                }
            }


            List<Student_Competency__c> scToDelete = new List<Student_Competency__c>();
            List<Student_Expertise__c> seToDelete = new List<Student_Expertise__c>();
            for (Student_Program__c sp : [SELECT Id, HRM_Capstone_Selection__c, Program__r.Name, Program__r.productCode, Application__c, Student__c FROM Student_Program__c WHERE Id in :studentProgramIdSet]) {
                if (sp.Program__r.productCode == 'C_MSHRM') {
                    if (sp.HRM_Capstone_Selection__c == 'Capstone 1') {

                        // Delete SE and SC from Capstone Project 2, if any
                        if (spSCListMap.get(sp.id) != null) {
                            for (Student_Competency__c sc : spSCListMap.get(sp.id)) {
                                if (sc.Student_Expertise__r.area_of_expertise__r.course_code__c == 'MHRM 6902') {
                                    scToDelete.add(sc);
                                }
                            }
                        }
                        if (spSEListMap.get(sp.id) != null) {
                            for (Student_Expertise__c se : spSEListMap.get(sp.id)) {
                                if (se.area_of_expertise__r.course_code__c == 'MHRM 6902') {
                                    seToDelete.add(se);
                                }
                            }
                        }
                        createCapstoneProjectHelper(sp, aoeList[0], genEdCodeCompetencyMap.get('MHRM 6901'));
                    } else if (sp.HRM_Capstone_Selection__c == 'Capstone 2') {

                        // Delete SE and SC from Capstone Project 1, if any
                        if (spSCListMap.get(sp.id) != null) {
                            for (Student_Competency__c sc : spSCListMap.get(sp.id)) {
                                if (sc.Student_Expertise__r.area_of_expertise__r.course_code__c == 'MHRM 6901') {
                                    scToDelete.add(sc);
                                }
                            }
                        }
                        if (spSEListMap.get(sp.id) != null) {
                            for (Student_Expertise__c se : spSEListMap.get(sp.id)) {
                                if (se.area_of_expertise__r.course_code__c == 'MHRM 6901') {
                                    seToDelete.add(se);
                                }
                            }
                        }
                        createCapstoneProjectHelper(sp, aoeList[1], genEdCodeCompetencyMap.get('MHRM 6902'));
                    }
                }
            }

            if (!scToDelete.isEmpty()) {
                delete scToDelete;
            }
            if (!seToDelete.isEmpty()) {
                delete seToDelete;
            }
        } catch (Exception e) {
            System.debug('** ' + e.getLineNumber());
            System.debug('** ' + e.getMessage());
        }
    }

    /*
* USER STORY 9121 - Tempo: Option to Select Capstone course for Student
* Helper Method
*/
    private void createCapstoneProjectHelper(Student_Program__c sp, Area_Of_Expertise__c aoe, List<Competency__c> competencyList) {
        Set<Id> setCBLRecordTypesSE = Utility.getRecordTypeFromCBLCustomSetting(Student_Expertise__c.sObjectType.getDescribe());
        Set<Id> setCBLRecordTypesSC = Utility.getRecordTypeFromCBLCustomSetting(Student_Competency__c.sObjectType.getDescribe());

        // Create SE and SC
        Student_Expertise__c newStudentExpertise = new Student_Expertise__c();
        newStudentExpertise.Student_Program__c = sp.Id;
        newStudentExpertise.Area_of_Expertise__c = aoe.id;
        newStudentExpertise.Opportunity__c = sp.Application__c;
        newStudentExpertise.Contact__c = sp.Student__c;
        newStudentExpertise.Pseudo_CE__c = 0.0;
        if (!setCBLRecordTypesSE.isEmpty()) {
            List<Id> stuExpRecordTypeIdList = new List<id>();
            stuExpRecordTypeIdList.addAll(setCBLRecordTypesSE);
            newStudentExpertise.recordTypeId = stuExpRecordTypeIdList[0];
        }
        insert(newStudentExpertise);

        List<Student_Competency__c> newStudentCompetencyList = new List<Student_Competency__c>();
        for (Competency__c competency : competencyList) {
            Student_Competency__c sc = new Student_Competency__c();
            sc.Student_Expertise__c = newStudentExpertise.id;
            sc.Contact__c = sp.Student__c;
            sc.Opportunity__c = sp.Application__c;
            sc.Status__c = 'Registered';
            sc.IsCompleted__c = false;
            sc.Student_Program__c = sp.Id;
            sc.Competency__c = competency.Id;
            if (!setCBLRecordTypesSC.isEmpty()) {
                List<Id> stuExpRecordTypeIdList = new List<id>();
                stuExpRecordTypeIdList.addAll(setCBLRecordTypesSC);
                sc.recordTypeId = stuExpRecordTypeIdList[0];
            }
            newStudentCompetencyList.add(sc);
        }
        if (!newStudentCompetencyList.isEmpty()) {
            insert newStudentCompetencyList;
        }
    }


    /*******************************************************************
    Method to handle Program Level PreReq Logic to Unlock once the required Credits are completed
    Related Story : S-22933
    Created By: Ravitej Varada
    Event : After Update
    * Sufia                     6/23/2021                 S-685236 Deprecating this method. This method is not called from anywhere and can be removed
    ********************************************************************/
    /*public void unlockPreReqCoursesOnCompletedCredits(Set<Id> spIdSet) {

        List<Student_Program__c> spList = new List<Student_Program__c>(
        [
                SELECT id, Total_Earned_Core_Upper__c, Total_Earned_Core_Lower__c, Total_Earned_General_Education__c,Total_Earned_General_Elective__c, Program__r.Pre_Req_Core_Credits__c, Required_Attribute_Credits__c, (
                        SELECT id, Name
                        FROM Student_Expertise__r
                        WHERE Is_Pre_Req_Lock__c = TRUE
                )
                FROM Student_Program__c
                WHERE Id in:spIdSet AND (Program__r.Pre_Req_Core_Credits__c > 0 OR Required_Attribute_Credits__c > 0)
        ]);


        List<Student_Expertise__c> sExpLst = new List<Student_Expertise__c>();
        for (Student_Program__c sp : spList) {

            decimal totalGenEdEarned = sp.Total_Earned_General_Education__c;
            if (totalGenEdEarned == null) totalGenEdEarned = 0;

            decimal totalGenElecEarned = sp.Total_Earned_General_Elective__c;
            if (totalGenElecEarned == null) totalGenElecEarned = 0;

            decimal totalCoreLowerEarned = sp.Total_Earned_Core_Lower__c;
            if (totalCoreLowerEarned == null) totalCoreLowerEarned = 0;

            decimal totalCoreUpperEarned = sp.Total_Earned_Core_Upper__c;
            if (totalCoreUpperEarned == null) totalCoreUpperEarned = 0;

            decimal preReqCoreCredits = sp.Program__r.Pre_Req_Core_Credits__c;
            if (preReqCoreCredits == null) preReqCoreCredits = 0;

            decimal reqAttributeCredits = sp.Required_Attribute_Credits__c;
            if (reqAttributeCredits == null) reqAttributeCredits = 0;


            decimal totalGenEdAndGenElecCreditsEarned = totalGenEdEarned + totalGenElecEarned;
            decimal totalCoreCreditsEarned = totalCoreLowerEarned + totalCoreUpperEarned;


            If ((preReqCoreCredits != 0 && reqAttributeCredits != 0 && totalCoreCreditsEarned >= preReqCoreCredits && totalGenEdAndGenElecCreditsEarned >= reqAttributeCredits) ||
                    (preReqCoreCredits != 0 && reqAttributeCredits == 0 && totalCoreCreditsEarned >= preReqCoreCredits) ||
                    (preReqCoreCredits == 0 && reqAttributeCredits != 0 && totalGenEdAndGenElecCreditsEarned >= reqAttributeCredits)
                    )
            {
                if (!sp.Student_Expertise__r.isEmpty()) {
                    For (Student_Expertise__c sExp : sp.Student_Expertise__r) {
                        sExp.Is_Pre_Req_Lock__c = False;
                        sExpLst.add(sExp);
                    }
                }
            }
        }
        system.debug(sExpLst);

        If (!sExpLst.isEmpty()) {
            Set<Student_Expertise__c> uniqeSESet = new Set<Student_Expertise__c>();
            List<Student_Expertise__c> uniqueSEList = new List<Student_Expertise__c>();
            uniqeSESet.addAll(sExpLst);
            uniqueSEList.addAll(uniqeSESet);
            Update uniqueSEList;
        }
    }*/
    
    /*
     * Bug 56561: Without Admin Attributes Technical Difficulties error is displayed - Till Admin attributes created
     */ 
    public static void populateTotalCreditsForRNMSNPrograms(List<Student_Program__c> studentProgramsList) {
        final String RNMSN_CODE = 'RNMSN';
        Set<String> programIdSet = new Set<String>();
        for (Student_Program__c sp : studentProgramsList) {
            programIdSet.add(sp.Program__c);
        }
                
        Map<Id, Product2> programMap = new Map<Id, Product2>([SELECT Id, ProductCode FROM Product2 WHERE Id IN :programIdSet]);

		for (Student_Program__c sp : studentProgramsList) {
            if (programMap.get(sp.Program__c) != null && programMap.get(sp.Program__c).ProductCode != null && !programMap.get(sp.Program__c).ProductCode.contains(RNMSN_CODE)) continue;
            sp.Total_Credits_in_Program_MSN__c = sp.Total_Credits_in_Program__c;
        }
        
    }
    
}