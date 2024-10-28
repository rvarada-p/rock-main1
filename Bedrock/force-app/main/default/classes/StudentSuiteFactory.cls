/*******************************************************************
Name  : StudentSuiteFactory
Author: Vinod (Appirio)
Date  : September 17, 2014
Description: Handler class for the Trigger BrandProfilesTrigger
Name: Sarah Khalid - Laureate
Date: June 14, 2016
Description: Made changes to incorporate Program hierarchy

Revision History 
Horacio Sanchez - 9/29/2020 - S-25237 Move Existing Pre-req functionality from AoE to PE
*************************************************************************/
public with sharing class StudentSuiteFactory {

    public void createTBYBStudentCompetencyAndStudentExpertiseForBrandProfile(list<Brand_Profile__c> bpList) {
        createTBYBStudentExpertiseForBrandProfile(bpList);
        createTBYBStudentCompetencyForBrandProfile(bpList);
    }

    public map<Id, list<Brand_Profile__c>> buildProgIdMapOfBPs(list<Brand_Profile__c> bpList) {
        map<Id, list<Brand_Profile__c>> mapProgId_bpList = new map<Id, list<Brand_Profile__c>>();
        for (Brand_Profile__c bp : bpList) {
            if (!mapProgId_bpList.containsKey(bp.Primary_Program_of_Interest__c)) {
                mapProgId_bpList.put(bp.Primary_Program_of_Interest__c, new list<Brand_Profile__c>());
            }
            mapProgId_bpList.get(bp.Primary_Program_of_Interest__c).add(bp);
        }
        return mapProgId_bpList;
    }

    public void createTBYBStudentExpertiseForBrandProfile(list<Brand_Profile__c> bpList) {
        list<Student_Expertise__c> newStudentExpertiseList = new list<Student_Expertise__c>();
        map<Id, list<Brand_Profile__c>> mapProgId_bpList = buildProgIdMapOfBPs(bpList);
        // build map of the single open Opportunity for Brand Profile's Primary Program of Interest
        map<Id, Id> mapBrandProfileIdWithOpenOpportunityId = getOpenOpportunityOfBrandProfile(bpList);
        // This will only bring back TBYB expertise for the Programs the incoming Brand Profiles specify
        for (Program_Expertise__c pExp : [
                SELECT Program__c,Learning_Order__c,Area_of_Expertise__c, Id, Is_Not_Available_for_Student__c
                FROM Program_Expertise__c
                WHERE Program__c IN :mapProgId_bpList.keySet()
                AND IsTryBeforeYouBuy__c = true
        ]) {
            for (Brand_Profile__c bp : mapProgId_bpList.get(pExp.Program__c)) {
                Student_Expertise__c sExp = new Student_Expertise__c();
                sExp.Area_of_Expertise__c = pExp.Area_of_Expertise__c;
                sExp.Program_Expertise__c = pExp.Id;
                sExp.Contact__c = bp.Contact__c;
                sExp.Learning_Order__c = pExp.Learning_Order__c;
                if (mapBrandProfileIdWithOpenOpportunityId.containsKey(bp.Id)) {
                    sExp.Opportunity__c = mapBrandProfileIdWithOpenOpportunityId.get(bp.Id);
                }
                newStudentExpertiseList.add(sExp);
            }
        }
        if (!newStudentExpertiseList.isEmpty()) {
            insert newStudentExpertiseList;
        }
    }

    public void createTBYBStudentCompetencyForBrandProfile(list<Brand_Profile__c> bpList) {
        list<Student_Competency__c> newStudentCompetencyList = new list<Student_Competency__c>();
        map<Id, list<Brand_Profile__c>> mapProgId_bpList = buildProgIdMapOfBPs(bpList);
        // build map of the single open Opportunity for Brand Profile's Primary Program of Interest
        map<Id, Id> mapBrandProfileIdWithOpenOpportunityId = getOpenOpportunityOfBrandProfile(bpList);
        // build map of existing Student Expertises per Brand Profile, organized by Program Expertise
        map<Id, map<Id, Student_Expertise__c>> mapBrandProfileIdWithMapOfStuExps = new map<Id, map<Id, Student_Expertise__c>>();
        for (Student_Expertise__c stuExp : [
                SELECT Id, Program_Expertise__c, Opportunity__r.Brand_Profile__c, Is_Not_Available_for_Student__c
                FROM Student_Expertise__c
                WHERE Opportunity__c IN :mapBrandProfileIdWithOpenOpportunityId.values()
        ]) {
            if (!mapBrandProfileIdWithMapOfStuExps.containsKey(stuExp.Opportunity__r.Brand_Profile__c)) {
                map<Id, Student_Expertise__c> tempMap = new map<Id, Student_Expertise__c>();
                tempMap.put(stuExp.Program_Expertise__c, stuExp);
                mapBrandProfileIdWithMapOfStuExps.put(stuExp.Opportunity__r.Brand_Profile__c, tempMap);
            } else {
                map<Id, Student_Expertise__c> tempMap = mapBrandProfileIdWithMapOfStuExps.get(stuExp.Opportunity__r.Brand_Profile__c);
                if (!tempMap.containsKey(stuExp.Program_Expertise__c)) {
                    tempMap.put(stuExp.Program_Expertise__c, stuExp);
                    mapBrandProfileIdWithMapOfStuExps.put(stuExp.Opportunity__r.Brand_Profile__c, tempMap);
                }
            }
        }
        // This will only bring back TBYB competencies for the Programs the incoming Brand Profiles specify
        for (Program_Competency__c pComp : [
                SELECT Product__c, Id,Program_Expertise__c, Competency__c,Learning_Order__c
                FROM Program_Competency__c
                WHERE Product__c IN :mapProgId_bpList.keySet()
                AND IsTryBeforeYouBuy__c = true
        ]) {
            for (Brand_Profile__c bp : mapProgId_bpList.get(pComp.Product__c)) {
                Student_Competency__c sComp = new Student_Competency__c();
                sComp.Competency__c = pComp.Competency__c;
                sComp.Program_Competency__c = pComp.Id;
                sComp.Contact__c = bp.Contact__c;
                sComp.Status__c = 'Registered';
                sComp.Learning_Order__c = pComp.Learning_Order__c;
                if (mapBrandProfileIdWithOpenOpportunityId.containsKey(bp.ID)) {
                    sComp.Opportunity__c = mapBrandProfileIdWithOpenOpportunityId.get(bp.ID);
                }
                if (pComp.Program_Expertise__c != null && mapBrandProfileIdWithMapOfStuExps.containsKey(bp.Id)) {
                    map<Id, Student_Expertise__c> mapProgExpWithStuExp = mapBrandProfileIdWithMapOfStuExps.get(bp.Id);
                    if (mapProgExpWithStuExp.containsKey(pComp.Id)) {
                        sComp.Student_Expertise__c = mapProgExpWithStuExp.get(pComp.Id).Id;
                    }
                }
                newStudentCompetencyList.add(sComp);
            }
        }
        if (!newStudentCompetencyList.isEmpty()) {
            insert newStudentCompetencyList;
        }
    }

    /*******************************************************************
    Method to create Student_Competency__c and Student_Expertise__c records
    If not Already Exist for the contact and Primary Program Of Interest
    Related task:T-320845
    Created b y: Vinod
    ********************************************************************/
    public void createStudentCompetencyAndStudentExpertise(list<Brand_Profile__c> lstBrans, set<ID> contactIds, set<Id> PrimaryProgramOfInterestIds) {
        // check StudentCompetency And StudentExpertise is Exist or not for the selected contact and Program Of Interest
        // get all existing Student_Expertise__c
        set<string> studentExpertiseExistContactAndPrimaryProgramOfInterest = new set<string>();
        for (Student_Expertise__c sEper : [
                Select ID,Program_Expertise__r.Program__c,Program_Expertise__c,Contact__c
                from Student_Expertise__c
                Where Contact__c in:contactIds and
                Program_Expertise__r.Program__c in :PrimaryProgramOfInterestIds
        ]) {
            string strKey = sEper.Contact__c + '$' + sEper.Program_Expertise__r.Program__c;
            studentExpertiseExistContactAndPrimaryProgramOfInterest.add(strKey);
        }
        // get all existing Student_Competency__c
        set<string> existingStudentCompetencyForContactAndPrimaryProgramOfInterest = new set<string>();
        for (Student_Competency__c sComp : [
                Select ID,Program_Competency__r.Product__c,Contact__c
                from Student_Competency__c
                Where Contact__c in:contactIds and
                Program_Competency__r.Product__c in :PrimaryProgramOfInterestIds
        ]) {
            string strKey = sComp.Contact__c + '$' + sComp.Program_Competency__r.Product__c;
            existingStudentCompetencyForContactAndPrimaryProgramOfInterest.add(strKey);
        }
        list<Brand_Profile__c> bpListForTBYB_Exp = new list<Brand_Profile__c>();
        list<Brand_Profile__c> bpListForTBYB_Comp = new list<Brand_Profile__c>();
        for (Brand_Profile__c bp : lstBrans) {
            string strKey = bp.Contact__c + '$' + bp.Primary_Program_of_Interest__c;
            // check Student_Expertise__c is already exist for the contact and Primary_Program_of_Interest__c
            if (!studentExpertiseExistContactAndPrimaryProgramOfInterest.contains(strKey)) {
                bpListForTBYB_Exp.add(bp);
            }
            // check Student_Competency__c is already exist for the contact and Primary_Program_of_Interest__c
            if (!existingStudentCompetencyForContactAndPrimaryProgramOfInterest.contains(strKey)) {
                bpListForTBYB_Comp.add(bp);
            }
        }
        if (!bpListForTBYB_Exp.isEmpty()) {
            createTBYBStudentExpertiseForBrandProfile(bpListForTBYB_Exp);
        }
        if (!bpListForTBYB_Comp.isEmpty()) {
            createTBYBStudentCompetencyForBrandProfile(bpListForTBYB_Comp);
        }
    }


    // TODO: ? add check for Primary Program of Interest ???        
    // builds map of the single open Opportunity for Brand Profile's Primary Program of Interest
    private map<ID, ID> getOpenOpportunityOfBrandProfile(list<Brand_Profile__c> lstProfile) {
        map<ID, ID> mapBrandProfileIDWithOpenOpportunityId = new map<ID, ID>();
        for (Opportunity opty : [Select ID,Brand_Profile__c, Program_Start_Date__c from Opportunity where Brand_Profile__c in:lstProfile and IsClosed = false Order By CreatedDate desc]) {
            if (!mapBrandProfileIDWithOpenOpportunityId.containsKey(opty.Brand_Profile__c)) {
                mapBrandProfileIDWithOpenOpportunityId.put(opty.Brand_Profile__c, opty.ID);
            }
        }
        return mapBrandProfileIDWithOpenOpportunityId;
    }

    /*******************************************************************
    Method to create Brand Profile when Opp goes to Admitted
    Created by: Sarah
    ********************************************************************/

    public void createBrandProfile(list<Opportunity> selectedOpportunity) {
        System.debug('In createBrandProfile');
        set<Id> contactIds = new set<Id>();
        for (Opportunity op : selectedOpportunity) {
            contactIds.add(op.Contact__c);
        }

        list<Brand_Profile__c> lstBrandProfile = new list<Brand_Profile__c>([SELECT Id FROM Brand_Profile__c WHERE Contact__c IN :contactIds LIMIT 1]);

        //Only create the BP if it doesn't exist already
        list<Brand_Profile__c> lstBPs = new list<Brand_Profile__c>();
        list<Opportunity> lstOpps = new list<Opportunity>();

        for (Opportunity opp : selectedOpportunity) {

            system.debug('******** OPP' + opp.Student_First_Name__c);
            system.debug('******** OPP' + opp.Student_Last_Name__c);
            system.debug('******** OPP' + opp.Email__c);
            system.debug('******** OPP' + opp.Primary_Program__c);
            system.debug('******** OPP' + opp.Contact__r.name);
            if (lstBrandProfile.size() == 0) {
                if (opp.Brand_Profile__c == null) {
                    Brand_Profile__c bp = new Brand_Profile__c();
                    bp.Primary_Program_of_Interest__c = opp.Primary_Program__c;
                    bp.First_Name__c = opp.Student_First_Name__c;
                    bp.Last_Name__c = opp.Student_Last_Name__c;
                    bp.Contact__c = opp.Contact__c;
                    bp.Email__c = opp.Email__c;
                    lstBPs.add(bp);
                }
            }
        }
        if (!lstBPs.isEmpty()) {
            insert lstBPs;
        }

    }


    /*******************************************************************
    Method to create  FullCBLStudentProgram
    Related task: T-321618
    Created by: Vinod
    ********************************************************************/
    public void createFullCBLStudentProgram(list<Opportunity> selectedOpportunity) {
        System.debug('in createFullCBLStudentProgram');
        // check student program is already existing
        map<ID, Student_Program__c> mapOpportunityWithAlreadyExistingStudentprogram = new map<ID, Student_Program__c>();
        for (Student_Program__c sProgram : [Select ID,Application__c from Student_Program__c where Application__c in:selectedOpportunity]) {
            mapOpportunityWithAlreadyExistingStudentprogram.put(sProgram.Application__c, sProgram);
        }
        // Create a Student Program record
        list<Student_Program__c> newStudentPrograms = new list<Student_Program__c>();
        set<ID>setPrimaryProgram = new set<ID>();
        map<ID, Student_Program__c> mapOpportunityWithStudentprogram = new map<ID, Student_Program__c>();
        Map<id, id> oppChildPrimaryProgramIds = new Map<id, id>();
        Map<id, id> oppParentPrimaryProgramIds = new Map<id, id>();
        Map<Id, Product2> prdParentPrgmVrsnMap;
        Map<Id, Product2> prdChildPrgmVrsnMap;
        for (Opportunity opp : selectedOpportunity) {
            oppParentPrimaryProgramIds.put(opp.Id, opp.Parent_Program__c);
            oppChildPrimaryProgramIds.put(opp.Id, opp.Primary_Program__c);
        }
        If (!oppParentPrimaryProgramIds.isEmpty()) {
            prdParentPrgmVrsnMap = new Map<Id, Product2>([Select id, (select id,Active__c from Program_Versions__r where Apply_to_New_Students__c = true) from Product2 where id in :oppParentPrimaryProgramIds.values()]);
        }
        If (!oppChildPrimaryProgramIds.isEmpty()) {
            prdChildPrgmVrsnMap = new Map<Id, Product2>([Select id, (select id,Active__c from Program_Versions__r where Apply_to_New_Students__c = true) from Product2 where id in :oppChildPrimaryProgramIds.values()]);
        }

        for (Opportunity opty : [Select ID, Change_of_Program__c, COP_Related_Opportunity__c, Primary_Program__c,Student_Program__c,Brand_Profile__c,Contact__c, Program_Start_Date__c, Student_Type__c from Opportunity where id in:selectedOpportunity]) {
            if (!mapOpportunityWithAlreadyExistingStudentprogram.containsKey(opty.ID)) {
                Student_Program__c sProgram = createStudentProgram(opty);


                If (sProgram.Application__c != null && !oppChildPrimaryProgramIds.isEmpty() && !prdChildPrgmVrsnMap.isEmpty() &&
                        oppChildPrimaryProgramIds.containsKey(sProgram.Application__c) &&
                        oppChildPrimaryProgramIds.get(sProgram.Application__c) != null &&
                        prdChildPrgmVrsnMap.containsKey(oppChildPrimaryProgramIds.get(sProgram.Application__c)) &&
                        prdChildPrgmVrsnMap.get(oppChildPrimaryProgramIds.get(sProgram.Application__c)) != null &&
                        !(prdChildPrgmVrsnMap.get(oppChildPrimaryProgramIds.get(sProgram.Application__c)).Program_Versions__r.isEmpty())) {
                    for (Program_Version__c pvObj : prdChildPrgmVrsnMap.get(oppChildPrimaryProgramIds.get(sProgram.Application__c)).Program_Versions__r) {
                        sProgram.Program_Version__c = pvObj.Id;
                    }
                } else if (sProgram.Application__c != null && !oppParentPrimaryProgramIds.isEmpty() && !prdParentPrgmVrsnMap.isEmpty() &&
                        oppParentPrimaryProgramIds.containsKey(sProgram.Application__c) &&
                        oppParentPrimaryProgramIds.get(sProgram.Application__c) != null &&
                        prdParentPrgmVrsnMap.containsKey(oppParentPrimaryProgramIds.get(sProgram.Application__c)) &&
                        prdParentPrgmVrsnMap.get(oppParentPrimaryProgramIds.get(sProgram.Application__c)) != null &&
                        !(prdParentPrgmVrsnMap.get(oppParentPrimaryProgramIds.get(sProgram.Application__c)).Program_Versions__r.isEmpty())) {
                    for (Program_Version__c pvObj : prdParentPrgmVrsnMap.get(oppParentPrimaryProgramIds.get(sProgram.Application__c)).Program_Versions__r) {
                        sProgram.Program_Version__c = pvObj.Id;
                    }
                }

                newStudentPrograms.add(sProgram);
                setPrimaryProgram.add(opty.Primary_Program__c);
                mapOpportunityWithStudentprogram.put(opty.ID, sProgram);
            }
        }
        try {
            insert newStudentPrograms;
        } catch (DmlException ex) {
            apexLogHandler.apexLog log;
            log = new apexLogHandler.apexLog('StudentSuiteFactory', 'createFullCBLStudentProgram', ex.getMessage());
        }
        
        // all the Program_Expertise and Program_Competencies related to the Opp.Primary_Program__c
        Map<ID, List<Program_Expertise__c>> mapProgramWithProgramExpertise = new Map<ID, List<Program_Expertise__c>>();
        Set<ID> setProgramExpertiseID = new set<ID>();
        for (Program_Expertise__c pExp : [Select Program__c, Id,Is_Pre_Req_Lock__c, Area_of_Expertise__c, Is_Not_Available_for_Student__c From Program_Expertise__c where Program__c in:setPrimaryProgram]) {
            setProgramExpertiseID.add(pExp.ID);
            if (!mapProgramWithProgramExpertise.containsKey(pExp.Program__c)) {
                mapProgramWithProgramExpertise.put(pExp.Program__c, new list<Program_Expertise__c>());
            }
            mapProgramWithProgramExpertise.get(pExp.Program__c).add(pExp);
        }
        
        system.debug('mapProgramWithProgramExpertise::::::;;' + mapProgramWithProgramExpertise);
        // get all Program_Competency__c
        Map<ID, list<Program_Competency__c>> mapProgramWithProgramCompetency = new map<ID, list<Program_Competency__c>>();
        Set<ID> setProgramCompetencyID = new set<ID>();
        for (Program_Competency__c pComp : [Select Program_Expertise__c, Product__c, Id, Competency__c, Learning_Order__c From Program_Competency__c where Product__c in :setPrimaryProgram]) {
            setProgramCompetencyID.add(pComp.id);
            if (!mapProgramWithProgramCompetency.containsKey(pComp.Product__c)) {
                mapProgramWithProgramCompetency.put(pComp.Product__c, new list<Program_Competency__c>());
            }
            mapProgramWithProgramCompetency.get(pComp.Product__c).add(pComp);
        }
        system.debug('mapProgramWithProgramCompetency::::::;;' + mapProgramWithProgramCompetency);
        // get all Student_Expertise and Student_Competencies
        Map<ID, List<Student_Expertise__c>> mapProgramExpertiseWithStudentExpertise = new Map<ID, List<Student_Expertise__c>>();
        for (Student_Expertise__c sExpe : [
                Select Student_Program__c, Student_Name__c, Program_Expertise__c, Opportunity__c, Id, Contact__c, Area_of_Expertise__c
                From Student_Expertise__c
                where Program_Expertise__c in:setProgramExpertiseID and Opportunity__c in:selectedOpportunity and Student_Program__c = null
        ]) {
            if (!mapProgramExpertiseWithStudentExpertise.containsKey(sExpe.Program_Expertise__c)) {
                mapProgramExpertiseWithStudentExpertise.put(sExpe.Program_Expertise__c, new list<Student_Expertise__c>());
            }
            mapProgramExpertiseWithStudentExpertise.get(sExpe.Program_Expertise__c).add(sExpe);
        }
        system.debug('mapProgramExpertiseWithStudentExpertise::::::;;' + mapProgramExpertiseWithStudentExpertise);
        // get all Student_Competency__c
        Map<ID, List<Student_Competency__c>> mapProgramCompetencyWithStudentCompetency = new Map<ID, List<Student_Competency__c>>();
        for (Student_Competency__c sComp : [
                Select Student_Program__c, Student_Expertise__c, Program_Competency__c, Opportunity__c, Id, Contact__c, Competency__c
                From Student_Competency__c
                where Program_Competency__c in:setProgramCompetencyID and Opportunity__c in:selectedOpportunity and Student_Program__c = null
        ]) {
            if (!mapProgramCompetencyWithStudentCompetency.containsKey(sComp.Program_Competency__c)) {
                mapProgramCompetencyWithStudentCompetency.put(sComp.Program_Competency__c, new List<Student_Competency__c>());
            }
            mapProgramCompetencyWithStudentCompetency.get(sComp.Program_Competency__c).add(sComp);
        }
        System.debug('mapProgramCompetencyWithStudentCompetency::::::;;' + mapProgramCompetencyWithStudentCompetency);
        Map<ID, list<Student_Expertise__c>> mapOpprtunityWithStudentExpertise = new Map<ID, list<Student_Expertise__c>>();
        // populate found Student_Expertise__c.Student_Program__c with newly created Student_Program__c
        // else create new Student_Expertise__c
        List<Student_Expertise__c> lstStudentExpertise = new list<Student_Expertise__c>();
        for (Student_Program__c newSProgram : newStudentPrograms) {
            // check the related program has Student_Expertise__c
            system.debug('newSProgram111::::::;;' + newSProgram);
            if (mapProgramWithProgramExpertise.containsKey(newSProgram.Program__c)) {
                for (Program_Expertise__c pExp : mapProgramWithProgramExpertise.get(newSProgram.Program__c)) {
                    // check that related Student_Expertise__c exist with same oppertunity
                    boolean isStudentExpertiseExist = false;
                    system.debug('pExp::::::;;' + pExp);
                    if (mapProgramExpertiseWithStudentExpertise.containsKey(pExp.id)) {
                        for (Student_Expertise__c sExper : mapProgramExpertiseWithStudentExpertise.get(pExp.id)) {
                            system.debug('sExper::::::;;' + sExper);
                            // check selected Student_Expertise__c has
                            if (sExper.Opportunity__c == newSProgram.Application__c) {
                                sExper.Student_Program__c = newSProgram.ID;
                                sExper.Program_Expertise__c = pExp.Id;
                                lstStudentExpertise.add(sExper);
                                if (!mapOpprtunityWithStudentExpertise.containsKey(newSProgram.Application__c)) {
                                    mapOpprtunityWithStudentExpertise.put(newSProgram.Application__c, new list<Student_Expertise__c>());
                                }
                                mapOpprtunityWithStudentExpertise.get(newSProgram.Application__c).add(sExper);
                                isStudentExpertiseExist = true;
                            }
                        }
                    }
                    system.debug('isStudentExpertiseExist::::::;;' + isStudentExpertiseExist);
                    if (!isStudentExpertiseExist) {
                        // create new Student_Expertise__c
                        Student_Expertise__c sExper = createStudentExpertise(newSProgram, pExp);
                        lstStudentExpertise.add(sExper);
                        // need to create student competency
                        if (!mapOpprtunityWithStudentExpertise.containsKey(newSProgram.Application__c)) {
                            mapOpprtunityWithStudentExpertise.put(newSProgram.Application__c, new list<Student_Expertise__c>());
                        }
                        mapOpprtunityWithStudentExpertise.get(newSProgram.Application__c).add(sExper);
                    }
                }
            }

        }
        System.debug('lstStudentExpertise::::::;;' + lstStudentExpertise);
        if (!lstStudentExpertise.isEmpty()) {
            upsert lstStudentExpertise;
        }
        // populate found Student_Competency__c.Student_Program__c with newly created Student_Program__c
        // else create new Student_Competency__c
        List<Student_Competency__c> lstStudentCompetency = new List<Student_Competency__c>();
        for (Student_Program__c newSProgram : newStudentPrograms) {
            // check related program has Program_Competency__c
            System.debug('newSProgram222::::::;;' + newSProgram);
            if (mapProgramWithProgramCompetency.containsKey(newSProgram.Program__c)) {
                for (Program_Competency__c pComp : mapProgramWithProgramCompetency.get(newSProgram.Program__c)) {
                    // check that related Student_Competency__c exist with same oppertunity
                    boolean isStudentCompetencyExist = false;
                    System.debug('pComp::::::;;' + pComp);
                    if (mapProgramCompetencyWithStudentCompetency.containsKey(pComp.ID)) {
                        for (Student_Competency__c sCompetency : mapProgramCompetencyWithStudentCompetency.get(pComp.ID)) {
                            system.debug('sCompetency::::::;;' + sCompetency);
                            if (sCompetency.Opportunity__c == newSProgram.Application__c) {
                                sCompetency.Student_Program__c = newSProgram.ID;
                                lstStudentCompetency.add(sCompetency);
                                isStudentCompetencyExist = true;
                            }
                        }
                    }
                    System.debug('isStudentCompetencyExist::::::;;' + isStudentCompetencyExist);
                    if (!isStudentCompetencyExist) {
                        // create student competency with the selected Program_Competency__c and opportunity
                        Student_Competency__c sCompetency = createStudentCompetency(newSProgram, pComp);
                        // poulate Student_Expertise__c field value
                        if (mapOpprtunityWithStudentExpertise.containsKey(newSProgram.Application__c)) {
                            for (Student_Expertise__c sExper : mapOpprtunityWithStudentExpertise.get(newSProgram.Application__c)) {
                                if (pComp.Program_Expertise__c == sExper.Program_Expertise__c) {
                                    sCompetency.Student_Expertise__c = sExper.ID;
                                    break;
                                }
                            }
                        }
                        lstStudentCompetency.add(sCompetency);
                    }
                }
            }
        }
        System.debug('lstStudentCompetency::::::;;' + lstStudentCompetency);
        if (!lstStudentCompetency.isEmpty()) {
            upsert lstStudentCompetency;
        }

        // S-25237
        // Setting up Pre-Requisite rules
        // First, get PE Ids from each SE in the list and Map each PE with its respective SE
        Set<Id> peInSeIdSet = new Set<Id>();
        Map<Id, Id> peIdSeIdMap = new Map<Id, Id>();
        for (Student_Expertise__c studentExpertise : lstStudentExpertise) {
            peInSeIdSet.add(studentExpertise.Program_Expertise__c);
            peIdSeIdMap.put(studentExpertise.Program_Expertise__c, studentExpertise.Id);
        }
        
        List<PE_Pre_Requisite_Rule__c> pePreRequisiteRuleList = new List<PE_Pre_Requisite_Rule__c>();
        pePreRequisiteRuleList = [SELECT Id, Program_Expertise__c, Pre_Requisite_Course__c FROM PE_Pre_Requisite_Rule__c WHERE Program_Expertise__c IN :peInSeIdSet];
        
        // Loop through the list of PE Pre-requiste rules to create the corresponding SE Pre-Requisite Rules
        List<SE_Pre_Requisite_Rule__c> sePreRequisiteRuleList = new List<SE_Pre_Requisite_Rule__c>();
        Set<Id> studentExpertiseToUpdateIDSet = new Set<Id>();
        if (!pePreRequisiteRuleList.isEmpty()) {
            for (PE_Pre_Requisite_Rule__c pePreReqRule : pePreRequisiteRuleList) {
                for (Student_Expertise__c studentExpertise : lstStudentExpertise) {
                    if (studentExpertise.Program_Expertise__c == pePreReqRule.Program_Expertise__c) {
                        // Create the SE Pre-Requisite Rule
                        SE_Pre_Requisite_Rule__c sePreReqRule = new SE_Pre_Requisite_Rule__c();
                        sePreReqRule.Student_Expertise__c = peIdSeIdMap.get(pePreReqRule.Program_Expertise__c);
                        sePreReqRule.Pre_Requisite_Course__c = peIdSeIdMap.get(pePreReqRule.Pre_Requisite_Course__c);
                        sePreReqRule.Is_Achieved__c = false;
                        sePreRequisiteRuleList.add(sePreReqRule);
                        
                        // Add the Id of the SE that will be updated to have a pre-lock
                        studentExpertiseToUpdateIDSet.add(studentExpertise.Id);
                        
                        break;
                    }
                }
            }
        }
        List<Student_Expertise__c> studentExpertiseToUpdateList = new List<Student_Expertise__c>();        
        for (Id seId : studentExpertiseToUpdateIDSet) {
            Student_Expertise__c seToUpdate = new Student_Expertise__c();
            seToUpdate.Id = seId;
            seToUpdate.Is_Pre_Req_Lock__c = true;
            studentExpertiseToUpdateList.add(seToUpdate);
        }
        
        if (!sePreRequisiteRuleList.isEmpty()) {
            insert sePreRequisiteRuleList;
        }
        
        if (!studentExpertiseToUpdateList.isEmpty()) {
            update studentExpertiseToUpdateList;
        }
        
        // S-25237 - End

        // update Opportunity's Student Program field
        List<Opportunity>updatedOpportunity = new List<Opportunity>();
        for (ID optyID : mapOpportunityWithStudentprogram.keySet()) {
            updatedOpportunity.add(new Opportunity(ID = optyID, Student_Program__c = mapOpportunityWithStudentprogram.get(optyID).ID, Change_of_Program__c = mapOpportunityWithStudentprogram.get(optyID).Change_of_Program__c, COP_Related_Opportunity__c = mapOpportunityWithStudentprogram.get(optyID).COP_Related_Opportunity__c));
        }
        if (!updatedOpportunity.isEmpty()) {
            update updatedOpportunity;
        }
        System.debug('Update Opps :: ' + updatedOpportunity);
        List<Opportunity> copOpps = new List<Opportunity>();
        for (Opportunity opp : updatedOpportunity) {
            if (opp.Change_of_Program__c == true && opp.Student_Program__c != null) {
                copOpps.add(opp);
            }
        }
        if (!copOpps.isEmpty()) {
            ProgramReconciliation reconciliation = new ProgramReconciliation();
            reconciliation.reconcileCOPNonTbybComps(copOpps);
        }
    }

    public Student_Program__c createStudentProgram(Opportunity opty) {
        Student_Program__c newSProgram = new Student_Program__c();
        newSProgram.Application__c = opty.ID;
        newSProgram.Student__c = opty.Contact__c;
        newSProgram.Program__c = opty.Primary_Program__c;
        newSProgram.Brand_Profile__c = opty.Brand_Profile__c;
        newSProgram.Program_Start_Date__c = opty.Program_Start_Date__c;
        newSProgram.Change_of_Program__c = opty.Change_of_Program__c;
        newSProgram.COP_Related_Opportunity__c = opty.COP_Related_Opportunity__c;
        newSProgram.Student_Type__c = (opty.Student_Type__c != null) ? opty.Student_Type__c : null;

        return newSProgram;
    }

    public Student_Expertise__c createStudentExpertise(Student_Program__c sProgram, Program_Expertise__c pExpertise) {
        // Student_Program__c, Student_Name__c, Program_Expertise__c, Opportunity__c, Id, Contact__c, Area_of_Expertise__c                                      
        Student_Expertise__c newSExper = new Student_Expertise__c();
        newSExper.Student_Program__c = sProgram.ID;
        newSExper.Contact__c = sProgram.Student__c;
        newSExper.Opportunity__c = sProgram.Application__c;
        newSExper.Area_of_Expertise__c = pExpertise.Area_of_Expertise__c;
        newSExper.Program_Expertise__c = pExpertise.ID;
        newSExper.Is_Not_Available_for_Student__c = pExpertise.Is_Not_Available_for_Student__c;
        newSExper.Is_Pre_Req_Lock__c = pExpertise.Is_Pre_Req_Lock__c;
        return newSExper;
    }

    public Student_Competency__c createStudentCompetency(Student_Program__c sProgram, Program_Competency__c pCompetency) {
        // Student_Program__c, Student_Name__c, Program_Expertise__c, Opportunity__c, Id, Contact__c, Area_of_Expertise__c                                      
        Student_Competency__c newSCompetency = new Student_Competency__c();
        newSCompetency.Student_Program__c = sProgram.ID;
        newSCompetency.Contact__c = sProgram.Student__c;
        newSCompetency.Opportunity__c = sProgram.Application__c;
        newSCompetency.Competency__c = pCompetency.Competency__c;
        newSCompetency.Program_Competency__c = pCompetency.ID;
        newSCompetency.Status__c = 'Registered';
        newSCompetency.Learning_Order__c = pCompetency.Learning_Order__c;
        return newSCompetency;
    }

    /***********************************************************************************************************************
    Method to Populate list price on Opp
    Related task: T-324811
    Created By: vinod (Appirio)
    ***********************************************************************************************************************/
    public void populateListPriceOnOpp(list<Opportunity> selectedOpprtunity) {
        System.debug('In populateListPriceOnOpp');
        for (Opportunity opty : selectedOpprtunity) {
            if (opty.Primary_Program__c != null && opty.Initial_Price_Book__c == null) {
                populateInitialPriceBook(selectedOpprtunity);
            }
        }
        // get all the price book enetry for the selected price book
        // if found more then one then we will use first one
        set<ID> priceBookIDs = new set<ID>();
        set<ID> productIDs = new set<ID>();
        for (Opportunity opty : selectedOpprtunity) {
            if (opty.Primary_Program__c != null && opty.Initial_Price_Book__c != null) {
                if (opty.Parent_Program__c != null) {
                    productIDs.add(opty.Parent_Program__c);
                } else {
                    productIDs.add(opty.Primary_Program__c);
                }
                priceBookIDs.add(opty.Initial_Price_Book__c);
            }
        }

        map<string, PricebookEntry>mapPriceBookAndProductWithPriceBookEnter = new map<string, PricebookEntry>();
        for (PricebookEntry pbEntry : [
                Select UnitPrice, Product2Id, Pricebook2Id, Id
                From PricebookEntry
                where Pricebook2Id in:priceBookIDs
                and Product2Id in:productIDs
                and IsActive = TRUE
        ]) { //(Available_for_Existing_Students__c = true
            //OR IsActive = TRUE) ] ){
            string strKey = pbEntry.Pricebook2Id + '$' + pbEntry.Product2Id;
            system.debug('strkey :::: ' + strKey);
            if (!mapPriceBookAndProductWithPriceBookEnter.containsKey(strKey)) {
                mapPriceBookAndProductWithPriceBookEnter.put(strKey, pbEntry);
            }
            System.debug('mapPriceBookandProductWithPriceBookEntry :::: ' + mapPriceBookAndProductWithPriceBookEnter);
        }

        if (!mapPriceBookAndProductWithPriceBookEnter.isEmpty()) {
            // populate the opportunity amount from the related price book entery
            for (Opportunity opty : selectedOpprtunity) {
                string strKey = '';
                if (opty.Parent_Program__c != null) {
                    strKey = opty.Initial_Price_Book__c + '$' + opty.Parent_Program__c;
                } else {
                    strKey = opty.Initial_Price_Book__c + '$' + opty.Primary_Program__c;
                }
                system.debug('debug:::::::::' + strKey);
                if (mapPriceBookAndProductWithPriceBookEnter.containsKey(strKey)) {
                    // populate the opprtunity amount
                    opty.Amount = mapPriceBookAndProductWithPriceBookEnter.get(strKey).UnitPrice;
                }
            }
        }
    }

    public void populateInitialPriceBook(list<Opportunity> selectedOpprtunity) {
        set<ID> productIDs = new set<ID>();
        for (Opportunity opty : selectedOpprtunity) {
            if (opty.Parent_Program__c != null) {
                productIDs.add(opty.Parent_Program__c);
                System.debug('Parent Program ::: ' + opty.Parent_Program__c);
            } else {
                productIDs.add(opty.Primary_Program__c);
            }
        }
        map<Id, Id>mapProduct2Id_Pricebook2Id = new map<Id, Id>();
        for (PricebookEntry pbEntry : [
                Select Product2Id, Pricebook2Id
                From PricebookEntry
                where Product2Id in:productIDs
                and IsActive = TRUE
        ]) {
            if (!mapProduct2Id_Pricebook2Id.containsKey(pbEntry.Product2Id)) {
                mapProduct2Id_Pricebook2Id.put(pbEntry.Product2Id, pbEntry.Pricebook2Id);
            }
        }
        if (!mapProduct2Id_Pricebook2Id.isEmpty()) {
            // populate the inital Pricebook
            for (Opportunity opty : selectedOpprtunity) {
                if (mapProduct2Id_Pricebook2Id.containsKey(opty.Primary_Program__c)) {
                    opty.Initial_Price_Book__c = mapProduct2Id_Pricebook2Id.get(opty.Primary_Program__c);
                } else if (mapProduct2Id_Pricebook2Id.containsKey(opty.Parent_Program__c)) {
                    opty.Initial_Price_Book__c = mapProduct2Id_Pricebook2Id.get(opty.Parent_Program__c);
                }
            }
        }
    }


}