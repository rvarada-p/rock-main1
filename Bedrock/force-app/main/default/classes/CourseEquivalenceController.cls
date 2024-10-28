/*******************************************************************
Name  : CourseEquivalenceController
Author: Horacio 
Date  : October 31, 2018
Description: Class to Handle TOC Tool

Revision History 
* Horacio Sanchez -  11/17/2020 -   S-31136 - Able to Delete Preliminary Transfer from TOC tool
* Horacio Sanchez    12/03/2020     Prod Defect 36329: Tempo: TOC Summary Page not refreshing
* Horacio Sanchez	 12/15/2020     User Story 36449: Tempo: TOC refactor
* Horacio Sanchez    01/25/2021     User Story 40038: L2: TOC tool and guest user access update
* Horacio Sanchez    01/27/2021     User Story 38826: Tempo: Add Preliminary Transfer Credits on Grad and UG degree audit
* Ravitej Varada     08/16/2021     User Story 63276: L2: Update GPA logic
*************************************************************************/
public without sharing class CourseEquivalenceController {
    public String selectedCreditType {get;set;}
    public String selectedConferredDegree {get;set;} 
    public String transferInstitution {get;set;}
    public String error {get;set;}
    public String selectedPseudoCourseId {get;set;}
    public String selectedMultipleTranscripts {get;set;}
    public String duplicateSeCourseName {get;set;}
    
    public Boolean displayInstitutionInput {get;set;}
    public Boolean isFlipToOfficialTransfer {get;set;}
    public Boolean isPseudoCourse {get;set;}
    public Boolean isUndoBtnDisplayed {get;set;}
    public Boolean isSeconUndoBtnDisplayed {get;set;}
    public Boolean displayConferredDegreePicklist {get;set;}
    public Boolean displayGradePicklist {get;set;}
    public Boolean isGradeSaved {get;set;}
    public Boolean showtransInstBool {get;set;}
    public Boolean isFulfilledCourseNameDisplayed {get;set;}
    public Boolean isSECheckboxDisplayed {get;set;}
    public Boolean isFromMultipleInstitutions {get;set;}
    public Boolean displayMultipleTranscriptsSelect {get;set;}
    public Boolean testFlag {get;set;}
    public Boolean deleteFlag {get;set;}
    
    public String studentProgramId {get;set;}
    public List<Student_Competency__c> priorCompetencyList;
    public List<Student_Expertise__c> priorStudentExpertiseList;
    public List<StudentExpertiseDetails> studentExpertiseDetailsList {get;set;}
    public List<StudentCompetencyDetails> studentCompetencyDetailsList {get;set;}
    public List<StudentExpertiseDetails> selectedSEDList {get;set;}
    
    public List<Student_Expertise__c> updateStudentExpertiseList;
    public List<Id> selectedStudentExpertise;
    public Map<Id, String> studentExpertiseIdTransferringInstitution;
    public Map<Id, Double> studentExpertiseIdTotalCEMap;
    private Map<String, List<Competency__c>> genEdCodeCompetencyMap;
    private String programCode;
    Set<String> aoeCourseCodeSet;
    private Set<String> aoeCourseCodesToRetrieve;
    
    private Set<Id> setCBLRecordTypesSE;
    private Set<Id> setCBLRecordTypesSC;    
    
    public list<student_competency__c> newCompsLst;
    
    // TOC Summary instance variable section
    public TOCSummaryModel tocSummary {get; set;}
    
    private List<Student_Competency__c> studentCompetencyList;
    public String newId {get;set;}
    public CourseEquivalenceController cc {get;set;}
    
    public CourseEquivalenceController() {
        String pageName = ApexPages.currentPage().getUrl().substringBetween('apex/', '?');
        if (pageName.contains('TOCCurrentState')) {
        	studentProgramId = ApexPages.currentPage().getParameters().get('id');
        } else {
            Id  opportunityId = ApexPages.currentPage().getParameters().get('id');
            
            List<Opportunity> opps = [SELECT Student_Program__r.id, primary_program__r.productCode
                                      FROM Opportunity 
                                      WHERE Id = :opportunityId
                                      LIMIT 1];
            if (opps != null && opps.size() > 0) {
                studentProgramId = opps[0].Student_Program__r.id;
            }
        }
        tocSummary = new TOCSummaryModel();
        getTOCSummary();
    }
    
    public CourseEquivalenceController(ApexPages.StandardController controller) {
        try {
            String pageName = ApexPages.currentPage().getUrl().substringBetween('apex/', '?');
            if (pageName.contains('TOCCurrentState')) {
                cc = new CourseEquivalenceController();
            } else {
                Id  opportunityId = ApexPages.currentPage().getParameters().get('id');
            	
                List<Opportunity> opps = [SELECT Student_Program__r.id, primary_program__r.productCode
                                          FROM Opportunity 
                                          WHERE Id = :opportunityId
                                          LIMIT 1];
                if (opps != null && opps.size() > 0) {
                    studentProgramId = opps[0].Student_Program__r.id;
                }
                programCode = opps[0].primary_program__r.productCode;
                
                displayInstitutionInput = false;
                displayConferredDegreePicklist = false;
                isUndoBtnDisplayed = false;
                displayGradePicklist = false;
                isGradeSaved = false;
                showtransInstBool = true;
                isSeconUndoBtnDisplayed = false;
                isFulfilledCourseNameDisplayed = false;
                isSECheckboxDisplayed = true;
                isFlipToOfficialTransfer = false;
                isFromMultipleInstitutions = false;
                displayMultipleTranscriptsSelect = false;
                studentExpertiseIdTransferringInstitution = new Map<Id, String>();
                studentExpertiseIdTotalCEMap = new Map<Id, Double>();
                genEdCodeCompetencyMap = new Map<String, List<Competency__c>>();
                aoeCourseCodeSet = new Set<String>();
                aoeCourseCodesToRetrieve = new Set<String>();
                testFlag = false;
            }
            
            
            // TOC Summary Init section
            
        }
        catch(Exception exp) {
            System.debug('Exception: ' + exp);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,exp.getMessage()));
        }
        
    }
    
    //Create the dropdown list
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('NONE','None'));
        options.add(new SelectOption('Fulfilled','Fulfilled'));
        options.add(new SelectOption('Transferred','Transfer'));
        options.add(new SelectOption('Preliminary Transfer','Preliminary Transfer'));
        options.add(new SelectOption('FLIP TO OFFICIAL TRANSFER','Flip to Official Transfer'));
        
        return options;
    }
    
    public List<SelectOption> getConferredDegreeItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('No','No'));
        options.add(new SelectOption('Yes','Yes'));
        return options;   
    }
    
    public List<SelectOption> getGradeValues() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','Select'));
        options.add(new SelectOption('A','A'));
        options.add(new SelectOption('B','B'));
        options.add(new SelectOption('C','C'));
        options.add(new SelectOption('D','D'));
        options.add(new SelectOption('S','S'));
        return options;   
    }
    
    //Set flags after credit type selected
    public PageReference setCreditTypeFlag() {
        try {
            setInitialValues();
            if (selectedCreditType == 'FLIP TO OFFICIAL TRANSFER') {
                displayInstitutionInput = false;
                isFlipToOfficialTransfer = true;
                isFromMultipleInstitutions = false;
                displayConferredDegreePicklist = false;
                displayMultipleTranscriptsSelect = false;
                testFlag = false;
            } else if (selectedCreditType == 'NONE') {
                displayInstitutionInput = false;
                isFlipToOfficialTransfer = false;
                isFromMultipleInstitutions = false;
                displayConferredDegreePicklist = false;
                displayMultipleTranscriptsSelect = false;
                testFlag = false;
            } else if (selectedCreditType == 'Transferred' || selectedCreditType == 'Preliminary Transfer') {
                displayConferredDegreePicklist = false;
                displayMultipleTranscriptsSelect = true;
                if (selectedMultipleTranscripts == 'Yes') {
                    displayInstitutionInput = false;
                    isFlipToOfficialTransfer = false;
                    isFromMultipleInstitutions = true;
                } else {
                    displayInstitutionInput = true;
                    isFlipToOfficialTransfer = false;
                    isFromMultipleInstitutions = true;
                }
            } else if (selectedCreditType == 'Fulfilled') {
                displayInstitutionInput = false;
                isFlipToOfficialTransfer = false;
                displayConferredDegreePicklist = true;
                isFromMultipleInstitutions = false;
                displayMultipleTranscriptsSelect = false;
                testFlag = false;
            } else {
                displayInstitutionInput = false;
                isFlipToOfficialTransfer = false;
                isFromMultipleInstitutions = false;
                displayConferredDegreePicklist = false;
                displayMultipleTranscriptsSelect = false;
                testFlag = false;
            }
        } catch(Exception exp) {
            system.debug(exp);
        }
        
        return null;
    }
    
    public void setInitialValues() {
        displayInstitutionInput = false;
        displayConferredDegreePicklist = false;
        isUndoBtnDisplayed = false;
        isSeconUndoBtnDisplayed = false;
        displayGradePicklist = false;
        isGradeSaved = false;
        showtransInstBool = true;
        isPseudoCourse = false;
        isFulfilledCourseNameDisplayed = false;
        isSECheckboxDisplayed = true;
        isFlipToOfficialTransfer = false;
        isFromMultipleInstitutions = false;
        displayMultipleTranscriptsSelect = false;
        testFlag = false;
        
        priorCompetencyList = new List<Student_Competency__c>();
        priorStudentExpertiseList = new List<Student_Expertise__c>();
        studentExpertiseDetailsList = new List<StudentExpertiseDetails>();
        studentCompetencyDetailsList = new List<StudentCompetencyDetails>();
        studentExpertiseIdTransferringInstitution = new Map<Id, String>();
        studentExpertiseIdTotalCEMap = new Map<Id, Double>();
        genEdCodeCompetencyMap = new Map<String, List<Competency__c>>();
        aoeCourseCodeSet = new Set<String>();
        aoeCourseCodesToRetrieve = new Set<String>();
    }
    
    public void getProgramCourses() {
        try {
            Map<Id, List<Student_Competency__c>> studentExpertiseIdStudentCompetencyListMap = new Map<Id, List<Student_Competency__c>>();
            
            if (selectedConferredDegree == 'No' && selectedCreditType == 'Fulfilled') {
                displayGradePicklist = true;
            }
            
            studentExpertiseDetailsList = new List<StudentExpertiseDetails>();
            
            priorStudentExpertiseList = new List<Student_Expertise__c>();
            priorStudentExpertiseList = [SELECT Id,Audit_Category__c, area_of_expertise_name__c, area_of_expertise__r.course_code__c, total_ce__c, grade_value__c, grade__c, pseudo_course__c, pseudo_ce__c, Fulfilled_Course_from_a_Conferred_Degree__c, Fulfilled_Course_Name__c, non_transferrable__c
                                         FROM Student_Expertise__c
                                         WHERE Student_program__c = :studentProgramId
                                         ORDER BY area_of_expertise__r.course_code__c ASC];
            
            List<Id> pseudoSeIdList = new List<Id>();
            for (Student_Expertise__c se : priorStudentExpertiseList) {
                if (se.pseudo_course__c) {
                    pseudoSeIdList.add(se.Id);
                }
            }
            
            Map<Id, String> seIdCreditType = new Map<Id, String>();
            Map<Id, String> seIdTransfrInstMap = new Map<Id, String>();
            Map<String, String> seCourseCoudeCreditType = new Map<String, String>();
            for (Student_Competency__c sc : [SELECT Id, Student_Expertise__r.id, status__c, student_expertise__r.area_of_expertise__r.course_code__c,
                                             Transferring_Institution__c, Pseudo_CE__c
                                             FROM Student_Competency__c
                                             WHERE Student_Program__c  = : studentProgramId]) { //WHERE Student_Expertise__r.id IN :pseudoSeIdList AND Student_Program__c  = : studentProgramId]) {
                                                 seIdCreditType.put(sc.student_expertise__r.Id, sc.status__c);
                                                 if (!studentExpertiseIdStudentCompetencyListMap.containsKey(sc.student_expertise__r.Id)) {
                                                     studentExpertiseIdStudentCompetencyListMap.put(sc.student_expertise__r.Id, new List<Student_Competency__c>{sc});
                                                 } else {
                                                     studentExpertiseIdStudentCompetencyListMap.get(sc.student_expertise__r.Id).add(sc);
                                                 }
                                                 if(sc.Transferring_Institution__c != null)
                                                     seIdTransfrInstMap.put(sc.student_expertise__r.Id, sc.Transferring_Institution__c);
                                                 seCourseCoudeCreditType.put(sc.student_expertise__r.area_of_expertise__r.course_code__c, sc.status__c);
                                             }
            
            Set<String> seCourseCode = new Set<String>();
            aoeCourseCodeSet = new Set<String>();
            for (Student_Expertise__c se : priorStudentExpertiseList) {
                StudentExpertiseDetails sed = new StudentExpertiseDetails();
                sed.seId = se.id;
                sed.creditType = seIdCreditType.get(se.id);
                sed.isConferredDegree = se.Fulfilled_Course_from_a_Conferred_Degree__c;
                sed.grade = se.Grade__c;
                sed.aoeCourseCode = se.area_of_expertise__r.course_code__c;
                sed.fulfilledCourseName = se.Fulfilled_Course_Name__c;
                sed.areaOfExpertiseName = se.area_of_expertise_name__c;
                //sed.totalCE = se.total_ce__c;
                sed.isPseudoCourse = se.Pseudo_Course__c;
                if (se.Pseudo_Course__c && studentExpertiseIdStudentCompetencyListMap.get(sed.seId)[0].Pseudo_CE__c != null) {
                    sed.totalCE = studentExpertiseIdStudentCompetencyListMap.get(sed.seId)[0].Pseudo_CE__c;
                } else {
                    sed.totalCE = se.total_ce__c;
                }
                sed.transferringInstitution = seIdTransfrInstMap.get(se.id);
                aoeCourseCodeSet.add(se.area_of_expertise__r.course_code__c);
                
                if (!(se.non_transferrable__c && (selectedCreditType == 'Transferred' || selectedCreditType == 'Preliminary Transfer'))) {
                    if (studentExpertiseIdStudentCompetencyListMap.get(se.Id) != null) {
                        boolean addSeToList = true;
                        for (Student_Competency__c tempSc : studentExpertiseIdStudentCompetencyListMap.get(se.Id)) {
                            if (tempSc.Status__c == 'Achieved' || tempSc.Status__c == 'Mastered' || tempSc.Status__c == 'Assessment Submitted' || tempSc.Status__c == 'Not Achieved' || tempSc.Status__c == 'Returned for Resubmission') {
                                addSeToList = false;
                                break;
                            }
                        }
                        if (addSeToList) {
                            studentExpertiseDetailsList.add(sed);
                        }
                    }
                }
                
                if (se.pseudo_course__c) {
                    if (!seCourseCode.contains(se.area_of_expertise__r.course_code__c)) {
                        seCourseCode.add(se.area_of_expertise__r.course_code__c);
                        Boolean isSeAdded = true;
                        for (String key : seCourseCoudeCreditType.keySet()) {
                            if (key == se.area_of_expertise__r.course_code__c) {
                                if (seCourseCoudeCreditType.get(key) == selectedCreditType || seCourseCoudeCreditType.get(key) == 'Registered') {
                                    isSeAdded = false;
                                }
                            }                                
                        }
                        
                        if (isSeAdded) {
                            sed = new StudentExpertiseDetails();
                            sed.aoeCourseCode = se.area_of_expertise__r.course_code__c;
                            //sed.totalCE = se.total_ce__c;
                            sed.isPseudoCourse = se.Pseudo_Course__c;
                            if (se.Pseudo_Course__c) {
                                sed.totalCE = se.Pseudo_CE__c;
                            } else {
                                sed.totalCE = se.total_ce__c;
                            }
                            sed.creditType = selectedCreditType;
                            if (!(se.non_transferrable__c && (selectedCreditType == 'Transferred' || selectedCreditType == 'Preliminary Transfer'))) {
                                boolean addSeToList = true;
                                for (Student_Competency__c tempSc : studentExpertiseIdStudentCompetencyListMap.get(se.Id)) {
                                    if (tempSc.Status__c == 'Achieved' || tempSc.Status__c == 'Mastered' || tempSc.Status__c == 'Assessment Submitted' || tempSc.Status__c == 'Not Achieved' || tempSc.Status__c == 'Returned for Resubmission') {
                                        addSeToList = false;
                                        break;
                                    }
                                }
                                if (addSeToList) {
                                    studentExpertiseDetailsList.add(sed);
                                }    
                            }
                        }
                    }
                }
            }
            
            // Handling GenEd courses
            Student_Program__c sp = [SELECT Id, program__r.degree_Level__c, Application__c, Student__c FROM Student_Program__c WHERE Id = :studentProgramId LIMIT 1];
            //if (sp.Program__r.Degree_Level__c == 'Undergrad') {
                aoeCourseCodesToRetrieve = getGenEdCoursesByProgramCode(programCode);
                
                List<Competency_Expertise__c> competencyExpertiseList = [SELECT area_of_expertise__r.id, 
                                                                         		area_of_expertise__r.Display_Name__c, 
                                                                         		area_of_expertise__r.course_name__c, 
                                                                         		area_of_expertise__r.course_code__c, 
                                                                         		area_of_expertise__r.pseudo_course__c, 
                                                                         		area_of_expertise__r.total_ce__c, 
                                                                         		competency__r.id, 
                                                                         		competency__r.display_name__c 
                                                                         FROM Competency_Expertise__c 
                                                                         WHERE Area_of_Expertise__r.Course_Code__c IN :aoeCourseCodesToRetrieve
                                                                         ORDER BY area_of_expertise__r.course_code__c];
                List<Area_Of_Expertise__c> areaOfExpertiseList = [SELECT id, 
                                                                  		 Course_Code__c, 
                                                                  		 course_name__c, 
                                                                  		 total_ce__c, 
                                                                  		 pseudo_course__c, 
                                                                         Display_Name__c, 
                                                                         Category__c 
                                                                  FROM Area_of_Expertise__c 
                                                                  WHERE Course_Code__c IN :aoeCourseCodesToRetrieve
                                                                  AND Course_Code__c NOT IN :aoeCourseCodeSet 
                                                                  ORDER BY Course_code__c];
                
                for (Competency_Expertise__c competencyExpertise : competencyExpertiseList) {
                    Competency__c competency = new Competency__c();
                    competency.id =competencyExpertise.competency__r.id;
                    if (!genEdCodeCompetencyMap.containsKey(competencyExpertise.area_of_expertise__r.course_code__c)) {                        
                        genEdCodeCompetencyMap.put(competencyExpertise.area_of_expertise__r.course_code__c, new List<Competency__c>{competency});
                    } else {
                        genEdCodeCompetencyMap.get(competencyExpertise.area_of_expertise__r.course_code__c).add(competency);
                    }
                }
                
                for (Area_Of_Expertise__c aoe : areaOfExpertiseList) {
                    StudentExpertiseDetails sed = new StudentExpertiseDetails();
                    sed.creditType = selectedCreditType;
                    sed.aoeCourseCode = aoe.course_code__c;
                    sed.areaOfExpertiseName = aoe.course_name__c;
                    sed.totalCE = aoe.total_ce__c;
                    sed.isPseudoCourse = aoe.Pseudo_Course__c;
                    sed.isGenEd = true;
                    sed.areaOfExpertiseId = aoe.id;
                    sed.opportunityId = sp.Application__c;
                    sed.contactId = sp.Student__c;
                    studentExpertiseDetailsList.add(sed);
                }
            //}
            
        } catch(Exception exp) {
            System.debug(exp);
        }
    }
    
    private PageReference setConfirmationPage() {
        testFlag = true;
        selectedSEDList = new List<StudentExpertiseDetails>();
        for (StudentExpertiseDetails sed : studentExpertiseDetailsList) {
            if (sed.isSelected == true) {
                if (selectedMultipleTranscripts == 'No' && (selectedCreditType == 'Transferred' || selectedCreditType == 'Preliminary Transfer')){
                    sed.transferringInstitution = transferInstitution;
                }
                selectedSEDList.add(sed);
            }            
        }
        return Page.CourseEquivalenceConfirmation;
    }
        
    public PageReference confirmationPage() {
        deleteFlag = false;
        
        return setConfirmationPage();
    }
    
    public PageReference confirmationDeletePage() {
        deleteFlag = true;
        return setConfirmationPage();
    }
    
    public void deleteOrRestoreEntries() {
        Set<Id> nonPseudoSEIdSet = new Set<Id>();
        Set<Id> seIdsToDeleteSet = new Set<Id>();
        Map<String, List<StudentExpertiseDetails>> aoeCOurseCodeSEDListMap = new Map<String, List<StudentExpertiseDetails>>();
        Map<String, Integer> aoeCourseCodeQuantitySED = new Map<String, Integer>();
        List<Student_Competency__c> updateRestoreStudentCompetencyList = new List<Student_Competency__c>();
        List<Student_Expertise__c> updateRestoreStudentExpertiseList = new List<Student_Expertise__c>();
        List<Student_Competency__c> deleteStudentCompetencyList = new List<Student_Competency__c>();
        
        Set<Id> achievedSEIdSet = new Set<Id>();
        Map<Id, StudentExpertiseDetails> idSelectedStudentExpertiseMap = new Map<Id, StudentExpertiseDetails>();
        for (StudentExpertiseDetails sed : selectedSEDList) {
            if (sed.seId != null) {
            	achievedSEIdSet.add(sed.seId);
                if (!idSelectedStudentExpertiseMap.containsKey(sed.seId)) {
                    idSelectedStudentExpertiseMap.put(sed.seId, sed);
                }
            }
        }
        
        List<StudentExpertiseDetails> filteredSelectedSEDList = new List<StudentExpertiseDetails>();
        
        // S-31136 Added delete logic for Preliminary Transfer
        if (selectedCreditType == 'Preliminary Transfer') {
            List<Student_Competency__c> tempSCList = [SELECT Id, Student_Expertise__c FROM Student_Competency__c WHERE Student_Expertise__c IN :achievedSEIdSet];
            Set<Id> tempSEIdSet = new Set<Id>();
            for (Student_Competency__c sc : tempSCList) {
                tempSEIdSet.add(sc.Student_Expertise__c);
            }
            for (Id seId : tempSEIdSet) {
                filteredSelectedSEDList.add(idSelectedStudentExpertiseMap.get(seId));
            }
        } else {
            for (Student_Expertise__c sed : [SELECT Id, isAchieved__c FROM Student_Expertise__c WHERE Id IN :achievedSEIdSet]) {
                if (sed.isAchieved__c) {
                    filteredSelectedSEDList.add(idSelectedStudentExpertiseMap.get(sed.id));
                }
            }
        }
        
        // Removing Student Expertise without ID from the Selected List
        /*List<StudentExpertiseDetails> filteredSelectedSEDList = new List<StudentExpertiseDetails>();
        for (StudentExpertiseDetails sed : selectedSEDList) {
            if (sed.seId != null) {
            	filteredSelectedSEDList.add(sed);
            }                
        }*/
        
        for (StudentExpertiseDetails sed : filteredSelectedSEDList) {
            if (!sed.isPseudoCourse) {
                nonPseudoSEIdSet.add(sed.seId);
                Student_Expertise__c se = new Student_Expertise__c();
                se.Id = sed.seId;
                se.Fulfilled_Course_from_a_Conferred_Degree__c = false;
                se.Fulfilled_Course_Name__c = '';
                updateRestoreStudentExpertiseList.add(se);
            } else {
                if (!aoeCOurseCodeSEDListMap.containsKey(sed.aoeCourseCode)) {
                    aoeCOurseCodeSEDListMap.put(sed.aoeCourseCode, new List<StudentExpertiseDetails>{sed});
                } else {
                    aoeCOurseCodeSEDListMap.get(sed.aoeCourseCode).add(sed);
                }
            }
            
            // Get the Id from GenEd courses
            for (String aoeCourseCode : aoeCourseCodesToRetrieve) {
                if (sed.aoeCourseCode == aoeCourseCode) {
                    seIdsToDeleteSet.add(sed.seId);
                }
            }
        }
        
        for (StudentExpertiseDetails sed : studentExpertiseDetailsList) {
            if (!aoeCourseCodeQuantitySED.containsKey(sed.aoeCourseCode)) {
                aoeCourseCodeQuantitySED.put(sed.aoeCourseCode, 1);
            } else {
                aoeCourseCodeQuantitySED.put(sed.aoeCourseCode, aoeCourseCodeQuantitySED.get(sed.aoeCourseCode) + 1);
            }
        }
        
        for (String key : aoeCOurseCodeSEDListMap.keySet()) {
            List<StudentExpertiseDetails> tempList = aoeCOurseCodeSEDListMap.get(key);
            if (aoeCourseCodeQuantitySED.get(key) == 1) {
                for (StudentExpertiseDetails sed : tempList) {
                    if (sed.seId != null) {
                        nonPseudoSEIdSet.add(sed.seId);
                        Student_Expertise__c se = new Student_Expertise__c();
                        se.Id = sed.seId;
                        se.Fulfilled_Course_from_a_Conferred_Degree__c = false;
                        se.Fulfilled_Course_Name__c = '';
                        updateRestoreStudentExpertiseList.add(se);
                    }                    
                }
            } else if (aoeCourseCodeQuantitySED.get(key) > 1) {
                if (aoeCourseCodeQuantitySED.get(key) == tempList.size()) {
                    for (Integer i = 0; i < tempList.size(); i++) {
                        if (i == 0) {
                            nonPseudoSEIdSet.add(tempList[0].seId);
                            Student_Expertise__c se = new Student_Expertise__c();
                            se.Id = tempList[0].seId;
                            se.Fulfilled_Course_from_a_Conferred_Degree__c = false;
                            se.Fulfilled_Course_Name__c = '';
                            updateRestoreStudentExpertiseList.add(se);
                            continue;
                        }
                        seIdsToDeleteSet.add(tempList[i].seId);
                    }
                } else if (tempList.size() < aoeCourseCodeQuantitySED.get(key)) {
                    for (StudentExpertiseDetails sed : tempList) {
                        nonPseudoSEIdSet.add(sed.seId);
                        seIdsToDeleteSet.add(sed.seId);
                    }
                }
            }           
            
        }
        
        List<Student_Expertise__c> seList = new List<Student_Expertise__c>();
        Map<Id, List<Student_Competency__c>> seIdSCListMap = new Map<Id, List<Student_Competency__c>>();
        for (Student_Competency__c studentCompetency : [SELECT Id, Status__c, IsCompleted__c, Transferring_Institution__c, Student_Expertise__r.id, Pseudo_CE__c FROM Student_Competency__c WHERE Student_Expertise__r.id IN :nonPseudoSEIdSet OR Student_Expertise__r.id IN :seIdsToDeleteSet]) {
        	Student_Competency__c sc = new Student_Competency__c();
            sc.Id = studentCompetency.Id;
            sc.Status__c = 'Registered';
            sc.IsCompleted__c = false;
            sc.Transferring_Institution__c = '';
            if (selectedCreditType == 'Preliminary Transfer' || selectedCreditType == 'Transferred') {
            	sc.Pseudo_CE__c = null;
            }
            if (!seIdSCListMap.containsKey(studentCompetency.Student_Expertise__r.id)) {
                seIdSCListMap.put(studentCompetency.Student_Expertise__r.id, new List<Student_Competency__c>{sc});
            } else {
                seIdSCListMap.get(studentCompetency.Student_Expertise__r.id).add(sc);
            }
            updateRestoreStudentCompetencyList.add(sc);
        }
        
        // This for is to update SEs one by one
        /*System.debug('*****:KEY SET: ' + seIdSCListMap.keySet().size());*/
        for (String key : seIdSCListMap.keySet()) {
           // System.debug('*****UPDATING SCs from SE ID: ' + key);
            /*for (Student_Competency__c sc : seIdSCListMap.get(key)) {
                System.debug('+++++SC ID: ' + sc.id);
            }*/
            //update seIdSCListMap.get(key);
            Student_Expertise__c se = new Student_Expertise__c();
            se.id = key;
            se.IsAchieved__c = false;
            se.Fulfilled_Course_from_a_Conferred_Degree__c = false;
            se.Fulfilled_Course_Name__c = '';
            update se;
        }
        
        if (!updateRestoreStudentCompetencyList.isEmpty()) {
            update updateRestoreStudentCompetencyList;
        }
        
        /*if (!updateRestoreStudentExpertiseList.isEmpty()) {
            update updateRestoreStudentExpertiseList;
        }*/
        
        if (!seIdsToDeleteSet.isEmpty()) {
            for (Student_Competency__c studentCompetency : [SELECT id FROM Student_Competency__c WHERE Student_Expertise__r.id IN :seIdsToDeleteSet]) {
                Student_Competency__c sc = new Student_Competency__c();
                sc.Id = studentCompetency.Id;
                deleteStudentCompetencyList.add(sc);
            }
            
            if (!deleteStudentCompetencyList.isEmpty()) {
                delete deleteStudentCompetencyList;
            }            
            
            List<Student_Expertise__c> studentExpertiseToDeleteList = new List<Student_Expertise__c>();
            for (Id studentExpertiseId : seIdsToDeleteSet) {
                Student_Expertise__c se = new Student_Expertise__c();
                se.id = studentExpertiseId;
                studentExpertiseToDeleteList.add(se);
            }
            try {
                delete studentExpertiseToDeleteList;
            } catch(Exception e) {
                System.debug('Exception: ' + e.getMessage());
            }
            
        }
    }
    
    public PageReference page1() {
        return Page.CourseEquivalence;
    }
    
    public void updateRecords() {
        try {
            isUndoBtnDisplayed = true;
            isGradeSaved = true;
            showtransInstBool = false;
            isSECheckboxDisplayed = false;
            
            setCBLRecordTypesSE = Utility.getRecordTypeFromCBLCustomSetting(Student_Expertise__c.sObjectType.getDescribe());
            setCBLRecordTypesSC = Utility.getRecordTypeFromCBLCustomSetting(Student_Competency__c.sObjectType.getDescribe());
            
            // Student Expertise list that will be updated
            updateStudentExpertiseList = new List<Student_Expertise__C>();
            studentExpertiseIdTransferringInstitution = new Map<Id, String>();
            studentExpertiseIdTotalCEMap = new Map<Id, Double>();
            
            // New list of selected Student Expertise; also, creating the list of Student Expertise that will be updated
            selectedStudentExpertise = new List<Id>();
            for (StudentExpertiseDetails sed : studentExpertiseDetailsList) {
                if (sed.isSelected == true) {
                    // First, check if it is a GenEd
                    if (sed.isGenEd != null && sed.isGenEd) {
                        Student_Expertise__c newStudentExpertise = new Student_Expertise__c();
                        newStudentExpertise.Student_Program__c = studentProgramId;
                        newStudentExpertise.Area_of_Expertise__c = sed.areaOfExpertiseId;
                        newStudentExpertise.Opportunity__c = sed.opportunityId;
                        newStudentExpertise.Contact__c = sed.contactId;
                        newStudentExpertise.Pseudo_CE__c = 0.0;
                        if (!setCBLRecordTypesSE.isEmpty()) {
                            List<Id> stuExpRecordTypeIdList = new List<id>();
                            stuExpRecordTypeIdList.addAll(setCBLRecordTypesSE);
                            newStudentExpertise.recordTypeId = stuExpRecordTypeIdList[0];            
                        }
                        insert(newStudentExpertise);
                        sed.seId = newStudentExpertise.id;
                        
                        List<Student_Competency__c> newStudentCompetencyList = new List<Student_Competency__c>();
                        for (Competency__c competency : genEdCodeCompetencyMap.get(sed.aoeCourseCode)) {
                            Student_Competency__c sc = new Student_Competency__c();
                            sc.Student_Expertise__c = newStudentExpertise.id;
                            sc.Contact__c = sed.contactId;
                            sc.Opportunity__c = sed.opportunityId;
                            sc.Status__c = 'Registered';
                            sc.IsCompleted__c = false;
                            sc.Student_Program__c = studentProgramId;
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
                    
                    // If not GenEd, determine if it is a Pseudo course, and if it already exists in SF by checking the ID.
                    if (sed.isPseudoCourse && sed.seId == null) {
                        Student_Expertise__c studentExpertise = [SELECT area_of_expertise__c, program_expertise__c, opportunity__c, contact__c 
                                                                 FROM Student_Expertise__c
                                                                 WHERE area_of_expertise__r.course_code__c = :sed.aoeCourseCode AND Student_program__c = :studentProgramId
                                                                 LIMIT 1];
                        if (studentExpertise != null) {
                            Student_Expertise__c seToAdd = new Student_Expertise__c();
                            seToAdd.Student_Program__c = studentProgramId;
                            seToAdd.program_expertise__c = studentExpertise.program_expertise__c;
                            seToAdd.area_of_expertise__c = studentExpertise.area_of_expertise__c;
                            seToAdd.opportunity__c = studentExpertise.opportunity__c;
                            seToAdd.contact__c = studentExpertise.contact__c;
                            if (!setCBLRecordTypesSE.isEmpty()) {
                                List<Id> stuExpRecordTypeIdList = new List<id>();
                                stuExpRecordTypeIdList.addAll(setCBLRecordTypesSE);
                                seToAdd.recordTypeId = stuExpRecordTypeIdList[0];            
                            }
                            insert(seToAdd);
                            sed.seId = seToAdd.id;
                            
                            // Creating the Student Competency associated to this Student Expertise
                            Student_Competency__c sc = [SELECT program_competency__c, competency__c,  learning_order__c
                                                        FROM Student_Competency__c
                                                        WHERE Student_Expertise__r.area_of_expertise__r.course_code__c = :sed.aoeCourseCode
                                                        LIMIT 1];
                            
                            if (sc != null) {
                                Student_Competency__c studentCompetency = new Student_Competency__c();
                                studentCompetency.student_expertise__c = seToAdd.id;
                                studentCompetency.contact__c = studentExpertise.contact__c;
                                studentCompetency.opportunity__c = studentExpertise.opportunity__c;
                                studentCompetency.status__c = 'Registered';
                                studentCompetency.isCompleted__c = false;
                                studentCompetency.student_program__c = studentProgramId;
                                studentCompetency.program_competency__c = sc.program_competency__c;
                                studentCompetency.competency__c = sc.competency__c;
                                studentCompetency.learning_order__c = sc.learning_order__c;
                                studentCompetency.pseudo_CE__c = sed.totalCE;
                                //studentCompetency.pseudo_CE__c = 0.0;
                                if (!setCBLRecordTypesSC.isEmpty()) {
                                    List<Id> stuExpRecordTypeIdList = new List<id>();
                                    stuExpRecordTypeIdList.addAll(setCBLRecordTypesSC);
                                    studentCompetency.recordTypeId = stuExpRecordTypeIdList[0];            
                                }
                                insert(studentCompetency);
                            }
                            
                            priorStudentExpertiseList = new List<Student_Expertise__c>();
                            priorStudentExpertiseList = [SELECT Id, area_of_expertise_name__c,Audit_Category__c,area_of_expertise__r.course_code__c, total_ce__c, grade_value__c, grade__c, pseudo_course__c, pseudo_ce__c, Fulfilled_Course_from_a_Conferred_Degree__c, Fulfilled_Course_Name__c, non_transferrable__c
                                                         FROM Student_Expertise__c
                                                         WHERE Student_program__c = :studentProgramId
                                                         ORDER BY area_of_expertise__r.course_code__c ASC];
                        }
                    }
                    
                    if (selectedCreditType == 'Fulfilled') {
                        Student_Expertise__c sec = new Student_Expertise__c();
                        sec.Id = sed.seId;
                        if (sed.fulfilledCourseName == null || sed.fulfilledCourseName == '') {
                            sec.Fulfilled_Course_Name__c = sed.areaOfExpertiseName;
                        } else {
                            sec.fulfilled_course_name__c = sed.fulfilledCourseName;    
                        }
                        sec.grade__c = sed.grade;
                       
                        switch on sed.grade {
                            when 'A' {
                                sec.grade_value__c = 4;
                            }
                            when 'B' {
                                sec.grade_value__c = 3;
                            }
                            when 'C' {
                                sec.grade_value__c = 2;
                            }
                            when 'D' {
                                sec.grade_value__c = 1;
                            }
                            when 'S' {
                                sec.grade_value__c = null; //63276
                            }
                        }
                        if (selectedConferredDegree == 'Yes') {
                            sec.fulfilled_course_from_a_conferred_degree__c = true;
                        } else {                        
                            sec.fulfilled_course_from_a_conferred_degree__c = false;
                        }
                        updateStudentExpertiseList.add(sec);
                    }
                    
                    if ((selectedCreditType == 'Transferred' || selectedCreditType == 'Preliminary Transfer') && selectedMultipleTranscripts == 'Yes' ) {
                        studentExpertiseIdTransferringInstitution.put(sed.seId, sed.transferringInstitution);
                    }
                    if ((selectedCreditType == 'Transferred' || selectedCreditType == 'Preliminary Transfer')) {
                        studentExpertiseIdTotalCEMap.put(sed.seId, sed.totalCE);
                    }                    
                    
                    selectedStudentExpertise.add(sed.seId);
                }
            }
            
            if (!updateStudentExpertiseList.isEmpty() && selectedCreditType == 'Fulfilled') {
                update updateStudentExpertiseList;
            }
            
            // creating the Student Competency backup list for the Undo function
            priorCompetencyList = new List<Student_Competency__c>();
            priorCompetencyList = [SELECT Id, Student_Expertise__r.id, Name,student_expertise__c, student_expertise__r.area_of_expertise__r.course_code__c, 
                                   competency_title__c, competency_code__c,  status__c, Competency_Credit_Equivalency__c, Transferring_Institution__c, 
                                   Student_Expertise__r.Pseudo_Course__c,Student_Expertise__r.Audit_Category__C, pseudo_ce__c, isCompleted__c, competency__c, student_ID__c
                                   FROM Student_Competency__c
                                   WHERE Student_Expertise__r.id IN :selectedStudentExpertise AND Student_Program__c  = : studentProgramId];
            
            // Student Competencies that will be updated
            List<Student_Competency__c> updateStudentCompetencyList = new List<Student_Competency__c>();
            
            studentCompetencyDetailsList = new List<StudentCompetencyDetails>();
            for (Student_Competency__c sc : [SELECT Id, Student_Expertise__c,Student_Expertise__r.id, Name, student_expertise__r.area_of_expertise__r.course_code__c, 
                                             competency_title__c, competency_code__c,  status__c, Competency_Credit_Equivalency__c, Transferring_Institution__c, 
                                             Student_Expertise__r.Pseudo_Course__c, pseudo_ce__c, isCompleted__c, competency__c, student_ID__c, 
                                             student_expertise__r.fulfilled_course_name__c,Student_Expertise__r.Audit_Category__c
                                             FROM Student_Competency__c
                                             WHERE Student_Expertise__r.id IN :selectedStudentExpertise AND Student_Program__c  = : studentProgramId]) {                
                                                 StudentCompetencyDetails scd = new StudentCompetencyDetails();
                                                 scd.scId = sc.id;
                                                 scd.seId = sc.Student_Expertise__c;
                                                 scd.auditCategory = sc.Student_Expertise__r.Audit_Category__c;
                                                 scd.studentCompetencyName = sc.name;
                                                 scd.courseName = sc.student_expertise__r.area_of_expertise__r.course_code__c;
                                                 scd.competencyName = sc.competency_title__c;
                                                 scd.competencyCode = sc.competency_code__c;
                                                 scd.status = selectedCreditType;
                                                 scd.creditEquivalent = sc.competency_credit_equivalency__c;
                                                 if (selectedCreditType == 'Fulfilled') {
                                                     scd.transferringInstitution = 'Walden University';
                                                     sc.Transferring_Institution__c = 'Walden University';
                                                     scd.fulfilledCourseName = sc.student_expertise__r.fulfilled_course_name__c;
                                                 } else if ((selectedCreditType == 'Transferred' || selectedCreditType == 'Preliminary Transfer') && selectedMultipleTranscripts == 'Yes' ) {
                                                     scd.transferringInstitution = studentExpertiseIdTransferringInstitution.get(sc.Student_Expertise__r.id);
                                                     sc.Transferring_Institution__c = studentExpertiseIdTransferringInstitution.get(sc.Student_Expertise__r.id);
                                                 } else {
                                                     scd.transferringInstitution = transferInstitution;
                                                     sc.Transferring_Institution__c = transferInstitution;
                                                 }
                                                 scd.isStudentExpertisePseudoCE = sc.Student_Expertise__r.Pseudo_Course__c;
                                                 if (sc.Student_Expertise__r.Pseudo_Course__c) {
                                                     isPseudoCourse = true;
                                                     if (selectedCreditType == 'Transferred' || selectedCreditType == 'Preliminary Transfer') {
                                                         scd.pseudoCE = studentExpertiseIdTotalCEMap.get(sc.Student_Expertise__r.id);
                                                         if (sc.Student_Expertise__r.Audit_Category__c == 'General Elective') {
                                                         	sc.Pseudo_CE__c = scd.pseudoCE;
                                                         } else {
                                                             sc.Pseudo_CE__c = 5.0;
                                                         }
                                                         
                                                     } else {
                                                         if (sc.pseudo_ce__c == null) {
                                                             scd.pseudoCE = 5.0;
                                                         } else {
                                                             scd.pseudoCE = sc.pseudo_ce__c;
                                                         }
                                                     }
                                                 }
                                                 studentCompetencyDetailsList.add(scd);
                                                 
                                                 sc.status__c = selectedCreditType;
                                                 if (selectedCreditType == 'Transferred' || selectedCreditType == 'Fulfilled') {
                                                     sc.isCompleted__c = true;    
                                                 } else {
                                                     sc.isCompleted__c = false;
                                                 }
                                                 updateStudentCompetencyList.add(sc);
                                             }
            
            if (!updateStudentCompetencyList.isEmpty()) {
                update updateStudentCompetencyList;
            }
            
            if (displayGradePicklist && isPseudoCourse) {
                isFulfilledCourseNameDisplayed = true;                
            }
            
            if (testFlag) {
                updatePseudoCE();
            }
            
        } catch(Exception exp) {
            error = exp.getMessage();
            system.debug(exp);
        }
    }
    
    public void getCoursesToFlipToTransfer() {
        try {        
            isFlipToOfficialTransfer = true;
            isUndoBtnDisplayed = false;
            
            studentCompetencyDetailsList = new List<StudentCompetencyDetails>();
            for (Student_Competency__c sc : [SELECT Id,Student_Expertise__c, Student_Expertise__r.id, name, student_expertise__r.area_of_expertise__r.course_code__c, 
                                             competency_title__c, competency_code__c,  status__c, competency_credit_equivalency__c, transferring_institution__c, 
                                             Student_Expertise__r.Pseudo_Course__c, pseudo_ce__c, isCompleted__c, competency__c, student_ID__c,Student_Expertise__r.Audit_Category__c
                                             FROM Student_Competency__c 
                                             WHERE Student_Program__c  = : studentProgramId AND status__c = 'Preliminary Transfer']) {
                                                 StudentCompetencyDetails scd = new StudentCompetencyDetails();
                                                 scd.scId = sc.id;
                                                 scd.auditCategory = sc.Student_Expertise__r.Audit_Category__c;
                                                 scd.seId = sc.Student_Expertise__c;
                                                 scd.studentCompetencyName = sc.name;
                                                 scd.courseName = sc.student_expertise__r.area_of_expertise__r.course_code__c;
                                                 scd.competencyName = sc.competency_title__c;
                                                 scd.competencyCode = sc.competency_code__c;
                                                 scd.status = sc.status__c;
                                                 scd.creditEquivalent = sc.competency_credit_equivalency__c;
                                                 scd.transferringInstitution = sc.transferring_institution__c;
                                                 scd.isStudentExpertisePseudoCE = sc.student_expertise__r.pseudo_course__c;
                                                 if (sc.Student_Expertise__r.Pseudo_Course__c) {
                                                     isPseudoCourse = true;
                                                     scd.pseudoCE = sc.pseudo_ce__c;
                                                 }
                                                 studentCompetencyDetailsList.add(scd);
                                             }
        } catch(Exception e) {
            System.debug(e);
        }
    } 
    
    //transfer student competencies from FLIP TO OFFICIAL TRANSFER based on the selected checkboxes
    public void flipToTransfer() {
        try {
            
            //new list of records if they are selected
            List<Id> selectedRecords = new List<Id>();
            
            for (StudentCompetencyDetails scd : studentCompetencyDetailsList) {
                if (scd.isSelected == true){
                    scd.status = 'Transferred';
                    selectedRecords.add(scd.scId);
                }
            }
            
            priorCompetencyList = new List<Student_Competency__c>();
            
            //create backup for undo changes
            priorCompetencyList = [SELECT Id,Student_Expertise__c, Student_Expertise__r.id, name, student_expertise__r.area_of_expertise__r.course_code__c, competency_title__c, competency_code__c,  status__c, competency_credit_equivalency__c, transferring_institution__c, Student_Expertise__r.Pseudo_Course__c, pseudo_ce__c, isCompleted__c, competency__c, student_ID__c
                                   FROM Student_Competency__c
                                   WHERE Id IN :selectedRecords AND Student_Program__c  = : studentProgramId];
            
            //Update student competencies with status
            List<Student_Competency__c> updateCompetencyList = new List<Student_Competency__c>();
            
            updatePseudoCE();
            
            for (Student_Competency__c sc : [SELECT status__c, isCompleted__c 
                                             FROM Student_Competency__c
                                             WHERE Id IN :selectedRecords AND Student_Program__c  = :studentProgramId]) {
                                                 sc.status__c = 'Transferred';
                                                 sc.isCompleted__c = true;
                                                 
                                                 updateCompetencyList.add(sc);
                                             }
            
            if (!updateCompetencyList.isEmpty()) {
                update updateCompetencyList;
            }
            
            isFlipToOfficialTransfer = false;
            isSeconUndoBtnDisplayed = true;
        }
        catch(Exception exp) {
            System.debug(exp);
        }
    }
    
    public void addPseudoCourse() {
        try {
            
            for (Integer i = 0; i < studentExpertiseDetailsList.size(); i++) {
                if (duplicateSeCourseName == studentExpertiseDetailsList[i].aoeCourseCode) {
                    StudentExpertiseDetails sed = new StudentExpertiseDetails();
                    sed.aoeCourseCode = duplicateSeCourseName;
                    
                    sed.totalCE = 5.0;
                    sed.isPseudoCourse = true;
                    sed.creditType = 'Registered';
                    if (i + 1 == studentExpertiseDetailsList.size()) {
                        studentExpertiseDetailsList.add(sed);
                    } else {
                        studentExpertiseDetailsList.add(i +1, sed);
                    }
                    break;
                }
            }
            
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    public void updatePseudoCE() {
        try {
            List<Student_Expertise__c> listStudentExpSeSplit = new List<Student_Expertise__c>();
            List<Student_Competency__c> lstUpdatePseudoCE = new List<Student_Competency__c>();
            Map<Id,Integer> seIdPseudoCeMap = new  Map<Id,Integer> ();
            for (StudentCompetencyDetails sc : studentCompetencyDetailsList) {
                //SE SPLIT logic  START
                if (sc.pseudoCE != null && sc.pseudoCE > 5 && sc.auditCategory == 'General Education; General Elective' && selectedCreditType != 'Fulfilled') {
                    seIdPseudoCeMap.put(sc.seId ,integer.ValueOf(sc.pseudoCE));
                } else if (sc.scId != null && sc.isStudentExpertisePseudoCE == true) {
                    lstUpdatePseudoCE.add(new Student_Competency__c(Id = sc.scId, Pseudo_CE__c = sc.pseudoCE));
                }
            }
            If(!seIdPseudoCeMap.isEmpty()){        
                listStudentExpSeSplit =  [SELECT Area_of_Expertise_Name__c,Area_of_Expertise__c,Audit_Category__c,Clone_from_SE_ID__c,Contact__c,CreatedById,CreatedDate,External_Key__c,Fulfilled_Course_from_a_Conferred_Degree__c,
                                          Fulfilled_Course_Name__c,Grade_Value__c,Grade__c,Id,IsAchieved__c,IsDeleted,Is_Added_from_Program_Plan__c,Is_Audit_History_Created__c,
                                          Is_Pre_Req_Lock__c,Is_Removed_from_Program_Plan__c,LastActivityDate,LastModifiedById,LastModifiedDate,Learning_Order__c,Level_Type__c,Name,Non_Transferrable__c,  
                                          Number_of_Competencies_Completed__c,Number_of_Competencies_Transferred__c,Opportunity__c,Outcome_Category__c,
                                          Outcome_Subject_Area_Expertise__c,Pre_Req_Condition_Rule__c,Program_Expertise__c,Program_Institution__c,Program_Name__c,  
                                          Pseudo_CE__c,Pseudo_Course__c,RecordTypeId,Student_Name__c,Student_Program__c,Subject_Area_Expertise__c,SystemModstamp,
                                          Total_Applied_Earned_CE_Outcome__c,Total_CE__c          
                                          FROM Student_Expertise__c
                                          WHERE Audit_Category__c = 'General Education; General Elective' 
                                          AND Pseudo_Course__c = TRUE AND ID In: seIdPseudoCeMap.keySet()];
            }
            
            if (!lstUpdatePseudoCE.isEmpty()) {
                update lstUpdatePseudoCE;
                isPseudoCourse = false;
            }
            newCompsLst = new List<student_competency__C>();
            if(!listStudentExpSeSplit.isEmpty()){
                newCompsLst =  CloneSEUtility.cloneSe(listStudentExpSeSplit, seIdPseudoCeMap);
                isPseudoCourse = false;
                
            }
            
        }
        catch(Exception exp) {
            System.debug(exp.getMessage());
        }
    }
    
    public void undoOperation() {
        try {
            
            if (selectedCreditType == 'Fulfilled') {
                studentExpertiseDetailsList = new List<StudentExpertiseDetails>();
                for (Student_Expertise__c sec : priorStudentExpertiseList) {
                    if (sec.Grade__c == null) {
                        sec.Grade__c = '';
                    }
                    if (sec.Grade_Value__c == null) {
                        sec.Grade_Value__c = null;
                    }
                    if (sec.Fulfilled_Course_Name__c == null) {
                        sec.fulfilled_course_name__c = '';
                    }
                    
                    StudentExpertiseDetails sed = new StudentExpertiseDetails();
                    sed.seId = sec.id;
                    sed.isConferredDegree = sec.Fulfilled_Course_from_a_Conferred_Degree__c;
                    sed.grade = sec.Grade__c;
                    sed.aoeCourseCode = sec.area_of_expertise__r.course_code__c;
                    sed.fulfilledCourseName = sec.Fulfilled_Course_Name__c;
                    //
                    sed.creditType = selectedCreditType;
                    
                    sed.totalCE = sec.total_ce__c;
                    sed.isPseudoCourse = sec.Pseudo_Course__c;
                    studentExpertiseDetailsList.add(sed);
                }
                
                if (!priorStudentExpertiseList.isEmpty()) {
                    update priorStudentExpertiseList;
                }
            }
            List<student_competency__c> scToUpdate = new  List<student_competency__c> ();
            if(newCompsLst != null && !newCompsLst.isEmpty()){
                for(student_competency__c sc:newCompsLst){
                    
                    sc.IsCompleted__c= false;
                    sc.Status__c = 'Registered';
                    sc.Pseudo_CE__c= 0;
                    scToUpdate.add(sc); 
                }
            }
            
            if(!priorCompetencyList.isEmpty()) {
                for (Student_Competency__c sc : priorCompetencyList) {
                    if (sc.Transferring_Institution__c == null) {
                        sc.Transferring_Institution__c = '';
                    }
                    if (sc.pseudo_CE__c == null) {
                        sc.pseudo_CE__c = 0.0;
                    }
                }
                scToUpdate.addAll(priorCompetencyList);
                
            }
            
            if(!scToUpdate.isEmpty()){
                update scToUpdate;
            }
            
            studentCompetencyDetailsList = new List<StudentCompetencyDetails>();
            for (Student_Competency__c sc : priorCompetencyList) {
                StudentCompetencyDetails scd = new StudentCompetencyDetails();
                scd.studentCompetencyName = sc.Name;
                scd.seId = sc.student_expertise__c;
                scd.competencyName = sc.competency_title__c;
                scd.auditCategory = sc.Student_Expertise__r.Audit_Category__c;
                scd.status = sc.status__c;
                scd.courseName = sc.student_expertise__r.area_of_expertise__r.course_code__c;
                scd.competencyCode = sc.competency_code__c;
                scd.creditEquivalent = sc.competency_credit_equivalency__c;
                //studCompDetail.compId = cc.competency__c;
                scd.scId = sc.id;
                if (sc.Transferring_Institution__c == null) {
                    scd.transferringInstitution = '';    
                } else {
                    scd.transferringInstitution = sc.transferring_institution__c;
                }
                scd.isStudentExpertisePseudoCE = sc.student_expertise__r.pseudo_Course__c;
                if (sc.student_expertise__r.pseudo_course__c) {
                    if (sc.pseudo_CE__c == null) {
                        scd.pseudoCE = 0;
                    } else {
                        scd.pseudoCE = sc.pseudo_CE__c;
                    }
                    
                }
                scd.isCompleted = sc.isCompleted__c;
                studentCompetencyDetailsList.add(scd);
            }
            
            
            isUndoBtnDisplayed = false;
            isPseudoCourse = false;
            isSeconUndoBtnDisplayed = false;
        } catch(Exception exp) {
            System.debug(exp);
        }
    }
    
    private Set<String> getGenEdCoursesByProgramCode(String programCode) {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get('TOC_GenEds_By_Program__c').getDescribe().fields.getMap();
        Map<String, String> apiNameLabelMap = new Map<String, String>();
        
        String fieldList;
        for (Schema.SObjectField fld : fieldMap.Values()) {
            if(fld.getDescribe().isCustom()) {
                if (fld.getDescribe().getLabel() == programCode) {
                    fieldList = fld.getDescribe().getName();
                    apiNameLabelMap.put(fld.getDescribe().getLabel(), fld.getDescribe().getName());
                }                
            }
        }
        
        Map<String, TOC_GenEds_By_Program__c> configMap = TOC_GenEds_By_Program__c.getall();
        
        Map<String, String> fieldValueMap = new Map<String, String>();
        for (String str : configMap.keySet()) {
            TOC_GenEds_By_Program__c config = configMap.get(str);       
            if (config.get(fieldList) != null) {
                String aoeCourseCodes = config.get(fieldList).toString();
                List<String> tempList = aoeCourseCodes.split(',');
                for (String s : tempList) {
                    s = s.trim();
                }
                Set<String> aoeCourseCodesSet = new Set<String>(tempList);
                return aoeCourseCodesSet;
            }                
        }
        
        return null;
    }
    
    // This method determines if it is an MSN_RN Grad Program
    private boolean isMSN_RNProgram(String programCode) {
        Set<String> gradProgramsForGenEdSet = new Set<string>();
        for(Grad_Programs_for_GenEd_and_GenElective__c gradPrograms : Grad_Programs_for_GenEd_and_GenElective__c.getAll().values()){
            gradProgramsForGenEdSet.add(gradPrograms.Name);
        }
        
        if (gradProgramsForGenEdSet.contains(programCode)) {
            return true;
        }
        return false;
    }
    
    public void initiateTOCSummary() {
        cc = new CourseEquivalenceController();
    }
    public void getTOCSummary() {
        try {
            tocSummary.totalPreliminaryTransferCE = 0.0;
    		tocSummary.totalTransferredCE = 0.0;
    		tocSummary.totalFulfilledCE = 0.0;
            tocSummary.categoryGroupingList = new List<CategoryGrouping>();
            
            Student_Program__c sp = [SELECT Student_name__c, program__R.display_name__c, cbl_id__c, program__r.Degree_Level__c, Program__r.ProductCode
                                     FROM Student_program__c 
                                     WHERE Id = :studentProgramId];
            if (sp != null) {
                tocSummary.studentName = sp.Student_Name__c;
                tocSummary.programName = sp.program__R.display_name__c;
                tocSummary.cblId = sp.CBL_Id__c;
                tocSummary.degreeLevel = sp.program__r.Degree_Level__c;
            }
            
            studentCompetencyList = new List<Student_Competency__c>();
            studentCompetencyList = [SELECT student_expertise__r.area_of_expertise_name__c, 
                                     student_expertise__r.area_of_expertise__r.course_code__c,
                                     status__c,
                                     student_expertise__r.audit_category__c,
                                     transferring_institution__c,
                                     student_expertise__r.pseudo_Course__c,
                                     student_expertise__r.pseudo_ce__c,
                                     student_expertise__r.total_ce__c,
                                     pseudo_ce__c
                                     FROM Student_Competency__c
                                     WHERE student_program__c = :studentProgramId
                                     AND (status__c = 'Fulfilled' OR status__c = 'Transferred' OR status__c = 'Preliminary Transfer')
                                     ORDER BY student_expertise__r.audit_category__c,
                                     student_expertise__r.area_of_expertise_name__c];
            if (tocSummary.degreeLevel == 'Undergrad' || isMSN_RNProgram(sp.Program__r.ProductCode)) {
                tocSummary.isUndergrad = true;
                manageList();
            } else {
                tocSummary.isUndergrad = false;
                manageGradStudent();
            }
            
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            System.debug('Exception: ' + e.getLineNumber());
            //return null;
        }
    }
    
    private void manageList() {
        Set<String> auditCategorySet = new Set<String>();
        Set<String> studentExpertiseSet = new Set<String>();
        for(Student_Competency__c sc : studentCompetencyList) {
            if (sc.student_expertise__r.audit_category__c != null) {
                String auditCategoryType = sc.student_expertise__r.audit_category__c.split(';')[0];
                if (!auditCategorySet.contains(auditCategoryType)) {
                    auditCategorySet.add(auditCategoryType);
                    CategoryGrouping grouping = new CategoryGrouping();
                    grouping.type = auditCategoryType;
                    grouping.entry = new List<CategoryGroupingItem>();
                    grouping.totalCE = 0.0;
                    grouping.preliminaryTransferCE = 0.0;
                    grouping.transferredCE = 0.0;
                    grouping.fulfilledCE = 0.0;
                    tocSummary.categoryGroupingList.add(grouping);
                }
            
                if (sc.student_expertise__r.area_of_expertise__r.course_code__c != null) {
                    if (!studentExpertiseSet.contains(sc.student_expertise__r.area_of_expertise__r.course_code__c)) {
                        CategoryGroupingItem item = new CategoryGroupingItem();
                        item.seCourseCode = sc.student_expertise__r.area_of_expertise__r.course_code__c;
                        item.seAOEName = sc.student_expertise__r.area_of_expertise_name__c;
                        if (sc.student_expertise__r.pseudo_Course__c) {
                            if (sc.pseudo_ce__c != null) {
                                //item.creditTotal = sc.student_expertise__r.pseudo_ce__c;
                                item.creditTotal = sc.pseudo_ce__c;
                            } else {
                                item.creditTotal = 0;
                            }
                        } else {
                            studentExpertiseSet.add(sc.student_expertise__r.area_of_expertise__r.course_code__c);
                            item.creditTotal = sc.student_expertise__r.total_ce__c;
                        }
                        item.transferringInstitution = sc.transferring_institution__c;
                        item.creditType = sc.status__c;
                        for (CategoryGrouping cat : tocSummary.categoryGroupingList) {
                            if (cat.type == auditCategoryType) {
                                cat.totalCE += item.creditTotal;
                                if (item.creditType == 'Preliminary Transfer') {
                                    tocSummary.totalPreliminaryTransferCE += item.creditTotal;
                                    cat.preliminaryTransferCE += item.creditTotal;
                                } else if (item.creditType == 'Transferred') {
                                    tocSummary.totalTransferredCE += item.creditTotal;
                                    cat.transferredCE += item.creditTotal;
                                } else if (item.creditType == 'Fulfilled') {
                                    tocSummary.totalFulfilledCE += item.creditTotal;
                                    cat.fulfilledCE += item.creditTotal;
                                }
                                cat.entry.add(item);
                            }
                        }
                    }
                }
            }
        }
    }
    
    private void manageGradStudent() {
        Set<String> studentExpertiseSet = new Set<String>();
        CategoryGrouping grouping = new CategoryGrouping();
        grouping.type = 'All';
        grouping.entry = new List<CategoryGroupingItem>();
        grouping.totalCE = 0.0;
        grouping.preliminaryTransferCE = 0.0;
        grouping.transferredCE = 0.0;
        grouping.fulfilledCE = 0.0;
        tocSummary.categoryGroupingList.add(grouping);
        for(Student_Competency__c sc : studentCompetencyList) {
            if (!studentExpertiseSet.contains(sc.student_expertise__r.area_of_expertise__r.course_code__c)) {
                studentExpertiseSet.add(sc.student_expertise__r.area_of_expertise__r.course_code__c);
                CategoryGroupingItem item = new CategoryGroupingItem();
                item.seCourseCode = sc.student_expertise__r.area_of_expertise__r.course_code__c;
                item.seAOEName = sc.student_expertise__r.area_of_expertise_name__c;
                item.creditTotal = sc.student_expertise__r.total_ce__c;
                item.transferringInstitution = sc.transferring_institution__c;
                item.creditType = sc.status__c;
                for (CategoryGrouping cat : tocSummary.categoryGroupingList) {
                    if (cat.type == 'All') {
                        cat.totalCE += item.creditTotal;
                        if (item.creditType == 'Preliminary Transfer') {
                            tocSummary.totalPreliminaryTransferCE += item.creditTotal;
                            cat.preliminaryTransferCE += item.creditTotal;
                        } else if (item.creditType == 'Transferred') {
                            tocSummary.totalTransferredCE += item.creditTotal;
                            cat.transferredCE += item.creditTotal;
                        } else if (item.creditType == 'Fulfilled') {
                            tocSummary.totalFulfilledCE += item.creditTotal;
                            cat.fulfilledCE += item.creditTotal;
                        }
                        cat.entry.add(item);
                   }
                }
            }
        }
    }
    
    public class StudentExpertiseDetails {
        public Id seId {get;set;}
        public Boolean isConferredDegree {get;set;}
        public String grade {get;set;}
        public Integer gradeValue {get;set;}
        public String aoeCourseCode {get;set;}
        public String fulfilledCourseName {get;set;}
        public String creditType {get;set;}
        public String transferringInstitution {get;set;}
        public Double totalCE {get;set;}
        public Boolean isSelected {get;set;}
        public Boolean isPseudoCourse {get;set;}
        public String areaOfExpertiseName {get;set;}
        public Boolean isGenEd;
        public Id areaOfExpertiseId;
        public Id opportunityId;
        public Id contactId;
        
        public StudentExpertiseDetails() {
            
        }
    }
    
    public class StudentCompetencyDetails {
        public Id scId {get;set;}
        public Id competencyId {get;set;}
        public Id seId {get;set;}
        public String transferringInstitution {get;set;}
        public String studentCompetencyName {get;set;}
        public String competencyName {get;set;}
        public String courseName {get;set;}
        public String status {get;set;}
        public String auditCategory {get;set;}
        public String competencyCode {get;set;}
        public String fulfilledCourseName {get;set;}
        public Double creditEquivalent {get;set;}
        public Double pseudoCE {get;set;}
        public Boolean isSelected {get;set;}
        public Boolean isStudentExpertisePseudoCE {get;set;}
        public Boolean isCompleted {get;set;}
        
        public StudentCompetencyDetails() {
            
        }
    }
    
    public class TOCSummaryModel {
        public String studentName {get;set;}
        public String programName {get;set;}
        public String cblId {get; set;}
        public String degreeLevel;
        public Boolean isUndergrad {get;set;}
        public Decimal totalPreliminaryTransferCE {get;set;}
    	public Decimal totalTransferredCE {get;set;}
    	public Decimal totalFulfilledCE {get;set;}
        public List<CategoryGrouping> categoryGroupingList {get;set;}
        
        public TOCSummaryModel() {
            
        }
    }
    
    public class CategoryGrouping {
        public String type {get;set;}
        public List<CategoryGroupingItem> entry {get; set;}
        public Decimal totalCE {get;set;}
        public Decimal preliminaryTransferCE {get;set;}
        public Decimal transferredCE {get;set;}
        public Decimal fulfilledCE {get;set;}        
        
        public CategoryGrouping() {
            
        }
    }
    
    public class CategoryGroupingItem {
        public String seCourseCode {get;set;}
        public String seAOEName {get;set;}
        public Decimal creditTotal {get;set;}
        public String transferringInstitution {get;set;}
        public String creditType {get;set;}
        
        public CategoryGroupingItem() {
            
        }
    }
}