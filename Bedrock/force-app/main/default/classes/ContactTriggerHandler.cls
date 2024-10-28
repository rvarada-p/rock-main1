/*******************************************************************
Name  : ContactTriggerHandler
Author: Vinod (Appirio)
Date  : December 09, 2014
Description: Handler class for the Trigger ContactTrigger
// Sufia  -07/20/2021 : - S-685961 : call to invoice processor to send emails
*************************************************************************/
public with sharing class ContactTriggerHandler {

  private boolean isExecuting = false;
  
  public ContactTriggerHandler(){
  }    
    /*******************************************************
    Before Update trigger method
    Related task: T-339567
    Created date:December 10, 2014
    *******************************************************/
    public void onBeforeUpdate(list<Contact > newContact){
        // code related to task T-339567
        ContactHelper objHelper = new ContactHelper();
    
         //objHelper.validateContactOnEdit(newContact); 
    }
    /*******************************************************
    After insert trigger method
    Related task: T-338463
    Created date:December 15, 2014
    *******************************************************/
    public void onAfterInsert(list<Contact> newContact){
        // code related to task T-338628
        list<Contact> customPersonAccountContactList = new list<Contact>();
        set<ID> accountIds = new set<ID>();
        ContactHelper objHelper = new ContactHelper();
        ID cCustomPersonAccountContactId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Custom Person Account Contact').getRecordTypeId();
        for(Contact con: newContact){
            if(con.RecordTypeId == cCustomPersonAccountContactId && con.AccountId != null){
                customPersonAccountContactList.add(con);
                accountIds.add(con.AccountId);
            }
        }
        if(!customPersonAccountContactList.isEmpty()){
            // populate the CBL Student Id on the selected Contact's Account
            // T-338628 
            objHelper.updateCustomPersonAccount(customPersonAccountContactList,accountIds,null);
            objHelper.updateCBLOpps(customPersonAccountContactList,null);
        }
    }
    /*******************************************************
    After update trigger method
    Related task: T-338463
    Created date:December 15, 2014
    *******************************************************/
    public void onAfterUpdate(list<Contact > newContact, map<ID,Contact> oldMap){
        System.debug('In onAfterUpdate');
        // code related to task T-338628
        list<Contact> customPersonAccountContactList = new list<Contact>();
        list<Contact> updateUserBs = new list<Contact>();
        set<ID> accountIds = new set<ID>();
        ContactHelper objHelper = new ContactHelper();
        ID cCustomPersonAccountContactId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Custom Person Account Contact').getRecordTypeId();
        for(Contact con: newContact){
            if(con.RecordTypeId == cCustomPersonAccountContactId && con.AccountId != null){
                customPersonAccountContactList.add(con);
                accountIds.add(con.AccountId);
            }
            if(con.Walden_Email__c != oldMap.get(con.id).Walden_Email__c && String.isNotBlank(con.Walden_Email__c)) {
                updateUserBs.add(con);
            }
        }
        if(!customPersonAccountContactList.isEmpty()){
            // populate the CBL Student Id on the selected Contact's Account
            // T-338628 
            objHelper.updateCustomPersonAccount(customPersonAccountContactList,accountIds,oldMap);
            objHelper.updateCBLOpps(customPersonAccountContactList,oldMap);
        }
        if(!updateUserBs.isEmpty()){
            objHelper.updateUserBs(updateUserBs);
        }
        
        //S-685961
        Set<Id> setProgramsToProcess = new Set<Id>();
        for(Student_Program__c program : [select Id from Student_Program__c where Student__c IN :updateUserBs]){
            setProgramsToProcess.add(program.Id);
        }
        StudentInvoiceEmailProcessor.processStuProgramsAndSendInvoice(setProgramsToProcess);  
    
    }
}