/*******************************************************************
Name  : MyTermController 
Author: Sushant (Laureate)
Date  : September 25, 2017
Description: Controller extension class for MyTermController Page

* Revision History
* Horacio Sanchez   10/27/2020     S-28150 Making Tempo Resources page available for Inactive Students
* Horacio Sanchez   11/29/2020     S-28150 Making Tempo Resources page available for Inactive Students
* Horacio Sanchez   01/19/2021     Prod Defect 40082: Tempo: SMEs are not displayed on Portal
* Ravitej Varada    07/28/2021       40082: Tempo:  WOW competency update
* Ravitej Varada    05/03/2022     S-694767: L2: Modify the Existing ATC (old flow) to Work Only if Product.Automate_Agree_to_Credit__c is False
* Horacio Sanchez   05/04/2022     S-89059 Update Tempo Portal Navigation Menu if ATC Start Date is Today
*************************************************************************/

public without sharing class MyTermController {
    public Student_Program__c sProgram { get; set; }
    public Id studentProgramId { get; set; }
    public Date startDate { get; set; }
    public Date endDate { get; set; }
    public Integer daysRemaining { get; set; }
    public List<compCardDetails> CompCards { get; set; }
    public decimal totalCreditEquivalency { get; set; }
    public String studentName { get; set; }
    public String cblId { get; set; }
    public Date issueDate { get; set; }
    public String Coach { get; set; }
    public String CoachEmail { get; set; }
    public String selectedDate { get; set; }
    public String sortOrder { get; set; }
    public String selectedCompCode { get; set; }
    public String dateType { get; set; }
    public Integer activeCompetencies { get; set; }
    public string modalHeader { get; set; }
    public string modalBody { get; set; }
    public Boolean isModalWindow { get; set; }
    public List<Student_Competency__c> studComp = new List<Student_Competency__c>();
    //expertisewiseCompetencies grouping
    public Map<String, List<compCardDetails>> expertisewiseCompetencies { get; set; }
    public Map<String, AreaOfExpertiseWrapper> nameToAreaOfExpertiseWrapper { get; set; }
    public Boolean isAgreedCreditText {get;set;}
    public String currentUserId {get;set;}
    public String contactId {get;set;}
    public string brightSpaceLmsId{get;set;}
    public String waldenEmail { get; set; }
    public String waldenEmailHash { get; set; }
    public String intercomAppId { get; set; }
    Public String degreeLevel { get; set; }
    public Boolean showCreateMyPlanButton {get;set;}
    public Boolean isOnboardingModal {get;set;}
    public List<Brand_Configuration__c> brandConfigurations {get;set;}
    public List<String> tempoResourcesUrlList {get;set;}
    public Boolean isATCCompleted {get;set;}
    
    Boolean isCommunityUser() {
        if('Customer Community Login'.equals( ([ Select UserLicense.Name  
                                                FROM Profile 
                                                WHERE Id =: userinfo.getProfileid()]).UserLicense.Name) ) {
            return true;
        } else {
            return false;
        }
    }
    public MyTermController(){}
    
    
    public MyTermController(ApexPages.StandardController controller) {        
        if ( ! isCommunityUser() ) {
            studentProgramId = ApexPages.currentPage().getParameters().get('id');
        } else {
            currentUserId = UserInfo.getUserId();
            User user = [SELECT Id, ContactId FROM User WHERE Id = :currentUserId];
            Contact contact = [SELECT Id,Walden_Email__c ,Email, (SELECT Id,Program__r.Degree_Level__c FROM Student_Programs__r ORDER BY CreatedDate DESC LIMIT 1) FROM CONTACT WHERE Id = :user.ContactId];
            contactId=contact.id;
            waldenEmail = contact.Email;
            waldenEmailHash = HmacSHA256Encryption.generateHmacSHA256Signature(waldenEmail); 
            ApexPages.currentPage().getParameters().put('id',contact.Student_Programs__r[0].id);
            ApexPages.currentPage().getParameters().get('id');
            studentProgramId = ApexPages.currentPage().getParameters().get('id');
            degreeLevel = contact.Student_Programs__r[0].Program__r.Degree_Level__c;
        }
        if (!test.isRunningTest()) {
            controller.addFields(new List<String>{'CurrentSubscriptionStartDate__c', 'CurrentSubscriptionEndDate__c'});
            Student_Program__c studProgram = (Student_Program__c) controller.getRecord();    
            startDate = studProgram.CurrentSubscriptionStartDate__c;
            endDate = studProgram.CurrentSubscriptionEndDate__c ;
        }
        studComp = [
                select id, Competency__r.Credit_Equivalency__c
                from Student_Competency__c
                where IsCompleted__c = true and
                CLP_Active__c = true and
                Student_Program__r.id = :studentProgramId AND
                (Completed_Date__c = null OR
                (Completed_Date__c >= :startDate and
                Completed_Date__c <= :endDate))
        ];
        
        system.debug('studComp' + studComp);
        totalCreditEquivalency = 0;
        activeCompetencies = 0;
        isOnboardingModal = false;
        showCreateMyPlanButton = false;
        isATCCompleted = true;
        
        if (studComp != null && !studComp.isEmpty()) {
            for (Student_Competency__c sc : studComp) {
                totalCreditEquivalency = totalCreditEquivalency + sc.Competency__r.Credit_Equivalency__c;
            }
        }

        system.debug('Student program id is:');
        system.debug(studentProgramId);
        this.sProgram = [
                SELECT Name,Program__r.Automate_Agree_to_Credit__c, Student_Full_Name__c, Current_Student_Subscription__c,Date_Student_Activated__c,
                        CurrentSubscriptionStartDate__c, CurrentSubscriptionEndDate__c,is_welcome_message__c,
                        Renewal_Denied__c, Renewal_Denied_Comment__c, Number_of_Enrolled_Terms__c,Competencies_Completed_in_Trial__c,
                        Number_of_Competencies_Completed__c, IsStudentProgramActive__c, Id, Application__c, Number_of_Competencies_Transferred__c,Program__c,
                        Number_of_Competencies__c,Application__r.Admissions_Contingency__c, Total_attempted_credits__c, Number_Credits_Completed_in_all_Terms__c,
                        Number_of_Credits_Completed_in_Trial__c,Number_of_Credits_TransferredFulfilled__c,SAP_Code__c, Previous_SAP_Code__c,
                        Current_Student_Subscription__r.Agreed_To_Credits__c,Current_Student_Subscription__r.Number_of_Credits_Completed__c,
                        Student__r.Name,CoachEmail__c,Coach__r.Name,Current_Subscription_Agreed_To_Credits__c, Active_Hold_Codes__c,
                        Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c, First_Start_Date__c, Modality_Switcher_chk__c,LOA_Gap_Months__c,
                        student__r.CBL_Student_ID__c,Program_Start_Date__r.Name, Current_Student_Subscription__r.Start_Date__c, (
                        SELECT ID, Student_Program__c, Status__c, competency_title__c, Competency_Credit_Equivalency__c,
                                Competency_Code__c,SME__c,SME__r.Name, Description__c, clp_active__c,Student_Expertise__r.Is_Pre_Req_Lock__c,
                                Area_Of_Expertise_Name__c, Competency__r.Description__c, competency__r.Assessment_Type__c
                        FROM Student_Competencies__r
                        WHERE Is_Enrolled__c = true AND
                        Competency_Code__c != 'TL000' AND
                        Competency__r.Type__c != 'Skill' and
                        (Completed_Date__c = null OR
                        (Completed_Date__c >= :startDate and
                        Completed_Date__c <= :endDate))
                )
                FROM Student_Program__c
                WHERE Id = :studentProgramId
        ];

        //Custom Settings to retrive Brand Conf Record ID to display Header and Body for Model Window         
        Community_Site_Settings__c defaultCustomSetngs = Community_Site_Settings__c.getValues('Default Settings');
        if( defaultCustomSetngs != null ) {
            Brand_Configuration__c BC = [Select id,name,Sub_Type__c,Body__c from Brand_Configuration__c where id = :defaultCustomSetngs.RecordID__c];
            modalHeader = BC.Sub_Type__c;
            modalBody = BC.Body__c;
            intercomAppId = defaultCustomSetngs.Intercom_App_Id__c ;
        }
        initTempoResourcesUrl();
        
        //Display Onboarding model  
        if (sProgram.First_Start_Date__c  != null) {
            Date firstStartDate = sProgram.First_Start_Date__c  ;
            Date firstStartDateAdd15 = firstStartDate.addDays(16); 
            if (system.today() >= firstStartDate && system.today() <= firstStartDateAdd15 && sProgram.is_welcome_message__c == True) {
                isOnboardingModal = true;
             }            
        }
            
        Map<string, D2L__c> mapD2LCustomSettings = D2L__c.getAll();
        //System.debug('ISO Code: ' + mapCustomSettings.get('CreditEquivalentsAgreed').RecordID__c);
        If (!mapD2LCustomSettings.isEmpty()) {
            system.debug('mapD2LCustomSettings NOT EMPTY'+mapD2LCustomSettings.get('D2L').BS_LMS_URL__c);
            brightSpaceLmsId = mapD2LCustomSettings.get('D2L').BS_LMS_URL__c;
        }
            
        if (sProgram.Current_Student_Subscription__r.Agreed_To_Credits__c != null && sProgram.Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c != null) {
            isAgreedCreditText = TRUE;            
        }
        
        // S-89059: Update Tempo Portal Navigation Menu if ATC Start Date is Today
        // Checking if Agree to Credits process has been completed
        if (sProgram.Current_Student_Subscription__c != null 
            && (sProgram.Current_Student_Subscription__r.Agreed_To_Credits__c == null || sProgram.Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c == null) 
            && sProgram.Program__r.Automate_Agree_to_Credit__c
            && sProgram.Current_Student_Subscription__r.Start_Date__c.daysBetween(Date.today()) < 14) {
            isATCCompleted = false;
        }

        system.debug('sProgram' + this.sProgram);
        getStudentComp();
        sortorderbyclick();
        //displayModalWindow();
        CoachEmail = sProgram.CoachEmail__c;
        Coach = sProgram.Coach__r.Name;
        studentName = sProgram.Student__r.name;
        cblId = sProgram.student__r.CBL_Student_ID__c ;
        String programStartDate = sProgram.Program_Start_Date__r.Name;
        List<String> months = new List<String>{
                'january', 'february', 'march', 'april', 'may', 'june', 'july', 'august', 'september', 'october', 'november', 'december'
        };
        Integer monthToFind = 0;
        if (programStartDate != null) {
            for (Integer i = 0; i < months.size(); i++) {

                if (programStartDate.split(' ')[0].toLowerCase() == months.get(i)) {
                    monthToFind = ++i;
                }
            }
            issueDate = Date.newInstance(Integer.valueOf(programStartDate.split(' ')[2]), monthToFind, Integer.valueOf(programStartDate.split(' ')[1].substring(0, programStartDate.split(' ')[1].indexOf(',') - 2)));
        }
        //programStartDate.split(" ")[2].toLowerCase()
        if (startDate != null && endDate != null) {
            daysRemaining = date.today().daysBetween(endDate);
        }
        
        initPopup();
    }

    // S-89059: Update Tempo Portal Navigation Menu if ATC Start Date is Today
    // Checking if Agree to Credits process has been completed
    public PageReference atcCompletedCheck() {
        if (!isATCCompleted) {
            PageReference myTermPage;
            if (degreeLevel == 'Undergrad') {
                myTermPage = new PageReference('/MyTermUndergrad');
            } else {
                myTermPage = new PageReference('/MyTerm');
            }
            myTermPage.setRedirect(true);
            return myTermPage;
        }
        return null;
    }
    
    
    //This method pulls Welcome message for Undergrad from Brand COnfiguration.
    void initPopup() {
        brandConfigurations = new List<Brand_Configuration__c>();
        brandConfigurations = [ SELECT Body__c,Display_Order__c,Heading__c,Name,Sub_Type__c,Type__c FROM Brand_Configuration__c WHERE Sub_Type__c = 'Welcome Messages' ORDER BY Display_Order__c ASC NULLS LAST  LIMIT 10];
    }
    
    //This method updates the Is_Welcome_Message__c field  when "Get Started" Button is clicked on Welcome Model .
    public void updateWelcomeMessage() {
        sProgram.Is_Welcome_Message__c = false;
        update sProgram;        
    }

    // If UG student tries to access My Term for Graduate, it will be redirected to UG page.
    public PageReference degreeLevelCheck() {
        if (degreeLevel == 'Undergrad') {
            PageReference myUndergradPage = new PageReference('/MyTermUndergrad');
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
        isAgreedCreditText = true;
    }

    // This method updates the start date or target date to selected competency
    public void updateDateToDB() {
        try {
            system.debug('selectedDate:' + selectedDate);
            List<String> dateParts = selectedDate.split('-');
            Date ssd = Date.newInstance(Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), Integer.valueOf(dateParts[2]));
            list<Student_Competency__c> studCompetencies = new List<Student_Competency__c>([
                    Select id,name,Start_Date__c,Target_Date__c
                    from Student_Competency__c
                    where Student_Program__c = :studentProgramId and
                    Competency_Code__c = :selectedCompCode and
                    (Completed_Date__c = null OR
                    (Completed_Date__c >= :startDate and
                    Completed_Date__c <= :endDate))
            ]);
            system.debug('studCompetencies' + studCompetencies);
            for (Student_Competency__c stc : studCompetencies) {
                if (dateType.equals('start')) {
                    stc.Start_Date__c = ssd;
                } else if (dateType.equals('submission')) {
                    stc.Target_Date__c = ssd;
                }

                system.debug('stc' + stc);
            }
            update studCompetencies;
        } catch (Exception exp) {
            system.debug('Exception caught');
            system.debug(exp);
        }
    }

    //This method checks Assessment_Submitted__c Flag TRUE when student clicks on Start Competecy button
    public void checkSelfAssessmentSubmittedFlag() {
       system.debug('selectedCompCode'+selectedCompCode); 
               system.debug('studentProgramId'+studentProgramId); 

        Student_Competency__c stuComp = [Select id,name,Student_Expertise__r.Is_Pre_Req_Lock__c,Assessment_Submitted__c from Student_Competency__c where Student_Program__c = :studentProgramId and Competency_Code__c = :selectedCompCode LIMIT 1];
        
        if (selectedCompCode != null) {
            stuComp.Assessment_Submitted__c = TRUE;
            update stuComp;
        }
        compCardDetails selectedCompcard;
        for (compCardDetails compcard : CompCards) {            
            if (compcard.studentCompetencyId == stuComp.id) {
                selectedCompcard = compcard;
            }
        }
        
        Long startTime = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 50) {
            //sleep for 50ms
            finishTime = DateTime.now().getTime();
        }

        Student_Competency__c selectedStudentProgram = [
                Select Student_Program__c,Student_Expertise__r.Is_Pre_Req_Lock__c, Name, id, Status__c, competency_title__c, Competency_Credit_Equivalency__c,
                        Competency_Code__c,SME__c,SME__r.Name, Description__c, Start_Date__c,
                        Target_Date__c, Assessment_Submitted__c, Pause_Competency__c,
                        Area_Of_Expertise_Name__c,
                        Student_Expertise__r.Program_Expertise__r.Overview__c, isCompleted__c, (
                        SELECT Id, Competency_Shell_ID__c 
                        FROM Student_Sections__r
                        LIMIT 1
                )
                From Student_Competency__c
                where id = :stuComp.id AND
                (Completed_Date__c = null OR
                (Completed_Date__c >= :startDate and
                Completed_Date__c <= :endDate))
        ];

        if (!selectedStudentProgram.Student_Sections__r.isEmpty()) {
            selectedCompcard.competencyLink = brightSpaceLmsId + 
                    selectedStudentProgram.Student_Sections__r[0].Competency_Shell_ID__c; 
        }
        selectedCompcard.SMEAssignment = selectedStudentProgram.SME__r.Name;
        selectedCompcard.IsAssessmentSubmitted = selectedStudentProgram.Assessment_Submitted__c;
        selectedCompcard.Status = selectedStudentProgram.Status__c;
        selectedCompcard.IsCompetencyPaused = selectedStudentProgram.Pause_Competency__c;
        if( selectedStudentProgram.Competency_Code__c != 'TW001'){
            activeCompetencies += 1; 
        }
       
    }

    public List<compCardDetails> getStudentComp() {
        CompCards = new list<compCardDetails>();
        activeCompetencies = 0;
        if (sProgram != null) {
            list<Student_Competency__c> studentCompetencies = new List<Student_Competency__c>([
                    Select Student_Program__c, Student_Expertise__r.Is_Pre_Req_Lock__c,Name, id, Status__c, competency_title__c, Competency_Credit_Equivalency__c,
                            Competency_Code__c,SME__c,SME__r.Name, Description__c, Start_Date__c, Target_Date__c, Assessment_Submitted__c, Pause_Competency__c, Area_Of_Expertise_Name__c,
                            Student_Expertise__r.Program_Expertise__r.Overview__c, isCompleted__c, competency__r.Assessment_Type__c, (
                            SELECT Id, Competency_Shell_ID__c
                            FROM Student_Sections__r
                            LIMIT 1
                    )
                    From Student_Competency__c
                    where Student_Program__c = :sProgram.id AND clp_active__c = true
                    and Competency_Code__c != 'CRO01' and
                    (Completed_Date__c = null OR
                    (Completed_Date__c >= :startDate and
                    Completed_Date__c <= :endDate))
                    order by Start_Date__c asc NULLS LAST
            ]);

            system.debug('student competencies is:' + studentCompetencies);
            Set<String> S1 = new Set<String>();
            for (Student_Competency__c sc : studentCompetencies) {
                s1.add(sc.Competency_Code__c);
            }

            List<competency__c> syllabusLink = new List<competency__c>([SELECT code__c, syllabus_link__c from competency__c WHERE code__c IN :s1]);
            Map<String, String> compSyllabus = new Map<String, String>();
            for (competency__c itr : syllabusLink) {
                compSyllabus.put(itr.code__c, itr.syllabus_link__c) ;

            }

            String difficultlevel;
            for (Student_Competency__c sc : studentCompetencies) {
                System.debug('SC: ' + sc);
                compCardDetails compCardObject = new compCardDetails();
                if (!sc.Student_Sections__r.isEmpty()) {
                    compCardObject.competencyLink = brightSpaceLmsId +
                            sc.Student_Sections__r[0].Competency_Shell_ID__c;
                }
                compCardObject.studentCompetencyId = sc.id;
                compCardObject.CompetencyCode = sc.Competency_Code__c;
                compCardObject.CreditEquivilant = sc.Competency_Credit_Equivalency__c;
                compCardObject.CompetencyName = sc.competency_title__c;
                compCardObject.SMEAssignment = sc.SME__r.Name;
                compCardObject.CompetencyDesc = sc.Description__c;
                compCardObject.Status = sc.Status__c;
                compCardObject.setStartDate = sc.Start_Date__c;
                compCardObject.setEndDate = sc.Target_Date__c;
                compCardObject.IsAssessmentSubmitted = sc.Assessment_Submitted__c;
                compCardObject.IsCompetencyPaused = sc.Pause_Competency__c;
                compCardObject.areaOfExpDescription = sc.Student_Expertise__r.Program_Expertise__r.Overview__c;
                compCardObject.areaOfExpertise = sc.Area_Of_Expertise_Name__c;
                compCardObject.isCompleted = sc.isCompleted__c;
                compCardObject.AssessmentType = sc.competency__r.Assessment_Type__c;
                compCardObject.SyllabusLink = compSyllabus.get(sc.Competency_Code__c);
                compCardObject.isPreReqLock =  sc.Student_Expertise__r.Is_Pre_Req_Lock__c;
                CompCards.add(compCardObject);

                // Determining the amount of Active Competencies for the 3 Active Competencies rule.
                if (sc.Assessment_Submitted__c && ((sc.Status__c == 'Registered') || (sc.Status__c == 'Not Achieved') || (sc.Status__c == 'TRANSFER')) && !sc.Pause_Competency__c && sc.Competency_Code__c != 'TW001') {
                    activeCompetencies += 1;
                }
                system.debug('activeCompetencies'+activeCompetencies);
            }

        }
        buildCompetenciesByExpertise(compCards);
        if(compCards.isEmpty()){
            showCreateMyPlanButton = true; 
        }
        return CompCards;
    }

    //To Group the competencies by Area oF Expertise
    void buildCompetenciesByExpertise(List<compCardDetails> compCards) {
        expertisewiseCompetencies = new Map<String, List<CompCardDetails>>();
        nameToAreaOfExpertiseWrapper = new Map<String, AreaOfExpertiseWrapper>();

        for (compCardDetails compCard : compCards) {
            if (String.isNotBlank(compCard.areaOfExpertise)) {
                if (expertisewiseCompetencies.containsKey(compCard.areaOfExpertise)) {
                    List<compCardDetails> competencies = expertisewiseCompetencies.get(compCard.areaOfExpertise);
                    competencies.add(compCard);
                    expertisewiseCompetencies.put(compCard.areaOfExpertise, competencies);
                    nameToAreaOfExpertiseWrapper.get(compCard.areaOfExpertise).totalCount++;
                    if (compCard.isCompleted) {
                        nameToAreaOfExpertiseWrapper.get(compCard.areaOfExpertise).completedCount++;
                    }
                } else {
                    expertisewiseCompetencies.put(compCard.areaOfExpertise, new List<compCardDetails>{
                            compCard
                    });

                    areaOfExpertiseWrapper AreaOfExpertiseWrapper = new AreaOfExpertiseWrapper();
                    AreaOfExpertiseWrapper.areaOfExpDescription = compCard.areaOfExpDescription;
                    AreaOfExpertiseWrapper.totalCount = 1;
                    AreaOfExpertiseWrapper.completedCount = 0;
                    nameToAreaOfExpertiseWrapper.put(compCard.areaOfExpertise, AreaOfExpertiseWrapper);

                }
            }
        }
        System.debug('expertisewiseCompetencies : ' + expertisewiseCompetencies);
        System.debug('nameToAreaOfExpertiseWrapper : ' + nameToAreaOfExpertiseWrapper);
    }

    // This method is used to sort the competencies Asc/Desc by Start date/Targer date
    public pagereference sortorderbyclick() {
        activeCompetencies = 0;
        CompCards = new list<compCardDetails>();
        if (sProgram != null) {
            student_Program__c stuProg = [select id,Sort_Order__c from student_program__c where id = :sProgram.Id];

            system.debug('sortOrder: ' + sortOrder + '; stuProg: ' + stuProg.Sort_Order__c);
            if (sortOrder != null) {
                if (sortOrder == 'sortStartDate') {
                    if (stuProg.Sort_Order__c == 'startDateAsc') {
                        sortOrder = 'startDateDesc';
                        stuProg.Sort_Order__c = 'startDateDesc';
                    } else if (stuProg.Sort_Order__c == 'startDateDesc') {
                        sortOrder = 'startDateAsc';
                        stuProg.Sort_Order__c = 'startDateAsc';
                    } else if (stuProg.Sort_Order__c == 'submitDateAsc') {
                        sortOrder = 'startDateAsc';
                        stuProg.Sort_Order__c = 'startDateAsc';
                    } else if (stuProg.Sort_Order__c == 'submitDateDesc') {
                        sortOrder = 'startDateAsc';
                        stuProg.Sort_Order__c = 'startDateAsc';
                    }
                } else if (sortOrder == 'sortSubmitDate') {
                    if (stuProg.Sort_Order__c == 'startDateAsc') {
                        sortOrder = 'submitDateAsc';
                        stuProg.Sort_Order__c = 'submitDateAsc';
                    } else if (stuProg.Sort_Order__c == 'startDateDesc') {
                        sortOrder = 'submitDateAsc';
                        stuProg.Sort_Order__c = 'submitDateAsc';
                    } else if (stuProg.Sort_Order__c == 'submitDateAsc') {
                        sortOrder = 'submitDateDesc';
                        stuProg.Sort_Order__c = 'submitDateDesc';
                    } else if (stuProg.Sort_Order__c == 'submitDateDesc') {
                        sortOrder = 'submitDateAsc';
                        stuProg.Sort_Order__c = 'submitDateDesc';
                    }
                }
            }

            system.debug('AfterSort: ' + sortOrder);


            list<Student_Competency__c> studentCompetencies ;
            if (sortOrder == 'learnOrder ' || stuProg.Sort_Order__c == null) {
                system.debug('SortCategory1');
                studentCompetencies = [
                        Select Student_Program__c, Status__c,Student_Expertise__r.Is_Pre_Req_Lock__c, competency_title__c, Competency_Credit_Equivalency__c,
                                Competency_Code__c,SME__c,SME__r.Name,Program_Competency__r.Learning_Order__c, 
                                Competency__r.Description__c, Description__c, Start_Date__c,
                                Target_Date__c, Assessment_Submitted__c, Pause_Competency__c, competency__r.Assessment_Type__c, (
                                SELECT Id, Competency_Shell_ID__c
                                FROM Student_Sections__r
                                LIMIT 1
                        )
                        From Student_Competency__c
                        where Student_Program__c = :sProgram.Id AND clp_active__c = TRUE
                        and Competency_Code__c != 'TL000' and
                        (Completed_Date__c = null OR
                        (Completed_Date__c >= :startDate and
                        Completed_Date__c <= :endDate))
                        //order by Student_Expertise__r.Program_Expertise__r.Learning_Order__c,Program_Competency__r.Learning_Order__c  ASC NULLS LAST 
                        order by Student_Expertise__r.Program_Expertise__r.Learning_Order__c, Learning_Order__c  ASC NULLS LAST 
                ];

            } else if (sortOrder == 'startDateAsc' || stuProg.Sort_Order__c == 'startDateAsc') {
                system.debug('SortCategory2');
                studentCompetencies = [
                        Select Student_Program__c, Status__c,Student_Expertise__r.Is_Pre_Req_Lock__c, competency_title__c, Competency_Credit_Equivalency__c,
                                Competency_Code__c,SME__c,SME__r.Name, Competency__r.Description__c, Description__c, Start_Date__c, Target_Date__c, Assessment_Submitted__c, Pause_Competency__c, competency__r.Assessment_Type__c, (
                                SELECT Id, Competency_Shell_ID__c
                                FROM Student_Sections__r
                                LIMIT 1
                        )
                        From Student_Competency__c
                        where Student_Program__c = :sProgram.Id AND clp_active__c = TRUE
                        and Competency_Code__c != 'TL000' and (Completed_Date__c = null OR
                        (Completed_Date__c >= :startDate and
                        Completed_Date__c <= :endDate))
                        order by Start_Date__c ASC NULLS LAST, status__c ASC NULLS LAST
                ];

            } else if (sortOrder == 'startDateDesc' || stuProg.Sort_Order__c == 'startDateDesc') {
                system.debug('SortCategory3');
                studentCompetencies = [
                        Select Student_Program__c, Status__c,Student_Expertise__r.Is_Pre_Req_Lock__c, competency_title__c, Competency_Credit_Equivalency__c,
                                Competency_Code__c,SME__c,SME__r.Name,
                                Description__c, Competency__r.Description__c, Start_Date__c,
                                Target_Date__c, Assessment_Submitted__c, Pause_Competency__c, competency__r.Assessment_Type__c, (
                                SELECT Id, Competency_Shell_ID__c
                                FROM Student_Sections__r
                                LIMIT 1
                        )
                        From Student_Competency__c
                        where Student_Program__c = :sProgram.Id AND clp_active__c = TRUE
                        and Competency_Code__c != 'TL000' and
                        (Completed_Date__c = null OR
                        (Completed_Date__c >= :startDate and
                        Completed_Date__c <= :endDate))
                        order by Start_Date__c DESC NULLS LAST, status__c ASC NULLS LAST
                ];

            } else if (sortOrder == 'submitDateAsc' || stuProg.Sort_Order__c == 'submitDateAsc') {
                system.debug('SortCategory4');
                studentCompetencies = [
                        Select Student_Program__c,Student_Expertise__r.Is_Pre_Req_Lock__c, Status__c, competency_title__c, Competency_Credit_Equivalency__c, Competency__r.Description__c,
                                Competency_Code__c,SME__c,SME__r.Name, Description__c,
                                Start_Date__c, Target_Date__c, Assessment_Submitted__c, Pause_Competency__c, competency__r.Assessment_Type__c, (
                                SELECT Id, Competency_Shell_ID__c
                                FROM Student_Sections__r
                                LIMIT 1
                        )
                        From Student_Competency__c
                        where Student_Program__c = :sProgram.Id AND clp_active__c = TRUE
                        and Competency_Code__c != 'TL000' and
                        (Completed_Date__c = null OR
                        (Completed_Date__c >= :startDate and
                        Completed_Date__c <= :endDate))
                        order by Target_Date__c ASC NULLS LAST, status__c ASC NULLS LAST
                ];

            } else if (sortOrder == 'submitDateDesc' || stuProg.Sort_Order__c == 'submitDateDesc') {
                system.debug('SortCategory5');
                studentCompetencies = [
                        Select Student_Program__c,Student_Expertise__r.Is_Pre_Req_Lock__c, Status__c, competency_title__c, Competency_Credit_Equivalency__c,
                                Competency_Code__c,SME__c,SME__r.Name, Description__c,
                                Start_Date__c,Competency__r.Description__c, Target_Date__c, Assessment_Submitted__c, Pause_Competency__c, competency__r.Assessment_Type__c, (
                                SELECT Id, Competency_Shell_ID__c
                                FROM Student_Sections__r
                                LIMIT 1
                        )
                        From Student_Competency__c
                        where Student_Program__c = :sProgram.Id AND clp_active__c = TRUE
                        and Competency_Code__c != 'TL000' and (Completed_Date__c = null OR
                        (Completed_Date__c >= :startDate and
                        Completed_Date__c <= :endDate))
                        order by Target_Date__c DESC NULLS LAST, status__c ASC NULLS LAST
                ];

            }

            if (sortOrder != null) {
                if( sortOrder == 'sortStartDate' ) {
                    stuProg.Sort_Order__c = 'startDateDesc';
                } else if(  sortOrder == 'sortSubmitDate' ) {
                    stuProg.Sort_Order__c = 'submitDateDesc';
                }
                try {
                    update stuProg;
                } catch (Exception genericException) {
                    System.debug('genericException : ' + genericException.getMessage());
                }
            } else {
                sortOrder = stuProg.Sort_Order__c;
            }
             system.debug('student competencies is:' + studentCompetencies);
            Set<String> S1 = new Set<String>();
            //if( studentCompetencies != null ) {
                for (Student_Competency__c sc : studentCompetencies) {
                    s1.add(sc.Competency_Code__c);
                }
            
                List<competency__c> syllabusLink = new List<competency__c>([SELECT code__c, syllabus_link__c from competency__c WHERE code__c IN :s1]);
                Map<String, String> compSyllabus = new Map<String, String>();
                for (competency__c itr : syllabusLink) {
                    compSyllabus.put(itr.code__c, itr.syllabus_link__c) ;
    
                }
    
                String difficultlevel;
                for (Student_Competency__c sc : studentCompetencies) {
                    System.debug('SC: ' + sc);
                    compCardDetails compCardObject = new compCardDetails();
                    compCardObject.CompetencyCode = sc.Competency_Code__c;
                    compCardObject.isPreReqLock = sc.Student_Expertise__r.Is_Pre_Req_Lock__c;
                    compCardObject.CreditEquivilant = sc.Competency_Credit_Equivalency__c;
                    compCardObject.CompetencyName = sc.competency_title__c;
                    compCardObject.SMEAssignment = sc.SME__r.Name;
                    compCardObject.CompetencyDesc = sc.Competency__r.Description__c;
                    if (sc.Status__c == 'Not Achieved') {
                        sc.Status__c = 'Not-Achieved';
                    }
                    compCardObject.Status = sc.Status__c;
                    compCardObject.setStartDate = sc.Start_Date__c;
                    compCardObject.setEndDate = sc.Target_Date__c;
                    compCardObject.IsAssessmentSubmitted = sc.Assessment_Submitted__c;
                    compCardObject.IsCompetencyPaused = sc.Pause_Competency__c;
                    compCardObject.studentCompetencyId = sc.id;
                    if (!sc.Student_Sections__r.isEmpty()) {
                        compCardObject.competencyLink = brightSpaceLmsId +
                                sc.Student_Sections__r[0].Competency_Shell_ID__c;
                    }
                    compCardObject.AssessmentType = sc.competency__r.Assessment_Type__c;
                    compCardObject.SyllabusLink = compSyllabus.get(sc.Competency_Code__c);
                    CompCards.add(compCardObject);
    
                    // Determining the amount of Active Competencies for the 3 Active Competencies rule.
                    if (sc.Assessment_Submitted__c && ((sc.Status__c == 'Registered') || (sc.Status__c == 'Not Achieved') || (sc.Status__c == 'TRANSFER')) && !sc.Pause_Competency__c && sc.Competency_Code__c != 'TW001') {
                        activeCompetencies += 1;
                    }
                }
    
          //  }
            system.debug('CompCards' + CompCards);
        }
        return null;
    }
    
    private void initTempoResourcesUrl() {
        Tempo_Resources__c tempoResources = Tempo_Resources__c.getValues('Main Resources');
        tempoResourcesUrlList = new List<String>();
        if (tempoResources != null ) {
            tempoResourcesUrlList.add(tempoResources.Walden_University_Library__c);
            tempoResourcesUrlList.add(tempoResources.Walden_Catalog__c);
            tempoResourcesUrlList.add(tempoResources.Writing_Center__c);
            tempoResourcesUrlList.add(tempoResources.APA_Resources__c);
            tempoResourcesUrlList.add(tempoResources.Career_Services_Center__c);
            tempoResourcesUrlList.add(tempoResources.myFinAid__c);
            tempoResourcesUrlList.add(tempoResources.Payment_Portal__c);
        }
    }

    public class AreaOfExpertiseWrapper {
        String areaOfExpDescription { get; set; }
        Integer totalCount { get; set; }
        Integer completedCount { get; set; }
    }

    public class compCardDetails {
        public String CompetencyCode { get; set; }
        public Boolean isPreReqLock { get; set; }
        public String studentCompetencyId { get; set; }
        public Double CreditEquivilant { get; set; }
        public String CompetencyName { get; set; }
        public String SMEAssignment { get; set; }
        public String CompetencyDesc { get; set; }
        public String AssessmentType { get; set; }
        public String SyllabusLink { get; set; }
        public String Status { get; set; }
        public String areaOfExpertise { get; set; }
        public String areaOfExpDescription { get; set; }
        public Date setStartDate { get; set; }
        public Date setEndDate { get; set; }
        public Boolean IsAssessmentSubmitted { get; set; }
        public Boolean IsCompetencyPaused { get; set; }
        public Boolean isCompleted;
        public String competencyLink { get; set; }

        public compCardDetails() {

        }

        public compCardDetails(String CompetencyCode, Double CreditEquivilant, String CompetencyName, String SMEAssignment, String CompetencyDesc, String AssessmentType, String SyllabusLink, String Status, date setStartDate, date setEndDate, Boolean IsAssessmentSubmitted, Boolean IsCompetencyPaused) {
            this.CompetencyCode = CompetencyCode;
            this.isPreReqLock = isPreReqLock;
            this.CreditEquivilant = creditEquivilant;
            this.CompetencyName = CompetencyName;
            this.SMEAssignment = SMEAssignment;
            this.CompetencyDesc = CompetencyDesc;
            this.AssessmentType = AssessmentType;
            this.SyllabusLink = SyllabusLink;
            this.Status = Status;
            this.setStartDate = setStartDate;
            this.setEndDate = setEndDate;
            this.IsAssessmentSubmitted = IsAssessmentSubmitted;
            this.IsCompetencyPaused = IsCompetencyPaused;
        }
    }

}