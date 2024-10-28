/*******************************************************************
Name  : ContactHelper
Author: Vinod (Appirio)
Date  : December 09, 2014
Description: Helper class for contact
*************************************************************************/
public with sharing class ContactHelper {
    
  public static set<Id> populatedCBLStudentIdSet = new set<Id>();

    public void populateCBLStudentId(set<ID> selectedContactIds){   
        // check contact CBL_Student_ID__c is already populated or not
        list<Contact> lstContacts = [Select ID,CBL_Student_ID__c from Contact where Id in:selectedContactIds and CBL_Student_ID__c = null];
        if(! lstContacts.isEmpty()){
            populateCBLStudentId(lstContacts);
    }
    }
    
    /******************************************************************************************************
    Populate CBL_Student_ID__c value on all Contacts with RecordType Name of "Custom Person Account Contact"
    Format needs to be "CBL+6digits". Example: CBL123456. First no will be CBL000001
    Related task: T-338463
    Created date:December 09, 2014
    *******************************************************************************************************/
    public void populateCBLStudentId(list<Contact> selectedContact){        
        list<Contact> lstContactForUpdate = new list<Contact>();
        // first get recent created contact.CBL_Student_ID__c to create next CBL_Student_ID__c
        list<Contact> mostRecentContact = [Select CBL_Student_ID__c from Contact where CBL_Student_ID__c != null order by CBL_Student_ID__c desc limit 1 ]; //CreatedDate desc limit 1];
        decimal lastCblStudentNo = 0;
        if(mostRecentContact != null && !mostRecentContact.isEmpty() && mostRecentContact[0].CBL_Student_ID__c.length() > 3){
            string strCblNo = mostRecentContact[0].CBL_Student_ID__c;
            // remove three character prefix 'CBL'
            strCblNo = strCblNo.subString(3,mostRecentContact[0].CBL_Student_ID__c.length());       
      if(!strCblNo.containsAny('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')) {
              lastCblStudentNo = decimal.valueOf(strCblNo);     
      }
        }
        // populate the cbl student id
        for(Contact con: selectedContact){
            Contact newContact = new Contact(Id= con.id);
            // increment 1 in last cbl no
            lastCblStudentNo++;
            // create next cbl no
            string strNextCblNo = string.valueOf(lastCblStudentNo);
            string nextCblNo = 'CBL';
            // prefix the 0
            for(integer i= strNextCblNo.length();i < 6;i++){
                nextCblNo = nextCblNo + '0';
            }
            // add CBL no
            nextCblNo = nextCblNo + strNextCblNo;
            if(strNextCblNo.length()<=9 ){
                // CBL_Student_ID__c length is 9
                newContact.CBL_Student_ID__c = nextCblNo;
              lstContactForUpdate.add(newContact);
        populatedCBLStudentIdSet.add(newContact.Id);    
            }    
        }
        system.debug('lstContactForUpdate::::::::::::::'+lstContactForUpdate);
        list<Contact> lstContactForUpdateRandomAlphaNumID = new list<Contact>();
        Database.Saveresult[] updateResult1 = Database.update(lstContactForUpdate,false);
        system.debug('updateResult1'+updateResult1);
    integer i=0;
        for(Database.SaveResult sr : updateResult1) {
            if(!sr.isSuccess()) {
                Contact newContact = lstContactForUpdate[i];
                lstContactForUpdateRandomAlphaNumID.add(newContact);
            }   
            i++;                
        }    
        system.debug('lstContactForUpdateRandomAlphaNumID::::::::::::::'+lstContactForUpdateRandomAlphaNumID);
    if(!lstContactForUpdateRandomAlphaNumID.isEmpty()) {          
        apexLogHandler.apexLog log;
        for(Contact con: lstContactForUpdateRandomAlphaNumID){
            string nextCblNo = 'CBL' +generateRandomAlphaNumericString(6);
            con.CBL_Student_ID__c = nextCblNo;  
        populatedCBLStudentIdSet.add(con.Id); 
        }
        Database.Saveresult[] updateResult2 = Database.update(lstContactForUpdateRandomAlphaNumID,false);
        for(Database.SaveResult sr : updateResult2) {
            if (!sr.isSuccess()) {
                // log error message
                string strMessage = '';
                for(Database.Error err : sr.getErrors()) {
                    strMessage+=  err.getMessage(); 
                }
                system.debug('strMessage1111111111'+strMessage);
                log = new apexLogHandler.apexLog('ContactHelper','populateCBLStudentId', strMessage);
            }                   
        }
        if(log != null){
            log.saveLogs();
        }
      }

    }
    /******************************************************************************************************
    get random  digit alpha numeric number 
    *******************************************************************************************************/
  public String generateRandomAlphaNumericString(integer length){
        String randomString = '';
        String characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
        integer charactersLength = characters.length();
        for (integer i = 0; i < length; i++) {
            double index = Math.random() * charactersLength;
            integer intIndex = (Integer)index;
            system.debug('intIndex:::::::::::::'+intIndex);
            randomString = randomString+ characters.subString(intIndex,intIndex+1);         
        }
        return randomString;
    }


  /******************************************************************************************************
   If just one of the Contact's Opps (of CBL RecordType variety) is in a Stage other than "New", "Uncontacted", "Contacted", or "Qualified"
  AND the running user's profile is not System Administrator, Tempo Integrator, CBL Registrar, or CBL Administrator, then throw a validation error that says:
  "You do not have the permission to edit the Contact"
  Related task: T-339567
  Created date:December 10, 2014
  *******************************************************************************************************/
 /*public void validateContactOnEdit(list<Contact> selectedContact){
    // get current user profile
    string strCurrentUserProfileName = '';
    for(Profile p:[Select Name,ID From Profile where id =: userInfo.getProfileId()]){
      strCurrentUserProfileName = p.Name;
    }
    set<string> setProfileName = new set<string>{'System Administrator','Tempo Integrator','CBL Registrar','CBL Administrator'};
    if(setProfileName.contains(strCurrentUserProfileName)){
      // no need to validate
      return;
    }
    // get opportunity cblrecordtypes
    set<ID> setCBLRecordTypes = Utility.getRecordTypeFromCBLCustomSetting(Opportunity.sObjectType.getDescribe());       
    set<string> setOpportunityStageName = new set<string>{'New','Uncontacted','Contacted','Qualified'};
    // get all opportunity of the contact
    map<ID,Opportunity> mapContactWithOpenCblOpportunity = new map<ID,Opportunity>();
    for(Opportunity opty:[select Id,Contact__c, StageName, Name from Opportunity 
                         where Contact__c in:selectedContact 
                         and RecordTypeId in: setCBLRecordTypes
                         and StageName  not in: setOpportunityStageName]){
      mapContactWithOpenCblOpportunity.put(opty.Contact__c,opty);
    }
    //
    for(Contact con: selectedContact){
      if(mapContactWithOpenCblOpportunity.containsKey(con.ID)
        && !populatedCBLStudentIdSet.contains(con.ID) ){
          // 
        con.addError('You do not have the permission to edit this Contact record because its Opportunity \''
                        + mapContactWithOpenCblOpportunity.get(con.ID).Name
                        + '\' is in the \''
                        + mapContactWithOpenCblOpportunity.get(con.ID).StageName
                        + '\' stage. Please contact your manager if something needs to be changed here.');
      }
    }
      
      
  } */
  /******************************************************************************************************
    Populate CBL_Student_ID__c on Account when ever Contact.CBL_Student_ID__c is updated
    Related task: T-338628
    Created By: Vinod 
    *******************************************************************************************************/
    public void updateCustomPersonAccount(list<Contact> selectedContact,set<ID> accountIds,map<ID,Contact> contactOldMap){ //populateCBLStudentIdOnAccount
        // get all selected account
        map<ID,Account> mapAccount = new map<ID,Account>([SELECT ID,Name,CBL_Student_Id__c,Phone,BillingStreet,Billing_Non_US_State__c
                                                        ,BillingCity,BillingState,BillingPostalCode,BillingCountry
                                                        ,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry
                                                      FROM Account WHERE id in: accountIds]);
    Boolean doUpdate = false;
        for(Contact con: selectedContact){
      
      // upon new
      if(contactOldMap==null){
        mapAccount.get(con.AccountId).Name = con.FirstName+' '+con.LastName;
        mapAccount.get(con.AccountId).CBL_Student_Id__c = con.CBL_Student_Id__c;
        mapAccount.get(con.AccountId).Phone = con.Phone;
        mapAccount.get(con.AccountId).BillingStreet = con.MailingStreet;
        mapAccount.get(con.AccountId).BillingCity = con.MailingCity;
        mapAccount.get(con.AccountId).BillingState = con.MailingState;
        mapAccount.get(con.AccountId).Billing_Non_US_State__c = con.Mailing_Non_US_State__c;
        mapAccount.get(con.AccountId).BillingPostalCode = con.MailingPostalCode;
        mapAccount.get(con.AccountId).BillingCountry = con.MailingCountry;
        doUpdate = true;

      // during update if changed
      } else {
            if(con.CBL_Student_ID__c!=null&&(con.CBL_Student_ID__c!=contactOldMap.get(con.Id).CBL_Student_ID__c)){
          mapAccount.get(con.AccountId).CBL_Student_Id__c = con.CBL_Student_Id__c;
          doUpdate = true;
        }
        if((con.FirstName!=null&&(con.FirstName!=contactOldMap.get(con.Id).FirstName))
          ||(con.LastName!=null&&(con.LastName!=contactOldMap.get(con.Id).LastName))){
          mapAccount.get(con.AccountId).Name = con.FirstName+' '+con.LastName;
          doUpdate = true;
        }
        if(con.Phone!=null&&(con.Phone!=contactOldMap.get(con.Id).Phone)){
          mapAccount.get(con.AccountId).Phone = con.Phone;
          doUpdate = true;
        }
        if(con.MailingStreet!=null&&(con.MailingStreet!=contactOldMap.get(con.Id).MailingStreet)){
          mapAccount.get(con.AccountId).BillingStreet = con.MailingStreet;
          doUpdate = true;
        }
        if(con.MailingCity!=null&&(con.MailingCity!=contactOldMap.get(con.Id).MailingCity)){
          mapAccount.get(con.AccountId).BillingCity = con.MailingCity;
          doUpdate = true;
        }
        if(con.MailingCountry!=null&&(con.MailingCountry!=contactOldMap.get(con.Id).MailingCountry)){
          mapAccount.get(con.AccountId).BillingCountry = con.MailingCountry;
          doUpdate = true;
        }
        if(con.MailingState!=null&&(con.MailingState!=contactOldMap.get(con.Id).MailingState)){
          mapAccount.get(con.AccountId).BillingState = con.MailingState;
          doUpdate = true;
        }
        if(con.Mailing_Non_US_State__c!=null&&(con.Mailing_Non_US_State__c!=contactOldMap.get(con.Id).Mailing_Non_US_State__c)){
          mapAccount.get(con.AccountId).Billing_Non_US_State__c = con.Mailing_Non_US_State__c;
          doUpdate = true;
        }
        if(con.MailingPostalCode!=null&&(con.MailingPostalCode!=contactOldMap.get(con.Id).MailingPostalCode)){
          mapAccount.get(con.AccountId).BillingPostalCode = con.MailingPostalCode;
          doUpdate = true;
        }
        
      }

        }
    if(doUpdate==true){
          update mapAccount.values();
    }
    }
  
  public void updateCBLOpps(list<Contact> selectedContact,map<ID,Contact> contactOldMap){ 
    System.debug('In updateCBLOpps');
    set<Id> setCBLRecordTypes = Utility.getRecordTypeFromCBLCustomSetting(Opportunity.sObjectType.getDescribe());
    list<Opportunity> oppsToUpdate = new list<Opportunity>();
    // get all selected opps
    list<Opportunity> oppList = new list<Opportunity>([SELECT ID,CBL_Student_Id__c,Student_First_Name__c, Student_Last_Name__c, Email__c, Student_Primary_Email__c, Student_Institution_Email__c,Contact__c
                                                       FROM Opportunity WHERE Contact__c in: selectedContact
                                                       AND RecordTypeId IN :setCBLRecordTypes]);
    if(oppList==null||oppList.isEmpty()){
      return;
    }
    
    // sort list into map
    map<Id,list<Opportunity>> mapContactId_oppList = new map<Id,list<Opportunity>>();
    for(Opportunity opp: oppList){
      list<Opportunity> oppsToMap = new list<Opportunity>();
      if(mapContactId_oppList.containsKey(opp.Contact__c)){
        oppsToMap = mapContactId_oppList.get(opp.Contact__c);
      }
      oppsToMap.add(opp);
      mapContactId_oppList.put(opp.Contact__c,oppsToMap);
    }
    
    // perform updates
    for(Contact con : selectedContact){
      // upon new
      if(contactOldMap==null){
        for(Opportunity opp : mapContactId_oppList.get(con.Id)){
          opp.CBL_Student_Id__c = con.CBL_Student_Id__c;
          opp.Student_Primary_Email__c = con.Email;
          opp.Student_Institution_Email__c = con.Walden_Email__c;
          oppsToUpdate.add(opp);
        }

      // during update if changed
      } else {
        Boolean isChangedStudentId = false;
        Boolean isChangedEmail= false;
        Boolean isChangedWaldenEmail = false;
        if(con.CBL_Student_ID__c!=null&&(con.CBL_Student_ID__c!=contactOldMap.get(con.Id).CBL_Student_ID__c)){
          isChangedStudentId = true;
        }
        if(con.Email!=null&&(con.Email!=contactOldMap.get(con.Id).Email)){
          isChangedEmail = true;
        }
        if(con.Walden_Email__c!=null&&(con.Walden_Email__c!=contactOldMap.get(con.Id).Walden_Email__c)){
          isChangedWaldenEmail = true;
        }

        if(mapContactId_oppList.containsKey(con.Id)){
          for(Opportunity opp : mapContactId_oppList.get(con.Id)){          
            opp.CBL_Student_Id__c = con.CBL_Student_Id__c;
            opp.Student_Primary_Email__c = con.Email;
            opp.Student_Institution_Email__c = con.Walden_Email__c;
            if(isChangedStudentId||isChangedEmail||isChangedWaldenEmail){
              oppsToUpdate.add(opp);
            }
          }
        }
      }
    }

    if(!oppsToUpdate.isEmpty()){
      update oppsToUpdate;
    }


  }

  public map<Lead,Contact> getExistingContactMap( list<Lead> incomingLeadList ){
  System.debug('in getExistingContactMap');
    map<Lead,Contact> returnMap = new map<Lead,Contact>();
    set<String> setOfIncomingEmails = new set<String>();
    set<String> setOfIncomingLastNamesWithPhones = new set<String>();

    for(Lead newLead:incomingLeadList){
      if(!String.isBlank(newLead.Email)) {
        setOfIncomingEmails.add(newLead.Email);
      }
      if(!String.isBlank(newLead.LastName) && !String.isBlank(newLead.Phone)) {
        setOfIncomingLastNamesWithPhones.add(newLead.LastName);
      }
    }

    for(Contact con:[SELECT Id,Email,FirstName,LastName,Phone,AccountId 
                      ,(Select Id, Primary_Program__c, Contact__c From Opportunities__r)
                      FROM Contact 
                      WHERE Email IN :setOfIncomingEmails 
                         OR LastName IN :setOfIncomingLastNamesWithPhones ]) {
      for(Lead newLead:incomingLeadList){
        
        if(newLead.Email.equalsIgnoreCase(con.Email)
          || (!String.isBlank(newLead.Phone) && !String.isBlank(newLead.LastName) && !String.isBlank(con.Phone)
            && ( newLead.LastName.equalsIgnoreCase(con.LastName) 
              && newLead.Phone.replaceAll('[^0-9]','').trim().equalsIgnoreCase( con.Phone.replaceAll('[^0-9]','').trim() ) ))){
          
          if(!returnMap.containsKey(newLead)){
            returnMap.put(newLead,con);
            break;
          }
        }
      }
    }

    return returnMap;

  }
    
    public void updateUserBs(List<Contact> selectedContactIds){   
        list<Brand_Profile__c> lstBps = [Select ID,LMS_ID__c, Contact__r.id   from Brand_Profile__c where Contact__c  in:selectedContactIds];
        Map<id,Decimal> mapContactWithLmsId = new  Map<id,Decimal>();
        JsonWrapper jsonGenerator = new JsonWrapper();
        for(Brand_Profile__c bp : lstBps){
            mapContactWithLmsId.put(bp.Contact__r.id, bp.LMS_ID__c);
        }
        
        for(Contact con: selectedContactIds){
            if(mapContactWithLmsId.get(con.Id) != null ){
            String json = jsonGenerator.updateUser(con.CBL_Student_Id__c,con.FirstName, con.LastName,  String.valueOf(con.Walden_Email__c ));
            BrightSpaceCalls.updateUser(json,   String.valueOf( mapContactWithLmsId.get(con.Id) ), con.id);
            }
        }
        
        
    }
    
    
}