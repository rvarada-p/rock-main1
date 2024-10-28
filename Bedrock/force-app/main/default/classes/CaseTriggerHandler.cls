/*******************************************************************
Name  : CaseTriggerHandler
Author: Vinay (Appirio)
Date  : May 4, 2015
Description: Handler class for the Trigger CaseTrigger. It should simply delegate based on business.
Keep any business logic (CBL) in helper classes/methods, not in this handler.
*************************************************************************/

public with sharing class CaseTriggerHandler {

  private set<ID> setCBLRecordTypes;
  
  public CaseTriggerHandler() {
    setCBLRecordTypes = Utility.getRecordTypeFromCBLCustomSetting(Opportunity.sObjectType.getDescribe()); 
  }
  
  public void beforeInsert(list<Case> newCaseList) {
    
    CaseHelper.fetchRecordType(newCaseList);
  }  
}