/*******************************************************************
Name        : SMEAssignmentGroupCreator
Author      : Horacio - Laureate
Date        : Feb 16, 2020
Description : This Apex class handles the logic to run the
              SME Assignment Grup, Group Members and Sections setup script from app
*************************************************************************
Revision History

Ravitej Varada : Change the SME cohort logic when creating the Assignment group based on the Program.
*************************************************************************/

public with sharing class SMEAssignmentGroupCreator {

    private static List<String> separateCommas(String input) {
        List<String> results = input.split(',');
        for (String result : results) {
            result = result.trim();
        }
        return results;
    }

    @AuraEnabled
    public static CSVObject getCSVObject(String csv_str) {
        system.debug('0000000000000' + csv_str);
        Savepoint sp = Database.setSavepoint();
        try {
            List<String> lines_raw = csv_str.split('\n');
            List<String> headers_raw = separateCommas(lines_raw[0]);
            List<List<String>> lines = new List<List<String>>();
            List<CSVHeader> headers = new List<CSVHeader>();
            lines_raw.remove(0);

            for (String line : lines_raw) {
                List<String> line_sep = separateCommas(line);
                List<String> fields = new List<String>();
                Boolean makeCompositeField = false;
                String compositeField;
                for (String field : line_sep) {
                    if (field.startsWith('"') && field.endsWith('"')) {
                        fields.add(field.trim());
                    } else if (field.startsWith('"')) {
                        makeCompositeField = true;
                        compositeField = field;
                    } else if (field.endsWith('"')) {
                        compositeField += ',' + field;
                        fields.add(compositeField.trim());
                        makeCompositeField = false;
                    } else if (makeCompositeField) {
                        compositeField += ',' + field;
                    } else {
                        fields.add(field.trim());
                    }
                }

                lines.add(fields);
            }


            set<String> licenseType = new set<String>{
                    'Non-Cohort', 'Compact', 'Alaska', 'Massachusetts', 'Minnesota', 'Washington'
            };

            Map<string, string> compCodeWithStatusMap = new Map<String, String>();
            Map<string, string> assignGroupNameWithCohortRequiredMap = new Map<String, String>();
            Map<string, set<string>> assgNamewithSmeSet = new Map<String, set<string>>();
            Set<string> compCodeSet = new set<String>();
            Set<string> assignGroupName = new set<String>();
            Set<string> emailOnlySet = new set<String>();
            Map<String, string > competencyCodeLineTemplateMap = new Map<String, string>();
            for (List<String> line : lines) {

                compCodeWithStatusMap.put(line[0], Line[3]);
                assignGroupNameWithCohortRequiredMap.put(line[2], Line[6]);
                compCodeSet.add(line[0]);
                assignGroupName.add(line[2]);
                emailOnlySet.add(line[1]);

                if (!assgNamewithSmeSet.containsKey(line[2])) {
                    assgNamewithSmeSet.put(Line[2], new Set<String>{
                            Line[1]
                    });
                } else {
                    assgNamewithSmeSet.get(Line[2]).add(Line[1]);
                }
                if (!competencyCodeLineTemplateMap.containsKey(line[2] + line[1])) {
                    competencyCodeLineTemplateMap.put(line[0], line[5]);
                }
            }

            System.debug('*****' + compCodeWithStatusMap);
            System.debug('*****' + assignGroupNameWithCohortRequiredMap);
            System.debug('*****' + compCodeSet);
            System.debug('*****' + assignGroupName);
            //System.debug('*****'+compCodeWithStatusMap);
            List<Assignment_Group_CST__c> assignmentGroupList = new List<Assignment_Group_CST__c>();

            //Assignment Group Check if exists or create.
            List<Competency__c> compList = new List<Competency__c>();
            List<Assignment_Group_CST__c> assignmentGroupNotExistsList = new List<Assignment_Group_CST__c>();
            compList = [SELECT Name,Assignment_Group_CST__c,Assignment_Group_CST__r.Name, Code__c FROM Competency__c WHERE Code__c IN :compCodeSet];
            System.debug('*****' + compList);

            For (Competency__c comp : compList) {
                if (comp.Assignment_Group_CST__c == Null) {
                    Assignment_Group_CST__c assignmentGroup = new Assignment_Group_CST__c();
                    assignmentGroup.name = comp.Code__c + ' SME Group';
                    assignmentGroup.Status__c = compCodeWithStatusMap.get(comp.Code__c);
                    assignmentGroupNotExistsList.add(assignmentGroup);
                    assignmentGroupList.add(assignmentGroup);
                } else {
                    //assignmentGroupExistsList.add(comp.Assignment_Group_CST__c);
                }
            }
            System.debug('*****' + assignmentGroupNotExistsList);

            if (!assignmentGroupNotExistsList.isEmpty()) {
                Insert assignmentGroupNotExistsList;
            }

            // Update  Competency with Assignment Group CST lookup
            For (Competency__c comp : compList) {
                if (comp.Assignment_Group_CST__c == Null) {
                    For (Assignment_Group_CST__c assignmentGroupCST : assignmentGroupList) {
                        if (assignmentGroupCST.Name == comp.Code__c + ' SME Group') {
                            comp.Assignment_Group_CST__c = assignmentGroupCST.id;
                        }
                    }
                }
            }
            If (!compList.isEmpty()) {
                Update compList;
            }


            //SME Cohort Group Check if exists or create.
            set<String> smeGroupExistsSet = new set<string>();
            List<Assignment_Group_CST__c> assignmentGroupCSTLst = new List<Assignment_Group_CST__c>();
            assignmentGroupCSTLst = [SELECT Id,Name, (SELECT Id,SME_Assignment_Group__r.Name,License_Type__c, State__c,Name FROM SME_Cohorts__r) FROM Assignment_Group_CST__c WHERE Name In:assignGroupName];
            List<SME_Cohort__c> smeCoList = new List<SME_Cohort__c>();
            For (Assignment_Group_CST__c agGrp : assignmentGroupCSTLst) {
                If (assignGroupNameWithCohortRequiredMap.get(agGrp.Name) == 'Yes') {
                    if (agGrp.SME_Cohorts__r.size() == 0) {
                        for (string Type : licenseType) {
                            SME_Cohort__c smeCo = new SME_Cohort__c();
                            If (Type == 'Compact' || Type == 'Non-Cohort') {
                                smeCo.License_Type__c = Type;
                            } else {
                                smeCo.License_Type__c = 'Single State';
                                smeCo.State__c = type;
                            }
                            smeCo.SME_Assignment_Group__c = agGrp.id;
                            smeCoList.add(smeCo);
                        }
                    } else {
                        For (SME_Cohort__c smeCohort : agGrp.SME_Cohorts__r) {
                            If (smeCohort.License_Type__c == 'Compact' || smeCohort.License_Type__c == 'Non-Cohort') {
                                smeGroupExistsSet.add(smeCohort.License_Type__c);
                            } else {
                                smeGroupExistsSet.add(smeCohort.State__c);
                            }
                        }
                        if (smeGroupExistsSet != null) {
                            for (string Type : licenseType) {
                                SME_Cohort__c smeCo = new SME_Cohort__c();
                                if (!smeGroupExistsSet.contains(Type)) {
                                    If (Type == 'Compact' || Type == 'Non-Cohort') {
                                        smeCo.License_Type__c = Type;
                                    } else {
                                        smeCo.License_Type__c = 'Single State';
                                        smeCo.State__c = type;
                                    }
                                    smeCo.SME_Assignment_Group__c = agGrp.id;
                                    smeCoList.add(smeCo);
                                }
                            }
                        }
                    }
                } else {
                    if (agGrp.SME_Cohorts__r.size() == 0) {
                        SME_Cohort__c smeCo = new SME_Cohort__c();
                        smeCo.License_Type__c = 'Non-Cohort' ;
                        smeCo.SME_Assignment_Group__c = agGrp.id;
                        smeCoList.add(smeCo);
                    }
                }
            }
            If (!smeCoList.isEmpty()) {
                insert smeCoList;
            }

            // USER with Sme Email and Uid
            Map<String, Id> emailUserIdMap = new Map<String, Id>();
            Map<String, string> emailUserLicenseTypeMap = new Map<String, string>();
            for (User u : [SELECT Id,SME_Cohort_License_Type__c, Email, Name FROM User where email in :emailOnlySet]) {
                if (!emailUserIdMap.containsKey(u.email)) {
                    emailUserIdMap.put(u.email, u.id);
                    if(u.SME_Cohort_License_Type__c != null) {
                        emailUserLicenseTypeMap.put(u.email, u.SME_Cohort_License_Type__c);
                    }
                }
            }

            Map<String, set<string>> asgGroupNameAndTypeWithSetOfSME = new Map<String, set<string>>();
            Map<String, id> asgGroupNameSMECohortIdMap = new Map<String, id> ();
            List<SME_Cohort__c> smeCohortLst = new List<SME_Cohort__c>();
            smeCohortLst = [SELECT Id, SME_Assignment_Group__r.Name, (SElect id, User__r.Email FROM Group_Members_CST__r), License_Type__c, State__c, Name FROM SME_Cohort__c WHERE SME_Assignment_Group__r.Name IN :assignGroupName];
            For (SME_Cohort__c smeCo : smeCohortLst) {
                If (!smeCo.Group_Members_CST__r.isEmpty()) {
                    for (Customer_Support_Team__c cst : smeCo.Group_Members_CST__r) {
                        If (smeCo.License_Type__c == 'Compact' || smeCo.License_Type__c == 'Non-Cohort') {
                            if (!asgGroupNameAndTypeWithSetOfSME.containsKey(smeCo.SME_Assignment_Group__r.Name + smeCo.License_Type__c)) {
                                asgGroupNameAndTypeWithSetOfSME.put(smeCo.SME_Assignment_Group__r.Name + smeCo.License_Type__c, new Set<String>{
                                        cst.User__r.Email
                                });
                            } else {
                                asgGroupNameAndTypeWithSetOfSME.get(smeCo.SME_Assignment_Group__r.Name + smeCo.License_Type__c).add(cst.User__r.Email);
                            }
                            asgGroupNameSMECohortIdMap.put(smeCo.SME_Assignment_Group__r.Name + smeCo.License_Type__c, smeCo.id);
                        } else {
                            if (!asgGroupNameAndTypeWithSetOfSME.containsKey(smeCo.SME_Assignment_Group__r.Name + smeCo.State__c)) {
                                asgGroupNameAndTypeWithSetOfSME.put(smeCo.SME_Assignment_Group__r.Name + smeCo.State__c, new Set<String>{
                                        cst.User__r.Email
                                });
                            } else {
                                asgGroupNameAndTypeWithSetOfSME.get(smeCo.SME_Assignment_Group__r.Name + smeCo.State__c).add(cst.User__r.Email);
                            }
                        }
                    }
                } else {
                    If (smeCo.License_Type__c == 'Compact' || smeCo.License_Type__c == 'Non-Cohort') {

                        asgGroupNameAndTypeWithSetOfSME.put(smeCo.SME_Assignment_Group__r.Name + smeCo.License_Type__c, new Set<String>{
                        });
                    } else {
                        asgGroupNameAndTypeWithSetOfSME.put(smeCo.SME_Assignment_Group__r.Name + smeCo.State__c, new Set<String>{
                        });
                    }

                }
                If (smeCo.License_Type__c == 'Compact' || smeCo.License_Type__c == 'Non-Cohort') {
                    asgGroupNameSMECohortIdMap.put(smeCo.SME_Assignment_Group__r.Name + smeCo.License_Type__c, smeCo.id);

                } else {
                    asgGroupNameSMECohortIdMap.put(smeCo.SME_Assignment_Group__r.Name + smeCo.State__c, smeCo.id);

                }

            }
            System.debug(asgGroupNameAndTypeWithSetOfSME);
            System.debug(asgGroupNameSMECohortIdMap);


            //Check If SME exists else create Group Member CST record
            List<Customer_Support_Team__c> customerSupportTeamLst = new List<Customer_Support_Team__c>();
            assignmentGroupCSTLst = [SELECT Id,Name, (SELECT Id,SME_Assignment_Group__r.Name,License_Type__c, State__c,Name FROM SME_Cohorts__r) FROM Assignment_Group_CST__c WHERE Name In:assignGroupName];


            List<Sections__c> sectionList = new List<Sections__c>();
            List<Customer_Support_Team__c> groupMemberList = new List<Customer_Support_Team__c>();
            map<string, set<id>> groupCSTNameWithSME = new map<string, set<id>>();
            For (Assignment_Group_CST__c groupCST : assignmentGroupCSTLst) {
                system.debug('groupCST' + groupCST);

                For (String sme : assgNamewithSmeSet.get(groupCST.Name)) {
                    List<String> smeLicenseTypeLst = new List<String>();
                    string smeLicenseTypeString = '';

                    If(emailUserLicenseTypeMap.containsKey(sme)) {
                        smeLicenseTypeString = emailUserLicenseTypeMap.get(sme).replace(';', ',');
                        smeLicenseTypeLst = smeLicenseTypeString.split(',');
                    }
                    system.debug(smeLicenseTypeLst.size());
                    if(!smeLicenseTypeLst.isEmpty()){
                        for (String type : smeLicenseTypeLst) {

                            system.debug('type' + type);
                            system.debug('sme' + sme);
                            system.debug(asgGroupNameAndTypeWithSetOfSME.get(groupCST.Name + type));
                            //system.debug(asgGroupNameAndTypeWithSetOfSME.get(groupCST.Name+type).contains(sme));
                            system.debug(asgGroupNameAndTypeWithSetOfSME.containsKey(groupCST.Name + type));
                            If (asgGroupNameAndTypeWithSetOfSME.containsKey(groupCST.Name + type) && !asgGroupNameAndTypeWithSetOfSME.get(groupCST.Name + type).contains(sme)) {
                                Customer_Support_Team__c groupMember = new Customer_Support_Team__c();
                                system.debug(asgGroupNameSMECohortIdMap.get(groupCST.Name + type));
                                system.debug(groupCST.Name + type);

                                groupMember.SME_Cohort_Group__c = asgGroupNameSMECohortIdMap.get(groupCST.Name + type);
                                groupMember.User__c = emailUserIdMap.get(sme);
                                groupMember.Split_Weight__c = 100;
                                groupMember.Status__c = 'Active';
                                groupMemberList.add(groupMember);
                                if (!groupCSTNameWithSME.containsKey(groupCST.Name)) {
                                    groupCSTNameWithSME.put(groupCST.Name, new Set<id>{
                                            emailUserIdMap.get(sme)
                                    });
                                } else {
                                    groupCSTNameWithSME.get(groupCST.Name).add(emailUserIdMap.get(sme));
                                }
                            }
                        }
                }
                }
            }


            //Check Sections if exists and Create Sections for new SME's
            for (Competency__c competency : [SELECT id, Assignment_Group_CST__c,Assignment_Group_CST__r.Name, code__c, (Select id,name,SME__r.Email,SME_Name__c,SME__c FROM Sections__r) FROM Competency__c WHERE Code__c in :compCodeSet]) {
                system.debug(competency.Code__c);
                set<id> sectionSMEidSet = new set<id>();
                if (!competency.Sections__r.isEmpty()) {

                    for (Sections__c sec : competency.Sections__r) {
                        sectionSMEidSet.add(sec.SME__c);
                    }

                }

                if (groupCSTNameWithSME.containsKey(competency.Assignment_Group_CST__r.Name)) {
                    for (id userId : groupCSTNameWithSME.get(competency.Assignment_Group_CST__r.Name)) {

                       if(!sectionSMEidSet.contains(userId)) {
                           Sections__c section = new Sections__c();
                           section.competency__c = competency.id;
                           section.SME__c = userId;
                           if (competencyCodeLineTemplateMap.get(competency.code__c) == '1') {
                               section.Current_Section__c = true;
                           } else {
                               section.Current_Section__c = false;
                           }
                           sectionList.add(section);

                       }
                    }
                }
            }

            if (!groupMemberList.isEmpty()) {
                insert groupMemberList;
            }
            if (!sectionList.isEmpty()) {
                insert sectionList;
            }
            //Split Logic
            groupCstSmeSplit(assignGroupName, assignGroupNameWithCohortRequiredMap);
            return new CSVObject(headers, lines);

        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('Error: ' + e.getMessage() + ', +++ ' + e.getCause() + ', ++++ ' + e.getLineNumber());
            throw new AuraHandledException('Error: ' + e.getMessage() + ', +++ ' + e.getCause() + ', ++++ ' + e.getLineNumber());
        }
    }

    //Split Logic method
    public static void groupCstSmeSplit(set<string> assignGroupName, map<string, string> assignGroupNameWithCohortRequiredMap) {


        System.debug('$$$$$$$$$$$$$' + assignGroupName);
        List<Assignment_Group_CST__c> assignmentGroupCSTSLst = new List<Assignment_Group_CST__c>();
        assignmentGroupCSTSLst = [SELECT Id,Name, (SELECT Id,SME_Assignment_Group__r.Name, License_Type__c, State__c,Name FROM SME_Cohorts__r) FROM Assignment_Group_CST__c WHERE Name In:assignGroupName];
        List<SME_Cohort__c> smeCoList = new List<SME_Cohort__c>();

        Map<String, set<string>> asgGroupNameAndTypeWithSetOfSME = new Map<String, set<string>>();
        Map<String, set<Customer_Support_Team__c>> asgGroupNameAndTypeWithGroupMemCSTMap = new Map<String, set<Customer_Support_Team__c>>();
        Map<String, id> asgGroupNameSMECohortIdMap = new Map<String, id> ();
        List<SME_Cohort__c> smeCohortLst = new List<SME_Cohort__c>();
        smeCohortLst = [SELECT Id, SME_Assignment_Group__r.Name, (SElect id, User__r.Email,Split_Weight__c,User__r.SME_Cohort_License_Type__c FROM Group_Members_CST__r), License_Type__c, State__c, Name FROM SME_Cohort__c WHERE SME_Assignment_Group__r.Name IN :assignGroupName];
        For (SME_Cohort__c smeCo : smeCohortLst) {
            If (!smeCo.Group_Members_CST__r.isEmpty()) {
                for (Customer_Support_Team__c cst : smeCo.Group_Members_CST__r) {
                    If (smeCo.License_Type__c == 'Compact' || smeCo.License_Type__c == 'Non-Cohort') {
                        if (!asgGroupNameAndTypeWithSetOfSME.containsKey(smeCo.SME_Assignment_Group__r.Name + smeCo.License_Type__c)) {
                            asgGroupNameAndTypeWithGroupMemCSTMap.put(smeCo.SME_Assignment_Group__r.Name + smeCo.License_Type__c, new Set<Customer_Support_Team__c>{
                                    cst
                            });
                            asgGroupNameAndTypeWithSetOfSME.put(smeCo.SME_Assignment_Group__r.Name + smeCo.License_Type__c, new Set<String>{
                                    cst.User__r.Email
                            });
                        } else {

                            asgGroupNameAndTypeWithGroupMemCSTMap.get(smeCo.SME_Assignment_Group__r.Name + smeCo.License_Type__c).add(cst);

                            asgGroupNameAndTypeWithSetOfSME.get(smeCo.SME_Assignment_Group__r.Name + smeCo.License_Type__c).add(cst.User__r.Email);
                        }
                        asgGroupNameSMECohortIdMap.put(smeCo.SME_Assignment_Group__r.Name + smeCo.License_Type__c, smeCo.id);
                    } else {
                        if (!asgGroupNameAndTypeWithSetOfSME.containsKey(smeCo.SME_Assignment_Group__r.Name + smeCo.State__c)) {
                            asgGroupNameAndTypeWithSetOfSME.put(smeCo.SME_Assignment_Group__r.Name + smeCo.State__c, new Set<String>{
                                    cst.User__r.Email
                            });
                            asgGroupNameAndTypeWithGroupMemCSTMap.put(smeCo.SME_Assignment_Group__r.Name + smeCo.State__c, new Set<Customer_Support_Team__c>{
                                    cst
                            });
                        } else {
                            asgGroupNameAndTypeWithSetOfSME.get(smeCo.SME_Assignment_Group__r.Name + smeCo.State__c).add(cst.User__r.Email);
                            asgGroupNameAndTypeWithGroupMemCSTMap.get(smeCo.SME_Assignment_Group__r.Name + smeCo.State__c).add(cst);
                        }
                    }
                }
            } else {
                If (smeCo.License_Type__c == 'Compact' || smeCo.License_Type__c == 'Non-Cohort') {

                    asgGroupNameAndTypeWithSetOfSME.put(smeCo.SME_Assignment_Group__r.Name + smeCo.License_Type__c, new Set<String>{
                    });
                } else {
                    asgGroupNameAndTypeWithSetOfSME.put(smeCo.SME_Assignment_Group__r.Name + smeCo.State__c, new Set<String>{
                    });
                }
            }
            If (smeCo.License_Type__c == 'Compact' || smeCo.License_Type__c == 'Non-Cohort') {
                asgGroupNameSMECohortIdMap.put(smeCo.SME_Assignment_Group__r.Name + smeCo.License_Type__c, smeCo.id);

            } else {
                asgGroupNameSMECohortIdMap.put(smeCo.SME_Assignment_Group__r.Name + smeCo.State__c, smeCo.id);
            }

        }
        System.debug(asgGroupNameAndTypeWithSetOfSME);
        List<Customer_Support_Team__c> groupCstLst = new List<Customer_Support_Team__c>();
        For (Assignment_Group_CST__c groupCST : assignmentGroupCSTSLst) {

            system.debug('--------' + groupCST.Name);

            For (SME_Cohort__c smeCohort : groupCST.SME_Cohorts__r) {
                string typeLicense = '';
                if (smeCohort.License_Type__c == 'Compact' || smeCohort.License_Type__c == 'Non-Cohort') {
                    typeLicense = groupCST.Name + smeCohort.License_Type__c;
                } else {
                    typeLicense = groupCST.Name + smeCohort.State__c;
                }
                integer splitPercentage = 0;

                if (smeCohort.License_Type__c == 'Compact') {
                    if (asgGroupNameAndTypeWithGroupMemCSTMap.containsKey(typeLicense)) {

                        splitPercentage = 100 / asgGroupNameAndTypeWithGroupMemCSTMap.get(typeLicense).size();
                        for (Customer_Support_Team__c sme : asgGroupNameAndTypeWithGroupMemCSTMap.get(typeLicense)) {
                            sme.Split_Weight__c = splitPercentage;
                            groupCstLst.add(sme);
                        }
                    }
                } else if (smeCohort.License_Type__c == 'Single State') {
                    if (asgGroupNameAndTypeWithGroupMemCSTMap.containsKey(typeLicense)) {
                        splitPercentage = 100 / asgGroupNameAndTypeWithGroupMemCSTMap.get(typeLicense).size();
                        for (Customer_Support_Team__c sme : asgGroupNameAndTypeWithGroupMemCSTMap.get(typeLicense)) {
                            sme.Split_Weight__c = splitPercentage;
                            groupCstLst.add(sme);
                        }
                    }
                } else if (smeCohort.License_Type__c == 'Non-Cohort') {

                    // NON COHORT LOGIC
                    If (assignGroupNameWithCohortRequiredMap.get(groupCST.Name) == 'Yes') {
                        if (asgGroupNameAndTypeWithGroupMemCSTMap.containsKey(typeLicense)) {
                            Integer splitPercentageNonCohort = 100 / asgGroupNameAndTypeWithGroupMemCSTMap.get(typeLicense).size();
                            Integer splitPercentageCompact = 100 / asgGroupNameAndTypeWithGroupMemCSTMap.get(typeLicense).size();
                            Integer splitPercentageSingleState = 100 / asgGroupNameAndTypeWithGroupMemCSTMap.get(typeLicense).size();
                            List<String> smeLicenseTypeLst = new List<String>();

                            set<Customer_Support_Team__c> splitPercentageNonCohortLst = new set<Customer_Support_Team__c>();
                            set<Customer_Support_Team__c> splitPercentageCompactLst = new set<Customer_Support_Team__c>();
                            set<Customer_Support_Team__c> splitPercentageSingleStateLst = new set<Customer_Support_Team__c>();

                            for (Customer_Support_Team__c sme : asgGroupNameAndTypeWithGroupMemCSTMap.get(typeLicense)) {
                                system.debug('sme.User__r'+sme.User__c);
                                string smeLicenseTypeString = sme.User__r.SME_Cohort_License_Type__c.replace(';', ',');
                                smeLicenseTypeLst = smeLicenseTypeString.split(',');

                                if (smeLicenseTypeLst.size() > 1) {
                                    For (string type : smeLicenseTypeLst) {// Non Cohort, Compact

                                        if (type == 'Compact') {
                                            splitPercentageCompactLst.add(sme);
                                        } else if (type != 'Non-Cohort' && !splitPercentageCompactLst.contains(sme)) {
                                            splitPercentageSingleStateLst.add(sme);
                                        }
                                    }
                                } else if (smeLicenseTypeLst.size() == 1) {
                                    splitPercentageNonCohortLst.add(sme);
                                }
                            }
                            system.debug(splitPercentageCompactLst.size());
                            system.debug(splitPercentageNonCohortLst.size());
                            system.debug(splitPercentageSingleStateLst.size());
                            system.debug(splitPercentageCompactLst);
                            system.debug(splitPercentageNonCohortLst);
                            system.debug(splitPercentageSingleStateLst);

                            Integer sizeOfNonCohort = 0;
                            if (splitPercentageNonCohortLst.size() > 0)
                                sizeOfNonCohort = 40 / (splitPercentageNonCohortLst.size());

                            Integer sizeOfCompact = 0;
                            if (splitPercentageCompactLst.size() > 0)
                                sizeOfCompact = 20 / (splitPercentageCompactLst.size());

                            Integer sizeOfSingleState = 0;
                            if (splitPercentageSingleStateLst.size() > 0)
                                sizeOfSingleState = 40 / (splitPercentageSingleStateLst.size());

                            system.debug(sizeOfNonCohort);
                            system.debug(sizeOfCompact);
                            system.debug(sizeOfSingleState);

                            for (Customer_Support_Team__c sme : asgGroupNameAndTypeWithGroupMemCSTMap.get(typeLicense)) {

                                if (splitPercentageCompactLst.contains(sme)) {
                                    system.debug('compact ' + sme.User__r.Email);

                                    sme.Split_Weight__c = sizeOfCompact;
                                } else if (splitPercentageSingleStateLst.contains(sme) && !splitPercentageCompactLst.contains(sme) && !splitPercentageNonCohortLst.contains(sme)) {
                                    system.debug('Single Styate' + sme.User__r.Email);
                                    sme.Split_Weight__c = sizeOfSingleState;
                                } else {
                                    system.debug('Noncohort' + sme.User__r.Email);
                                    sme.Split_Weight__c = sizeOfNonCohort;
                                }
                                groupCstLst.add(sme);
                            }
                        }
                    } else {

                        if (asgGroupNameAndTypeWithGroupMemCSTMap.containsKey(typeLicense)) {
                            splitPercentage = 100 / asgGroupNameAndTypeWithGroupMemCSTMap.get(typeLicense).size();
                            for (Customer_Support_Team__c sme : asgGroupNameAndTypeWithGroupMemCSTMap.get(typeLicense)) {
                                sme.Split_Weight__c = splitPercentage;
                                groupCstLst.add(sme);
                            }
                        }
                    }
                }
            }
        }

        system.debug(groupCstLst);
        if (!groupCstLst.isEmpty()) {
            update groupCstLst;
        }


    }
}