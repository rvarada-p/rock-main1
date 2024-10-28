/*******************************************************************
Name  : StudentSubscriptionTriggerHandler
Author: Tom (Appirio)
Date  : September 30, 2014
Description: Handler class for the Trigger StudentSubscriptionTrigger

* Revision History
* Horacio Sanchez	-	Aug 12, 2021	-	User Story 58882: L2: Trigger Automatic Email invoice when Student Subscription is Manually created
*************************************************************************/
public with sharing class StudentSubscriptionTriggerHandler {
    private set<ID> setCBLRecordTypes;
  	private boolean isExecuting = false;
  	private integer batchSize = 0;
    
  	public StudentSubscriptionTriggerHandler( boolean isExecuting, integer size ) {
    	isExecuting = isExecuting;
    	batchSize = size;
    	setCBLRecordTypes = Utility.getRecordTypeFromCBLCustomSetting(Student_Subscription__c.sObjectType.getDescribe());
  	}

  	public void onBeforeInsert( list<Student_Subscription__c > newStudentSubscriptions ) {
    	List<Student_Subscription__c > selectedStudentSubscriptions = new list<Student_Subscription__c >(); 
    	for (Student_Subscription__c sub:newStudentSubscriptions) {        
            SObjectType objTypeForInstitution = Schema.getGlobalDescribe().get('Student_Subscription__c');
            if (sub.Program_Institution__c != null && objTypeForInstitution.getDescribe().getRecordTypeinfosByName().containsKey(sub.Program_Institution__c)){
                sub.RecordTypeId = objTypeForInstitution.getDescribe().getRecordTypeinfosByName().get( sub.Program_Institution__c ).getRecordTypeId();
            }
    
            if (setCBLRecordTypes.contains(sub.recordtypeid)){
                selectedStudentSubscriptions.add(sub);
            }
    	}
        
    	StudentSubscriptionHelper stuSubHelper = new StudentSubscriptionHelper();
    	if (!selectedStudentSubscriptions.isEmpty()) {
            stuSubHelper.populateSubscriptionBaseCostAndEndDate( selectedStudentSubscriptions, true );
            stuSubHelper.enforceSingleSubscriptionPerPeriodPerStudentProgram( selectedStudentSubscriptions );
            //stuSubHelper.calculateTotalSubscriptionDiscount( selectedStudentSubscriptions );
            // ensure the start date is on the first monday or not
          	stuSubHelper.verifyStartDateAsFirstMondayOfTheGivenMonth( selectedStudentSubscriptions );
    	}
	}

  	public void onAfterInsert(List<Student_Subscription__c > newStudentSubscriptions) {
      
      	system.debug('onAfterInsert size of newStudentSubscriptions ' + newStudentSubscriptions.size());
      
      	StudentSubscriptionHelper stuSubHelper = new StudentSubscriptionHelper();
      
      	Set<Id> setStudentProgramIDs = new Set<Id>();
      	Set<Id> manuallyCreatedSubsIdSet = new Set<Id>();
      
      	for (Student_Subscription__c sub:newStudentSubscriptions) {
          	setStudentProgramIDs.add(sub.Student_Program__c);
          	if (sub.Is_Created_Manually__c) {
            	manuallyCreatedSubsIdSet.add(sub.Id);
          	}
      	}
      
      	if (!newStudentSubscriptions.isEmpty()) {
          	stuSubHelper.insertStudentSubscriptionExemptions(newStudentSubscriptions, setStudentProgramIDs);
      	}
      
      	//S-58882: L2: Trigger Automatic Email invoice when Student Subscription is Manually created
      	if (!manuallyCreatedSubsIdSet.isEmpty()) {
        	stuSubHelper.handleManuallyCreatedSubs(manuallyCreatedSubsIdSet);
      	}
              /*
        if(!newStudentSubscriptions.isEmpty()){
        stuSubHelper.insertSubscriptionDiscountLineItems( newStudentSubscriptions );
        }
        */
  	}
    
  	public void onBeforeUpdate( list<Student_Subscription__c > newStudentSubscriptions, map<ID,Student_Subscription__c> oldMap) {
    	list<Student_Subscription__c > selectedStudentSubscriptions = new list<Student_Subscription__c >(); 
    	list<Student_Subscription__c > selectedStudentSubscriptionsForDateValidation = new list<Student_Subscription__c >(); 
    	for (Student_Subscription__c sub:newStudentSubscriptions){
       	    if (setCBLRecordTypes.contains(sub.recordtypeid)) {
            	selectedStudentSubscriptions.add(sub);
            	if(sub.Start_Date__c != oldMap.get(sub.ID).Start_Date__c){
                	selectedStudentSubscriptionsForDateValidation.add(sub);
            	}
        	}
    	}
    	StudentSubscriptionHelper stuSubHelper = new StudentSubscriptionHelper();
    	if(!selectedStudentSubscriptionsForDateValidation.isEmpty()){
        	stuSubHelper.verifyStartDateAsFirstMondayOfTheGivenMonth(selectedStudentSubscriptionsForDateValidation);
    	}
    	if(!selectedStudentSubscriptions.isEmpty()){
        	stuSubHelper.enforceSingleSubscriptionPerPeriodPerStudentProgram( selectedStudentSubscriptions );
      		stuSubHelper.populateSubscriptionBaseCostAndEndDate( selectedStudentSubscriptions, false );
    	}
  	}
  
  	public void onAfterUpdate(List<Student_Subscription__c> newStudentSubscriptions, List<Student_Subscription__c > oldStudentSubscriptions, Map<ID,Student_Subscription__c> newMap, Map<ID,Student_Subscription__c> oldMap) {
    	list<Student_Program__c> updatePaymentPlan = new List<Student_Program__c>();
    	List<Student_Subscription__c> studentSubs = new List<Student_Subscription__c>();
    	List<Id> studentProgs = new List<Id>(); 
    	StudentProgramHelper stuProgHelper = new StudentProgramHelper();
    	Map<Id, Date> stuProgLastMetDate = new Map<Id, Date>();
		List<Id> stuSubsEngagementUpdatedPlan = new List<Id>();
		set<id> spIdPaymentPlanSet = new Set<id>();
    	StudentSubscriptionHelper stuSubHelper = new StudentSubscriptionHelper();
    	List<Student_Subscription__c> stuSubsWithDPWDEffectiveDate = new List<Student_Subscription__c>();
    
    	for(Student_Subscription__c newStudentSubs: newStudentSubscriptions) {
        
        	//Update Payment Plan Picklist on SP
        	if(newStudentSubs.Subscription_Status__c == 'RE = Registered' || oldMap.get(newStudentSubs.id).Subscription_Status__c == 'RE = Registered') {
               spIdPaymentPlanSet.add(newStudentSubs.Student_Program__c);
           	}
        
        	if(newStudentSubs.Last_Date_Met_With_Coach__c != null 
         	   && newMap.get(newStudentSubs.id).Last_Date_Met_With_Coach__c != oldMap.get(newStudentSubs.id).Last_Date_Met_With_Coach__c) {
        		//Last_Date_Met_With_Coach__c is updated to a not null value.
        		studentSubs.add(newStudentSubs);
      		}
      
      		if(newStudentSubs.Agreed_To_Credits__c != oldMap.get(newStudentSubs.Id).Agreed_To_Credits__c) {
        		if(newStudentSubs.Student_Program__c != null) {
          			stuSubsEngagementUpdatedPlan.add(newStudentSubs.Student_Program__c);      
        		}
      		} 
        	if (newStudentSubs.Subscription_DP_WD_Effective_Date__c != null && 
            	oldMap.get(newStudentSubs.id).Subscription_DP_WD_Effective_Date__c != newMap.get(newStudentSubs.id).Subscription_DP_WD_Effective_Date__c &&
            	oldMap.get(newStudentSubs.id).Date_Subscription_Status_Changed__c == newMap.get(newStudentSubs.id).Date_Subscription_Status_Changed__c
           		) {
            		stuSubsWithDPWDEffectiveDate.add(newStudentSubs);
        	}
    	}
                                 
    	if (!stuSubsWithDPWDEffectiveDate.isEmpty()) {
        	stuSubHelper.upsertStudentTransactionFromWithdrawDate(stuSubsWithDPWDEffectiveDate);                     
    	}
    
    	for(Student_Subscription__c stSubs : studentSubs) {
      		if(stSubs.Student_Program__c != null) {
        		studentProgs.add(stSubs.Student_Program__c);
        		stuProgLastMetDate.put(stSubs.Student_Program__c, stSubs.Last_Date_Met_With_Coach__c);
      		}    
    	}
    
                                 
    	//Update Payment Plan Picklist on SP
    	if(!spIdPaymentPlanSet.isEmpty()) {
        	updatePaymentPlan = [SELECT id,Name, Open_C2_Hold__c,Payment_Plan__c FROM Student_Program__c WHERE Id In:spIdPaymentPlanSet];
        	system.debug('------updatePaymentPlan'+updatePaymentPlan);
        	StudentProgramHelper.UpdatePaymentPlan(updatePaymentPlan,False);
 		}
                                 
    	if(studentProgs != null && studentProgs.size() > 0) {
      		stuProgHelper.logStudentEngagementByType(studentProgs, 'Met with Faculty Coach', stuProgLastMetDate);
    	}
                                 
    	if(stuSubsEngagementUpdatedPlan != null && stuSubsEngagementUpdatedPlan.size() > 0) {
      		stuProgHelper.logStudentEngagementByType(stuSubsEngagementUpdatedPlan, 'Submitted or Updated Plan', null);                                 
    	}
  	}

}