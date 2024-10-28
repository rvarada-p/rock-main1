/*******************************************************************
Name  : BrightSpaceCalls
Author: Sarah Khalid - Laureate
Date  : September 21, 2017
Description: Helper  class for making various API callouts with BrightSpace LMS
*************************************************************************/


global with sharing class BrightSpaceCalls {
    
    public static boolean exceededLimits = false;
    
    //This method creates an Area of Expertise in BrightSpace LMS
    @future (callout=true)
    public static void createAreaOfExpertise(String json, Id aoeId) {   
        JsonWrapper jsonGenerator = new JsonWrapper(); 
        System.debug('JSON in callout: ' + json);
        String lpVersion =  String.valueOf(D2L__c.getValues('D2L').LP_Version__c);
        String createAoEEndpoint = D2L__c.getValues('D2L').Create_AoE__c;
        createAoEEndpoint = createAoEEndpoint.replace('(version)', lpVersion);
        System.debug('Endpoint: ' + createAoEEndpoint);
        
        if(!checkAPILimits(aoeId, 'Area of Expertise')) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:BS' + createAoEEndpoint);
            req.setBody(json);
            req.setMethod('POST');
            
            Http http = new Http();
            HTTPResponse res;
            
            try {
                res = http.send(req); 
                
                System.debug('Response: ' + res.getBody() + ' Status Code: ' + res.getStatusCode());
                if(res.getStatusCode() == 200 ) {
                    String bsAoeId = jsonGenerator.returnOrgUnitCreateData(res.getBody());
                    System.debug('AoE ID: ' + bsAoeId);     
                    if(bsAoeId!=null && bsAoeId!='') { 
                        System.debug('Updating AoeID: ' + aoeId);
                        Area_of_Expertise__c aoeToUpdate = new Area_of_Expertise__c();
                        aoeToUpdate.id=aoeId;
                        aoeToUpdate.LMS_ID__c = bsAoeId;        
                        update aoeToUpdate;
                    }
                }
                else {
                    BrightSpace_API_Exceptions__c bsExp = new BrightSpace_API_Exceptions__c();
                    bsExp.Area_of_Expertise__c = aoeId;
                    if(res!=null) {
                        bsExp.Status_Code__c = res.getStatusCode();
                        bsExp.Error_Description__c = res.getStatus();
                    }
                    insert bsExp;                   
                }
            }
            catch(Exception exp) {
                System.debug('Exception: ' + exp);
                BrightSpace_API_Exceptions__c bsExp = new BrightSpace_API_Exceptions__c();
                bsExp.Area_of_Expertise__c = aoeId;
                if(res!=null) {
                    bsExp.Status_Code__c = res.getStatusCode();
                    bsExp.Error_Description__c = res.getStatus();
                }
                insert bsExp;
            }
        }
    }
    
    
    
    //This method creates an Area of Expertise in BrightSpace LMS
    @future (callout=true)
    public static void createProgram(String json, Id progId) {   
        JsonWrapper jsonGenerator = new JsonWrapper(); 
        System.debug('JSON in callout: ' + json);
        String lpVersion =  String.valueOf(D2L__c.getValues('D2L').LP_Version__c);
        String createAoEEndpoint = D2L__c.getValues('D2L').Create_AoE__c;
        createAoEEndpoint = createAoEEndpoint.replace('(version)', lpVersion);
        System.debug('Endpoint: ' + createAoEEndpoint);
        
        if(!checkAPILimits(progId, 'Program')) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:BS' + createAoEEndpoint);
            req.setBody(json);
            req.setMethod('POST');
            
            Http http = new Http();
            HTTPResponse res;
            
            try {
                res = http.send(req); 
                
                System.debug('Response: ' + res.getBody() + ' Status Code: ' + res.getStatusCode());
                if(res.getStatusCode() == 200 ) {
                    String bsProgId = jsonGenerator.returnOrgUnitCreateData(res.getBody());
                    System.debug('Prog LMS ID: ' + bsProgId);     
                    if(bsProgId!=null && bsProgId!='') { 
                        System.debug('Updating Prog LMS ID: ' + progId);
                        product2 progToUpdate = new product2();
                        progToUpdate.id=progId;
                        progToUpdate.LMS_ID__c = bsProgId;        
                        update progToUpdate;
                    }
                }
                else {
                    BrightSpace_API_Exceptions__c bsExp = new BrightSpace_API_Exceptions__c();
                   // bsExp.product2 = progId;
                    if(res!=null) {
                        bsExp.Status_Code__c = res.getStatusCode();
                        bsExp.Error_Description__c = res.getStatus();
                    }
                    insert bsExp;                   
                }
            }
            catch(Exception exp) {
                System.debug('Exception: ' + exp);
                BrightSpace_API_Exceptions__c bsExp = new BrightSpace_API_Exceptions__c();
               // bsExp.product2 = progId;
                if(res!=null) {
                    bsExp.Status_Code__c = res.getStatusCode();
                    bsExp.Error_Description__c = res.getStatus();
                }
                insert bsExp;
            }
        }
    }
    
    
    
    //This method create a user in Brightspace API
    @future (callout=true)
    public static void createUser(String json, Id userId) {   
        JsonWrapper jsonGenerator = new JsonWrapper(); 
        System.debug('JSON in callout: ' + json);
        System.debug('User ID: ' + userId);
        String lpVersion =  String.valueOf(D2L__c.getValues('D2L').LP_Version__c);
        String createUserEndpoint = D2L__c.getValues('D2L').Create_User_Endpoint__c;
        createUserEndpoint = createUserEndpoint.replace('(version)', lpVersion);
        System.debug('Endpoint: ' + createUserEndpoint);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:BS' + createUserEndpoint);
        req.setBody(json);
        req.setMethod('POST');
        if(!checkAPILimits(userId, '')) {
            Http http = new Http(); 
            HTTPResponse res;
            
            try {
                res = http.send(req); 
                System.debug('Response: ' + res.getBody() + ' Status Code: ' + res.getStatusCode());
                if(res.getStatusCode() == 200 ) {
                    Integer bsUserId = jsonGenerator.returnUserData(res.getBody()); 
                    
                    String myIdPrefix = userId.getSObjectType().getDescribe().getName();
                    System.debug('Id Prefix: ' + myIdPrefix);
                    if(myIdPrefix!=null) {
                        System.debug('Inserting User: ' + bsUserId + ' Object type: ' + myIdPrefix);
                        if(myIdPrefix == 'Brand_Profile__c') {
                            Brand_Profile__c bp = new Brand_Profile__c();
                            bp.Id = userId;
                            bp.LMS_ID__c = bsUserId;
                            update bp; 
                        }
                        else if(myIdPrefix == 'User') {
                            User userToUpdate = new User();     
                            userToUpdate.Id = userId;           
                            userToUpdate.LMS_ID__c = bsUserId;      
                            update userToUpdate;
                        }
                    }
                }
                else {
                    BrightSpace_API_Exceptions__c bsExp = new BrightSpace_API_Exceptions__c();
                    
                    if(res!=null) { 
                        bsExp.Status_Code__c = res.getStatusCode();
                        bsExp.Error_Description__c = res.getStatus();
                    }
                    insert bsExp;               
                }
            }  
            catch(Exception exp) {
                System.debug('Exception: ' + exp);
                BrightSpace_API_Exceptions__c bsExp = new BrightSpace_API_Exceptions__c();
                
                if(res!=null) {
                    bsExp.Status_Code__c = res.getStatusCode();
                    bsExp.Error_Description__c = res.getStatus();
                }
                insert bsExp;
            }
        }
    }   
    
    //This methods updates an existing user in the LMS
    @future (callout=true)
    public static void updateUser(String json, String userId, String contactId) {   
        JsonWrapper jsonGenerator = new JsonWrapper(); 
        System.debug('JSON in callout: ' + json);
        System.debug('User ID: ' + userId);
        String lpVersion =  String.valueOf(D2L__c.getValues('D2L').LP_Version__c);
        String updateUserEndpoint = D2L__c.getValues('D2L').Update_User__c;
        updateUserEndpoint = updateUserEndpoint.replace('(version)', lpVersion);
        updateUserEndpoint = updateUserEndpoint.replace('(userId)', userId);
        System.debug('Endpoint: ' + updateUserEndpoint);
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:BS' + updateUserEndpoint);
        req.setBody(json);
        req.setMethod('PUT'); 
        
        if(!checkAPILimits(contactId, 'Contact')) {
            Http http = new Http(); 
            HTTPResponse res;
            
            try {
                res = http.send(req); 
                System.debug('Response: ' + res.getBody() + ' Status Code: ' + res.getStatusCode());
                if(res.getStatusCode() == 200 ) {
                    //Update user flag on the Contact record
                    if(contactId!=null) {
                        Contact conToUpdate=new Contact();
                        conToUpdate.Id = contactId;
                        conToUpdate.Updated_CBL_ID_in_LMS__c = true;
                        update conToUpdate;
                    }
                }
                else {
                    BrightSpace_API_Exceptions__c bsExp = new BrightSpace_API_Exceptions__c();
                    
                    if(res!=null) {
                        bsExp.Status_Code__c = res.getStatusCode();
                        bsExp.Error_Description__c = res.getStatus();
                    }
                    insert bsExp;                   
                }
            } 
            catch(Exception exp) {
                System.debug('Exception: ' + exp);
                BrightSpace_API_Exceptions__c bsExp = new BrightSpace_API_Exceptions__c();
                
                if(res!=null) {
                    bsExp.Status_Code__c = res.getStatusCode();
                    bsExp.Error_Description__c = res.getStatus();
                }
                insert bsExp;
            }
        }
    }   
    
    
    //This method creates the Competency Template and Course Shell in BrightSpace LMS
    @future (callout=true)
    public static void createCompetencyTemplateAndShell(String compId, String compName, String compCode, list<Decimal> parents) {   
        JsonWrapper jsonGenerator = new JsonWrapper(); 
        String json = jsonGenerator.createCreateCourseTemplate(compName, compCode, parents);
        
        System.debug('JSON in callout: ' + json);
        String lpVersion =  String.valueOf(D2L__c.getValues('D2L').LP_Version__c);
        String createCompTemplateEndpoint = D2L__c.getValues('D2L').Create_Course_Template__c;
        String createCompShellEndpoint = D2L__c.getValues('D2L').Create_Competency_Shell__c;
        createCompTemplateEndpoint = createCompTemplateEndpoint.replace('(version)', lpVersion);
        createCompShellEndpoint = createCompShellEndpoint.replace('(version)', lpVersion);
        System.debug('Endpoint: ' + createCompTemplateEndpoint);
        
        if(!checkAPILimits(compId, 'Competency')) {
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:BS' + createCompTemplateEndpoint);
            req.setBody(json);
            req.setMethod('POST'); 
            
            Http http = new Http();
            HTTPResponse res;
            HTTPResponse createShellResponse;
            
            try {
                res = http.send(req); 
                
                System.debug('Response: ' + res);
                if(res.getStatusCode() == 200 ) {
                    System.debug('Respnse Body: ' + res.getBody());
                    
                    String bsCourseTemplateId = jsonGenerator.returnOrgUnitCreateData(res.getBody());
                    System.debug('Competency Template ID: ' + bsCourseTemplateId);
                    req=null;
                    res=null;   
                    if(bsCourseTemplateId!=null && bsCourseTemplateId!='') {
                        
                        Competency__c compToUpdate = new Competency__c();
                        compToUpdate.id=compId;
                        compToUpdate.Course_Template_ID__c = bsCourseTemplateId;    
                        
                        String jsonCompetencyShell = jsonGenerator.createCreateCompetencyShell(compName, compCode, Decimal.valueOf(bsCourseTemplateId));
                        System.debug('Json for Creating Competency Shell : ' + jsonCompetencyShell);
                        HttpRequest createShellReq = new HttpRequest();
                        
                        createShellReq.setEndpoint('callout:BS' + createCompShellEndpoint); 
                        createShellReq.setBody(jsonCompetencyShell);
                        createShellReq.setMethod('POST');
                        createShellResponse = http.send(createShellReq);
                        
                        System.debug('Response: ' + createShellResponse.getBody());
                        String bsCompetencyShellId = jsonGenerator.returnOrgUnitCreateData(createShellResponse.getBody());
                        System.debug('Shell ID ' + bsCompetencyShellId);
                        compToUpdate.Competency_Shell_ID__c = bsCompetencyShellId;
                        
                        update compToUpdate;
                        
                        Competency_Version__c  compVer = new Competency_Version__c (Competency__c =compId,Competency_Code__c =compCode,Competency_Shell_ID__c = bsCompetencyShellId,Active__c = TRUE);
                        insert compVer;
                    }
                    
                }
                else {
                    BrightSpace_API_Exceptions__c bsExp = new BrightSpace_API_Exceptions__c();
                    bsExp.Competency__c = compId;
                    if(res!=null) {
                        bsExp.Status_Code__c = res.getStatusCode();
                        bsExp.Error_Description__c = res.getStatus();
                    }
                    insert bsExp;                   
                }
                
            }
            catch(Exception exp) {
                
                BrightSpace_API_Exceptions__c bsExp = new BrightSpace_API_Exceptions__c();
                bsExp.Competency__c = compId;
                if(res!=null) {
                    bsExp.Status_Code__c = res.getStatusCode();
                    bsExp.Error_Description__c = res.getStatus();
                }
                insert bsExp;
                
            }
        }
    }   
    
    //This method creates an Enrollment in BrightSpace LMS
    @future (callout=true)
    public static void createEnrollment(String json, Id recordId, Decimal smeSection, Decimal studentLMSId, Decimal studentRoleID, Id scID) {   
        JsonWrapper jsonGenerator = new JsonWrapper(); 
        System.debug('JSON in callout: ' + json);
        String lpVersion =  String.valueOf(D2L__c.getValues('D2L').LP_Version__c);
        String createEnrollmentEndpoint = D2L__c.getValues('D2L').Create_Enrollment_Endpoint__c;
        createEnrollmentEndpoint = createEnrollmentEndpoint.replace('(version)', lpVersion);
        System.debug('Endpoint: ' + createEnrollmentEndpoint);
        
        if(!checkAPILimits(recordId, '')) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:BS' + createEnrollmentEndpoint);
            req.setBody(json);
            req.setMethod('POST');
            
            Http http = new Http();
            HTTPResponse res;
            HTTPResponse sectionEnrollmentResponse;
            
            System.debug('Request: '  + req);
            try {
                res = http.send(req); 
                
                System.debug('Response: ' + res.getBody() + ' Status Code: ' + res.getStatusCode());
                if(res.getStatusCode() == 200 ) {
                    //If course offering enrollment is successful then enroll into Section
                    String jsonSection = jsonGenerator.createEnrollmentData(smeSection, studentLMSId, studentRoleId);
                    //req=null;
                    //res=null; 
                    
                    System.debug('Json for Section enrollment : ' + jsonSection);
                    System.debug('End Point: ' + createEnrollmentEndpoint);
                    HttpRequest sectionEnrollmentReq = new HttpRequest();
                    
                    sectionEnrollmentReq.setEndpoint('callout:BS' + createEnrollmentEndpoint);  
                    sectionEnrollmentReq.setBody(jsonSection);
                    sectionEnrollmentReq.setMethod('POST');
                    sectionEnrollmentResponse = http.send(sectionEnrollmentReq);
                    
                    System.debug('Response: ' + sectionEnrollmentResponse.getStatusCode());
                    if(sectionEnrollmentResponse.getStatusCode() == 200) {      
                        Student_Competency__c sc = new Student_Competency__c();
                        sc.Id = scId;
                        sc.Student_Enrolled_in_LMS__c = true; 
                        update sc;
                    }
                    
                    if(sectionEnrollmentResponse.getStatusCode() == 200) {         
                        Student_Competency__c sc = new Student_Competency__c();
                        sc.Id = scId;
                        sc.Student_Enrolled_in_LMS__c = true; 
                        update sc;
                    }             
                }
                else {
                    BrightSpace_API_Exceptions__c bsExp = new BrightSpace_API_Exceptions__c();
                    //bsExp.Area_of_Expertise__c = aoeId;
                    if(res!=null) {
                        bsExp.Status_Code__c = res.getStatusCode();
                        bsExp.Error_Description__c = res.getStatus();
                        bsExp.Student_Competency__c = scId;
                    }
                    insert bsExp;                   
                }
                
            }
            catch(Exception exp) {
                System.debug('Exception: ' + exp);
                BrightSpace_API_Exceptions__c bsExp = new BrightSpace_API_Exceptions__c();
                //bsExp.Area_of_Expertise__c = aoeId;
                if(res!=null) {
                    bsExp.Status_Code__c = res.getStatusCode();
                    bsExp.Error_Description__c = res.getStatus();
                    bsExp.Student_Competency__c = scId;
                }
                insert bsExp;
            }
        }
    }
    
    
    
    
    @future (callout=true)
    public static void studentCoachEnrollment(String json, Id recordId, String auditorId, string removeCoachid) {   
        
        system.debug('removeCoachid'+removeCoachid);
        System.debug('JSON in callout: ' + json);
        String leVersion =  String.valueOf(D2L__c.getValues('D2L').LE_Version__c);
        String auditorAuditeeEndPoint = D2L__c.getValues('D2L').Auditor_Auditee_End_Point__c;
        auditorAuditeeEndPoint = auditorAuditeeEndPoint.replace('(version)', leVersion);
        auditorAuditeeEndPoint = auditorAuditeeEndPoint.replace('(auditorId)', auditorId);
        System.debug('Endpoint: ' + auditorAuditeeEndPoint);
        
        if(!checkAPILimits(recordId, 'Student Program')) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:BS' + auditorAuditeeEndPoint);
            req.setBody(json);
            req.setMethod('POST');
            
            Http http = new Http();
            HTTPResponse res;
            System.debug('Request: '  + req);
            try {
                res = http.send(req); 
                System.debug('Response: ' + res.getBody() + ' Status Code: ' + res.getStatusCode());
                if(res.getStatusCode() == 200 ) {
                    if(removeCoachid != '' && removeCoachid != null){
                        BrightSpaceCalls.studentCoachUnEnrollment(json, recordId, removeCoachid);
                    }
                }
                else {
                    BrightSpace_API_Exceptions__c bsExp = new BrightSpace_API_Exceptions__c();
                    bsExp.Student_Program__c = recordId;
                    if(res!=null) {
                        bsExp.Status_Code__c = res.getStatusCode();
                        bsExp.Error_Description__c = res.getStatus();
                    }
                    insert bsExp;                   
                }
                
            }
            catch(Exception exp) { 
                System.debug('Exception: ' + exp);
                BrightSpace_API_Exceptions__c bsExp = new BrightSpace_API_Exceptions__c();
                bsExp.Student_Program__c = recordId;
                if(res!=null) {
                    bsExp.Status_Code__c = res.getStatusCode();
                    bsExp.Error_Description__c = res.getStatus();
                }
                insert bsExp;
            }
        }
    }
    
    
    
     
    //This method creates an Enrollment in BrightSpace LMS
    public static void studentCoachUnEnrollment(String json, Id recordId, String auditorId) {   
        
        System.debug('JSON in callout: ' + json);
        String leVersion =  String.valueOf(D2L__c.getValues('D2L').LE_Version__c);
        String auditorAuditeeEndPoint = D2L__c.getValues('D2L').Auditor_Auditee_End_Point__c;
        auditorAuditeeEndPoint = auditorAuditeeEndPoint.replace('(version)', leVersion);
        auditorAuditeeEndPoint = auditorAuditeeEndPoint.replace('(auditorId)', auditorId);
        System.debug('Endpoint: ' + auditorAuditeeEndPoint);
        
        if(!checkAPILimits(recordId, 'Student Program')) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:BS' + auditorAuditeeEndPoint);
            req.setBody(json);
            req.setMethod('DELETE');
            
            Http http = new Http();
            HTTPResponse res;
            System.debug('Request: '  + req);
            try {
                res = http.send(req); 
                
                System.debug('Response: ' + res.getBody() + ' Status Code: ' + res.getStatusCode());
                if(res.getStatusCode() == 200 ) {
                     
                }
                else {
                    BrightSpace_API_Exceptions__c bsExp = new BrightSpace_API_Exceptions__c();
                    bsExp.Student_Program__c = recordId;
                    if(res!=null) {
                        bsExp.Status_Code__c = res.getStatusCode();
                        bsExp.Error_Description__c = res.getStatus();
                    }
                    insert bsExp;                   
                }
                
            }
            catch(Exception exp) { 
                System.debug('Exception: ' + exp);
                BrightSpace_API_Exceptions__c bsExp = new BrightSpace_API_Exceptions__c();
                bsExp.Student_Program__c = recordId;
                if(res!=null) {
                    bsExp.Status_Code__c = res.getStatusCode();
                    bsExp.Error_Description__c = res.getStatus();
                }
                insert bsExp;
            }
        }
    }

    
    //Unenroll Student Section from Bright Space in batch mode
    public static void markStudentCompleteInLMS(List<Student_Sections__c> lstStudentSections) {   
        
        List<Apex_Log__c> logs = new List<Apex_Log__c>();
        integer totalSuccessCount  = 0;
        integer totalErrorCount  = 0; 
        string className = 'BatchStudentCompleteAPI';
        
        
        //Fetch the different related custom settings
        String lpVersion =  String.valueOf(D2L__c.getValues('D2L').LP_Version__c);
        String unEnrollStudentEndPoint = D2L__c.getValues('D2L').Create_Enrollment_Endpoint__c;     
        unEnrollStudentEndPoint = unEnrollStudentEndPoint.replace('(version)', lpVersion);  
        Decimal unenrolledStudentRoleId = D2L__c.getValues('D2L').Unenrolled_Student_Role_ID__c; 
        system.debug('unEnrollStudentEndPoint '+ unEnrollStudentEndPoint);
        JsonWrapper jsonGenerator = new JsonWrapper(); 
        list<Student_Sections__c> lstSSToUpdate = new list<Student_Sections__c>(); 
        
        for(Student_Sections__c ss : lstStudentSections) {
            system.debug('ss'+ ss.id);
            Decimal competencyShellID = ss.Competency_Shell_ID__c!=null ? Decimal.valueOf(ss.Competency_Shell_ID__c) : null;
            Integer studentLMSID = ss.Student_LMS_ID__c!=null ? Integer.valueOf(ss.Student_LMS_ID__c) : null;
            Integer sectionID = ss.LMS_Section_ID__c!=null ? Integer.valueOf(ss.LMS_Section_ID__c) : null;
            
            if(competencyShellID!=null && studentLMSID!=null && sectionID!=null) {
                System.debug('Comeptency Shell ID: ' + competencyShellID + ' Student LMS ID ' + studentLMSID + ' Section ID ' + sectionID);
                HttpRequest req = new HttpRequest();
                Http http = new Http();
                HTTPResponse res;
                HTTPResponse studentUnEnrollentResponse;
                String json = jsonGenerator.createEnrollmentData(competencyShellID, studentLMSId, unenrolledStudentRoleId);
                System.debug('Unenroll Student Endpoint: ' + unEnrollStudentEndPoint + ' json body: ' + json);
                
                try {
                    
                    //API call for Role change from the course 
                    HttpRequest unEnrollStudentRequest = new HttpRequest();
                    unEnrollStudentRequest.setEndpoint('callout:BS' + unEnrollStudentEndPoint); 
                    unEnrollStudentRequest.setBody(json);
                    unEnrollStudentRequest.setMethod('POST');
                    studentUnEnrollentResponse = http.send(unEnrollStudentRequest);
                    system.debug('studentUnEnrollentResponse'+ studentUnEnrollentResponse);
                    if(studentUnEnrollentResponse.getStatusCode() == 200) {
                        System.debug('Roll Changed from Course Offering');
                        ss.Unenrolled_from_LMS__c = true; 
                        lstSSToUpdate.add(ss);
                        //store the success logs to Apex_log__c object 
                        logs.add(new apex_log__c(class_name__c=className,
                                                 Status_Code__c= studentUnEnrollentResponse.getStatusCode(),
                                                 Status_Message__c= 'SUCCESS',
                                                 method_name__c  = 'markStudentCompleteInLMS',
                                                 Message__c= 'Successfully changed the role to \'Student (Complete)\' from Course Offering.'+' Id : ' +ss.Id));
                        totalSuccessCount = totalSuccessCount+1;   
                    }else{
                        //store the Error logs to Apex_log__c object 
                        logs.add(new apex_log__c(class_name__c=className,
                                                 Status_Code__c= studentUnEnrollentResponse.getStatusCode(),
                                                 Status_Message__c= 'ERROR',
                                                 method_name__c  = 'markStudentCompleteInLMS',
                                                 Message__c= 'Error encountered - ID :' + ss.Id+' Response : ' +studentUnEnrollentResponse.getBody()));
                        totalErrorCount = totalErrorCount+1;
                        
                    }
                    
                }
                catch(Exception exp) {
                    System.debug('Exception: ' + exp);
                }
            }
        }
        system.debug('totalErrorCount'+totalErrorCount);
        system.debug('totalSuccessCount'+totalSuccessCount);
        
        
        if(logs.size()!=0){
            system.debug('Logs'+logs.size());
            insert logs;
        }
        
        if(!lstSSToUpdate.isEmpty()) {
            update lstSSToUpdate;
        }
    }
    
    
    
    //This methods activates or deactivates user in the LMS in batch mode    
    public static void updateUserIsActive(List<Student_Program__c> lstStudentPrograms) {   
        List<Apex_Log__c> logs = new List<Apex_Log__c>();
        integer totalSuccessCount  = 0;
        integer totalErrorCount  = 0; 
        JsonWrapper jsonGenerator = new JsonWrapper(); 
        String lpVersion;
        list<Student_Program__c> spsToUpdate = new list<Student_Program__c>();
        list<BrightSpace_API_Exceptions__c> bsExceptions = new list<BrightSpace_API_Exceptions__c>();
        lpVersion =  String.valueOf(D2L__c.getValues('D2L').LP_Version__c);
        for(Student_Program__c sp: lstStudentPrograms) {
            boolean isActive = sp.IsStudentProgramActive__c;
            String cblId = sp.CBL_Id__c;
            String firstName = sp.Student_First_Name__c;
            String lastName =  sp.Student_Last_Name__c;
            String email = sp.Student_Primary_Email__c;
            String LmsUserId= string.valueOf(integer.valueOf(sp.Student_LMS_ID__c));
            system.debug('spID--------'+sp.Id+'isActive----:'+isActive+'------cblId :'+cblId+'------email'+email+'------firstName'+firstName+'------lastName+'+lastName+'------LmsUserId'+LmsUserId);
            String json= jsonGenerator.updateUser(cblId,firstName,lastName,email,isactive);
            System.debug('@@@@@@json'+json);
            
            String updateUserEndpoint = D2L__c.getValues('D2L').Update_User__c;
            updateUserEndpoint = updateUserEndpoint.replace('(version)', lpVersion);
            
            if( String.isNotBlank(LmsUserId)) {
                updateUserEndpoint = updateUserEndpoint.replace('(userId)', LmsUserId);
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:BS' + updateUserEndpoint);
                req.setBody(json);
                req.setMethod('PUT'); 
                system.debug(' isActive '+isActive);
                
                Http http = new Http(); 
                HTTPResponse res;
                
                try {
                    res = http.send(req); 
                    System.debug('Response: ' + res.getBody() + ' Status Code: ' + res.getStatusCode());
                    if(res.getStatusCode() == 200) {
                        //Update Active in LMS flag on the SP record
                        Student_Program__c sProg = new Student_Program__c();
                        sProg.Id = sp.Id;
                        if(sp.IsStudentProgramActive__c == true) {
                            sProg.Date_Activated_in_LMS__c = System.today();
                            logs.add(new apex_log__c(class_name__c= 'BatchActivateStudentInBS',
                                                     Status_Code__c= res.getStatusCode(),
                                                     Status_Message__c= 'SUCCESS',
                                                     method_name__c  = 'updateUserIsActive',
                                                     Message__c= 'Successfully Activated user in BS for Student: '+ sp.Student__r.Name+' SP ID :  ' +sp.Id));
                        }
                        else {
                            sProg.Date_De_activated_in_LMS__c = System.today();
                            logs.add(new apex_log__c(class_name__c= 'BatchDeActiveStudentInBS',
                                                     Status_Code__c= res.getStatusCode(),
                                                     Status_Message__c= 'SUCCESS',
                                                     method_name__c  = 'updateUserIsActive',
                                                     Message__c= 'Successfully De-Activated user in BS for Student: '+ sp.Student__r.Name+' SP ID :  ' +sp.Id));
                        }
                        
                        totalSuccessCount = totalSuccessCount+1;   
                        spsToUpdate.add(sProg);
                    } 
                    else {
                        system.debug('Response'+ res.getBody()+' Status Code: ' + res.getStatusCode());
                        BrightSpace_API_Exceptions__c bsExp = new BrightSpace_API_Exceptions__c();
                        logs.add(new apex_log__c(class_name__c= 'BatchActivateStudentInBS',
                                                 Status_Code__c= res.getStatusCode(),
                                                 Status_Message__c= 'ERROR',
                                                 method_name__c  = 'updateUserIsActive',
                                                 Message__c= 'Error encountered - ID :' + sp.Id+' Response : ' +res.getBody()));
                        if(res!=null) {
                            bsExp.Status_Code__c = res.getStatusCode();
                            bsExp.Error_Description__c = res.getStatus();
                        }
                        //insert bsExp;  
                        totalErrorCount = totalErrorCount+1; 
                        bsExceptions.add(bsExp);               
                    }
                } 
                catch(Exception exp) {
                    System.debug('Exception: ' + exp);
                    BrightSpace_API_Exceptions__c bsExp = new BrightSpace_API_Exceptions__c();
                    
                    if(res!=null) {
                        bsExp.Status_Code__c = res.getStatusCode();
                        bsExp.Error_Description__c = res.getStatus();
                    }
                    bsExceptions.add(bsExp);
                }   
            }       
        }
        if(!spsToUpdate.isEmpty()) {
            update spsToUpdate;
        }
        if(!bsExceptions.isEmpty()) {
            insert bsExceptions;
        }
        if(logs.size()!=0){
            system.debug('Logs'+logs.size());
            insert logs;
        }
    }      
    
    
    
    public static boolean checkAPILimits(String recordId, String recordType) {
        
        System.debug(' limits : ' + Limits.getLimitFutureCalls());
        if(Limits.getLimitFutureCalls()<1) {
            BrightSpaceCalls.exceededLimits = true;
        }
        if(BrightSpaceCalls.exceededLimits) {
            BrightSpace_API_Exceptions__c bsExp = new BrightSpace_API_Exceptions__c();
            if(recordType == 'Area of Expertise') {
                bsExp.Area_of_Expertise__c = recordId;
            }
            else if(recordType == 'Competency') {
                bsExp.Competency__c = recordId;
            }
            else if(recordType=='Contact') {
                bsExp.Contact__c = recordId;
            }
            else if(recordType=='Student Program') {
                bsExp.Student_Program__c = recordId;
            }
            bsExp.Error_Description__c = 'Future Callout Limit in Transaction Exceeded';
            System.debug('bsExp : ' + bsExp);
            System.debug('bsExp : ' + new DmlException().getStackTraceString());
            insert bsExp;
        }
        
        return BrightSpaceCalls.exceededLimits;
    }
    
}