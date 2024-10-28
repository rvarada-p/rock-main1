/************************************************************************
Name  : SMEMessagesController
Developer: Sarah Khalid, Jan 2017
Description: Apex controller for the SMEMessages main page
             This class will run in System admin context 
             due to ChatterMessage object visibility issues
*************************************************************************/

public without sharing class SMEMessagesController {

    public static Id loggedInSMEId { get; set; }
    public String isArchived { get; set; }
    public Id selectedStudentId { get; set; }
    public String competencyId { get; set; }
    public String selectedSCId { get; set; }
    public static String chatMessage { get; set; }
    public static HttpResponse res { get; set; }
    public String searchString { get; set; }
    public StudentMessageList studentInfoHeader { get; set; }
    public List<StudentMessageList> leftNavList { get; set; }
    public list<SC_Self_Assessment_Answer__c> currentSelfAssessmentResponse { get; set; }
    public map<String,StudentMessageList> mapSCChatterMessages { get; set; } 
    public list<ChatterSCMessage> chatterMessageList { get; set; }
    public list<Student_Competency__c> studentComps { get; set; }
        
        public SMEMessagesController() {
        System.debug('In constructor');
        try { 
            loggedInSMEId = UserInfo.getUserId();
            competencyId = ApexPages.currentPage().getParameters().get('CompId');
            isArchived = ApexPages.currentPage().getParameters().get('archived');
            currentSelfAssessmentResponse = new list<SC_Self_Assessment_Answer__c>();
            if(mapSCChatterMessages==null) {
                getLeftNavStudents();
            }
        }  
        catch(Exception exp) {
            
        } 
    } 
    
    //Method that fetches the details for the neft nav bar
    public void getLeftNavStudents() {
        try {

            mapSCChatterMessages = new map<String, StudentMessageList>();
            studentComps = new List<Student_Competency__c>();
            String searchCriteria;
            String soql;
            if(loggedInSMEId==null) {
                loggedInSMEId = UserInfo.getUserId();
            }
            //If a competency ID is specified only fetch the Students related to that in expanded list view for left nav
            if(searchString!=null && searchString!='') {
                searchCriteria ='\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\'';             
            }
            else {
                searchCriteria ='\'%' + ''+ '%\'';     
            }
            system.debug('Competency ID : ' + competencyId + ' searchCriteria : ' + searchCriteria + ' is archived : ' + isArchived);
                        
            if(competencyId==null) { 
                    soql = 'SELECT Id, SME_Messaged_Student__c, Assessment_Submitted__c, Pause_Competency__c, IsCompleted__c, Competency__c, New_Messages__c, Outreach_Required__c, Engagement_Met__c, Engagement_Unmet__c, Competency_Code__c, Student_Name__c, Student_ID__c FROM Student_Competency__c WHERE SME__c = \''+  String.valueOf(loggedInSMEId) + '\' AND IsCompleted__c!=true AND IsStudentProgramActive__c = true AND Pause_Competency__c!=true AND (Student_Name__c LIKE ' + searchCriteria + ' OR Competency_Code__c LIKE ' + searchCriteria + ' ) ORDER BY New_Messages__c, Outreach_Required__c, Engagement_Unmet__c';
                    System.debug('SOQL : ' + soql);
                    studentComps = Database.query(soql);
            }
            //If no competency ID is specified fetch all the Competencies in collpased form on left nav for regular messages
            else if(competencyId!=null && isArchived!='true') {
                soql = 'SELECT Id, SME_Messaged_Student__c, Assessment_Submitted__c, Pause_Competency__c, IsCompleted__c, Competency__c, New_Messages__c, Outreach_Required__c, Engagement_Met__c, Engagement_Unmet__c, Competency_Code__c, Student_Name__c, Student_ID__c FROM Student_Competency__c WHERE SME__c = \'' + loggedInSMEId + '\' AND Competency__c =\'' + competencyId + '\' AND  IsStudentProgramActive__c = true AND IsCompleted__c!=true AND Pause_Competency__c!=true AND Student_Name__c LIKE ' + searchCriteria + ' ORDER BY New_Messages__c, Outreach_Required__c, Engagement_Unmet__c';
                System.debug('SOQL : ' + soql);
                studentComps = Database.query(soql);
            }
            //If no competency ID is specified fetch all the Competencies in collpased form on left nav for archived messages
            else if(competencyId!=null && isArchived=='true') {
                soql = 'SELECT Id, SME_Messaged_Student__c, Pause_Competency__c, IsCompleted__c, Assessment_Submitted__c, Competency__c, New_Messages__c, Outreach_Required__c, Engagement_Met__c, Engagement_Unmet__c, Competency_Code__c, Student_Name__c, Student_ID__c FROM Student_Competency__c WHERE SME__c = \'' + loggedInSMEId + '\' AND Competency__c =\'' + competencyId + '\' AND  IsStudentProgramActive__c = true AND (IsCompleted__c=true OR Pause_Competency__c=true) AND Student_Name__c LIKE ' + searchCriteria + ' ORDER BY New_Messages__c, Outreach_Required__c, Engagement_Unmet__c';
                System.debug('SOQL : ' + soql);
                studentComps = Database.query(soql);
            }            
            System.debug('SOQL : ' + soql + ' Student Comps: ' + studentComps); 
            //Based on the Student Competencies get the ChatterSCMessages
            List<ChatterSCMessage__c> messagesList = new List<ChatterSCMessage__c>([SELECT Id, MessageID__c, CreatedDate, Message_Sender__c, Status__c, Student__c, Student_Competency__c FROM ChatterSCMessage__c WHERE SME__c = :loggedInSMEId AND Student_Competency__c IN :studentComps ORDER BY CreatedDate ]);
            System.debug('Chatter Message List :: ' + messagesList + ' size  ' + studentComps.size());
            
            //Create a map of the chatter mesages coupled with ChatterSCMessage
            if(studentComps.size()>0 ) {
                for(Student_Competency__c sc : studentComps) {
                    StudentMessageList message = new StudentMessageList();
                    message.studentCompetencyId =  sc.Id; 
                    message.competencyCode = sc.Competency_Code__c;
                    message.studentName = sc.Student_Name__c;
                    message.isNewMessage = false;
                    message.outreachRequired = sc.Outreach_Required__c;
                    message.engagementUnmet = sc.Engagement_Unmet__c;
                    message.newStudentIndicator = false;
                    message.isEngagementMet = sc.Engagement_Met__c;     
                    message.smeUserId = loggedInSMEId;      
                    message.noNewMessages = sc.New_Messages__c;
                    message.selfAssessmentSubmitted = sc.Assessment_Submitted__c;
                    message.smeContactedStudent = sc.SME_Messaged_Student__c;
                    message.isPaused = sc.Pause_Competency__c;
                    message.isCompleted = sc.IsCompleted__c;
                    for(ChatterSCMessage__c cscm : messagesList) {                  
                        //If the student has a message history then populate it
                        if(sc.Id == cscm.Student_Competency__c) {                           
                            if(!mapSCChatterMessages.containsKey(sc.Id)) {
                                message.chatterSCMessageId = cscm.Id;
                                message.studentId = cscm.Student__c;         
                                message.lastMessageReceived = cscm.CreatedDate;
                                mapSCChatterMessages.put(sc.Id, message);                               
                            } 
                        }
                        
                    }
                    //If no message history between SME and Student for this competency
                    if(!mapSCChatterMessages.containsKey(sc.Id)) {
                        mapSCChatterMessages.put(sc.Id, message);
                    }
                                        
                }
            }
            //If the search did not return any results
            else if(studentComps.size() == 0 && searchString!=null) {
                String searchErrorMessage = SME_Dashboard__c.getValues('Current Settings').Search_Error_Message__c;  
                System.debug(searchErrorMessage);           
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, searchErrorMessage));
             }
            System.debug('ChatterSC Messages :: ' + mapSCChatterMessages); 
            if(searchString!=null) {
                searchString = null;
            }            
        }
        catch(Exception exp) {
            
        }
    } 
    
    public PageReference runSearch() {
        System.debug('In Search Function');
        //studentComps = (List<Student_Competency__c>)[FIND :searchString RETURNING Student_Competency__c(Name)][0];
        searchString = ApexPages.currentPage().getParameters().get('searchString');
        System.debug('Search String: ' + searchString);
        if(searchString!=null) {
            getLeftNavStudents();
        }
        return null;
    }
    
    //This method is invoked from the front end when the SME clicks on a Students Name
    public PageReference loadMessageDetails() {
        //load details about ChatterSCMessage
         String messageThreadError = SME_Dashboard__c.getValues('Current Settings').Message_Thread_Error__c;

        try {           
            if(selectedSCId!=null) {
                getCurrentSelfAssessmentResponse(selectedSCId);
                loadMessageHistory(selectedSCId);
                studentInfoHeader = mapSCChatterMessages.get(selectedSCId);
                System.debug('studentInfoHeader :' + studentInfoHeader);
                Student_Competency__c selectedSC = [SELECT Student_Email__c FROM Student_Competency__c WHERE Id = :selectedSCId LIMIT 1];
                String studentChatterEmail;
                //Append .tempowalden to the email and lookup against that in User object to get Chatter User ID for Student
                if(selectedSC!=null) {
                    studentChatterEmail = selectedSC.Student_Email__c;
                    if(studentChatterEmail!=null) {
                        studentChatterEmail = studentChatterEmail + '.tempowalden';
                        User studentChatterUser = [SELECT Id FROM User WHERE Username = :studentChatterEmail AND IsActive = true LIMIT 1];
                        if(studentChatterUser!=null) {
                            selectedStudentId = studentChatterUser.Id;
                        }
                    }
                }
                
            }
            else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, messageThreadError));                
            }
        }
        catch(Exception exp) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, messageThreadError));                            
        }
        
        return null;
    }
    
    //This method loads details for Reflect & Connect questionnare for selected message thread
    public void getCurrentSelfAssessmentResponse(Id scId) {
        if(scId!=null) {
            currentSelfAssessmentResponse = [SELECT Id, Competency_Title__c, Question__c, Answer__c, Question_Data_Type__c FROM SC_Self_Assessment_Answer__c WHERE Student_Competency_ID__c = :scId ORDER BY Display_Order__c ];
        }
        System.debug('Current Self Assessment Response : ' + currentSelfAssessmentResponse);
    }
    
    
    //This method loads the message thread by joining together the ChatterMessage and ChatterSCMessage__c objects
    public void loadMessageHistory(Id scId) {
        System.debug('In loadMessageHistory');
        list<ChatterSCMessage__c> currentMessageThread = new list<ChatterSCMessage__c>();
        list<Id> chatterMessageIds = new list<Id>();
        list<ChatterMessage> chatterMessages = new list<ChatterMessage>();
        
        try {
            currentMessageThread = [SELECT Id, MessageID__c, CreatedDate, Message_Sender__c, Status__c, Student__c, Student_Competency__c FROM ChatterSCMessage__c WHERE Student_Competency__c = :selectedSCId ORDER BY CreatedDate];
            if(currentMessageThread.size()>0 ) {
                for(ChatterSCMessage__c cm : currentMessageThread) {
                    if(cm.MessageID__c!=null) {
                        chatterMessageIds.add(cm.MessageID__c);
                    }
                }
            }
            if(chatterMessageIds.size() > 0) {
                chatterMessages = [SELECT Id, Body FROM ChatterMessage WHERE Id in :chatterMessageIds ORDER BY SentDate];
            }
            
            //map<String, list<ChatterSCMessage>> mapMessageList = new map<String, list<ChatterSCMessage>>();
            chatterMessageList = new list<ChatterSCMessage>();
            for(ChatterSCMessage__c cm : currentMessageThread) {
                String mapKey = '';
                mapKey = cm.Student_Competency__c + '-' + loggedInSMEId + '-' + cm.Student__c;
                ChatterSCMessage cscm = new ChatterSCMessage();
                cscm.chatterSCMessageId = cm.Id;
                cscm.messageId = cm.MessageID__c!=null ? cm.MessageID__c : '';
                cscm.studentCompetencyId = cm.Student_Competency__c!=null ? cm.Student_Competency__c : '';
                cscm.studentUserId = cm.Student__c!=null ? cm.Student__c : '';
                cscm.smeUserId = loggedInSMEId;
                cscm.messageStatus = cm.Status__c;
                TimeZone tz = UserInfo.getTimeZone();
                Decimal formattedDate =  tz.getOffset(cm.CreatedDate) / (1000 * 3600 * 24.0);
                cscm.messageTimestamp = cm.CreatedDate + formattedDate;
                cscm.messageSender = cm.Message_Sender__c;
                 
                for(ChatterMessage sfcm : chatterMessages) {
                    if(cm.MessageID__c!=null && sfcm.Id == cm.MessageID__c) {
                        cscm.messageBody = sfcm.Body;                       
                    }
                }
                chatterMessageList.add(cscm);      
                
            }
            if(currentMessageThread.size()>0) {
                markMessagesRead(currentMessageThread);
            }
            System.debug('Message List : Map Size :' + chatterMessageList.size() + '  ' + chatterMessageList);
        }
        catch(Exception exp) {
            
        }
    }
    
    //This method marks the conversation from the Student to SME as read when the SME loads the messages for a given conversation
    public void markMessagesRead(list<ChatterSCMessage__c> chatterMessages) {
        list<ChatterSCMessage__c> markReadList = new list<ChatterSCMessage__c>();
        for(ChatterSCMessage__c cm : chatterMessages) {
            if(cm.Message_Sender__c == 'Student') {
                cm.Status__c = 'Read';
                markReadList.add(cm);
            }
        }
        update markReadList;
    }
 
 
    @RemoteAction @future(callout=true)
    //This method insert a chatter message (combination of ChatterSCMessage object and the Salesforce native ChatterMessage objects)
    public static void insertChatterMessage(Id scId, Id studentId, Id smeId, String cMessage) {
        System.debug('Chat Text : ' + ' SC ID ' + scId + ' SME ID ' + smeId + ' Student ID ' + studentId );
        String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
        String url =  salesforceHost + '/services/data/v26.0/chatter/users/me/messages/';
        cMessage = cMessage.replace('\n', '\\n'); 
        cMessage = cMessage.replace('\"', '\\"'); 
        cMessage = cMessage.replace('/"', '//"'); 
        //String jsonString = JSON.serialize(cMessage);
        
        if(studentId!=null && smeId!=null && cMessage!=null) {
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(url);
            req.setHeader('Content-type', 'application/json');
            req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
            String messageJson = '{ "body" : "' + cMessage + '", "recipients" : ["' + studentId + '", "' + smeId + '"]}';
            System.debug('JSON : ' + messageJson);
            req.setBody(messageJson);
            
            Http http = new Http();
            //HttpResponse res;
            if(!Test.isRunningTest()) {
                res = http.send(req); 
                System.debug('HTTP Response : ' + res + ' Response Body : ' + res.getBody());               
            }
            if(res.getStatusCode() == 201) { 
                Map<String, Object> messageResponse = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                system.debug('Message Response ' + messageResponse);
                Id messageId = String.valueOf(messageResponse.get('id'));
                ChatterSCMessage__c scChatterMessage = new ChatterSCMessage__c();
                scChatterMessage.MessageId__c = messageId;
                scChatterMessage.SME__c = smeId;
                scChatterMessage.Student__c = studentId;
                scChatterMessage.Student_Competency__c = scId;
                scChatterMessage.Status__c = 'Un-Read';
                insert scChatterMessage;
                
            }
            else {
                String chatterSendError =  SME_Dashboard__c.getValues('Current Settings').Chatter_Message_Error__c;             
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, chatterSendError));                                          
            }
        }
    }    

    @RemoteAction 
    //This method marks an engagement as being met when the SME checks on the Engagement Met checkbox on the Messages Tab for a given SC 
    public static void markEngagementMet(Id scId) {
        System.debug('Student Comepetency ID :' + scId);
        Student_Competency__c compMarkEngagementMet = new Student_Competency__c();
        if(scId!=null) {
            compMarkEngagementMet.Id = scId;
            compMarkEngagementMet.Engagement_Met__c = true;
            update compMarkEngagementMet;
        }
    }
    
    //Inner class for the left hand section with student list
    public class StudentMessageList {
        public Id studentCompetencyId { get; set; }
        public String competencyCode { get; set; }
        public String competencyTitle { get; set; }
        public String studentName { get; set; }
        public Id studentId { get; set; }
        public Id smeUserId { get; set; }
        public Datetime lastMessageReceived { get; set; }
        public boolean isNewMessage { get; set; }
        public boolean outreachRequired { get; set; }
        public boolean engagementUnmet { get; set; }
        public boolean newStudentIndicator { get; set; }
        public boolean isEngagementMet { get; set; }
        public boolean isPaused { get; set; }
        public boolean isCompleted { get; set; }
        public String messageSender { get; set; }
        public Id chatterSCMessageId { get; set; }
        public Decimal noNewMessages { get; set; }
        public boolean selfAssessmentSubmitted { get; set; }
        public Decimal smeContactedStudent { get; set; }
        
        public StudentMessageList() {
            
        }

    }
    
    //Inner class for Chatter Message Thread 
    public class ChatterSCMessage { 
        public Id chatterSCMessageId { get; set; }
        public Id messageId { get; set; }
        public Id studentCompetencyId { get; set; }
        public Id studentUserId { get; set; }
        public Id smeUserId { get; set; }
        public String messageBody { get; set; }
        public String messageStatus { get; set; }
        public Datetime messageTimestamp { get; set; }
        public String messageSender { get; set; }
        
        public ChatterSCMessage() {
            
        }
    }

    
}