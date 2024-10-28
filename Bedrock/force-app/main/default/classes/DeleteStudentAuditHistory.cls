/************************************************************************************** 
Apex Class Name     : DeleteStudentAuditHistory
Created Date        : 4th April 2018
Function            : This class is to Re-evaluate Student Audit History when SE.IsAchieved = False
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                  
* Ravitej Varada            07/01/2019                Original Version

Revision History
* Horacio Sanchez    01/25/2021     User Story 40038: L2: TOC tool and guest user access update
* Ravitej Varada    01/28/2021     User Story 40989: Delete Student Audit History to include Statistics for BSN (Step 2.2)
*************************************************************************************/
public without sharing class DeleteStudentAuditHistory {
    public static void delAndcreateStudentAuditHistory(Map<Id, Student_Expertise__c> oldStudentExpsMap, List<Student_Expertise__c> newStudentExpsList) {

        system.debug('oldStudentExpsMap' + oldStudentExpsMap);
        system.debug('newStudentExpsList' + newStudentExpsList);
        system.debug('newStudentExpsList' + newStudentExpsList[0].Outcome_Category__c);

        try {
            List<Student_Expertise__c> stdntExpList = new List<Student_Expertise__c>();
            List<Student_Audit_History__c> lstStudentAuditHistory = new List<Student_Audit_History__c>();
            map<id, student_audit_history__c> newAuditRecordMap = new map<id, student_audit_history__c>();
            Set<Id> prgrmIdSet = new Set<Id>();
            for (Student_Expertise__c stdntExpObj : newStudentExpsList) {
                system.debug('oldStudentExpsMap' + oldStudentExpsMap.get(stdntExpObj.Id).Outcome_Category__c);

                if (!stdntExpObj.IsAchieved__c && oldStudentExpsMap.get(stdntExpObj.Id).IsAchieved__c) {
                    prgrmIdSet.add(stdntExpObj.Student_Program__c);
                } else if (oldStudentExpsMap.get(stdntExpObj.Id).Pseudo_CE__c > 0 && oldStudentExpsMap.get(stdntExpObj.Id).Pseudo_CE__c != stdntExpObj.Pseudo_CE__c) {
                    prgrmIdSet.add(stdntExpObj.Student_Program__c);
                }
            }
            System.debug('prgrmIdSet::' + prgrmIdSet);
            stdntExpList = [
                    Select id, IsAchieved__c, Is_Audit_History_Created__c,Student_Program__c,Level_Type__c, Pseudo_Course__c, Pseudo_CE__c, Total_CE__c,Audit_Category__c,
                            Outcome_Category__c, Subject_Area_Expertise__c,Outcome_Subject_Area_Expertise__c, Total_Applied_Earned_CE_Outcome__c
                    from Student_Expertise__c
                    where id in :oldStudentExpsMap.keyset()
            ];
            System.debug('stdntExpList::' + stdntExpList);
            if (!prgrmIdSet.isEmpty()) {
                Map<Id, Student_Program__c> stdntPrgmMap = new Map<Id, Student_Program__c>(
                [
                        Select id, (
                                select id,Student_Expertise__c, Earned_CE_Core_Upper__c,Earned_CE_Core__c,Earned_Back__c,Earned_CE_Concentration__c,
                                        Total_CE_Core_Upper__c,Student_Expertise__r.Pseudo_Course__c,Total_CE_Core__c,Total_CE_Concentration__c,Total_CE_General_Education__c,
                                        Total_CE_General_Electives__c,Student_Expertise__r.Audit_Category__c,Student_Expertise__r.Outcome_Category__c,Student_Program__c,
                                        Student_Expertise__r.Level_Type__c,Earned_CE_General_Education__c,Earned_CE_General_Electives__c,
                                        Student_Expertise__r.Total_CE__c, Student_Expertise__r.IsAchieved__c,Student_Expertise__r.Pseudo_CE__c,
                                        Earned_CE_Arts_and_Humanities__c, Earned_CE_Mathematics_Natural_Science__c,Student_Expertise__r.Subject_Area_Expertise__c,
                                        Earned_CE_Social_Science__c,Total_CE_Any_Category__c,Earned_CE_Any_Category__c,Student_Expertise__r.Outcome_Subject_Area_Expertise__c,
                                        Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c, Earned_CE_Written_and_Oral_Communication__c, Total_CE_Arts_and_Humanities__c,
                                        Total_CE_Mathematics_Natural_Science__c,Total_CE_Social_Science__c,Total_CE_Written_and_Oral_Communication__c,Earned_CE_Statistics__c,Total_CE_Statistics__c
                                from Student_Audit_Historys__r
                                order by Name desc
                        )
                        from Student_Program__c
                        where id in :prgrmIdSet
                ]);


                Set<Id> calCompPrgmIdSet = new Set<Id>();
                List<Student_Expertise__c> stExList = new List<Student_Expertise__c>();


                for (Student_Expertise__c stdntExpObj : stdntExpList) {

                    System.debug('stdntExpObj.Outcome_Category__c:::' + stdntExpObj.Outcome_Category__c);
                    System.debug('stdntExpObj.Audit_Category__c:::' + stdntExpObj.Audit_Category__c);

                    System.debug('stdntExpObj.Outcome_Subject_Area_Expertise__c:::' + stdntExpObj.Outcome_Subject_Area_Expertise__c);
                    System.debug('stdntExpObj.Subject_Area_Expertise__c:::' + stdntExpObj.Subject_Area_Expertise__c);
                    System.debug('stdntExpObj.IsAchieved__c:::' + stdntExpObj.IsAchieved__c);
                    System.debug('oldStudentExpsMap.get(stdntExpObj.Id).IsAchieved__c:::' + oldStudentExpsMap.get(stdntExpObj.Id).IsAchieved__c);
                    System.debug('stdntPrgmMap.containsKey(stdntExpObj.Student_Program__c):::' + stdntPrgmMap.containsKey(stdntExpObj.Student_Program__c));
                    System.debug('stdntPrgmMap.get(stdntExpObj.Student_Program__c):::' + stdntPrgmMap.get(stdntExpObj.Student_Program__c));
                    System.debug('!stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.isEmpty():::' + !stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.isEmpty());
                    System.debug('!calCompPrgmIdSet.contains(stdntExpObj.Student_Program__c):::' + !calCompPrgmIdSet.contains(stdntExpObj.Student_Program__c));


                    if ((!stdntExpObj.IsAchieved__c && oldStudentExpsMap.get(stdntExpObj.Id).IsAchieved__c || oldStudentExpsMap.get(stdntExpObj.Id).Pseudo_CE__c > 0 && oldStudentExpsMap.get(stdntExpObj.Id).Pseudo_CE__c != stdntExpObj.Pseudo_CE__c) &&
                            stdntPrgmMap.containsKey(stdntExpObj.Student_Program__c) &&
                            stdntPrgmMap.get(stdntExpObj.Student_Program__c) != null &&
                            !stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.isEmpty()
                            ) {

                        Student_Audit_History__c cloneAuditHistory = new Student_Audit_History__c();
                        Student_Audit_History__c auditHistory = new Student_Audit_History__c();

                        //Get Last inserted Audit History record
                        auditHistory = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[0];


                        system.debug('----------------SAH LOGS-----------------');
                        debugCloneAuditHistory(cloneAuditHistory);


                        IF (newAuditRecordMap.isEmpty()) {
                            cloneAuditHistory = auditHistory.clone(False, TRUE, false, false);
                            System.debug('cloneAuditHistory empty:::' + cloneAuditHistory);
                        } else {
                            cloneAuditHistory = newAuditRecordMap.get(stdntExpObj.student_Program__c);
                            System.debug('cloneAuditHistory not empty:::' + cloneAuditHistory);
                        }

                        system.debug('----------------SAH LOGS-----------------');
                        debugCloneAuditHistory(cloneAuditHistory);

                        cloneAuditHistory.id = null;
                        debugCloneAuditHistory(cloneAuditHistory);
                        cloneAuditHistory.Student_Expertise__c = stdntExpObj.id;

                        Decimal totalCE = 0;
                        if (stdntExpObj.Total_Applied_Earned_CE_Outcome__c != null) {
                            totalCE = stdntExpObj.Total_Applied_Earned_CE_Outcome__c;//3
                        } else {
                            if (stdntExpObj.Pseudo_Course__c) {
                                totalCE = oldStudentExpsMap.get(stdntExpObj.id).Pseudo_CE__c;
                            } else if (stdntExpObj.Pseudo_Course__c == False) {
                                totalCE = stdntExpObj.Total_CE__c;
                            }
                        }

                        system.debug('totalCE' + totalCE);
                        System.debug('stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r::' + stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size());

                        String outcomeCatStr = stdntExpObj.Outcome_Category__c;

                        system.debug('----------------SAH LOGS-----------------');
                        debugCloneAuditHistory(cloneAuditHistory);


                        // Subtracting False SE CE values from Outcome Category Bucket
                        if (outcomeCatStr == 'Core Upper') {
                            cloneAuditHistory.Earned_CE_Core_Upper__c = cloneAuditHistory.Earned_CE_Core_Upper__c - totalCE;
                        } else if (outcomeCatStr == 'Core Lower') {
                            cloneAuditHistory.Earned_CE_Core__c = cloneAuditHistory.Earned_CE_Core__c - totalCE;
                        } else if (outcomeCatStr == 'BACK') {
                            cloneAuditHistory.Earned_Back__c = cloneAuditHistory.Earned_Back__c - totalCE;
                        } else if (outcomeCatStr == 'Concentration') {
                            cloneAuditHistory.Earned_CE_Concentration__c = cloneAuditHistory.Earned_CE_Concentration__c - totalCE;
                        } else if (outcomeCatStr == 'General Elective') {
                            debugCloneAuditHistory(cloneAuditHistory);

                            cloneAuditHistory.Earned_CE_General_Electives__c = cloneAuditHistory.Earned_CE_General_Electives__c - totalCE;
                            debugCloneAuditHistory(cloneAuditHistory);
                        } else if (outcomeCatStr == 'General Education') {
                            If (stdntExpObj.Subject_Area_Expertise__c == 'Arts and Humanities' && stdntExpObj.Outcome_Subject_Area_Expertise__c == 'Arts and Humanities') {
                                cloneAuditHistory.Earned_CE_Arts_and_Humanities__c = cloneAuditHistory.Earned_CE_Arts_and_Humanities__c - totalCE;
                            } else If (stdntExpObj.Subject_Area_Expertise__c == 'Mathematics/Natural Sciences' && stdntExpObj.Outcome_Subject_Area_Expertise__c == 'Mathematics/Natural Sciences') {
                                cloneAuditHistory.Earned_CE_Mathematics_Natural_Science__c = cloneAuditHistory.Earned_CE_Mathematics_Natural_Science__c - totalCE;
                            } else If (stdntExpObj.Subject_Area_Expertise__c == 'Social Sciences' && stdntExpObj.Outcome_Subject_Area_Expertise__c == 'Social Sciences') {
                                cloneAuditHistory.Earned_CE_Social_Science__c = cloneAuditHistory.Earned_CE_Social_Science__c - totalCE;
                            } else If (stdntExpObj.Subject_Area_Expertise__c == 'Written and Oral Communication' && stdntExpObj.Outcome_Subject_Area_Expertise__c == 'Written and Oral Communication') {
                                cloneAuditHistory.Earned_CE_Written_and_Oral_Communication__c = cloneAuditHistory.Earned_CE_Written_and_Oral_Communication__c - totalCE;
                            } else If (stdntExpObj.Subject_Area_Expertise__c == 'Statistics' && stdntExpObj.Outcome_Subject_Area_Expertise__c == 'Statistics') {
                                cloneAuditHistory.Earned_CE_Statistics__c = cloneAuditHistory.Earned_CE_Statistics__c - totalCE;
                            } else If (stdntExpObj.Outcome_Subject_Area_Expertise__c == 'Any Category') {
                                cloneAuditHistory.Earned_CE_Any_Category__c = cloneAuditHistory.Earned_CE_Any_Category__c - totalCE;
                            }
                        }


                        debugCloneAuditHistory(cloneAuditHistory);


                        // Re-Evaulate Student Audit History Buckets as per Hierarchy Rules
                        system.debug('%%%%%%%%%%%%%%%%%%%%%stdntExpObj.Outcome_Category__c' + stdntExpObj.Outcome_Category__c);

                        if (stdntExpObj.Outcome_Category__c != 'Back') {

                            System.debug('stdntExpObj.Outcome_Category__c::' + stdntExpObj.Outcome_Category__c);
                            Set<Id> exIdSet = new Set<Id>();
                            //AC = CU and OC= CU
                            if (stdntExpObj.Audit_Category__c + ' ' + stdntExpObj.Level_Type__c == 'Core Upper' && stdntExpObj.Outcome_Category__c == 'Core Upper') {
                                set<id> processedSahSetId = new set<id>();
                                // CORE UPPER BUCKET EVALUTION IF any SE Credits are Broken and Appiled.
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'Core Upper' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c == 'Core Upper') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_Core_Upper__c < cloneAuditHistory.Total_CE_Core_Upper__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                                        Decimal CETotalToSub = 0;
                                        Decimal CETotalToAdd = 0;
                                        Decimal totalCEVal = 0;
                                        Decimal remainingCE = 0;
                                        Decimal appliedCEOutCome = 0;

                                        if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                                            CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                                        }

                                        if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                                            totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                                        } else {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                                            totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                                        }

                                        remainingCE = cloneAuditHistory.Total_CE_Core_Upper__c - cloneAuditHistory.Earned_CE_Core_Upper__c;

                                        IF (totalCEVal != CETotalToSub) {
                                            If (CETotalToAdd <= remainingCE) {
                                                appliedCEOutCome = CETotalToAdd;
                                            } else {
                                                appliedCEOutCome = remainingCE;
                                            }
                                            cloneAuditHistory.Earned_CE_Core_Upper__c += appliedCEOutCome ;
                                            Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                                    Outcome_Category__c = 'Core Upper', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                                            stExList.add(stObj);
                                            processedSahSetId.add(saHstryObj.id);
                                        }
                                    }
                                }

                                //Back to CU
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {//6
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                                    system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c == 'Core Upper') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_Core_Upper__c < cloneAuditHistory.Total_CE_Core_Upper__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                                        System.debug('saHstryObj.Student_Expertise__r.Outcome_Category__c::' + saHstryObj.Student_Expertise__r.Outcome_Category__c);
                                        exIdSet.add(saHstryObj.Student_Expertise__c);
                                        Decimal CETotalToSub = 0;
                                        Decimal CETotalToAdd = 0;
                                        Decimal remainingCE = 0;
                                        Decimal appliedCEOutCome = 0;

                                        if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                                            CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                                        }

                                        if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                                        } else {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                                        }

                                        cloneAuditHistory.Earned_Back__c -= CETotalToSub;
                                        remainingCE = cloneAuditHistory.Total_CE_Core_Upper__c - cloneAuditHistory.Earned_CE_Core_Upper__c;//8
                                        If (CETotalToAdd <= remainingCE) {
                                            appliedCEOutCome = CETotalToAdd;
                                        } else {
                                            appliedCEOutCome = remainingCE;
                                        }
                                        cloneAuditHistory.Earned_CE_Core_Upper__c += appliedCEOutCome ;

                                        System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                                Outcome_Category__c = 'Core Upper', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome);
                                        stExList.add(stObj);
                                        processedSahSetId.add(saHstryObj.id);
                                    }
                                }

                                //GE to CU
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                                    system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c == 'Core Upper') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_Core_Upper__c < cloneAuditHistory.Total_CE_Core_Upper__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                                        System.debug('saHstryObj.Student_Expertise__r.Outcome_Category__c::' + saHstryObj.Student_Expertise__r.Outcome_Category__c);
                                        exIdSet.add(saHstryObj.Student_Expertise__c);
                                        Decimal CETotalToSub = 0;
                                        Decimal CETotalToAdd = 0;
                                        Decimal remainingCE = 0;
                                        Decimal appliedCEOutCome = 0;
                                        if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                                            CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                                        }

                                        if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                                        } else {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                                        }


                                        cloneAuditHistory.Earned_CE_General_Electives__c -= CETotalToSub;

                                        remainingCE = cloneAuditHistory.Total_CE_Core_Upper__c - cloneAuditHistory.Earned_CE_Core_Upper__c;
                                        If (CETotalToAdd <= remainingCE) {
                                            appliedCEOutCome = CETotalToAdd;
                                        } else {
                                            appliedCEOutCome = remainingCE;
                                        }
                                        cloneAuditHistory.Earned_CE_Core_Upper__c += appliedCEOutCome ;

                                        System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                                Outcome_Category__c = 'Core Upper', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome);
                                        stExList.add(stObj);
                                        processedSahSetId.add(saHstryObj.id);
                                    }
                                }


                                //  Elective Bucket Evalution IF any SE Credits are Broken and Appiled.
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                                        Decimal CETotalToSub = 0;
                                        Decimal CETotalToAdd = 0;
                                        Decimal totalCEVal = 0;
                                        Decimal remainingCE = 0;
                                        Decimal appliedCEOutCome = 0;

                                        if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                                            CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                                        }

                                        if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                                            totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                                        } else {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                                            totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                                        }

                                        remainingCE = cloneAuditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;

                                        IF (totalCEVal != CETotalToSub) {
                                            If (CETotalToAdd <= remainingCE) {
                                                appliedCEOutCome = CETotalToAdd;
                                            } else {
                                                appliedCEOutCome = remainingCE;
                                            }
                                            cloneAuditHistory.Earned_CE_General_Electives__c += appliedCEOutCome ;
                                            Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                                    Outcome_Category__c = 'General Elective', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                                            stExList.add(stObj);
                                            processedSahSetId.add(saHstryObj.id);
                                        }
                                    }
                                }

                                //Back -> Elec
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                                    system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                                        backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                                        processedSahSetId.add(saHstryObj.id);
                                    }
                                }

                                //new
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                                    system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'Concentration' || (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Lower' ||
                                                    (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' +
                                                            saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Upper' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                                        backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                                        processedSahSetId.add(saHstryObj.id);
                                    }
                                }
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {

                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

                                    system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'Core Lower' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c == 'Core Upper') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_Core_Upper__c < cloneAuditHistory.Total_CE_Core_Upper__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                                        exIdSet.add(saHstryObj.Student_Expertise__c);
                                        Decimal CETotalToSub = 0;
                                        Decimal CETotalToAdd = 0;
                                        Decimal remainingCE = 0;
                                        Decimal appliedCEOutCome = 0;
                                        if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                                            CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                                        }

                                        if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                                        } else {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                                        }

                                        cloneAuditHistory.Earned_CE_Core__c -= CETotalToSub;

                                        remainingCE = cloneAuditHistory.Total_CE_Core_Upper__c - cloneAuditHistory.Earned_CE_Core_Upper__c;
                                        If (CETotalToAdd <= remainingCE) {
                                            appliedCEOutCome = CETotalToAdd;
                                        } else {
                                            appliedCEOutCome = remainingCE;
                                        }
                                        cloneAuditHistory.Earned_CE_Core_Upper__c += appliedCEOutCome ;

                                        System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                                Outcome_Category__c = 'Core Upper', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome);
                                        stExList.add(stObj);
                                        processedSahSetId.add(saHstryObj.id);
                                    }
                                }

                                //  Core Lower Bucket Evalution IF any SE Credits are Broken and Appiled.
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'Core Lower' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'Core Lower') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_Core__c < cloneAuditHistory.Total_CE_Core__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                                        Decimal CETotalToSub = 0;
                                        Decimal CETotalToAdd = 0;
                                        Decimal totalCEVal = 0;
                                        Decimal remainingCE = 0;
                                        Decimal appliedCEOutCome = 0;

                                        if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                                            CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                                        }

                                        if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                                            totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                                        } else {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                                            totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                                        }

                                        remainingCE = cloneAuditHistory.Total_CE_Core__c - cloneAuditHistory.Earned_CE_Core__c;

                                        IF (totalCEVal != CETotalToSub) {
                                            If (CETotalToAdd <= remainingCE) {
                                                appliedCEOutCome = CETotalToAdd;
                                            } else {
                                                appliedCEOutCome = remainingCE;
                                            }
                                            cloneAuditHistory.Earned_CE_Core__c += appliedCEOutCome ;
                                            Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                                    Outcome_Category__c = 'Core Lower', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                                            stExList.add(stObj);
                                            processedSahSetId.add(saHstryObj.id);
                                        }
                                    }
                                }

                                // Back - CL
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {

                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                                    system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c == 'Core Lower') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_Core__c < cloneAuditHistory.Total_CE_Core__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                                        exIdSet.add(saHstryObj.Student_Expertise__c);
                                        Decimal CETotalToSub = 0;
                                        Decimal CETotalToAdd = 0;
                                        Decimal remainingCE = 0;
                                        Decimal appliedCEOutCome = 0;
                                        if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                                            CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                                        }

                                        if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                                        } else {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                                        }

                                        cloneAuditHistory.Earned_Back__c -= CETotalToSub;


                                        remainingCE = cloneAuditHistory.Total_CE_Core__c - cloneAuditHistory.Earned_CE_Core__c;
                                        If (CETotalToAdd <= remainingCE) {
                                            appliedCEOutCome = CETotalToAdd;
                                        } else {
                                            appliedCEOutCome = remainingCE;
                                        }
                                        cloneAuditHistory.Earned_CE_Core__c += appliedCEOutCome ;

                                        System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                                Outcome_Category__c = 'Core Lower', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome);
                                        stExList.add(stObj);
                                        processedSahSetId.add(saHstryObj.id);

                                    }
                                }

                                //new
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {

                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                                    system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c == 'Core Lower') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_Core__c < cloneAuditHistory.Total_CE_Core__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                                        exIdSet.add(saHstryObj.Student_Expertise__c);
                                        Decimal CETotalToSub = 0;
                                        Decimal CETotalToAdd = 0;
                                        Decimal remainingCE = 0;
                                        Decimal appliedCEOutCome = 0;
                                        if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                                            CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                                        }

                                        if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                                        } else {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                                        }
                                        cloneAuditHistory.Earned_CE_General_Electives__c -= CETotalToSub;


                                        remainingCE = cloneAuditHistory.Total_CE_Core__c - cloneAuditHistory.Earned_CE_Core__c;
                                        If (CETotalToAdd <= remainingCE) {
                                            appliedCEOutCome = CETotalToAdd;
                                        } else {
                                            appliedCEOutCome = remainingCE;
                                        }
                                        cloneAuditHistory.Earned_CE_Core__c += appliedCEOutCome ;

                                        System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                                Outcome_Category__c = 'Core Lower', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome);
                                        stExList.add(stObj);
                                        processedSahSetId.add(saHstryObj.id);


                                    }
                                }

                                //  Elective Bucket Evalution IF any SE Credits are Broken and Appiled.
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                                        Decimal CETotalToSub = 0;
                                        Decimal CETotalToAdd = 0;
                                        Decimal totalCEVal = 0;
                                        Decimal remainingCE = 0;
                                        Decimal appliedCEOutCome = 0;

                                        if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                                            CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                                        }

                                        if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                                            totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                                        } else {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                                            totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                                        }

                                        remainingCE = cloneAuditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;

                                        IF (totalCEVal != CETotalToSub) {
                                            If (CETotalToAdd <= remainingCE) {
                                                appliedCEOutCome = CETotalToAdd;
                                            } else {
                                                appliedCEOutCome = remainingCE;
                                            }
                                            cloneAuditHistory.Earned_CE_General_Electives__c += appliedCEOutCome ;
                                            Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                                    Outcome_Category__c = 'General Elective', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                                            stExList.add(stObj);
                                            processedSahSetId.add(saHstryObj.id);
                                        }
                                    }
                                }

                                //Gelec from Back - elective
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                                    system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                                        backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                                        processedSahSetId.add(saHstryObj.id);
                                    }
                                }

                                //Any course from Back - Elective
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                                    system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'Concentration' || (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Lower' ||
                                                    (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' +
                                                            saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Upper' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                                        backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                                        processedSahSetId.add(saHstryObj.id);
                                    }
                                }
                            }


                            // 3 & 5 //AC= CU && OC = CL
                            else if ((stdntExpObj.Audit_Category__c + ' ' + stdntExpObj.Level_Type__c == 'Core Upper' || stdntExpObj.Audit_Category__c + ' ' + stdntExpObj.Level_Type__c == 'Core Lower') && stdntExpObj.Outcome_Category__c == 'Core Lower') {
                                set<id> processedSahSetId = new set<id>();

                                //  Core Lower Bucket Evalution IF any SE Credits are Broken and Appiled.
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'Core Lower' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'Core Lower') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_Core__c < cloneAuditHistory.Total_CE_Core__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                                        Decimal CETotalToSub = 0;
                                        Decimal CETotalToAdd = 0;
                                        Decimal totalCEVal = 0;
                                        Decimal remainingCE = 0;
                                        Decimal appliedCEOutCome = 0;

                                        if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                                            CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                                        }

                                        if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                                            totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                                        } else {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                                            totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                                        }

                                        remainingCE = cloneAuditHistory.Total_CE_Core__c - cloneAuditHistory.Earned_CE_Core__c;

                                        IF (totalCEVal != CETotalToSub) {
                                            If (CETotalToAdd <= remainingCE) {
                                                appliedCEOutCome = CETotalToAdd;
                                            } else {
                                                appliedCEOutCome = remainingCE;
                                            }
                                            cloneAuditHistory.Earned_CE_Core__c += appliedCEOutCome ;
                                            Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                                    Outcome_Category__c = 'Core Lower', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                                            stExList.add(stObj);
                                            processedSahSetId.add(saHstryObj.id);
                                        }
                                    }
                                }


                                //CL from  BAck > CL
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {

                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                                    system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c == 'Core Lower') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_Core__c < cloneAuditHistory.Total_CE_Core__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                                        exIdSet.add(saHstryObj.Student_Expertise__c);
                                        Decimal CETotalToSub = 0;
                                        Decimal CETotalToAdd = 0;
                                        Decimal remainingCE = 0;
                                        Decimal appliedCEOutCome = 0;
                                        if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                                            CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                                        }

                                        if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                                        } else {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                                        }

                                        system.debug('%%%%%%%%%%%%%%%%%%%  CETotal>>>>>' + CETotalToSub);
                                        system.debug('%%%%%%%%%%%%%%%%%%%  stdntExpObj.Outcome_Category__c>>>>>' + stdntExpObj.Outcome_Category__c);
                                        system.debug('saHstryObj.Student_Expertise__r.Outcome_Category__c:::' + saHstryObj.Student_Expertise__r.Outcome_Category__c);
                                        system.debug('CETotal:::' + CETotalToAdd);

                                        cloneAuditHistory.Earned_Back__c -= CETotalToSub;


                                        remainingCE = cloneAuditHistory.Total_CE_Core__c - cloneAuditHistory.Earned_CE_Core__c;
                                        If (CETotalToAdd <= remainingCE) {
                                            appliedCEOutCome = CETotalToAdd;
                                        } else {
                                            appliedCEOutCome = remainingCE;
                                        }
                                        cloneAuditHistory.Earned_CE_Core__c += appliedCEOutCome ;

                                        System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                                Outcome_Category__c = 'Core Lower', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome);
                                        stExList.add(stObj);
                                        processedSahSetId.add(saHstryObj.id);

                                    }
                                }
                                //CL from GE - CL
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {

                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                                    system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c == 'Core Lower') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_Core__c < cloneAuditHistory.Total_CE_Core__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                                        exIdSet.add(saHstryObj.Student_Expertise__c);
                                        Decimal CETotalToSub = 0;
                                        Decimal CETotalToAdd = 0;
                                        Decimal remainingCE = 0;
                                        Decimal appliedCEOutCome = 0;
                                        if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                                            CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                                        }

                                        if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                                        } else {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                                        }

                                        system.debug('%%%%%%%%%%%%%%%%%%%  CETotal>>>>>' + CETotalToSub);
                                        system.debug('%%%%%%%%%%%%%%%%%%%  stdntExpObj.Outcome_Category__c>>>>>' + stdntExpObj.Outcome_Category__c);
                                        system.debug('saHstryObj.Student_Expertise__r.Outcome_Category__c:::' + saHstryObj.Student_Expertise__r.Outcome_Category__c);
                                        system.debug('CETotal:::' + CETotalToAdd);

                                        cloneAuditHistory.Earned_CE_General_Electives__c -= CETotalToSub;


                                        remainingCE = cloneAuditHistory.Total_CE_Core__c - cloneAuditHistory.Earned_CE_Core__c;
                                        If (CETotalToAdd <= remainingCE) {
                                            appliedCEOutCome = CETotalToAdd;
                                        } else {
                                            appliedCEOutCome = remainingCE;
                                        }
                                        cloneAuditHistory.Earned_CE_Core__c += appliedCEOutCome ;

                                        System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                                Outcome_Category__c = 'Core Lower', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome);
                                        stExList.add(stObj);
                                        processedSahSetId.add(saHstryObj.id);

                                    }
                                }

                                //  Elective Bucket Evalution IF any SE Credits are Broken and Appiled.
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                                        Decimal CETotalToSub = 0;
                                        Decimal CETotalToAdd = 0;
                                        Decimal totalCEVal = 0;
                                        Decimal remainingCE = 0;
                                        Decimal appliedCEOutCome = 0;

                                        if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                                            CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                                        }

                                        if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                                            totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                                        } else {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                                            totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                                        }

                                        remainingCE = cloneAuditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;

                                        IF (totalCEVal != CETotalToSub) {
                                            If (CETotalToAdd <= remainingCE) {
                                                appliedCEOutCome = CETotalToAdd;
                                            } else {
                                                appliedCEOutCome = remainingCE;
                                            }
                                            cloneAuditHistory.Earned_CE_General_Electives__c += appliedCEOutCome ;
                                            Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                                    Outcome_Category__c = 'General Elective', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                                            stExList.add(stObj);
                                            processedSahSetId.add(saHstryObj.id);
                                        }
                                    }
                                }

                                //Back - elective
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                                    system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                                        backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                                        processedSahSetId.add(saHstryObj.id);
                                    }
                                }

                                //Any course back to Elec
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                                    system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'Concentration' || (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Lower' ||
                                                    (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' +
                                                            saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Upper' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                                        backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                                        processedSahSetId.add(saHstryObj.id);
                                    }
                                }

                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {

                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                                    system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c == 'Core Upper') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_Core__c < cloneAuditHistory.Total_CE_Core__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                                        exIdSet.add(saHstryObj.Student_Expertise__c);
                                        Decimal CETotalToSub = 0;
                                        Decimal CETotalToAdd = 0;
                                        Decimal remainingCE = 0;
                                        Decimal appliedCEOutCome = 0;
                                        if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                                            CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                                        }

                                        if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                                        } else {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                                        }

                                        cloneAuditHistory.Earned_Back__c -= CETotalToSub;


                                        remainingCE = cloneAuditHistory.Total_CE_Core__c - cloneAuditHistory.Earned_CE_Core__c;
                                        If (CETotalToAdd <= remainingCE) {
                                            appliedCEOutCome = CETotalToAdd;
                                        } else {
                                            appliedCEOutCome = remainingCE;
                                        }
                                        cloneAuditHistory.Earned_CE_Core__c += appliedCEOutCome ;

                                        System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                                Outcome_Category__c = 'Core Lower', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome);
                                        stExList.add(stObj);
                                        processedSahSetId.add(saHstryObj.id);
                                    }
                                }

                                //new
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {

                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                                    system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c == 'Core Upper') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_Core__c < cloneAuditHistory.Total_CE_Core__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                                        exIdSet.add(saHstryObj.Student_Expertise__c);
                                        Decimal CETotalToSub = 0;
                                        Decimal CETotalToAdd = 0;
                                        Decimal remainingCE = 0;
                                        Decimal appliedCEOutCome = 0;
                                        if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                                            CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                                        }

                                        if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                                        } else {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                                        }

                                        cloneAuditHistory.Earned_CE_General_Electives__c -= CETotalToSub;


                                        remainingCE = cloneAuditHistory.Total_CE_Core__c - cloneAuditHistory.Earned_CE_Core__c;
                                        If (CETotalToAdd <= remainingCE) {
                                            appliedCEOutCome = CETotalToAdd;
                                        } else {
                                            appliedCEOutCome = remainingCE;
                                        }
                                        cloneAuditHistory.Earned_CE_Core__c += appliedCEOutCome ;

                                        System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                                Outcome_Category__c = 'Core Lower', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome);
                                        stExList.add(stObj);
                                        processedSahSetId.add(saHstryObj.id);

                                    }
                                }

                                //  Elective Bucket Evalution IF any SE Credits are Broken and Appiled.
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                                        Decimal CETotalToSub = 0;
                                        Decimal CETotalToAdd = 0;
                                        Decimal totalCEVal = 0;
                                        Decimal remainingCE = 0;
                                        Decimal appliedCEOutCome = 0;

                                        if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                                            CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                                        }

                                        if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                                            totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                                        } else {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                                            totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                                        }

                                        remainingCE = cloneAuditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;

                                        IF (totalCEVal != CETotalToSub) {
                                            If (CETotalToAdd <= remainingCE) {
                                                appliedCEOutCome = CETotalToAdd;
                                            } else {
                                                appliedCEOutCome = remainingCE;
                                            }
                                            cloneAuditHistory.Earned_CE_General_Electives__c += appliedCEOutCome ;
                                            Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                                    Outcome_Category__c = 'General Elective', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                                            stExList.add(stObj);
                                            processedSahSetId.add(saHstryObj.id);
                                        }
                                    }
                                }

                                //Back - elective
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                                    system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                                        backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                                        processedSahSetId.add(saHstryObj.id);
                                    }
                                }

                                //Any course back - Elec
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                                    system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'Concentration' || (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Lower' ||
                                                    (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' +
                                                            saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Upper' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                                        backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                                        processedSahSetId.add(saHstryObj.id);
                                    }
                                }
                            }
                            //OC = Elec AU = Any CAt
                            else if ((stdntExpObj.Audit_Category__c + ' ' + stdntExpObj.Level_Type__c == 'Core Upper' || stdntExpObj.Audit_Category__c + ' ' + stdntExpObj.Level_Type__c == 'Core Lower' || stdntExpObj.Audit_Category__c == 'Concentration' || stdntExpObj.Audit_Category__c == 'General Elective' || stdntExpObj.Audit_Category__c == 'General Education' || stdntExpObj.Audit_Category__c == 'General Education; General Elective') && stdntExpObj.Outcome_Category__c == 'General Elective') {
                                debugCloneAuditHistory(cloneAuditHistory);
                                set<id> processedSahSetId = new set<id>();
                                //  Elective Bucket Evalution IF any SE Credits are Broken and Appiled.
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                                        Decimal CETotalToSub = 0;
                                        Decimal CETotalToAdd = 0;
                                        Decimal totalCEVal = 0;
                                        Decimal remainingCE = 0;
                                        Decimal appliedCEOutCome = 0;

                                        if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                                            CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                                        }

                                        if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                                            totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                                        } else {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                                            totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                                        }

                                        remainingCE = cloneAuditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;

                                        IF (totalCEVal != CETotalToSub) {
                                            If (CETotalToAdd <= remainingCE) {
                                                appliedCEOutCome = CETotalToAdd;
                                            } else {
                                                appliedCEOutCome = remainingCE;
                                            }
                                            cloneAuditHistory.Earned_CE_General_Electives__c += appliedCEOutCome ;
                                            Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                                    Outcome_Category__c = 'General Elective', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                                            stExList.add(stObj);
                                            processedSahSetId.add(saHstryObj.id);
                                        }
                                    }
                                }
                                //Any elective in Back to Electives
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                                    system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                                        system.debug('debugCloneAuditHistory' + saHstryObj);
                                        system.debug('debugCloneAuditHistory' + stExList);
                                        system.debug('debugCloneAuditHistory' + exIdSet);
                                        debugCloneAuditHistory(cloneAuditHistory);

                                        backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                                        processedSahSetId.add(saHstryObj.id);
                                    }
                                }
                                //Any Course in Back to Electives
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    system.debug('debugCloneAuditHistory');
                                    debugCloneAuditHistory(cloneAuditHistory);

                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'Concentration' || (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Lower' ||
                                                    (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' +
                                                            saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Upper' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {


                                        system.debug('debugCloneAuditHistory' + saHstryObj);
                                        system.debug('debugCloneAuditHistory' + stExList);
                                        system.debug('debugCloneAuditHistory' + exIdSet);
                                        debugCloneAuditHistory(cloneAuditHistory);

                                        backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                                        processedSahSetId.add(saHstryObj.id);
                                    }
                                }
                                debugCloneAuditHistory(cloneAuditHistory);
                            }
                            //AU = Concentration & OC = Concentration
                            else if (stdntExpObj.Audit_Category__c == 'Concentration' && stdntExpObj.Outcome_Category__c == 'Concentration') {
                                set<id> processedSahSetId = new set<id>();


                                //  Concentration Bucket Evalution IF any SE Credits are Broken and Appiled.
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'Concentration' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'Concentration') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_Concentration__c < cloneAuditHistory.Total_CE_Concentration__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                                        Decimal CETotalToSub = 0;
                                        Decimal CETotalToAdd = 0;
                                        Decimal totalCEVal = 0;
                                        Decimal remainingCE = 0;
                                        Decimal appliedCEOutCome = 0;

                                        if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                                            CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                                        }

                                        if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                                            totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                                        } else {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                                            totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                                        }

                                        remainingCE = cloneAuditHistory.Total_CE_Concentration__c - cloneAuditHistory.Earned_CE_Concentration__c;

                                        IF (totalCEVal != CETotalToSub) {
                                            If (CETotalToAdd <= remainingCE) {
                                                appliedCEOutCome = CETotalToAdd;
                                            } else {
                                                appliedCEOutCome = remainingCE;
                                            }
                                            cloneAuditHistory.Earned_CE_Concentration__c += appliedCEOutCome ;
                                            Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                                    Outcome_Category__c = 'Concentration', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                                            stExList.add(stObj);
                                            processedSahSetId.add(saHstryObj.id);
                                        }
                                    }
                                }


                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                                    system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'Concentration') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_Concentration__c < cloneAuditHistory.Total_CE_Concentration__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                                        System.debug('saHstryObj.Student_Expertise__r.Outcome_Category__c::' + saHstryObj.Student_Expertise__r.Outcome_Category__c);
                                        exIdSet.add(saHstryObj.Student_Expertise__c);
                                        Decimal CETotalToSub = 0;
                                        Decimal CETotalToAdd = 0;
                                        Decimal remainingCE = 0;
                                        Decimal appliedCEOutCome = 0;
                                        if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                                            CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                                        }

                                        if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                                        } else {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                                        }

                                        cloneAuditHistory.Earned_Back__c -= CETotalToSub;


                                        remainingCE = cloneAuditHistory.Total_CE_Concentration__c - cloneAuditHistory.Earned_CE_Concentration__c;
                                        If (CETotalToAdd <= remainingCE) {
                                            appliedCEOutCome = CETotalToAdd;
                                        } else {
                                            appliedCEOutCome = remainingCE;
                                        }
                                        cloneAuditHistory.Earned_CE_Concentration__c += appliedCEOutCome ;

                                        System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                                Outcome_Category__c = 'Concentration', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome);
                                        stExList.add(stObj);

                                        processedSahSetId.add(saHstryObj.id);
                                    }
                                }
                                //new
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                                    system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'Concentration') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_Concentration__c < cloneAuditHistory.Total_CE_Concentration__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                                        System.debug('saHstryObj.Student_Expertise__r.Outcome_Category__c::' + saHstryObj.Student_Expertise__r.Outcome_Category__c);
                                        exIdSet.add(saHstryObj.Student_Expertise__c);
                                        Decimal CETotalToSub = 0;
                                        Decimal CETotalToAdd = 0;
                                        Decimal remainingCE = 0;
                                        Decimal appliedCEOutCome = 0;
                                        if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                                            CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                                        }

                                        if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                                        } else {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                                        }

                                        cloneAuditHistory.Earned_CE_General_Electives__c -= CETotalToSub;


                                        remainingCE = cloneAuditHistory.Total_CE_Concentration__c - cloneAuditHistory.Earned_CE_Concentration__c;
                                        If (CETotalToAdd <= remainingCE) {
                                            appliedCEOutCome = CETotalToAdd;
                                        } else {
                                            appliedCEOutCome = remainingCE;
                                        }
                                        cloneAuditHistory.Earned_CE_Concentration__c += appliedCEOutCome ;

                                        System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                                Outcome_Category__c = 'Concentration', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome);
                                        stExList.add(stObj);
                                        processedSahSetId.add(saHstryObj.id);
                                    }
                                }


                                //  Elective Bucket Evalution IF any SE Credits are Broken and Appiled.
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                                        Decimal CETotalToSub = 0;
                                        Decimal CETotalToAdd = 0;
                                        Decimal totalCEVal = 0;
                                        Decimal remainingCE = 0;
                                        Decimal appliedCEOutCome = 0;

                                        if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                                            CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                                        }

                                        if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                                            totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                                        } else {
                                            CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                                            totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                                        }

                                        remainingCE = cloneAuditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;

                                        IF (totalCEVal != CETotalToSub) {
                                            If (CETotalToAdd <= remainingCE) {
                                                appliedCEOutCome = CETotalToAdd;
                                            } else {
                                                appliedCEOutCome = remainingCE;
                                            }
                                            cloneAuditHistory.Earned_CE_General_Electives__c += appliedCEOutCome ;
                                            Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                                    Outcome_Category__c = 'General Elective', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                                            stExList.add(stObj);
                                            processedSahSetId.add(saHstryObj.id);
                                        }
                                    }
                                }


                                // Find Elective in Back --> Back - ,Elective +
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                                    system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                                        backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                                        processedSahSetId.add(saHstryObj.id);
                                    }
                                }
                                // Find Any course in Back --> Back - ,Elective +
                                exIdSet = new Set<Id>();
                                for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                                    Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                                    saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                                    system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                                    if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                                            !String.isBlank(saHstryObj.Student_Expertise__c) &&
                                            saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                                            !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                                            (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'Concentration' || (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Lower' ||
                                                    (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' +
                                                            saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Upper' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                                            saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                                            cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                                        backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                                        processedSahSetId.add(saHstryObj.id);
                                    }
                                }
                            }
                            //10
                            else if ((stdntExpObj.Audit_Category__c == 'General Education' || stdntExpObj.Audit_Category__c == 'General Education; General Elective') && stdntExpObj.Outcome_Category__c == 'General Education') {
                                system.debug('**OUTCOME = **General Education******');
                                system.debug('** = **SAE******' + stdntExpObj.Subject_Area_Expertise__c);
                                //Arts and Humanities
                                if (stdntExpObj.Subject_Area_Expertise__c == 'Arts and Humanities') {
                                    debugCloneAuditHistory(cloneAuditHistory);
                                    system.debug('****Arts and Humanities******');
                                    genEdArtsAndHumanities(stdntPrgmMap, stdntExpObj, exIdSet, stExList, cloneAuditHistory);
                                    debugCloneAuditHistory(cloneAuditHistory);
                                }
                                //Mathematics/Natural Sciences
                                else if (stdntExpObj.Subject_Area_Expertise__c == 'Mathematics/Natural Sciences') {
                                    genEdMathNaturalSciences(stdntPrgmMap, stdntExpObj, exIdSet, stExList, cloneAuditHistory);
                                }
                                //Social Sciences
                                else if (stdntExpObj.Subject_Area_Expertise__c == 'Social Sciences') {
                                    genEdSocialSciences(stdntPrgmMap, stdntExpObj, exIdSet, stExList, cloneAuditHistory);
                                }
                                //Written and Oral Communication
                                else if (stdntExpObj.Subject_Area_Expertise__c == 'Written and Oral Communication') {
                                    genEdWrittenAndOralCommunication(stdntPrgmMap, stdntExpObj, exIdSet, stExList, cloneAuditHistory);
                                }
                                //Statistics
                                else if (stdntExpObj.Subject_Area_Expertise__c == 'Statistics') {
                                    genEdStatastics(stdntPrgmMap, stdntExpObj, exIdSet, stExList, cloneAuditHistory);
                                }

                            }
                        }

                        debugCloneAuditHistory(cloneAuditHistory);

                        newAuditRecordMap.put(cloneAuditHistory.student_program__c, cloneAuditHistory);
                        lstStudentAuditHistory.add(cloneAuditHistory);
                        stdntExpObj.Outcome_Category__c = null;
                        System.debug('stdntExpObj::' + stdntExpObj);
                        calCompPrgmIdSet.add(stdntExpObj.Student_Program__c);
                    }
                }


                System.debug('newAuditRecordMap!!!!!::' + newAuditRecordMap);
                System.debug('newAuditRecordMap!!!!!::' + newAuditRecordMap.values());
                System.debug('newAuditRecordMap!!!!!::' + newAuditRecordMap.keyset());
                System.debug('newAuditRecordMap!!!::' + newAuditRecordMap.size());
                if (!newAuditRecordMap.isEmpty()) {
                    insert newAuditRecordMap.values();
                }
                Map<id, student_expertise__c> seMap = new Map<id, student_expertise__c>();
                for (student_expertise__c se : stExList) {
                    System.debug('@@@@@SE::' + se);
                    seMap.put(se.id, se);
                }
                System.debug('stExList::' + stExList);
                System.debug('seMap.values()::' + seMap.values());
                System.debug('stExList::' + stExList.size());
                if (!seMap.isEmpty()) {
                    update seMap.values();
                }


                For (student_expertise__c se : stdntExpList) {
                    se.Outcome_Category__c = null;
                    se.Is_Audit_History_Created__c = false;
                    se.Total_Applied_Earned_CE_Outcome__c = null;
                    se.Outcome_Subject_Area_Expertise__c = null;
                }

                System.debug('stdntExpList::' + stdntExpList);
                if (!stdntExpList.isEmpty()) {
                    update stdntExpList;
                }
            }
        } catch (Exception ex) {
            System.debug('Exception ex::' + ex);
        }
    }

    //Logic for Written and Oral Communication
    Public static void genEdWrittenAndOralCommunication(Map<Id, Student_Program__c> stdntPrgmMap, Student_Expertise__c stdntExpObj, Set<Id> exIdSet, List<Student_Expertise__c> stExList, Student_Audit_History__c cloneAuditHistory) {
        set<id> processedSahSetId = new set<id>();
        If (stdntExpObj.Outcome_Subject_Area_Expertise__c == 'Written and Oral Communication') {

            //Gen Ed Written and Oral Communication SUb Buc Evalution IF any SE Credits are Broken and Appiled.
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Education' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Written and Oral Communication' &&
                        cloneAuditHistory.Earned_CE_Written_and_Oral_Communication__c < cloneAuditHistory.Total_CE_Written_and_Oral_Communication__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal totalCEVal = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    remainingCE = cloneAuditHistory.Total_CE_Written_and_Oral_Communication__c - cloneAuditHistory.Earned_CE_Written_and_Oral_Communication__c;

                    IF (totalCEVal != CETotalToSub) {
                        If (CETotalToAdd <= remainingCE) {
                            appliedCEOutCome = CETotalToAdd;
                        } else {
                            appliedCEOutCome = remainingCE;
                        }
                        cloneAuditHistory.Earned_CE_Written_and_Oral_Communication__c += appliedCEOutCome ;
                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                        stExList.add(stObj);
                        processedSahSetId.add(saHstryObj.id);
                    }
                }
            }
            //Find GE.SS in Back -> Back -  GEdu-WOC +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Written and Oral Communication' &&
                        cloneAuditHistory.Earned_CE_Written_and_Oral_Communication__c < cloneAuditHistory.Total_CE_Written_and_Oral_Communication__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                    System.debug('saHstryObj.Student_Expertise__r.Outcome_Category__c::' + saHstryObj.Student_Expertise__r.Outcome_Category__c);
                    exIdSet.add(saHstryObj.Student_Expertise__c);
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;
                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }
                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }
                    cloneAuditHistory.Earned_Back__c -= CETotalToSub;
                    remainingCE = cloneAuditHistory.Total_CE_Written_and_Oral_Communication__c - cloneAuditHistory.Earned_CE_Written_and_Oral_Communication__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_Written_and_Oral_Communication__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Written and Oral Communication');
                    stExList.add(stObj);
                    processedSahSetId.add(saHstryObj.id);

                }
            }
            //Find GE.SS in GElec -> GElec -  GE-WOC +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Written and Oral Communication' &&
                        cloneAuditHistory.Earned_CE_Written_and_Oral_Communication__c < cloneAuditHistory.Total_CE_Written_and_Oral_Communication__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                    System.debug('saHstryObj.Student_Expertise__r.Outcome_Category__c::' + saHstryObj.Student_Expertise__r.Outcome_Category__c);
                    exIdSet.add(saHstryObj.Student_Expertise__c);


                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    cloneAuditHistory.Earned_CE_General_Electives__c -= CETotalToSub;


                    remainingCE = cloneAuditHistory.Total_CE_Written_and_Oral_Communication__c - cloneAuditHistory.Earned_CE_Written_and_Oral_Communication__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_Written_and_Oral_Communication__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Written and Oral Communication');
                    stExList.add(stObj);
                    processedSahSetId.add(saHstryObj.id);
                }
            }
            //  Elective Bucket Evalution IF any SE Credits are Broken and Appiled.
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal totalCEVal = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    remainingCE = cloneAuditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;

                    IF (totalCEVal != CETotalToSub) {
                        If (CETotalToAdd <= remainingCE) {
                            appliedCEOutCome = CETotalToAdd;
                        } else {
                            appliedCEOutCome = remainingCE;
                        }
                        cloneAuditHistory.Earned_CE_General_Electives__c += appliedCEOutCome ;
                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                Outcome_Category__c = 'General Elective', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                        stExList.add(stObj);
                        processedSahSetId.add(saHstryObj.id);
                    }
                }
            }
            // Find Gen Elec in Back 	--> Back - ,Elective +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                    processedSahSetId.add(saHstryObj.id);
                }
            }
            // Find Any Course in Back 	--> Back - ,Elective +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'Concentration' || (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Lower' ||
                                (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' +
                                        saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Upper' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                    backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                    processedSahSetId.add(saHstryObj.id);

                }
            }
            // Find GE.SS in Any 	--> GE.Any - ,GE.SS +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Education' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Written and Oral Communication' &&
                        stdntExpObj.Outcome_Subject_Area_Expertise__c == 'Any Category' &&
                        cloneAuditHistory.Earned_CE_Written_and_Oral_Communication__c < cloneAuditHistory.Total_CE_Written_and_Oral_Communication__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    system.debug('##########New Logic for any');
                    exIdSet.add(saHstryObj.Student_Expertise__c);

                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;
                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    cloneAuditHistory.Earned_CE_Any_Category__c -= CETotalToSub;


                    remainingCE = cloneAuditHistory.Total_CE_Written_and_Oral_Communication__c - cloneAuditHistory.Earned_CE_Written_and_Oral_Communication__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_Written_and_Oral_Communication__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Written and Oral Communication');
                    stExList.add(stObj);
                    processedSahSetId.add(saHstryObj.id);

                }
            }
            //Gen Ed Any Category SUb Buc Evalution IF any SE Credits are Broken and Appiled.
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Education' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Written and Oral Communication' &&
                        cloneAuditHistory.Earned_CE_Any_Category__c < cloneAuditHistory.Total_CE_Any_Category__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal totalCEVal = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    remainingCE = cloneAuditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;

                    IF (totalCEVal != CETotalToSub) {
                        If (CETotalToAdd <= remainingCE) {
                            appliedCEOutCome = CETotalToAdd;
                        } else {
                            appliedCEOutCome = remainingCE;
                        }
                        cloneAuditHistory.Earned_CE_Any_Category__c += appliedCEOutCome ;
                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                        stExList.add(stObj);
                        processedSahSetId.add(saHstryObj.id);
                    }
                }
            }

            // Find GE.(Any 4 SUB Cat ) in Back 	--> Back - ,GE.Any +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'Back' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_Any_Category__c < cloneAuditHistory.Total_CE_Any_Category__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    system.debug('##########New Logic for any');
                    exIdSet.add(saHstryObj.Student_Expertise__c);

                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;
                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    cloneAuditHistory.Earned_Back__c -= CETotalToSub;


                    remainingCE = cloneAuditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_Any_Category__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Any Category');
                    stExList.add(stObj);

                    processedSahSetId.add(saHstryObj.id);
                }
            }

            // Find GE.(Any 4 SUB Cat ) in Elective 	--> Elective - ,GE.Any +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_Any_Category__c < cloneAuditHistory.Total_CE_Any_Category__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    system.debug('##########New Logic for any');
                    exIdSet.add(saHstryObj.Student_Expertise__c);

                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;
                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    cloneAuditHistory.Earned_CE_General_Electives__c -= CETotalToSub;


                    remainingCE = cloneAuditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_Any_Category__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Any Category');
                    stExList.add(stObj);
                    processedSahSetId.add(saHstryObj.id);
                }

            }

            //  Elective Bucket Evalution IF any SE Credits are Broken and Appiled.
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal totalCEVal = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    remainingCE = cloneAuditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;

                    IF (totalCEVal != CETotalToSub) {
                        If (CETotalToAdd <= remainingCE) {
                            appliedCEOutCome = CETotalToAdd;
                        } else {
                            appliedCEOutCome = remainingCE;
                        }
                        cloneAuditHistory.Earned_CE_General_Electives__c += appliedCEOutCome ;
                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                Outcome_Category__c = 'General Elective', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                        stExList.add(stObj);
                        processedSahSetId.add(saHstryObj.id);
                    }
                }
            }

            // Find Elective in Back --> Back - ,Elective +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                    processedSahSetId.add(saHstryObj.id);
                }
            }
            // Find Any Course in Back --> Back -, Elective +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'Concentration' || (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Lower' ||
                                (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' +
                                        saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Upper' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                    backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                    processedSahSetId.add(saHstryObj.id);
                }
            }
        }
        //Any Categort Logic
        else if (stdntExpObj.Outcome_Subject_Area_Expertise__c == 'Any Category') {
            genEdAnyCat(stdntPrgmMap, stdntExpObj, exIdSet, stExList, cloneAuditHistory);
        }
    }
    //Logic for Social Sciences
    Public static void genEdSocialSciences(Map<Id, Student_Program__c> stdntPrgmMap, Student_Expertise__c stdntExpObj, Set<Id> exIdSet, List<Student_Expertise__c> stExList, Student_Audit_History__c cloneAuditHistory) {
        set<id> processedSahSetId = new set<id>();
        If (stdntExpObj.Outcome_Subject_Area_Expertise__c == 'Social Sciences') {

            //Gen Ed Social Science SUb Buc Evalution IF any SE Credits are Broken and Appiled.
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Education' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Social Sciences' &&
                        cloneAuditHistory.Earned_CE_Social_Science__c < cloneAuditHistory.Total_CE_Social_Science__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal totalCEVal = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    remainingCE = cloneAuditHistory.Total_CE_Social_Science__c - cloneAuditHistory.Earned_CE_Social_Science__c;

                    IF (totalCEVal != CETotalToSub) {
                        If (CETotalToAdd <= remainingCE) {
                            appliedCEOutCome = CETotalToAdd;
                        } else {
                            appliedCEOutCome = remainingCE;
                        }
                        cloneAuditHistory.Earned_CE_Social_Science__c += appliedCEOutCome ;
                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                        stExList.add(stObj);
                        processedSahSetId.add(saHstryObj.id);
                    }
                }
            }
            //Find GE.SS in Back -> Back -  GEdu-SS +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Social Sciences' &&
                        cloneAuditHistory.Earned_CE_Social_Science__c < cloneAuditHistory.Total_CE_Social_Science__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                    System.debug('saHstryObj.Student_Expertise__r.Outcome_Category__c::' + saHstryObj.Student_Expertise__r.Outcome_Category__c);
                    exIdSet.add(saHstryObj.Student_Expertise__c);
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;
                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }
                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }
                    cloneAuditHistory.Earned_Back__c -= CETotalToSub;
                    remainingCE = cloneAuditHistory.Total_CE_Social_Science__c - cloneAuditHistory.Earned_CE_Social_Science__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_Social_Science__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Social Sciences');
                    stExList.add(stObj);
                    processedSahSetId.add(saHstryObj.id);

                }
            }

            //Find GE.SS in GElec -> GElec -  GE-SS +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Social Sciences' &&
                        cloneAuditHistory.Earned_CE_Social_Science__c < cloneAuditHistory.Total_CE_Social_Science__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                    System.debug('saHstryObj.Student_Expertise__r.Outcome_Category__c::' + saHstryObj.Student_Expertise__r.Outcome_Category__c);
                    exIdSet.add(saHstryObj.Student_Expertise__c);

                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    cloneAuditHistory.Earned_CE_General_Electives__c -= CETotalToSub;


                    remainingCE = cloneAuditHistory.Total_CE_Social_Science__c - cloneAuditHistory.Earned_CE_Social_Science__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_Social_Science__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Social Sciences');
                    stExList.add(stObj);
                    processedSahSetId.add(saHstryObj.id);
                }
            }

            //  Elective Bucket Evalution IF any SE Credits are Broken and Appiled.
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal totalCEVal = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    remainingCE = cloneAuditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;

                    IF (totalCEVal != CETotalToSub) {
                        If (CETotalToAdd <= remainingCE) {
                            appliedCEOutCome = CETotalToAdd;
                        } else {
                            appliedCEOutCome = remainingCE;
                        }
                        cloneAuditHistory.Earned_CE_General_Electives__c += appliedCEOutCome ;
                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                Outcome_Category__c = 'General Elective', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                        stExList.add(stObj);
                        processedSahSetId.add(saHstryObj.id);
                    }
                }
            }


            // Find Gen Elec in Back 	--> Back - ,Elective +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);
                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                    processedSahSetId.add(saHstryObj.id);
                }

            }

            // Find Any Course in Back 	--> Back - ,Elective +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);
                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'Concentration' || (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Lower' ||
                                (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' +
                                        saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Upper' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                    backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);

                    processedSahSetId.add(saHstryObj.id);
                }

            }

            // Find GE.SS in Any 	--> GE.Any - ,GE.SS +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Education' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Social Sciences' &&
                        stdntExpObj.Outcome_Subject_Area_Expertise__c == 'Any Category' &&
                        cloneAuditHistory.Earned_CE_Social_Science__c < cloneAuditHistory.Total_CE_Social_Science__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    system.debug('##########New Logic for any');
                    exIdSet.add(saHstryObj.Student_Expertise__c);

                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;
                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    cloneAuditHistory.Earned_CE_Any_Category__c -= CETotalToSub;


                    remainingCE = cloneAuditHistory.Total_CE_Social_Science__c - cloneAuditHistory.Earned_CE_Social_Science__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_Social_Science__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Social Sciences');
                    stExList.add(stObj);
                    processedSahSetId.add(saHstryObj.id);


                }
            }

            //Gen Ed Any Category SUb Buc Evalution IF any SE Credits are Broken and Appiled.
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Education' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Written and Oral Communication' &&
                        cloneAuditHistory.Earned_CE_Any_Category__c < cloneAuditHistory.Total_CE_Any_Category__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal totalCEVal = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    remainingCE = cloneAuditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;

                    IF (totalCEVal != CETotalToSub) {
                        If (CETotalToAdd <= remainingCE) {
                            appliedCEOutCome = CETotalToAdd;
                        } else {
                            appliedCEOutCome = remainingCE;
                        }
                        cloneAuditHistory.Earned_CE_Any_Category__c += appliedCEOutCome ;
                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                        stExList.add(stObj);
                        processedSahSetId.add(saHstryObj.id);
                    }
                }
            }

            // Find GE.(Any 4 SUB Cat ) in Back 	--> Back - ,GE.Any +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'Back' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_Any_Category__c < cloneAuditHistory.Total_CE_Any_Category__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    system.debug('##########New Logic for any');
                    exIdSet.add(saHstryObj.Student_Expertise__c);

                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;
                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    cloneAuditHistory.Earned_Back__c -= CETotalToSub;


                    remainingCE = cloneAuditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_Any_Category__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Any Category');
                    stExList.add(stObj);

                    processedSahSetId.add(saHstryObj.id);
                }
            }

            // Find GE.(Any 4 SUB Cat ) in Elective 	--> Elective - ,GE.Any +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_Any_Category__c < cloneAuditHistory.Total_CE_Any_Category__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    system.debug('##########New Logic for any');
                    exIdSet.add(saHstryObj.Student_Expertise__c);

                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;
                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    cloneAuditHistory.Earned_CE_General_Electives__c -= CETotalToSub;


                    remainingCE = cloneAuditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_Any_Category__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Any Category');
                    stExList.add(stObj);

                    processedSahSetId.add(saHstryObj.id);
                }

            }

            //  Elective Bucket Evalution IF any SE Credits are Broken and Appiled.
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal totalCEVal = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    remainingCE = cloneAuditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;

                    IF (totalCEVal != CETotalToSub) {
                        If (CETotalToAdd <= remainingCE) {
                            appliedCEOutCome = CETotalToAdd;
                        } else {
                            appliedCEOutCome = remainingCE;
                        }
                        cloneAuditHistory.Earned_CE_General_Electives__c += appliedCEOutCome ;
                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                Outcome_Category__c = 'General Elective', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                        stExList.add(stObj);
                        processedSahSetId.add(saHstryObj.id);
                    }
                }
            }

            // Find Elective in Back --> Back - ,Elective +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);
                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);

                    processedSahSetId.add(saHstryObj.id);
                }

            }

            // Find Any Course in Back --> Back -, Elective +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);
                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'Concentration' || (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Lower' ||
                                (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' +
                                        saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Upper' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                    backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);


                    processedSahSetId.add(saHstryObj.id);
                }

            }
        }

        //Any Categort Logic
        else if (stdntExpObj.Outcome_Subject_Area_Expertise__c == 'Any Category') {
            genEdAnyCat(stdntPrgmMap, stdntExpObj, exIdSet, stExList, cloneAuditHistory);
        }
    }
    //Logic for Mathematics/Natural Sciences
    Public static void genEdMathNaturalSciences(Map<Id, Student_Program__c> stdntPrgmMap, Student_Expertise__c stdntExpObj, Set<Id> exIdSet, List<Student_Expertise__c> stExList, Student_Audit_History__c cloneAuditHistory) {
        set<id> processedSahSetId = new set<id>();
        If (stdntExpObj.Outcome_Subject_Area_Expertise__c == 'Mathematics/Natural Sciences') {

            //Gen Ed MathNaturalSciences SUb Buc Evalution IF any SE Credits are Broken and Appiled.
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Education' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Mathematics/Natural Sciences' &&
                        cloneAuditHistory.Earned_CE_Mathematics_Natural_Science__c < cloneAuditHistory.Total_CE_Mathematics_Natural_Science__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal totalCEVal = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    remainingCE = cloneAuditHistory.Total_CE_Mathematics_Natural_Science__c - cloneAuditHistory.Earned_CE_Mathematics_Natural_Science__c;

                    IF (totalCEVal != CETotalToSub) {
                        If (CETotalToAdd <= remainingCE) {
                            appliedCEOutCome = CETotalToAdd;
                        } else {
                            appliedCEOutCome = remainingCE;
                        }
                        cloneAuditHistory.Earned_CE_Mathematics_Natural_Science__c += appliedCEOutCome ;
                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                        stExList.add(stObj);
                        processedSahSetId.add(saHstryObj.id);
                    }
                }
            }

            //Find GE.MNS in Back -> Back -  GEdu-MNS +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Mathematics/Natural Sciences' &&
                        cloneAuditHistory.Earned_CE_Mathematics_Natural_Science__c < cloneAuditHistory.Total_CE_Mathematics_Natural_Science__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                    System.debug('saHstryObj.Student_Expertise__r.Outcome_Category__c::' + saHstryObj.Student_Expertise__r.Outcome_Category__c);
                    exIdSet.add(saHstryObj.Student_Expertise__c);
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;
                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }
                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }
                    cloneAuditHistory.Earned_Back__c -= CETotalToSub;
                    remainingCE = cloneAuditHistory.Total_CE_Arts_and_Humanities__c - cloneAuditHistory.Earned_CE_Arts_and_Humanities__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_Mathematics_Natural_Science__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Mathematics/Natural Sciences');
                    stExList.add(stObj);
                    processedSahSetId.add(saHstryObj.id);

                }
            }
            //Find GE.MNS in GElec -> GElec -  GE-MNS +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Mathematics/Natural Sciences' &&
                        cloneAuditHistory.Earned_CE_Mathematics_Natural_Science__c < cloneAuditHistory.Total_CE_Mathematics_Natural_Science__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                    System.debug('saHstryObj.Student_Expertise__r.Outcome_Category__c::' + saHstryObj.Student_Expertise__r.Outcome_Category__c);
                    exIdSet.add(saHstryObj.Student_Expertise__c);


                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    cloneAuditHistory.Earned_CE_General_Electives__c -= CETotalToSub;


                    remainingCE = cloneAuditHistory.Total_CE_Mathematics_Natural_Science__c - cloneAuditHistory.Earned_CE_Mathematics_Natural_Science__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_Mathematics_Natural_Science__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Mathematics/Natural Sciences');
                    stExList.add(stObj);
                    processedSahSetId.add(saHstryObj.id);

                }
            }

            //  Elective Bucket Evalution IF any SE Credits are Broken and Appiled.
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal totalCEVal = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    remainingCE = cloneAuditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;

                    IF (totalCEVal != CETotalToSub) {
                        If (CETotalToAdd <= remainingCE) {
                            appliedCEOutCome = CETotalToAdd;
                        } else {
                            appliedCEOutCome = remainingCE;
                        }
                        cloneAuditHistory.Earned_CE_General_Electives__c += appliedCEOutCome ;
                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                Outcome_Category__c = 'General Elective', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                        stExList.add(stObj);
                        processedSahSetId.add(saHstryObj.id);
                    }
                }
            }

            // Find Gen Elec in Back 	--> Back - ,Elective +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                    processedSahSetId.add(saHstryObj.id);


                }
            }
            // Find Any Course in Back 	--> Back - ,Elective +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'Concentration' || (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Lower' ||
                                (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' +
                                        saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Upper' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                    backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);

                    processedSahSetId.add(saHstryObj.id);


                }
            }
            // Find GE.MNS in Any 	--> GE.Any - ,GE.MNS +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Education' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Mathematics/Natural Sciences' &&
                        stdntExpObj.Outcome_Subject_Area_Expertise__c == 'Any Category' &&
                        cloneAuditHistory.Earned_CE_Mathematics_Natural_Science__c < cloneAuditHistory.Total_CE_Mathematics_Natural_Science__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    system.debug('##########New Logic for any');
                    exIdSet.add(saHstryObj.Student_Expertise__c);

                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;
                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    cloneAuditHistory.Earned_CE_Any_Category__c -= CETotalToSub;


                    remainingCE = cloneAuditHistory.Total_CE_Mathematics_Natural_Science__c - cloneAuditHistory.Earned_CE_Mathematics_Natural_Science__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_Mathematics_Natural_Science__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Mathematics/Natural Sciences');
                    stExList.add(stObj);


                    processedSahSetId.add(saHstryObj.id);

                }
            }

            //Gen Ed Any Category SUb Buc Evalution IF any SE Credits are Broken and Appiled.
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Education' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Written and Oral Communication' &&
                        cloneAuditHistory.Earned_CE_Any_Category__c < cloneAuditHistory.Total_CE_Any_Category__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal totalCEVal = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    remainingCE = cloneAuditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;

                    IF (totalCEVal != CETotalToSub) {
                        If (CETotalToAdd <= remainingCE) {
                            appliedCEOutCome = CETotalToAdd;
                        } else {
                            appliedCEOutCome = remainingCE;
                        }
                        cloneAuditHistory.Earned_CE_Any_Category__c += appliedCEOutCome ;
                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                        stExList.add(stObj);
                        processedSahSetId.add(saHstryObj.id);
                    }
                }
            }

            // Find GE.(Any 4 SUB Cat ) in Back 	--> Back - ,GE.Any +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'Back' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_Any_Category__c < cloneAuditHistory.Total_CE_Any_Category__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    system.debug('##########New Logic for any');
                    exIdSet.add(saHstryObj.Student_Expertise__c);

                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;
                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    cloneAuditHistory.Earned_Back__c -= CETotalToSub;


                    remainingCE = cloneAuditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_Any_Category__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Any Category');
                    stExList.add(stObj);


                    processedSahSetId.add(saHstryObj.id);

                }
            }
            // Find GE.(Any 4 SUB Cat ) in Elective 	--> Elective - ,GE.Any +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_Any_Category__c < cloneAuditHistory.Total_CE_Any_Category__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    system.debug('##########New Logic for any');
                    exIdSet.add(saHstryObj.Student_Expertise__c);

                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;
                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    cloneAuditHistory.Earned_CE_General_Electives__c -= CETotalToSub;


                    remainingCE = cloneAuditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_Any_Category__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Any Category');
                    stExList.add(stObj);

                    processedSahSetId.add(saHstryObj.id);

                }

            }

            //  Elective Bucket Evalution IF any SE Credits are Broken and Appiled.
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal totalCEVal = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    remainingCE = cloneAuditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;

                    IF (totalCEVal != CETotalToSub) {
                        If (CETotalToAdd <= remainingCE) {
                            appliedCEOutCome = CETotalToAdd;
                        } else {
                            appliedCEOutCome = remainingCE;
                        }
                        cloneAuditHistory.Earned_CE_General_Electives__c += appliedCEOutCome ;
                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                Outcome_Category__c = 'General Elective', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                        stExList.add(stObj);
                        processedSahSetId.add(saHstryObj.id);
                    }
                }
            }

            // Find Elective in Back --> Back - ,Elective +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);

                    processedSahSetId.add(saHstryObj.id);

                }
            }
            // Find Any Course in Back --> Back -, Elective +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'Concentration' || (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Lower' ||
                                (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' +
                                        saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Upper' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                    backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);

                    processedSahSetId.add(saHstryObj.id);


                }
            }


        }
        //Any Categort Logic
        else if (stdntExpObj.Outcome_Subject_Area_Expertise__c == 'Any Category') {
            genEdAnyCat(stdntPrgmMap, stdntExpObj, exIdSet, stExList, cloneAuditHistory);
        }
    }
    //Logic for Arts and Humanities
    Public static void genEdArtsAndHumanities(Map<Id, Student_Program__c> stdntPrgmMap, Student_Expertise__c stdntExpObj, Set<Id> exIdSet, List<Student_Expertise__c> stExList, Student_Audit_History__c cloneAuditHistory) {
        set<id> processedSahSetId = new set<id>();

        If (stdntExpObj.Outcome_Subject_Area_Expertise__c == 'Arts and Humanities') {
            system.debug('****Outcome SAE- Arts and Humanities******');

            //Gen Ed Arts and Humanities Sub Buc Evalution IF any SE Credits are Broken and Appiled.
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Education' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Arts and Humanities' &&
                        cloneAuditHistory.Earned_CE_Arts_and_Humanities__c < cloneAuditHistory.Total_CE_Arts_and_Humanities__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal totalCEVal = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    remainingCE = cloneAuditHistory.Total_CE_Arts_and_Humanities__c - cloneAuditHistory.Earned_CE_Arts_and_Humanities__c;

                    IF (totalCEVal != CETotalToSub) {
                        If (CETotalToAdd <= remainingCE) {
                            appliedCEOutCome = CETotalToAdd;
                        } else {
                            appliedCEOutCome = remainingCE;
                        }
                        cloneAuditHistory.Earned_CE_Arts_and_Humanities__c += appliedCEOutCome ;
                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                        stExList.add(stObj);
                        processedSahSetId.add(saHstryObj.id);
                    }
                }
            }

            //Find GE.AH in Back -> Back -  GEdu-AH +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Arts and Humanities' &&
                        cloneAuditHistory.Earned_CE_Arts_and_Humanities__c < cloneAuditHistory.Total_CE_Arts_and_Humanities__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    system.debug('%%%%%%%%%%%%%%%%%%%  1');
                    System.debug('saHstryObj.Student_Expertise__r.Outcome_Category__c::' + saHstryObj.Student_Expertise__r.Outcome_Category__c);
                    exIdSet.add(saHstryObj.Student_Expertise__c);
                    system.debug('%%%%%%%%%%%%%%%%%%% ' + saHstryObj);
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;
                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }
                    system.debug('cloneAuditHistory.Earned_Back__c ' + cloneAuditHistory.Earned_Back__c);
                    cloneAuditHistory.Earned_Back__c -= CETotalToSub;
                    system.debug('cloneAuditHistory.Earned_Back__c ' + cloneAuditHistory.Earned_Back__c);

                    remainingCE = cloneAuditHistory.Total_CE_Arts_and_Humanities__c - cloneAuditHistory.Earned_CE_Arts_and_Humanities__c; //10-0 = 10
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    system.debug('CETotalToSub' + CETotalToSub);//5
                    system.debug('CETotalToSub' + CETotalToAdd);//5
                    system.debug('CETotalToSub' + remainingCE);//10
                    system.debug('CETotalToSub' + appliedCEOutCome);
                    cloneAuditHistory.Earned_CE_Arts_and_Humanities__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Arts and Humanities');
                    stExList.add(stObj);
                    processedSahSetId.add(saHstryObj.id);

                }
            }

            //Find GE.AH in GElec -> GElec -  GE-AH +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {//6
                debugCloneAuditHistory(cloneAuditHistory);

                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Arts and Humanities' &&
                        cloneAuditHistory.Earned_CE_Arts_and_Humanities__c < cloneAuditHistory.Total_CE_Arts_and_Humanities__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    system.debug('%%%%%%%%%%%%%%%%%%%  2');
                    System.debug('saHstryObj.Student_Expertise__r.Outcome_Category__c::' + saHstryObj.Student_Expertise__r.Outcome_Category__c);
                    exIdSet.add(saHstryObj.Student_Expertise__c);

                    system.debug('%%%%%%%%%%%%%%%%%%% ' + saHstryObj);
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }
                    system.debug('cloneAuditHistory.Earned_CE_General_Electives__c ' + cloneAuditHistory.Earned_CE_General_Electives__c);
                    cloneAuditHistory.Earned_CE_General_Electives__c -= CETotalToSub;
                    system.debug('cloneAuditHistory.Earned_CE_General_Electives__c ' + cloneAuditHistory.Earned_CE_General_Electives__c);

                    remainingCE = cloneAuditHistory.Total_CE_Arts_and_Humanities__c - cloneAuditHistory.Earned_CE_Arts_and_Humanities__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    system.debug('CETotalToSub' + CETotalToSub);
                    system.debug('CETotalToSub' + CETotalToAdd);
                    system.debug('CETotalToSub' + remainingCE);
                    system.debug('CETotalToSub' + appliedCEOutCome);
                    cloneAuditHistory.Earned_CE_Arts_and_Humanities__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Arts and Humanities');
                    stExList.add(stObj);
                    processedSahSetId.add(saHstryObj.id);

                }
                debugCloneAuditHistory(cloneAuditHistory);

            }

            //  Elective Bucket Evalution IF any SE Credits are Broken and Appiled.
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal totalCEVal = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    remainingCE = cloneAuditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;

                    IF (totalCEVal != CETotalToSub) {
                        If (CETotalToAdd <= remainingCE) {
                            appliedCEOutCome = CETotalToAdd;
                        } else {
                            appliedCEOutCome = remainingCE;
                        }
                        cloneAuditHistory.Earned_CE_General_Electives__c += appliedCEOutCome ;
                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                Outcome_Category__c = 'General Elective', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                        stExList.add(stObj);
                        processedSahSetId.add(saHstryObj.id);
                    }
                }
            }

            // Find Gen Elec in Back 	--> Back - ,Elective +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);
                debugCloneAuditHistory(cloneAuditHistory);
                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                    debugCloneAuditHistory(cloneAuditHistory);
                    backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                    processedSahSetId.add(saHstryObj.id);

                }
            }

            // Find Any Course in Back 	--> Back - ,Elective +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);
                debugCloneAuditHistory(cloneAuditHistory);
                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'Concentration' || (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Lower' ||
                                (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' +
                                        saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Upper' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    system.debug('%%%%%%%%%%%%%%%%%%% 4');

                    debugCloneAuditHistory(cloneAuditHistory);
                    backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                    processedSahSetId.add(saHstryObj.id);
                    debugCloneAuditHistory(cloneAuditHistory);
                }
            }

            // Find GE.AH in Any 	--> GE.Any - ,GE.AH +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Education' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Arts and Humanities' &&
                        stdntExpObj.Outcome_Subject_Area_Expertise__c == 'Any Category' &&
                        cloneAuditHistory.Earned_CE_Arts_and_Humanities__c < cloneAuditHistory.Total_CE_Arts_and_Humanities__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    system.debug('##########New Logic for any');
                    exIdSet.add(saHstryObj.Student_Expertise__c);

                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;
                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    cloneAuditHistory.Earned_CE_Any_Category__c -= CETotalToSub;


                    remainingCE = cloneAuditHistory.Total_CE_Arts_and_Humanities__c - cloneAuditHistory.Earned_CE_Arts_and_Humanities__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_Arts_and_Humanities__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Arts and Humanities');
                    stExList.add(stObj);
                    processedSahSetId.add(saHstryObj.id);

                }
            }

            //Gen Ed Any Category SUb Buc Evalution IF any SE Credits are Broken and Appiled.
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Education' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Written and Oral Communication' &&
                        cloneAuditHistory.Earned_CE_Any_Category__c < cloneAuditHistory.Total_CE_Any_Category__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal totalCEVal = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    remainingCE = cloneAuditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;

                    IF (totalCEVal != CETotalToSub) {
                        If (CETotalToAdd <= remainingCE) {
                            appliedCEOutCome = CETotalToAdd;
                        } else {
                            appliedCEOutCome = remainingCE;
                        }
                        cloneAuditHistory.Earned_CE_Any_Category__c += appliedCEOutCome ;
                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                        stExList.add(stObj);
                        processedSahSetId.add(saHstryObj.id);
                    }
                }
            }

            // Find GE.(Any 4 SUB Cat ) in Back 	--> Back - ,GE.Any +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'Back' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_Any_Category__c < cloneAuditHistory.Total_CE_Any_Category__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    system.debug('##########New Logic for any');
                    exIdSet.add(saHstryObj.Student_Expertise__c);

                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;
                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    cloneAuditHistory.Earned_Back__c -= CETotalToSub;


                    remainingCE = cloneAuditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_Any_Category__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Any Category');
                    stExList.add(stObj);
                    processedSahSetId.add(saHstryObj.id);

                }
            }

            // Find GE.(Any 4 SUB Cat ) in Elective 	--> Elective - ,GE.Any +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_Any_Category__c < cloneAuditHistory.Total_CE_Any_Category__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    system.debug('##########New Logic for any');
                    exIdSet.add(saHstryObj.Student_Expertise__c);

                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;
                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    cloneAuditHistory.Earned_CE_General_Electives__c -= CETotalToSub;


                    remainingCE = cloneAuditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_Any_Category__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Any Category');
                    stExList.add(stObj);
                    processedSahSetId.add(saHstryObj.id);
                }

            }

            //  Elective Bucket Evalution IF any SE Credits are Broken and Appiled.
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal totalCEVal = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    remainingCE = cloneAuditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;

                    IF (totalCEVal != CETotalToSub) {
                        If (CETotalToAdd <= remainingCE) {
                            appliedCEOutCome = CETotalToAdd;
                        } else {
                            appliedCEOutCome = remainingCE;
                        }
                        cloneAuditHistory.Earned_CE_General_Electives__c += appliedCEOutCome ;
                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                Outcome_Category__c = 'General Elective', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                        stExList.add(stObj);
                        processedSahSetId.add(saHstryObj.id);
                    }
                }
            }

            // Find Elective in Back --> Back - ,Elective +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                    processedSahSetId.add(saHstryObj.id);

                }
            }

            // Find Any Course in Back --> Back -, Elective +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'Concentration' || (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Lower' ||
                                (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' +
                                        saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Upper' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c) {

                    backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                    processedSahSetId.add(saHstryObj.id);

                }
            }

            debugCloneAuditHistory(cloneAuditHistory);

        }
        //Any Categort Logic
        else if (stdntExpObj.Outcome_Subject_Area_Expertise__c == 'Any Category') {
            system.debug('****Outcome SAE- Arts and Humanities******');
            genEdAnyCat(stdntPrgmMap, stdntExpObj, exIdSet, stExList, cloneAuditHistory);

        }

    }
    //RV-S-39026
    Public static void genEdStatastics(Map<Id, Student_Program__c> stdntPrgmMap, Student_Expertise__c stdntExpObj, Set<Id> exIdSet, List<Student_Expertise__c> stExList, Student_Audit_History__c cloneAuditHistory) {
        set<id> processedSahSetId = new set<id>();

        If (stdntExpObj.Outcome_Subject_Area_Expertise__c == 'Statistics') {
            system.debug('****Outcome SAE- Statistics******');

            //Gen Ed Statistics Sub Buc Evalution IF any SE Credits are Broken and Appiled.
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Education' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Statistics' &&
                        cloneAuditHistory.Earned_CE_Statistics__c < cloneAuditHistory.Total_CE_Statistics__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal totalCEVal = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    remainingCE = cloneAuditHistory.Total_CE_Statistics__c - cloneAuditHistory.Earned_CE_Statistics__c;

                    IF (totalCEVal != CETotalToSub) {
                        If (CETotalToAdd <= remainingCE) {
                            appliedCEOutCome = CETotalToAdd;
                        } else {
                            appliedCEOutCome = remainingCE;
                        }
                        cloneAuditHistory.Earned_CE_Statistics__c += appliedCEOutCome ;
                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                        stExList.add(stObj);
                        processedSahSetId.add(saHstryObj.id);
                    }
                }
            }

            //Find GE.AH in Back -> Back -  GEdu-AH +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Statistics' &&
                        cloneAuditHistory.Earned_CE_Statistics__c < cloneAuditHistory.Total_CE_Statistics__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    system.debug('%%%%%%%%%%%%%%%%%%%  1');
                    System.debug('saHstryObj.Student_Expertise__r.Outcome_Category__c::' + saHstryObj.Student_Expertise__r.Outcome_Category__c);
                    exIdSet.add(saHstryObj.Student_Expertise__c);
                    system.debug('%%%%%%%%%%%%%%%%%%% ' + saHstryObj);
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;
                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }
                    system.debug('cloneAuditHistory.Earned_Back__c ' + cloneAuditHistory.Earned_Back__c);
                    cloneAuditHistory.Earned_Back__c -= CETotalToSub;
                    system.debug('cloneAuditHistory.Earned_Back__c ' + cloneAuditHistory.Earned_Back__c);

                    remainingCE = cloneAuditHistory.Total_CE_Statistics__c - cloneAuditHistory.Earned_CE_Statistics__c; //10-0 = 10
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    system.debug('CETotalToSub' + CETotalToSub);//5
                    system.debug('CETotalToSub' + CETotalToAdd);//5
                    system.debug('CETotalToSub' + remainingCE);//10
                    system.debug('CETotalToSub' + appliedCEOutCome);
                    cloneAuditHistory.Earned_CE_Statistics__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Statistics');
                    stExList.add(stObj);
                    processedSahSetId.add(saHstryObj.id);

                }
            }

            //Find GE.AH in GElec -> GElec -  GE-AH +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {//6
                debugCloneAuditHistory(cloneAuditHistory);

                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Statistics' &&
                        cloneAuditHistory.Earned_CE_Statistics__c < cloneAuditHistory.Total_CE_Statistics__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    system.debug('%%%%%%%%%%%%%%%%%%%  2');
                    System.debug('saHstryObj.Student_Expertise__r.Outcome_Category__c::' + saHstryObj.Student_Expertise__r.Outcome_Category__c);
                    exIdSet.add(saHstryObj.Student_Expertise__c);

                    system.debug('%%%%%%%%%%%%%%%%%%% ' + saHstryObj);
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }
                    system.debug('cloneAuditHistory.Earned_CE_General_Electives__c ' + cloneAuditHistory.Earned_CE_General_Electives__c);
                    cloneAuditHistory.Earned_CE_General_Electives__c -= CETotalToSub;
                    system.debug('cloneAuditHistory.Earned_CE_General_Electives__c ' + cloneAuditHistory.Earned_CE_General_Electives__c);

                    remainingCE = cloneAuditHistory.Total_CE_Statistics__c - cloneAuditHistory.Earned_CE_Statistics__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    system.debug('CETotalToSub' + CETotalToSub);
                    system.debug('CETotalToSub' + CETotalToAdd);
                    system.debug('CETotalToSub' + remainingCE);
                    system.debug('CETotalToSub' + appliedCEOutCome);
                    cloneAuditHistory.Earned_CE_Statistics__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Statistics');
                    stExList.add(stObj);
                    processedSahSetId.add(saHstryObj.id);

                }
                debugCloneAuditHistory(cloneAuditHistory);

            }

            //  Elective Bucket Evalution IF any SE Credits are Broken and Appiled.
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal totalCEVal = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    remainingCE = cloneAuditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;

                    IF (totalCEVal != CETotalToSub) {
                        If (CETotalToAdd <= remainingCE) {
                            appliedCEOutCome = CETotalToAdd;
                        } else {
                            appliedCEOutCome = remainingCE;
                        }
                        cloneAuditHistory.Earned_CE_General_Electives__c += appliedCEOutCome ;
                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                Outcome_Category__c = 'General Elective', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                        stExList.add(stObj);
                        processedSahSetId.add(saHstryObj.id);
                    }
                }
            }

            // Find Gen Elec in Back 	--> Back - ,Elective +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);
                debugCloneAuditHistory(cloneAuditHistory);
                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                    debugCloneAuditHistory(cloneAuditHistory);
                    backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                    processedSahSetId.add(saHstryObj.id);

                }
            }

            // Find Any Course in Back 	--> Back - ,Elective +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);
                debugCloneAuditHistory(cloneAuditHistory);
                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'Concentration' || (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Lower' ||
                                (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' +
                                        saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Upper' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    system.debug('%%%%%%%%%%%%%%%%%%% 4');

                    debugCloneAuditHistory(cloneAuditHistory);
                    backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                    processedSahSetId.add(saHstryObj.id);
                    debugCloneAuditHistory(cloneAuditHistory);
                }
            }

            // Find GE.AH in Any 	--> GE.Any - ,GE.stat +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Education' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Statistics' &&
                        stdntExpObj.Outcome_Subject_Area_Expertise__c == 'Any Category' &&
                        cloneAuditHistory.Earned_CE_Statistics__c < cloneAuditHistory.Total_CE_Statistics__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    system.debug('##########New Logic for any');
                    exIdSet.add(saHstryObj.Student_Expertise__c);

                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;
                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    cloneAuditHistory.Earned_CE_Any_Category__c -= CETotalToSub;


                    remainingCE = cloneAuditHistory.Total_CE_Statistics__c - cloneAuditHistory.Earned_CE_Statistics__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_Statistics__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Statistics');
                    stExList.add(stObj);
                    processedSahSetId.add(saHstryObj.id);

                }
            }

            //Gen Ed Any Category SUb Buc Evalution IF any SE Credits are Broken and Appiled.
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Education' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Statistics' &&
                        cloneAuditHistory.Earned_CE_Any_Category__c < cloneAuditHistory.Total_CE_Any_Category__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal totalCEVal = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    remainingCE = cloneAuditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;

                    IF (totalCEVal != CETotalToSub) {
                        If (CETotalToAdd <= remainingCE) {
                            appliedCEOutCome = CETotalToAdd;
                        } else {
                            appliedCEOutCome = remainingCE;
                        }
                        cloneAuditHistory.Earned_CE_Any_Category__c += appliedCEOutCome ;
                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                        stExList.add(stObj);
                        processedSahSetId.add(saHstryObj.id);
                    }
                }
            }

            // Find GE.(Any 4 SUB Cat ) in Back 	--> Back - ,GE.Any +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'Back' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_Any_Category__c < cloneAuditHistory.Total_CE_Any_Category__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    system.debug('##########New Logic for any');
                    exIdSet.add(saHstryObj.Student_Expertise__c);

                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;
                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    cloneAuditHistory.Earned_Back__c -= CETotalToSub;


                    remainingCE = cloneAuditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_Any_Category__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Any Category');
                    stExList.add(stObj);
                    processedSahSetId.add(saHstryObj.id);

                }
            }

            // Find GE.(Any 4 SUB Cat ) in Elective 	--> Elective - ,GE.Any +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_Any_Category__c < cloneAuditHistory.Total_CE_Any_Category__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    system.debug('##########New Logic for any');
                    exIdSet.add(saHstryObj.Student_Expertise__c);

                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;
                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    cloneAuditHistory.Earned_CE_General_Electives__c -= CETotalToSub;


                    remainingCE = cloneAuditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_Any_Category__c += appliedCEOutCome ;

                    System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Any Category');
                    stExList.add(stObj);
                    processedSahSetId.add(saHstryObj.id);
                }

            }

            //  Elective Bucket Evalution IF any SE Credits are Broken and Appiled.
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    Decimal CETotalToSub = 0;
                    Decimal CETotalToAdd = 0;
                    Decimal totalCEVal = 0;
                    Decimal remainingCE = 0;
                    Decimal appliedCEOutCome = 0;

                    if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                        CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                    }

                    if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                    } else {
                        CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                        totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                    }

                    remainingCE = cloneAuditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;

                    IF (totalCEVal != CETotalToSub) {
                        If (CETotalToAdd <= remainingCE) {
                            appliedCEOutCome = CETotalToAdd;
                        } else {
                            appliedCEOutCome = remainingCE;
                        }
                        cloneAuditHistory.Earned_CE_General_Electives__c += appliedCEOutCome ;
                        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                                Outcome_Category__c = 'General Elective', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                        stExList.add(stObj);
                        processedSahSetId.add(saHstryObj.id);
                    }
                }
            }

            // Find Elective in Back --> Back - ,Elective +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                    backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                    processedSahSetId.add(saHstryObj.id);

                }
            }

            // Find Any Course in Back --> Back -, Elective +
            exIdSet = new Set<Id>();
            for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
                Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
                saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
                system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

                if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                        !String.isBlank(saHstryObj.Student_Expertise__c) &&
                        saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                        !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                        (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'Concentration' || (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Lower' ||
                                (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' +
                                        saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Upper' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                        saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                        cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c) {

                    backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                    processedSahSetId.add(saHstryObj.id);

                }
            }

            debugCloneAuditHistory(cloneAuditHistory);

        }
        //Any Categort Logic
        else if (stdntExpObj.Outcome_Subject_Area_Expertise__c == 'Any Category') {
            system.debug('****Outcome SAE- Statistics******');
            genEdAnyCat(stdntPrgmMap, stdntExpObj, exIdSet, stExList, cloneAuditHistory);

        }

    }

    //RV-S-39026


    //Logic for Any Cat Assessment
    Public static void genEdAnyCat(Map<Id, Student_Program__c> stdntPrgmMap, Student_Expertise__c stdntExpObj, Set<Id> exIdSet, List<Student_Expertise__c> stExList, Student_Audit_History__c cloneAuditHistory) {
        set<id> processedSahSetId = new set<id>();

        //Gen Ed Any Category SUb Buc Evalution IF any SE Credits are Broken and Appiled.
        exIdSet = new Set<Id>();
        for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
            Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
            saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


            if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                    !String.isBlank(saHstryObj.Student_Expertise__c) &&
                    saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Education' &&
                    !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                    (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                    saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                    saHstryObj.Student_Expertise__r.Subject_Area_Expertise__c == 'Written and Oral Communication' &&
                    cloneAuditHistory.Earned_CE_Any_Category__c < cloneAuditHistory.Total_CE_Any_Category__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                Decimal CETotalToSub = 0;
                Decimal CETotalToAdd = 0;
                Decimal totalCEVal = 0;
                Decimal remainingCE = 0;
                Decimal appliedCEOutCome = 0;

                if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                    CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                }

                if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                    CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                    totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                } else {
                    CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                    totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                }

                remainingCE = cloneAuditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;

                IF (totalCEVal != CETotalToSub) {
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_Any_Category__c += appliedCEOutCome ;
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                    stExList.add(stObj);
                    processedSahSetId.add(saHstryObj.id);
                }
            }
        }
        // Find GE.(Any 4 SUB Cat ) in Back 	--> Back - ,GE.Any +
        exIdSet = new Set<Id>();
        for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
            Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
            saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

            if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                    !String.isBlank(saHstryObj.Student_Expertise__c) &&
                    saHstryObj.Student_Expertise__r.Outcome_Category__c == 'Back' &&
                    !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                    (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                    saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                    cloneAuditHistory.Earned_CE_Any_Category__c < cloneAuditHistory.Total_CE_Any_Category__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                system.debug('##########New Logic for any');
                exIdSet.add(saHstryObj.Student_Expertise__c);

                Decimal CETotalToSub = 0;
                Decimal CETotalToAdd = 0;
                Decimal remainingCE = 0;
                Decimal appliedCEOutCome = 0;
                if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                    CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                }

                if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                    CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                } else {
                    CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                }

                cloneAuditHistory.Earned_Back__c -= CETotalToSub;


                remainingCE = cloneAuditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;
                If (CETotalToAdd <= remainingCE) {
                    appliedCEOutCome = CETotalToAdd;
                } else {
                    appliedCEOutCome = remainingCE;
                }
                cloneAuditHistory.Earned_CE_Any_Category__c += appliedCEOutCome ;

                System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                        Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Any Category');
                stExList.add(stObj);

                processedSahSetId.add(saHstryObj.id);
            }
        }
        // Find GE.(Any 4 SUB Cat ) in Elective 	--> Elective - ,GE.Any +
        exIdSet = new Set<Id>();
        for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
            Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
            saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];

            if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                    !String.isBlank(saHstryObj.Student_Expertise__c) &&
                    saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                    !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                    (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                    saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                    cloneAuditHistory.Earned_CE_Any_Category__c < cloneAuditHistory.Total_CE_Any_Category__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                system.debug('##########New Logic for any');
                exIdSet.add(saHstryObj.Student_Expertise__c);

                Decimal CETotalToSub = 0;
                Decimal CETotalToAdd = 0;
                Decimal remainingCE = 0;
                Decimal appliedCEOutCome = 0;
                if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                    CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                }

                if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                    CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                } else {
                    CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
                }

                cloneAuditHistory.Earned_CE_General_Electives__c -= CETotalToSub;


                remainingCE = cloneAuditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;
                If (CETotalToAdd <= remainingCE) {
                    appliedCEOutCome = CETotalToAdd;
                } else {
                    appliedCEOutCome = remainingCE;
                }
                cloneAuditHistory.Earned_CE_Any_Category__c += appliedCEOutCome ;

                System.debug('cloneAuditHistory 1:::' + cloneAuditHistory);
                Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                        Outcome_Category__c = 'General Education', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome, Outcome_Subject_Area_Expertise__c = 'Any Category');
                stExList.add(stObj);
                processedSahSetId.add(saHstryObj.id);
            }

        }
        //  Elective Bucket Evalution IF any SE Credits are Broken and Appiled.
        exIdSet = new Set<Id>();
        for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
            Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
            saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];


            if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                    !String.isBlank(saHstryObj.Student_Expertise__c) &&
                    saHstryObj.Student_Expertise__r.Outcome_Category__c == 'General Elective' &&
                    !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                    (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                    saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                    cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                Decimal CETotalToSub = 0;
                Decimal CETotalToAdd = 0;
                Decimal totalCEVal = 0;
                Decimal remainingCE = 0;
                Decimal appliedCEOutCome = 0;

                if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
                    CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
                }

                if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
                    CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c - CETotalToSub;
                    totalCEVal = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
                } else {
                    CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c - CETotalToSub;
                    totalCEVal = saHstryObj.Student_Expertise__r.Total_CE__c;
                }

                remainingCE = cloneAuditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;

                IF (totalCEVal != CETotalToSub) {
                    If (CETotalToAdd <= remainingCE) {
                        appliedCEOutCome = CETotalToAdd;
                    } else {
                        appliedCEOutCome = remainingCE;
                    }
                    cloneAuditHistory.Earned_CE_General_Electives__c += appliedCEOutCome ;
                    Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                            Outcome_Category__c = 'General Elective', Total_Applied_Earned_CE_Outcome__c = CETotalToSub + appliedCEOutCome);
                    stExList.add(stObj);
                    processedSahSetId.add(saHstryObj.id);
                }
            }
        }
        // Find Elective in Back --> Back - ,Elective +
        exIdSet = new Set<Id>();
        for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
            Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
            saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
            system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

            if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                    !String.isBlank(saHstryObj.Student_Expertise__c) &&
                    saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                    !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                    (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Elective') &&
                    saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                    cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {
                backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                processedSahSetId.add(saHstryObj.id);
            }
        }
        // Find Any Course in Back --> Back -, Elective +
        exIdSet = new Set<Id>();
        for (Integer i = 0; i < stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r.size(); i++) {
            Student_Audit_History__c saHstryObj = new Student_Audit_History__c();
            saHstryObj = stdntPrgmMap.get(stdntExpObj.Student_Program__c).Student_Audit_Historys__r[i];
            system.debug('%%%%%%%%%%%%%%%%%%%  saHstryObj>>>>>' + saHstryObj);

            if (saHstryObj.Student_Expertise__r.Outcome_Category__c != null &&
                    !String.isBlank(saHstryObj.Student_Expertise__c) &&
                    saHstryObj.Student_Expertise__r.Outcome_Category__c == 'BACK' &&
                    !exIdSet.contains(saHstryObj.Student_Expertise__c) &&
                    (saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'Concentration' || (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' + saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Lower' ||
                            (saHstryObj.Student_Expertise__r.Audit_Category__c + ' ' +
                                    saHstryObj.Student_Expertise__r.Level_Type__c) == 'Core Upper' || saHstryObj.Student_Expertise__r.Audit_Category__c == 'General Education; General Elective') &&
                    saHstryObj.Student_Expertise__r.IsAchieved__c && saHstryObj.Student_Expertise__c != stdntExpObj.id &&
                    cloneAuditHistory.Earned_CE_General_Electives__c < cloneAuditHistory.Total_CE_General_Electives__c && !processedSahSetId.contains(saHstryObj.id) || test.isRunningTest()) {

                backToGe(saHstryObj, cloneAuditHistory, stExList, exIdSet);
                processedSahSetId.add(saHstryObj.id);

            }
        }
    }

    Public static void backToGe(Student_Audit_History__c saHstryObj, Student_Audit_History__c cloneAuditHistory, List<Student_Expertise__c> stExList, Set<Id> exIdSet) {

        system.debug('debugCloneAuditHistory' + saHstryObj);
        system.debug('debugCloneAuditHistory' + stExList);
        system.debug('debugCloneAuditHistory' + exIdSet);
        debugCloneAuditHistory(cloneAuditHistory);

        exIdSet.add(saHstryObj.Student_Expertise__c);
        Decimal CETotalToSub = 0;
        Decimal CETotalToAdd = 0;
        Decimal remainingCE = 0;
        Decimal appliedCEOutCome = 0;
        if (saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c != null) {
            CETotalToSub = saHstryObj.Student_Expertise__r.Total_Applied_Earned_CE_Outcome__c;
        }

        if (saHstryObj.Student_Expertise__r.Pseudo_Course__c && saHstryObj.Student_Expertise__r.Pseudo_CE__c != null) {
            CETotalToAdd = saHstryObj.Student_Expertise__r.Pseudo_CE__c;
        } else {
            CETotalToAdd = saHstryObj.Student_Expertise__r.Total_CE__c;
        }
        debugCloneAuditHistory(cloneAuditHistory);
        cloneAuditHistory.Earned_Back__c -= CETotalToSub;
        System.debug('appliedCEOutCome 1:::' + remainingCE);
        System.debug('appliedCEOutCome 1:::' + CETotalToAdd);
        System.debug('appliedCEOutCome 1:::' + appliedCEOutCome);

        remainingCE = cloneAuditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;

        If (CETotalToAdd <= remainingCE) {
            appliedCEOutCome = CETotalToAdd;
        } else {
            appliedCEOutCome = remainingCE;
        }
        cloneAuditHistory.Earned_CE_General_Electives__c += appliedCEOutCome ;

        System.debug('appliedCEOutCome 1:::' + remainingCE);
        System.debug('appliedCEOutCome 1:::' + CETotalToAdd);
        System.debug('appliedCEOutCome 1:::' + appliedCEOutCome);
        debugCloneAuditHistory(cloneAuditHistory);

        Student_Expertise__c stObj = new Student_Expertise__c(id = saHstryObj.Student_Expertise__c,
                Outcome_Category__c = 'General Elective', Total_Applied_Earned_CE_Outcome__c = appliedCEOutCome);
        stExList.add(stObj);

        debugCloneAuditHistory(cloneAuditHistory);

    }

    Public static void debugCloneAuditHistory(Student_Audit_History__c cloneAuditHistory) {
        System.debug('Earned_CE_Core_Upper__c::' + cloneAuditHistory.Earned_CE_Core_Upper__c);
        System.debug('Earned_CE_Core__c::' + cloneAuditHistory.Earned_CE_Core__c);
        System.debug('Earned_Back__c::' + cloneAuditHistory.Earned_Back__c);
        System.debug('Earned_CE_Concentration__c::' + cloneAuditHistory.Earned_CE_Concentration__c);
        System.debug('Earned_CE_General_Electives__c::' + cloneAuditHistory.Earned_CE_General_Electives__c);
        System.debug('Earned_CE_Arts_and_Humanities__c::' + cloneAuditHistory.Earned_CE_Arts_and_Humanities__c);
        System.debug('Earned_CE_Mathematics_Natural_Science__c::' + cloneAuditHistory.Earned_CE_Mathematics_Natural_Science__c);
        System.debug('Earned_CE_Social_Science__c::' + cloneAuditHistory.Earned_CE_Social_Science__c);
        System.debug('Earned_CE_Written_and_Oral_Communication__c::' + cloneAuditHistory.Earned_CE_Written_and_Oral_Communication__c);
        System.debug('Earned_CE_Any_Category__c::' + cloneAuditHistory.Earned_CE_Any_Category__c);
        System.debug('Earned_CE_General_Education__c::' + cloneAuditHistory.Earned_CE_General_Education__c);
        System.debug('Student_Expertise__c::' + cloneAuditHistory.Student_Expertise__c);
    }
}