/*******************************************************************
Name  : OpportunityTriggerHandler
Author: Tom, Vinod (Appirio)
Date  : September 30, 2014
Description: Handler class for the Trigger OpportunityTrigger. It should simply delegate based on business.
Keep any business logic (CBL) in helper classes/methods, not in this handler.
* Sufia             - June 28, 2021 - User Story S-685520
*************************************************************************/
public with sharing class OpportunityTriggerHandler {
  private set<ID> setCBLRecordTypes;
  private boolean isExecuting = false;
  private integer batchSize = 0;
  public static  boolean firstRun = true;

  public OpportunityTriggerHandler(boolean isExecuting, integer size){
    isExecuting = isExecuting;
    batchSize = size;
    setCBLRecordTypes = Utility.getRecordTypeFromCBLCustomSetting(Opportunity.sObjectType.getDescribe());
  }

  public void beforeInsert(list<Opportunity> newOpportunity){

    for(Opportunity opty: newOpportunity){  
      System.debug('Preferred Start Date: ' + opty.Program_Start_Date__c);
      // Set Institution based RecordType
      if(opty.Primary_Program__c!=null){
        SObjectType objTypeForInstitution = Schema.getGlobalDescribe().get('Opportunity');
        opty.RecordTypeId = objTypeForInstitution.getDescribe().getRecordTypeinfosByName().get( opty.Institution__c ).getRecordTypeId();
      }
    }

    // Find CBL (Walden) records
    list<Opportunity> selectedCBL_Opportunities = new list<Opportunity>(); 
    for(Opportunity opty: newOpportunity){
      if(setCBLRecordTypes.contains(opty.RecordTypeId)){
        selectedCBL_Opportunities.add(opty);
        // default CloseDate to a year out from creation
        if(opty.CloseDate != null){ 
          opty.CloseDate = Date.today().addDays(365);
        }
      }         
    }

    // Process CBL (Walden) records: populate list price, assign EA
    StudentSuiteFactory objSfactory = new StudentSuiteFactory();
    if(!selectedCBL_Opportunities.isEmpty()){
      objSfactory.populateListPriceOnOpp(selectedCBL_Opportunities); 
      //OpportunityHelper.cblEAAssignment(selectedCBL_Opportunities);
    }

  }

  public void afterInsert(list<Opportunity> newOpportunity){
    // Find CBL (Walden) records
    list<Opportunity> selectedCBL_Opportunities = new list<Opportunity>();
    for(Opportunity opty: newOpportunity){
      if(setCBLRecordTypes.contains(opty.RecordTypeId)){
        selectedCBL_Opportunities.add(opty);
      }                       
    }
    
    // Process CBL (Walden) records  
    if(!selectedCBL_Opportunities.isEmpty()) {
      OpportunityHelper.createStudentApplicationRequirements(selectedCBL_Opportunities);
      OpportunityHelper.runroundrobin(selectedCBL_Opportunities);
    }
    
  }

  public void afterUpdate(list<Opportunity> newOpportunity, map<ID,Opportunity> oldMap){
      System.debug('In afterUpdate Opportunity');  
      // Find CBL (Walden) records
      list<Opportunity> selectedCBL_Opportunities = new list<Opportunity>();
      list<Opportunity> oppsNeedingBPs = new list<Opportunity>();
      list<Opportunity> oppsToReconcileforCOSBeforeAdmitted = new list<Opportunity>();
      list<Opportunity> oppsToUpdateCBLId = new list<Opportunity>();
      list<Opportunity> oppsToUpdateBECourseFulfilled = new list<Opportunity>();//Business Essentials Update to Fulfilled
      
      for(Opportunity opty: newOpportunity){
        Opportunity oldOpty = oldMap.get(opty.ID);
        if(setCBLRecordTypes.contains(opty.RecordTypeId)){
          selectedCBL_Opportunities.add(opty);
        }
        if(opty.Brand_Profile__c == null) {
          oppsNeedingBPs.add(opty);
        }
     
        /*
        if(opty.StageName == 'Student' && oldOpty.StageName != 'Student') {
            oppsToUpdateCBLId.add(opty);
        }
        */
        //Populate the list of Opportunities that have to reconciled for COS once the Opp stage goes to Admitted
        if(opty.Change_of_Specialization__c && (opty.StageName == 'Admitted' && oldOpty.StageName!='Admitted')) {
          oppsToReconcileforCOSBeforeAdmitted.add(opty);
         }
         /*
         //S-685520 :- Deprecating as per story
         //Create SE & SC  related to Business Essentials Course When Status is Student and Business_Essentials__c is marked as True.
         if(opty.StageName == 'Student' && oldOpty.StageName == 'Admitted' && opty.Business_Essentials__c == True){
         	oppsToUpdateBECourseFulfilled.add(opty);
         } */       
      }
      
      /*
      //S-685520 :- Deprecating as per story
      if(!oppsToUpdateBECourseFulfilled.isEmpty()){
      	OpportunityHelper.updateBEToFulfilled(newOpportunity);
      	
      } */

      if(!oppsNeedingBPs.isEmpty()) {
        OpportunityHelper.checkAndAssociateExistingBP(selectedCBL_Opportunities);
      }

      // Process CBL (Walden) records
      if(!selectedCBL_Opportunities.isEmpty()) {
        OpportunityHelper oppHelper = new OpportunityHelper();
        oppHelper.updatesUponOpportunityAdmitOrWin(selectedCBL_Opportunities, oldMap);
        oppHelper.updateStudentProgramStartDate(selectedCBL_Opportunities, oldMap);  
        OpportunityHelper.runroundrobin(selectedCBL_Opportunities);
      } 
      
        if(!oppsToReconcileforCOSBeforeAdmitted.isEmpty()) {
          ProgramReconciliation reconciliation = new ProgramReconciliation();
          reconciliation.reconcileCOSBeforeAdmitted(oppsToReconcileforCOSBeforeAdmitted, oldMap);
        }
        /*
        if(!oppsToUpdateCBLId.isEmpty()) {
            OpportunityHelper.updateOppsWithCBLwithContactFields(oppsToUpdateCBLId, oldMap);
        }
        */
      //oppsToUpdateCBLId

  }

  public void beforeUpdate(list<Opportunity> newOpportunity,map<ID,Opportunity> oldMap){


    if(OpportunityTriggerHandler.firstRun) {
       OpportunityTriggerHandler.firstRun = false;
      System.debug('In beforeUpdate Opportunit');
      // Find CBL (Walden) records 
      list<Opportunity> selectedCBL_Opportunities = new list<Opportunity>();
      list<Opportunity> admittedOps = new list<Opportunity>();

      for(Opportunity opty: newOpportunity){
        if(setCBLRecordTypes.contains(opty.RecordTypeId)){
          selectedCBL_Opportunities.add(opty);
        }
      }

      // Process CBL (Walden) records  
      if(!selectedCBL_Opportunities.isEmpty()){         
        StudentSuiteFactory objSfactory = new StudentSuiteFactory();
        System.debug('Selected Opportunities: ' + selectedCBL_Opportunities);
        OpportunityHelper.updateOppsWithCBLwithContactFields(selectedCBL_Opportunities, oldMap);
        //StudentSuiteFactory objSfactory = new StudentSuiteFactory();
        
        list<Opportunity> priceCBL_OppList = new list<Opportunity>();
       
        for(Opportunity opty: selectedCBL_Opportunities){
          Opportunity oldOpty = oldMap.get(opty.ID);
            system.debug('&&&&&&&&&Primary_Program__c@@@@@@'+opty.Primary_Program__c);
            system.debug('&&&&&&&&& opty.Initial_Price_Book__c @@@@@@'+ opty.Initial_Price_Book__c );
            system.debug('&&&&&&&&&OLD PP@@@@@@'+oldOpty.Primary_Program__c);
            system.debug('&&&&&&&&&OLD PB@@@@@@'+oldOpty.Initial_Price_Book__c);

          if( opty.Primary_Program__c != null && opty.Initial_Price_Book__c != null
            && (opty.Primary_Program__c != oldOpty.Primary_Program__c || opty.Initial_Price_Book__c != oldOpty.Initial_Price_Book__c)){
               priceCBL_OppList.add(opty);
          }
            system.debug('&&&&&&&&& Stage Name @@@@@@'+opty.StageName);
            system.debug('&&&&&&&&& OLD Stage Name @@@@@@'+oldOpty.StageName);
          if( opty.StageName == 'Student' && oldOpty.StageName != 'Student' ){
            opty.Date_Enrolled__c = system.today();
          }
         
        }

        if(!priceCBL_OppList.isEmpty()){
          OpportunityHelper.markOppForCOSBeforeAdmitted(priceCBL_OppList);
          OpportunityHelper.updateProgramOnBrandProfile(priceCBL_OppList);
          objSfactory.populateListPriceOnOpp(priceCBL_OppList);
          OpportunityHelper.calculateAmountAfterDiscount(priceCBL_OppList);

        }

      }
    }
  }

}