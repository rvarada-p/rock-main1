/************************************************************************
Name  : BatchCommUserProvisioning
Author: Ravitej Varada
Date  : February 14, 2018
Description: batch class for Apex Rule Engine: Community User Provisioning For Existing Users
*************************************************************************/
global with sharing class BatchCommUserProvisioning implements Database.Batchable<sObject>, Database.Stateful{

        global integer totalRecordsProcess;
        global integer totalSuccess;
        global integer totalFailure;
        global Set<String> contactIds = new Set<String>();
        
        public Map<Id, String> errorMap;
        public Map<Id, String> successMap;
        public String baseURL;
        public Map<Id, SObject> IdToSObjectMap;
        
        global BatchCommUserProvisioning (){
            errorMap = new Map<Id, String>();
            successMap = new Map<Id, String>();
            baseURL = URL.getSalesforceBaseUrl().toExternalForm();
            IdToSObjectMap = new Map<Id, SObject>();
        }
        
        global Database.QueryLocator start( Database.BatchableContext bc ){
            String SOQL;
            totalRecordsProcess = 0;
            totalSuccess = 0;
            totalFailure = 0;
            Date toDay = Date.today();

            SOQL = ' SELECT Id, Student_Status__c, Student__c, Student__r.CBL_Student_ID__c '+
                     'FROM Student_Program__c ' +
                     'WHERE  Student__r.CBL_Student_ID__c!= NULL AND ' +
                            'Student_Status__c = \'Active\'';
            return Database.getQueryLocator( SOQL );
        }

        global void execute( Database.BatchableContext bc, list<SObject> scope ){
            list<Student_Program__c> lstStudentProgram = (list<Student_Program__c>)scope;
            for(Student_Program__c lsSp : lstStudentProgram){
                contactIds.add( lsSp.Student__c );

            }
            if(!contactIds.isEmpty()) {

                List<Contact> contactsToCreateUsers = [
                        SELECT id,name, FirstName, LastName,
                               AccountId,Email,
                               CBL_Student_ID__c
                        FROM Contact
                        WHERE Id IN :contactIds
                ];
                
                Profile communityProfile = [
                        SELECT Id
                        FROM Profile
                        WHERE Name = 'Tempo Community Users'
                        LIMIT 1 ];
                        
                Set<String> contactIds = new Set<String>();
                for( User user : [ SELECT Id, ContactId,ProfileId FROM User 
                                   WHERE ProfileId = :communityProfile.id AND
                                         ContactId != null ] ) {
                    contactIds.add(user.ContactId);
                }
                
                List<User> usersToCreate = new List<User>();
                for (Contact contact : contactsToCreateUsers) {
                    string alias ;
                    if(contact.LastName.length()>4){
                       alias= contact.FirstName.substring(0, 1) + contact.LastName.substring(0, 4);
                    }else {
                       alias =contact.FirstName.substring(0, 1) + contact.LastName;
                    }
                    if( !contactIds.contains(contact.id) ) {
                        usersToCreate.add(new User(Username = contact.email,
                                    ContactId = contact.id,
                                    ProfileId = communityProfile.Id,
                                    Alias = alias,
                                    Email = contact.email + '.Walden',
                                    FirstName = contact.FirstName,
                                    LastName = contact.LastName,
                                    FederationIdentifier = contact.CBL_Student_ID__c,
                                    TimeZoneSidKey = 'America/New_York',
                                    LocaleSidKey = 'en_US',
                                    EmailEncodingKey = 'UTF-8',
                                    LanguageLocaleKey = 'en_US',
                                    IsActive = true
                        ));
                    }
                }
                
                List<Database.SaveResult> result = Database.Insert(usersToCreate, false);
                Integer index = 0;
                for( Database.SaveResult dsr : result ){
                    if(!dsr.isSuccess()){
                        String errMsg = dsr.getErrors()[0].getMessage();
                        errorMap.put(usersToCreate[index].ContactId, errMsg);
                       
                    } else {
                        String sucMsg = baseURL + '/' + usersToCreate[index].Id;
                        System.debug('usersToCreate : ' + usersToCreate);
                        System.debug('index : ' + index);
                        System.debug('usersToCreate[index].Id : ' + usersToCreate[index].Id);
                        successMap.put(usersToCreate[index].Id, sucMsg);
                    }
                    IdToSObjectMap.put(usersToCreate[index].Id, usersToCreate[index]);
                    index++;
                }

            }

            totalRecordsProcess+= lstStudentProgram.size();
            system.debug('totalRecordsProcess'+totalRecordsProcess);
        }
        
        void trackResultToApexLog(Database.BatchableContext BC) {
            if(! IdToSObjectMap.isEmpty()) {
                
                List<Apex_Log__c> logs = new List<Apex_Log__c>();
                
                if(!errorMap.isEmpty()){
                    for(Id id  : errorMap.keySet()){
                        Apex_Log__c log = new Apex_Log__c();
                        log.Status_Message__c = 'Fail';
                        log.Message__c = errorMap.get(id);
                        log.Reference_ID__c = 'User - ' + UserInfo.getUserId() + ';' + ' Contact id - ' + IdToSObjectMap.get(id);
                        log.class_name__c = 'BatchClassCommUserProvisioning';
                        logs.add( log );
                    }   
                }
                if(! successMap.isEmpty()) {
                    for(Id id  : successMap.keySet()){
                        Apex_Log__c log = new Apex_Log__c();
                        log.Status_Message__c = 'Success';
                        log.Message__c = errorMap.get(id);
                        log.Reference_ID__c = 'User - ' + UserInfo.getUserId() + ';' + ' Contact id - ' + ((User) IdToSObjectMap.get(id)).ContactId;
                        log.class_name__c = 'BatchClassCommUserProvisioning';
                        logs.add( log );
                    }
                }
                Database.insert(logs,false);
            }
        }
        
        global void finish(Database.BatchableContext BC){

            if( IdToSObjectMap != null && !IdToSObjectMap.isEmpty()) {
                trackResultToApexLog(BC);
            }
        }
    }