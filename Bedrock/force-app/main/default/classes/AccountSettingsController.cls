/*******************************************************************
Name  : AccountSettingsController 
Author: Ravitej Varada (Laureate)
Date  : February 15, 2018
Description: Controller extension class for AccountSettings Page

* Revision History
* Horacio Sanchez   11/26/2020     S-28146: Tempo: View Active Student Hold Codes on Tempo Student Portal
* Horacio Sanchez   05/04/2021     S-50437: L2: Update Tempo Student Id card template
* Horacio Sanchez   07/19/2021     S-58474: L2: Update "Request Official Transcript" Button on Student Portal
* Horacio Sanchez   08/05/2021     S-58475: L2: Create new Case for FAM
* Horacio Sanchez   08/19/2021     S-63894: L2: Add all the applicable holds to be checked for Official Transcript
* Ravitej Varada    09/17/2021     S-688672: L2: Hide Document Hold from Student portal
* Ravitej Varada    05/03/2022     S-694767: L2: Modify the Existing ATC (old flow) to Work Only if Product.Automate_Agree_to_Credit__c is False
* Martin Lopez		06/06/2022	   S-695558: L2: Present a notifications page in the Tempo student portal
*************************************************************************/
public without sharing class AccountSettingsController {
    
    public String studentName { get; set; }
    public String cblId { get; set; }
    public Date issueDate { get; set; }
    public Id studentProgramId { get; set; }
    public Student_Program__c sProgram { get; set; }
    public string modalHeader { get; set; }
    public string modalBody { get; set; }
    public Boolean isModalWindow { get; set; }
    public Boolean isHold { get; set; }
    public String currentUserId {get;set;}
    public String waldenEmail { get; set;}
    public String waldenEmailHash { get; set; }
    public String contactId {get;set;}
    public String intercomAppId { get; set; }
    public id currentSubscriptionId{ get; set; }
    public string hash { get; set; }
    public string schoolCode { get; set; }
    public string studentFacultyPortalSso { get; set; }
    public Boolean toggle {get; set;}
    public Boolean hasOpenHold {get; set;}
    public List<NotificationEntry> notificationEntryList {get; set;}
    public Boolean notificationsAvailable {get;set;}
    public List<student_competency__c> notificationSurveyList {get;set;}
    public Boolean isMarylandState {get; set;}
    public Boolean redirectToOfficialTranscript {get;set;}
    
    private static final String MARYLAND = 'Maryland';
    private static final String CALIFORNIA_STATE = 'CALIFORNIA';
    private static final String WASHINGTON_STATE = 'WASHINGTON';
    
    Boolean isCommunityUser() {
        if('Customer Community Login'.equals( ([ Select UserLicense.Name  
                                                FROM Profile 
                                                WHERE Id =: userinfo.getProfileid()]).UserLicense.Name) ) {
                                                    return true;
                                                } else {
                                                    return false;
                                                }
    }
    public AccountSettingsController(){}
    
    public AccountSettingsController(ApexPages.StandardController controller) {
        isHold = False;
        redirectToOfficialTranscript = false;
        
        if (! isCommunityUser() ) {
            studentProgramId = ApexPages.currentPage().getParameters().get('id');
        } else {
            currentUserId = UserInfo.getUserId();
            User user = [ SELECT Id, ContactId FROM User WHERE Id = :currentUserId ];
            Contact contact = [SELECT Id, walden_email__c, Email, firstName, lastName, CBL_Student_Id__c, MailingState, 
                               (SELECT Id, IsStudentProgramActive__c, Current_Student_Subscription__c, Program__r.Display_Name__c, Program__r.Degree_Level__c
                                FROM Student_Programs__r),
                               (SELECT Id,Primary_Program_of_Interest__r.name,Primary_Program_of_Interest__r.display_name__c,Primary_Program_of_Interest__c, Primary_Program_of_Interest__r.Program_Guide_Link__c,CBL_Student_ID__c 
                                FROM Brand_Profiles__r) 
                               FROM CONTACT WHERE Id = :user.ContactId ];
            contactId= contact.id;
            waldenEmail = contact.Email;
            waldenEmailHash = HmacSHA256Encryption.generateHmacSHA256Signature(waldenEmail); 
            for (Student_Program__c c: contact.Student_Programs__r) {
                if (c.IsStudentProgramActive__c == true) {
                    ApexPages.currentPage().getParameters().put('id',c.id);
                    //currentSubscriptionId = c.Current_Student_Subscription__c;
                    break;
                } else if(contact.Brand_Profiles__r[0].Primary_Program_of_Interest__r.display_name__c == c.Program__r.Display_Name__c ) {
                    ApexPages.currentPage().getParameters().put('id',c.id); 
                }
            }    
            studentProgramId = ApexPages.currentPage().getParameters().get('id');
            setupStateFlag(contact.MailingState);
        }
        system.debug('studentProgramId'+studentProgramId);
        
        Student_Program__c studProgram = (Student_Program__c) controller.getRecord();
        this.sProgram = [
            SELECT Id, Name, Program__r.Automate_Agree_to_Credit__c,student__r.Walden_email__c,student__r.Email,Student_Full_Name__c, Current_Student_Subscription__c,Student__r.firstname,Student__r.lastname, student__r.middle_name__c,
            CurrentSubscriptionStartDate__c, CurrentSubscriptionEndDate__c,Student__r.name,Current_Student_Subscription__r.Agreed_To_Credits__c,
            IsStudentProgramActive__c, CoachEmail__c,Coach__r.Name,Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c, Application__c,
            First_Start_Date__c, student__r.CBL_Student_ID__c, student__r.MailingState, Program_Start_Date__r.Name, Active_Student_Payment_Plan__c, 
            Active_Hold_Codes__c, Open_Document_Hold__c, Open_Bursar_Hold__c, Open_C2_Hold__c, Open_BK_Hold__c, Open_Contingency_Hold__c, student__c,
            (SELECT Id FROM Subscriptions__r  where Future_Term__c = false order by createdDate DESC LIMIT 1)
            FROM Student_Program__c
            WHERE Id = :studentProgramId
        ];
        
        if (!sProgram.Subscriptions__r.isempty()) {
        	currentSubscriptionId =sProgram.Subscriptions__r[0].id;
        }
        
        if (sProgram.Open_Document_Hold__c > 0 ) {
            isHold = True;
        }
        
        setupHoldNotifications(sProgram);
        setupSurveyNotifications(sProgram); //S-695558
        
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
        
        //Custom Settings to retrive Brand Conf Record ID to display Header and Body for Model Window
        
        Community_Site_Settings__c defaultCustomSetngs = Community_Site_Settings__c.getValues('Default Settings');
        if( defaultCustomSetngs != null ) {
            Brand_Configuration__c BC = [Select id,name,Sub_Type__c,Body__c from Brand_Configuration__c where id = :defaultCustomSetngs.RecordID__c];
            modalHeader = BC.Sub_Type__c;
            modalBody = BC.Body__c;
            intercomAppId = defaultCustomSetngs.Intercom_App_Id__c ;
              if(defaultCustomSetngs.Student_Financial_Portal_Sso__c != null){
            studentFacultyPortalSso = defaultCustomSetngs.Student_Financial_Portal_Sso__c;
            }
        }
        
        
        ecsiRedirect();
       // displayModalWindow();
        setAvailabilityToRequestOfficialTranscript();
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
        system.debug('displayModalWindow');
        Student_Subscription__c studentSubscription = new Student_Subscription__c(id = sProgram.Current_Student_Subscription__c);
        
        studentSubscription.Date_Student_Agreed_To_Credits__c = date.today();
        update studentSubscription;
        isModalWindow = false;
    }
    
    
    public void ecsiRedirect(){
       Community_Site_Settings__c defaultCustomSetngs = Community_Site_Settings__c.getValues('Default Settings');
         If(defaultCustomSetngs.ECSI_Prefix__c != null && defaultCustomSetngs.ECSI_School_Code__c  != null && defaultCustomSetngs.ECSI_Suffix__c != null){
            schoolCode =  defaultCustomSetngs.ECSI_School_Code__c;
            string prefix=  defaultCustomSetngs.ECSI_Prefix__c;
            string suffix=  defaultCustomSetngs.ECSI_Suffix__c;
            hash = generateSHA256(prefix+schoolCode+cblId+System.now().format('dd')+System.now().format('HH')+System.now().format('mm')+suffix);             
         }
         
    }
    
    private static String generateSHA256(String inputString){
        String algorithmName = 'SHA-256';
        Blob targetBlob = Blob.valueOf(inputString);
        Blob hash = Crypto.generateDigest(algorithmName, targetBlob);
        return EncodingUtil.convertToHex(hash);
    }
    
    private void setupHoldNotifications(Student_Program__c sProgram) {
        notificationEntryList = new List<NotificationEntry>();
        Integer genericHoldsCounter = 0;
        if (sProgram.Active_Hold_Codes__c > 0) {
            hasOpenHold = true;
            List<Student_Hold_Code__c> studentHoldCodeList = [SELECT Id, Name, Hold_Close_Date__c, Hold_Code__c
                                                          FROM Student_Hold_Code__c 
                                                          WHERE Student_Program__c = :sProgram.Id AND Hold_Close_Date__c = NULL
                                                          ORDER BY CreatedDate DESC];
            List<Hold_Code_Notification__mdt> holdCodeNotificationsList = [SELECT Id, Title__c, Description__c, Hold_Code_Id__c FROM Hold_Code_Notification__mdt ORDER BY Hold_Code_Id__c DESC ];
            
            // Finding the specific hold notification, if none is found, will get the default one
            for (Student_Hold_Code__c shc : studentHoldCodeList) {
                for (Hold_Code_Notification__mdt notification : holdCodeNotificationsList) {
                    if (notification.Hold_Code_Id__c == '-1') {
                        genericHoldsCounter+=1;
                        break;
                    }
                    if (shc.Hold_Code__c == notification.Hold_Code_Id__c) {
                        NotificationEntry entry = new NotificationEntry();
                        entry = new NotificationEntry();
                        entry.title = notification.Title__c;
                        entry.description = notification.Description__c;
                        notificationEntryList.add(entry);                
                        break;
                    }
                }
            }
            
            // Getting the default hold entry if the list of entries is empty, which means it didn't found a matching hold code
            for (Integer i = 0; i < genericHoldsCounter; i++) {
                for (Hold_Code_Notification__mdt notification : holdCodeNotificationsList) {
                    if (notification.Hold_Code_Id__c == '-1') {
                        NotificationEntry entry = new NotificationEntry();
                        entry = new NotificationEntry();
                        entry.title = notification.Title__c;
                        entry.description = notification.Description__c;
                        notificationEntryList.add(entry);
                        break;
                    }
                }
            }
        } else {
            hasOpenHold = false;
        }
    }
    
    //Setting up Survey notifications for story S-695558
    private void setupSurveyNotifications(Student_Program__c sProgram) {
        notificationSurveyList = [SELECT Id, name, Survey_Message_Sent__c, Contact__r.Email, Contact__r.name, Contact__r.firstName, competency_code__c, competency_title__c, End_of_Survey_Link__c, Completed_Date__c
                          FROM student_competency__c 
                          WHERE (Status__c = 'Achieved' OR Status__c= 'Mastered') 
                          AND  (NOT Competency_Code__c LIKE  'X_PM%') 
                          AND competency__r.type__c = 'Academic' 
                          AND End_of_Survey_Link__c <> null 
                          AND Student_Program__c =:sProgram.Id 
                          AND Survey_Message_Sent__c=true //Bring only read notifications.
                          ORDER BY Survey_Message_Sent__c ASC, Completed_Date__c DESC];
        notificationsAvailable = !notificationSurveyList.IsEmpty();
    }
    
    // S-50437: L2: Update Tempo Student Id card template
    private void setupStateFlag(String mailingState) {
        if (mailingState != null && mailingState.equalsIgnoreCase(MARYLAND)) {
            isMarylandState = true;
        } else {
            isMarylandState = false;
        }
    }
    
    public class NotificationEntry {
        public String title {get; set;}
        public String description {get; set;}

        public NotificationEntry() {

        }
    }
    
    // S-58474: L2: Update "Request Official Transcript" Button on Student Portal
    private void setAvailabilityToRequestOfficialTranscript() {
        if (sProgram.Student__r.MailingState != null && (sProgram.Student__r.MailingState.toUpperCase().equals(CALIFORNIA_STATE) || sProgram.Student__r.MailingState.toUpperCase().equals(WASHINGTON_STATE))) {
            redirectToOfficialTranscript = true;
        } else {
            if (hasStudentHoldCodes() && !sProgram.Active_Student_Payment_Plan__c) {
                redirectToOfficialTranscript = false;
            } else {
                redirectToOfficialTranscript = true;
            }
        }
    }
    
    // S-63894: L2: Add all the applicable holds to be checked for Official Transcript
    private Boolean hasStudentHoldCodes() {
        List<Student_Hold_Code__c> shcList = [SELECT Id, Name 
                                              FROM Student_hold_code__c 
                                              WHERE Student_Program__c = :sProgram.Id
                                              AND Hold_Code__r.Name IN ('BH', 'C1', 'C2', 'C3', 'DH', 'FS', 'LT')
                                              AND Hold_Close_Date__c = NULL];
        
        return (shcList.isEmpty() ? false : true);
    }
    
    // S-58475: L2: Create new Case for FAM
    public void handleBlockedTranscriptApex() {
        List<Case> caseList = [SELECT Id 
                               FROM Case 
                               WHERE Student_Program__c = :sProgram.Id
                               AND Type = 'Financial Account Management'
                               AND Subject = 'Request Official Transcript'
                               AND ContactId = :sProgram.Student__c
            				   AND (Status = 'New' OR Status = 'In-Progress' OR Status = 'Escalated')];
        
        if (caseList.isEmpty()) {
            Case newCase = new Case();
            newCase.Type = 'Financial Account Management';
            newCase.Case_Topic__c = 'General Request';
            newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Financial Account Management').getRecordTypeId();
            newCase.ContactId = sProgram.Student__c;
            newCase.Student_Program__c = sProgram.Id;
            newCase.Status = 'New';
            newCase.Priority = 'Medium';
            newCase.Subject = 'Request Official Transcript';
            newCase.OwnerId = [SELECT Id, QueueId FROM QueueSobject WHERE queue.Name = 'FAM Queue' LIMIT 1][0].QueueId;
            insert newCase;
        }
    }
    
}