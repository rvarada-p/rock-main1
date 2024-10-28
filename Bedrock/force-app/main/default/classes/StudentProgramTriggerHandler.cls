/*******************************************************************
Name  : StudentProgramTriggerHandler
Author: Vinod (Appirio)
Date  : September 24, 2014
Description: Handler class for the Trigger StudentProgramTrigger

Revision History:
Ravitej Varada      - Aug 25th 2020 -  S-22933 - Program Level PreReq Logic to Unlock once the required Credits are completed
Ravitej Varada      - Sep 20th 2020 -  S-23002 - Coach Assignment when opp.Stage= Student
Ravitej Varada      - Sep 20th 2020 -  S- 23002 WorkFlow Rule moved to handle - Time Status and Date activated or Deactivated time stamp
Horacio Sanchez     - Dec 14th 2020 -  Prod Defect 36816: Tempo: Coach Assignment in Bspace
* Sufia               6/23/2021                 S-685236 code commented as handleUnlockCourseFunctionality in StudentExpertiseHelper class will handle this
Horacio Sanchez     - Jun 23th 2021 -  Bug 56561: Without Admin Attributes Technical Difficulties error is displayed - Till Admin attributes created
*************************************************************************/
 public with sharing class StudentProgramTriggerHandler {
    private set<ID> setCBLRecordTypes;
    private boolean isExecuting = false;
    private integer batchSize = 0;


    public StudentProgramTriggerHandler(boolean isExecuting, integer size) {
        isExecuting = isExecuting;
        batchSize = size;
        setCBLRecordTypes = Utility.getRecordTypeFromCBLCustomSetting(Student_Program__c.sObjectType.getDescribe());
    }

    public void onBeforeInsert(list<Student_Program__c> newStudentPrograms) {
        date nextSAPMonth = null;
        date firstStartDate = null;
        datetime nextSAPDate = null;
        //set RecordType based on related Program and parse out
        list<Student_Program__c> cbl_StudentPrograms = new list<Student_Program__c>();
        list<Student_Program__c> ProcessProgramCatRequirementOnSp = new list<Student_Program__c>();
                
        for (Student_Program__c sProg : newStudentPrograms) {
            if (sProg.Program__c != null) {
                SObjectType objTypeForInstitution = Schema.getGlobalDescribe().get('Student_Program__c');
                sProg.RecordTypeId = objTypeForInstitution.getDescribe().getRecordTypeinfosByName().get(sProg.Program_Institution__c).getRecordTypeId();
            }
            if (setCBLRecordTypes.contains(sProg.RecordTypeId)) {
                cbl_StudentPrograms.add(sProg);
            }

            //Next SAP Date  populating for 3rd Month
            if (sProg.First_Start_Date__c != null) {
                firstStartDate = sProg.First_Start_Date__c;
                nextSAPMonth = firstStartDate.addMonths(6);
                nextSAPDate = DateTime.newInstance(nextSAPMonth.year(), nextSAPMonth.month(), 5);
                while (!nextSAPDate.format('EEEE').equalsIgnoreCase('Friday') && nextSAPDate.day() < 12) {
                    nextSAPDate = nextSAPDate.addDays(1);
                }
                sProg.Next_SAP_Date__c = Date.valueOf(nextSAPDate);
            }

            if (sProg.Program__c != null) {
                ProcessProgramCatRequirementOnSp.add(sProg);
            }


        }
        if (!cbl_StudentPrograms.isEmpty()) {
            StudentProgramHelper.populateStudentProgramDefaultFieldsForCBL(cbl_StudentPrograms);
            StudentProgramHelper.populateAnticipatedGraduationDate(cbl_StudentPrograms);
        }
        if (!ProcessProgramCatRequirementOnSp.isEmpty()) {
            StudentProgramHelper.ProcessProgramCatRequirementOnSp(ProcessProgramCatRequirementOnSp);
        }
        
        StudentProgramHelper.populateTotalCreditsForRNMSNPrograms(newStudentPrograms);
        
    }

    /*******************************************************************
    Method to handle the after onsert trigger
    ********************************************************************/
    public void onAfterInsert(list<Student_Program__c> newStudentProgram) {
        set<ID> setStudentProg = new set<ID>();
        // create Student_Enrollment_Steps__c record
        StudentProgramHelper objHelper = new StudentProgramHelper();
        list<Student_Program__c> selectedStudentProgram = new list<Student_Program__c>();
        // start code: T-324358
        set<ID> setOpportunityID = new set<ID>();
        list<Student_Program__c> selectedStudentProgramToStudentProgram = new list<Student_Program__c>();
        set<ID> programeIds = new set<ID>();

        for (Student_Program__c sProg : newStudentProgram) {


            if (setCBLRecordTypes.contains(sProg.recordtypeid)) {
                setStudentProg.add(sProg.Student__c);
                if (sProg.Program__c != null) {
                    programeIds.add(sProg.Program__c);
                    selectedStudentProgram.add(sProg);
                }
                // Code for the task: T-324358
                if (sProg.Application__c != null) {
                    selectedStudentProgramToStudentProgram.add(sProg);
                    setOpportunityID.add(sProg.Application__c);
                }
            }
        }

        if (!selectedStudentProgram.isEmpty()) {
            objHelper.createStudentEnrollmentSteps(newStudentProgram, programeIds);
        }
        if (!setOpportunityID.isEmpty()) {
            objHelper.bindStudentDiscountWithStudentProgram(selectedStudentProgramToStudentProgram, setOpportunityID);
        }
        if (!setStudentProg.isEmpty()) {
            objHelper.rollUpStudentProgramOnContact(setStudentProg);
        }
        
    }


    /*******************************************************************
    Method to handle the before update trigger
    ********************************************************************/
    public void onBeforeUpdate(list<Student_Program__c> updatedStudentPrograms, map<ID, Student_Program__c>mapOld) {
        System.debug('On before update');
        date nextSAPMonth = null;
        date firstStartDate = null;
        datetime nextSAPDate = null;
        StudentProgramHelper objHelper = new StudentProgramHelper();
        list<Student_Program__c> updatedStartDate = new List<Student_Program__c>();
        list<Student_Program__c> updateCoachAssignment = new list<Student_Program__c>();
        //List<Student_Program__c> updatedProgram = new List<Student_Program__c>();
        String waldenCoachLabel = LABEL.CBL_System_Coach_Name;
        list<Student_Program__c> updatePaymentPlan = new List<Student_Program__c>();


        for (Student_Program__c sProg : updatedStudentPrograms) {
            Student_Program__c oldMap = mapOld.get(sProg.ID);

            // S- 23002 WorkFlow Rule moved to handle - Time Status and Date activated or Deactivated time stamp
            if (oldMap.isStudentProgramActive__c != sProg.isStudentProgramActive__c) {
                 If (sProg.isStudentProgramActive__c) {
                    sProg.Time_Status__c = 'Full-Time';
                    sProg.Date_Student_Activated__c = System.today();
                } else {
                    sProg.Time_Status__c = 'Dropped';
                    sProg.Date_Student_De_activated__c = System.today();
                 }
            }

            //Update Payment Plan Picklist on SP
            if (sprog.Open_C2_Hold__c != mapOld.get(sProg.id).Open_C2_Hold__c) {
                updatePaymentPlan.add(sProg);
            }


            //Next SAP Date - Add/Substract the LOA Gap months Logic
            integer loaGapMonthsDiff = 0;
            dateTime nextSAPAssessmentMonth = null;
            if (sProg.Next_SAP_Date__c != null) {
                if (sProg.LOA_Gap_Months__c != null) {
                    if (oldMap.LOA_Gap_Months__c != null && sProg.LOA_Gap_Months__c != null) {
                        if (oldMap.LOA_Gap_Months__c < sProg.LOA_Gap_Months__c) {
                            loaGapMonthsDiff = integer.valueOf(sProg.LOA_Gap_Months__c) - integer.valueOf(oldMap.LOA_Gap_Months__c);
                            nextSAPAssessmentMonth = sProg.Next_SAP_Date__c.addMonths(loaGapMonthsDiff);
                        } else if (oldMap.LOA_Gap_Months__c > sProg.LOA_Gap_Months__c) {
                            loaGapMonthsDiff = integer.valueOf(oldMap.LOA_Gap_Months__c) - integer.valueOf(sProg.LOA_Gap_Months__c);
                            nextSAPAssessmentMonth = sProg.Next_SAP_Date__c.addMonths(-loaGapMonthsDiff);
                        }
                    } else if (oldMap.LOA_Gap_Months__c == null) {
                        loaGapMonthsDiff = integer.valueOf(sProg.LOA_Gap_Months__c);
                        nextSAPAssessmentMonth = sProg.Next_SAP_Date__c.addMonths(loaGapMonthsDiff);
                    }
                } else if (sprog.LOA_Gap_Months__c == null && oldMap.LOA_Gap_Months__c != null) {
                    loaGapMonthsDiff = integer.valueOf(oldMap.LOA_Gap_Months__c);
                    nextSAPAssessmentMonth = sProg.Next_SAP_Date__c.addMonths(-loaGapMonthsDiff);
                }
                If (nextSAPAssessmentMonth != Null) {
                    datetime lastMonthDate = DateTime.newInstance(nextSAPAssessmentMonth.year(), nextSAPAssessmentMonth.month(), 5);
                    while (!lastMonthDate.format('EEEE').equalsIgnoreCase('Friday') && lastMonthDate.day() < 12) {
                        lastMonthDate = lastMonthDate.addDays(1);
                    }
                    sProg.Next_SAP_Date__c = date.valueOf(lastMonthDate);
                }
            }


            if (sProg.Program_Start_Date__c != null && sProg.Program_Start_Date__c != oldMap.Program_Start_Date__c) {
                //update AGD in here
                updatedStartDate.add(sProg);
            }
            
            // Code for Prod Defect 36816: Tempo: Coach Assignment in Bspace
            //Trigger Coach assignment in BrightSpace - If coach is not Walden Coach and the BS LMS ID is populated
            if (sProg.Coach_Name__c != null && (oldMap.Coach_Name__c != sProg.Coach_Name__c) && sProg.Coach_Name__c != waldenCoachLabel && sProg.Coach_LMS_Id__c != null && sProg.Is_Coach_Enrolled_in_BS__c) {
                updateCoachAssignment.add(sProg);
            } else if(sProg.Is_Coach_Enrolled_in_BS__c && oldMap.Is_Coach_Enrolled_in_BS__c == false && sProg.Student_LMS_ID__c != null) {
                updateCoachAssignment.add(sProg);
            }


            //If the Program lookup on the SP has changed
            // if(sProg.Program__c!=null && sProg.Program__c!=oldMap.Program__c) {
            //    updatedProgram.add(sProg);
            //}

            //Next SAP Date  populating for 6rd Month
            if (sProg.First_Start_Date__c != null) {
                if (sProg.First_Start_Date__c != oldMap.First_Start_Date__c) {
                    firstStartDate = sProg.First_Start_Date__c;
                    nextSAPMonth = firstStartDate.addMonths(6);
                    nextSAPDate = DateTime.newInstance(nextSAPMonth.year(), nextSAPMonth.month(), 5);
                    while (!nextSAPDate.format('EEEE').equalsIgnoreCase('Friday') && nextSAPDate.day() < 12) {
                        nextSAPDate = nextSAPDate.addDays(1);
                    }
                    sProg.Next_SAP_Date__c = Date.valueOf(nextSAPDate);
                }
            }

        }

        //Payment Plan Update
        if (!updatePaymentPlan.isEmpty()) {
            StudentProgramHelper.UpdatePaymentPlan(updatePaymentPlan, True);
        }

        if (!updatedStartDate.isEmpty()) {
            StudentProgramHelper.populateAnticipatedGraduationDate(updatedStartDate);
        }
        if (!updateCoachAssignment.isEmpty()) {
            StudentProgramHelper.assignCoachInBS(updateCoachAssignment, mapOld);
        }
        /*
        if(!updatedProgram.isEmpty()) {
            ProgramReconciliation programHelper = new ProgramReconciliation();
            programHelper.reoncileCOSStudent(updatedProgram, mapOld);
        }
        */
    }

    /*******************************************************************
    Method to handle the after update trigger
    ********************************************************************/
    public void onAfterUpdate(List<Student_Program__c> updatedStudentPrograms, Map<ID, Student_Program__c>mapOld) {

        List<Student_Program__c> updatedProgram = new List<Student_Program__c>();
        StudentProgramHelper objHelper = new StudentProgramHelper();
        list<Student_Program__c> updatedStartDate = new List<Student_Program__c>();
        list<Student_Program__c> selectedCBLStudentProgram = new list<Student_Program__c>();
        set<ID> setStudentProgramIDToPopulateStudentSubscription = new set<ID>();
        List<Student_Program__c> stuProgsEligibleToRegister = new List<Student_Program__c>();
        list<Student_Program__c> updateActiveBsStudentProgList = new list<Student_Program__c>();
        list<Student_Program__c> updateCoachAssignmentLst = new list<Student_Program__c>();
        List<Student_Program__c> updateDeferralsStudentProgramList = new List<Student_Program__c>();
        Set<Id> createCapstoneProjectList = new Set<Id>();
        Set<id> preReqSpIdSet = new Set<Id>();

        for (Student_Program__c sProg : updatedStudentPrograms) {
            Student_Program__c oldMap = mapOld.get(sProg.ID);

            // S- 23002 Coach Assignment Update logic
            if (oldMap.isStudentProgramActive__c != sProg.isStudentProgramActive__c) {
                updateCoachAssignmentLst.add(sProg);
            }
            //S-22933- Program Level PreReq Logic to Unlock once the required Credits are completed
            if (( (sProg.Total_Earned_General_Elective__c != oldMap.Total_Earned_General_Elective__c && sProg.Total_Earned_General_Elective__c >0 ) ||
                    (sProg.Total_Earned_General_Education__c != oldMap.Total_Earned_General_Education__c && sProg.Total_Earned_General_Elective__c >0 )||
                    (sProg.Total_Earned_Core_Lower__c != oldMap.Total_Earned_Core_Lower__c && sProg.Total_Earned_General_Elective__c >0 )||
                    (sProg.Total_Earned_Core_Upper__c != oldMap.Total_Earned_Core_Upper__c && sProg.Total_Earned_General_Elective__c >0 )
            )) {
                preReqSpIdSet.add(sProg.Id);
            }

            if (sProg.Program_Start_Date__c != mapOld.get(sProg.Id).program_start_date__c) {
                updateDeferralsStudentProgramList.add(sProg);
            }

            //code for T-393499
            if (sProg.Student_Enrollment_Status_Code__c == 'EL' && sProg.Student_Enrollment_Status_Code__c != mapOld.get(sProg.id).Student_Enrollment_Status_Code__c) {
                stuProgsEligibleToRegister.add(sProg);
            }

            //If the Program lookup on the SP has changed
            if (sProg.Program__c != null && sProg.Program__c != oldMap.Program__c) {
                updatedProgram.add(sProg);
            }

            if (setCBLRecordTypes.contains(sProg.recordtypeid)) {
                selectedCBLStudentProgram.add(sProg);
                // code for T-331926
                Student_Program__c old = mapOld.get(sProg.ID);
                if (sProg.Program_Start_Date__c != null && sProg.Program_Start_Date__c != old.Program_Start_Date__c) {
                    setStudentProgramIDToPopulateStudentSubscription.add(sProg.ID);
                }

            }

            /*
             * USER STORY 9121 - Tempo: Option to Select Capstone course for Student
             * START
             */
            if (sProg.HRM_Capstone_Selection__c != null && sProg.HRM_Capstone_Selection__c != mapOld.get(sProg.Id).HRM_Capstone_Selection__c) {
                createCapstoneProjectList.add(sProg.Id);
            } else if (sProg.HRM_Capstone_Selection__c == null && sProg.HRM_Capstone_Selection__c != mapOld.get(sProg.Id).HRM_Capstone_Selection__c) {
                Trigger.new[0].addError(' Value cannot be null. Please select a Capstone Project from the dropdown');
            }
            /*
             * USER STORY 9121 - Tempo: Option to Select Capstone course for Student
             * END
             */


            if (oldMap.Program_Completion__c != 100 && sProg.Program_Completion__c == 100) {
                //Fetching the assignment rules on case
                AssignmentRule AR = new AssignmentRule();
                AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
                Case newCase = new Case(Status = 'New', Subject = 'Student has reached 100% completion', Student_Program__c = sProg.Id, Type = 'Degree Completed') ;
                newCase.setOptions(dmlOpts);
                insert newCase;
            }
            
            /*
            //Activate or Deactivate user in BS based on isStudentProgramActive__c flag
            if(oldMap.isStudentProgramActive__c != sProg.isStudentProgramActive__c){
              updateActiveBsStudentProgList.add(sProg);
            }*/


        }
        /*if(!updateActiveBsStudentProgList.isEmpty()){
         objHelper.updateBsUserIsActive(updateActiveBsStudentProgList);
        }*/

        // S- 23002 Coach Assignment Update logic
        if (!updateCoachAssignmentLst.isEmpty()) {
            system.debug('updateCoachAssignmentLst');
            StudentProgramHelper.coachAssignmentUpdate(updateCoachAssignmentLst,mapOld);
        }


        if (!updatedProgram.isEmpty()) {
            ProgramReconciliation programHelper = new ProgramReconciliation();
            programHelper.reoncileCOSStudent(updatedProgram, mapOld);
        }

        if (stuProgsEligibleToRegister != null && stuProgsEligibleToRegister.size() > 0) {
            objHelper.createStudentEngagementRules(stuProgsEligibleToRegister);
        }

        if (!selectedCBLStudentProgram.isEmpty()) {
            objHelper.createInitialSubscriptions(selectedCBLStudentProgram, mapOld);
        }

        //S-22933- Program Level PreReq Logic to Unlock once the required Credits are completed
        if (!preReqSpIdSet.isEmpty()) {
            //S-685236   commenting as handleUnlockCourseFunctionality in StudentExpertiseHelper class will handle this
            //objHelper.unlockPreReqCoursesOnCompletedCredits(preReqSpIdSet);
        }

        if (!setStudentProgramIDToPopulateStudentSubscription.isEmpty()) {
            objHelper.populateStartDateOnStudentSubscription(setStudentProgramIDToPopulateStudentSubscription);
            // below code is related to Task: T-337411
            // rollup TBYB competency completion on Opportunity where  Student Program's Program Start Date changed
            // get all student competency and the opportunity id
            set<ID> selectedOpportunityID = new set<ID>();
            for (Student_Competency__c sComp : [
                    select ID,Opportunity__c
                    from Student_Competency__c
                    where Opportunity__c != null
                    and Student_Program__c in:setStudentProgramIDToPopulateStudentSubscription
                    and (Status__c = 'Mastered' OR Status__c = 'Achieved')
                    and Competency_Type__c = 'Academic'
            ]) {
                selectedOpportunityID.add(sComp.Opportunity__c);
            }
            if (!selectedOpportunityID.isEmpty()) {
                StudentCompetencyHelper objStudentCompetencyHelper = new StudentCompetencyHelper();
                objStudentCompetencyHelper.rollUpNumberOfCompletedCompetenciesInTrial(selectedOpportunityID);
            }
        }

        if (!updateDeferralsStudentProgramList.isEmpty()) {
            objHelper.createDeferrals(updateDeferralsStudentProgramList, mapOld);
        }

        /*
         * USER STORY 9121 - Tempo: Option to Select Capstone course for Student
         * START
         */
        if (!createCapstoneProjectList.isEmpty()) {
            objHelper.createCapstoneProject(createCapstoneProjectList);
        }
        /*
         * USER STORY 9121 - Tempo: Option to Select Capstone course for Student
         * END
         */
        
    }


}