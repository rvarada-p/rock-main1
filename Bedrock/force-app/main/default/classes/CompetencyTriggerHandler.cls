/*******************************************************************
Name  : CompetencyTriggerHandler
Author: Vinod (Appirio)
Date  : September 26, 2014
Description: Handler class for the Trigger CompetencyTrigger
*************************************************************************/
public with sharing class CompetencyTriggerHandler {
    private set<ID> setCBLRecordTypes;
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public static  boolean firstRun = true;
    
    
    public CompetencyTriggerHandler(boolean isExecuting, integer size){
        isExecuting = isExecuting;
        batchSize = size;
        setCBLRecordTypes = Utility.getRecordTypeFromCBLCustomSetting(Competency__c.sObjectType.getDescribe());
    }

    public void onBeforeUpdate(list<Competency__c > newCompetency,map<ID,Competency__c> oldMap){
        //list of all competencies to create Course Templates for in BrightSpace LMS
        list<Competency__c> lstSelectedCompetency = new list<Competency__c>();
        if(CompetencyTriggerHandler.firstRun) {
            CompetencyTriggerHandler.firstRun = false;          
            for(Competency__c comp: newCompetency){
                system.debug('publish to LMS :::::::::::'+comp.Publish_to_LMS__c);
                system.debug('oldMap.get(comp.ID).Publish_to_LMS__c:::::::::::'+oldMap.get(comp.ID).Publish_to_LMS__c);
                if(setCBLRecordTypes.contains(comp.RecordTypeId) && comp.Publish_to_LMS__c==true && comp.Publish_to_LMS__c != oldMap.get(comp.ID).Publish_to_LMS__c && comp.Competency_Shell_ID__c==null && comp.Course_Template_ID__c == null){
                    lstSelectedCompetency.add(comp);
                }
            }
            system.debug('lstSelectedCompetency:::::::::::'+lstSelectedCompetency);
            ProgramExpertiseHelper programExpertiseHelper = new ProgramExpertiseHelper();
            //Trigger to populate rogram Expertise's Total_hours_to_Complete_All_Competencies__c
            if(!lstSelectedCompetency.isEmpty()){
                System.debug('in onBeforeUpdate in trigger handler');
                programExpertiseHelper.publishCompToLMS(lstSelectedCompetency);
            }
        }
        
    }

    public void onAfterUpdate(list<Competency__c > newCompetency,map<ID,Competency__c> oldMap){
        //system.debug('lstSelectedCompetency:::::::::::'+lstLMSComps);
        ProgramExpertiseHelper programExpertiseHelper = new ProgramExpertiseHelper();

            // list used to Roll up Avg Time to Complete from Competencies to AoEs
            list<Competency__c> lstSelectedCompetency = new list<Competency__c>();
            for(Competency__c comp: newCompetency){
                system.debug('comp.Average_Time_in_hours__c:::::::::::'+comp.Average_Time_in_hours__c);
                system.debug('oldMap.get(comp.ID).Average_Time_in_hours__c:::::::::::'+oldMap.get(comp.ID).Average_Time_in_hours__c);
                if(setCBLRecordTypes.contains(comp.RecordTypeId) && comp.Average_Time_in_hours__c != oldMap.get(comp.ID).Average_Time_in_hours__c){
                    lstSelectedCompetency.add(comp);
                }
            }
            system.debug('lstSelectedCompetency:::::::::::'+lstSelectedCompetency);
            //ProgramExpertiseHelper programExpertiseHelper = new ProgramExpertiseHelper();
            //Trigger to populate rogram Expertise's Total_hours_to_Complete_All_Competencies__c
            //Related task: T-320974
            if(!lstSelectedCompetency.isEmpty()){
                programExpertiseHelper.rollUpProgramExpertiseTotalHoursToCompleteAllCompetencies(lstSelectedCompetency);
            }
        //}
    }

    public void onAfterDelete(list<Competency__c > newCompetency){
        
        ProgramExpertiseHelper programExpertiseHelper = new ProgramExpertiseHelper();
        //Trigger to populate rogram Expertise's Total_hours_to_Complete_All_Competencies__c
        //Related task: T-320974
        list<Competency__c > selectedCompetency = new list<Competency__c >();
        for(Competency__c comp:newCompetency){
            if(setCBLRecordTypes.contains(comp.RecordTypeId) ){
                selectedCompetency.add(comp);
            }
        }
        if(!selectedCompetency.isEmpty()){
            programExpertiseHelper.rollUpProgramExpertiseTotalHoursToCompleteAllCompetencies(selectedCompetency);
        }
    }

    public void onAfterUnDelete(list<Competency__c > newCompetency){
        ProgramExpertiseHelper programExpertiseHelper = new ProgramExpertiseHelper();
        //Trigger to populate rogram Expertise's Total_hours_to_Complete_All_Competencies__c
        //Related task: T-320974
        list<Competency__c > selectedCompetency = new list<Competency__c >();
        for(Competency__c comp:newCompetency){
            if(setCBLRecordTypes.contains(comp.RecordTypeId) ){
                selectedCompetency.add(comp);
            }
        }
        if(!selectedCompetency.isEmpty()){
            programExpertiseHelper.rollUpProgramExpertiseTotalHoursToCompleteAllCompetencies(selectedCompetency);
        }
    }
}