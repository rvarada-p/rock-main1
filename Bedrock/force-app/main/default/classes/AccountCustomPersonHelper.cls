/*******************************************************************
Name  : AccountCustomPersonHelper
Author: Tom (Appirio)
Date  : March 20, 2015
Description: Helper class for Custom Person Accounts
*************************************************************************/
public with sharing class AccountCustomPersonHelper {

  public void updateCustomPersonContact(list<Account> selectedAccounts, map<ID,Account> accountOldMap){ 
    // get all selected contacts
    map<ID,Contact> mapContact = new map<ID,Contact>();
    for(Contact con:[SELECT ID,AccountId,Phone,MailingStreet,Mailing_Non_US_State__c
                            ,MailingCity,MailingState,MailingPostalCode,MailingCountry
                     FROM Contact WHERE AccountId IN :selectedAccounts]){
      mapContact.put(con.AccountId,con);
    }
    Boolean doUpdate = false;
    if(!mapContact.isEmpty()){
      for(Account acct: selectedAccounts){
        if(acct.Phone!=null&&(acct.Phone!=accountOldMap.get(acct.Id).Phone)){
          mapContact.get(acct.Id).Phone = acct.Phone;
          doUpdate = true;
        }
        if(acct.BillingStreet!=null&&(acct.BillingStreet!=accountOldMap.get(acct.Id).BillingStreet)){
          mapContact.get(acct.Id).MailingStreet = acct.BillingStreet;
          doUpdate = true;
        }
        if(acct.BillingCity!=null&&(acct.BillingCity!=accountOldMap.get(acct.Id).BillingCity)){
          mapContact.get(acct.Id).MailingCity = acct.BillingCity;
          doUpdate = true;
        }
        if(acct.BillingCountry!=null&&(acct.BillingCountry!=accountOldMap.get(acct.Id).BillingCountry)){
          mapContact.get(acct.Id).MailingCountry = acct.BillingCountry;
          doUpdate = true;
        }
        if(acct.BillingState!=null&&(acct.BillingState!=accountOldMap.get(acct.Id).BillingState)){
          mapContact.get(acct.Id).MailingState = acct.BillingState;
          doUpdate = true;
        }
        if(acct.Billing_Non_US_State__c!=null&&(acct.Billing_Non_US_State__c!=accountOldMap.get(acct.Id).Billing_Non_US_State__c)){
          mapContact.get(acct.Id).Mailing_Non_US_State__c = acct.Billing_Non_US_State__c;
          doUpdate = true;
        }
        if(acct.BillingPostalCode!=null&&(acct.BillingPostalCode!=accountOldMap.get(acct.Id).BillingPostalCode)){
          mapContact.get(acct.Id).MailingPostalCode = acct.BillingPostalCode;
          doUpdate = true;
        }
      }
    }
    if(doUpdate==true){
      update mapContact.values();
    }
  }

}