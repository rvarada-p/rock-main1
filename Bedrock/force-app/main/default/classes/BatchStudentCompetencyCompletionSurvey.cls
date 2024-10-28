/************************************************************************************** 
 Apex Class Name     : BatchStudentCompetencyCompletionSurvey
 Created Date        : 4th April 2018
 Function            : This Batch Class Handles to create event and send survey message 
                       to the students in the intercom once the student competency is 
                       achieved or mastered
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ravitej Varada            04/04/2018                Original Version
*************************************************************************************/
global class BatchStudentCompetencyCompletionSurvey implements Database.Batchable<sObject>, Database.AllowsCallouts,Schedulable{
    
    public string soql;
    public string className = 'BatchStudentCompetencyCompletionSurvey';
    public Exception[] errors = new Exception[0];
    public List<Apex_Log__c> logs = new List<Apex_Log__c>();
    
    global void execute(SchedulableContext SC){ 
    Integer myCallOutLimit = Limits.getLimitCallouts();
    BatchStudentCompetencyCompletionSurvey objBatch = new BatchStudentCompetencyCompletionSurvey();
    ID batchprocessid = Database.executeBatch(objBatch,myCallOutLimit/2);    
    } 
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
         soql = 'SELECT id,name,Contact__r.Email,Contact__r.name,Contact__r.firstName,competency_code__c,competency_title__c, End_of_Survey_Link__c FROM student_competency__c ' +
                'WHERE (Status__c = \'Achieved\' OR Status__c= \'Mastered\') AND '+
                'Survey_Message_Sent__c = FALSE AND (NOT Competency_Code__c LIKE \'X_PM%\') AND competency__r.type__c =\'Academic\' and lastmodifiedDate = TODAY';
      
        return Database.getQueryLocator(soql);
     }

    
    global void execute(Database.BatchableContext BC, List<student_competency__c> scope) { 

        try{
        list<student_competency__c> lstStuCompUpdate = new  list<student_competency__c>();
        list<student_competency__c> lstStuComp = (list<student_competency__c>)scope;
        string accessToken ='';
        string endPointUrl ='';
        string eventName = 'Competency Completion Survey';
        string surveyMsg ='';
        integer totalSuccessCount  = 0;
        integer totalErrorCount  = 0;
        string statusMessage =''; 
       
        long todayDate = datetime.now().getTime()/1000;//Epoch format 
         //Custom Settings to retrive intercom information
        Community_Site_Settings__c defaultCustomSetngs = Community_Site_Settings__c.getValues('Default Settings');
        if( defaultCustomSetngs != null ) {
             endPointUrl= defaultCustomSetngs.IntercomEndPointUrl__c;
             accessToken= defaultCustomSetngs.Intercom_Access_Token__c;
        }
        //Iterating the sc records for contacts to Create Event and post a survey message through intercom api calls 
        for(student_competency__c sc :lstStuComp){
          system.debug('@@@@@Email : '+sc.Contact__r.email);
            string body = '{"event_name" : "'+eventName+'","created_at": '+todayDate+',"email" : "'+ sc.Contact__r.Email+'", "metadata": {"competency_code": "'+sc.competency_code__c+'"}}';
            //surveyMsg = 'Dear '+sc.Contact__r.firstName+',<br>Congratulations on successfully completing one of your program competencies!<br><a href= https://walden.co1.qualtrics.com/jfe/form/SV_3DlnvW2UKV6qy4R> Click here to give feedback on your completed Competency</a>.<br>If the link above does not work, please copy and paste the following link into your browser:  https://walden.co1.qualtrics.com/jfe/form/SV_3DlnvW2UKV6qy4R<br>Thank you!';
            surveyMsg = 'Dear '+sc.Contact__r.firstName+',<br>Congratulations on successfully completing ' + sc.competency_code__c + ': ' + sc.competency_title__c + '!<br><a href=' + sc.End_of_Survey_Link__c.replace(' ', '%20') + '>Please click here to give feedback on your completed Competency</a>.<br>Thank you!'; 
            system.HttpResponse response ;
            string endPointSuffix= 'events';
            //Intercom API call to create event
            response = intercomCall( body,  endPointSuffix ,endPointUrl,  accessToken);
            
            If(response.getStatusCode() == 200 ||response.getStatusCode() == 202){
              
                endPointSuffix= 'messages';
                body = '{"message_type": "inapp","body": "'+surveyMsg+'","from": {"type": "admin","id": "70474"},"to": {"type":"user","email": "'+ sc.Contact__r.Email+'"}}';
                //Intercom API call to post Message
                response = intercomCall( body,  endPointSuffix ,endPointUrl,  accessToken);
                
                If(response.getStatusCode() == 200){
                sc.Survey_Message_Sent__c  = true;
                lstStuCompUpdate.add(sc);
                
                statusMessage = 'Survey message sucessfully sent to '+sc.Contact__r.name+' ('+sc.Contact__r.Email+') for competency code ['+sc.Competency_Code__c+'].';
                logs.add(new apex_log__c(class_name__c=className,
                                         Status_Code__c= response.getStatusCode(),
                                         Reference_ID__c= sc.Id,
                                         Status_Message__c= 'Success',
                                         Message__c= statusMessage));
                    totalSuccessCount = totalSuccessCount+1;
                }else{//Intercom Message  call else statement

                statusMessage = 'Could not send survey message to '+sc.Contact__r.name+' ('+sc.Contact__r.Email+') for competency code ['+sc.Competency_Code__c+'].';
                logs.add(new apex_log__c(class_name__c=className,
                                         Status_Code__c= response.getStatusCode(),
                                         Reference_ID__c= sc.Id,
                                         Status_Message__c= 'Error',
                                         Message__c= statusMessage));
               totalErrorCount = totalErrorCount+1;
                }

            }else{//event call else statement
           
                statusMessage = 'Error encountered : '+response.getBody();
                logs.add(new apex_log__c(class_name__c=className,
                                         Status_Code__c= response.getStatusCode(),
                                         Reference_ID__c= sc.Id,
                                         Status_Message__c= 'Error',
                                         Message__c= statusMessage));
                totalErrorCount = totalErrorCount+1;                
            }
         }
        system.debug('totalSuccessCount'+totalSuccessCount);
        system.debug('totalErrorCount'+totalErrorCount);
         
         if(lstStuCompUpdate.size()!=0){
            update lstStuCompUpdate;
         }
           if(logs.size()!=0){
            system.debug('Logs'+logs.size());
            insert logs;
         }
        }catch(exception e){
         System.debug('An exception occurred: ' + e.getMessage());
         errors.add(e);
            
        system.debug('errors'+errors);
        system.debug('errors'+errors.size());
        }

    }
    //method to call INtercom Api.
     public static system.HttpResponse intercomCall(string body, string endPointSuffix , string endPointUrl, string accessToken){

            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPointUrl+endPointSuffix);
            request.setHeader('accept', 'application/json');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + accessToken);
            request.setMethod('POST');
            request.setBody(body);
            Http http = new Http();
            HTTPResponse response = http.send(request);
            System.debug(response.getStatusCode());
            System.debug(response.getBody());
            return response;
                
            }

    global void finish(Database.BatchableContext BC){ 
        system.debug('-------- Inside Finish');
        system.debug('errors'+errors);
        system.debug('errors'+errors.size());

        if (!errors.isEmpty() && errors.size()>0){
            string errorStr = '';
            for (Exception error: errors){
                string message = error.getMessage();
                logs.add(new apex_log__c(class_name__c=className,Status_Message__c= 'Error Exception',message__c= message));

            }
            if(logs.size()!=0){
            system.debug('Logs'+logs.size());
            insert logs;
         }
            
        }
       
     }
}