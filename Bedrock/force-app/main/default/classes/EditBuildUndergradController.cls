/*******************************************************************
Name  : EditBuildUndergradController 
Author: Ravitej Varada (Laureate)
Date  : March  5, 2018
Description: Controller extension class for EditBuildUndergrad Page

Revision History 
Horacio Sanchez - 10/23/2020 - S-28149 Added logic when a competency is removed from the right side to also update the Cancel/Save buttons
Horacio Sanchez - 11/04/2020 - S-30862: Do not Allow students to remove Open competency, unless it is paused
* Ravitej Varada    07/28/2021       40082: Tempo:  WOW competency update
* Horacio Sanchez   05/24/2022     S-89059 Update Tempo Portal Navigation Menu if ATC Start Date is Today
* Horacio Sanchez   06/15/2022     S-89068: CLP minimum credits logic for students entering their final subscription term
*************************************************************************/

public with sharing class EditBuildUndergradController{

    public Student_Program__c sProgram { get; set; }
    public map<Decimal, String> Message_order = new map<Decimal, String>();
    public Id studentProgramId;
    public List<Student_Competency__c> studentComps { get; set; }
    //public List<compCardDetails> leftCompCards { get; set; }
    public List<compCardDetails> rightCompCards { get; set; }
    public Set<String> selectedComps;
    public Set<String> deselectedComps;
    public Date startDate { get; set; }
    public Date endDate { get; set; }
    public String studentName { get; set; }
    public Double credit_progression_rate { get; set; }
    public Double credit_sum { get; set; }
    public Boolean save_Flag { get; set; }
    private set<Student_Competency__c> addStudentCompetencies;
    private set<Student_Competency__c> removeStudentCompetencies;
    public String message { get; set; }
    public Boolean firstClick;
    public boolean secondClick;
    public boolean thirdClick;
    public List<customMap> allExpertiseWiseCompetencies { get; set; }
    public List<customMap> addedExpertiseWiseCompetencies { get; set; }
    public string modalHeader { get; set; }
    public string modalBody { get; set; }
    public Boolean isModalWindow { get; set; }
    public String currentUserId { get; set; }
    public String contactId {get;set;}
    public String waldenEmail { get; set; }
    public String waldenEmailHash { get; set; }    
    public String intercomAppId { get; set; }
    public Map<String, AreaOfExpertiseWrapper> nameToAreaOfExpertiseWrapperLeft { get; set; }
    public Map<String, AreaOfExpertiseWrapper> nameToAreaOfExpertiseWrapperRight { get; set; }
    public String degreeLevel { get; set; }
    public string ChkMapKey{get;set;}
    public Boolean isATCCompleted {get;set;}
    
    Boolean isCommunityUser() {
        if('Customer Community Login'.equals( ([ Select UserLicense.Name  FROM Profile WHERE Id =: userinfo.getProfileid()]).UserLicense.Name) ) {
            return true;
        } else {
            return false;
        }
    }    
    
    public EditBuildUndergradController(ApexPages.StandardController controller) {
        ChkMapKey = '';
        //Retrieve Current User Active student Program ID from contact
        if (!isCommunityUser()) {
            studentProgramId = ApexPages.currentPage().getParameters().get('id');
        } else {
            currentUserId = UserInfo.getUserId();
            User user = [SELECT Id, ContactId FROM User WHERE Id = :currentUserId];
            Contact contact = [
                    SELECT Id,walden_Email__c,name, (
                            SELECT Id, Program__r.Degree_Level__c
                            FROM Student_Programs__r
                            WHERE IsStudentProgramActive__c = true
                            LIMIT 1
                    )
                    FROM CONTACT
                    WHERE Id = :user.ContactId
            ];
            contactId= contact.id;
            studentName = contact.name;
            waldenEmail = contact.walden_Email__c;
            waldenEmailHash = HmacSHA256Encryption.generateHmacSHA256Signature(waldenEmail); 
            ApexPages.currentPage().getParameters().put('id', contact.Student_Programs__r[0].id);
            ApexPages.currentPage().getParameters().get('id');
            studentProgramId = ApexPages.currentPage().getParameters().get('id');
            degreeLevel = contact.Student_Programs__r[0].Program__r.Degree_Level__c;
        }
        isModalWindow = false;
        system.debug('Student program id is:' + studentProgramId);
        selectedComps = new Set<String>() ;
        deselectedComps = new Set<String>() ;
        this.sProgram = [
                SELECT Name,Program__r.Automate_Agree_to_Credit__c, Student_Full_Name__c, Current_Student_Subscription__c, CurrentSubscriptionStartDate__c, CurrentSubscriptionEndDate__c,
                        Renewal_Denied__c, Renewal_Denied_Comment__c, Number_of_Enrolled_Terms__c,Competencies_Completed_in_Trial__c,
                        Number_of_Competencies_Completed__c, IsStudentProgramActive__c, Id, Application__c, Number_of_Competencies_Transferred__c,Program__c,
                        Number_of_Competencies__c,Application__r.Admissions_Contingency__c, Total_attempted_credits__c, Number_Credits_Completed_in_all_Terms__c,
                        Number_of_Credits_Completed_in_Trial__c,Number_of_Credits_TransferredFulfilled__c,SAP_Code__c, Previous_SAP_Code__c,
                        Current_Student_Subscription__r.Agreed_To_Credits__c,Current_Student_Subscription__r.Number_of_Credits_Completed__c,
                        Student__r.Name,Credit_Progression_Rate__c, Program__r.Name, Current_Student_Subscription__r.Start_Date__c,
                        Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c, First_Start_Date__c, (
                        SELECT ID, Competency__c, competency__r.Description__c, Student_Program__c,
                            Status__c, IsCompleted__c,Student_Expertise__r.Area_of_Expertise__r.Overview__c,Assessment_Submitted__c,Pause_Competency__c,
                                competency_title__c, Competency_Credit_Equivalency__c, Student_Expertise__r.Program_Expertise__r.Overview__c,
                                Student_Expertise__r.Is_Removed_from_Program_Plan__c,Student_Expertise__r.Program_Expertise__r.Learning_Order__c,Program_Competency__r.Program_Expertise__r.Category__c,
                                Program_Competency__r.Program_Expertise__r.Pseudo_Course__c,Student_Expertise__r.Audit_Category__c,Student_Expertise__r.Is_Not_Available_for_Student__c,
                                Competency_Code__c,competency__r.Assessment_Type__c,SME__c,SME__r.Name, Description__c, clp_active__c, Area_Of_Expertise_Name__c, Student_Expertise__r.Area_of_Expertise__r.Display_On_Web__c
                        FROM Student_Competencies__r
                        WHERE Is_Enrolled__c = true AND Student_Expertise__r.Area_of_Expertise__r.Display_On_Web__c = TRUE AND Student_Expertise__r.Is_Removed_from_Program_Plan__c = FALSE
                        ORDER BY Learning_Order__c NULLS LAST, Competency_Code__c 
                )
                FROM Student_Program__c
                WHERE Id = :studentProgramId
        ];
        addStudentCompetencies = new set<Student_Competency__c>();
        removeStudentCompetencies = new set<Student_Competency__c>();
        credit_progression_rate = sProgram.Credit_Progression_Rate__c;
        startDate = sProgram.CurrentSubscriptionStartDate__c;
        endDate = sProgram.CurrentSubscriptionEndDate__c ;
        getLeftCompCards(this.sProgram.Student_Competencies__r);
        credit_sum = 0.0;
        getRightCompCards(this.sProgram.Student_Competencies__r);
        setSaveFlag();
        firstClick = false;
        secondClick = false;
        thirdClick = false;
        createMessageMap();
        getMessageFirstLoad();
        //Custom Settings to retrive Brand Conf Record ID to display Header and Body for Model Window
        
        Community_Site_Settings__c defaultCustomSetngs = Community_Site_Settings__c.getValues('Default Settings');
        if (defaultCustomSetngs != null) {
            Brand_Configuration__c BC = [Select id,name,Sub_Type__c,Body__c from Brand_Configuration__c where id = :defaultCustomSetngs.RecordID__c];
            modalHeader = BC.Sub_Type__c;
            modalBody = BC.Body__c;
            intercomAppId = defaultCustomSetngs.Intercom_App_Id__c ;
        }
        
        isATCCompleted = true;
        // S-89059: Update Tempo Portal Navigation Menu if ATC Start Date is Today
        // Checking if Agree to Credits process has been completed
        if (sProgram.Current_Student_Subscription__c != null 
            && (sProgram.Current_Student_Subscription__r.Agreed_To_Credits__c == null || sProgram.Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c == null) 
            && sProgram.Program__r.Automate_Agree_to_Credit__c
            && sProgram.Current_Student_Subscription__r.Start_Date__c.daysBetween(Date.today()) < 14) {
            isATCCompleted = false;
        }
        //displayModalWindow();
        
        // S-89068
        calculateMinimumCredits();
    }
    
    /*
     * S-89068: CLP minimum credits logic for students entering their final subscription term
     */
    public void calculateMinimumCredits() {
        Double totalCreditsAvailableInCompetencies = 0.0;
        for (CustomMap cp : allExpertiseWiseCompetencies) {
            for (AreaOfExpertiseWithCompetencies aoe : cp.value1) {
                if (aoe.competency.Status == 'Registered' || aoe.competency.Status == 'Assessment Submitted' || aoe.competency.Status == 'Not-Achieved' || aoe.competency.Status == 'Returned for Resubmission' || aoe.competency.Status == 'Not Enrolled') {
                    totalCreditsAvailableInCompetencies += aoe.competency.creditEquivilant;
                }
            }
        }
        
        if (totalCreditsAvailableInCompetencies < credit_progression_rate) {
            credit_progression_rate = totalCreditsAvailableInCompetencies;
        }
    }

    // If Graduate student tries to access Edit/Build for UG, it will be redirected to Graduate page.
    public PageReference degreeLevelCheck() {
        if (degreeLevel == 'Graduate') {
            PageReference myGraduatePage = new PageReference('/EditBuild');
            myGraduatePage.setRedirect(true);
            return myGraduatePage;
        }
        return null;
    }
	
    //This method controlls the modal content window based on agreed to credits on SP 
    public void displayModalWindow() {
        system.debug('displayModalWindow');
        
        if (sProgram != null) {
            if (sProgram.Current_Student_Subscription__r.Agreed_To_Credits__c != null &&
                sProgram.Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c == null && sProgram.Program__r.Automate_Agree_to_Credit__c == False ) {
                    isModalWindow = true;
                } else {
                    isModalWindow = false;
                }
        }
        system.debug('isModalWindow' + isModalWindow);
    }

    //This method updates the Date_Student_Agreed_To_Credits__c field  when "Agreed to credit Equavalence" Button is clicked.
    public void updateAgreedToCreditsDate() {
        Student_Subscription__c studentSubscription = new Student_Subscription__c(id = sProgram.Current_Student_Subscription__c);
        studentSubscription.Date_Student_Agreed_To_Credits__c = date.today();
        update studentSubscription;
        isModalWindow = false;
    }

    //This method creates map of messages to be displayed
    public void createMessageMap() {
        try {
            List<Brand_Configuration__c> messageList = new List<Brand_Configuration__c>([SELECT Id, Body__c,display_order__c FROM Brand_Configuration__c where type__c = 'Messages' and sub_type__c = 'CLP Status Messages']);
            if (messageList != null) {
                for (Brand_Configuration__c itr : messageList) {
                    Message_order.put(itr.display_order__c, itr.Body__c);
                }
            }
        } catch (Exception exp) {
            system.debug(exp);
        }
    }

    //this method returns the message to be displayed when page is loaded for the first time
    public String getMessageFirstLoad() {
        try {
            if (save_Flag) {
                message = Message_order.get(5);
            } else {
                message = Message_order.get(1);
            }
        } catch (Exception exp) {
            system.debug(exp);
        }
        return message;
    }

    //this method sets the flag to enable/disable the save button
    public void setSaveFlag() {
        try {
            if (credit_sum >= credit_progression_rate) {
                save_Flag = true;
            } else {
                save_Flag = false;
            }
        } catch (Exception exp) {
            system.debug(exp);
        }
    }

    //this method returns the competencies to be displayed on the left side
    public void getLeftCompCards(list<Student_Competency__c> studentCompetencies) {
        list<compCardDetails> leftCompCards = new list<compCardDetails>();
        leftCompCards = buildCompCards(leftCompCards, studentCompetencies);
        allExpertiseWiseCompetencies = buildCompetenciesByExpertise(leftCompCards,'left');
        System.debug('allExpertiseWiseCompetencies : ' + json.serializepretty(allExpertiseWiseCompetencies));
        //return leftCompCards;  
    }

    List<compCardDetails> buildCompCards(List<compCardDetails> compCards, List<Student_Competency__c> studentCompetencies) {
        try {
            compCards = new list<compCardDetails>();

            if (studentCompetencies != null) {

                Set<String> S1 = new Set<String>();
                for (Student_Competency__c sc : studentCompetencies) {
                    S1.add(sc.Competency_Code__c);
                }

                Map<String, Id> CompCodeId = new Map<String, Id>();
                Set<String> S2 = new Set<String>();
                for (Competency__c sc : compLst(s1)) {
                    CompCodeId.put(sc.Code__c, sc.ID);
                    S2.add(sc.ID);
                }

                Map<String, String> compSyllabus = new Map<String, String>();
                for (competency__c itr : compLst(s1)) {
                    compSyllabus.put(itr.code__c, itr.syllabus_link__c);
                }

                String difficultlevel;
                compCards = new List<compCardDetails>();
                System.debug('&&&&&&&studentCompetencies : ' + studentCompetencies);
                for (Student_Competency__c sc : studentCompetencies) {
                    compCardDetails compCardObject = new compCardDetails();
                    System.debug('&&&&&&&sc : ' + sc);
                    compCardObject.CompetencyCode = sc.Competency_Code__c;
                    compCardObject.CreditEquivilant = sc.Competency_Credit_Equivalency__c;
                    compCardObject.CompetencyName = sc.competency_title__c;
                    compCardObject.SMEAssignment = sc.SME__r.Name;
                    compCardObject.isAssessmentSubmitted = sc.Assessment_Submitted__c;
        			compCardObject.isCompetencyPaused = sc.Pause_Competency__c;
                    compCardObject.CompetencyDesc = sc.competency__r.Description__c;
                    compCardObject.aoeLearningOrder = Integer.valueOf(sc.Student_Expertise__r.Program_Expertise__r.Learning_Order__c);
                    compCardObject.category = sc.Program_Competency__r.Program_Expertise__r.Category__c;
                    if (sc.Status__c == 'Not Achieved') {
                        sc.Status__c = 'Not-Achieved';
                    }
                    compCardObject.Status = sc.Status__c;
                    compCardObject.areaOfExpertiseDescription = sc.Student_Expertise__r.Area_of_Expertise__r.Overview__c;
                    System.debug('compCardObject.areaOfExpertiseDescription : ' + compCardObject.areaOfExpertiseDescription);
                    compCardObject.isCompleted = sc.isCompleted__c;
                    compCardObject.AreaOfExpertise = sc.Area_Of_Expertise_Name__c;
                    compCardObject.clpActive = sc.clp_active__c;
                    compCardObject.AssessmentType = sc.competency__r.Assessment_Type__c;
                    compCardObject.isNotAvailableForStudent = sc.Student_Expertise__r.Is_Not_Available_for_Student__c;

                    if( String.isNotBlank(sc.Student_Expertise__r.Audit_Category__c) ) {
                        compCardObject.category = sc.Student_Expertise__r.Audit_Category__c;
                    }
                    
                    compCardObject.SyllabusLink = compSyllabus.get(sc.Competency_Code__c);
                    if (sc.clp_active__c == true) {
                        compCardObject.visible_flag = false;
                    } else {
                        compCardObject.visible_flag = true;
                    }
                    compCards.add(compCardObject);
                }
            }


        } catch (Exception exp) {
            system.debug(exp);
        }
        return compCards;
    }
    
    /**/
    List<customMap> buildCompetenciesByExpertise(List<compCardDetails> compCards, String section) {
        ChkMapKey = '';
        Map<String, List<AreaOfExpertiseWithCompetencies>> expertiseWiseCompetencies_p = new Map<String, List<AreaOfExpertiseWithCompetencies>>();
        Map<Integer, String> learningOrderToAOEName = new Map<Integer, String>();
        if (section == 'left') {
            nameToAreaOfExpertiseWrapperLeft = new Map<String, AreaOfExpertiseWrapper>();
        } else {
            nameToAreaOfExpertiseWrapperRight = new Map<String, AreaOfExpertiseWrapper>();
        }
        Integer count = 1000000;
        for (compCardDetails compCard : compCards) {
            if (String.isNotBlank(compCard.areaOfExpertise)) {
                if (expertiseWiseCompetencies_p.containsKey(compCard.areaOfExpertise)) {
                    AreaOfExpertiseWrapper aoeWrapper = new AreaOfExpertiseWrapper();
                    aoeWrapper.areaOfExpertiseDescription = compCard.areaOfExpertiseDescription;
                    List<AreaOfExpertiseWithCompetencies> aoeWithCompetencies = expertiseWiseCompetencies_p.get(compCard.AreaOfExpertise);
                    System.debug('compCard : ' + compCard);
                    System.debug('compCard.areaOfExpertiseDescription: ' + compCard.areaOfExpertiseDescription);
                    aoeWithCompetencies.add(new AreaOfExpertiseWithCompetencies(compCard.areaOfExpertiseDescription, compCard));
                    expertiseWiseCompetencies_p.put(compCard.AreaOfExpertise, aoeWithCompetencies);
                    if (section == 'left') {
                        nameToAreaOfExpertiseWrapperLeft.get(compCard.areaOfExpertise).totalCount++;
                    } else {                        
                        nameToAreaOfExpertiseWrapperRight.get(compCard.areaOfExpertise).totalCount++;
                    }
                    
                    if (((compCard.SMEAssignment != null && compCard.SMEAssignment != '') || compCard.isAssessmentSubmitted) && !compCard.isCompetencyPaused && !compCard.isCompleted) {
                        nameToAreaOfExpertiseWrapperLeft.get(compCard.areaOfExpertise).hasActiveCompetency = true;
                    }
                    if (compCard.isNotAvailableForStudent) {
                        nameToAreaOfExpertiseWrapperLeft.get(compCard.areaOfExpertise).isNotAvailableForStudent = true;
                    }
                    
                    if (compCard.isCompleted) {
                        if (section == 'left') {
                            nameToAreaOfExpertiseWrapperLeft.get(compCard.areaOfExpertise).completedCount++;
                        } else {
                            nameToAreaOfExpertiseWrapperRight.get(compCard.areaOfExpertise).completedCount++;
                        }
                    }
                } else {
                    AreaOfExpertiseWrapper aoeWrapper = new AreaOfExpertiseWrapper();
                    aoeWrapper.areaOfExpertiseDescription = compCard.areaOfExpertiseDescription;
                    if (String.isNotBlank(compCard.category)) {
                        aoeWrapper.categoryLst = compCard.category.split(';');
                    }
                    if (compCard.aoeLearningOrder != null) {
                        learningOrderToAOEName.put(compCard.aoeLearningOrder, compCard.AreaOfExpertise);
                    } else {
                        learningOrderToAOEName.put( count, compCard.AreaOfExpertise);
                    }
                    count++;
                    AreaOfExpertiseWithCompetencies aoeWithCompetency = new AreaOfExpertiseWithCompetencies(compCard.areaOfExpertiseDescription, compCard);
                    expertiseWiseCompetencies_p.put(compCard.AreaOfExpertise, new List<AreaOfExpertiseWithCompetencies>{ aoeWithCompetency });
                    aoeWrapper.totalCount = 1;
                    if (compCard.isCompleted) {
                        aoeWrapper.completedCount = 1;
                    } else {
                        aoeWrapper.completedCount = 0;
                    }
                    
                    if (((compCard.SMEAssignment != null && compCard.SMEAssignment != '') || compCard.isAssessmentSubmitted) && !compCard.isCompetencyPaused && !compCard.isCompleted) {
                        aoeWrapper.hasActiveCompetency = true;
                    } else {
                        aoeWrapper.hasActiveCompetency = false;
                    }
                    
                    if (compCard.isNotAvailableForStudent) {
                        aoeWrapper.isNotAvailableForStudent = true;
                    } else {
                        aoeWrapper.isNotAvailableForStudent = false;
                    }
                    
                    if (section == 'left') {
                        nameToAreaOfExpertiseWrapperLeft.put(compCard.areaOfExpertise, aoeWrapper);
                    } else {
                        nameToAreaOfExpertiseWrapperRight.put(compCard.areaOfExpertise, aoeWrapper);
                       	ChkMapKey+=  compCard.areaOfExpertise + ',';                        
                    }
                }
            }
        }//end for loop 
        
        //ChkMapKey = string.valueof(nameToAreaOfExpertiseWrapperRight.values());        
        System.debug('learningOrderToAOEName: ' + learningOrderToAOEName);
        List<Integer> learningOrders = new List<Integer> (learningOrderToAOEName.keySet());
        learningOrders.sort();
        List<customMap> expertiseWiseCompetencies = new List<customMap>();
        for( Integer learningOrder : learningOrders) {
            System.debug('learningOrderToAOEName : ' + learningOrderToAOEName + '  Learning order : ' + learningOrder);
            customMap instance = new customMap();
            instance.key = learningOrderToAOEName.get(learningOrder);
            instance.value1 = expertiseWiseCompetencies_p.get(learningOrderToAOEName.get(learningOrder));
            if (instance.value1[0].competency.clpActive) {
                instance.isAdded = true;
            } else {
                instance.isAdded = false;
            }
            instance.key = learningOrderToAOEName.get(learningOrder);
            expertiseWiseCompetencies.add(instance);  
        }
        return expertiseWiseCompetencies;
    }
    //this method returns the competencies to be displayed on the right side
    public List<compCardDetails> getRightCompCards(list<Student_Competency__c> studentCompetencies_p) {
        //list<compCardDetails> rightCompCards = new list<compCardDetails>();
        list<Student_Competency__c> studentCompetencies = new List<Student_Competency__c>();
        for (Student_Competency__c studentCompetency : studentCompetencies_p) {
            if (studentCompetency.clp_active__c) {
                studentCompetencies.add(studentCompetency);
            }
        }
        rightCompCards = buildCompCards(rightCompCards, studentCompetencies);
        if( rightCompCards != null ) {
            addedExpertiseWiseCompetencies = buildCompetenciesByExpertise(rightCompCards,'right');
            for (compCardDetails itr : rightCompCards) {
                itr.visible_flag = true;
                if (itr.CreditEquivilant != null) {
                    if( !itr.isCompleted ) {
                        credit_sum = credit_sum + itr.CreditEquivilant;
                    }
                }
            }
        }
        return rightCompCards;
    }
   
    // Returns comp code and syllabus Link   From Competency__c
    Public List<Competency__c> compLst(set<string> S1) {
        If (!S1.isEmpty()) {
            List<Competency__c> compIDs = new List<Competency__c>([Select ID,Code__c,syllabus_link__c FROM Competency__c WHERE Code__c IN :S1]);
            return compIDs;
        }
        return null;
    }

    //this method will be called when the '+' button is clicked on the left side    
    public void addCompetencies() {
        try {
            String passedAOEId = Apexpages.currentPage().getParameters().get('compID');
            System.debug('passedAOEId in add : ' + passedAOEId);
             if( rightCompCards  == null) {
                rightCompCards = new list<compCardDetails>(); 
            }
            List<List<AreaOfExpertiseWithCompetencies>> competencies = new List<List<AreaOfExpertiseWithCompetencies>>();
            for( customMap mapInstance : allExpertiseWiseCompetencies ) {
                if( mapInstance.key == passedAOEId ) {
                    competencies.add(mapInstance.value1);
                    mapInstance.isAdded = true;
                }    
            }
            for (List<AreaOfExpertiseWithCompetencies> allCompCardDetails : competencies ) {
                for (AreaOfExpertiseWithCompetencies ccd : allCompCardDetails) {
                        System.debug('ccd in add : ' + ccd.competency.AreaOfExpertise );
                        compCardDetails newRightColumnComp = ccd.competency;
                               /* new compCardDetails(ccd.competency.ID, ccd.competency.CompetencyCode, ccd.competency.CreditEquivilant,
                                        ccd.competency.CompetencyName, ccd.competency.SMEAssignment, ccd.competency.CompetencyDesc,
                                        ccd.competency.AssessmentType, ccd.competency.SyllabusLink, ccd.competency.Status,
                                        ccd.competency.AreaOfExpertise,
                                        ccd.competency.areaOfExpertiseDescription,
                                        ccd.competency.aoeLearningOrder);*/
                        newRightColumnComp.visible_flag = true;
                        if (deselectedComps != null) {
                            if (deselectedComps.contains(ccd.competency.CompetencyCode)) {
                                deselectedComps.remove(ccd.competency.CompetencyCode);
                            }
                        }
                        selectedComps.add(ccd.competency.CompetencyCode);
                        rightCompCards.add(newRightColumnComp);
                        system.debug('ccd:' + ccd);
                        system.debug('ccd:' + ccd.competency.CreditEquivilant);
                        //ccd.competency.visible_flag = false;
                        if( !ccd.competency.isCompleted ) {
                            credit_sum += ccd.competency.CreditEquivilant;
                        }
                }
            }
            setSaveFlag();
            if (save_Flag) {
                message = Message_order.get(5);
            } else {
                if ((!firstClick) && (!secondClick) && (!thirdClick)) {
                    message = Message_order.get(2);
                    firstClick = true;
                } else if ((firstClick) && (!secondClick) && (!thirdClick)) {
                    message = Message_order.get(3);
                    firstClick = false;
                    secondClick = true;
                } else if ((!firstClick) && (secondClick) && (!thirdClick)) {
                    message = Message_order.get(4);
                    firstClick = false;
                    secondClick = false;
                }
            }
        } catch (Exception exp) {
            system.debug(exp);
        }
        system.debug('message:' + message);
        system.debug('After adding rightCompCards:' + json.serializepretty(rightCompCards));
        addedExpertiseWiseCompetencies = buildCompetenciesByExpertise(rightCompCards,'right');
    }

    public PageReference removeCompetencies() {
        List<List<AreaOfExpertiseWithCompetencies>> competencies = new List<List<AreaOfExpertiseWithCompetencies>>();
        List<compCardDetails> groupedLeftCompCards = new List<compCardDetails>();
        try {
            String passedAOEId = Apexpages.currentPage().getParameters().get('removedCompID');
            System.debug('passedAOEId : ' + passedAOEId );
            Integer count = 0;
            for( customMap mapInstance : allExpertiseWiseCompetencies ) {
                if( mapInstance.key == passedAOEId ) {
                    competencies.add(mapInstance.value1);
                    mapInstance.isAdded = false;
                    break;
                }  
            }
            
            for( customMap mapInstance : addedExpertiseWiseCompetencies ) {
                if( mapInstance.key == passedAOEId ) {
                    competencies.add(mapInstance.value1);
                    mapInstance.isAdded = false;
                    break;
                }  
                count++;
            }
            System.debug('count : ' + count);
            addedExpertiseWiseCompetencies.remove(count);
            System.debug('competencies : ' + JSON.serialize(competencies));
            for (List<AreaOfExpertiseWithCompetencies> allCompCardDetails : competencies ) {
                for (AreaOfExpertiseWithCompetencies ccdInstance : allCompCardDetails) {
                    
                    compCardDetails ccd = ccdInstance.competency;
                            /*new compCardDetails(ccdInstance.competency.ID, ccdInstance.competency.CompetencyCode, ccdInstance.competency.CreditEquivilant,
                                    ccdInstance.competency.CompetencyName, ccdInstance.competency.SMEAssignment, ccdInstance.competency.CompetencyDesc,
                                    ccdInstance.competency.AssessmentType, ccdInstance.competency.SyllabusLink, ccdInstance.competency.Status,
                                    ccdInstance.competency.AreaOfExpertise,
                                    ccdInstance.competency.areaOfExpertiseDescription,
                                    ccdInstance.competency.aoeLearningOrder);*/
                    if( selectedComps != null) {
                        if (selectedComps.contains(ccd.CompetencyCode)) {
                            selectedComps.remove(ccd.CompetencyCode);
                        }
                    }
                    deselectedComps.add(ccd.CompetencyCode);
                    //ccd.visible_flag = false;
                    system.debug('ccd:' + ccd.CreditEquivilant);
                    credit_sum -= ccd.CreditEquivilant;
                    if (credit_sum < 0) {
                        credit_sum = 0;
                    }
                    System.debug( 'credit_sum : ' + credit_sum ); 
                    groupedLeftCompCards.add(ccd);
                }
            }
            credit_sum = 0;
            system.debug('After rightCompCards:' + json.serializepretty(rightCompCards));
            List<compCardDetails> addedCompCards =  new List<compCardDetails>();
             for (compCardDetails addedCompCard : rightCompCards) {
                if (addedCompCard.areaOfExpertise != passedAOEId) {
                    if (!addedCompCard.isCompleted) {
                        credit_sum += addedCompCard.CreditEquivilant;
                    }
                    addedCompCards.add(addedCompCard);
                    //selectedComps.remove(addedCompCard.CompetencyCode);
                } else {
                    //deselectedComps.add(addedCompCard.CompetencyCode);
                }
            }
            
            rightCompCards = addedCompCards;
            setSaveFlag();
            if (save_Flag) {
                message = Message_order.get(5);
            } else {
                message = Message_order.get(1);
            }
        } catch (Exception exp) {
            system.debug(exp);
        }
        system.debug('message:' + message);
        addedExpertiseWiseCompetencies = buildCompetenciesByExpertise(rightCompCards,'right');

        return null;
    }


    //method called once the save button is clicked to save the competencies
    public PageReference saveCompetencies() {
        try {
            List<Student_Competency__c> IdCompetency = new List<Student_Competency__c>([
                    Select ID,
                            Competency_Code__c
                    From Student_Competency__c
                    where Student_Program__c = :sProgram.Id
            ]);
            Map<String, ID> compID = new Map<String, ID>();
            for (Student_Competency__c itr : IdCompetency) {
                compID.put(itr.competency_code__c, itr.ID);
            }
            list<Student_Competency__c> updateCompetencyList = new list<Student_Competency__c>();
            for (String itr : selectedComps) {
                ID idvalue = compID.get(itr);
                updateCompetencyList.add(new Student_Competency__c(id = idvalue, clp_active__c = true));
            }
            for (String itr : deselectedComps) {
                ID idvalue = compID.get(itr);
                updateCompetencyList.add(new Student_Competency__c(id = idvalue, clp_active__c = false));
            }
            system.debug('updateCompetencyList:' + updateCompetencyList);
            if (!updateCompetencyList.isEmpty()) {
                update updateCompetencyList;
            }

            PageReference myTermPage = new PageReference('/apex/mytermundergrad');
            myTermPage.setRedirect(true);
            return myTermPage;

        } catch (Exception exp) {
            system.debug(exp);
        }
        return null;
    }
    
    public PageReference editBuildUndergradCancel() {
        PageReference myTermPage = new PageReference('/apex/mytermundergrad');
        myTermPage.setRedirect(true);
        return myTermPage;
    }

    private class AreaOfExpertiseWrapper {
        public String areaOfExpertiseDescription { get; set; }
        public Integer totalCount { get; set; }
        public Integer completedCount { get; set; }
        public Boolean hasActiveCompetency { get; set; }
        public Boolean isNotAvailableForStudent { get; set; }
        public List<String> categoryLst { get; set;}

        
        public AreaOfExpertiseWrapper() {

        }

        public AreaOfExpertiseWrapper(String areaOfExpertiseDescription, Integer totalCount, Integer completedCount) {
            this.areaOfExpertiseDescription = areaOfExpertiseDescription;
            this.totalCount = totalCount;
            this.completedCount = completedCount;
        }
    }
    
    public class customMap {
        public String key{get;set;}
        public List<AreaOfExpertiseWithCompetencies> value1{get;set;}
        public Boolean isAdded {get; set;}
        public Boolean isNotAvailableForStudent {get;set;}
    }
    
    Public class AreaOfExpertiseWithCompetencies {
        public String aoeDescription { get; set; }
        public CompCardDetails competency { get; set; }

        public AreaOfExpertiseWithCompetencies() {

        }

        public AreaOfExpertiseWithCompetencies(String aoeDescription, compCardDetails compCard) {
            this.aoeDescription = aoeDescription;
            this.competency = compCard;
        }
    }
    
    public class compCardDetails {
        public String CompetencyCode { get; set; }
        public String Id{ get; set; }
        public Double CreditEquivilant { get; set; }
        public String CompetencyName { get; set; }
        public String SMEAssignment { get; set; }
        public String CompetencyDesc { get; set; }
        public String AssessmentType { get; set; }
        public String SyllabusLink { get; set; }
        public String Status { get; set; }
        public String areaOfExpertise { get; set; }
        public String areaOfExpertiseDescription { get; set; }
        public Date setStartDate { get; set; }
        public Date setEndDate { get; set; }
        public Boolean isAssessmentSubmitted { get; set; }
        public Boolean isCompetencyPaused { get; set; }
        public Boolean isCompleted;
        public Boolean visible_flag {get; set;}
        public String competencyLink { get; set; }
        Integer aoeLearningOrder;
        public Boolean add { get; set; }
        public Boolean remove { get; set; }
        public String category { get; set; }
        public Boolean clpActive { get; set; }
        public Boolean isNotAvailableForStudent;
        public compCardDetails() {

        }

        public compCardDetails( Id ID, String CompetencyCode, Double CreditEquivilant, 
                                String CompetencyName, String SMEAssignment, 
                                String CompetencyDesc, String AssessmentType, String SyllabusLink, 
                                String Status, String AreaOfExpertise, String areaOfExpertiseDescription,
                               Integer aoeLearningOrder) {
            this.ID = ID;
            this.CompetencyCode = CompetencyCode;
            this.CreditEquivilant = creditEquivilant;
            this.CompetencyName = CompetencyName;
            this.SMEAssignment = SMEAssignment;
            this.CompetencyDesc = CompetencyDesc;
            this.AssessmentType = AssessmentType;
            this.SyllabusLink = SyllabusLink;
            this.Status = Status;
            this.AreaOfExpertise = AreaOfExpertise;
            this.areaOfExpertiseDescription = areaOfExpertiseDescription;
            this.visible_flag = false;
            this.add = false;
            this.remove = false;
        }
    }
}