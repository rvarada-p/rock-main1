/************************************************************************************** 
Apex Class Name     : BatchPopulateProgCatReqCeRollupOnSP
Created Date        : 23th December 2018
Function            : One time batch run to populate Req and Earned rollups on SP
					  for existing records
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                  
* Ravitej Varada            06/20/2019                Original Version
*************************************************************************************/
global class BatchPopulateProgCatReqCeRollupOnSP  implements Database.Batchable<sObject> {
    
    global String Query;
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'Select id,Program__c from Student_Program__c where Program__r.Degree_level__c = \'UnderGrad\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Student_Program__c> spLst){
        Set<Id> spIds = new Set<Id>();
        Set<Id> progrmIdSet = new Set<Id>();
        for(Student_program__c spObj : spLst){
            progrmIdSet.add(spObj.Program__c); 
            spIds.add(spObj.id);
        }
        Map<Id,Product2> productMap = new Map<Id,Product2>([Select id,(Select id, Category__c, Level__c, Subject_Area_Expertise__c, Total_CE__c from Degree_Requirements__r where Subject_Area_Expertise__c = null) from Product2 where id in: progrmIdSet]);
        for(Student_program__c spObj : spLst){
            Product2 pObj = new Product2();
            pObj = productMap.get(spObj.Program__c);
            if(!pObj.Degree_Requirements__r.isEmpty()){
                for(Program_Category_Requirement__c pcrObj : pObj.Degree_Requirements__r){
                    if(pcrObj.Category__c == 'Core' && pcrObj.Level__c == 'Upper'){
                        spObj.Required_Core_Upper__c = pcrObj.Total_CE__c;
                    }
                    else if(pcrObj.Category__c == 'Core' && pcrObj.Level__c == 'Lower'){
                        spObj.Required_Core_Lower__c = pcrObj.Total_CE__c;
                    }
                    else if(pcrObj.Category__c == 'General Education'){
                        spObj.Required_General_Education__c = pcrObj.Total_CE__c;
                    }
                    else if(pcrObj.Category__c == 'General Elective'){
                        spObj.Required_General_Elective__c = pcrObj.Total_CE__c;
                    }
                    else if(pcrObj.Category__c == 'Concentration'){
                        spObj.Required_Concentration__c = pcrObj.Total_CE__c;
                    }
                }
            }
        }
        
        database.update(spLst, false);
         
      	StudentAuditHistoryTriggerHelper.mapUGTotalEarnedCredits(spIds);
        
    }
    
    global void finish(Database.BatchableContext BC){
    }
}