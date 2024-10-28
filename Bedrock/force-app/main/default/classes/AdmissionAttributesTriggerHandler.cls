/*******************************************************************
Name  : AdmissionAttributesTriggerHandler
Author: Horacio Sanchez
Date  : May 11, 2021
Description: Handler class for the Trigger AdmissionAttributesTrigger
             S-52090: L2: Update Credits on SP based on Admission Attributes at Opp

* Revision History
* Horacio Sanchez   - May 14, 2021 - User Story 48046: L2: Insert Selected Attributes from L1 as courses in L2 (MSN1, MSN7 and MSNA)
* Horacio Sanchez   - May 20, 2021 - User Story 52470: L2: Create Student Program Category Requirements
* Sufia             - June 28, 2021 - User Story S-685520 - Updates
*************************************************************************/
public with sharing class AdmissionAttributesTriggerHandler {
    
    public void onBeforeInsert(List<Admission_Attributes__c> newAdmissionAttributes) {
        List<Admission_Attributes__c> currentAAList = [SELECT Id, Name, Opportunity__c FROM Admission_Attributes__c];
        
        for (Admission_Attributes__c aa : newAdmissionAttributes) {
            for (Admission_Attributes__c caa : currentAAList) {
                if (aa.Name == caa.Name && aa.Opportunity__c == caa.Opportunity__c) {
                    aa.Name.addError('Admission Attribute with this code already exists for this Opportunity');
                }
            }
        }
    }
    
    public void onAfterInsert(List<Admission_Attributes__c > newAdmissionAttributes) {
        AdmissionAttributesTriggerHelper helper = new AdmissionAttributesTriggerHelper();
        Set<Id> aaIdSet = new Set<Id>();
        for (Admission_Attributes__c aa : newAdmissionAttributes) {
            aaIdSet.add(aa.Id);
        }
        
        List<Admission_Attributes__c> fullAAList = [SELECT Id, Name, Attribute_Name__c, Opportunity__c, Opportunity__r.Student_Program__c,External_Id__c, 
                                                           Opportunity__r.Contact__c,
                                                           Opportunity__r.Student_Program__r.Total_Credits_in_Program__c, 
                                                           Opportunity__r.Student_Program__r.Total_Credits_in_Program_MSN__c,
                                                           Opportunity__r.Student_Program__r.Program__r.ProductCode
                                                    FROM Admission_Attributes__c
                                                    WHERE Id IN :aaIdSet];
        
        List<Admission_Attributes__c> filteredFullAAList = new List<Admission_Attributes__c>();
        Map<String, Attribute_Rules__c> attributeRulesMap = Attribute_Rules__c.getAll();
        for (Admission_Attributes__c aa : fullAAList) {
            if (attributeRulesMap.get(aa.Name) != null) {
                filteredFullAAList.add(aa);
            }
        }
        
        if (!fullAAList.isEmpty()) {
            helper.updateTotalCreditsOnSP(filteredFullAAList, true);
            helper.manageSelectedAttributes(filteredFullAAList);
            helper.createStudentProgramCategoryRequirements(filteredFullAAList);
            //S-685520
            helper.handleBusinessEssentialsAndContingency(NULL,fullAAList);
        }
    }
    
    // S-48046: L2: Insert Selected Attributes from L1 as courses in L2 (MSN1, MSN7 and MSNA)
    public void onBeforeDelete(List<Admission_Attributes__c> oldAdmissionAttributesList) {
        AdmissionAttributesTriggerHelper helper = new AdmissionAttributesTriggerHelper();
        Set<Id> aaIdSet = new Set<Id>();
        for (Admission_Attributes__c aa : oldAdmissionAttributesList) {
            aaIdSet.add(aa.Id);
        }
        
        List<Admission_Attributes__c> fullAAList = [SELECT Id, Name, Attribute_Name__c, External_Id__c,Opportunity__c, Opportunity__r.Student_Program__c, Opportunity__r.Contact__c,
                                                           Opportunity__r.Student_Program__r.Total_Credits_in_Program__c, 
                                                           Opportunity__r.Student_Program__r.Total_Credits_in_Program_MSN__c,
                                                           Opportunity__r.Student_Program__r.Program__r.ProductCode
                                                    FROM Admission_Attributes__c
                                                    WHERE Id IN :aaIdSet];
        
        List<Admission_Attributes__c> filteredFullAAList = new List<Admission_Attributes__c>();
        Map<String, Attribute_Rules__c> attributeRulesMap = Attribute_Rules__c.getAll();
        for (Admission_Attributes__c aa : fullAAList) {
            if (attributeRulesMap.get(aa.Name) != null) {
                filteredFullAAList.add(aa); 
            }
        }
        
        if (!fullAAList.isEmpty()) {
            helper.manageDeleteAttributes(filteredFullAAList);
            helper.deleteStudentProgramCategoryRequirements(filteredFullAAList);
            helper.updateTotalCreditsOnSP(filteredFullAAList, false);
            //S-685520
            helper.clearAdmissionContingencyFieldOnAttrRemoval(fullAAList);
            //Bug-58157
            helper.unachieveSEsAndSCsWhenMBA2AAisDeleted(fullAAList);
        }
    }
    public void onAfterUpdate(Map<Id,Admission_Attributes__c> oldMap, List<Admission_Attributes__c > newAdmissionAttributes) {
       AdmissionAttributesTriggerHelper helper = new AdmissionAttributesTriggerHelper();
        Set<Id> aaIdSet = new Set<Id>();
        for (Admission_Attributes__c aa : newAdmissionAttributes) {
            aaIdSet.add(aa.Id);
        }
        
        List<Admission_Attributes__c> fullAAList = [SELECT Id, Name, Attribute_Name__c, Opportunity__c, Opportunity__r.Student_Program__c,External_Id__c, 
                                                           Opportunity__r.Contact__c,
                                                           Opportunity__r.Student_Program__r.Total_Credits_in_Program__c, 
                                                           Opportunity__r.Student_Program__r.Total_Credits_in_Program_MSN__c,
                                                           Opportunity__r.Student_Program__r.Program__r.ProductCode
                                                    FROM Admission_Attributes__c
                                                    WHERE Id IN :aaIdSet];
        
        List<Admission_Attributes__c> filteredFullAAList = new List<Admission_Attributes__c>();
        Map<String, Attribute_Rules__c> attributeRulesMap = Attribute_Rules__c.getAll();
        for (Admission_Attributes__c aa : fullAAList) {
            if (attributeRulesMap.get(aa.Name) != null) {
                filteredFullAAList.add(aa);
            }
        }
        
        if (!fullAAList.isEmpty()) {
            helper.updateTotalCreditsOnSP(filteredFullAAList, true);
            helper.manageSelectedAttributes(filteredFullAAList);
            helper.createStudentProgramCategoryRequirements(filteredFullAAList);
            //S-685520
            helper.handleBusinessEssentialsAndContingency(oldMap,fullAAList);
        } 
    }
}