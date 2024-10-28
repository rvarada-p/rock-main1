/*******************************************************************
Name  		: ProgramCreator
Author		: Horacio - Laureate
Date 		: Feb 16, 2020
Description	: This Apex class handles the logic to run the 
			  program setup script from app
*************************************************************************/
public class ProgramCreator {
    
    private static List<String> separateCommas(String input){
        List<String> results = input.split(',');
        for(String result : results) {
            result = result.trim();
        }
        return results;
    }
    
    
    @AuraEnabled
    public static CSVObject getCSVObject(String csv_str) {
        Savepoint sp = Database.setSavepoint();
        try {
            List<String> lines_raw = csv_str.split('\n');
            List<String> headers_raw = separateCommas(lines_raw[0]);
            List<List<String>> lines = new List<List<String>>();
            List<CSVHeader> headers = new List<CSVHeader>();
            lines_raw.remove(0);
            Map<String, Program> programCodeProgramMap = new Map<String, Program>();
            List<Product2> programList = new List<Product2>();
            List<ProgramCategoryRequirement> programCategoryRequirementsList = new List<ProgramCategoryRequirement>();            
            
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
                        compositeField +=  ',' + field;
                    } else {
                        fields.add(field.trim());
                    }
                }
                
                lines.add(fields);
            }
            
            for (List<String> line : lines) {
                if (!programCodeProgramMap.containsKey(line[1])) {
                    Program prog = new Program();
                    prog.parentProgramCode = line[0];
                    prog.programCode = line[1];
                    prog.programName = line[2];
                    prog.outcome = line[3];
                    prog.programMajor = line[4];
                    prog.degreeLevel = line[5];
                    prog.specialization = line[6];
                    prog.institution = line[7];
                    prog.creditType = line[8];
                    if (line[9] != null && line[9] != '') {
                        prog.totalCreditsInProgram = Decimal.valueOf(line[9]);
                    } else {
                        prog.totalCreditsInProgram = null;
                    }
                    if (line[10] != null && line[10] != '') {
                        prog.creditProgressionRate = Decimal.valueOf(line[10]);
                    } else {
                        prog.creditProgressionRate = null;
                    }
                    if (line[11] != null && line[11] != '') {
                        prog.maximumTransferCredits = Integer.valueOf(line[11]);
                    } else {
                        prog.maximumTransferCredits = null;
                    }
                    if (line[12] != null && line[12] != '') {
                    	prog.requiredTransferCredits = Integer.valueOf(line[12]);    
                    } else {
                        prog.requiredTransferCredits = null;
                    }                    
                    if (line[13] != null && line[13] != '') {
                        prog.requiredUpperLevelCredits = Decimal.valueOf(line[13]);
                    } else {
                        prog.requiredUpperLevelCredits = null;
                    }
                    if (line[14] != null && line[14] != '') {
                        prog.requiredInstitutionCredits = Decimal.valueOf(line[14]);
                    } else {
                        prog.requiredInstitutionCredits = null;
                    }
                    programCodeProgramMap.put(line[1], prog);
                }
                
                // Build Program Requirement
                try {
                	ProgramCategoryRequirement categoryRequirement = new ProgramCategoryRequirement();
                    categoryRequirement.category = line[15];
                    categoryRequirement.level = line[16];
                    if (line[17] != null && line[17] != '') {
                        categoryRequirement.totalCE = Decimal.valueOf(line[17]);
                    } else {
                        categoryRequirement.totalCE = null;
                    }
                    categoryRequirement.subjectAreaExpertise = line[18];
                    categoryRequirement.programCode = line[1];
                    programCategoryRequirementsList.add(categoryRequirement);    
                } catch (Exception e) {
                    Database.rollback(sp);
                    System.debug('Error: ' + e.getLineNumber() + ', ' + e.getMessage());
                }
            }
        
            Set<String> parentProgramCodeSet = new Set<String>();
            Map<String, Id> parentProgramCodeAndIdMap = new Map<String, Id>();
            for (String key : programCodeProgramMap.keySet()) {
                parentProgramCodeSet.add(programCodeProgramMap.get(key).parentProgramCode);
            }            
            
            List<Product2> parentProgramList = [SELECT Id, Name, productCode FROM Product2 WHERE productCode IN :parentProgramCodeSet];
            List<Institution__c> institutionList = [SELECT id, name from Institution__c where name = 'Walden' LIMIT 1];
            for (Product2 prog : parentProgramList) {
                if (!parentProgramCodeAndIdMap.containsKey(prog.ProductCode)) {
                    parentProgramCodeAndIdMap.put(prog.productCode, prog.Id);
                }
            }
            
            // Creating Programs
            for (String key : programCodeProgramMap.keySet()) {
                Product2 prod = new Product2();
                prod.Parent_Program__c = parentProgramCodeAndIdMap.get(programCodeProgramMap.get(key).parentProgramCode);
                prod.ProductCode = programCodeProgramMap.get(key).programCode;
                prod.Name = programCodeProgramMap.get(key).programName;
                prod.Display_Name__c = programCodeProgramMap.get(key).programName; // not from file
                prod.Outcome__c = programCodeProgramMap.get(key).outcome;
                prod.Program_Major__c = programCodeProgramMap.get(key).programMajor;
                prod.Degree_Level__c = programCodeProgramMap.get(key).degreeLevel;
                prod.Specialization__c = programCodeProgramMap.get(key).specialization;
                prod.Institution__c = institutionList[0].id;
                prod.Credit_Type__c = programCodeProgramMap.get(key).creditType;
                prod.Total_Credits_in_Program__c = programCodeProgramMap.get(key).totalCreditsInProgram;
                prod.Credit_Progression_Rate__c = programCodeProgramMap.get(key).creditProgressionRate;
                prod.Maximum_Transfer_Credits__c = programCodeProgramMap.get(key).maximumTransferCredits;
                prod.Required_Upper_Level_Credits__c = programCodeProgramMap.get(key).requiredUpperLevelCredits;
                prod.Required_Institution_Credits__c = programCodeProgramMap.get(key).requiredInstitutionCredits;
                prod.Required_Transfer_Credits__c = programCodeProgramMap.get(key).requiredTransferCredits;
                prod.Effective_From_Date__c = Date.today(); // not from file
                prod.Effective_To_Date__c = Date.today().addYears(5); //not from file
                prod.Family = 'CBL'; // Not from file
                prod.Publish_to_LMS__c = true; // Not from file
                programList.add(prod);
            }
            
            if (!programList.isEmpty()) {
                insert programList;
            }
            
            // Getting program Ids and associating it with program Code; creating Program Version objects
            Map<String, String> programCodeProgramIdMap = new Map<String, String>();
            List<Program_Version__c> programVersionList = new List<Program_Version__c>();
            for (Product2 prog : programList) {
                if (!programCodeProgramIdMap.containsKey(prog.ProductCode)) {
                    programCodeProgramIdMap.put(prog.ProductCode, prog.Id);
                }
                Program_Version__c programVersion = new Program_Version__c();
                programVersion.Program_Lookup__c = prog.Id;
                programVersion.Active__c = true;
                programVersion.Apply_to_New_Students__c = true;
                programVersion.Credit_Progression_Rate__c = prog.Credit_Progression_Rate__c;
                programVersion.Total_Credits_in_Program__c = prog.Total_Credits_in_Program__c;
                programVersion.Version_Effective_Date__c = Date.today();
                programVersionList.add(programVersion);
            }
            
            List<Program_Category_Requirement__c> pcrList = new List<Program_Category_Requirement__c>();
            for (ProgramCategoryRequirement categoryRequirement : programCategoryRequirementsList) {
                Program_Category_Requirement__c pcr = new Program_Category_Requirement__c();
                pcr.Category__c = categoryRequirement.category;
                pcr.Level__c = categoryRequirement.level;
                pcr.Program__c = programCodeProgramIdMap.get(categoryRequirement.programCode);
                pcr.Subject_Area_Expertise__c = categoryRequirement.subjectAreaExpertise;
                pcr.Total_CE__c = categoryRequirement.totalCE;
                pcrList.add(pcr);
            }
            
            if (!programVersionList.isEmpty()) {
                insert programVersionList;
            }
            
            if (!pcrList.isEmpty()) {
                insert pcrList;
            }
            
            return new CSVObject(headers, lines);
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug('Error: ' + e.getMessage() + ', +++ ' + e.getCause() + ', ++++ ' + e.getLineNumber());
            throw new AuraHandledException('Error: ' + e.getMessage() + ', +++ ' + e.getCause() + ', ++++ ' + e.getLineNumber());
        }
        
        //return null;
    }
    
    public class Program {
        String parentProgramCode;
        String programCode;
        String programName;
        String outcome;
        String programMajor;
        String degreeLevel;
        String specialization;
        String institution;
        String creditType;
        Decimal totalCreditsInProgram;
        Decimal creditProgressionRate;
        Integer maximumTransferCredits;
        Integer requiredTransferCredits;
        Decimal requiredUpperLevelCredits;
        Decimal requiredInstitutionCredits;
            
        public Program() {
            
        }
    }

    public class ProgramCategoryRequirement {
        String category;
        String level;
        String programCode;
        String subjectAreaExpertise;
        Decimal totalCE;
        
        public ProgramCategoryRequirement() {
            
        }
    }

}