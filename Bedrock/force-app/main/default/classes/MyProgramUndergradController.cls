/*******************************************************************
Name  : MyProgramUndergradController
Author: Ravitej Varada (Laureate)
Date  : Mar 07, 2018
Description: Controller extension class for MyProgramUndergrad Page

* Revision History
* Horacio Sanchez   10/27/2020     S-28150 Making My Program (Undergrad) available for Inactive Students
* Horacio Sanchez   01/19/2021     Prod Defect 40082: Tempo: SMEs are not displayed on Portal
* Horacio Sanchez   03/12/2021     S-45097 Tempo: Update Program Name in Tempo portal
* Horacio Sanchez   05/24/2022     S-89059 Update Tempo Portal Navigation Menu if ATC Start Date is Today
*************************************************************************/
public without sharing class MyProgramUndergradController {
    //--expertisewiseCompetencies grouping
    public List<customMap> expertiseWiseCompetencies { get; set; }
    public Map<String, AreaOfExpertiseWrapper> nameToAreaOfExpertiseWrapper { get; set; }
    public Integer activeCompetencies { get; set; }
    public Student_Program__c sProgram { get; set; }
    public String currentUserId {get;set;}
    Public String studentProgramId{get;set;}
    public String contactId {get;set;}
    public String waldenEmail { get; set; }
    public String waldenEmailHash { get; set; }
    public String studentName { get; set; }
    public string modalHeader { get; set; }
    public string modalBody { get; set; }
    public Boolean isModalWindow { get; set; }    
    public Boolean isAgreedCreditText {get;set;}
    public String degreeLevel { get; set; }
    public String intercomAppId { get; set; }
    public string isAddedFromProgramPlan { get; set; }
	public String brightSpaceLmsId;
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
    public MyProgramUndergradController() {
        
        if ( ! isCommunityUser() ) {
            studentProgramId = ApexPages.currentPage().getParameters().get('id');
        } else {
            currentUserId = UserInfo.getUserId();
            User user = [ SELECT Id, ContactId FROM User WHERE Id = :currentUserId ];
            Contact contact = [ SELECT Id,email,Walden_Email__c,Name, (SELECT Id, Program__r.Degree_Level__c FROM Student_Programs__r ORDER BY CreatedDate DESC LIMIT 1) FROM CONTACT WHERE Id = :user.ContactId ];
            contactId= contact.id;
            waldenEmail = contact.email;
            waldenEmailHash = HmacSHA256Encryption.generateHmacSHA256Signature(waldenEmail); 
            studentName = contact.name;
            ApexPages.currentPage().getParameters().put('id',contact.Student_Programs__r[0].id);
            studentProgramId = ApexPages.currentPage().getParameters().get('id');
            degreeLevel = contact.Student_Programs__r[0].Program__r.Degree_Level__c;
        }
        
        Map<string, D2L__c> mapD2LCustomSettings = D2L__c.getAll();
        //System.debug('ISO Code: ' + mapCustomSettings.get('CreditEquivalentsAgreed').RecordID__c);
        If (!mapD2LCustomSettings.isEmpty()) {
            system.debug('mapD2LCustomSettings NOT EMPTY'+mapD2LCustomSettings.get('D2L').BS_LMS_URL__c);
            brightSpaceLmsId = mapD2LCustomSettings.get('D2L').BS_LMS_URL__c;
        }
        
        activeCompetencies = 0;
        System.debug('studentProgramId : ' + studentProgramId);
        this.sProgram = [
                SELECT Name,Program__r.Automate_Agree_to_Credit__c,program__r.Parent_Program__r.Program_Guide_Link__c,program__r.Program_Guide_Link__c, Student_Full_Name__c, 
                        Current_Student_Subscription__c, CurrentSubscriptionStartDate__c, CurrentSubscriptionEndDate__c, Program__r.Display_Name__c,
                        IsStudentProgramActive__c, Id,Program__c ,Current_Student_Subscription__r.Agreed_To_Credits__c, Current_Student_Subscription__r.Start_Date__c,
                        Current_Student_Subscription__r.Number_of_Credits_Completed__c,Student__r.Name,CoachEmail__c,Coach__r.Name, 
                        Program__r.Name,Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c,student__r.CBL_Student_ID__c,Program_Start_Date__r.Name, (
                        SELECT Id, Student_Program__c, Status__c, competency_title__c, Competency_Credit_Equivalency__c,
                                Competency_Code__c,SME__c,SME__r.Name, Description__c, Start_Date__c, Target_Date__c, Assessment_Submitted__c, Pause_Competency__c, Area_Of_Expertise_Name__c,
                                Student_Expertise__r.Program_Expertise__r.Overview__c, isCompleted__c, competency__r.Description__c,competency__r.Assessment_Type__c,
                                Student_Expertise__r.Program_Expertise__r.Learning_Order__c,Student_Expertise__r.Area_of_Expertise__r.Overview__c,
                                Student_Expertise__r.Is_Removed_from_Program_Plan__c,Program_Competency__r.Program_Expertise__r.Category__c,
                            	Student_Expertise__r.Audit_Category__c,
                                Program_Competency__r.Program_Expertise__r.Pseudo_Course__c,
                            	Student_Expertise__r.Area_of_Expertise__r.Display_On_Web__c,
                                Student_Expertise__r.Is_Added_from_Program_Plan__c,
                                Competency_Version__r.Competency_Shell_ID__c
                        FROM Student_Competencies__r
                        WHERE Is_Enrolled__c = true AND Student_Expertise__r.Area_of_Expertise__r.Display_On_Web__c= TRUE AND Student_Expertise__r.Is_Removed_from_Program_Plan__c = FALSE
                        ORDER BY Competency_Code__c ASC NULLS LAST 
                )
                FROM Student_Program__c
                WHERE Id = :studentProgramId
        ];
        getStudentComp(sProgram);    
        //Custom Settings to retrive Brand Conf Record ID to display Header and Body for Model Window
         Community_Site_Settings__c defaultCustomSetngs = Community_Site_Settings__c.getValues('Default Settings');
        if( defaultCustomSetngs != null ) {
            Brand_Configuration__c BC = [Select id,name,Sub_Type__c,Body__c from Brand_Configuration__c where id = :defaultCustomSetngs.RecordID__c];
            modalHeader = BC.Sub_Type__c;
            modalBody = BC.Body__c;
            intercomAppId = defaultCustomSetngs.Intercom_App_Id__c ;

        }
         If(sProgram.Current_Student_Subscription__r.Agreed_To_Credits__c != null &&
                    sProgram.Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c != null){
            isAgreedCreditText = TRUE;
            
        }
        
        //displayModalWindow();
         
        isATCCompleted = true;
        
        // S-89059: Update Tempo Portal Navigation Menu if ATC Start Date is Today
        // Checking if Agree to Credits process has been completed
        if (sProgram.Current_Student_Subscription__c != null 
            && (sProgram.Current_Student_Subscription__r.Agreed_To_Credits__c == null || sProgram.Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c == null) 
            && sProgram.Program__r.Automate_Agree_to_Credit__c
            && sProgram.Current_Student_Subscription__r.Start_Date__c.daysBetween(Date.today()) < 15) {
            isATCCompleted = false;
        }
    
    }

    // If Graduate student tries to access My Program for UG, it will be redirected to Graduate page.
    public PageReference degreeLevelCheck() {
        if (degreeLevel == 'Graduate') {
            PageReference myGraduatePage = new PageReference('/ProgramOverview');
            myGraduatePage.setRedirect(true);
            return myGraduatePage;
        }
        
        // S-89059: Update Tempo Portal Navigation Menu if ATC Start Date is Today
        // Checking if Agree to Credits process has been completed
        if (!isATCCompleted) {
            PageReference myTermPage = new PageReference('/MyTerm');
            myTermPage.setRedirect(true);
            return myTermPage;
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

    public List<compCardDetails> getStudentComp(Student_Program__c sProgram) {
                system.debug('$$$$$$$$$sProgram Size'+sProgram.Student_Competencies__r.size());

        List<compCardDetails> CompCards = new List<compCardDetails>();
        if (sProgram != null) {

            Set<String> S1 = new Set<String>();
            for (Student_Competency__c sc : sProgram.Student_Competencies__r) {
                s1.add(sc.Competency_Code__c);
            }
             List<competency__c> syllabusLink = new List<competency__c>([SELECT code__c, syllabus_link__c from competency__c WHERE code__c IN :s1]);
            Map<String, String> compSyllabus = new Map<String, String>();
            for (competency__c itr : syllabusLink) {
                compSyllabus.put(itr.code__c, itr.syllabus_link__c) ;

            }
            
            
            for (Student_Competency__c sc : sProgram.Student_Competencies__r) {
                System.debug('SC: ' + sc);
                compCardDetails compCardObject = new compCardDetails();
                compCardObject.CompetencyCode = sc.Competency_Code__c;
                compCardObject.CreditEquivilant = sc.Competency_Credit_Equivalency__c;
                compCardObject.CompetencyName = sc.competency_title__c;
                compCardObject.isAddedFromProgramPlan = sc.Student_Expertise__r.Is_Added_from_Program_Plan__c;
                compCardObject.SMEAssignment = sc.SME__r.Name;
                compCardObject.aoeLearningOrder = Integer.valueOf(sc.Student_Expertise__r.Program_Expertise__r.Learning_Order__c);
                compCardObject.CompetencyDesc = sc.competency__r.Description__c;
                if (sc.Status__c == 'Not Achieved') {
                    sc.Status__c = 'Not-Achieved';
                }
                compCardObject.Status = sc.Status__c;
                compCardObject.setStartDate = sc.Start_Date__c;
                compCardObject.setEndDate = sc.Target_Date__c;
                compCardObject.IsAssessmentSubmitted = sc.Assessment_Submitted__c;
                compCardObject.IsCompetencyPaused = sc.Pause_Competency__c;
                compCardObject.areaOfExpertiseDescription = sc.Student_Expertise__r.Area_of_Expertise__r.Overview__c;
                compCardObject.areaOfExpertise = sc.Area_Of_Expertise_Name__c;
                compCardObject.isCompleted = sc.isCompleted__c;
                compCardObject.AssessmentType = sc.competency__r.Assessment_Type__c;

                if( String.isNotBlank(sc.Student_Expertise__r.Audit_Category__c) ) {
                    compCardObject.category = sc.Student_Expertise__r.Audit_Category__c;
                }
                compCardObject.SyllabusLink = compSyllabus.get(sc.Competency_Code__c);
                compCardObject.competencyLink = brightSpaceLmsId + sc.Competency_Version__r.competency_shell_id__c;
                CompCards.add(compCardObject);
            }

        }
        system.debug('CompCards' + compCards);
        system.debug('@@@@@@@@@CompCards' + compCards.size());
        buildCompetenciesByExpertise(compCards);
        return CompCards;
    }

    void buildCompetenciesByExpertise(List<compCardDetails> compCards) {
        Map<String, List<AreaOfExpertiseWithCompetencies>> expertiseWiseCompetencies_p = new Map<String, List<AreaOfExpertiseWithCompetencies>>();
        Map<Integer, String> learningOrderToAOEName = new Map<Integer, String>();
        
        nameToAreaOfExpertiseWrapper = new Map<String, AreaOfExpertiseWrapper>();
        Integer count = 1000000;
        for (compCardDetails compCard : compCards) {
            if (String.isNotBlank(compCard.areaOfExpertise)) {
                if (expertiseWiseCompetencies_p.containsKey(compCard.areaOfExpertise)) {
                    AreaOfExpertiseWrapper aoeWrapper = new AreaOfExpertiseWrapper();
                    aoeWrapper.areaOfExpertiseDescription = compCard.areaOfExpertiseDescription;
                    List<AreaOfExpertiseWithCompetencies> aoeWithCompetencies = expertiseWiseCompetencies_p.get(compCard.AreaOfExpertise);
                    System.debug('compCard : ' + compCard);
                    System.debug('compCard.areaOfExpertiseDescription: ' + compCard.areaOfExpertiseDescription);
                    aoeWithCompetencies.add(new AreaOfExpertiseWithCompetencies(
                            compCard.areaOfExpertiseDescription, compCard));
                    expertiseWiseCompetencies_p.put(compCard.AreaOfExpertise, aoeWithCompetencies);
                    
                    nameToAreaOfExpertiseWrapper.get(compCard.areaOfExpertise).totalCount++;
                    if (compCard.isCompleted) {
                        nameToAreaOfExpertiseWrapper.get(compCard.areaOfExpertise).completedCount++;
                    }
                } else {
                    AreaOfExpertiseWrapper aoeWrapper = new AreaOfExpertiseWrapper();
                    aoeWrapper.areaOfExpertiseDescription = compCard.areaOfExpertiseDescription;
                    if( String.isNotBlank(compCard.category) ) {
                        aoeWrapper.categoryLst = compCard.category.split(';');
                    }
                    if( compCard.aoeLearningOrder != null ) {
                        learningOrderToAOEName.put(compCard.aoeLearningOrder, compCard.AreaOfExpertise);
                    } else {
                        learningOrderToAOEName.put( count, compCard.AreaOfExpertise);
                    }
                    count++;
                    AreaOfExpertiseWithCompetencies aoeWithCompetency = new AreaOfExpertiseWithCompetencies(
                            compCard.areaOfExpertiseDescription, compCard);
                     expertiseWiseCompetencies_p.put(compCard.AreaOfExpertise, new List<AreaOfExpertiseWithCompetencies>{
                            aoeWithCompetency
                    });
                    aoeWrapper.totalCount = 1;
                    if (compCard.isCompleted) {
                        aoeWrapper.completedCount = 1;
                    } else {
                        aoeWrapper.completedCount = 0;
                    }
                    nameToAreaOfExpertiseWrapper.put(compCard.areaOfExpertise, aoeWrapper);
                    

                }
            }
        }
        List<Integer> learningOrders = new List<Integer> (learningOrderToAOEName.keySet());
        learningOrders.sort();
        System.debug('learningOrders : ' + learningOrders);
        expertiseWiseCompetencies = new List<customMap>();
        System.debug('learningOrderToAOEName : ' + learningOrderToAOEName.keyset().size() );
        System.debug('learningOrderToAOEName : ' + learningOrderToAOEName.values().size() );
        for( Integer learningOrder : learningOrders) {
        System.debug('learningOrderToAOEName : ' + learningOrderToAOEName + '  Learning order : ' + learningOrder);
            
            customMap instance = new customMap();
            instance.key = learningOrderToAOEName.get(learningOrder);
            instance.value1 = expertiseWiseCompetencies_p.get(learningOrderToAOEName.get(learningOrder));
            expertiseWiseCompetencies.add(instance);  
        }
        System.debug('expertiseWiseCompetencies_p : ' + json.serializepretty(expertiseWiseCompetencies_p));
        System.debug('nameToAreaOfExpertiseWrapper : ' + json.serializepretty(nameToAreaOfExpertiseWrapper));
        System.debug('nameToAreaOfExpertiseWrapper : ' + json.serializepretty(expertiseWiseCompetencies));
    }
    private class AreaOfExpertiseWrapper {
        public String areaOfExpertiseDescription { get; set; }
        public Integer totalCount { get; set; }
        public Integer completedCount { get; set; }
        public List<String> categoryLst { get; set;}
        public AreaOfExpertiseWrapper() {

        }

        public AreaOfExpertiseWrapper(String areaOfExpertiseDescription, Integer totalCount, Integer completedCount, List<String> categoryLst) {
            this.areaOfExpertiseDescription = areaOfExpertiseDescription;
            this.totalCount = totalCount;
            this.completedCount = completedCount;
        }
    }
    
    public class customMap {
        public String key{get;set;}
        public List<AreaOfExpertiseWithCompetencies> value1{get;set;}
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
        public Boolean IsAssessmentSubmitted { get; set; }
        public Boolean IsCompetencyPaused { get; set; }
        public Boolean isCompleted;
        public String competencyLink { get; set; }
        public Boolean isAddedFromProgramPlan { get; set; }
        Integer aoeLearningOrder;
        public String category { get; set; }
        public compCardDetails() {

        }

        public compCardDetails(String CompetencyCode, Double CreditEquivilant, String CompetencyName, String SMEAssignment, String CompetencyDesc, String AssessmentType, String SyllabusLink, String Status, date setStartDate, date setEndDate, Boolean IsAssessmentSubmitted, Boolean IsCompetencyPaused) {
            this.CompetencyCode = CompetencyCode;
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
            this.isAddedFromProgramPlan = isAddedFromProgramPlan;
        }
    }
}