/*******************************************************************
Name  : AdmissionAttributesTriggerHelper
Author: Horacio Sanchez
Date  : May 11, 2021
Description: Helper class for the Trigger AdmissionAttributesTrigger
             S-52090: L2: Update Credits on SP based on Admission Attributes at Opp

* Revision History
* Horacio Sanchez   - May 14, 2021 - User Story 48046: L2: Insert Selected Attributes from L1 as courses in L2 (MSN1, MSN7 and MSNA)
* Horacio Sanchez   - May 20, 2021 - User Story 52470: L2: Create Student Program Category Requirements
* Sufia             - June 28, 2021 - User Story S-685520
* Horacio Sanchez   - Jul 07, 2021 - Bug 58157: Business Essentials Fulfilled SC's and SE's are not changing to Registered when MBA2 attribute is deleted in L2
*************************************************************************/
public with sharing class AdmissionAttributesTriggerHelper {
    
    private static final String RNMSN_CODE = 'RNMSN';
    
    // S-52090: L2: Update Credits on SP based on Admission Attributes at Opp
    public void updateTotalCreditsOnSP(List<Admission_Attributes__c> admissionAttributesList, boolean adding) {
        // Get the course codes
        Map<String, Attribute_Rules__c> attributeRulesMap = Attribute_Rules__c.getAll();
        Map<String, Double> spIdAACountMap = new Map<String, Double>();
        for (Admission_Attributes__c admissionAttributes : admissionAttributesList) {
            if (!admissionAttributes.Opportunity__r.Student_Program__r.Program__r.ProductCode.contains(RNMSN_CODE)) continue;
            
            // get the value of the specified key
            Double count = spIdAACountMap.get(admissionAttributes.Opportunity__r.Student_Program__c);
            Double totalCredits = admissionAttributes.Opportunity__r.Student_Program__r.Total_Credits_in_Program_MSN__c != null ? admissionAttributes.Opportunity__r.Student_Program__r.Total_Credits_in_Program_MSN__c : admissionAttributes.Opportunity__r.Student_Program__r.Total_Credits_in_Program__c;
            Double attributeCredits = attributeRulesMap.get(admissionAttributes.Name).Required_Credits__c;
            
            // if the map contains no mapping for the key, map the key with a value of the Total Credits in Program + 5 (or -5 if deleting)
            if (count == null) {
                if (adding) {
                    spIdAACountMap.put(admissionAttributes.Opportunity__r.Student_Program__c, totalCredits + attributeCredits);
                } else {
                    spIdAACountMap.put(admissionAttributes.Opportunity__r.Student_Program__c, totalCredits - attributeCredits);
                }                
            } else {
                Double updatedTotalCreditsInProgram;
                if (adding) {
                    updatedTotalCreditsInProgram = spIdAACountMap.get(admissionAttributes.Opportunity__r.Student_Program__c) + attributeCredits;
                } else {
                    updatedTotalCreditsInProgram = spIdAACountMap.get(admissionAttributes.Opportunity__r.Student_Program__c) - attributeCredits;
                }                
                spIdAACountMap.put(admissionAttributes.Opportunity__r.Student_Program__c, updatedTotalCreditsInProgram);
            }
        }
        
        List<Student_Program__c> spToUpdateList = new List<Student_Program__c>();
        for (String s : spIdAACountMap.keySet()) {
            Student_Program__c sp = new Student_Program__c();
            sp.Id = s;
            sp.Total_Credits_in_Program_MSN__c = spIdAACountMap.get(s);
            spToUpdateList.add(sp);
        }
        
        if (!spToUpdateList.isEmpty()) {
            update spToUpdateList;
        }        
    }
    
    // S-48046: L2: Insert Selected Attributes from L1 as courses in L2 (MSN1, MSN7 and MSNA)
    public void manageSelectedAttributes(List<Admission_Attributes__c> admissionAttributesList) {
        List<Attribute_Rules__c> attributeRules = Attribute_Rules__c.getall().values();
        List<Admission_Attributes__c> requiredAttributesList = new List<Admission_Attributes__c>();
        List<Admission_Attributes__c> nonRequiredAttributesList = new List<Admission_Attributes__c>();
        
        for (Admission_Attributes__c aa : admissionAttributesList) {
            if (!aa.Opportunity__r.Student_Program__r.Program__r.ProductCode.contains(RNMSN_CODE)) continue;
            for (Attribute_Rules__c ar : attributeRules) {
                if (aa.Name == ar.Name) {
                    if (ar.Create_Course__c) {
                        requiredAttributesList.add(aa);
                    } else {
                        nonRequiredAttributesList.add(aa);
                    }
                    break;
                }
            }
        }       
        
        if (!requiredAttributesList.isEmpty()) {
            manageInsertRequiredAttributes(requiredAttributesList);
        }
    }
    
    // S-48046: L2: Insert Selected Attributes from L1 as courses in L2 (MSN1, MSN7 and MSNA)
    // Method creates SE and SC from the required attributes that were inserted
    private void manageInsertRequiredAttributes(List<Admission_Attributes__c> requiredAttributesList) {
        
        // Get the course codes
        Map<String, Attribute_Rules__c> attributeRulesMap = Attribute_Rules__c.getAll();
        Set<String> courseCodesSet = new Set<String>();
        for (Admission_Attributes__c aa : requiredAttributesList) {
            courseCodesSet.add(attributeRulesMap.get(aa.Name).Course_Name__c);
        }
        
        // Get the Area of Expertise Id to create SEs and LMS Ids to get Competency Id needed to create SCs
        List<Area_Of_Expertise__c> areaOfExpertiseList = [SELECT Id, Name, Course_Code__c, LMS_ID__c FROM Area_Of_Expertise__c WHERE Course_Code__c IN :courseCodesSet];
        Map<String, Area_Of_Expertise__c> courseCodeAOEMap= new Map<String, Area_Of_Expertise__c>();
        Set<String> AOELMSIdSet = new Set<String>();
        Map<String, String> courseCodeLMSIdMap = new Map<String, String>();
        for (Area_Of_Expertise__c aoe : areaOfExpertiseList) {
            courseCodeAOEMap.put(aoe.Course_Code__c, aoe);
            AOELMSIdSet.add(aoe.LMS_ID__c);
            courseCodeLMSIdMap.put(aoe.Course_Code__c, aoe.LMS_ID__c);
        }
        
        // Create SE for each required Attribute
        List<Student_Expertise__c> newSEList = new List<Student_Expertise__c>();
        for (Admission_Attributes__c aa : requiredAttributesList) {
            Student_Expertise__c se = new Student_Expertise__c();
            se.Student_Program__c = aa.Opportunity__r.Student_Program__c;
            se.Opportunity__c = aa.Opportunity__c;
            se.Contact__c = aa.Opportunity__r.Contact__c;
            se.Pseudo_CE__c = 0;
            se.Area_of_Expertise__c = courseCodeAOEMap.get(attributeRulesMap.get(aa.Name).Course_Name__c).Id;
            se.RecordTypeId = Schema.SObjectType.Student_Expertise__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
            newSEList.add(se);
        }
        
        Map<String, String> SEIdStudentExpertiseMap = new Map<String, String>();
        if (!newSEList.isEmpty()) {
            Database.SaveResult[] insertedSEList = Database.insert(newSEList, false);
         
            // Iterate through each returned result
            for (Integer i = 0; i < insertedSEList.size(); i++) {
                if (insertedSEList.get(i).isSuccess()) {
                    SEIdStudentExpertiseMap.put('' + newSEList[i].Student_Program__c + newSEList[i].Area_of_Expertise__c, newSEList[i].Id);
                } else {
                    Database.Error errors =  insertedSEList.get(i).getErrors().get(0);
                }
            }
        }
        
        // Get Competencies required for SCs
        List<Competency__c> competenciesList = [SELECT Id, Name, AoE_LMS_ID__c FROM Competency__c WHERE AoE_LMS_ID__c IN :AOELMSIdSet];
        Map<String, List<Competency__c>> AOELMSIdCompetenciesListMap = new Map<String, List<Competency__c>>();
        for (Competency__c competency : competenciesList) {
            if (AOELMSIdCompetenciesListMap.containsKey(competency.AoE_LMS_ID__c)) {
                AOELMSIdCompetenciesListMap.get(competency.AoE_LMS_ID__c).add(competency);
            } else {
                AOELMSIdCompetenciesListMap.put(competency.AoE_LMS_ID__c, new List<Competency__c>{competency});
            }
        }
        
        // Creating SCs
        List<Student_Competency__c> studentCompetenciesList = new List<Student_Competency__c>();
        for (Admission_Attributes__c aa : requiredAttributesList) {
            List<Competency__c> competencies = AOELMSIdCompetenciesListMap.get(courseCodeLMSIdMap.get(attributeRulesMap.get(aa.Name).Course_Name__c));
            for (Competency__c competency : competencies) {
                Student_Competency__c sc = new Student_Competency__c();
                sc.Contact__c = aa.Opportunity__r.Contact__c;
                sc.Opportunity__c = aa.Opportunity__c;
                sc.Student_Program__c = aa.Opportunity__r.Student_Program__c;
                sc.Competency__c = competency.Id;
                sc.Student_Expertise__c = SEIdStudentExpertiseMap.get('' + aa.Opportunity__r.Student_Program__c + courseCodeAOEMap.get(attributeRulesMap.get(aa.Name).Course_Name__c).Id);
                sc.Status__c = 'Registered';
                sc.RecordTypeId = Schema.SObjectType.Student_Competency__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
                studentCompetenciesList.add(sc);
            }
        }
        
        if (!studentCompetenciesList.isEmpty()) {
            insert studentCompetenciesList;
        }
        
    }
    
    // S-48046: L2: Insert Selected Attributes from L1 as courses in L2 (MSN1, MSN7 and MSNA)
    public void manageDeleteAttributes(List<Admission_Attributes__c> attributesList) {
        
        // Get the course codes, Opportunities and SPs
        Map<String, Attribute_Rules__c> attributeRulesMap = Attribute_Rules__c.getAll();
        Set<String> courseCodesSet = new Set<String>();
        Set<String> opportunityIdSet = new Set<String>();
        Set<String> spIdSet = new Set<String>();
        Map<String, List<String>> spAOESet = new Map<String, List<String>>();
        for (Admission_Attributes__c aa : attributesList) {
            courseCodesSet.add(attributeRulesMap.get(aa.Name).Course_Name__c);
            opportunityIdSet.add(aa.Opportunity__c);
            spIdSet.add(aa.Opportunity__r.Student_Program__c);
            if (!spAOESet.containsKey(aa.Opportunity__r.Student_Program__c)) {
                spAOESet.put(aa.Opportunity__r.Student_Program__c, new List<String>{attributeRulesMap.get(aa.Name).Course_Name__c});
            } else {
                spAOESet.get(aa.Opportunity__r.Student_Program__c).add(attributeRulesMap.get(aa.Name).Course_Name__c);
            }
        }
        
        // Get the Area of Expertise Id
        List<Area_Of_Expertise__c> areaOfExpertiseList = [SELECT Id, Name, Course_Code__c FROM Area_Of_Expertise__c WHERE Course_Code__c IN :courseCodesSet];
        Set<String> AOEIdSet = new Set<String>();
        for (Area_Of_Expertise__c aoe : areaOfExpertiseList) {
            AOEIdSet.add(aoe.Id);
        }
        
        if (!opportunityIdSet.isEmpty() && !spIdSet.isEmpty() && !AOEIdSet.isEmpty()) {
            // Get the SEs that match Opportunity, SP, and AOE
            List<Student_Expertise__c> studentExpertiseList = [SELECT Id, Name, Area_of_Expertise__r.Course_code__c, Student_Program__c
                                                               FROM Student_Expertise__c 
                                                               WHERE Opportunity__c IN :opportunityIdSet
                                                               AND Student_Program__c IN :spIdSet
                                                               AND Area_of_Expertise__c IN :AOEIdSet];
            
            // Get SE Ids into a set to later get SCs
            Set<String> seIdSet = new Set<String>();
            for (Student_Expertise__c se : studentExpertiseList) {
                for (String aoe : spAOESet.get(se.Student_Program__c)) {
                    if (se.Area_of_Expertise__r.Course_code__c == aoe) {
                        seIdSet.add(se.Id);
                        break;
                    }
                }
            }
            
            // Get list of SCs
            List<Student_Competency__c> studentCompetencyList = [SELECT Id, Name FROM Student_Competency__c WHERE Student_Expertise__c IN :seIdSet];
            
            // Delete SCs
            if (!studentCompetencyList.isEmpty()) {
                delete studentCompetencyList;
            }
            
            // Get final list of SE to be deleted
            List<Student_Expertise__c> seToDeleteList = new List<Student_Expertise__c>();
            for (String seId : seIdSet) {
                Student_Expertise__c se = new Student_Expertise__c();
                se.Id = seId;
                seToDeleteList.add(se);
            }
            
            // Delete SEs
            if (!seToDeleteList.isEmpty()) {
                delete seToDeleteList;
            }
        }        
    }
    
    // S-52470: L2: Create Student Program Category Requirements
    public void createStudentProgramCategoryRequirements(List<Admission_Attributes__c> admissionAttributesList) {
        
        // Get the Custom Setting
        Map<String, Attribute_Rules__c> attributeRulesMap = Attribute_Rules__c.getAll();
        List<Student_Program_Category_Requirement__c> spCRList = new List<Student_Program_Category_Requirement__c>();
        for (Admission_Attributes__c aa : admissionAttributesList) {
            Student_Program_Category_Requirement__c spCR = new Student_Program_Category_Requirement__c();
            spCR.Attribute__c = attributeRulesMap.get(aa.Name).Name;
            spCR.Required_Credits__c = attributeRulesMap.get(aa.Name).Required_Credits__c;
            spCR.Subject_Area_Expertise__c = attributeRulesMap.get(aa.Name).Subject_Matter_Expertise__c;
            spCR.Student_Program__c = aa.Opportunity__r.Student_Program__c;
            spCR.Category__c = attributeRulesMap.get(aa.Name).Category__c;
            spCRList.add(spCR);
        }
        
        if (!spCRList.isEmpty()) {
            insert spCRList;
        }
        
    }
    
    public void deleteStudentProgramCategoryRequirements(List<Admission_Attributes__c> admissionAttributesList) {        
        // Get the Custom Setting
        Map<String, Attribute_Rules__c> attributeRulesMap = Attribute_Rules__c.getAll();
        Set<String> attributesNameSet = new Set<String>();
        Set<String> spIdSet = new Set<String>();
        for (Admission_Attributes__c aa : admissionAttributesList) {
            attributesNameSet.add(aa.Name);
            spIdSet.add(aa.Opportunity__r.Student_Program__c);
        }
        
        
        List<Student_Program_Category_Requirement__c> spCRList = [SELECT Id, Attribute__c, Student_Program__c 
                                                                  FROM Student_Program_Category_Requirement__c
                                                                  WHERE Attribute__c IN :attributesNameSet
                                                                  AND Student_Program__c IN :spIdSet];
        
        List<Student_Program_Category_Requirement__c> spCRToDeleteList = new List<Student_Program_Category_Requirement__c>();
        for (Admission_Attributes__c aa : admissionAttributesList) {
            for (Student_Program_Category_Requirement__c spcr : spCRList) {
                if (aa.Name == spcr.Attribute__c && aa.Opportunity__r.Student_Program__c == spcr.Student_Program__c) {
                    spCRToDeleteList.add(spcr);
                    break;
                }
            }
        }
        
        if (!spCRToDeleteList.isEmpty()) {
            delete spCRToDeleteList;
        }
        
    }
    /*******************************************************************
    Name  : handleBusinessEssentialsAndContingency
    Author: Sufia
    Date  : June 28, 2021
    Description: S-685520 :- On insert of new attribute process updates on SE and SC
    *************************************************************************/
    public void handleBusinessEssentialsAndContingency(Map<Id,Admission_Attributes__c> oldMap,List<Admission_Attributes__c> newList) {
        Set<Id> setContactIdsWhoseSEAndSCsNeedsToBeUpdated = new Set<Id>();
        List<sObject> sobjUpdates = new List<sObject>();
        for(Admission_Attributes__c attr : newList){
            if((oldMap==NULL || (oldMap!=NULL && 
               (
                   oldMap.get(attr.Id).Name!=attr.Name ||  
                   oldMap.get(attr.Id).Attribute_Name__c != attr.Attribute_Name__c)
               )) && 
            'MBA2'.equalsIgnoreCase(attr.Name) && 'WMBA/MGMT/DDBA/ACCT 4990 Waive'.equalsIgnoreCase(attr.Attribute_Name__c) && String.isNotBlank(attr.External_Id__c)
              ) {
                setContactIdsWhoseSEAndSCsNeedsToBeUpdated.add(attr.Opportunity__r.Contact__c);
            }
            if(attr.Opportunity__r.Student_Program__r.Program__r.ProductCode!=NULL){ 
                if(Constants.CONTINGENT_STRING.equalsIgnoreCase(attr.Attribute_Name__c) && attr.Opportunity__c!=NULL){
                    sobjUpdates.add(new Opportunity(Id = attr.Opportunity__c,Admissions_Contingency__c=Constants.NOT_CLEARED_STRING));
                }
                else if(Constants.CONTINGENT_CLEARED_STRING.equalsIgnoreCase(attr.Attribute_Name__c) && attr.Opportunity__c!=NULL){
                    sobjUpdates.add(new Opportunity(Id = attr.Opportunity__c,Admissions_Contingency__c=Constants.CLEARED_STRING));
                }
                else{
                    sobjUpdates.add(new Opportunity(Id = attr.Opportunity__c,Admissions_Contingency__c=NULL));
                }
            }
        }
        for(Contact student : [select Id,(select Id from Student_Expertise__r where Area_of_Expertise__r.Name='Business Essentials (WMBA 4990)'),(select Id from Student_Competencies__r where Competency__r.Code__c IN :Constants.BECompetenciesList1) from Contact where Id IN :setContactIdsWhoseSEAndSCsNeedsToBeUpdated]){
            for(Student_Expertise__c expertise : student.Student_Expertise__r){
                    expertise.IsAchieved__c = true;
                    sobjUpdates.add(expertise);
            }
			for(Student_Competency__c competency : student.Student_Competencies__r){
                    competency.Status__c = Constants.FULFILLED_STRING;
                    sobjUpdates.add(competency);
            }
        }
        OpportunityTriggerHandler.firstRun=false;
        update Utility.getsObjectListChunkSafe(sobjUpdates);
        OpportunityTriggerHandler.firstRun=true;
    }
    /*******************************************************************
    Name  : handleBusinessEssentialsAndContingency
    Author: Sufia
    Date  : June 28, 2021
    Description: S-685520 :- On delete of attribute process updates on contigency field on opportunity
    *************************************************************************/
    public void clearAdmissionContingencyFieldOnAttrRemoval(List<Admission_Attributes__c> newList) {
        List<sObject> sobjUpdates = new List<sObject>();
        for(Admission_Attributes__c attr : newList){
            if(attr.Opportunity__r.Student_Program__r.Program__r.ProductCode!=NULL){ 
                if(Constants.CONTINGENT_STRING.equalsIgnoreCase(attr.Attribute_Name__c) && attr.Opportunity__c!=NULL){
                    sobjUpdates.add(new Opportunity(Id = attr.Opportunity__c,Admissions_Contingency__c=NULL));
                }
                if(Constants.CONTINGENT_CLEARED_STRING.equalsIgnoreCase(attr.Attribute_Name__c) && attr.Opportunity__c!=NULL){
                    sobjUpdates.add(new Opportunity(Id = attr.Opportunity__c,Admissions_Contingency__c=NULL));
                }
            }
        }
        update Utility.getsObjectListChunkSafe(sobjUpdates);
    }
    
    /*
	 * Bug 58157: Business Essentials Fulfilled SC's and SE's are not changing to Registered when MBA2 attribute is deleted in L2
     */ 
	public void unachieveSEsAndSCsWhenMBA2AAisDeleted(List<Admission_Attributes__c> aaList) {
    	Set<Id> setContactIdsWhoseSEAndSCsNeedsToBeUpdated = new Set<Id>();
        List<sObject> sobjUpdates = new List<sObject>();
        for (Admission_Attributes__c attr : aaList) {
        	if ('MBA2'.equalsIgnoreCase(attr.Name) && 'WMBA/MGMT/DDBA/ACCT 4990 Waive'.equalsIgnoreCase(attr.Attribute_Name__c) && String.isNotBlank(attr.External_Id__c)) {
                setContactIdsWhoseSEAndSCsNeedsToBeUpdated.add(attr.Opportunity__r.Contact__c);
            }
        }
        for (Contact student : [select Id,(select Id from Student_Expertise__r where Area_of_Expertise__r.Name='Business Essentials (WMBA 4990)'),(select Id from Student_Competencies__r where Competency__r.Code__c IN :Constants.BECompetenciesList1) from Contact where Id IN :setContactIdsWhoseSEAndSCsNeedsToBeUpdated]){
            for (Student_Expertise__c expertise : student.Student_Expertise__r) {
                expertise.IsAchieved__c = false;
                sobjUpdates.add(expertise);
            }
            for(Student_Competency__c competency : student.Student_Competencies__r) {
                competency.Status__c = Constants.REGISTERED_STRING;
                sobjUpdates.add(competency);
            }
        }
         
        update Utility.getsObjectListChunkSafe(sobjUpdates);
    }
}