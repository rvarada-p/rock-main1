/*******************************************************************
Name  : DataGenerator
Author: Horacio Sanchez
Date  : June 15, 2021
Description: Helper class that creates different custom and standard objects
			 S-48047: L2: Insert Selected Attributes from L1 as courses in L2
*************************************************************************/
public class DataGenerator {

    public static void createSEsAndSCsFromAOECodeAndSP(Set<String> courseCodesSet, Student_Program__c sp) {
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
        for (String aoeCourseCode : courseCodesSet) {
            Student_Expertise__c se = new Student_Expertise__c();
            se.Student_Program__c = sp.Id;
            se.Opportunity__c = sp.Application__c;
            se.Contact__c = sp.Student__c;
            se.Pseudo_CE__c = 0;
            se.Area_of_Expertise__c = courseCodeAOEMap.get(aoeCourseCode).Id;
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
        for (String aoeCourseCode : courseCodesSet) {
            List<Competency__c> competencies = AOELMSIdCompetenciesListMap.get(courseCodeLMSIdMap.get(aoeCourseCode));
            for (Competency__c competency : competencies) {
                Student_Competency__c sc = new Student_Competency__c();
                sc.Contact__c = sp.Student__c;
                sc.Opportunity__c = sp.Application__c;
                sc.Student_Program__c = sp.Id;
                sc.Competency__c = competency.Id;
                sc.Student_Expertise__c = SEIdStudentExpertiseMap.get('' + sp.Id + courseCodeAOEMap.get(aoeCourseCode).Id);
                sc.Status__c = 'Registered';
                sc.RecordTypeId = Schema.SObjectType.Student_Competency__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
                studentCompetenciesList.add(sc);
            }
        }
        
        if (!studentCompetenciesList.isEmpty()) {
            insert studentCompetenciesList;
        }
    }
    
    public static void deleteSEsAndSCsFromAOECodeAndSP(Set<String> courseCodesSet, Student_Program__c sp) {
        // Get the SEs that match Opportunity, SP, and AOE
        List<Student_Expertise__c> studentExpertiseList = [SELECT Id, Name, Area_of_Expertise__r.Course_code__c, Student_Program__c
                                                           FROM Student_Expertise__c 
                                                           WHERE Opportunity__c = :sp.Application__c
                                                           AND Student_Program__c = :sp.Id
                                                           AND Area_of_Expertise__r.Course_code__c IN :courseCodesSet];
        
        // Get SE Ids into a set to later get SCs
        Set<String> seIdSet = new Set<String>();
        for (Student_Expertise__c se : studentExpertiseList) {
            seIdSet.add(se.Id);            
        }
        
        // Get list of SCs
        List<Student_Competency__c> studentCompetencyList = [SELECT Id, Name FROM Student_Competency__c WHERE Student_Expertise__c IN :seIdSet];
        
        // Delete SCs
        if (!studentCompetencyList.isEmpty()) {
            delete studentCompetencyList;
        }
        
        // Delete SEs
        if (!studentExpertiseList.isEmpty()) {
            delete studentExpertiseList;
        }
    }
}