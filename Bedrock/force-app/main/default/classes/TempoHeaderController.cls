/*******************************************************************
Name  : TempoHeaderController 
Author: Ravitej Varada (Laureate)
Date  : February 15, 2018
Description: Controller extension class for TempoHeader VisualForce COmponent

* Revision History
* Horacio Sanchez   10/27/2020     S-28150 Making My Learning button available for Inactive Students
* Ravitej Varada    03/28/2022     Present a bell icon on tempo student portal when surveys are available
* Ravitej Varada    05/03/2022     S-694767: L2: Modify the Existing ATC (old flow) to Work Only if Product.Automate_Agree_to_Credit__c is False
* Ravitej Varada    05/11/2022     I-426956 - 15 Days Logic for ATC
* Ravitej Varada    05/16/2022     I-426956 - Remove 15 Days Logic for ATC
* Hema Sadasivan    05/18/2022     S-89055 - Remove read notifications from the mini view (bell icon) in Tempo Student Portal

*************************************************************************/

public with sharing class TempoHeaderController {
    public String studentProgramId { get; set; }
    Public string logoutUrl{get;set;}
    public String currentUserId {get;set;}
    public String contactId {get;set;}
    public String studentName{get;set;}
    public String waldenEmail {get;set;}
    public String myLearningUrl {get;set;}
    public Boolean showMyLearningButton {get;set;}
    public List<Brand_Configuration__c> brandConfigurations {get;set;}
    public Integer notificationUnreadCount{get;set;} 
    public Integer notificationTotalCount{get;set;} 
    public List<notificationWrapper> notificationWrpLst {get;set;}
    public Boolean notificationsAvailable {get;set;}
    public Integer notificationListCount {get;set;}
    public String scId {get; set;}    
    private Boolean isContactActiveFlag;
    public Contact c {get;set;}
    public Boolean isModalWindow { get; set; }
    public string modalHeader { get; set; }
    public string modalBody { get; set; }

    public TempoHeaderController() {
        currentUserId = UserInfo.getUserId();
        User user = [SELECT Id, ContactId FROM User WHERE Id = :currentUserId ];
        Contact contact = [SELECT Id,firstname,lastname,email,walden_email__c, (SELECT Id, program__r.Degree_Level__c FROM Student_Programs__r ORDER BY CreatedDate DESC LIMIT 1) FROM CONTACT WHERE Id = :user.ContactId];        
        Contact isContactActive = [SELECT Id, (SELECT Id, IsStudentProgramActive__c FROM Student_Programs__r) FROM Contact WHERE Id = :user.ContactId LIMIT 1 ];
        showMyLearningButton = true;
        for (Integer i = 0; i < isContactActive.Student_Programs__r.size(); i++ ) {
            //showMyLearningButton = showMyLearningButton || isContactActive.Student_Programs__r[i].IsStudentProgramActive__c;
            isContactActiveFlag = isContactActive.Student_Programs__r[i].IsStudentProgramActive__c;
            studentProgramId= isContactActive.Student_Programs__r[i].Id;
        }

        //ApexPages.currentPage().getParameters().put('id',contact.id);
        c=contact;
        contactId = contact.Id;
        studentName=contact.firstname;
        waldenEmail=contact.Walden_Email__c;
        system.debug('COntact ID'+contactId);

        Community_Site_Settings__c defaultCustomSetngs = Community_Site_Settings__c.getValues('Default Settings');
        if( defaultCustomSetngs != null ) {
            logoutUrl = defaultCustomSetngs.Sign_Out_URL__c;
            Brand_Configuration__c BC = [Select id,name,Sub_Type__c,Body__c from Brand_Configuration__c where id = :defaultCustomSetngs.RecordID__c];
            modalHeader = BC.Sub_Type__c;
            modalBody = BC.Body__c;
        }

        if (contact.Student_Programs__r.isEmpty()) {
            system.debug('is null');
            myLearningUrl = '';
        } else if (!contact.Student_Programs__r.isEmpty()) {
            if (isContactActiveFlag) {
                if (contact.Student_Programs__r[0].program__r.Degree_Level__c == 'Graduate') {
                    myLearningUrl = '/apex/myTerm';
                } else if (contact.Student_Programs__r[0].program__r.Degree_Level__c == 'Undergrad') {
                    myLearningUrl = '/apex/myTermUndergrad';
                }
            } else {
                if (contact.Student_Programs__r[0].program__r.Degree_Level__c == 'Graduate') {
                    myLearningUrl = '/apex/ProgramOverview';
                } else if (contact.Student_Programs__r[0].program__r.Degree_Level__c == 'Undergrad') {
                    myLearningUrl = '/apex/MyProgramUndergrad';
                }
            }

        }
        initGetStartedModal();
        getNotification();
        displayModalWindow();
    }

    void initGetStartedModal() {
        brandConfigurations = new List<Brand_Configuration__c>();
        brandConfigurations = [ SELECT Body__c,Display_Order__c,Heading__c,Name,Sub_Type__c,Type__c FROM Brand_Configuration__c WHERE Sub_Type__c = 'Welcome Messages' ORDER BY Display_Order__c ASC NULLS LAST  LIMIT 10];
    }


    //This method controlls the modal content window based on agreed to credits on SP 
    public void displayModalWindow() {
        system.debug('displayModalWindow');
        List<Student_Program__c> sProgramLst = new List<Student_Program__c>();
        sProgramLst = [ SELECT Name,Program__r.Automate_Agree_to_Credit__c,Current_Student_Subscription__r.Agreed_To_Credits__c,Current_Student_Subscription__r.Start_Date__c,program__r.Parent_Program__r.Program_Guide_Link__c,program__r.Program_Guide_Link__c, Student_Full_Name__c, 
                        Current_Student_Subscription__c,Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c, CurrentSubscriptionStartDate__c, CurrentSubscriptionEndDate__c,
                        IsStudentProgramActive__c, Id,Program__c from Student_Program__c where Student__c=:contactId  and IsStudentProgramActive__c = True];
        
        //I-426956
        Student_Program__c sProgram = new  Student_Program__c();
        if (!sProgramLst.isEmpty()) {
            sProgram = sProgramLst[0];
            if (sProgram.Current_Student_Subscription__r.Agreed_To_Credits__c != null &&
                sProgram.Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c == null && sProgram.Program__r.Automate_Agree_to_Credit__c == False) {
                    isModalWindow = true;
                } else {
                    isModalWindow = false;
                }
        }
        system.debug('isModalWindow' + isModalWindow);
    }


    public void closeModal() {
        System.debug('Close Onboarding modal');
    }

    public void getNotification(){
        notificationWrpLst = new List<notificationWrapper>();
        notificationsAvailable = false;
        notificationListCount = 0;
        System.debug('Close Onboarding modal'+studentProgramId);
        List<student_competency__c> studentCompLst = new List<student_competency__c> ();
        studentCompLst = [SELECT Id, name, Survey_Message_Sent__c, Contact__r.Email, Contact__r.name, Contact__r.firstName, competency_code__c, competency_title__c, End_of_Survey_Link__c, Completed_Date__c
                          FROM student_competency__c 
                          WHERE (Status__c = 'Achieved' OR Status__c= 'Mastered') 
                          AND  (NOT Competency_Code__c LIKE  'X_PM%') 
                          AND competency__r.type__c = 'Academic' 
                          AND End_of_Survey_Link__c <> null 
                          AND Student_Program__c =:studentProgramId 
                          AND Survey_Message_Sent__c=false //S-89055
                          ORDER BY Survey_Message_Sent__c ASC, Completed_Date__c DESC];
        System.debug('studentCompLst'+studentCompLst);
        Integer notificationCount=0;
        for(student_competency__c sc: studentCompLst){
            notificationWrapper wrp = new notificationWrapper();
            wrp.surveyLink = sc.End_of_Survey_Link__c;
            wrp.firstName = sc.Contact__r.firstName;
            wrp.competencyCode = sc.competency_code__c;
            wrp.competencyTitle = sc.competency_title__c;
            wrp.Id = sc.Id;
            wrp.completedDate = sc.Completed_Date__c;
            //if (sc.Survey_Message_Sent__c == false) {
            wrp.isNotificationRead = true; //S-89055
            notificationCount++; //S-89055
            //}
            notificationWrpLst.add(wrp);
        }
        notificationUnreadCount = notificationCount;
        notificationTotalCount = studentCompLst.size();

        if (notificationWrpLst.size() > 0) {
            notificationsAvailable = true;
            notificationListCount = notificationWrpLst.size();
        }

        system.debug('notificationWrpLst');
    }

    public void updateCompSurvey() {

        if (scId != null) {
            system.debug('scIdscIdscIdscIdscId'+scId);
            student_competency__c studentComp  = new  student_competency__c  ();
            studentComp = [SELECT id,name,Survey_Message_Sent__c ,Contact__r.Email,Contact__r.name,Contact__r.firstName,competency_code__c,competency_title__c, End_of_Survey_Link__c FROM student_competency__c WHERE id=:scId];
            PageReference page = new PageReference(studentComp.End_of_Survey_Link__c);
            page.setRedirect(true);


            student_competency__c sc1= new student_competency__c();
            sc1.id=scId;
            sc1.Survey_Message_Sent__c=true;
            update sc1;

            getNotification();
        }
    }


    Public class notificationWrapper{
        public Boolean isNotificationRead {get;set;}
        public String surveyLink {get;set;}
        public String firstName {get;set;}
        public String competencyCode {get;set;}
        public String competencyTitle {get;set;}
        public String Id {get;set;}
        public Date completedDate {get;set;}
    }
    
}