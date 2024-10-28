/*******************************************************************
Name  : EditMyProgramRNMSNController
Author: Horacio Sanchez
Date  : June 1, 2021
Description: Controller for EditMyProgramRNMSN VF Component
			 S-52649: L2: Update Edit my Program Page for Rn to MSN program

* Revision History
* Horacio Sanchez - 06/11/2021 - S-53561: L2: Update Edit my Program Page for Rn to MSN (FrontEnd)
* Horacio Sanchez - 06/14/2021 - S-48047: L2: Insert Selected Attributes from L1 as courses in L2
*************************************************************************/
public without sharing class EditMyProgramRNMSNController {
    
    public Id studentProgramId;
    public Student_Program__c sProg = new  Student_Program__c ();
    public Map<Id, AreaOfExpertise> removedAreaOfExpertises {get; set;}
    public String currentUserId {get; set;}
    
    public Set<String> leftSubSubjectAreaSet {get; set;}
    public Map<String, List<AreaOfExpertise>> leftSubjectAreaNameAOEListMap {get; set;}
    public Set<String> rightSubSubjectAreaSet {get; set;}
    public Map<String, SubjectArea> subjectAreaNameSubjectAreaMap {get; set;}
    public Map<String, List<AreaOfExpertise>> rightSubjectAreaNameAOEListMap {get; set;}
    public Set<String> courseCodesSet {get; set;}
    public Map<String, String> courseCodeSubjectAreaNameMap {get; set;}
    public Map<String, List<String>> tmsn0CourseCodesMap {get; set;}
    private Set<String> aoeCodesToCreateSet;
    private Set<String> aoeCodesToDeleteSet;
    private Set<String> loneAOEsIdSet;
    private Set<String> tmsn0CourseCodesSet;
    private Student_Program_Category_Requirement__c tmsn0SPCR;
    
    //private String programCode;
    private Boolean hasTMSN0;
    private final static String TMSN0 = 'TMSN0';
    private string tmsn0SubjectAreaName;
    
    Boolean isCommunityUser() {
        if('Customer Community Login'.equals( ([ Select UserLicense.Name  FROM Profile WHERE Id =: userinfo.getProfileid()]).UserLicense.Name) ) {
            return true;
        } else {
            return false;
        }
    }
    
    public EditMyProgramRNMSNController() {
        if (!isCommunityUser()) {
            studentProgramId = ApexPages.currentPage().getParameters().get('id');
        } else {
            currentUserId = UserInfo.getUserId();
            System.debug('currentUserId: ' + currentUserId);
            User user = [SELECT Id, ContactId FROM User WHERE Id = :currentUserId];
            Contact contact = [
                    SELECT Id,walden_Email__c,name, (
                            SELECT Id, Program__r.Degree_Level__c, program__r.id, Program__r.ProductCode
                            FROM Student_Programs__r
                            WHERE IsStudentProgramActive__c = true
                            LIMIT 1
                    )
                    FROM CONTACT
                    WHERE Id = :user.ContactId
            ];
            ApexPages.currentPage().getParameters().put('id', contact.Student_Programs__r[0].id);
            ApexPages.currentPage().getParameters().get('id');
            studentProgramId = ApexPages.currentPage().getParameters().get('id');
        }
        
        hasTMSN0 = false;
        sProg  = [SELECT id, name, Application__c, Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c, 
                  		 Current_Student_Subscription__r.Agreed_To_Credits__c, Student__c, program__c, Degree_Level__c,
                  (SELECT Id, Area_Of_Expertise_Name__c
                        FROM Student_Competencies__r
                        WHERE Is_Enrolled__c = true 
                   		AND Student_Expertise__r.Area_of_Expertise__r.Display_On_Web__c= TRUE 
                   		AND Student_Expertise__r.Is_Removed_from_Program_Plan__c = FALSE
                   		AND Student_Expertise__r.Is_Added_from_Program_Plan__c = FALSE
                        ORDER BY Competency_Code__c ASC NULLS LAST
                  ),
                  (SELECT Name, Attribute__c, Category__c, Subject_Area_Expertise__c, Course__c
                   		FROM Student_Program_Category_Requirements__r
                  		ORDER BY Attribute__c ASC)
                  FROM student_program__c 
                  WHERE id = :studentProgramId];
        
        Set<String> spStudentExpertiseIdSet = new Set<String>();
        if (sProg != null) {
            for (Student_Competency__c sc : sProg.Student_Competencies__r) {
                spStudentExpertiseIdSet.add(sc.Area_Of_Expertise_Name__c);
            }
        }
        
        removedAreaOfExpertises = new Map<Id, AreaOfExpertise>();
        leftSubjectAreaNameAOEListMap = new Map<String, List<AreaOfExpertise>>();
        leftSubSubjectAreaSet = new Set<String>();
        rightSubjectAreaNameAOEListMap = new Map<String, List<AreaOfExpertise>>();
        rightSubSubjectAreaSet = new Set<String>();
        subjectAreaNameSubjectAreaMap = new Map<String, SubjectArea>();
        loneAOEsIdSet = new Set<String>();
        aoeCodesToCreateSet = new Set<String>();
        aoeCodesToDeleteSet = new Set<String>();
        tmsn0CourseCodesSet = new Set<String>();
        tmsn0SPCR = new Student_Program_Category_Requirement__c();
        
        // Getting Custom Settings for Admission Attributes
        Map<String, Attribute_Rules__c> attributeRulesMap = Attribute_Rules__c.getAll();
        
        // Iterating through Admission Attributes to get the corresponding Course Codes needed for the query
        courseCodesSet = new Set<String>();
        courseCodeSubjectAreaNameMap = new Map<String, String>();
        tmsn0CourseCodesMap = new Map<String, List<String>>();
        for (Student_Program_Category_Requirement__c spcr : sProg.Student_Program_Category_Requirements__r) {
            Attribute_Rules__c attributeRule = attributeRulesMap.get(spcr.Attribute__c);
            if (attributeRule.Create_Course__c) continue;
            if (spcr.Attribute__c.equalsIgnoreCase(TMSN0)) {
                hasTMSN0 = true;
                tmsn0SubjectAreaName = attributeRule.Subject_Area_Name__c;
                tmsn0CourseCodesMap.put(attributeRule.Subject_Area_Name__c, new List<String>());
                for (String aoeCourseCode : attributeRule.Course_Codes_Pool__c.split(';')) {
                    tmsn0CourseCodesMap.get(attributeRule.Subject_Area_Name__c).add(aoeCourseCode.trim());
                }
                courseCodesSet.addAll(attributeRule.Course_Codes_Pool__c.split(';'));
                tmsn0SPCR = spcr;
                tmsn0CourseCodesSet.add(spcr.Course__c);
                continue;
            }
            leftSubSubjectAreaSet.add(attributeRule.Subject_Area_Name__c);
            rightSubSubjectAreaSet.add(attributeRule.Subject_Area_Name__c);
            
            if (!subjectAreaNameSubjectAreaMap.containsKey(attributeRule.Subject_Area_Name__c)) {
                subjectAreaNameSubjectAreaMap.put(attributeRule.Subject_Area_Name__c, new SubjectArea(0, 1));
            } else {
                subjectAreaNameSubjectAreaMap.get(attributeRule.Subject_Area_Name__c).totalAOEs++;
            }
            courseCodesSet.addAll(attributeRule.Course_Codes_Pool__c.split(';'));
            
            for (String s : attributeRule.Course_Codes_Pool__c.split(';')) {
                courseCodeSubjectAreaNameMap.put(s.trim(), attributeRule.Subject_Area_Name__c);
            }
        }
        
        // Removing whitespace from both ends of the course code string
        List<String> courseCodesList = new List<String>(courseCodesSet);
        for (Integer i = 0; i < courseCodesList.size(); i++) {
            courseCodesList[i] = courseCodesList[i].trim();            
        }
                
        String query = 'SELECT id, name, category__c, Overview__c, Course_Code__c, Area_of_Expertise__c.Display_Name__c, Subject_Area__c, LMS_ID__c,';
        query += '(SELECT id, name, Competency__r.name, Credit_Equivalency__c, Competency_Code__c ,area_of_expertise__r.category__c FROM Competencies__r  ORDER BY Competency_Code__c), ';
        query += '(SELECT id,Program__r.Display_Name__c,category__c FROM Program_Expertise__r), ';
        query += '(SELECT Id, Area_of_Expertise__c, Is_Removed_from_Program_Plan__c, Is_Added_from_Program_Plan__c FROM Student_Expertise__r WHERE Student_Program__c = \'';
        query += sProg .id;
        query += '\'), ';
        query += '(SELECT Id, Area_of_Expertise__c, Course_Code__c, IsAchieved__c, Course_Name__c, Student_Expertise__c FROM Pre_requisite_Rules__r) ';
        query += 'FROM Area_of_Expertise__c WHERE Course_Code__c IN (\'' + String.join(courseCodesList, '\', \'') + '\')';
        List<Area_of_Expertise__c> areaOfExpertiseList = Database.query(query);
        
        // Iterating through the queried AOEs - leaving out Electives section
        for (Area_of_Expertise__c aoe : areaOfExpertiseList) {
            AreaOfExpertise aoeWrapper = new AreaOfExpertise();
            aoeWrapper.areaOfExpertiseRecord = aoe;
            aoeWrapper.subjectArea = aoe.Subject_Area__c;
            String subjectAreaName = courseCodeSubjectAreaNameMap.get(aoe.Course_Code__c);
            if (subjectAreaName != null) {
                aoeWrapper.category = aoe.category__c.split(';');                
                if (aoe.overview__c != null) {
                    aoeWrapper.overview = aoe.overview__c; 
                }
                if (!aoe.Student_Expertise__r.isEmpty()) {
                    aoeWrapper.isNew = false;
                    aoeWrapper.isAdded = true;
                    if (!tmsn0CourseCodesSet.contains(aoe.Course_Code__c)) {
                        if (!rightSubjectAreaNameAOEListMap.containsKey(subjectAreaName)) {
                            rightSubjectAreaNameAOEListMap.put(subjectAreaName, new List<AreaOfExpertise>{aoeWrapper});
                        } else {
                            rightSubjectAreaNameAOEListMap.get(subjectAreaName).add(aoeWrapper);
                        }
                        subjectAreaNameSubjectAreaMap.get(subjectAreaName).aoesAdded++;
                    }
                } else {
                    aoeWrapper.isNew = true;
                    aoeWrapper.isAdded = false;
                }
                
                if (!leftSubjectAreaNameAOEListMap.containsKey(subjectAreaName)) {
                    leftSubjectAreaNameAOEListMap.put(subjectAreaName, new List<AreaOfExpertise>{aoeWrapper});
                } else {
                    leftSubjectAreaNameAOEListMap.get(subjectAreaName).add(aoeWrapper);
                }
                if (!rightSubjectAreaNameAOEListMap.containsKey(subjectAreaName)) {
                    rightSubjectAreaNameAOEListMap.put(subjectAreaName, new List<AreaOfExpertise>());
                }
            }
        }
        
        if (hasTMSN0) {
            Map<String, Area_of_Expertise__c> aoeCourseCodeAOEMap = new Map<String, Area_of_Expertise__c>();
            for (Area_of_Expertise__c aoe : areaOfExpertiseList) {
                aoeCourseCodeAOEMap.put(aoe.Course_Code__c, aoe);
            }
            
            for (String subSubjectArea : tmsn0CourseCodesMap.keySet()) {
                leftSubSubjectAreaSet.add(subSubjectArea);
                rightSubSubjectAreaSet.add(subSubjectArea);
                if (!subjectAreaNameSubjectAreaMap.containsKey(subSubjectArea)) {
                    subjectAreaNameSubjectAreaMap.put(subSubjectArea, new SubjectArea(0, 1));
                } else {
                    subjectAreaNameSubjectAreaMap.get(subSubjectArea).totalAOEs++;
                }
                for (String aoeCourseCode : tmsn0CourseCodesMap.get(subSubjectArea)) {
                    Area_of_Expertise__c aoe = aoeCourseCodeAOEMap.get(aoeCourseCode);
                    if (aoe != null) {
                        AreaOfExpertise aoeWrapper = new AreaOfExpertise();                        
                        aoeWrapper.areaOfExpertiseRecord = aoe;
                        aoeWrapper.subjectArea = aoe.Subject_Area__c;
                        if (subSubjectArea != null) {
                            aoeWrapper.category = aoe.category__c.split(';');                
                            if (aoe.overview__c != null) {
                                aoeWrapper.overview = aoe.overview__c; 
                            }
                            if (!aoe.Student_Expertise__r.isEmpty() ) {
                                aoeWrapper.isNew = false;
                                aoeWrapper.isAdded = true;
                                if (tmsn0CourseCodesSet.contains(aoe.Course_Code__c)) {
                                    if (!rightSubjectAreaNameAOEListMap.containsKey(subSubjectArea)) {
                                        rightSubjectAreaNameAOEListMap.put(subSubjectArea, new List<AreaOfExpertise>{aoeWrapper});
                                    } else {
                                        rightSubjectAreaNameAOEListMap.get(subSubjectArea).add(aoeWrapper);
                                    }
                                    subjectAreaNameSubjectAreaMap.get(subSubjectArea).aoesAdded++;
                                }
                            } else {
                                aoeWrapper.isNew = true;
                                aoeWrapper.isAdded = false;
                            }
                        }
                        
                        // Check: for all the other Subject Area names, if there is one group with one, then grey out the course in the Electives group
                        for (String subjectAreaName : leftSubjectAreaNameAOEListMap.keySet()) {
                            if (leftSubjectAreaNameAOEListMap.get(subjectAreaName).size() == 1 && !subjectAreaName.equals(tmsn0SubjectAreaName)) {
                                loneAOEsIdSet.add(leftSubjectAreaNameAOEListMap.get(subjectAreaName)[0].areaOfExpertiseRecord.Id);
                                if (leftSubjectAreaNameAOEListMap.get(subjectAreaName)[0].areaOfExpertiseRecord.Course_Code__c == aoeCourseCode) {
                                    aoeWrapper.isAdded = true;
                                }
                            }
                        }
                        
                        if (!leftSubjectAreaNameAOEListMap.containsKey(subSubjectArea)) {
                            leftSubjectAreaNameAOEListMap.put(subSubjectArea, new List<AreaOfExpertise>{aoeWrapper});
                        } else {
                            leftSubjectAreaNameAOEListMap.get(subSubjectArea).add(aoeWrapper);
                        }
                        if (!rightSubjectAreaNameAOEListMap.containsKey(subSubjectArea)) {
                            rightSubjectAreaNameAOEListMap.put(subSubjectArea, new List<AreaOfExpertise>());
                        }
                    }
                }
            }
        }
        
        // Checking for all subject areas; if completed, then grey out all the group
        for (String subjectAreaName : leftSubjectAreaNameAOEListMap.keySet()) {
            if (subjectAreaName != null) {
                for (AreaOfExpertise aoe : leftSubjectAreaNameAOEListMap.get(subjectAreaName)) {
                    if (subjectAreaNameSubjectAreaMap.get(subjectAreaName).aoesAdded == subjectAreaNameSubjectAreaMap.get(subjectAreaName).totalAOEs) {
                        aoe.isAdded = true;
                    }
                }
            }
        }
    }
    
    //this method will be called when the '+' button is clicked on the left side
    public PageReference addAreaOfExpertise() {
        try {
            String selectedAreaOfExpertise= Apexpages.currentPage().getParameters().get('selectedExpertiseIdToAdd');
            String selectedSubjectAreaName  = Apexpages.currentPage().getParameters().get('selectedSubjectAreaNameToAdd');
            AreaOfExpertise selectedAOE;
            String secondSubjectArea;
            
            SubjectArea selectedSubjectArea = subjectAreaNameSubjectAreaMap.get(selectedSubjectAreaName);
            selectedSubjectArea.aoesAdded++;
            subjectAreaNameSubjectAreaMap.put(selectedSubjectAreaName, selectedSubjectArea);
            
            for (AreaOfExpertise aoe : leftSubjectAreaNameAOEListMap.get(selectedSubjectAreaName)) {
                if (selectedSubjectArea.aoesAdded == selectedSubjectArea.totalAOEs) {
                    aoe.isAdded = true;
                }
                if (aoe.areaOfExpertiseRecord.Id.equals(selectedAreaOfExpertise)) {
                    selectedAOE = aoe;
                    aoe.isAdded = true;
                }
            }
            
            aoeCodesToDeleteSet.remove(selectedAOE.areaOfExpertiseRecord.Course_Code__c);
            if (selectedAOE.isNew) {
             	aoeCodesToCreateSet.add(selectedAOE.areaOfExpertiseRecord.Course_Code__c);
            }            
            
            if (hasTMSN0) {    
                if (tmsn0SubjectAreaName != null && selectedSubjectAreaName.equals(tmsn0SubjectAreaName)) {
                    secondSubjectArea = courseCodeSubjectAreaNameMap.get(selectedAOE.areaOfExpertiseRecord.Course_Code__c);
                    tmsn0SPCR.Course__c = selectedAOE.areaOfExpertiseRecord.Course_Code__c;
                } else {
                    secondSubjectArea = tmsn0SubjectAreaName;
                }
                
                if (secondSubjectArea != null) {
                    for (AreaOfExpertise aoe : leftSubjectAreaNameAOEListMap.get(secondSubjectArea)) {
                        if (aoe.areaOfExpertiseRecord.Course_Code__c.equals(selectedAOE.areaOfExpertiseRecord.Course_Code__c)) {
                            aoe.isAdded = true;
                            break;
                        }
                    }
                }
            }
            
            // Add AOE to the right part of the page
            rightSubjectAreaNameAOEListMap.get(selectedSubjectAreaName).add(selectedAOE);            
        } catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, 'Exception at line ' +  e.getLineNumber() + ', ' + e.getMessage());
            throw e;
        }        
        
        return null;   
    }
    
    //this method will be called when the '-' button is clicked on the left side    
    public void removeAreaOfExpertise() {
        try {
            String removedAreaOfExpertise = Apexpages.currentPage().getParameters().get('selectedExpertiseIdToRemove');
            String removedSubjectAreaName = Apexpages.currentPage().getParameters().get('selectedSubjectAreaNameToRemove');        
            AreaOfExpertise selectedAOE;
            String secondSubjectArea;
            
            SubjectArea selectedSubjectArea = subjectAreaNameSubjectAreaMap.get(removedSubjectAreaName);
            selectedSubjectArea.aoesAdded--;
            subjectAreaNameSubjectAreaMap.put(removedSubjectAreaName, selectedSubjectArea);
            
            // Remove AOE from its group in the right part of the page
            Set<String> remainingSelectedAOEsIdSet = new Set<String>();
            for (Integer i = rightSubjectAreaNameAOEListMap.get(removedSubjectAreaName).size() - 1; i >= 0; i--) {
                AreaOfExpertise aoe = rightSubjectAreaNameAOEListMap.get(removedSubjectAreaName)[i];
                if (aoe.areaOfExpertiseRecord.Id.equals(removedAreaOfExpertise)) {
                    selectedAOE = aoe;
                    rightSubjectAreaNameAOEListMap.get(removedSubjectAreaName).remove(i);
                } else {
                    remainingSelectedAOEsIdSet.add(aoe.areaOfExpertiseRecord.Id);
                }
            }
            
            aoeCodesToCreateSet.remove(selectedAOE.areaOfExpertiseRecord.Course_Code__c);
            aoeCodesToDeleteSet.add(selectedAOE.areaOfExpertiseRecord.Course_Code__c);
            
            if (hasTMSN0) {
                // An AOE from Electives is removed
                if (tmsn0SubjectAreaName != null && removedSubjectAreaName.equals(tmsn0SubjectAreaName)) {
                    // Refreshing left area for Electives section
                    for (AreaOfExpertise aoe : leftSubjectAreaNameAOEListMap.get(removedSubjectAreaName)) {
                        aoe.isAdded = false;
                        for (String rightAOEId : remainingSelectedAOEsIdSet) {
                            if (aoe.areaOfExpertiseRecord.Id.equals(rightAOEId)) {
                                aoe.isAdded = true;
                            }
                        }
                        if (loneAOEsIdSet.contains(aoe.areaOfExpertiseRecord.Id)) {
                            aoe.isAdded = true;
                        }
                        
                        // Checking for the rest of the subject areas in the right side, if any AOE is added then grey out 
                        // in the Electives section in the left part
                        for (String rightSubjectAreaName : rightSubjectAreaNameAOEListMap.keySet()) {
                            if (rightSubjectAreaNameAOEListMap.get(rightSubjectAreaName).equals(tmsn0SubjectAreaName)) continue;
                            for (AreaOfExpertise rightAOE : rightSubjectAreaNameAOEListMap.get(rightSubjectAreaName)) {
                                if (aoe.areaOfExpertiseRecord.Id.equals(rightAOE.areaOfExpertiseRecord.Id)) {
                                    aoe.isAdded = true;
                                }
                            }
                        }
                    }
                    secondSubjectArea = courseCodeSubjectAreaNameMap.get(selectedAOE.areaOfExpertiseRecord.Course_Code__c);
                    
                    // Refreshing left area for section other than Electives, if exists
                    if (secondSubjectArea != null) {
                        for (AreaOfExpertise aoe : leftSubjectAreaNameAOEListMap.get(secondSubjectArea)) {
                            if (subjectAreaNameSubjectAreaMap.get(secondSubjectArea).aoesAdded == subjectAreaNameSubjectAreaMap.get(secondSubjectArea).totalAOEs) {
                                break;
                            }
                            aoe.isAdded = false;
                            for (String rightAOEId : remainingSelectedAOEsIdSet) {
                                if (aoe.areaOfExpertiseRecord.Id.equals(rightAOEId)) {
                                    aoe.isAdded = true;
                                }
                            }
                        }
                    }                    
                    tmsn0SPCR.Course__c = '';
                } else { // An AOE from a section that is NOT Electives is removed
                    // Refreshing left area for section other than Elective
                    for (AreaOfExpertise aoe : leftSubjectAreaNameAOEListMap.get(removedSubjectAreaName)) {
                        aoe.isAdded = false;
                        for (String rightAOEId : remainingSelectedAOEsIdSet) {
                            if (aoe.areaOfExpertiseRecord.Id.equals(rightAOEId)) {
                                aoe.isAdded = true;
                            }
                        }
                        for (AreaOfExpertise aoeElective : rightSubjectAreaNameAOEListMap.get(tmsn0SubjectAreaName)) {
                            if (aoe.areaOfExpertiseRecord.Id.equals(aoeElective.areaOfExpertiseRecord.Id)) {
                                aoe.isAdded = true;
                            }
                        }
                    }                    
                    secondSubjectArea = tmsn0SubjectAreaName;
                    // Refreshing left area for Electives section
                    for (AreaOfExpertise aoe : leftSubjectAreaNameAOEListMap.get(secondSubjectArea)) {
                        if (subjectAreaNameSubjectAreaMap.get(secondSubjectArea).aoesAdded == subjectAreaNameSubjectAreaMap.get(secondSubjectArea).totalAOEs) {
                            break;
                        }
                        aoe.isAdded = false;
                        for (String rightAOEId : remainingSelectedAOEsIdSet) {
                            if (aoe.areaOfExpertiseRecord.Id.equals(rightAOEId)) {
                                aoe.isAdded = true;
                            }
                        }
                        if (loneAOEsIdSet.contains(aoe.areaOfExpertiseRecord.Id)) {
                            aoe.isAdded = true;
                        }
                    }
                }
            } else {
                // Refreshing left area for section other than Elective
                for (AreaOfExpertise aoe : leftSubjectAreaNameAOEListMap.get(removedSubjectAreaName)) {
                    aoe.isAdded = false;
                    for (String rightAOEId : remainingSelectedAOEsIdSet) {
                        if (aoe.areaOfExpertiseRecord.Id.equals(rightAOEId)) {
                            aoe.isAdded = true;
                        }
                    }
                }
            }
        } catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, 'Exception at line ' +  e.getLineNumber() + ', ' + e.getMessage());
            throw e;
        }
    }
    
    //this method will be called when save button is clicked     
    public PageReference saveCompetencies() {
        try {
            if (aoeCodesToCreateSet != null && !aoeCodesToCreateSet.isEmpty()) {
                DataGenerator.createSEsAndSCsFromAOECodeAndSP(aoeCodesToCreateSet, sProg);
            }
            if (aoeCodesToDeleteSet != null && !aoeCodesToDeleteSet.isEmpty()) {
                DataGenerator.deleteSEsAndSCsFromAOECodeAndSP(aoeCodesToDeleteSet, sProg);
            }
            
            if (tmsn0SPCR != null && tmsn0SPCR.Id != null) {
                update tmsn0SPCR;
            }
       
            PageReference myTermPage;
            myTermPage = new PageReference('/apex/ProgramOverview');
            myTermPage.setRedirect(true);
            return myTermPage;
            
        } catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, 'Exception at line ' +  e.getLineNumber() + ', ' + e.getMessage());
            throw e;       
        }        
    }
    
    public PageReference editMyProgramCancel() {
        PageReference myTermPage;
        myTermPage = new PageReference('/apex/ProgramOverview');
        myTermPage.setRedirect(true);
        return myTermPage;
    }

    public class AreaOfExpertise {
        public Area_of_Expertise__c areaOfExpertiseRecord{get;set;}
        public Boolean isAdded {get; set;}
        public List<String> category {get; set;}
        public Boolean isNew {get; set;}
        public String overview {get; set;}
        public String subjectArea {get; set;}
        public String subSubjectArea {get; set;}
    }
    
    public class SubjectArea {
        public String subjectAreaName {get; set;}
        public Integer aoesAdded {get; set;}
        public Integer totalAOEs {get; set;}
        
        public SubjectArea() {
            
        }
        
        public SubjectArea(Integer totalAOEs) {
            this.totalAOES = totalAOEs;
        }
        
        public SubjectArea(Integer aoesAdded, Integer totalAOEs) {
            this.aoesAdded = aoesAdded;
            this.totalAOEs = totalAOEs;
        }
    }
}