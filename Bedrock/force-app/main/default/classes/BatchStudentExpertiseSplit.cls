/************************************************************************************** 
Apex Class Name     : BatchStudentExpertiseSplit 
Created Date        : 23th December 2018
Function            :  
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                  
* Ravitej Varada            12/23/2018                Original Version
*************************************************************************************/
global with sharing class BatchStudentExpertiseSplit implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
    global integer totalrecordsProcess;
    global integer totalSuccess;
    global integer totalFailure;
    
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        String SOQL;
        totalrecordsProcess = 0; 
        totalSuccess = 0;
        totalFailure = 0;
        
        SOQL = 'SELECT Area_of_Expertise_Name__c,Area_of_Expertise__c,Audit_Category__c,Clone_from_SE_ID__c,Contact__c,CreatedById,CreatedDate,External_Key__c,Fulfilled_Course_from_a_Conferred_Degree__c,'
            +' Fulfilled_Course_Name__c,Grade_Value__c,Grade__c,Id,IsAchieved__c,IsDeleted,Is_Added_from_Program_Plan__c,Is_Audit_History_Created__c,'  
            + ' Is_Pre_Req_Lock__c,Is_Removed_from_Program_Plan__c,LastActivityDate,LastModifiedById,LastModifiedDate,Learning_Order__c,Level_Type__c,Name,Non_Transferrable__c,'  
            + ' Number_of_Competencies_Completed__c,Number_of_Competencies_Transferred__c,Opportunity__c,Outcome_Category__c,'  
            + ' Outcome_Subject_Area_Expertise__c,Pre_Req_Condition_Rule__c,Program_Expertise__c,Program_Institution__c,Program_Name__c,'  
            + ' Pseudo_CE__c,Pseudo_Course__c,RecordTypeId,Student_Name__c,Student_Program__c,Subject_Area_Expertise__c,SystemModstamp,'  
            + ' Total_Applied_Earned_CE_Outcome__c,Total_CE__c'            
            + ' FROM Student_Expertise__c'  
            + ' WHERE IsAchieved__c = TRUE and Pseudo_CE__c > 5 and '
            +'  Degree_Level__c = \'Undergrad\' and Audit_Category__c = \'General Education; General Elective\' ';
            //+ ' AND Pseudo_Course__c = TRUE AND ID=\'a0O3F000002sObq\'' ;
        
        return Database.getQueryLocator(SOQL);
    } 
    
    global void execute(SchedulableContext SC) { 
        BatchStudentExpertiseSplit objBatch = new BatchStudentExpertiseSplit(); 
        ID batchprocessid = Database.executeBatch(objBatch, 10);
    }
    
    global void execute(Database.BatchableContext bc, List<Student_Expertise__c> newStudentExps) {
        List<Student_Expertise__c> seListToProcess = new  List<Student_Expertise__c> ();
        for(Student_Expertise__c se: newStudentExps){
             if(se.Pseudo_CE__c != se.Total_Applied_Earned_CE_Outcome__c){
                seListToProcess.add(se);
            }
        }
        if(!seListToProcess.isEmpty()){
           SplitStudentExpertise(seListToProcess,false,null); 
        }
        
        
    }
    
    
      public static void SplitStudentExpertise(List<Student_Expertise__c> studentExpsLst, Boolean isBeforeUpdate, Map<Id,Integer> seIdPseudoCeMap){
        
        List<Student_Expertise__c> studentExpsLstToInsert = new List<Student_Expertise__c>();
        List<Student_Expertise__c> studentExpsLstToUpdate = new List<Student_Expertise__c>();
        for(Student_Expertise__c seObj: studentExpsLst){
            
            integer seToCreateCount = 0;  
            if(isBeforeUpdate && !seIdPseudoCeMap.isEmpty() && seIdPseudoCeMap.containsKey(seObj.id) && seIdPseudoCeMap.get(seObj.id) != null){
                seToCreateCount = seIdPseudoCeMap.get(seObj.id)/5;
            }else if (!isBeforeUpdate){
                seToCreateCount =  integer.valueof(seObj.Pseudo_CE__c/5);  
            }
            system.debug('seToCreateCount'+seToCreateCount);
            
            seObj.Total_Applied_Earned_CE_Outcome__c = 0;
            studentExpsLstToUpdate.add(seObj);   
            
            for(integer i = 1; i < seToCreateCount; i++){
                Student_Expertise__c seClonedObj = new Student_Expertise__c();
                seClonedObj = seObj.clone(false,true,false,false);
                seClonedObj.Clone_from_SE_ID__c = seObj.Id;
                System.debug('seClonedObj::'+seClonedObj);
                studentExpsLstToInsert.add(seClonedObj);
            }             
        }   
        if(!isBeforeUpdate && !studentExpsLstToUpdate.isEmpty()){
            update studentExpsLstToUpdate;
        }
        if(!studentExpsLstToInsert.isEmpty()){
            insert studentExpsLstToInsert;
        }
        
        Map<Id,Set<Id>> oldSEAndClonedSEMap = new Map<Id,Set<Id>>();
        for(Student_Expertise__c seClonedObj : studentExpsLstToInsert){
            if(oldSEAndClonedSEMap.containsKey(seClonedObj.Clone_from_SE_ID__c)){
                Set<Id> idSet = new Set<Id>();
                idSet = oldSEAndClonedSEMap.get(seClonedObj.Clone_from_SE_ID__c);
                idSet.add(seClonedObj.Id);
                oldSEAndClonedSEMap.put(seClonedObj.Clone_from_SE_ID__c,idSet);
            }else{
                oldSEAndClonedSEMap.put(seClonedObj.Clone_from_SE_ID__c,new Set<Id>{seClonedObj.Id});
            }           
        }
        
        List<Student_Competency__c> scList = new List<Student_Competency__c>();
        List<Student_Competency__c> scListToInsert = new List<Student_Competency__c>();
        List<Student_Competency__c> scListToUpdate = new List<Student_Competency__c>();
        scList = [SELECT Area_Of_Expertise_Name__c,Assessment_Submitted_Date__c,Assessment_Submitted__c,Available_for_Try_Before_You_Buy__c,
                  Average_Difficulty_Level__c,Brand_Profile_ID__c,CLP_Active__c,Competency_Achieved_Mastered__c,Competency_Code__c,
                  Competency_Credit_Equivalency__c,Competency_Title__c,Competency_Type__c,Competency_Version__c,Competency__c,Completed_Date__c,Contact__c,
                  CreatedById,CreatedDate,Date_Assessment_Unlocked__c,Date_TBYB_Competency_Started__c,Description__c,Engagement_Met__c,
                  Engagement_Required__c,Engagement_Unmet__c,Enrollment_DP_WD_Date__c,External_Key__c,First_Subscription_Start_Date__c,Flat_World_Knowledge_Link__c,
                  Fulfilled_Grade__c,FWK_Id__c,Id,IsCompleted__c,IsDeleted,IsStudentProgramActive__c,Is_Enrolled__c,LastActivityDate,LastModifiedById,LastModifiedDate,
                  LastReferencedDate,LastViewedDate,Last_Date_of_SME_Enagagement__c,Learning_Order__c,Name,New_Messages__c,New_Self_Assessment__c,New_Student_Indicator__c,
                  no_of_days_since_complete_in_currentterm__c,no_of_days_since_current_sub_start_date__c,Number_of_Assessment_Attempts__c,of_Assessment_Unlocked__c,
                  Opportunity__c,Outreach_Required__c,Pause_Competency_Date__c,Pause_Competency__c,PC_FWK_ID__c,Program_Competency_Type__c,Program_Competency__c,
                  Program_Institution__c,Program__c,Pseudo_CE__c,Quiz_Completed__c,RecordTypeId,Resume_Competency_Date__c,R_C_submitted__c,
                  Self_Assessment_Submitted_Date__c,SME_Messaged_Student__c,SME__c,Start_Date__c,Status__c,Student_Assigned__c,Student_Enrolled_in_LMS_c__c,
                  Student_Enrolled_in_LMS__c,Student_Expertise_Name__c,Student_Expertise__c,Student_ID__c,Student_Name__c,Student_Program__c,
                  Student_Status__c,Student_Subscription_Achieved_In__c,Student_s_Walden_Email__c,Submission_Status__c,Survey_Message_Sent__c,
                  SystemModstamp,Target_Date__c,TBYB_Start_Competency__c,Term_End_Date__c,Transferring_Institution__c,Unlocked_Assessment__c,Unlock_Assessment__c 
                  FROM Student_Competency__c where Student_Expertise__c in :oldSEAndClonedSEMap.keyset()];
        for(Student_Competency__c scObj : scList){
            scObj.Pseudo_CE__c = 5;
            scListToUpdate.add(scObj);
            
            if(oldSEAndClonedSEMap.containsKey(scObj.Student_Expertise__c) && 
               oldSEAndClonedSEMap.get(scObj.Student_Expertise__c) != null && 
               !oldSEAndClonedSEMap.get(scObj.Student_Expertise__c).isEmpty()){
                for(Id newSeId : oldSEAndClonedSEMap.get(scObj.Student_Expertise__c)){
                    Student_Competency__c clonedScObj = new Student_Competency__c();
                    
                    clonedScObj = scObj.clone(false,true,false,false);
                    clonedScObj.Student_Expertise__c = newSeId;
                    scListToInsert.add(clonedScObj);
                }
            }
        }
        if(!scListToInsert.isEmpty()){
        	insert scListToInsert;
        }
        if(!isBeforeUpdate && !scListToUpdate.isEmpty()){
        	update scListToUpdate;
        }
    }   
    
    
    global void finish(Database.BatchableContext BC) {     
    }
}