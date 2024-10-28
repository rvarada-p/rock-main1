/************************************************************************************** 
Apex Class Name     : DegreeAuditGRController
Created Date        : 11th October 2019
Function            : Controller class for DegreeAudit Page
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ravitej Varada            10/11/2019                Original Version
*
* Revision History
* Horacio Sanchez     01/27/2021      S-38826: Tempo: Add Preliminary Transfer Credits on Grad and UG degree audit
*************************************************************************************/
public with sharing class DegreeAuditGRController {
    public Student_Program__c studentProgram{get; set;}
    public Student_Program__c sProgram {get;set;}
    public List<String> rules = new List<String>();
    public List<DegreeAuditInfoWrapper> lstDegreeAuditInfoWrapper{get; set;}
    public List<Student_Expertise__c> lstStudentExperise = new List<Student_Expertise__c>();
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
    public decimal totalCe { get; set; }
    public decimal earnedCe { get; set; }
    public String studentName { get; set; }
    public Boolean isModalWindow { get; set; }
    public Boolean isAgreedCreditText {get;set;}
    public Double ugProgramCompletion {get;set;}
    
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
    
    //controller
    public DegreeAuditGRController(ApexPages.StandardController controller) {
        earnedUpperLevelCredits = 0;
        totalCe = 0;
        earnedCe = 0;
        if ( ! isCommunityUser() ) {
            studentProgramId = ApexPages.currentPage().getParameters().get('id');
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
        
        //displayModalWindow();
        
        if(!test.isRunningTest()){  
            controller.addfields(new List<string>{'Program__c' });
        }
        studentProgram = (Student_Program__c)controller.getRecord();
        
        sProgram = [SELECT Id,Program__r.Automate_Agree_to_Credit__c, Current_Student_Subscription__c, current_student_subscription__r.agreed_to_credits__c,
                    current_student_subscription__r.date_student_agreed_to_credits__c,
                    is_welcome_message__c, student__r.name,
                    Total_Credits_in_Program__c, All_Credits_Completed__c,
                    program__r.Required_Institution_Credits__c, Number_Credits_Completed_in_all_Terms__c, fulfilled_Credit__c,
                    Number_of_Credits_Transferred__c,
                    program__r.Required_Upper_Level_Credits__c, Number_of_Upper_Level_Credits__c, Program_Completion__c  
                    FROM Student_Program__c
                    WHERE Id = :studentProgram.Id];
       
        
        
        
        List<Student_Expertise__c> StuExpLst = [ SELECT Id, Student_Program__r.Program__c,
                                                Area_of_Expertise_Name__c,Area_of_Expertise__c,Pseudo_CE__c, Total_Applied_Earned_CE_Outcome__c,
                                                Audit_Category__c,Contact__c,External_Key__c, IsAchieved__c,IsDeleted,Level_Type__c,
                                                Name,Number_of_Competencies_Completed__c,Number_of_Competencies_Transferred__c,
                                                Opportunity__c,Outcome_Category__c,Program_Expertise__c,Area_of_Expertise__r.Category__c,
                                                Area_of_Expertise__r.Level__c,Area_of_Expertise__r.Level_Type__c,Program_Expertise__r.Category__c,
                                                Program_Institution__c,Program_Name__c,Pseudo_Course__c,Area_of_Expertise__r.Course_Code__c ,
                                                RecordTypeId,Student_Name__c,Student_Program__c,Total_CE__c, Subject_Area_Expertise__c
                                                FROM Student_Expertise__c
                                                WHERE Student_Program__c = :studentProgram.id];
                                               // WHERE Student_Program__c = :studentProgram.id and Area_of_Expertise__r.type__c = 'Academic' ];
        
 
        lstDegreeAuditInfoWrapper = new List<DegreeAuditInfoWrapper>();
        for (Student_Expertise__c stuExp: StuExpLst) {
            DegreeAuditInfoWrapper degreeAuditInfoWrapperInstance = new DegreeAuditInfoWrapper();
            
            degreeAuditInfoWrapperInstance.courseName = stuExp.Area_of_Expertise_Name__c;
            degreeAuditInfoWrapperInstance.courseCode = stuExp.Area_of_Expertise__r.Course_Code__c;
            degreeAuditInfoWrapperInstance.seId = stuExp.Id;
            
            if (stuExp.IsAchieved__c == true) {
                degreeAuditInfoWrapperInstance.credits = stuExp.Total_CE__c;
                earnedCe += stuExp.Total_CE__c;
                degreeAuditInfoWrapperInstance.met = 'Yes';
            } else {
                degreeAuditInfoWrapperInstance.credits = stuExp.Total_CE__c;
                degreeAuditInfoWrapperInstance.met = 'No';
            }
            if (stuExp.Pseudo_Course__c == true){
                degreeAuditInfoWrapperInstance.credits = stuExp.Pseudo_CE__c;
            } else {
                degreeAuditInfoWrapperInstance.credits = stuExp.Total_CE__c;
            }
            totalCe += stuExp.Total_CE__c;
            lstDegreeAuditInfoWrapper.add(degreeAuditInfoWrapperInstance);
        }
        
         
        if (sProgram != null) {
            studentName = sProgram.Student__r.name;
            if (earnedCe > 0) {
            	ugProgramCompletion = (earnedCe/sProgram.Total_Credits_in_Program__c *100).setScale(2);
            }
        }
        
        calculatePreliminaryTransferMet();    
        
    }
    
    private void calculatePreliminaryTransferMet() {
        Map<String, DegreeAuditInfoWrapper> seIdWrapperMap = new Map<String, DegreeAuditInfoWrapper>();
        Set<Id> seIdSet = new Set<Id>();
        for (DegreeAuditInfoWrapper wrapper : lstDegreeAuditInfoWrapper) {
            if (!seIdWrapperMap.containsKey(wrapper.seId)) {
                seIdWrapperMap.put(wrapper.seId, wrapper);
            }
            seIdSet.add(wrapper.seId);
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
                seIdWrapperMap.get(seId).met = 'PR';
            }            
        }
    }
    
    public class DegreeAuditInfoWrapper {
        public String seId {get;set;}
        public String courseName {get;set;}
        public String courseCode {get;set;}
        public Decimal credits {get;set;}
        public String met {get;set;}
    }
    
    
    
}