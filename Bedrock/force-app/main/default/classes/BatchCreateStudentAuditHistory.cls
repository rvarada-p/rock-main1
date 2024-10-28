/************************************************************************************** 
Apex Class Name     : BatchCreateStudentAuditHistory
Created Date        : 23th December 2018
Function            : Helper class for StudentExpertiseTriggerHandler class
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                  
* Ravitej Varada            12/23/2018                Original Version

Revision History :

Ravitej Varada      - Jan 18th 2021 -  S-39026 -  Handle 'Statistics' subject area expetise in Gen Ed.
*************************************************************************************/
global with sharing class BatchCreateStudentAuditHistory implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    global integer totalrecordsProcess;
    global integer totalSuccess;
    global integer totalFailure;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String SOQL;
        totalrecordsProcess = 0;
        totalSuccess = 0;
        totalFailure = 0;

        List<String> gradProgramsForGenEdSet = new List<String>();
        for (Grad_Programs_for_GenEd_and_GenElective__c gradPrograms : Grad_Programs_for_GenEd_and_GenElective__c.getAll().values()) {
            gradProgramsForGenEdSet.add(gradPrograms.Name);
        }

        System.debug('*****: ' + String.join(gradProgramsForGenEdSet, '\', \''));

        SOQL = 'SELECT id,Name,IsAchieved__c  ,Audit_Category__c ,Level_Type__c ,Outcome_Category__c ,Pseudo_Course__c ,Pseudo_CE__c ,Total_CE__c ,Is_Audit_History_Created__c ,Area_of_Expertise__c ,Student_Program__c' +
                +' FROM Student_Expertise__c'
                + ' WHERE (Is_Audit_History_Created__c = False'
                + ' AND IsAchieved__c = TRUE AND Outcome_Category__c = null) AND (student_program__r.program__r.Degree_Level__c = \'Undergrad\' '
                + ' OR student_program__r.Program__r.ProductCode IN (\'' + String.join(gradProgramsForGenEdSet, '\', \'') + '\') )';

        return Database.getQueryLocator(SOQL);
    }

    global void execute(SchedulableContext SC) {
        BatchCreateStudentAuditHistory objBatch = new BatchCreateStudentAuditHistory();
        ID batchprocessid = Database.executeBatch(objBatch, 20);
    }


    global void execute(Database.BatchableContext bc, List<Student_Expertise__c> newStudentExps) {

        List<Student_Audit_History__c> lstStudentAuditHistory = new List<Student_Audit_History__c>();
        List<Student_Audit_History__c> lstStudentAuditHistoryToProcess = new List<Student_Audit_History__c>();
        List<Student_Expertise__c> studentExpertiseToUpdate = new List<Student_Expertise__c>();

        Set<Id> newStudentExpsIdsToProcess = new Set<Id>();
        Map<Id, Product2> mapProgram = new Map<Id, Product2>();
        Map<Id, Student_Program__c> mapStudentProgram = new Map<Id, Student_Program__c>();


        for (Student_Expertise__c studentExpertise : newStudentExps) {
            if (studentExpertise.IsAchieved__c && studentExpertise.Is_Audit_History_Created__c == False && studentExpertise.Pseudo_Course__c == False) {
                newStudentExpsIdsToProcess.add(studentExpertise.id);
            } else if (studentExpertise.IsAchieved__c && studentExpertise.Is_Audit_History_Created__c == False && studentExpertise.Pseudo_Course__c == True && studentExpertise.Pseudo_CE__c != null && studentExpertise.Pseudo_CE__c > 0) {
                newStudentExpsIdsToProcess.add(studentExpertise.id);
            }
        }


        newStudentExps = new List<Student_Expertise__c>([
                SELECT Id, Student_Program__r.Program__c,
                        Area_of_Expertise_Name__c,Area_of_Expertise__c,
                        Audit_Category__c,Contact__c,External_Key__c, IsAchieved__c,IsDeleted,Level_Type__c,
                        Name,Number_of_Competencies_Completed__c,Number_of_Competencies_Transferred__c,
                        Opportunity__c,Outcome_Category__c,Program_Expertise__c,Area_of_Expertise__r.Category__c,Pseudo_CE__c,
                        Area_of_Expertise__r.Level__c,Area_of_Expertise__r.Level_Type__c,Program_Expertise__r.Category__c,
                        Program_Institution__c,Program_Name__c,Pseudo_Course__c,Subject_Area_Expertise__c,
                        RecordTypeId,Student_Name__c,Student_Program__c,Total_CE__c, Is_Audit_History_Created__c
                FROM Student_Expertise__c
                WHERE Id IN :newStudentExpsIdsToProcess
        ]);

        Map<Id, List<Student_Expertise__c>> spseMap = new Map<Id, List<Student_Expertise__c>>();
        for (Student_Expertise__c seObj : newStudentExps) {
            if (spseMap.containsKey(seObj.Student_Program__c)) {
                List<Student_Expertise__c> sexpList = new List<Student_Expertise__c>();
                sexpList = spseMap.get(seObj.Student_Program__c);
                sexpList.add(seObj);
                spseMap.put(seObj.Student_Program__c, sexpList);
            } else {
                spseMap.put(seObj.Student_Program__c, new List<Student_Expertise__c>{
                        seObj
                });
            }
        }

        system.debug('&&&&&&&&newStudentExps : ' + newStudentExps);
        for (Student_Expertise__c studentExpertise : newStudentExps) {
            if (studentExpertise.Student_Program__r.Program__c != null) {
                mapProgram.put(studentExpertise.Student_Program__r.Program__c, new Product2());
            }
            if (studentExpertise.Student_Program__c != null) {
                mapStudentProgram.put(studentExpertise.Student_Program__c, new Student_Program__c());
            }
        }
        mapProgram = new Map<Id, Product2>([
                SELECT Id, (
                        SELECT Category__c,Level__c,Program__c,Subject_Area_Expertise__c,
                                Total_CE__c
                        FROM Degree_Requirements__r
                )
                FROM Product2
                WHERE Id IN :mapProgram.keySet()
        ]);

        mapStudentProgram = new Map<Id, Student_Program__c>([
                SELECT Id, (
                        SELECT Id, Total_CE_Core_Upper__c,
                                Total_CE_Core__c, Total_CE_Concentration__c, Total_CE_General_Electives__c,
                                Total_CE_General_Education__c, Earned_CE_Concentration__c, Earned_CE_Core__c,
                                Earned_CE_Core_Upper__c, Earned_CE_General_Education__c,
                                Earned_CE_General_Electives__c, Earned_Back__c, Name,
                                Student_Program__c,
                                Earned_CE_Arts_and_Humanities__c,
                                Total_CE_Arts_and_Humanities__c,
                                Earned_CE_Any_Category__c,
                                Total_CE_Any_Category__c,
                                Earned_CE_Written_and_Oral_Communication__c,
                                Total_CE_Written_and_Oral_Communication__c,
                                Earned_CE_Mathematics_Natural_Science__c,
                                Total_CE_Mathematics_Natural_Science__c,
                                Total_CE_Social_Science__c,
                                Earned_CE_Social_Science__c,
                                Earned_CE_Statistics__c,
                                Total_CE_Statistics__c
                        FROM Student_Audit_Historys__r
                        ORDER BY name DESC
                        LIMIT 1
                )
                FROM Student_Program__c
                WHERE Id IN :mapStudentProgram.keySet()
        ]);

        if (!mapProgram.isEmpty() && !mapStudentProgram.isEmpty()) {
            Student_Audit_History__c auditHistory = new Student_Audit_History__c();
            Student_Audit_History__c cloneAuditHistory = new Student_Audit_History__c();
            for (Id spId : spseMap.keySet()) {//1 SP
                lstStudentAuditHistoryToProcess = new List<Student_Audit_History__c>();
                for (Student_Expertise__c studentExpertise : spseMap.get(spId)) {//4 SE records
                    Student_Audit_History__c newAuditHistory_One = new Student_Audit_History__c();

                    //Category ,Level and Total CE Assignement
                    String auditCategory = '';
                    string levelType = '';
                    Decimal totalCE = 0;
                    If (studentExpertise.Audit_Category__c != null && studentExpertise.Level_Type__c != null) {
                        auditCategory = studentExpertise.Audit_Category__c;
                        levelType = studentExpertise.Level_Type__c;
                    }
                    if (studentExpertise.Pseudo_Course__c && studentExpertise.Pseudo_CE__c != null) {
                        totalCE = studentExpertise.Pseudo_CE__c;
                    } else {
                        totalCE = studentExpertise.Total_CE__c;
                    }
                    //*****  

                    //If Student Audit Record Found 
                    if ((!mapStudentProgram.get(studentExpertise.Student_Program__c).Student_Audit_Historys__r.isEmpty() && auditCategory != null && levelType != null) || (!lstStudentAuditHistoryToProcess.isEmpty() && auditCategory != null && levelType != null)) {
                        system.debug('SE :  ' + lstStudentAuditHistoryToProcess);

                        if (!lstStudentAuditHistoryToProcess.isEmpty()) {
                            for (Student_Audit_History__c sah : lstStudentAuditHistoryToProcess) {
                                auditHistory = sah.clone();
                                cloneAuditHistory = sah.clone();
                                cloneAuditHistory.Earned_Back__c = sah.Earned_Back__c;
                                cloneAuditHistory.Earned_CE_Concentration__c = sah.Earned_CE_Concentration__c;
                                cloneAuditHistory.Earned_CE_Core__c = sah.Earned_CE_Core__c;
                                cloneAuditHistory.Earned_CE_Core_Upper__c = sah.Earned_CE_Core_Upper__c;
                                cloneAuditHistory.Earned_CE_Any_Category__c = sah.Earned_CE_Any_Category__c ;
                                cloneAuditHistory.Earned_CE_Arts_and_Humanities__c = sah.Earned_CE_Arts_and_Humanities__c ;
                                cloneAuditHistory.Earned_CE_Written_and_Oral_Communication__c = sah.Earned_CE_Written_and_Oral_Communication__c ;
                                cloneAuditHistory.Earned_CE_Mathematics_Natural_Science__c = sah.Earned_CE_Mathematics_Natural_Science__c ;
                                cloneAuditHistory.Earned_CE_Social_Science__c = sah.Earned_CE_Social_Science__c ;
                                cloneAuditHistory.Earned_CE_Statistics__c = sah.Earned_CE_Statistics__c ;
                                cloneAuditHistory.Earned_CE_General_Electives__c = sah.Earned_CE_General_Electives__c;
                                cloneAuditHistory.Student_Program__c = sah.Student_Program__c;
                            }
                        } else {

                            auditHistory = mapStudentProgram.get(studentExpertise.Student_Program__c).Student_Audit_Historys__r[0];
                            cloneAuditHistory = auditHistory.clone(False, TRUE, false, false);
                        }

                        system.debug('*****cloneAuditHistory' + cloneAuditHistory.Earned_Back__c);
                        system.debug('*****auditHistory' + auditHistory.Earned_Back__c);
                        system.debug('*****auditCategory:' + auditCategory);
                        system.debug('*****Leveltype:' + Leveltype);
                        system.debug('*****cloneAuditHistory.Earned_CE_Core_Upper__c:' + cloneAuditHistory.Earned_CE_Core_Upper__c);
                        system.debug('*****auditHistory.Total_CE_Core_Upper__c:' + auditHistory.Total_CE_Core_Upper__c);
                        system.debug('*****auditHistory.Total_CE_Core__c:' + auditHistory.Total_CE_Core__c);

                        //Hirarchy Bucket RULE assignment
                        if (auditCategory == 'Core' && Leveltype == 'Upper') {
                            decimal remainingCE = 0;
                            if (cloneAuditHistory.Earned_CE_Core_Upper__c < auditHistory.Total_CE_Core_Upper__c) {  //8 <10
                                remainingCE = auditHistory.Total_CE_Core_Upper__c - cloneAuditHistory.Earned_CE_Core_Upper__c;// 10-8=2
                                If (totalCE <= remainingCE) {//10 <= 2
                                    cloneAuditHistory.Earned_CE_Core_Upper__c += totalCE ;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                } else {
                                    cloneAuditHistory.Earned_CE_Core_Upper__c += remainingCE ;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;
                                }
                                studentExpertise.Outcome_Category__c = 'Core Upper';

                            } else if (cloneAuditHistory.Earned_CE_Core__c < auditHistory.Total_CE_Core__c) {
                                remainingCE = auditHistory.Total_CE_Core__c - cloneAuditHistory.Earned_CE_Core__c;
                                If (totalCE <= remainingCE) {
                                    cloneAuditHistory.Earned_CE_Core__c += totalCE ;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                } else {
                                    cloneAuditHistory.Earned_CE_Core__c += remainingCE ;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;
                                }
                                studentExpertise.Outcome_Category__c = 'Core Lower';

                            } else if (cloneAuditHistory.Earned_CE_General_Electives__c < auditHistory.Total_CE_General_Electives__c) {
                                remainingCE = auditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;
                                If (totalCE <= remainingCE) {
                                    cloneAuditHistory.Earned_CE_General_Electives__c += totalCE ;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                } else {
                                    cloneAuditHistory.Earned_CE_General_Electives__c += remainingCE ;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;
                                }
                                studentExpertise.Outcome_Category__c = 'General Elective';
                            } else {
                                cloneAuditHistory.Earned_Back__c = auditHistory.Earned_Back__c + totalCE;
                                studentExpertise.Outcome_Category__c = 'Back';
                                studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;

                            }
                        } else if (auditCategory == 'Core' && Leveltype == 'Lower') {
                            decimal remainingCE = 0;
                            if (cloneAuditHistory.Earned_CE_Core__c < auditHistory.Total_CE_Core__c) {

                                remainingCE = auditHistory.Total_CE_Core__c - cloneAuditHistory.Earned_CE_Core__c;
                                If (totalCE <= remainingCE) {
                                    cloneAuditHistory.Earned_CE_Core__c += totalCE ;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                } else {
                                    cloneAuditHistory.Earned_CE_Core__c += remainingCE ;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;
                                }
                                studentExpertise.Outcome_Category__c = 'Core Lower';
                            } else if (cloneAuditHistory.Earned_CE_General_Electives__c < auditHistory.Total_CE_General_Electives__c) {
                                remainingCE = auditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;
                                If (totalCE <= remainingCE) {
                                    cloneAuditHistory.Earned_CE_General_Electives__c += totalCE ;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                } else {
                                    cloneAuditHistory.Earned_CE_General_Electives__c += remainingCE ;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;
                                }
                                studentExpertise.Outcome_Category__c = 'General Elective';

                            } else {
                                cloneAuditHistory.Earned_Back__c = auditHistory.Earned_Back__c + totalCE;
                                studentExpertise.Outcome_Category__c = 'Back';
                                studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;

                            }

                        } else if (auditCategory == 'Concentration') {
                            decimal remainingCE = 0;
                            if (cloneAuditHistory.Earned_CE_Concentration__c < auditHistory.Total_CE_Concentration__c) {
                                remainingCE = auditHistory.Total_CE_Concentration__c - cloneAuditHistory.Earned_CE_Concentration__c;
                                If (totalCE <= remainingCE) {
                                    cloneAuditHistory.Earned_CE_Concentration__c += totalCE ;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                } else {
                                    cloneAuditHistory.Earned_CE_Concentration__c += remainingCE ;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;
                                }
                                studentExpertise.Outcome_Category__c = 'Concentration';
                            } else if (cloneAuditHistory.Earned_CE_General_Electives__c < auditHistory.Total_CE_General_Electives__c) {
                                remainingCE = auditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;
                                If (totalCE <= remainingCE) {
                                    cloneAuditHistory.Earned_CE_General_Electives__c += totalCE ;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                } else {
                                    cloneAuditHistory.Earned_CE_General_Electives__c += remainingCE ;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;
                                }
                                studentExpertise.Outcome_Category__c = 'General Elective';
                            } else {
                                cloneAuditHistory.Earned_Back__c += totalCE;
                                studentExpertise.Outcome_Category__c = 'Back';
                                studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;

                            }

                        } else if (auditCategory == 'General Education' || auditCategory == 'General Education; General Elective') {
                            decimal remainingCE = 0;
                            IF (studentExpertise.Subject_Area_Expertise__c == 'Arts and Humanities') {

                                if (cloneAuditHistory.Earned_CE_Arts_and_Humanities__c < auditHistory.Total_CE_Arts_and_Humanities__c) {
                                    remainingCE = auditHistory.Total_CE_Arts_and_Humanities__c - cloneAuditHistory.Earned_CE_Arts_and_Humanities__c;
                                    If (totalCE <= remainingCE) {
                                        cloneAuditHistory.Earned_CE_Arts_and_Humanities__c += totalCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                    } else {
                                        cloneAuditHistory.Earned_CE_Arts_and_Humanities__c += remainingCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;
                                    }
                                    studentExpertise.Outcome_Category__c = 'General Education';
                                    studentExpertise.Outcome_Subject_Area_Expertise__c = 'Arts and Humanities';
                                } else if (cloneAuditHistory.Earned_CE_Any_Category__c < auditHistory.Total_CE_Any_Category__c) {
                                    remainingCE = auditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;
                                    If (totalCE <= remainingCE) {
                                        cloneAuditHistory.Earned_CE_Any_Category__c += totalCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                    } else {
                                        cloneAuditHistory.Earned_CE_Any_Category__c += remainingCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;

                                    }
                                    studentExpertise.Outcome_Category__c = 'General Education';
                                    studentExpertise.Outcome_Subject_Area_Expertise__c = 'Any Category';

                                } else if (cloneAuditHistory.Earned_CE_General_Electives__c < auditHistory.Total_CE_General_Electives__c) {
                                    remainingCE = auditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;
                                    If (totalCE <= remainingCE) {
                                        cloneAuditHistory.Earned_CE_General_Electives__c += totalCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;

                                    } else {
                                        cloneAuditHistory.Earned_CE_General_Electives__c += remainingCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;
                                    }
                                    studentExpertise.Outcome_Category__c = 'General Elective';

                                } else {
                                    cloneAuditHistory.Earned_Back__c += totalCE;
                                    studentExpertise.Outcome_Category__c = 'Back';
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;

                                }
                            } else IF (studentExpertise.Subject_Area_Expertise__c == 'Written and Oral Communication') {


                                if (cloneAuditHistory.Earned_CE_Written_and_Oral_Communication__c < auditHistory.Total_CE_Written_and_Oral_Communication__c) {
                                    remainingCE = auditHistory.Total_CE_Written_and_Oral_Communication__c - cloneAuditHistory.Earned_CE_Written_and_Oral_Communication__c;
                                    If (totalCE <= remainingCE) {
                                        cloneAuditHistory.Earned_CE_Written_and_Oral_Communication__c += totalCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                    } else {
                                        cloneAuditHistory.Earned_CE_Written_and_Oral_Communication__c += remainingCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;
                                    }
                                    studentExpertise.Outcome_Category__c = 'General Education';
                                    studentExpertise.Outcome_Subject_Area_Expertise__c = 'Written and Oral Communication';


                                } else if (cloneAuditHistory.Earned_CE_Any_Category__c < auditHistory.Total_CE_Any_Category__c) {
                                    remainingCE = auditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;
                                    If (totalCE <= remainingCE) {
                                        cloneAuditHistory.Earned_CE_Any_Category__c += totalCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                    } else {
                                        cloneAuditHistory.Earned_CE_Any_Category__c += remainingCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;
                                    }
                                    studentExpertise.Outcome_Category__c = 'General Education';
                                    studentExpertise.Outcome_Subject_Area_Expertise__c = 'Any Category';


                                } else if (cloneAuditHistory.Earned_CE_General_Electives__c < auditHistory.Total_CE_General_Electives__c) {
                                    remainingCE = auditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;
                                    If (totalCE <= remainingCE) {
                                        cloneAuditHistory.Earned_CE_General_Electives__c += totalCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;

                                    } else {
                                        cloneAuditHistory.Earned_CE_General_Electives__c += remainingCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;
                                    }
                                    studentExpertise.Outcome_Category__c = 'General Elective';

                                } else {
                                    cloneAuditHistory.Earned_Back__c += totalCE;
                                    studentExpertise.Outcome_Category__c = 'Back';
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;

                                }

                            } else IF (studentExpertise.Subject_Area_Expertise__c == 'Mathematics/Natural Sciences') {

                                if (cloneAuditHistory.Earned_CE_Mathematics_Natural_Science__c < auditHistory.Total_CE_Mathematics_Natural_Science__c) {
                                    remainingCE = auditHistory.Total_CE_Mathematics_Natural_Science__c - cloneAuditHistory.Earned_CE_Mathematics_Natural_Science__c;
                                    If (totalCE <= remainingCE) {
                                        cloneAuditHistory.Earned_CE_Mathematics_Natural_Science__c += totalCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                    } else {
                                        cloneAuditHistory.Earned_CE_Mathematics_Natural_Science__c += remainingCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;
                                    }
                                    studentExpertise.Outcome_Category__c = 'General Education';
                                    studentExpertise.Outcome_Subject_Area_Expertise__c = 'Mathematics/Natural Sciences';
                                } else if (cloneAuditHistory.Earned_CE_Any_Category__c < auditHistory.Total_CE_Any_Category__c) {
                                    remainingCE = auditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;
                                    If (totalCE <= remainingCE) {
                                        cloneAuditHistory.Earned_CE_Any_Category__c += totalCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                    } else {
                                        cloneAuditHistory.Earned_CE_Any_Category__c += remainingCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;
                                    }
                                    studentExpertise.Outcome_Category__c = 'General Education';
                                    studentExpertise.Outcome_Subject_Area_Expertise__c = 'Any Category';

                                } else if (cloneAuditHistory.Earned_CE_General_Electives__c < auditHistory.Total_CE_General_Electives__c) {
                                    remainingCE = auditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;
                                    If (totalCE <= remainingCE) {
                                        cloneAuditHistory.Earned_CE_General_Electives__c += totalCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;

                                    } else {
                                        cloneAuditHistory.Earned_CE_General_Electives__c += remainingCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;
                                    }
                                    studentExpertise.Outcome_Category__c = 'General Elective';
                                } else {
                                    cloneAuditHistory.Earned_Back__c += totalCE;
                                    studentExpertise.Outcome_Category__c = 'Back';
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;

                                }
                            } else IF (studentExpertise.Subject_Area_Expertise__c == 'Social Sciences') {

                                if (cloneAuditHistory.Earned_CE_Social_Science__c < auditHistory.Total_CE_Social_Science__c) {
                                    remainingCE = auditHistory.Total_CE_Social_Science__c - cloneAuditHistory.Earned_CE_Social_Science__c;
                                    If (totalCE <= remainingCE) {
                                        cloneAuditHistory.Earned_CE_Social_Science__c += totalCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                    } else {
                                        cloneAuditHistory.Earned_CE_Social_Science__c += remainingCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;
                                    }
                                    studentExpertise.Outcome_Category__c = 'General Education';
                                    studentExpertise.Outcome_Subject_Area_Expertise__c = 'Social Sciences';
                                } else if (cloneAuditHistory.Earned_CE_Any_Category__c < auditHistory.Total_CE_Any_Category__c) {
                                    remainingCE = auditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;
                                    If (totalCE <= remainingCE) {
                                        cloneAuditHistory.Earned_CE_Any_Category__c += totalCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                    } else {
                                        cloneAuditHistory.Earned_CE_Any_Category__c += remainingCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;
                                    }
                                    studentExpertise.Outcome_Category__c = 'General Education';
                                    studentExpertise.Outcome_Subject_Area_Expertise__c = 'Any Category';

                                } else if (cloneAuditHistory.Earned_CE_General_Electives__c < auditHistory.Total_CE_General_Electives__c) {
                                    remainingCE = auditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;
                                    If (totalCE <= remainingCE) {
                                        cloneAuditHistory.Earned_CE_General_Electives__c += totalCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;

                                    } else {
                                        cloneAuditHistory.Earned_CE_General_Electives__c += remainingCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;
                                    }
                                    studentExpertise.Outcome_Category__c = 'General Elective';
                                } else {
                                    cloneAuditHistory.Earned_Back__c += totalCE;
                                    studentExpertise.Outcome_Category__c = 'Back';
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;

                                }
                            }
                            //Logic to handle Statistics SAE  - 39026
                             else IF (studentExpertise.Subject_Area_Expertise__c == 'Statistics') {

                                if (cloneAuditHistory.Earned_CE_Statistics__c < auditHistory.Total_CE_Statistics__c) {
                                    remainingCE = auditHistory.Total_CE_Statistics__c - cloneAuditHistory.Earned_CE_Statistics__c;
                                    If (totalCE <= remainingCE) {
                                        cloneAuditHistory.Earned_CE_Statistics__c += totalCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                    } else {
                                        cloneAuditHistory.Earned_CE_Statistics__c += remainingCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;
                                    }
                                    studentExpertise.Outcome_Category__c = 'General Education';
                                    studentExpertise.Outcome_Subject_Area_Expertise__c = 'Statistics';
                                } else if (cloneAuditHistory.Earned_CE_Any_Category__c < auditHistory.Total_CE_Any_Category__c) {
                                    remainingCE = auditHistory.Total_CE_Any_Category__c - cloneAuditHistory.Earned_CE_Any_Category__c;
                                    If (totalCE <= remainingCE) {
                                        cloneAuditHistory.Earned_CE_Any_Category__c += totalCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                    } else {
                                        cloneAuditHistory.Earned_CE_Any_Category__c += remainingCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;
                                    }
                                    studentExpertise.Outcome_Category__c = 'General Education';
                                    studentExpertise.Outcome_Subject_Area_Expertise__c = 'Any Category';

                                } else if (cloneAuditHistory.Earned_CE_General_Electives__c < auditHistory.Total_CE_General_Electives__c) {
                                    remainingCE = auditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;
                                    If (totalCE <= remainingCE) {
                                        cloneAuditHistory.Earned_CE_General_Electives__c += totalCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;

                                    } else {
                                        cloneAuditHistory.Earned_CE_General_Electives__c += remainingCE ;
                                        studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;
                                    }
                                    studentExpertise.Outcome_Category__c = 'General Elective';
                                } else {
                                    cloneAuditHistory.Earned_Back__c += totalCE;
                                    studentExpertise.Outcome_Category__c = 'Back';
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                 }
                            }
                             //ENd - 39026
                         } else if (auditCategory == 'General Elective') {
                            decimal remainingCE = 0;

                            if (cloneAuditHistory.Earned_CE_General_Electives__c < auditHistory.Total_CE_General_Electives__c) {
                                remainingCE = auditHistory.Total_CE_General_Electives__c - cloneAuditHistory.Earned_CE_General_Electives__c;
                                If (totalCE <= remainingCE) {
                                    cloneAuditHistory.Earned_CE_General_Electives__c += totalCE ;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                } else {
                                    cloneAuditHistory.Earned_CE_General_Electives__c += remainingCE ;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = remainingCE;
                                }
                                studentExpertise.Outcome_Category__c = 'General Elective';
                            } else {
                                cloneAuditHistory.Earned_Back__c += totalCE + 0;
                                studentExpertise.Outcome_Category__c = 'Back';
                                studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                            }
                        }

                        studentExpertise.Is_Audit_History_Created__c = True;
                        cloneAuditHistory.Student_Expertise__c = studentExpertise.Id;
                        studentExpertiseToUpdate.add(studentExpertise);
                        lstStudentAuditHistoryToProcess.add(cloneAuditHistory);
                        lstStudentAuditHistory.add(cloneAuditHistory);
                        system.debug('cloneAuditHistory ' + cloneAuditHistory);
                        system.debug('lstStudentAuditHistory ' + lstStudentAuditHistory);
                    }
                    //If no Student Audit record is found 
                    else {
                        system.debug('SE ELSE no SAR ' + studentExpertise);
                        Student_Audit_History__c newAuditHistory = new Student_Audit_History__c();
                        newAuditHistory.Student_Program__c = studentExpertise.Student_Program__c;
                        newAuditHistory.Earned_Back__c = 0;
                        newAuditHistory.Earned_CE_Concentration__c = 0;
                        newAuditHistory.Earned_CE_Core__c = 0;
                        newAuditHistory.Earned_CE_Core_Upper__c = 0;
                        newAuditHistory.Earned_CE_General_Electives__c = 0;
                        newAuditHistory.Earned_CE_Arts_and_Humanities__c = 0;
                        newAuditHistory.Earned_CE_Written_and_Oral_Communication__c = 0;
                        newAuditHistory.Earned_CE_Mathematics_Natural_Science__c = 0;
                        newAuditHistory.Earned_CE_Social_Science__c = 0;
                        newAuditHistory.Earned_CE_Statistics__c = 0;
                        newAuditHistory.Earned_CE_Any_Category__c = 0;


                        //Loop To assign Total CE  for new Student Audit History Record based on category from Program_Category_Requirement__c
                        for (Program_Category_Requirement__c degreeRequirement : mapProgram.get(studentExpertise.Student_Program__r.Program__c).Degree_Requirements__r) {
                            if (degreeRequirement.Category__c == 'Core' && degreeRequirement.Level__c == 'Upper') {
                                newAuditHistory.Total_CE_Core_Upper__c = degreeRequirement.Total_CE__c;
                            } else if (degreeRequirement.Category__c == 'Core' && degreeRequirement.Level__c == 'Lower') {
                                newAuditHistory.Total_CE_Core__c = degreeRequirement.Total_CE__c;
                            } else if (degreeRequirement.Category__c == 'Concentration') {
                                newAuditHistory.Total_CE_Concentration__c = degreeRequirement.Total_CE__c;
                            }

                            else if (degreeRequirement.Category__c == 'General Education' && degreeRequirement.Subject_Area_Expertise__c == null) {
                                newAuditHistory.Total_CE_General_Education__c = degreeRequirement.Total_CE__c;
                            } else if (degreeRequirement.Category__c == 'General Education' && degreeRequirement.Subject_Area_Expertise__c == 'Arts and Humanities') {
                                newAuditHistory.Total_CE_Arts_and_Humanities__c = degreeRequirement.Total_CE__c;
                            } else if (degreeRequirement.Category__c == 'General Education' && degreeRequirement.Subject_Area_Expertise__c == 'Written and Oral Communication') {
                                newAuditHistory.Total_CE_Written_and_Oral_Communication__c = degreeRequirement.Total_CE__c;
                            } else if (degreeRequirement.Category__c == 'General Education' && degreeRequirement.Subject_Area_Expertise__c == 'Mathematics/Natural Sciences') {
                                newAuditHistory.Total_CE_Mathematics_Natural_Science__c = degreeRequirement.Total_CE__c;
                            } else if (degreeRequirement.Category__c == 'General Education' && degreeRequirement.Subject_Area_Expertise__c == 'Social Sciences') {
                                newAuditHistory.Total_CE_Social_Science__c = degreeRequirement.Total_CE__c;
                             }
                            //START - 39026
                             else if (degreeRequirement.Category__c == 'General Education' && degreeRequirement.Subject_Area_Expertise__c == 'Statistics') {
                                newAuditHistory.Total_CE_Statistics__c = degreeRequirement.Total_CE__c;
                             }
                             //END - 39026
                            else if (degreeRequirement.Category__c == 'General Education' && degreeRequirement.Subject_Area_Expertise__c == 'Any Category') {
                                newAuditHistory.Total_CE_Any_Category__c = degreeRequirement.Total_CE__c;
                            } else if (degreeRequirement.Category__c == 'General Elective') {
                                newAuditHistory.Total_CE_General_Electives__c = degreeRequirement.Total_CE__c;
                            }
                        }

                        if (auditCategory == 'Core' && levelType == 'Upper') {
                            if (totalCE > newAuditHistory.Total_CE_Core_Upper__c) {
                                newAuditHistory.Earned_CE_Core_Upper__c = newAuditHistory.Total_CE_Core_Upper__c ;
                                studentExpertise.Total_Applied_Earned_CE_Outcome__c = newAuditHistory.Total_CE_Core_Upper__c;
                            } else {
                                newAuditHistory.Earned_CE_Core_Upper__c = totalCE;
                                studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                            }
                            studentExpertise.Outcome_Category__c = 'Core Upper';
                        }//Core Upper 
                        else if (auditCategory == 'Core' && levelType == 'Lower') {
                            if (totalCE > newAuditHistory.Total_CE_Core__c) {
                                newAuditHistory.Earned_CE_Core__c = newAuditHistory.Total_CE_Core__c ;
                                studentExpertise.Total_Applied_Earned_CE_Outcome__c = newAuditHistory.Total_CE_Core__c;
                            } else {
                                newAuditHistory.Earned_CE_Core__c = totalCE;
                                studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                            }
                            studentExpertise.Outcome_Category__c = 'Core Lower';
                        }//Core Lower
                        else if (auditCategory == 'Concentration') {
                            if (totalCE > newAuditHistory.Total_CE_Concentration__c) {
                                newAuditHistory.Earned_CE_Concentration__c = newAuditHistory.Total_CE_Concentration__c ;
                                studentExpertise.Total_Applied_Earned_CE_Outcome__c = newAuditHistory.Total_CE_Concentration__c;
                            } else {
                                newAuditHistory.Earned_CE_Concentration__c = totalCE;
                                studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                            }
                            studentExpertise.Outcome_Category__c = 'Concentration';
                        }//Concentration 
                        else if (auditCategory == 'General Education' || (auditCategory.contains('General Elective') && auditCategory.contains('General Education'))) {
                            If (studentExpertise.Subject_Area_Expertise__c == 'Arts and Humanities') {
                                if (totalCE > newAuditHistory.Total_CE_Arts_and_Humanities__c) {
                                    newAuditHistory.Earned_CE_Arts_and_Humanities__c = newAuditHistory.Total_CE_Arts_and_Humanities__c ;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = newAuditHistory.Total_CE_Arts_and_Humanities__c;
                                    studentExpertise.Outcome_Subject_Area_Expertise__c = 'Arts and Humanities';
                                } else {
                                    newAuditHistory.Earned_CE_Arts_and_Humanities__c = totalCE;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                    studentExpertise.Outcome_Subject_Area_Expertise__c = 'Arts and Humanities';
                                }
                            } else If (studentExpertise.Subject_Area_Expertise__c == 'Mathematics/Natural Sciences') {

                                if (totalCE > newAuditHistory.Total_CE_Mathematics_Natural_Science__c) {
                                    newAuditHistory.Earned_CE_Mathematics_Natural_Science__c = newAuditHistory.Total_CE_Mathematics_Natural_Science__c ;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = newAuditHistory.Total_CE_Mathematics_Natural_Science__c;
                                    studentExpertise.Outcome_Subject_Area_Expertise__c = 'Mathematics/Natural Sciences';
                                } else {
                                    newAuditHistory.Earned_CE_Mathematics_Natural_Science__c = totalCE;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                    studentExpertise.Outcome_Subject_Area_Expertise__c = 'Mathematics/Natural Sciences';

                                }
                            } else If (studentExpertise.Subject_Area_Expertise__c == 'Social Sciences') {
                                if (totalCE > newAuditHistory.Total_CE_Social_Science__c) {
                                    newAuditHistory.Earned_CE_Social_Science__c = newAuditHistory.Total_CE_Social_Science__c ;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = newAuditHistory.Total_CE_Social_Science__c;
                                    studentExpertise.Outcome_Subject_Area_Expertise__c = 'Social Sciences';

                                } else {
                                    newAuditHistory.Earned_CE_Social_Science__c = totalCE;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                    studentExpertise.Outcome_Subject_Area_Expertise__c = 'Social Sciences';

                                }
                            } else If (studentExpertise.Subject_Area_Expertise__c == 'Written and Oral Communication') {
                                if (totalCE > newAuditHistory.Total_CE_Written_and_Oral_Communication__c) {
                                    newAuditHistory.Earned_CE_Written_and_Oral_Communication__c = newAuditHistory.Total_CE_Written_and_Oral_Communication__c ;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = newAuditHistory.Total_CE_Written_and_Oral_Communication__c;
                                    studentExpertise.Outcome_Subject_Area_Expertise__c = 'Written and Oral Communication';

                                } else {
                                    newAuditHistory.Earned_CE_Written_and_Oral_Communication__c = totalCE;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                    studentExpertise.Outcome_Subject_Area_Expertise__c = 'Written and Oral Communication';

                                }
                            }
                            //START - 39026
                            else If (studentExpertise.Subject_Area_Expertise__c == 'Statistics') {
                                if (totalCE > newAuditHistory.Total_CE_Statistics__c) {
                                    newAuditHistory.Earned_CE_Statistics__c = newAuditHistory.Total_CE_Statistics__c ;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = newAuditHistory.Total_CE_Statistics__c;
                                    studentExpertise.Outcome_Subject_Area_Expertise__c = 'Statistics';
                                } else {
                                    newAuditHistory.Earned_CE_Statistics__c = totalCE;
                                    studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                                    studentExpertise.Outcome_Subject_Area_Expertise__c = 'Statistics';
                                }
                            }
                            //End - 39026
                            studentExpertise.Outcome_Category__c = 'General Education';
                        }//General Education
                        else if (auditCategory == 'General Elective') {
                            if (totalCE > newAuditHistory.Total_CE_General_Electives__c) {
                                newAuditHistory.Earned_CE_General_Electives__c = newAuditHistory.Total_CE_General_Electives__c ;
                                studentExpertise.Total_Applied_Earned_CE_Outcome__c = newAuditHistory.Total_CE_General_Electives__c;
                            } else {
                                newAuditHistory.Earned_CE_General_Electives__c = totalCE;
                                studentExpertise.Total_Applied_Earned_CE_Outcome__c = totalCE;
                            }
                            studentExpertise.Outcome_Category__c = 'General Elective';
                        }//General Elective
                        studentExpertise.Is_Audit_History_Created__c = True;
                        newAuditHistory.Student_Expertise__c = studentExpertise.Id;
                        lstStudentAuditHistory.add(newAuditHistory);
                        lstStudentAuditHistoryToProcess.add(newAuditHistory);
                        studentExpertiseToUpdate.add(studentExpertise);

                    }
                }
            }

        }
        If (!studentExpertiseToUpdate.isEmpty()) {
            update studentExpertiseToUpdate;
        }
        If (!lstStudentAuditHistory.isEmpty()) {
            insert lstStudentAuditHistory;
        }
    }

    global void finish(Database.BatchableContext BC) {
    }
}