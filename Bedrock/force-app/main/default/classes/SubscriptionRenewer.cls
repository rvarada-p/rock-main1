/************************************************************************
Name  : SubscriptionRenewer
Author: Originally "BatchSubscriptionRenewedHelper" by Vinod (Appirio)
Date  : October 14, 2014
Author: Refactored by Tom (Appirio)
Date  : May 27, 2014
Date: July 1 2016
Change: Added in Subscription Renewed date
Description: worker class for batch class BatchSubscriptionRenewed
Test class: SubscriptionRenewer_Test
*************************************************************************/
public with sharing class SubscriptionRenewer {
  public  integer totalNumberOfSuccess;
  public  integer totalNumberOfFailure;
  public  integer totalUpdated;
  public SubscriptionRenewer(){
  } 
  public void subscriptionRenew(list<Student_Program__c> lstStudentProgram){
    totalNumberOfSuccess = 0;
    totalNumberOfFailure = 0;
    totalUpdated = 0;
    list<Student_Program__c> lstStudentProgramForUpdate = new list<Student_Program__c>();
    list<Student_Program__c> lstStudentProgramForApexLoger = new list<Student_Program__c>();
    list<Student_Subscription__c> lstStudentSubscription = new list<Student_Subscription__c>(); 
    map<ID,ID> mapStudentProgramNewStudentSubscriptionID = new map<ID,ID>();
    apexLogHandler.apexLog log;
        
    try{
      // get next  Student Subscription for the selected student program
      //(meaning where Student Subscription.Start_Date__c equals TODAY())
      Date toDay = Date.today();
      set<ID> setProgramId = new set<ID>();
      set<ID> setCurrentSubScriptionId = new set<ID>();
      for(Student_Program__c sProg:lstStudentProgram){
        if(sProg.Program__c != null){
          setProgramId.add(sProg.Program__c);
        } 
        if(sProg.Current_Student_Subscription__c != null){
          setCurrentSubScriptionId.add(sProg.Current_Student_Subscription__c);
        }
      }
      map<ID,Student_Subscription__c> mapStudentProgramWithNextStudentSubscription = new map<ID,Student_Subscription__c>();
      for(Student_Subscription__c stuSub:[Select ID,Start_Date__c,Student_Program__c,End_Date__c
                                          from Student_Subscription__c 
                                          where Student_Program__c in: lstStudentProgram
                                          and Start_Date__c =:toDay ]){//and id not in: setCurrentSubScriptionId]){
        mapStudentProgramWithNextStudentSubscription.put(stuSub.Student_Program__c,stuSub);
      }

      // exclude any SPs with upcoming LOA and mark inactive and blank out the 'Current Sub'
      set<ID> setStudentProgram_onLOA = new set<ID>();
      for(Student_Program__c sProgram:lstStudentProgram){
        if(  mapStudentProgramWithNextStudentSubscription.containsKey(sProgram.Id)
          && sProgram.Leave_of_Absence_LOA_To__c != null ){
          Student_Subscription__c stuSub = mapStudentProgramWithNextStudentSubscription.get(sProgram.Id);
          if( ( sProgram.Leave_of_Absence_LOA_To__c <= stuSub.End_Date__c
            && sProgram.Leave_of_Absence_LOA_To__c >= stuSub.Start_Date__c ) || (sProgram.Leave_of_Absence_LOA_To__c >=stuSub.End_Date__c)){
            
            sProgram.IsStudentProgramActive__c = false;
            sProgram.Current_Student_Subscription__c = null;
            sProgram.Subscription_Renewal_Date__c = null;
            lstStudentProgramForUpdate.add(sProgram);
            totalUpdated++;
            
            mapStudentProgramWithNextStudentSubscription.remove(sProgram.Id);
            setStudentProgram_onLOA.add(sProgram.Id);
          }
        }
      }

      // get most recent price book entery for the Student_Program__c.Program__c
      // get the price book entery
      map<ID,PricebookEntry> mapProgramWithMostRecentPricebookEntry = new map<ID,PricebookEntry>();
      for(PricebookEntry pEntery :[Select Product2Id, Pricebook2Id, Id, Available_for_Existing_Students__c 
                                    From PricebookEntry
                                    where Available_for_Existing_Students__c = true
                                    and Product2Id in: setProgramId
                                    order by LastModifiedDate desc]){
        if(!mapProgramWithMostRecentPricebookEntry.containsKey(pEntery.Product2Id)){
          // add only most recent pricebook entery
          mapProgramWithMostRecentPricebookEntry.put(pEntery.Product2Id,pEntery);
        }
      }
       //date stroe TODAY()-1 
       Date dtLastDaydate = toDay.addDays(-1);
       for(Student_Program__c sProgram: lstStudentProgram){   
        if(  sProgram.Current_Student_Subscription__c != null 
          && sProgram.Current_Student_Subscription__r.Subscription_Status__c == 'RE = Registered'
          && !setStudentProgram_onLOA.contains(sProgram.Id) ){         
        // find then next Student Subscription (meaning where Student Subscription.Start_Date__c equals TODAY()) 
          if(mapStudentProgramWithNextStudentSubscription.containsKey(sProgram.ID)){
            sProgram.Current_Student_Subscription__c = mapStudentProgramWithNextStudentSubscription.get(sProgram.ID).ID;
            sProgram.Subscription_Renewal_Date__c = system.today();
            lstStudentProgramForUpdate.add(sProgram);
            totalUpdated++;
          }else if(sProgram.Current_Student_Subscription__r.End_Date__c == dtLastDaydate){
            
            // This would only occur if the BatchAutoSubscriptionCreation failed to create a new Sub record
            // or the student's current Sub status was not 'RE'
            
            // next student subscription not found and Student Program.Current Student Subscription__r.End_Date__c ==  TODAY()-1         
            // first check the Term_Price_Book__c
            if(mapProgramWithMostRecentPricebookEntry.containsKey(sProgram.Program__c)){
              // create new student subscription
              Student_Subscription__c newStuSub = new Student_Subscription__c();
              newStuSub.Start_Date__c = toDay;
              newStuSub.Student_Program__c = sProgram.ID;
              newStuSub.Term_Price_Book__c = mapProgramWithMostRecentPricebookEntry.get(sProgram.Program__c).Pricebook2Id;
              lstStudentSubscription.add(newStuSub);
              lstStudentProgramForUpdate.add(sProgram);
            }else{
              // write apex logger
              lstStudentProgramForApexLoger.add(sProgram);        
            }
          }
        } else if(sProgram.Current_Student_Subscription__c == null && !setStudentProgram_onLOA.contains(sProgram.Id) ){
        // No Current Subscription, so enable the new one starting today        
          if(mapStudentProgramWithNextStudentSubscription.containsKey(sProgram.ID)){
            sProgram.Current_Student_Subscription__c = mapStudentProgramWithNextStudentSubscription.get(sProgram.ID).ID;
            sProgram.Subscription_Renewal_Date__c = System.today();
            lstStudentProgramForUpdate.add(sProgram);
            totalUpdated++;
          } 
        }
      }
       // insert new Student_Subscription__c
      if(!lstStudentSubscription.isEmpty()){
        Database.Saveresult[] saveResult = Database.insert(lstStudentSubscription,false);
        // Iterate through each returned result
        integer index = 0;
        for (Database.SaveResult sr : saveResult) {
          if (sr.isSuccess()) {
            // get newly create student sub to populate studentprogram
            Student_Subscription__c stuSub = lstStudentSubscription[index];
            mapStudentProgramNewStudentSubscriptionID.put(stuSub.Student_Program__c,stuSub.id);
            totalNumberOfSuccess++;
          }
          else {
            // Operation failed, so get all errors                
            totalNumberOfFailure++;
          }
          index++;
        }
      }
      // update the student program
      if(!lstStudentProgramForUpdate.isEmpty()){ 
        // check if a new Student_Subscription__c is created for the student program then 
        // populate Student_Program__c.Current_Student_Subscription__c with newly created Student_Subscription__c
        for(Student_Program__c sProg: lstStudentProgramForUpdate){
          
          // take care of any newly created subs from this batch process and set appropreate fields
          if(mapStudentProgramNewStudentSubscriptionID.containsKey(sProg.ID)){
            sProg.Current_Student_Subscription__c = mapStudentProgramNewStudentSubscriptionID.get(sProg.ID);
            sProg.Subscription_Renewal_Date__c = system.today();
          } 
          // continue to enable valid Student Programs
          if(!setStudentProgram_onLOA.contains(sProg.Id)){
            sProg.IsStudentProgramActive__c = true;
          }
        }

        Database.Saveresult[] saveResult = Database.update(lstStudentProgramForUpdate,false);
        for (Database.SaveResult sr : saveResult) {
          if (!sr.isSuccess()) {
            // log error message
            string strMessage = '';
             for(Database.Error err : sr.getErrors()) {
                strMessage+=  err.getMessage(); 
            }
            log = new apexLogHandler.apexLog('BatchSubscriptionRenewed','subscriptionRenew', strMessage);
          }           
        }
      }
      // create apex loger
      for(Student_Program__c sProg: lstStudentProgramForApexLoger){
        string strMessage = 'The Auto-Renewed process was missed for Student Program: ' + sProg.Name;
        strMessage +='. However it was determined that a new Subscription record should still be generated and it has. Please review the Student Program and take any corrective steps if necessary.';
        log = new apexLogHandler.apexLog('BatchSubscriptionRenewed','subscriptionRenew', strMessage); 
      }
      totalNumberOfSuccess = totalNumberOfSuccess+totalUpdated;
      
    }
    catch(exception ex){
      system.debug('Exception::::::::::::::::::::'+ ex.getMessage());
      log = new apexLogHandler.apexLog('BatchSubscriptionRenewedHelper','subscriptionRenew', ex.getMessage());
    }
    finally{
      if(log != null){ 
        log.saveLogs();
      }
    }
  }
    /*******************************************************************
    Method to automate Financial Hold application logic 
    Related story: S-22943 Sprint 2020.4.3 
    Created By: Horacio Sanchez
    ********************************************************************/
    public void auotmateFinancialHoldLogic(Set<Id> spIdSet) {
        List<Student_Program__c> studentProgramList = new List<Student_Program__c>();
        for (Id spId : spIdSet) {
            Student_Program__c sp = new Student_Program__c();
            sp.Id = spId;
            sp.Student_Enrollment_Status__c = 'Financial Hold (FH)';
            sp.Student_Enrollment_Status_Code__c = 'FH';
            sp.IsStudentProgramActive__c = false;
            sp.Enrollment_DP_WD_Effective_Date__c = Date.today();
            sp.Enrollment_DP_WD_Processed__c = Date.today();
            studentProgramList.add(sp);
        }
        
        if (!studentProgramList.isEmpty()) {
            update studentProgramList;
        }
    }
}