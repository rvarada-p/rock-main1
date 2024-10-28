/*******************************************************************
Name  : EditMyProgramController 
Author: Ravitej Varada (Laureate)
Date  : May  25, 2018
Description: Controller extension class for EditMyProgram Page

* Revision History
* Horacio Sanchez   01/05/2021     S-38295: Tempo: Learning order for MSN_RN Pool of Courses
* Horacio Sanchez   06/01/2021     S-52649: L2: Update Edit my Program Page for Rn to MSN program
* Horacio Sanchez   05/24/2022     S-89059 Update Tempo Portal Navigation Menu if ATC Start Date is Today
*************************************************************************/

public with sharing class EditMyProgramController{
    private set<ID> setCBLRecordTypes;
    private set<ID> setStudentCompRecType;

    Public Student_Program__c sProg = new  Student_Program__c ();
    public Map<Id, AreaOfExpertise> leftAreaOfExpertiseMap {get;set;}
    public Map<Id, AreaOfExpertise> rightAreaOfExpertiseMap {get;set;}
    public Map<Id, AreaOfExpertise> removedAreaOfExpertises {get;set;}
    public List<String> leftAoEId {get;set;}
    public List<String> rightAoEId {get;set;}
    
    public String studentName { get; set; }
    
    public string isAddedFromProgramPlan { get; set; }
    public Id studentProgramId;
    public string modalHeader { get; set; }
    public string modalBody { get; set; }
    public Boolean isModalWindow { get; set; }
    public String currentUserId { get; set; }
    public String contactId {get;set;}
    public String waldenEmail { get; set; }
    public String waldenEmailHash { get; set; }    
    public String intercomAppId { get; set; }
    public Id programId {get;set;}
    public Boolean isRNMSNProgram {get;set;}
    private String programCode;
    private List<String> orderedCategoriesList;
    private Map<String, Area_of_Expertise__c> aoeIdaoeMap;
    
    public List<String> leftAOECategories {get;set;}
    public Boolean isATCCompleted {get;set;}
    
    Boolean isCommunityUser() {
        if('Customer Community Login'.equals( ([ Select UserLicense.Name  FROM Profile WHERE Id =: userinfo.getProfileid()]).UserLicense.Name) ) {
            return true;
        } else {
            return false;
        }
    }
    
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
    
    private List<String> getNursCoursesForMSN_RNProgram() {
        List<String> nursCodes = new List<String>();
        for (Nurs_Courses_for_MSN_RN__c code : Nurs_Courses_for_MSN_RN__c.getAll().values()) {
            nursCodes.add(code.Name);
        }
        return nursCodes;
    }
    
    public EditMyProgramController() {
        initInstanceVariablesFromUser();
        initPageConstruction();
    }
    
    public EditMyProgramController(ApexPages.StandardController controller) {
        initInstanceVariablesFromUser();        
    }
    
    private void initInstanceVariablesFromUser() {
        if (!isCommunityUser()) {
            studentProgramId = ApexPages.currentPage().getParameters().get('id');
        } else {
            currentUserId = UserInfo.getUserId();
            User user = [SELECT Id, ContactId FROM User WHERE Id = :currentUserId];
            Contact contact = [
                    SELECT Id,walden_Email__c,name, (
                            SELECT Id, Program__r.Degree_Level__c, program__r.id, Program__r.ProductCode,
                        		   Current_Student_Subscription__r.Agreed_To_Credits__c, Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c,
                                   Program__r.Automate_Agree_to_Credit__c, Current_Student_Subscription__r.Start_Date__c
                            FROM Student_Programs__r
                            WHERE IsStudentProgramActive__c = true
                            LIMIT 1
                    )
                    FROM CONTACT
                    WHERE Id = :user.ContactId
            ];
            contactId= contact.id;
            programId = contact.Student_Programs__r[0].program__r.id;
            waldenEmail = contact.walden_Email__c;
            waldenEmailHash = HmacSHA256Encryption.generateHmacSHA256Signature(waldenEmail); 
            ApexPages.currentPage().getParameters().put('id', contact.Student_Programs__r[0].id);
            ApexPages.currentPage().getParameters().get('id');
            studentProgramId = ApexPages.currentPage().getParameters().get('id');
            programCode = contact.Student_Programs__r[0].Program__r.ProductCode;
            isRNMSNProgram = false;
            if (programCode.containsIgnoreCase('RNMSN')) {
                isRNMSNProgram = true;
            }
            //degreeLevel = contact.Student_Programs__r[0].Program__r.Degree_Level__c;
            
            isATCCompleted = true;
        
            // S-89059: Update Tempo Portal Navigation Menu if ATC Start Date is Today
            // Checking if Agree to Credits process has been completed
            Student_Program__c sp = contact.Student_Programs__r[0];
            if (sp.Current_Student_Subscription__c != null 
                && (sp.Current_Student_Subscription__r.Agreed_To_Credits__c == null || sp.Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c == null) 
                && sp.Program__r.Automate_Agree_to_Credit__c
                && sp.Current_Student_Subscription__r.Start_Date__c.daysBetween(Date.today()) < 15) {
                isATCCompleted = false;
            }
        }
    }
    
    // S-89059: Update Tempo Portal Navigation Menu if ATC Start Date is Today
    // Checking if Agree to Credits process has been completed
    public PageReference atcCompletedCheck() {
        if (!isATCCompleted) {
            PageReference myTermPage = new PageReference('/MyTermUndergrad');
            return myTermPage;
        }
        return null;
    }
    
    private void initPageConstruction() {
        try {
        System.debug('InitPageConstruction');
        sProg  = [SELECT id, Program__r.Automate_Agree_to_Credit__c,name, Application__c, Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c, Current_Student_Subscription__r.Agreed_To_Credits__c, Student__c, program__c, Degree_Level__c,
                  (SELECT Id, Area_Of_Expertise_Name__c
                        FROM Student_Competencies__r
                        WHERE Is_Enrolled__c = true 
                   		AND Student_Expertise__r.Area_of_Expertise__r.Display_On_Web__c= TRUE 
                   		AND Student_Expertise__r.Is_Removed_from_Program_Plan__c = FALSE
                   		AND Student_Expertise__r.Is_Added_from_Program_Plan__c = FALSE
                        ORDER BY Competency_Code__c ASC NULLS LAST
                  )
                  FROM student_program__c 
                  WHERE id = :studentProgramId];
        Set<String> spStudentExpertiseIdSet = new Set<String>();
        if (sProg != null) {
            for (Student_Competency__c sc : sProg.Student_Competencies__r) {
                spStudentExpertiseIdSet.add(sc.Area_Of_Expertise_Name__c);
            }
        }
        List<String> spStudentExpertiseIdList = new List<String>(spStudentExpertiseIdSet);
        removedAreaOfExpertises = new Map<Id, AreaOfExpertise>();
        leftAreaOfExpertiseMap = new Map< Id, AreaOfExpertise>();
        rightAreaOfExpertiseMap = new Map<Id, AreaOfExpertise>();
        String query = 'SELECT id, name, category__c,Overview__c, Course_Code__c, Area_of_Expertise__c.Display_Name__c, Subject_Area__c, ';
        query += '(SELECT id, name, Competency__r.name, Credit_Equivalency__c, Competency_Code__c ,area_of_expertise__r.category__c FROM Competencies__r  ORDER BY Competency_Code__c), ';
        query += '(SELECT id,Program__r.Display_Name__c,category__c FROM Program_Expertise__r), ';
        if (isMSN_RNProgram(programCode)) {
        	query += '(SELECT Id, Area_of_Expertise__c, Is_Removed_from_Program_Plan__c, Is_Added_from_Program_Plan__c FROM Student_Expertise__r WHERE Audit_category__c NOT IN (\'Core\', \'Concentration\') AND Student_Program__c = \'';    
        } else {
            query += '(SELECT Id, Area_of_Expertise__c, Is_Removed_from_Program_Plan__c, Is_Added_from_Program_Plan__c FROM Student_Expertise__r WHERE Student_Program__c = \'';
        }        
        query += sProg .id;
        query += '\'), ';
        query += '(SELECT Id, Area_of_Expertise__c, Course_Code__c, IsAchieved__c, Course_Name__c, Student_Expertise__c FROM Pre_requisite_Rules__r) ';
        //query += 'FROM Area_of_Expertise__c WHERE (Display_on_Program_Edit__c = TRUE AND Display_on_web__c = TRUE)';// AND Name NOT IN (\'' + String.join(spStudentExpertiseIdList, '\', \'') + '\')';
        
        if (isMSN_RNProgram(programCode)) {
            query += 'FROM Area_of_Expertise__c WHERE (Display_on_Program_Edit__c = TRUE AND Display_on_web__c = TRUE) OR Course_Code__c IN (\'' + String.join(getNursCoursesForMSN_RNProgram(), '\', \'') + '\')'; 
        } else {
			query += 'FROM Area_of_Expertise__c WHERE (Display_on_Program_Edit__c = TRUE AND Display_on_web__c = TRUE AND Name NOT IN (\'' + String.join(spStudentExpertiseIdList, '\', \'') + '\'))';
        }
        
        List<Area_of_Expertise__c> areaOfExpertiseList = Database.query(query);
        for (Area_of_Expertise__c aoe : areaOfExpertiseList) {
            AreaOfExpertise aoeWrapper = new AreaOfExpertise();
            aoeWrapper.areaOfExpertiseRecord = aoe;
            if (String.isNotBlank(aoe.category__c)) {
                aoeWrapper.category = aoe.category__c.split(';');  
                
                if (aoe.overview__c != null) {
                    aoeWrapper.overview = aoe.overview__c; 
                }
                if (!aoe.Student_Expertise__r.isEmpty() ) {
                    if (!aoe.Student_Expertise__r[0].Is_Removed_from_Program_Plan__c) {
                        aoeWrapper.isNew = false;
                        aoeWrapper.isAdded = true;
                        rightAreaOfExpertiseMap.put(aoe.id, aoeWrapper);    
                    } else {
                        aoeWrapper.isNew = false;
                        aoeWrapper.isAdded = false;    
                    }
                } else {
                    aoeWrapper.isNew = true;
                    aoeWrapper.isAdded = false;
                }                    
                
                //left AOE List filter
                if (sProg.Degree_Level__c == 'Undergrad') {
                    if (!aoe.Program_Expertise__r.isEmpty()) {
                        System.debug('AOE: ' + aoe.Display_Name__c);
                        for (Program_Expertise__c pe :aoe.Program_Expertise__r )  {
                            if( pe.category__c  =='Core'   &&  pe.Program__c == sProg.Program__c )  {
                            } else if (pe == NULL) {
                            } else if (pe.category__c != null && (pe.category__c.contains('General Education') || pe.category__c.contains('General Elective') || pe.category__c.contains('General Education;General Elective'))){
                                leftAreaOfExpertiseMap.put(aoe.id, aoeWrapper);
                            } else if (pe.category__c  == 'Core'  &&  pe.Program__c != sProg.Program__c) {
                                leftAreaOfExpertiseMap.put(aoe.id, aoeWrapper);
                            }       
                        }
                    } else {
                        leftAreaOfExpertiseMap.put(aoe.id, aoeWrapper);
                    }   
                } else {
                    if (aoe.Category__c != null && (aoe.category__c.contains('General Education') || aoe.category__c.contains('General Elective') || aoe.category__c.contains('General Education;General Elective'))) {
                        leftAreaOfExpertiseMap.put(aoe.id, aoeWrapper);
                    }
                }
            }
        }

        Set<Id> masterAOEIdsSet = new Set<Id>();
        for (Master_Aoe__c masterAOE : [SELECT Course__r.id, Course__r.name, Course__r.category__c, Course__r.Overview__c, Course__r.Course_Code__c, Course__r.Display_Name__c
                                        FROM Master_AOE__c
                                        WHERE program__c = :programId]) {
        	AreaOfExpertise aoeWrapper = new AreaOfExpertise();
            aoeWrapper.areaOfExpertiseRecord = masterAOE.course__r;
            masterAOEIdsSet.add(masterAOE.course__r.id);
            if (masterAOE.Course__r.category__c == null || masterAOE.Course__r.category__c == '') {
                masterAOE.Course__r.category__c = 'General Education';
                aoeWrapper.category = new List<String>{'General Education'};
            } else {
                aoeWrapper.category = masterAOE.Course__r.category__c.split(';');
            }
            //aoeWrapper.isNew = true;
            //aoeWrapper.isAdded = false;
            leftAreaOfExpertiseMap.put(masterAOE.course__r.id, aoeWrapper);
        }
        
        for (Area_of_Expertise__c aoe : [SELECT id, name, category__c,Overview__c, Course_Code__c, Area_of_Expertise__c.Display_Name__c,
                                                (SELECT id, name, Competency__r.name, Credit_Equivalency__c, Competency_Code__c ,area_of_expertise__r.category__c 
                                                 FROM Competencies__r 
                                                 ORDER BY Competency_Code__c),
                                         		(SELECT Id, Area_of_Expertise__c, Is_Removed_from_Program_Plan__c,Is_Added_from_Program_Plan__c 
                                           		 FROM Student_Expertise__r
                                           		 WHERE Student_Program__c = :sProg.id)
                                         FROM Area_of_expertise__c
                                         WHERE id In :masterAOEIdsSet]) {
            AreaOfExpertise tempAoe = leftAreaOfExpertiseMap.get(aoe.id);
            if (tempAoe != null) {
                tempAoe.areaOfExpertiseRecord = aoe;
            }
            
            if (!aoe.Student_Expertise__r.isEmpty()) {
            	if (!aoe.Student_Expertise__r[0].Is_Removed_from_Program_Plan__c) {
                    tempAoe.isNew = false;
                    tempAoe.isAdded = true;
                    rightAreaOfExpertiseMap.put(aoe.id, tempAoe);    
                } else {
                    tempAoe.isNew = false;
                    tempAoe.isAdded = false;    
                }
            } else {
                tempAoe.isNew = true;
                tempAoe.isAdded = false;
            }  
        }
        
        Map<String, List<AreaOfExpertise>> mapCategoryToAreaOfExpertises = new Map<String, List<AreaOfExpertise>>();
        for (AreaOfExpertise aoe : leftAreaOfExpertiseMap.values()) {
            for (String category : aoe.category) {
                if (mapCategoryToAreaOfExpertises.containsKey(category)) {
                    List<AreaOfExpertise> areaOfExpertises = new List<AreaOfExpertise>();
                    areaOfExpertises = mapCategoryToAreaOfExpertises.get(category);
                    areaOfExpertises.add(aoe);
                    mapCategoryToAreaOfExpertises.put(category, areaOfExpertises );            
                } else {
                    mapCategoryToAreaOfExpertises.put(category, new List<AreaOfExpertise>{aoe});    
                }
            }
        }
        leftAOECategories = new List<String>();
        leftAOECategories.addAll(mapCategoryToAreaOfExpertises.keySet());
        leftAOECategories.sort();
        //System.debug('sorted categories : ' + JSON.serialize(leftAOECategories));
        leftAoEId = new List<String>();
        //System.debug('mapCategoryToAreaOfExpertises : ' + JSON.serializepreety(mapCategoryToAreaOfExpertises));
        List<String> oddCategories = new List<String>();
        for (String aoeCategory : leftAOECategories) {
            for (AreaOfExpertise aoe : mapCategoryToAreaOfExpertises.get(aoeCategory)) {
                if (!aoe.areaOfExpertiseRecord.category__c.contains(';')) {
                    if (!leftAoEId.contains(aoe.areaOfExpertiseRecord.id)) {
                        leftAoEId.add(aoe.areaOfExpertiseRecord.id);
                    }
                } else {
                    if( !oddCategories.contains(aoe.areaOfExpertiseRecord.id) ) {
                        oddCategories.add(aoe.areaOfExpertiseRecord.id);
                    }
                }
            }
        }
        for (String aoeId : oddCategories ) {
            if (!leftAoEId.contains(aoeId) ) {
                leftAoEId.add(aoeId);       
            }
        }
        
        // S-38295: Tempo: Learning order for MSN_RN Pool of Courses
        // Order by Category if is MSN_RN program
        try {
            if (isMSN_RNProgram(programCode)) {
                aoeIdaoeMap = new Map<String, Area_of_Expertise__c>();
                List<Area_Of_Expertise__c> aoeList = [SELECT Id, Name, category__c FROM Area_Of_Expertise__c WHERE id IN :leftAoEId];
                for (Area_Of_Expertise__c aoe : aoeList) {
                    if (!aoeIdaoeMap.containsKey(aoe.Id)) {
                        aoeIdaoeMap.put(aoe.Id, aoe);
                    }
                }
                orderedCategoriesList = new List<String>();
                addIdsToListByCategory(aoeIdaoeMap, 'General Education');
                addIdsToListByCategory(aoeIdaoeMap, 'General Education;General Elective');
                addIdsToListByCategory(aoeIdaoeMap, 'Core;General Elective');
                addIdsToListByCategory(aoeIdaoeMap, 'General Elective');
                if (!aoeIdaoeMap.isEmpty()) {
                    for (String aoeId : aoeIdaoeMap.keySet()) {
                        orderedCategoriesList.add(aoeId);
                    }
                }
                leftAoEId = new List<String>();
                leftAoEId = orderedCategoriesList;
        	}
        } catch(Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        
        //Custom Settings to retrive Brand Conf Record ID to display Header and Body for Model Window        
        mapCategoryToAreaOfExpertises = new Map<String, List<AreaOfExpertise>>();
        for (AreaOfExpertise aoe : rightAreaOfExpertiseMap.values() ) {
            for (String category : aoe.category) {
                if (mapCategoryToAreaOfExpertises.containsKey(category)) {
                    List<AreaOfExpertise> areaOfExpertises = new List<AreaOfExpertise>();
                    areaOfExpertises = mapCategoryToAreaOfExpertises.get(category);
                    areaOfExpertises.add(aoe);
                    mapCategoryToAreaOfExpertises.put(category, areaOfExpertises );            
                } else {
                    mapCategoryToAreaOfExpertises.put(category, new List<AreaOfExpertise>{aoe});    
                }
            }
        }
        
        List<String> rightAOECategories = new List<String>();
        rightAOECategories.addAll(mapCategoryToAreaOfExpertises.keySet());
        rightAOECategories.sort();
        rightAoEId = new List<String>();
        oddCategories = new List<String>();
        for (String aoeCategory : rightAOECategories) {
            for (AreaOfExpertise aoe : mapCategoryToAreaOfExpertises.get(aoeCategory)) {
                if(!aoe.areaOfExpertiseRecord.category__c.contains(';')) {
                    if( !rightAoEId.contains(aoe.areaOfExpertiseRecord.id) ) {
                        rightAoEId.add(aoe.areaOfExpertiseRecord.id);
                    }
                } else {
                    if( !oddCategories.contains(aoe.areaOfExpertiseRecord.id) ) {
                        oddCategories.add(aoe.areaOfExpertiseRecord.id);
                    }
                }
            }
        }
        for (String aoeId : oddCategories ) {
            if (!rightAoEId.contains(aoeId) ) {
                rightAoEId.add(aoeId);      
            }  
        }
        
        Community_Site_Settings__c defaultCustomSetngs = Community_Site_Settings__c.getValues('Default Settings');
        if (defaultCustomSetngs != null ) {
            Brand_Configuration__c BC = [Select id,name,Sub_Type__c,Body__c from Brand_Configuration__c where id = :defaultCustomSetngs.RecordID__c];
            modalHeader = BC.Sub_Type__c;
            modalBody = BC.Body__c;
            intercomAppId = defaultCustomSetngs.Intercom_App_Id__c ;

        }
        //displayModalWindow();
        }catch(Exception e) {
            System.debug(System.LoggingLevel.ERROR, 'Exception at line ' +  e.getLineNumber() + ', ' + e.getMessage());
            throw e;
        }
    }
    
    /*
     * S-38295: Tempo: Learning order for MSN_RN Pool of Courses 
     * Helper method to order AoEs by category
	 */ 
    private void addIdsToListByCategory(Map<String, Area_of_Expertise__c> aoeMap, String category) {
        for (String aoeId : aoeMap.keySet()) {
            if (aoeMap.get(aoeId).Category__c == category) {
                orderedCategoriesList.add(aoeId);
            }
        }
        for (String id : orderedCategoriesList) {
            aoeIdaoeMap.remove(id);
        }
    }    
    
    //This method controlls the modal content window based on agreed to credits on SP 
    public void displayModalWindow() {
        if (sProg != null) {
            if (sProg.Current_Student_Subscription__r.Agreed_To_Credits__c != null &&
                    sProg.Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c == null && sProg.Program__r.Automate_Agree_to_Credit__c == False) {
                isModalWindow = true;
            } else {
                isModalWindow = false;
            }
        }
    }
    
    
    
    //this method will be called when the '-' button is clicked on the left side    
    public void removeAreaOfExpertise() {
        String selectedAreaOfExprtise_p = Apexpages.currentPage().getParameters().get('selectedExpertiseIdToRemove');
        leftAreaOfExpertiseMap.get(selectedAreaOfExprtise_p ).isAdded = false;
        if( !rightAreaOfExpertiseMap.get(selectedAreaOfExprtise_p ).isNew ) {
            removedAreaOfExpertises.put(selectedAreaOfExprtise_p, leftAreaOfExpertiseMap.get(selectedAreaOfExprtise_p ));
        }

        rightAreaOfExpertiseMap.remove(selectedAreaOfExprtise_p );
        Integer count = 0;
        List<Integer> aoeIdsToRemove = new List<Integer>();
        for(  String idToremove : rightAoEId  ) {
            if( idToremove == selectedAreaOfExprtise_p ) {
                aoeIdsToRemove.add(count);
            }
            count++;
        }
        for(Integer countToRemove :  aoeIdsToRemove) {
            rightAoEId.remove(countToRemove);    
        }
        
    }
    
    //this method will be called when the '+' button is clicked on the left side
    public PageReference addAreaOfExpertise() {
       // try {
        String selectedAreaOfExprtise_p  = Apexpages.currentPage().getParameters().get('selectedExpertiseIdToAdd');
        leftAreaOfExpertiseMap.get(selectedAreaOfExprtise_p).isAdded = true;
        if( !leftAreaOfExpertiseMap.get(selectedAreaOfExprtise_p ).isNew && 
             leftAreaOfExpertiseMap.get(selectedAreaOfExprtise_p).areaOfExpertiseRecord.Student_Expertise__r[0].Is_Removed_from_Program_Plan__c) {
            //leftAreaOfExpertiseMap.get(selectedAreaOfExprtise_p).areaOfExpertiseRecord.Student_Expertise__r[0].Is_Removed_from_Program_Plan__c = false; 
            removedAreaOfExpertises.put(selectedAreaOfExprtise_p, leftAreaOfExpertiseMap.get(selectedAreaOfExprtise_p ));
        }
        rightAreaOfExpertiseMap.put(selectedAreaOfExprtise_p,leftAreaOfExpertiseMap.get(selectedAreaOfExprtise_p )); 
        //rightAoEId.add(selectedAreaOfExprtise_p);
        if( removedAreaOfExpertises.containsKey(selectedAreaOfExprtise_p) ) {
            removedAreaOfExpertises.put(selectedAreaOfExprtise_p, leftAreaOfExpertiseMap.get(selectedAreaOfExprtise_p ));
        }
        
        Map<String, List<AreaOfExpertise>> mapCategoryToAreaOfExpertises = new Map<String, List<AreaOfExpertise>>();
        for( AreaOfExpertise aoe : rightAreaOfExpertiseMap.values() ) {
            for( String category : aoe.category) {
                if( mapCategoryToAreaOfExpertises.containsKey(category) ) {
                    List<AreaOfExpertise> areaOfExpertises = new List<AreaOfExpertise>();
                    areaOfExpertises = mapCategoryToAreaOfExpertises.get(category);
                    areaOfExpertises.add(aoe);
                    mapCategoryToAreaOfExpertises.put(category, areaOfExpertises );            
                } else {
                    mapCategoryToAreaOfExpertises.put(category, new List<AreaOfExpertise>{aoe});    
                }
            }
        }
        
        List<String> rightAOECategories = new List<String>();
        rightAOECategories.addAll(mapCategoryToAreaOfExpertises.keySet());
        rightAOECategories.sort();
        //System.debug('sorted categories : ' + JSON.serialize(leftAOECategories));
        rightAoEId = new List<String>();
        //System.debug('mapCategoryToAreaOfExpertises : ' + JSON.serializepreety(mapCategoryToAreaOfExpertises));
        List<String> oddCategories = new List<String>();
        for( String aoeCategory : rightAOECategories) {
            for( AreaOfExpertise aoe : mapCategoryToAreaOfExpertises.get(aoeCategory)) {
                if(!aoe.areaOfExpertiseRecord.category__c.contains(';')) {
                    if( !rightAoEId.contains(aoe.areaOfExpertiseRecord.id) ) {
                        rightAoEId.add(aoe.areaOfExpertiseRecord.id);
                    }
                } else {
                    if( !oddCategories.contains(aoe.areaOfExpertiseRecord.id) ) {
                        oddCategories.add(aoe.areaOfExpertiseRecord.id);
                    }
                }
            }
        }
        for(String aoeId : oddCategories ) {
            if(!rightAoEId.contains(aoeId) ) {
                rightAoEId.add(aoeId);      
            }  
        }
        //rightAoEId.addAll(oddCategories);
    /*    } catch(Exception e) {
            debugString = 'Exception: ' + e.getMessage();
        }*/
        return null;   
    }
    
    //this method will be called when save button is clicked     
    public PageReference saveCompetencies() {
        List<Student_Expertise__c> studentExpertiesToUpdate = new List<Student_Expertise__c>();
        List<Student_Expertise__c> stuExp = new List<Student_Expertise__c>();
        List<student_competency__c> stuCOmp = new List<student_competency__c>();
        
        System.debug(removedAreaOfExpertises);        
        if (!removedAreaOfExpertises.isEmpty()) {
            for(AreaOfExpertise aoe : removedAreaOfExpertises.values()) {
                if (!aoe.isNew) {
                    if (!aoe.areaOfExpertiseRecord.Student_Expertise__r[0].Is_Removed_from_Program_Plan__c) {
                        aoe.areaOfExpertiseRecord.Student_Expertise__r[0].Is_Removed_from_Program_Plan__c = true; 
                        stuExp.add(aoe.areaOfExpertiseRecord.Student_Expertise__r[0]);                        
                    } else {
                        aoe.areaOfExpertiseRecord.Student_Expertise__r[0].Is_Removed_from_Program_Plan__c = false;
                    }
                    studentExpertiesToUpdate.add(aoe.areaOfExpertiseRecord.Student_Expertise__r[0]);
                }  
            }            
            
            if (!stuExp.isEmpty()) {
            	stuCOmp= [select id,name,clp_active__c from student_competency__c where student_expertise__c IN : stuExp];
                for(student_competency__c  sc: stuCOmp) {
                	sc.clp_active__c= false;
                }
            }
            
            if (!stuCOmp.isEmpty() ) {
                update stuCOmp;
            }
            
            if (!studentExpertiesToUpdate.isEmpty() ) {
                update studentExpertiesToUpdate;
            }
        }
        List<Area_of_Expertise__c> areaOfExpertisesToProcess = new List<Area_of_Expertise__c>();
        for( AreaOfExpertise aoe : rightAreaOfExpertiseMap.values() ) {
            if( aoe.isNew ) {
                areaOfExpertisesToProcess.add(aoe.areaOfExpertiseRecord);       
            }    
        }
        
        System.debug(areaOfExpertisesToProcess.size());

        processNewlyAddedAreaOfExpertises(areaOfExpertisesToProcess);
       
        PageReference myTermPage;
        if (isMSN_RNProgram(programCode)) {
            myTermPage = new PageReference('/apex/ProgramOverview');
        } else {
        	myTermPage = new PageReference('/apex/myprogramUnderGrad');    
        }
        
        myTermPage.setRedirect(true);
        return myTermPage;
    }
    
    public PageReference editMyProgramCancel() {
        PageReference myTermPage;
        if (isMSN_RNProgram(programCode)) {
            myTermPage = new PageReference('/apex/ProgramOverview');
        } else {
        	myTermPage = new PageReference('/apex/myprogramUnderGrad');    
        }
        
        myTermPage.setRedirect(true);
        return myTermPage;
    }
    
    public void processNewlyAddedAreaOfExpertises(List<Area_of_Expertise__c> areaOfExpertisesToProcess) {
        List<Student_Competency__c> scList = new List<Student_Competency__c>();
	    setCBLRecordTypes = Utility.getRecordTypeFromCBLCustomSetting(Student_Expertise__c.sObjectType.getDescribe());
        Map<Id, student_expertise__c> areaOfExpertiseIdToStudentExpertise = new Map<Id, student_expertise__c>();
        
        for (Area_of_Expertise__c aoe : areaOfExpertisesToProcess ) {
            student_expertise__c se = new  student_expertise__c(
                                            Student_Program__c = sProg.id,
                                            Area_of_Expertise__c = aoe.Id,
                                            Contact__c = sProg.Student__c,
                                            Is_Added_from_Program_Plan__c = True
                                           //Opportunity__c = sProg.Application__c
            ); 
            If(!setCBLRecordTypes.isEmpty()){
                    List<Id> stuExpRecordTypeIdList = new List<id>();
                    stuExpRecordTypeIdList.addAll(setCBLRecordTypes);
                    se.recordTypeId = stuExpRecordTypeIdList[0];

                }
            se.Is_Pre_Req_Lock__c  = (!aoe.Pre_requisite_Rules__r.isEmpty())? true:false;     
            areaOfExpertiseIdToStudentExpertise.put(aoe.id, se);
        }
        
        insert areaOfExpertiseIdToStudentExpertise.values();
        System.debug( 'areaOfExpertiseIdToStudentExpertise : ' + areaOfExpertiseIdToStudentExpertise);
        setStudentCompRecType = Utility.getRecordTypeFromCBLCustomSetting(Student_Competency__c.sObjectType.getDescribe());
        for (Area_of_Expertise__c aoe : areaOfExpertisesToProcess) {
            for (Competency_Expertise__c ce: aoe.Competencies__r ) {
                Student_Competency__c sc = new Student_Competency__c(
                    Student_Expertise__c = areaOfExpertiseIdToStudentExpertise.get(aoe.id).Id,
                    Competency__c = ce.competency__C ,
                    Contact__c = sProg.Student__c,
                    //Opportunity__c = sProg.Application__c,
                    Status__c = 'Registered',
                    CLP_Active__c = false,
                    Student_Program__c= sProg.Id);
                if (ce.competency_code__c != null) {
                    sc.Learning_Order__c = Integer.valueOf(ce.competency_code__c.substring(Math.max(ce.competency_code__c.length() - 2, 0)));
                }
                if (!setStudentCompRecType.isEmpty()) {
                    List<Id> setStudentCompRecTypeIdList = new List<id>();
                    setStudentCompRecTypeIdList.addAll(setStudentCompRecType);
                    sc.recordTypeId = setStudentCompRecTypeIdList[0];
                }      
                scList.add(sc);
            }  
        }
        System.debug('scList : ' + scList); 
        insert scList;     
        
        List<Pre_requisite_Rules__c> prrList = new List<Pre_requisite_Rules__c>();
        for( Area_of_Expertise__c aoe : areaOfExpertisesToProcess ) {
            for(Pre_requisite_Rules__c aoePrrObj: aoe.Pre_requisite_Rules__r){
                    Pre_requisite_Rules__c sePrrObj = new Pre_requisite_Rules__c(
                            Student_Expertise__c = areaOfExpertiseIdToStudentExpertise.get(aoe.id).Id,
                            Course_Name__c = aoePrrObj.Course_Name__c
                            );
              
                    prrList.add(sePrrObj);
              
            }  
        }
        System.debug('prrList:' + prrList); 
        insert prrList;           
    }
    
    public class AreaOfExpertise {
        public Area_of_Expertise__c areaOfExpertiseRecord{get;set;}
        public Boolean isAdded{get;set;}
        public List<String> category{get;set;}
        public Boolean isNew{get;set;}
        public String overview{get;set;}
    }
    
}