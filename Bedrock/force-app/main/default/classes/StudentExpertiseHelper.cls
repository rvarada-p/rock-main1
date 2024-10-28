/************************************************************************************** 
Apex Class Name     : StudentExpertiseHelper
Created Date        : 4th April 2018
Function            : Helper class for StudentExpertiseTriggerHandler class
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                  
*
* Ravitej Varada            04/24/2018                Original Version
*
* Revision History
* Horacio Sanchez           9/29/2020                 S-25237 Move Existing Pre-req functionality from AoE to PE
* Sufia                     6/23/2021                 S-685236 Update Existing Pre-requisite Logic for RN to MSN Programs
*************************************************************************************/
public without sharing class StudentExpertiseHelper {

    /*******************************************************************
    Method to Calculate Grade Value & Grade When Student Expertise  isAchieved__c = TRUE
    and exclude Fulfilled Student Competencies
    Related Story : S-48659
    Created By: Ravitej Varada
    Event : Before Update
    ********************************************************************/

    public static void calculateGradeValue(List<Student_Expertise__c> newStudentExps){

        map<ID,list<Student_Competency__c>> mapStudentExpWithStudentCompetency = new map<ID,list<Student_Competency__c>>();

        for(Student_Competency__c sComp:[Select ID,Student_Expertise__c,Competency_Credit_Equivalency__c,status__c from Student_Competency__c where Student_Expertise__c in:newStudentExps]){
            if(!mapStudentExpWithStudentCompetency.containsKey(sComp.Student_Expertise__c)){
                mapStudentExpWithStudentCompetency.put(sComp.Student_Expertise__c,new list<Student_Competency__c>());
            }
            mapStudentExpWithStudentCompetency.get(sComp.Student_Expertise__c).add(sComp);
        }
        //map for status value
        map<String,decimal> gradeEque = new map<String,decimal>();
        gradeEque.put('Transferred',0);
        gradeEque.put('Achieved',3);
        gradeEque.put('Mastered',4);

        For(Student_Expertise__c stuExp : newStudentExps){

            decimal compCEvalue = 0;
            decimal sumCEValueStatus = 0 ;
            decimal totalCE = 0 ;
            decimal gradeValue = 0 ;
            string grade = '' ;
            boolean isTransferred = false;
            boolean isFulfilled = false;

            if(!mapStudentExpWithStudentCompetency.isEmpty()){
                if(mapStudentExpWithStudentCompetency.containsKey(stuExp.id)){

                    // Calculation Logic for grade value.
                    for(Student_Competency__c sComp : mapStudentExpWithStudentCompetency.get(stuExp.id)){
                        if (sComp.status__c == 'Mastered' || sComp.status__c == 'Achieved' ||  sComp.status__c == 'Transferred' ){
                            sumCEValueStatus += sComp.Competency_Credit_Equivalency__c * gradeEque.get(sComp.status__c);
                            totalCE += sComp.Competency_Credit_Equivalency__c;
                            if(sComp.status__c == 'Transferred'){
                                isTransferred = True;
                            }
                        }else if(sComp.status__c == 'Fulfilled'){
                            system.debug('%%%%%%5status'+sComp.status__c);

                            isFulfilled = True;
                        }
                    }

                    system.debug('isTransferred'+isTransferred);
                    system.debug('isFulfilled'+isFulfilled);

                    if(totalCE > 0 && isFulfilled == False){
                        gradeValue = sumCEValueStatus/totalCE;
                    }else if(isFulfilled){
                        gradeValue = stuExp.Grade_Value__c;
                    }
                    //Populate the Grade based on grade value.
                    if(gradeValue >= 3.5){
                        grade = 'A';
                    }else if(gradeValue >= 3 && gradeValue <= 3.49){
                        grade = 'B';
                    }else if(isTransferred ){
                        grade = 'TR';
                    }else if(isFulfilled ){
                        grade = stuExp.Grade__c;
                    }

                    stuExp.Grade_Value__c = gradeValue;
                    stuExp.Grade__c = grade;

                }
            }
        }
    }

    /*******************************************************************
   Method to Calculate GRand GPA  of achieved Student Expertise on the Related StudentProgram
   IF the child Student Expertise is Achieved And Category is COre and Level Type is Upper
   Related task: S-40657
   Created By: Ravitej Varada
   ********************************************************************/
    public static void calculateGrandGPAOnStudentProgram(set<ID> setStudentProgramID){

        List<Student_Program__c> stdPgrmList = new List<Student_Program__c>();
        stdPgrmList = [select id, GPA__c, (select id,Total_CE__c  , Grade_Value__c, Grade__c from Student_Expertise__r where IsAchieved__c = true) from Student_Program__c where id in :setStudentProgramID];
        Map<Id,Student_Expertise__c> stdntExprtsMap = new Map<Id,Student_Expertise__c>([Select id, Grade_Value__c, Grade__c,
        (Select id, Status__c from Student_Competencies__r where Status__c!='Transferred')
        From Student_Expertise__c
        Where IsAchieved__c = true
        AND Grade_Value__c != null
        AND Outcome_Category__c != 'Back'
        AND Grade__c != null
        AND Fulfilled_Course_from_a_Conferred_Degree__c = FALSE
        AND Area_Of_Expertise__r.Type__c != 'Non-Academic'
        AND Student_Program__c in :setStudentProgramID]);

        for(Student_Program__c stPrmObj : stdPgrmList){
            if(stPrmObj.Student_Expertise__r.size()>0){
                Decimal grandValTotal = 0;
                decimal TotalCE = 0;
                for(Student_Expertise__c sExpObj : stPrmObj.Student_Expertise__r){
                    //Calculation logic for GPA value on SP
                    if(stdntExprtsMap.containsKey(sExpObj.Id) && stdntExprtsMap.get(sExpObj.Id)!=null && stdntExprtsMap.get(sExpObj.Id).Student_Competencies__r.size()>0 && sExpObj.Grade_Value__c != null){
                        grandValTotal +=  sExpObj.Grade_Value__c  * sExpObj.Total_CE__c;
                        TotalCE   += sExpObj.Total_CE__c;


                    }
                }
                if(TotalCE > 0 )
                    stPrmObj.GPA__c = grandValTotal/TotalCE;
                else
                        stPrmObj.GPA__c = 0;
            }else{
                stPrmObj.GPA__c = 0;
            }
        }
        update stdPgrmList;


    }

    /*******************************************************************
    Method to Rollup Method to calculate Transferred and Fulfuilled for UG program.
    Related Story : S-56757
    Created By: Horacio
    Event : After Update
    ********************************************************************/
    public static void calculateUGProgramTransferredFulfilledCE(Set<Id> spIdSet) {
        List<Student_Program__c> spList = new List<Student_Program__c>(
        [SELECT id, UG_Program_Transferred_Fulfilled_CE__c,
        (SELECT id, Total_Applied_Earned_CE_Outcome__c
        FROM Student_Expertise__r
        WHERE Outcome_Category__c != 'Back' AND (Grade__c = 'TR' OR Fulfilled_Course_from_a_Conferred_Degree__c = true OR Fulfilled_Course_Name__c != null))
        FROM Student_Program__c
        WHERE program__r.degree_level__c = 'Undergrad'AND Id in: spIdSet]);

        if (!spList.isEmpty()) {
            for (Student_program__c spObj : spList) {
                System.debug('spObj::'+spObj);
                if (!spObj.Student_Expertise__r.isEmpty()) {
                    Decimal ugProgramTransferredFulfilledCredits = 0;
                    for (Student_Expertise__c seObj : spObj.Student_Expertise__r) {
                        if( seObj.Total_Applied_Earned_CE_Outcome__c != null){
                            ugProgramTransferredFulfilledCredits += seObj.Total_Applied_Earned_CE_Outcome__c;
                        }
                    }
                    spObj.UG_Program_Transferred_Fulfilled_CE__c = ugProgramTransferredFulfilledCredits;
                }
            }
            update spList;
        }
    }
    
    /*******************************************************************
    Method to Update Pre-requisite; updates SE Pre-Requisite Rule object and Is_PreLock field on SE
    Related Story : S-25237
    Created By: Horacio
    Event : After Update
    ********************************************************************/
    public void managePreRequisiteFunctionality(Set<Id> achievedSEIdSet) {
        List<SE_Pre_Requisite_Rule__c> sePreReqList = new List<SE_Pre_Requisite_Rule__c>();
        List<SE_Pre_Requisite_Rule__c> sePreReqToUpdateList = new List<SE_Pre_Requisite_Rule__c>();
        Set<Id> sePreReqToUpdateIdSet = new Set<Id>();
        System.debug('+++++: ' + achievedSEIdSet);
        sePreReqList = [SELECT Id, Student_Expertise__c
                        FROM SE_Pre_Requisite_Rule__c
                        WHERE Pre_Requisite_Course__c IN :achievedSEIdSet];
        for (SE_Pre_Requisite_Rule__c sePreReqRule : sePreReqList) {
            SE_Pre_Requisite_Rule__c sePreReqRuleToUpdate = new SE_Pre_Requisite_Rule__c();
            sePreReqRuleToUpdate.Id = sePreReqRule.Id;
            sePreReqRuleToUpdate.Is_Achieved__c = true;
            sePreReqToUpdateList.add(sePreReqRuleToUpdate);
            sePreReqToUpdateIdSet.add(sePreReqRule.Student_Expertise__c);
        }
        if (!sePreReqToUpdateList.isEmpty()) {
            update sePreReqToUpdateList;
        }
        
        List<SE_Pre_Requisite_Rule__c> updatedSePreReqList = new List<SE_Pre_Requisite_Rule__c>();
        updatedSePreReqList = [SELECT Id, Student_Expertise__c, Pre_Requisite_Course__c, Is_Achieved__c, Student_Expertise__r.Program_Expertise__r.Pre_Req_Condition_Rule__c
                               FROM SE_Pre_Requisite_Rule__c
                               WHERE Student_Expertise__c IN :sePreReqToUpdateIdSet];
        Map<Id, List<SE_Pre_Requisite_Rule__c>> seIdPreReqListMap = new Map<Id, List<SE_Pre_Requisite_Rule__c>>();
        for (SE_Pre_Requisite_Rule__c sePreReqRule : updatedSePreReqList) {
            if (!seIdPreReqListMap.containsKey(sePreReqRule.Student_Expertise__c)) {
                seIdPreReqListMap.put(sePreReqRule.Student_Expertise__c, new List<SE_Pre_Requisite_Rule__c>{sePreReqRule});
            } else {
                seIdPreReqListMap.get(sePreReqRule.Student_Expertise__c).add(sePreReqRule);
            }
        }
        Set<Id> seIdsToRemoveLockSet = new Set<Id>();
        for (Id masterSEId : seIdPreReqListMap.keySet()) {
            List<SE_Pre_Requisite_Rule__c> masterSEPreReqList = seIdPreReqListMap.get(masterSEId);
            if (masterSEPreReqList != null && masterSEPreReqList.size() == 1) {
                seIdsToRemoveLockSet.add(masterSEId);
            } else if(masterSEPreReqList != null && masterSEPreReqList.size() > 1) {
                String preReqConditionRule = masterSEPreReqList[0].Student_Expertise__r.Program_Expertise__r.Pre_Req_Condition_Rule__c;
                Boolean unlockSE;
                if (preReqConditionRule == null || preReqConditionRule == '' || preReqConditionRule == 'AND') {
                    unlockSE = true;
                    for (SE_Pre_Requisite_Rule__c preReq : masterSEPreReqList) {
                        if (!preReq.Is_Achieved__c) {
                            unlockSE = false;
                            break;
                        }
                    }
                } else {
                    unlockSE = false;
                    for (SE_Pre_Requisite_Rule__c preReq : masterSEPreReqList) {
                        if (preReq.Is_Achieved__c) {
                            unlockSE = true;
                            break;
                        }
                    }
                }
                if (unlockSE) {
                    seIdsToRemoveLockSet.add(masterSEId);
                }
            }
        }
        List<Student_Expertise__c> seToUnlockList = new List<Student_Expertise__c>();
        for (Id seId : seIdsToRemoveLockSet) {
            Student_Expertise__c se = new Student_Expertise__c();
            se.Id = seId;
            se.Is_Pre_Req_Lock__c = false;
            seToUnlockList.add(se);
        }
        if (!seToUnlockList.isEmpty()) {
            update seToUnlockList;
        }
    }
    
    /*******************************************************************
    Method to handle unlocking of upper core courses
    Related Story : S-685236
    Created By: Sufia
    Event : After Update
    ********************************************************************/
    
    public void handleUnlockCourseFunctionality(Set<Id> setStudentProgramIds){
        List<Student_Expertise__c> updateUnlockSEs = new List<Student_Expertise__c>();
        for(Student_Program__c sp : [select Id,Required_Attribute_Credits__c,Program__r.Pre_Req_Core_Credits__c,(select Id,IsAchieved__c,Total_CE__c,Audit_Category__c,Area_of_Expertise__r.Level__c,Level_Type__c,Is_Pre_Req_Lock__c from Student_Expertise__r) from  Student_Program__c where Id IN :setStudentProgramIds]){
            Decimal achievedCreditSumLowerCore = 0.0;
            Map<Id,List<Student_Expertise__c>> mapSPAndUpperCoreSEs = new Map<Id,List<Student_Expertise__c>>();
            for(Student_Expertise__c se : sp.Student_Expertise__r){
                if(se.Level_Type__c=='Lower' && !se.Is_Pre_Req_Lock__c && se.IsAchieved__c){
                   achievedCreditSumLowerCore+=(se.Total_CE__c==NULL ? 0 : se.Total_CE__c);
                }
                else if(se.Level_Type__c=='Upper' && se.Area_of_Expertise__r.Level__c=='6000' && se.Audit_Category__c=='Core' && se.Is_Pre_Req_Lock__c){
                   if(mapSPAndUpperCoreSEs.containsKey(sp.Id))
                      mapSPAndUpperCoreSEs.get(sp.Id) .add(se);
                   else
                       mapSPAndUpperCoreSEs.put(sp.Id,new List<Student_Expertise__c>{se}); 
                }
            }
            Decimal totalPreReqCredit = (sp.Program__r.Pre_Req_Core_Credits__c==NULL ? 0 : sp.Program__r.Pre_Req_Core_Credits__c) + (sp.Required_Attribute_Credits__c==NULL ? 0 : sp.Required_Attribute_Credits__c);
            if(achievedCreditSumLowerCore>=totalPreReqCredit && mapSPAndUpperCoreSEs.containsKey(sp.Id)){
                for(Student_Expertise__c se : mapSPAndUpperCoreSEs.get(sp.Id)) {
                    updateUnlockSEs.add(new Student_Expertise__c(Id=se.Id,Is_Pre_Req_Lock__c=false));
                } 
            }
        }
        StudentExpertiseTriggerHandler.skipAfterUpdateRecursion = true;
        update updateUnlockSEs;
        StudentExpertiseTriggerHandler.skipAfterUpdateRecursion = false;
    }
}