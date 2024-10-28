/*******************************************************************
Name  : EditBuildController 
Author: Sushant (Laureate)
Date  : October 2, 2017
Description: Controller extension class for EditBuildController Page

Revision History 
* Horacio Sanchez   11/04/2020     S-30862: Do not Allow students to remove Open competency, unless it is paused
* Ravitej Varada    05/03/2022     S-694767: L2: Modify the Existing ATC (old flow) to Work Only if Product.Automate_Agree_to_Credit__c is False
* Horacio Sanchez   05/04/2022     S-89059: Update Tempo Portal Navigation Menu if ATC Start Date is Today
* Horacio Sanchez   05/18/2022     S-89060: Update CLP Logic of what competencies appear for graduate students
* Horacio Sanchez   06/01/2022     S-89067: Update CLP Submission Step to Show Additional Disclaimer; Pass data to L2 SF
* Horacio Sanchez   06/15/2022     S-89068: CLP minimum credits logic for students entering their final subscription term
* Horacio Sanchez   06/20/2022     S-89395: ATC - End to End Testing, Bug Fixes - Fixed preset CLP when a competency is already started
*************************************************************************/

public with sharing class EditBuildController {

    public Student_Program__c sProgram { get; set; }
    public Map<Decimal, String> Message_order = new map<Decimal, String>();
    public Id studentProgramId;
    public List<Student_Competency__c> studentComps { get; set; }
    public List<compCardDetails> leftCompCards { get; set; }
    public List<compCardDetails> rightCompCards { get; set; }
    public Set<String> selectedComps;
    public Set<String> deselectedComps;
    public Date startDate { get; set; }
    public Date endDate { get; set; }
    public String studentName { get; set; }
    public Double credit_progression_rate { get; set; }
    public Double credit_sum { get; set; }
    public Boolean save_Flag { get; set; }
    private Set<Student_Competency__c> addStudentCompetencies;
    private Set<Student_Competency__c> removeStudentCompetencies;
    public String message { get; set; }
    public Boolean firstClick;
    public Boolean secondClick;
    public Boolean thirdClick;
    public List<customMap> expertiseWiseCompetencies { get; set; }
    public String modalHeader { get; set; }
    public String modalBody { get; set; }
    public Boolean isModalWindow { get; set; }
    public String currentUserId { get; set; }
    public String contactId {get;set;}
    public String waldenEmail { get; set; }
    public String waldenEmailHash { get; set; }    
    public String intercomAppId { get; set; }
    public String degreeLevel { get; set; }
    public Boolean isATCCompleted {get;set;}
        
    Boolean isCommunityUser() {
        if('Customer Community Login'.equals( ([ Select UserLicense.Name  FROM Profile WHERE Id =: userinfo.getProfileid()]).UserLicense.Name) ) {
            return true;
        } else {
            return false;
        }
    }
    
    public EditBuildController(ApexPages.StandardController controller) {

        //Retrieve Current User Active student Program ID from contact
        if (!isCommunityUser()) {
            studentProgramId = ApexPages.currentPage().getParameters().get('id');
        } else {
            currentUserId = UserInfo.getUserId();
            User user = [SELECT Id, ContactId FROM User WHERE Id = :currentUserId];
            Contact contact = [
                    SELECT Id,walden_Email__c,name,Email,  (
                            SELECT Id,Program__r.Degree_Level__c
                            FROM Student_Programs__r
                            WHERE IsStudentProgramActive__c = true
                            LIMIT 1
                    )
                    FROM CONTACT
                    WHERE Id = :user.ContactId
            ];
            contactId= contact.id;
            studentName = contact.name;
            waldenEmail = contact.Email;
            waldenEmailHash = HmacSHA256Encryption.generateHmacSHA256Signature(waldenEmail); 
            ApexPages.currentPage().getParameters().put('id', contact.Student_Programs__r[0].id);
            ApexPages.currentPage().getParameters().get('id');
            studentProgramId = ApexPages.currentPage().getParameters().get('id');
            degreeLevel = contact.Student_Programs__r[0].Program__r.Degree_Level__c;
        }
        
        isModalWindow = false;
        isATCCompleted = true;
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
                        SELECT ID, Competency__c, competency__r.Description__c, Student_Program__c, Status__c, Assessment_Submitted__c, Pause_Competency__c,
                                competency_title__c, Competency_Credit_Equivalency__c, Student_Expertise__r.Program_Expertise__r.Overview__c, Learning_Order__c,
                                Student_Expertise__r.Program_Expertise__r.Learning_Order__c, Student_Expertise__r.Is_Not_Available_for_Student__c,
                                Competency_Code__c,SME__c,SME__r.Name, Description__c, clp_active__c, Area_Of_Expertise_Name__c,competency__r.Assessment_Type__c
                        FROM Student_Competencies__r
                        WHERE Is_Enrolled__c = TRUE 
                        AND   Competency_Code__c != 'TL000' 
                        AND   Student_Expertise__r.Area_of_Expertise__r.Display_On_Web__c = TRUE 
                        AND   Competency__r.Type__c != 'Skill'
                        AND   Student_Expertise__r.Is_Removed_from_Program_Plan__c = FALSE
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
        
        // S-89059: Update Tempo Portal Navigation Menu if ATC Start Date is Today
        // Checking if Agree to Credits process has been completed
        if (sProgram.Current_Student_Subscription__c != null 
            && (sProgram.Current_Student_Subscription__r.Agreed_To_Credits__c == null || sProgram.Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c == null) 
            && sProgram.Program__r.Automate_Agree_to_Credit__c
            && sProgram.Current_Student_Subscription__r.Start_Date__c.daysBetween(Date.today()) < 14) {
            isATCCompleted = false;
        }
        
        setSaveFlag();
        firstClick = false;
        secondClick = false;
        thirdClick = false;
        createMessageMap();
        getMessageFirstLoad();
        
        getLeftCompCards(this.sProgram.Student_Competencies__r);
        credit_sum = 0.0;
        
        // S-89068
        calculateMinimumCredits();
        
        // S-89060: Update CLP Logic of what competencies appear for graduate students
        if (!isATCCompleted) {
            getPreSetCLP();
        } else {
            getRightCompCards(this.sProgram.Student_Competencies__r);
        }
        
        //Custom Settings to retrive Brand Conf Record ID to display Header and Body for Model Window        
        Community_Site_Settings__c defaultCustomSetngs = Community_Site_Settings__c.getValues('Default Settings');
        if (defaultCustomSetngs != null) {
            Brand_Configuration__c BC = [Select id,name,Sub_Type__c,Body__c from Brand_Configuration__c where id = :defaultCustomSetngs.RecordID__c];
            modalHeader = BC.Sub_Type__c;
            modalBody = BC.Body__c;
            intercomAppId = defaultCustomSetngs.Intercom_App_Id__c ;
        }
        
        //displayModalWindow();
    }
    
    /*
     * S-89068: CLP minimum credits logic for students entering their final subscription term
     */
    public void calculateMinimumCredits() {
        Double totalCreditsAvailableInCompetencies = 0.0;
        for (CustomMap cp : expertiseWiseCompetencies) {
            for (AreaOfExpertiseWithCompetencies aoe : cp.value1) {
                if (aoe.competency.Status == 'Registered' || aoe.competency.Status == 'Assessment Submitted' || aoe.competency.Status == 'Not-Achieved' || aoe.competency.Status == 'Returned for Resubmission' || aoe.competency.Status == 'Not Enrolled') {
                    totalCreditsAvailableInCompetencies += aoe.competency.creditEquivilant;
                }
            }
        }
        
        if (totalCreditsAvailableInCompetencies <= credit_progression_rate) {
            credit_progression_rate = totalCreditsAvailableInCompetencies;
        }
    }
    
    /*
     * S-89060: Update CLP Logic of what competencies appear for graduate students
     */ 
    public void getPreSetCLP() {
        Double totalCreditsAdded = 0.0;
        if (rightCompCards == null) {
            rightCompCards = new List<compCardDetails>();
        }
           
        // First look for the started competencies
        for (CustomMap cp : expertiseWiseCompetencies) {
            for (AreaOfExpertiseWithCompetencies aoe : cp.value1) {
                if (aoe.competency.Status == 'Registered' || aoe.competency.Status == 'Assessment Submitted' || aoe.competency.Status == 'Not-Achieved' || aoe.competency.Status == 'Returned for Resubmission' || aoe.competency.Status == 'Not Enrolled') {
                    if (aoe.competency.isAssessmentSubmitted) {
                        addCompetency(aoe.competency.Id);
                        totalCreditsAdded += aoe.competency.creditEquivilant;
                    }
                    if (totalCreditsAdded >= credit_progression_rate) {
                        break;
                    }
                }
            }
            if (totalCreditsAdded >= credit_progression_rate) {
                break;
            }
        }
        
        // Then get the remaining competencies to add to the right side
        for (CustomMap cp : expertiseWiseCompetencies) {
            for (AreaOfExpertiseWithCompetencies aoe : cp.value1) {
                if (aoe.competency.Status == 'Registered' || aoe.competency.Status == 'Assessment Submitted' || aoe.competency.Status == 'Not-Achieved' || aoe.competency.Status == 'Returned for Resubmission' || aoe.competency.Status == 'Not Enrolled') {
                    addCompetency(aoe.competency.Id);
                    totalCreditsAdded += aoe.competency.creditEquivilant;
                    if (totalCreditsAdded >= credit_progression_rate) {
                        break;
                    }
                }
            }
            if (totalCreditsAdded >= credit_progression_rate) {
                break;
            }
        }
    }

    // If UG student tries to access Edit Build for Graduate, it will be redirected to UG page.
    public PageReference degreeLevelCheck() {
        if (degreeLevel == 'Undergrad') {
            PageReference myUndergradPage = new PageReference('/EditBuildUnderGrad');
            myUndergradPage.setRedirect(true);
            return myUndergradPage;
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
            System.debug(exp.getLineNumber() + ', ' + exp.getMessage());
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
            System.debug(exp.getLineNumber() + ', ' + exp.getMessage());
        }
        return message;
    }

    //this method sets the flag to enable/disable the save button
    public void setSaveFlag() {
        System.debug('Credit progression rate: ' + credit_progression_rate);
        System.debug('Credit sum: ' + credit_sum);
        try {
            if (credit_sum >= credit_progression_rate) {
                save_Flag = true;
            } else {
                save_Flag = false;
            }
        } catch (Exception exp) {
            system.debug(exp);
            System.debug(exp.getLineNumber() + ', ' + exp.getMessage());
        }
    }

    //this method returns the competencies to be displayed on the left side
    public void getLeftCompCards(list<Student_Competency__c> studentCompetencies) {
        leftCompCards = new List<compCardDetails>();
        leftCompCards = buildCompCards(leftCompCards, studentCompetencies);
        buildCompetenciesByExpertise(leftCompCards);
        System.debug('expertiseWiseCompetencies : ' + expertiseWiseCompetencies);
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

                for (Student_Competency__c sc : studentCompetencies) {
                    compCardDetails compCardObject = new compCardDetails();
                    compCardObject.ID = sc.ID;
                    compCardObject.CompetencyCode = sc.Competency_Code__c;
                    compCardObject.CreditEquivilant = sc.Competency_Credit_Equivalency__c;
                    compCardObject.CompetencyName = sc.competency_title__c;
                    compCardObject.SMEAssignment = sc.SME__r.Name;
                    compCardObject.isAssessmentSubmitted = sc.Assessment_Submitted__c;
                    compCardObject.isCompetencyPaused = sc.Pause_Competency__c;
                    compCardObject.CompetencyDesc = sc.competency__r.Description__c;
                    if (sc.Student_Expertise__r.Program_Expertise__r.Learning_Order__c == null) {
                        if (sc.Area_Of_Expertise_Name__c != null && sc.Area_Of_Expertise_Name__c.contains('Capstone') && sc.Area_Of_Expertise_Name__c.contains('MHRM')) {
                            compCardObject.aoeLearningOrder = 15;
                        }
                    } else {
                        compCardObject.aoeLearningOrder = Integer.valueOf(sc.Student_Expertise__r.Program_Expertise__r.Learning_Order__c);    
                    }
                    //compCardObject.aoeLearningOrder = Integer.valueOf(sc.Learning_Order__c);
                    if (sc.Status__c == 'Not Achieved') {
                        sc.Status__c = 'Not-Achieved';
                    }
                    compCardObject.Status = sc.Status__c;
                    compCardObject.areaOfExpertiseDescription = sc.Student_Expertise__r.Program_Expertise__r.Overview__c;
                    System.debug('compCardObject.areaOfExpertiseDescription : ' + compCardObject.areaOfExpertiseDescription);
                    compCardObject.AssessmentType = sc.competency__r.Assessment_Type__c;
                    compCardObject.AreaOfExpertise = sc.Area_Of_Expertise_Name__c;
                    compCardObject.SyllabusLink = compSyllabus.get(sc.Competency_Code__c);
                    compCardObject.isNotAvailableForStudent = sc.Student_Expertise__r.Is_Not_Available_for_Student__c;
                    if (sc.clp_active__c == true && isATCCompleted) {
                        compCardObject.visible_flag = false;
                    } else {
                        compCardObject.visible_flag = true;
                    }
                    compCardObject.isCLPActive = sc.clp_active__c;
                    compCards.add(compCardObject);
                }
            }


        } catch (Exception exp) {
            System.debug(exp);
            System.debug(exp.getLineNumber() + ', ' + exp.getMessage());
        }
        return compCards;
    }
    
    void buildCompetenciesByExpertise(List<compCardDetails> groupedLeftCompCards) {
        Map<String, List<AreaOfExpertiseWithCompetencies>> expertiseWiseCompetencies_p = new Map<String, List<AreaOfExpertiseWithCompetencies>>();
        Map<Integer, String> learningOrderToAOEName = new Map<Integer, String>();
        
        Integer count = 1000000;
        for (compCardDetails compCard : groupedLeftCompCards) {
            if (String.isNotBlank(compCard.AreaOfExpertise)) {
                if (expertiseWiseCompetencies_p.containsKey(compCard.AreaOfExpertise)) {
                    List<AreaOfExpertiseWithCompetencies> aoeWithCompetencies = expertiseWiseCompetencies_p.get(compCard.AreaOfExpertise);
                    System.debug('compCard : ' + compCard);
                    System.debug('compCard.areaOfExpertiseDescription: ' + compCard.areaOfExpertiseDescription);
                    aoeWithCompetencies.add(new AreaOfExpertiseWithCompetencies(compCard.areaOfExpertiseDescription, compCard, compCard.isNotAvailableForStudent));
                    expertiseWiseCompetencies_p.put(compCard.AreaOfExpertise, aoeWithCompetencies);
                } else {
                    //learningOrderToAOEName.put(compCard.aoeLearningOrder, compCard.AreaOfExpertise);
                    if( compCard.aoeLearningOrder != null ) {
                        learningOrderToAOEName.put(compCard.aoeLearningOrder, compCard.AreaOfExpertise);
                    } else {
                        learningOrderToAOEName.put( count, compCard.AreaOfExpertise);
                    }
                    count++;
                    AreaOfExpertiseWithCompetencies aoeWithCompetency = new AreaOfExpertiseWithCompetencies(compCard.areaOfExpertiseDescription, compCard, compCard.isNotAvailableForStudent);
                    expertiseWiseCompetencies_p.put(compCard.AreaOfExpertise, new List<AreaOfExpertiseWithCompetencies>{aoeWithCompetency});
                }
            }
        }
        List<Integer> learningOrders = new List<Integer> (learningOrderToAOEName.keySet());
        learningOrders.sort();
        System.debug('learningOrders : ' + learningOrders);
        expertiseWiseCompetencies = new List<customMap>();
        for (Integer learningOrder : learningOrders) {
            customMap instance = new customMap();
            instance.key = learningOrderToAOEName.get(learningOrder); // HERE
            instance.value1 = expertiseWiseCompetencies_p.get(learningOrderToAOEName.get(learningOrder));
            expertiseWiseCompetencies.add(instance);
        }
    }

    //this method returns the competencies to be displayed on the right side
    public List<compCardDetails> getRightCompCards(list<Student_Competency__c> studentCompetencies_p) {
        rightCompCards = new list<compCardDetails>();
        List<Student_Competency__c> studentCompetencies = new List<Student_Competency__c>();
        for (Student_Competency__c studentCompetency : studentCompetencies_p) {
            if (studentCompetency.clp_active__c) {
                studentCompetencies.add(studentCompetency);
            }
        }
        rightCompCards = buildCompCards(rightCompCards, studentCompetencies);
        for (compCardDetails itr : rightCompCards) {
            itr.visible_flag = true;
            if (itr.CreditEquivilant != null) {
                credit_sum = credit_sum + itr.CreditEquivilant;
            }
        }
        return rightCompCards;
    }
    
    // Returns comp code and syllabus Link   From Competency__c
    public List<Competency__c> compLst(set<string> S1) {
        If (!S1.isEmpty()) {
            List<Competency__c> compIDs = new List<Competency__c>([Select ID,Code__c,syllabus_link__c FROM Competency__c WHERE Code__c IN :S1]);
            return compIDs;
        }
        return null;
    }

    //this method will be called when the '+' button is clicked on the left side    
    public void addCompetencyFromStudentPortal() {
        try {
            String passedCompId = Apexpages.currentPage().getParameters().get('compID');
            addCompetency(passedCompId);
        } catch (Exception e) {
            System.debug('Exception in line: ' + e.getLineNumber());
            System.debug('Exception: ' + e.getMessage());
        }
    }
    
    //
    private void addCompetency(String compId) {
        try {
            List<List<AreaOfExpertiseWithCompetencies>> competencies = new List<List<AreaOfExpertiseWithCompetencies>>();
            for (customMap mapInstance : expertiseWiseCompetencies ) {
                competencies.add(mapInstance.value1);    
            }
            for (List<AreaOfExpertiseWithCompetencies> allCompCardDetails : competencies) {
                for (AreaOfExpertiseWithCompetencies ccd : allCompCardDetails) {
                    if (compId != null && compId != '' && ccd.competency.ID.equals(compId)) {
                        compCardDetails newRightColumnComp =
                                new compCardDetails(ccd.competency.ID, ccd.competency.CompetencyCode, ccd.competency.CreditEquivilant,
                                        ccd.competency.CompetencyName, ccd.competency.SMEAssignment, ccd.competency.CompetencyDesc,
                                        ccd.competency.AssessmentType, ccd.competency.SyllabusLink, ccd.competency.Status,
                                        ccd.competency.AreaOfExpertise,
                                        ccd.competency.areaOfExpertiseDescription);
                        newRightColumnComp.SMEAssignment = ccd.competency.SMEAssignment;
                        newRightColumnComp.isAssessmentSubmitted = ccd.competency.isAssessmentSubmitted;
                        newRightColumnComp.visible_flag = true;
                        if (deselectedComps != null) {
                            if (deselectedComps.contains(ccd.competency.CompetencyCode)) {
                                deselectedComps.remove(ccd.competency.CompetencyCode);
                            }
                        }
                        selectedComps.add(ccd.competency.CompetencyCode);
                        rightCompCards.add(newRightColumnComp);
                        system.debug('ccd:' + ccd);
                        ccd.competency.visible_flag = false;
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
        } catch (Exception e) {
            System.debug('Exception in line: ' + e.getLineNumber());
            System.debug('Exception: ' + e.getMessage());
        }
        system.debug('After addCompetency');
    }

    public PageReference removeCompetencies() {
        try {
            String passedCompId = Apexpages.currentPage().getParameters().get('removedCompID');
            /*for (compCardDetails ccd : rightCompCards) {
                if (passedCompId != null && passedCompId != '' && ccd.ID.equals(passedCompId)) {
                    System.debug('Inside the loop');
                    if (selectedComps != null) {
                        if (selectedComps.contains(ccd.CompetencyCode)) {
                            selectedComps.remove(ccd.CompetencyCode);
                        }
                    }
                    deselectedComps.add(ccd.CompetencyCode);
                    ccd.visible_flag = false;
                    credit_sum -= ccd.CreditEquivilant;
                    if (credit_sum < 0) {
                        credit_sum = 0;
                    }
                    List<List<AreaOfExpertiseWithCompetencies>> competencies = new List<List<AreaOfExpertiseWithCompetencies>>();
                    for (customMap mapInstance : expertiseWiseCompetencies) {
                        competencies.add(mapInstance.value1);    
                    }
                    for (List<AreaOfExpertiseWithCompetencies> allCompCardDetails : competencies ) {
                        for (AreaOfExpertiseWithCompetencies ccd2 : allCompCardDetails) {
                            if ((ccd.CompetencyCode).equals(ccd2.competency.CompetencyCode)) {
                                ccd2.competency.visible_flag = true;
                            }
                        }
                    }
                }
            }*/
            for (Integer i = rightCompCards.size() - 1; i >= 0; i--) {
                compCardDetails ccd = rightCompCards.get(i);
                if (passedCompId != null && passedCOmpId != '' && ccd.Id.equals(passedCompId)) {
                    if (selectedComps != null) {
                        if (selectedComps.contains(ccd.CompetencyCode)) {
                            selectedComps.remove(ccd.CompetencyCode);
                        }
                    }
                    deselectedComps.add(ccd.CompetencyCode);
                    ccd.visible_flag = false;
                    credit_sum -= ccd.CreditEquivilant;
                    if (credit_sum < 0) {
                        credit_sum = 0;
                    }
                    List<List<AreaOfExpertiseWithCompetencies>> competencies = new List<List<AreaOfExpertiseWithCompetencies>>();
                    for (customMap mapInstance : expertiseWiseCompetencies) {
                        competencies.add(mapInstance.value1);    
                    }
                    for (List<AreaOfExpertiseWithCompetencies> allCompCardDetails : competencies ) {
                        for (AreaOfExpertiseWithCompetencies ccd2 : allCompCardDetails) {
                            if ((ccd.CompetencyCode).equals(ccd2.competency.CompetencyCode)) {
                                ccd2.competency.visible_flag = true;
                            }
                        }
                    }
                    rightCompCards.remove(i);
                }
            }
            setSaveFlag();
            if (save_Flag) {
                message = Message_order.get(5);
            } else {
                message = Message_order.get(1);
            }
        } catch (Exception exp) {
            system.debug(exp);
            System.debug(exp.getLineNumber() + ', ' + exp.getMessage());
        }
        return null;
    }


    //method called once the save button is clicked to save the competencies
    public PageReference saveCompetencies() {
        try {
            List<Student_Competency__c> IdCompetency = new List<Student_Competency__c>([
                    SELECT ID, Competency_Code__c, Competency_Credit_Equivalency__c
                    FROM Student_Competency__c
                    WHERE Student_Program__c = :sProgram.Id
            ]);
            Map<String, Student_Competency__c> compID = new Map<String, Student_Competency__c>();
            for (Student_Competency__c itr : IdCompetency) {
                compID.put(itr.competency_code__c, itr);
            }
            List<Student_Competency__c> updateCompetencyList = new List<Student_Competency__c>();
            for (String itr : selectedComps) {
                Id idvalue = compID.get(itr).Id;
                updateCompetencyList.add(new Student_Competency__c(id = idvalue, clp_active__c = true));
            }
            for (String itr : deselectedComps) {
                Id idvalue = compID.get(itr).Id;
                updateCompetencyList.add(new Student_Competency__c(id = idvalue, clp_active__c = false));
            }
            system.debug('updateCompetencyList:' + updateCompetencyList);
            if (!updateCompetencyList.isEmpty()) {
                update updateCompetencyList;
            }
            
            // S-89067
            if (sProgram.Current_Student_Subscription__c != null 
                && sProgram.Current_Student_Subscription__r.Agreed_To_Credits__c == null 
                && sProgram.Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c == null 
                && sProgram.Program__r.Automate_Agree_to_Credit__c) {
                Student_Subscription__c subscription = new Student_Subscription__c();
                subscription.Id = sProgram.Current_Student_Subscription__c;
                subscription.Agreed_To_Credits__c = credit_progression_rate;
                update subscription;
                subscription = new Student_Subscription__c();
                subscription.Id = sProgram.Current_Student_Subscription__c;
                subscription.Date_Student_Agreed_To_Credits__c = Date.today();
                update subscription;
                
                // If previously added competencies, with CLP Active flag = true, are not added to current CLP, then make the flag = true;
                List<Student_Competency__c> updateCompetencySecondaryList = new List<Student_Competency__c>();
                for (CustomMap cp : expertiseWiseCompetencies) {
                    for (AreaOfExpertiseWithCompetencies aoe : cp.value1) {
                        if (aoe.competency.Status == 'Registered' || aoe.competency.Status == 'Assessment Submitted' || aoe.competency.Status == 'Not-Achieved' || aoe.competency.Status == 'Returned for Resubmission' || aoe.competency.Status == 'Not Enrolled') {
                            if (aoe.competency.isCLPActive) {
                                for (compCardDetails ccd : rightCompCards) {
                                    if (aoe.competency.Id.equals(ccd.Id)) {
                                        break;
                                    }
                                    Id idvalue = ccd.Id;
                					updateCompetencySecondaryList.add(new Student_Competency__c(id = idvalue, clp_active__c = false));
                                }
                            }
                        }
                    }
                }
                if (!updateCompetencySecondaryList.isEmpty()) {
                	update updateCompetencySecondaryList;
                }
            }
            
            PageReference myTermPage = new PageReference('/apex/MyTerm');
            myTermPage.setRedirect(true);
            myTermPage.getParameters().put('id', studentProgramId);
            return myTermPage;

        } catch (Exception exp) {
            system.debug(exp);
            System.debug(exp.getLineNumber() + ', ' + exp.getMessage());
        }
        return null;
    }
        
    public PageReference editBuildCancel() {
        PageReference myTermPage = new PageReference('/apex/MyTerm');
        myTermPage.setRedirect(true);
        return myTermPage;
    }


    public class AreaOfExpertiseWithCompetencies {
        public String aoeDescription { get; set; }
        public CompCardDetails competency { get; set; }
        public Boolean isNotAvailableForStudent {get;set;}

        public AreaOfExpertiseWithCompetencies() {

        }

        public AreaOfExpertiseWithCompetencies(String aoeDescription, compCardDetails compCard) {
            this.aoeDescription = aoeDescription;
            this.competency = compCard;
        }

        public AreaOfExpertiseWithCompetencies(String aoeDescription, compCardDetails compCard, boolean isNotAvailableForStudent) {
            this.aoeDescription = aoeDescription;
            this.competency = compCard;
            this.isNotAvailableForStudent = isNotAvailableForStudent;
        }
    }
    
    public class customMap {
        public String key{get;set;}
        public List<AreaOfExpertiseWithCompetencies> value1{get;set;}
    }
    
    Public class compCardDetails {
        public Id ID { get; set; }
        public String CompetencyCode { get; set; }
        public Double CreditEquivilant { get; set; }
        public String CompetencyName { get; set; }
        public String SMEAssignment { get; set; }
        public String CompetencyDesc { get; set; }
        public String AssessmentType { get; set; }
        public String SyllabusLink { get; set; }
        public String Status { get; set; }
        public String AreaOfExpertise { get; set; }
        public String areaOfExpertiseDescription { get; set; }
        public Boolean visible_flag { get; set; }
        public Boolean add { get; set; }
        public Boolean remove { get; set; }
        public Boolean isAssessmentSubmitted { get; set; }
        public Boolean isCompetencyPaused { get; set; }
        public Boolean isNotAvailableForStudent;
        Integer aoeLearningOrder;
        public Boolean isCLPActive { get; set; }
        
        public compCardDetails() {

        }

        public compCardDetails(Id ID, String CompetencyCode, Double CreditEquivilant, String CompetencyName, String SMEAssignment, String CompetencyDesc, String AssessmentType, String SyllabusLink, String Status, String AreaOfExpertise, String areaOfExpertiseDescription) {
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