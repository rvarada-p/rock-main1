/*******************************************************************
Name  : BrandProfilesTriggerHandler
Author: Vinod (Appirio)
Date  : September 16, 2014
Description: Handler class for the Trigger BrandProfilesTrigger
*************************************************************************/
public with sharing class BrandProfilesTriggerHandler { 
    
    public static Id tempoRecordType;
    private set<ID> setCBLRecordTypes;
    private boolean isExecuting = false;
  private integer batchSize = 0;
  
  public BrandProfilesTriggerHandler(boolean isExecuting, integer size){
    isExecuting = isExecuting;
    batchSize = size;
    setCBLRecordTypes = Utility.getRecordTypeFromCBLCustomSetting(Brand_Profile__c.sObjectType.getDescribe());

    tempoRecordType = Schema.SObjectType.Brand_Profile__c.getRecordTypeInfosByName().get('Tempo').getRecordTypeId();
  }

  public void onBeforeInsert(list<Brand_Profile__c > newBrandProfile){          

        list<Brand_Profile__c>selectedCBL_BrandProfiles = new list<Brand_Profile__c>(); 
        for(Brand_Profile__c bProfile: newBrandProfile){
            if(setCBLRecordTypes.contains(bProfile.RecordTypeId) && bProfile.Email__c != null){
                selectedCBL_BrandProfiles.add(bProfile);
            }
        }
        TempoProfileHelper tempoProfileHelper = new TempoProfileHelper();

        if(!selectedCBL_BrandProfiles.isEmpty()){
            // create               
            tempoProfileHelper.associateBrandProfileWithContact(selectedCBL_BrandProfiles);
        }
    }

    public void onAfterInsert(list<Brand_Profile__c > newBrandProfile,map<ID,Brand_Profile__c> oldMap){
        System.debug('on after insert');
        // use to get contact
        set<ID> contactIds = new set<ID>();
        list<Brand_Profile__c>selectedCBL_BrandProfiles = new list<Brand_Profile__c>();
        
        for(Brand_Profile__c bProfile: newBrandProfile){
            if(setCBLRecordTypes.contains(bProfile.RecordTypeId) && bProfile.Contact__c != null){
                contactIds.add(bProfile.Contact__c);
                selectedCBL_BrandProfiles.add(bProfile);
            }
        }
        if(!selectedCBL_BrandProfiles.isEmpty()){
            system.debug('on creating bp and BS user');
            // create 
            TempoProfileHelper tempoProfileHelper = new TempoProfileHelper();
            tempoProfileHelper.createStudentInBS(newBrandProfile);
            tempoProfileHelper.associateContactOpportunityWithBrandProfile(selectedCBL_BrandProfiles,contactIds);
        }
    }
    
    public void onAfterUpdate(list<Brand_Profile__c > newBrandProfile,map<ID,Brand_Profile__c> oldMap){
        // use to get contact
        list<Brand_Profile__c>selectedCBL_BrandProfiles = new list<Brand_Profile__c>(); 
        list<Brand_Profile__c>selectedTempoBrandForSync = new list<Brand_Profile__c>();
        list<BrandProfileHistory> brandProfileHistory = new list<BrandProfileHistory>(); 
        
        Set<String> contactIds = new Set<String>();
           
        for(Brand_Profile__c bProfile: newBrandProfile){
            if(setCBLRecordTypes.contains(bProfile.RecordTypeId) && bProfile.Primary_Program_of_Interest__c != null && bProfile.Contact__c != null
                && bProfile.Primary_Program_of_Interest__c != oldMap.get(bProfile.id).Primary_Program_of_Interest__c 
                && bProfile.Primary_Program_of_Interest_Parent__c!= oldMap.get(bProfile.id).Primary_Program_of_Interest_Parent__c){
                selectedCBL_BrandProfiles.add(bProfile);
                if(bProfile.Primary_Program_of_Interest__c!=null && oldMap.get(bProfile.id).Primary_Program_of_Interest__c!=null) {
                    String newPrimaryProgram = (String) bProfile.Primary_Program_of_Interest__c; 
                    //newPrimaryProgram = newPrimaryProgram.subString(0,15);
                    String oldPrimaryProgram = (String)oldMap.get(bProfile.id).Primary_Program_of_Interest__c;
                    //oldPrimaryProgram = oldPrimaryProgram.subString(0, 15);
                    System.debug('Old Program ID :: ' + oldPrimaryProgram + ' New Primary Program :: ' + newPrimaryProgram);
                    BrandProfileHistory bp = new BrandProfileHistory(bProfile, newPrimaryProgram, oldPrimaryProgram, bProfile.Contact__c, bProfile.id);
                    brandProfileHistory.add(bp);
                }
            }
            String newEmail = bProfile.Email__c;
            String oldEmail =  oldMap.get(bProfile.id).Email__c;
            if(bProfile.Email__c != null &&  newEmail!=oldEmail){
                selectedTempoBrandForSync.add(bProfile);
            }  
            
             
            if( oldMap.get(bProfile.id).LMS_ID__C !=  bProfile.LMS_ID__C
                && bProfile.Contact__c !=  null ) {
                contactIds.add( bProfile.Contact__c );
            }                     
        }
        
        TempoProfileHelper tempoProfileHelper = new TempoProfileHelper();        
        if(!selectedTempoBrandForSync.isEmpty()) { 
            tempoProfileHelper.syncBrandProfileEmailAndChatterInformation(selectedTempoBrandForSync);           
        }
        
        if(!selectedCBL_BrandProfiles.isEmpty()){ 
            // create 
            tempoProfileHelper.createOpportunityOnPrimaryProgramOfInterestChanged(selectedCBL_BrandProfiles);
            ProgramReconciliation tbybReconciliation = new ProgramReconciliation();
            System.debug('Brand Profile history ::: ' + brandProfileHistory);
            tbybReconciliation.reconcileCOPTbybComps(brandProfileHistory);
        }
        
        if( !contactIds.isEmpty() ) {
            createUsers(contactIds);
        }
    }
    
    public void createUsers( Set<String> contactIds ) {
        List<Contact> contactsToCreateUsers = [ SELECT id,name, FirstName, LastName,  
                                                       AccountId,Email, 
                                                       CBL_Student_ID__c
                                                FROM Contact
                                                WHERE Id IN :contactIds ];
        Profile communityProfile = [ SELECT Id 
                                     FROM Profile
                                     WHERE Name = 'Tempo Community Users' 
                                     LIMIT 1 ];
        List<User> usersToCreate =  new List<User>();
        for( Contact contact : contactsToCreateUsers) {
           
             string alias ;
                    if(contact.LastName.length()>4){
                       alias= contact.FirstName.substring(0, 1) + contact.LastName.substring(0, 4);
                    }else {
                       alias =contact.FirstName.substring(0, 1) + contact.LastName;
                    }
            
            usersToCreate.add( new User( Username = contact.email,
                                         ContactId = contact.id,
                                         ProfileId = communityProfile.Id,
                                         Alias = alias,
                                         Email = contact.email + '.Walden',
                                         FirstName = contact.FirstName,
                                         LastName = contact.LastName,
                                         FederationIdentifier = contact.CBL_Student_ID__c,
                                         TimeZoneSidKey = 'America/New_York',
                                         LocaleSidKey= 'en_US',
                                         EmailEncodingKey = 'UTF-8',
                                         LanguageLocaleKey = 'en_US',
                                         IsActive = true
                                        ));
        }
        insert usersToCreate;
    }
    /*
     public void onBeforeUpdate(list<Brand_Profile__c > newBrandProfile,map<ID,Brand_Profile__c> oldMap){
        System.debug('In before update');
        list<Brand_Profile__c>selectedTempoBrandForSync = new list<Brand_Profile__c>();   
        for(Brand_Profile__c bProfile: newBrandProfile){
            String newEmail = bProfile.Email__c;
            String oldEmail =  oldMap.get(bProfile.id).Email__c;
            if(tempoRecordType==bProfile.RecordTypeId && bProfile.Email__c != null &&  newEmail!=oldEmail){
                selectedTempoBrandForSync.add(bProfile);
            }
        }
        TempoProfileHelper tempoProfileHelper = new TempoProfileHelper();
        if(!selectedTempoBrandForSync.isEmpty()) {
            tempoProfileHelper.syncBrandProfileEmailAndChatterInformation(selectedTempoBrandForSync);
        }
      }
      */
    /*
    public void onBeforeUpdate(list<Brand_Profile__c > newBrandProfile,map<ID,Brand_Profile__c> oldMap){
        list<Brand_Profile__c>selectedTempoBrandForValidation = new list<Brand_Profile__c>();   
        set<ID> setTempoBrandContactIds = new set<ID>();    

        // Brand Profile to prevent a Contact from having multiple Tempo Brand Profile records 
        for(Brand_Profile__c bProfile: newBrandProfile){
            if(tempoRecordType==bProfile.RecordTypeId && bProfile.Contact__c != null && oldMap.get(bProfile.id).Contact__c != null ){
                selectedTempoBrandForValidation.add(bProfile);
                setTempoBrandContactIds.add(bProfile.Contact__c);
            }
        }
        TempoProfileHelper tempoProfileHelper = new TempoProfileHelper(); 
        if(!selectedTempoBrandForValidation.isEmpty()){
            tempoProfileHelper.validateTempoBrandProfileExistForTheSelectedContact(selectedTempoBrandForValidation,setTempoBrandContactIds);
        }
    }
     */
     
    //Inner class used for processing logic for COP
    public class BrandProfileHistory {
        public Brand_Profile__c brandProfile { get; set; }
        public String oldProgramID { get; set; }
        public String newProgramID { get; set; }
        public String contactID { get; set; }
        public String brandProfileID { get; set; }
        
        public BrandProfileHistory() { }
        public BrandProfileHistory(Brand_Profile__c bp, String newProg, String oldProg, String contactID, String bpID) {
            this.brandProfile = bp;
            this.oldProgramID = oldProg;
            this.newProgramID = newProg;
            this.contactID = contactID;
            this.brandProfileID = bpID;
        }
    }
}