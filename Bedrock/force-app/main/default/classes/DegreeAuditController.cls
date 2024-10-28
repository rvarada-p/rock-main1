/************************************************************************************** 
 Apex Class Name     : DegreeAuditController
 Created Date        : 26th April 2018
 Function            : Controller class for DegreeAudit Page
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ravitej Varada            04/26/2018                Original Version
*
* Revision History
* Horacio Sanchez		01/18/2021		S-39002: Tempo: Statistics Category: Add New Program Category Requirements for BSN Program (Step 1)
* Horacio Sanchez       01/27/2021      S-38826: Tempo: Add Preliminary Transfer Credits on Grad and UG degree audit
* Horacio Sanchez       10/18/2021      S-69140: L2: Update Degree Audit page reference
*************************************************************************************/
public with sharing class DegreeAuditController {
    public Student_Program__c studentProgram{get; set;}
    public Student_Program__c sProgram {get;set;}
    public List<String> rules = new List<String>();
    public List<DegreeAuditInfoWrapper> lstDegreeAuditInfoWrapper{get; set;}
    public List<Student_Expertise__c> lstStudentExperise = new List<Student_Expertise__c>();
    public List<Student_Expertise__c> listSubjectAreaExpertiseSE = new List<Student_Expertise__c>();
    public Map<String, Decimal> bucketToRequiredCredit = new Map<String, Decimal>();
    public Id studentProgramId { get; set; }
    public String degreeLevel { get; set; }
    public String currentUserId {get;set;}
    public String contactId {get;set;}
    public String waldenEmail { get; set; }
    public String waldenEmailHash { get; set; }
    public string modalHeader { get; set; }
    public string modalBody { get; set; }
    public String intercomAppId { get; set; }
     public decimal earnedUpperLevelCredits { get; set; }
    public String studentName { get; set; }
    public Boolean isModalWindow { get; set; }
    public Boolean isAgreedCreditText {get;set;}
    public String error {get;set;}
    public Double totalCreditsInProgram {get;set;}
    public ExternalDegreeSP edsp {get;set;}
    public Double ugProgramCompletion {get;set;}
    public Boolean isMSNRNProgram {get;set;}
    private Set<String> seIdsPreliminaryTransferSet;
    
    Boolean isCommunityUser() {
        if('Customer Community Login'.equals( ([ Select UserLicense.Name  FROM Profile WHERE Id =: userinfo.getProfileid()]).UserLicense.Name) ) {
            return true;
        } else {
            return false;
        }
    }
    
    //This method updates the Date_Student_Agreed_To_Credits__c field  when "Agreed to credit Equavalence" Button is clicked.
    public void updateAgreedToCreditsDate() {
        Student_Subscription__c studentSubscription = new Student_Subscription__c(id = studentProgram.Current_Student_Subscription__c);
        studentSubscription.Date_Student_Agreed_To_Credits__c = date.today();
        update studentSubscription;
        isModalWindow = false;
        isAgreedCreditText = true;
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
    //This method updates the Is_Welcome_Message__c field  when "Get Started" Button is clicked on Welcome Model .
    public void updateWelcomeMessage() {
        studentProgram.Is_Welcome_Message__c = false;
        update studentProgram;
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
    
    //controller
    public DegreeAuditController(ApexPages.StandardController controller) {
        earnedUpperLevelCredits = 0;
        
        if ( ! isCommunityUser() ) {
            studentProgramId = ApexPages.currentPage().getParameters().get('id');
                        system.debug('id'+studentProgramId);

        } else {
            currentUserId = UserInfo.getUserId();
            User user = [ SELECT Id, ContactId FROM User WHERE Id = :currentUserId ];
            Contact contact = [ SELECT Id,Walden_Email__c , email,(SELECT Id, Program__r.Degree_Level__c FROM Student_Programs__r WHERE IsStudentProgramActive__c = true
                                LIMIT 1) FROM CONTACT WHERE Id = :user.ContactId ];
            contactId= contact.id;
            waldenEmail = contact.email;
            waldenEmailHash = HmacSHA256Encryption.generateHmacSHA256Signature(waldenEmail); 
            ApexPages.currentPage().getParameters().put('id',contact.Student_Programs__r[0].id);
            ApexPages.currentPage().getParameters().get('id');
            studentProgramId = ApexPages.currentPage().getParameters().get('id');
            degreeLevel = contact.Student_Programs__r[0].Program__r.Degree_Level__c;
        }
        
        //Custom Settings to retrive Brand Conf Record ID to display Header and Body for Model Window
        Community_Site_Settings__c defaultCustomSetngs = Community_Site_Settings__c.getValues('Default Settings');
        if( defaultCustomSetngs != null ) {
            Brand_Configuration__c BC = [Select id,name,Sub_Type__c,Body__c from Brand_Configuration__c where id = :defaultCustomSetngs.RecordID__c];
            modalHeader = BC.Sub_Type__c;
            modalBody = BC.Body__c;
            intercomAppId = defaultCustomSetngs.Intercom_App_Id__c ;      
        }
        
//        displayModalWindow();
        
        if(!test.isRunningTest()){  
            controller.addfields(new List<string>{'Program__c' });
        }
        
        studentProgram = (Student_Program__c)controller.getRecord();
        
        sProgram = [SELECT Id, Current_Student_Subscription__c, Program__r.Automate_Agree_to_Credit__c,current_student_subscription__r.agreed_to_credits__c,
                           current_student_subscription__r.date_student_agreed_to_credits__c,
                           is_welcome_message__c, student__r.name,
                           Total_Credits_in_Program__c, All_Credits_Completed__c,
                           program__r.Required_Institution_Credits__c, Number_Credits_Completed_in_all_Terms__c, fulfilled_Credit__c,
                           Number_of_Credits_Transferred__c, Program__r.ProductCode,
                           program__r.Required_Upper_Level_Credits__c, Number_of_Upper_Level_Credits__c, Program_Completion__c,
                    	   Program_Version__r.Required_Upper_Level_Credits__c
                    FROM Student_Program__c
                    WHERE Id = :studentProgram.Id];
        if (sProgram != null) {
            studentName = sProgram.Student__r.name;
            edsp = new ExternalDegreeSP();
            edsp.totalCreditsInProgram = sProgram.Total_Credits_in_Program__c;
            edsp.allCreditsCompleted = sProgram.All_Credits_Completed__c;
            edsp.requiredInstitutionCredits = sProgram.program__r.Required_Institution_Credits__c;
            edsp.numberCreditsCompletedAllTerms = sProgram.Number_Credits_Completed_in_all_Terms__c;
            edsp.numberCreditsTransferred = sProgram.Number_of_Credits_Transferred__c;
            edsp.requiredUpperLevelCredits = sProgram.program__r.Required_Upper_Level_Credits__c;
            edsp.numberUpperLevelCredits = sProgram.Number_of_Upper_Level_Credits__c;
            ugProgramCompletion = sProgram.Program_Completion__c / 100;
            isMSNRNProgram = isMSN_RNProgram(sProgram.Program__r.ProductCode);
        }    
        
       //try{
      List<Student_Expertise__c> StuExpLst = [ SELECT Id, Student_Program__r.Program__c,
                                                               Area_of_Expertise_Name__c,Area_of_Expertise__c,Pseudo_CE__c, Total_Applied_Earned_CE_Outcome__c,
                                                                 Audit_Category__c,Contact__c,External_Key__c, IsAchieved__c,IsDeleted,Level_Type__c,
                                                                 Name,Number_of_Competencies_Completed__c,Number_of_Competencies_Transferred__c,
                                                                 Opportunity__c,Outcome_Category__c, Outcome_Subject_Area_Expertise__c, Program_Expertise__c,Area_of_Expertise__r.Category__c,
                                                                 Area_of_Expertise__r.Level__c,Area_of_Expertise__r.Level_Type__c,Program_Expertise__r.Category__c,
                                                                 Program_Institution__c,Program_Name__c,Pseudo_Course__c,Area_of_Expertise__r.Course_Code__c ,
                                              RecordTypeId,Student_Name__c,Student_Program__c,Total_CE__c, Subject_Area_Expertise__c
                                              FROM Student_Expertise__c
                                              WHERE Student_Program__c = :studentProgram.id  ];
        
        populatePreliminaryTransferSE(stuExpLst);
        
        for (Student_Expertise__c se: StuExpLst) {
            if (se.Pseudo_Course__c == false) {
                lstStudentExperise.add(se);  
            } else if(se.IsAchieved__c == true && se.Pseudo_Course__c == true) {
                lstStudentExperise.add(se);
            } else if (seIdsPreliminaryTransferSet.contains(se.Id)) {
                lstStudentExperise.add(se);
            }
            //if(se.Level_Type__c != null && se.Level_Type__c == 'Upper'&& se.IsAchieved__c == True){
            if(se.Level_Type__c != null && se.Level_Type__c == 'Upper'&& se.IsAchieved__c == True &&  se.Outcome_Category__c != 'Back' && se.Outcome_Category__c != Null){
                earnedUpperLevelCredits += se.Total_CE__c;
            }
        }
        
        Product2 productRecord = [ SELECT id,name,( SELECT id,name,Category__c ,Level__c  ,Total_CE__c, Subject_Area_Expertise__c
                                                   FROM Degree_Requirements__r) 
                                  FROM Product2 
                                  WHERE id= :studentProgram.program__c ];
        
        
        for( Program_Category_Requirement__c degreeRequirement : productRecord.Degree_Requirements__r ) {
            
            if (degreeRequirement.Category__c == 'Core' && degreeRequirement.Level__c =='Upper') {
                bucketToRequiredCredit.put('Core Upper', degreeRequirement.Total_CE__c);
            } else if (degreeRequirement.Category__c == 'Core' && degreeRequirement.Level__c =='Lower') {
                bucketToRequiredCredit.put('Core Lower', degreeRequirement.Total_CE__c);
            } else if (degreeRequirement.Category__c == 'Concentration' && degreeRequirement.Level__c =='Any') {
                bucketToRequiredCredit.put('Concentration', degreeRequirement.Total_CE__c);
            } else if (degreeRequirement.Category__c == 'General Education' && degreeRequirement.Subject_Area_Expertise__c == null ) {
                bucketToRequiredCredit.put('General Education', degreeRequirement.Total_CE__c);
            } else if (degreeRequirement.Category__c == 'General Education' && degreeRequirement.Subject_Area_Expertise__c == 'Arts and Humanities') {
                bucketToRequiredCredit.put('Arts and Humanities', degreeRequirement.Total_CE__c);
            } else if (degreeRequirement.Category__c == 'General Education' && degreeRequirement.Subject_Area_Expertise__c == 'Mathematics/Natural Sciences') {
                bucketToRequiredCredit.put('Mathematics/Natural Sciences', degreeRequirement.Total_CE__c);
            } else if (degreeRequirement.Category__c == 'General Education' && degreeRequirement.Subject_Area_Expertise__c == 'Social Sciences') {
                bucketToRequiredCredit.put('Social Sciences', degreeRequirement.Total_CE__c);
            } else if (degreeRequirement.Category__c == 'General Education' && degreeRequirement.Subject_Area_Expertise__c == 'Written and Oral Communication') {
                bucketToRequiredCredit.put('Written and Oral Communication', degreeRequirement.Total_CE__c);
            } else if (degreeRequirement.Category__c == 'General Education' && degreeRequirement.Subject_Area_Expertise__c == 'Statistics') {
                bucketToRequiredCredit.put('Statistics', degreeRequirement.Total_CE__c);
            } else if (degreeRequirement.Category__c == 'General Education' && degreeRequirement.Subject_Area_Expertise__c == 'Any Category') {
                bucketToRequiredCredit.put('Any Category', degreeRequirement.Total_CE__c);
            }else if(degreeRequirement.Category__c == 'General Elective' && degreeRequirement.Level__c =='Any'){
                bucketToRequiredCredit.put('General Elective', degreeRequirement.Total_CE__c);
            }       
            
        }
        
        Map<String, Decimal> bucketToEarnedCredit = new Map<String, Decimal>();
           try{
         Student_Audit_History__c auditHistory = [ SELECT CreatedDate,Earned_Back__c,Earned_CE_Concentration__c,Earned_CE_Core_Upper__c,
                                                     Earned_CE_Core__c,Earned_CE_General_Education__c,Earned_CE_General_Electives__c,
                                                     LastModifiedDate,Student_Program__c,Total_CE_Concentration__c,Total_CE_Core_Upper__c,
                                                     Total_CE_Core__c,Total_CE_General_Education__c,Total_CE_General_Electives__c,
                                                     Earned_CE_Arts_and_Humanities__c, Earned_CE_Mathematics_Natural_Science__c, Earned_CE_Social_Science__c, Earned_CE_Written_and_Oral_Communication__c, Earned_CE_Any_Category__c, Earned_CE_Statistics__c,
                                                     Total_CE_Arts_and_Humanities__c, Total_CE_Mathematics_Natural_Science__c, Total_CE_Social_Science__c, Total_CE_Written_and_Oral_Communication__c, Total_CE_Any_Category__c, Total_CE_Statistics__c
                                                 FROM Student_Audit_History__c  
                                                 WHERE Student_Program__c = :studentProgram.id
                                                 ORDER BY Name DESC NULLS 
                                                 LAST LIMIT 1 ];
        
        bucketToEarnedCredit.put('Core Upper', auditHistory.Earned_CE_Core_Upper__c);
        bucketToEarnedCredit.put('Core Lower', auditHistory.Earned_CE_Core__c);
        bucketToEarnedCredit.put('Concentration', auditHistory.Earned_CE_Concentration__c);
        bucketToEarnedCredit.put('General Education', auditHistory.Earned_CE_General_Education__c);
        bucketToEarnedCredit.put('Arts and Humanities', auditHistory.Earned_CE_Arts_and_Humanities__c);
        bucketToEarnedCredit.put('Mathematics/Natural Sciences', auditHistory.Earned_CE_Mathematics_Natural_Science__c);
        bucketToEarnedCredit.put('Social Sciences', auditHistory.Earned_CE_Social_Science__c);
        bucketToEarnedCredit.put('Written and Oral Communication', auditHistory.Earned_CE_Written_and_Oral_Communication__c);
        bucketToEarnedCredit.put('Statistics', auditHistory.Earned_CE_Statistics__c);
        bucketToEarnedCredit.put('Any Category', auditHistory.Earned_CE_Any_Category__c);       
        bucketToEarnedCredit.put('General Elective', auditHistory.Earned_CE_General_Electives__c);
        bucketToEarnedCredit.put('Back',auditHistory.Earned_Back__c);

          }catch (Exception exp) {
            system.debug(exp);
        }
        Map<String, List<Student_Expertise__c>> bucketToStudentExpertises = new Map<String, List<Student_Expertise__c>>();
        
        for(Student_Expertise__c stuExp: lstStudentExperise ) {
            String outComeCategory = '';
            if (stuExp.Outcome_Category__c == null) {
                if (stuExp.Audit_Category__c == 'Core') {
                    outComeCategory = stuExp.Audit_Category__c +' '+stuExp.Level_Type__c;
                } else if (stuExp.Audit_Category__c == 'General Education' || 
                         stuExp.Audit_Category__c == 'General Elective' ||
                         stuExp.Audit_Category__c == 'Concentration' || 
                         stuExp.Audit_Category__c =='General Education; General Elective') {
                    outComeCategory= stuExp.Audit_Category__c;                             
                }
            } else {
                outComeCategory =  stuExp.Outcome_Category__c ;
            }
            
            if(outComeCategory == 'Core Upper'){
                if( bucketToStudentExpertises.containsKey('Core Upper')) {
                    List<Student_Expertise__c> studentExpertises = bucketToStudentExpertises.get('Core Upper');
                    studentExpertises.add(stuExp);
                    bucketToStudentExpertises.put('Core Upper', studentExpertises);
                } else {
                    bucketToStudentExpertises.put('Core Upper', new List<Student_Expertise__c>{stuExp});
                }
            } else if (outComeCategory == 'Core Lower') {
                if (bucketToStudentExpertises.containsKey('Core Lower')) {
                    List<Student_Expertise__c> studentExpertises = bucketToStudentExpertises.get('Core Lower');
                    studentExpertises.add(stuExp);
                    bucketToStudentExpertises.put('Core Lower', studentExpertises);
                } else {
                    bucketToStudentExpertises.put('Core Lower', new List<Student_Expertise__c>{stuExp});
                }
            } else if(outComeCategory == 'Concentration'){
                if( bucketToStudentExpertises.containsKey('Concentration')) {
                    List<Student_Expertise__c> studentExpertises = bucketToStudentExpertises.get('Concentration');
                    studentExpertises.add(stuExp);
                    bucketToStudentExpertises.put('Concentration', studentExpertises);
                } else {
                    bucketToStudentExpertises.put('Concentration', new List<Student_Expertise__c>{stuExp});
                }
            } else if(outComeCategory == 'General Education' || outComeCategory == 'General Education; General Elective') {
                if (bucketToStudentExpertises.containsKey('General Education')) {
                    List<Student_Expertise__c> studentExpertises = bucketToStudentExpertises.get('General Education');
                    studentExpertises.add(stuExp);
                    bucketToStudentExpertises.put('General Education', studentExpertises);
                } else {
                    bucketToStudentExpertises.put('General Education', new List<Student_Expertise__c>{stuExp});
                }
            }else if(outComeCategory == 'General Elective'){
                if( bucketToStudentExpertises.containsKey('General Elective')) {
                    List<Student_Expertise__c> studentExpertises = bucketToStudentExpertises.get('General Elective');
                    studentExpertises.add(stuExp);
                    bucketToStudentExpertises.put('General Elective', studentExpertises);
                } else {
                    bucketToStudentExpertises.put('General Elective', new List<Student_Expertise__c>{stuExp});
                }
            }else if(outComeCategory == 'Back'){
                if( bucketToStudentExpertises.containsKey('Back')) {
                    List<Student_Expertise__c> studentExpertises = bucketToStudentExpertises.get('Back');
                    studentExpertises.add(stuExp);
                    bucketToStudentExpertises.put('Back', studentExpertises);
                } else {
                    bucketToStudentExpertises.put('Back', new List<Student_Expertise__c>{stuExp});
                }
            }
        }
          
        lstDegreeAuditInfoWrapper = new List<DegreeAuditInfoWrapper>();
        for (String rule : getRules()) {
            DegreeAuditInfoWrapper degreeAuditInfoWrapperInstance = new DegreeAuditInfoWrapper();
            if (rule.contains('Core') && rule.contains('Upper')) {
                degreeAuditInfoWrapperInstance.category = 'Core';
                degreeAuditInfoWrapperInstance.level = ' - Upper';
            } else if (rule.contains('Core') && rule.contains('Lower')) {
                degreeAuditInfoWrapperInstance.category = 'Core';
                degreeAuditInfoWrapperInstance.level = ' - Lower';
            } else if (rule.contains('Concentration') ) {
                degreeAuditInfoWrapperInstance.category = 'Concentration';
                degreeAuditInfoWrapperInstance.level = ' - Any';
            } else if (rule.contains('General Education') ) {
                degreeAuditInfoWrapperInstance.category = 'General Education';
                degreeAuditInfoWrapperInstance.level = '';
            } else if (rule.contains('Arts and Humanities') ) {
                degreeAuditInfoWrapperInstance.category = 'Arts and Humanities';
                degreeAuditInfoWrapperInstance.level = '';
                degreeAuditInfoWrapperInstance.outcomeSubjectAreaExpertise = rule;
            } else if (rule.contains('Mathematics/Natural Sciences') ) {
                degreeAuditInfoWrapperInstance.category = 'Mathematics/Natural Sciences';
                degreeAuditInfoWrapperInstance.level = '';
                degreeAuditInfoWrapperInstance.outcomeSubjectAreaExpertise = rule;
            } else if (rule.contains('Social Sciences') ) {
                degreeAuditInfoWrapperInstance.category = 'Social Sciences';
                degreeAuditInfoWrapperInstance.level = '';
                degreeAuditInfoWrapperInstance.outcomeSubjectAreaExpertise = rule;
            } else if (rule.contains('Written and Oral Communication') ) {
                degreeAuditInfoWrapperInstance.category = 'Written and Oral Communication';
                degreeAuditInfoWrapperInstance.level = '';
                degreeAuditInfoWrapperInstance.outcomeSubjectAreaExpertise = rule;
            } else if (rule.contains('Statistics') ) {
                degreeAuditInfoWrapperInstance.category = 'Statistics';
                degreeAuditInfoWrapperInstance.level = '';
                degreeAuditInfoWrapperInstance.outcomeSubjectAreaExpertise = rule;
            } else if (rule.contains('Any Category') ) {
                degreeAuditInfoWrapperInstance.category = 'Any Category';
                degreeAuditInfoWrapperInstance.level = '';
                degreeAuditInfoWrapperInstance.outcomeSubjectAreaExpertise = rule;
            } else if (rule.contains('General Elective') ) {
                degreeAuditInfoWrapperInstance.category = 'General Elective';
                degreeAuditInfoWrapperInstance.level = '';
            } else if (rule.contains('Back') ) {
                degreeAuditInfoWrapperInstance.category = 'Back';
                degreeAuditInfoWrapperInstance.level = '';

            }
            degreeAuditInfoWrapperInstance.requiredCredit = bucketToRequiredCredit.get(rule);
            degreeAuditInfoWrapperInstance.earnedCredit = bucketToEarnedCredit.get(rule);
            degreeAuditInfoWrapperInstance.met = degreeAuditInfoWrapperInstance.earnedCredit >= degreeAuditInfoWrapperInstance.requiredCredit ? 'Yes' : 'No';
            degreeAuditInfoWrapperInstance.lststudentexpertiseInfo = new List<studentexpertiseInfo>();
            
            if (!bucketToStudentExpertises.isempty() && bucketToStudentExpertises.containsKey(rule)) {
                for (Student_Expertise__c studentExpertise : bucketToStudentExpertises.get(rule)) {
                    StudentexpertiseInfo seInfo = new StudentexpertiseInfo();
                    seInfo.seId = studentExpertise.Id;
                    seInfo.courseCode = studentExpertise.Area_of_Expertise__r.Course_Code__c;
                    seInfo.courseTitle = studentExpertise.Area_of_Expertise_Name__c ;
                    if (studentExpertise.Outcome_Category__c != null) {
                        if (studentExpertise.IsAchieved__c) {
                         	seInfo.met = 'YES';
                        } else {
                            seInfo.met = 'NO';
                        }                 	
                        seInfo.outcomeSubjectAreaExpertise = studentExpertise.Outcome_Subject_Area_Expertise__c;
                    } else if (seIdsPreliminaryTransferSet.contains(studentExpertise.Id)) {
                        seInfo.met = 'PR';
                    } else {
                        seInfo.met = 'NO';
                    }
                    if (studentExpertise.Total_Applied_Earned_CE_Outcome__c != null) {
                        seInfo.credit = studentExpertise.Total_Applied_Earned_CE_Outcome__c;
                    } else {
                        if(studentExpertise.Pseudo_Course__c == TRUE ) {
                        	seInfo.credit = studentExpertise.Pseudo_CE__c;
                        } else {
                            seInfo.credit = studentExpertise.Total_CE__c;
                        }
                    }
                    seInfo.subjectAreaExpertise = studentExpertise.Subject_Area_Expertise__c;
                    degreeAuditInfoWrapperInstance.lststudentexpertiseInfo.add(seInfo);
                }
            }            
            lstDegreeAuditInfoWrapper.add(degreeAuditInfoWrapperInstance);            
        }        
        getGenEdFlag(); 
        getSubjectAreaExpertiseLists();
        
    }
    
    void getGenEdFlag() {
    	Boolean genEdFlag = true;
        for (DegreeAuditInfoWrapper wrapper : lstDegreeAuditInfoWrapper) {
            if (wrapper.category == 'Arts and Humanities' || wrapper.category == 'Mathematics/Natural Sciences' || wrapper.category == 'Social Sciences' || wrapper.category == 'Written and Oral Communication' || wrapper.category == 'Statistics' || wrapper.category == 'Any Category') {
                if (wrapper.met == 'Yes') {
                    genEdFlag = (genEdFlag && true);
                } else {
                    genEdFlag = (genEdFlag && false);
                }
            }
        }
        for (DegreeAuditInfoWrapper wrapper : lstDegreeAuditInfoWrapper) {
            if (wrapper.category == 'General Education') {
                if (genEdFlag) {
                    wrapper.met = 'Yes';
                } else {
                    wrapper.met = 'No';
                }
            }
        }    
    }
    
    List<String> getRules() {
       rules = new List<String>();
        if (bucketToRequiredCredit.keySet().contains('Core Upper')){
              rules.add('Core Upper');
        } if (bucketToRequiredCredit.keySet().contains('Core Lower')){
              rules.add('Core Lower');
        } if (bucketToRequiredCredit.keySet().contains('Concentration')){
              rules.add('Concentration');
        } if (bucketToRequiredCredit.keySet().contains('General Education')){
              rules.add('General Education');
        } if (bucketToRequiredCredit.keySet().contains('Arts and Humanities')){
              rules.add('Arts and Humanities');
        } if (bucketToRequiredCredit.keySet().contains('Mathematics/Natural Sciences')){
              rules.add('Mathematics/Natural Sciences');
        } if (bucketToRequiredCredit.keySet().contains('Social Sciences')){
              rules.add('Social Sciences');
        } if (bucketToRequiredCredit.keySet().contains('Written and Oral Communication')){
              rules.add('Written and Oral Communication');
        } if (bucketToRequiredCredit.keySet().contains('Statistics')){
              rules.add('Statistics');
        } if (bucketToRequiredCredit.keySet().contains('Any Category')){
              rules.add('Any Category');
        } if (bucketToRequiredCredit.keySet().contains('General Elective')){
              rules.add('General Elective');
        }
        rules.add('Back');
        return rules;
    }
    
    void getSubjectAreaExpertiseLists() {
        Map<String, List<StudentExpertiseInfo>> outcomeCategorySEList = new Map<String, List<StudentExpertiseInfo>>();
        DegreeAuditInfoWrapper artsAndHumanitiesWrapper;
        DegreeAuditInfoWrapper mathsWrapper;
        DegreeAuditInfoWrapper socialSciencesWrapper;
        DegreeAuditInfoWrapper communicationsWrapper;
        DegreeAuditInfoWrapper statisticsWrapper;
        DegreeAuditInfoWrapper anyWrapper;
        
        for (DegreeAuditInfoWrapper wrapper : lstDegreeAuditInfoWrapper) {
            if (wrapper.category == 'Arts and Humanities') {
                artsAndHumanitiesWrapper = wrapper;
            } else if (wrapper.category == 'Mathematics/Natural Sciences') {
                mathsWrapper = wrapper;
            } else if (wrapper.category == 'Social Sciences') {
                socialSciencesWrapper = wrapper;
            } else if (wrapper.category == 'Written and Oral Communication') {
                communicationsWrapper = wrapper;
            } else if (wrapper.category == 'Statistics') {
                statisticsWrapper = wrapper;
            } else if (wrapper.category == 'Any Category') {
                anyWrapper = wrapper;
            }
            
            if (wrapper.category == 'General Education') {
                for (StudentExpertiseInfo seInfo : wrapper.lststudentexpertiseInfo) {
                    if (seInfo.outcomeSubjectAreaExpertise == null) {
                        if (seIdsPreliminaryTransferSet.contains(seInfo.seId)) {
                            if (!outcomeCategorySEList.containsKey(seInfo.subjectAreaExpertise)) {
                                outcomeCategorySEList.put(seInfo.subjectAreaExpertise, new List<StudentExpertiseInfo>{seInfo});
                            } else {
                                outcomeCategorySEList.get(seInfo.subjectAreaExpertise).add(seInfo);
                            }
                        }
                    }
                    if (!outcomeCategorySEList.containsKey(seInfo.outcomeSubjectAreaExpertise)) {
                        if (seInfo.outcomeSubjectAreaExpertise != null) {
                            outcomeCategorySEList.put(seInfo.outcomeSubjectAreaExpertise, new List<StudentExpertiseInfo>{seInfo});
                        }                        
                    } else {
                        outcomeCategorySEList.get(seInfo.outcomeSubjectAreaExpertise).add(seInfo);
                    }
                }
            }
        }
        
        for (DegreeAuditInfoWrapper wrapper : lstDegreeAuditInfoWrapper) {
            if (wrapper.category == 'Arts and Humanities') {
                if (artsAndHumanitiesWrapper != null && outcomeCategorySEList.get('Arts and Humanities') != null) {
                	artsAndHumanitiesWrapper.lststudentexpertiseInfo.addAll(outcomeCategorySEList.get('Arts and Humanities'));
                }
            } else if (wrapper.category == 'Mathematics/Natural Sciences') {
                if (mathsWrapper != null && outcomeCategorySEList.get('Mathematics/Natural Sciences') != null) {
                	mathsWrapper.lststudentexpertiseInfo.addAll(outcomeCategorySEList.get('Mathematics/Natural Sciences'));
                }
            } else if (wrapper.category == 'Social Sciences') {
                if (socialSciencesWrapper != null && outcomeCategorySEList.get('Social Sciences') != null) {
                	socialSciencesWrapper.lststudentexpertiseInfo.addAll(outcomeCategorySEList.get('Social Sciences'));
                }
            } else if (wrapper.category == 'Written and Oral Communication') {
                if (communicationsWrapper != null && outcomeCategorySEList.get('Written and Oral Communication') != null) {
                	communicationsWrapper.lststudentexpertiseInfo.addAll(outcomeCategorySEList.get('Written and Oral Communication'));
                }
            } else if (wrapper.category == 'Statistics') {
                if (statisticsWrapper != null && outcomeCategorySEList.get('Statistics') != null) {
                	statisticsWrapper.lststudentexpertiseInfo.addAll(outcomeCategorySEList.get('Statistics'));
                }
            } else if (wrapper.category == 'Any Category') {
                if (anyWrapper != null && outcomeCategorySEList.get('Any Category') != null) {
                	anyWrapper.lststudentexpertiseInfo.addAll(outcomeCategorySEList.get('Any Category'));
                }
            }
        }
        
        for (DegreeAuditInfoWrapper wrapper : lstDegreeAuditInfoWrapper) {
            if (wrapper.category == 'General Education') {
                if (wrapper.lststudentexpertiseInfo.isEmpty()) {
                    StudentExpertiseInfo seInfoDummy = new StudentExpertiseInfo();
                    wrapper.lststudentexpertiseInfo.add(seInfoDummy);
                }
                for (StudentExpertiseInfo seInfo : wrapper.lststudentexpertiseInfo) {
                	seInfo.outcomeSubjectAreaExpertiseWrapper = new List<DegreeAuditInfoWrapper>();
                    seInfo.outcomeSubjectAreaExpertiseWrapper.add(artsAndHumanitiesWrapper);
                    seInfo.outcomeSubjectAreaExpertiseWrapper.add(mathsWrapper);
                    seInfo.outcomeSubjectAreaExpertiseWrapper.add(socialSciencesWrapper);
                    seInfo.outcomeSubjectAreaExpertiseWrapper.add(communicationsWrapper);
                    seInfo.outcomeSubjectAreaExpertiseWrapper.add(statisticsWrapper);
                    seInfo.outcomeSubjectAreaExpertiseWrapper.add(anyWrapper);
                    break;
                }
            }
        }
    }
    
    /*
     * S-38826: Tempo: Add Preliminary Transfer Credits on Grad and UG degree audit
     * This method helps determine which SEs have all its SCs with status equal to Preliminary Transfer
     */ 
    private void populatePreliminaryTransferSE(List<Student_Expertise__c> seList) {
        seIdsPreliminaryTransferSet = new Set<String>();
        Set<Id> seIdSet = new Set<Id>();
        for (Student_Expertise__c se : seList) {
            seIdSet.add(se.Id);
        }
        List<Student_Competency__c> studentCompetencyList = [SELECT Id, Status__c, Student_Expertise__c FROM Student_Competency__c WHERE Student_Expertise__c IN :seIdSet];
        Map<String, List<Student_Competency__c>> seIdStudentCompetency = new Map<String, List<Student_Competency__c>>();
        for (Student_Competency__c sc : studentCompetencyList) {
            if (!seIdStudentCompetency.containsKey(sc.Student_Expertise__c)) {
                seIdStudentCompetency.put(sc.Student_Expertise__c, new List<Student_Competency__c>{sc});
            } else {
                seIdStudentCompetency.get(sc.Student_Expertise__c).add(sc);
            }
        }
        
        for (String seId : seIdStudentCompetency.keySet()) {
            Boolean isPreliminaryTransfer = true;
            
            for (Student_Competency__c sc : seIdStudentCompetency.get(seId)) {
                if (sc.Status__c != 'Preliminary Transfer') {
                    isPreliminaryTransfer = false;
                    break;
                }
            }
            
            if (isPreliminaryTransfer) {
                seIdsPreliminaryTransferSet.add(seId);
            }            
        }
    }
    
    public class DegreeAuditInfoWrapper {
        public String seId {get;set;}
        public String category {get;set;}
        public String level {get;set;}
        public Decimal requiredCredit {get;set;}
        public Decimal earnedCredit{get;set;}
        public String met {get;set;}
        public String outcomeSubjectAreaExpertise {get;set;}
        public List<StudentexpertiseInfo> lststudentexpertiseInfo {get;set;}
    }
    
    public class StudentexpertiseInfo {
        public String seId {get;set;}
        public String courseCode {get;set;}
        public String courseTitle {get;set;}
        public Decimal credit {get;set;}
        public String met {get;set;}
        public String outcomeSubjectAreaExpertise {get;set;}
        public String subjectAreaExpertise {get;set;}
        public List<DegreeAuditInfoWrapper> outcomeSubjectAreaExpertiseWrapper {get;set;}
    }
    
    public class ExternalDegreeSP {
        public Double totalCreditsInProgram {get;set;}
        public Double allCreditsCompleted {get;set;}
        public Double requiredInstitutionCredits {get;set;}
        public Double numberCreditsCompletedAllTerms {get;set;}
        public Double numberCreditsTransferred {get;set;}
        public Double requiredUpperLevelCredits {get;set;}
        public Double numberUpperLevelCredits {get;set;}
    }
    
}