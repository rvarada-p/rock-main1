/*******************************************************************
Name  : AccountTriggerHandler
Author: Tom (Appirio)
Date  : March 20, 2015
Description: Handler class for the Trigger AccountTrigger
*************************************************************************/
public with sharing class AccountTriggerHandler {

  public void onAfterUpdate(list<Account> updatedAccounts, map<ID,Account> oldMap){
    ID customPersonAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Custom Person Account').getRecordTypeId();
    list<Account> customPersonAccountList = new list<Account>();
    AccountCustomPersonHelper objHelper = new AccountCustomPersonHelper();
    for(Account acct: updatedAccounts){
      if(acct.RecordTypeId == customPersonAccountRecordTypeId){
        customPersonAccountList.add(acct);
      }
    }
    if(!customPersonAccountList.isEmpty()){
      objHelper.updateCustomPersonContact(updatedAccounts,oldMap);
    }
  }

}