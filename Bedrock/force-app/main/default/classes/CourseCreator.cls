/*******************************************************************
Name  		: CourseCreator
Author		: Ravitej Varada - Laureate
Date  		: Feb 16, 2020
Description	: This Apex class handles the logic to run the 
			  Course setup script from app
*************************************************************************/
public class CourseCreator  {
    
    //Method to seperate the commas
    private static List<String> separateCommas(String input){
        List<String> results = input.split(',');
        for(String result : results) {
            result = result.trim();
        }
        return results;
    }
    
    
    @AuraEnabled
    public static CSVObject getCSVObject(String csv_str) {
        system.debug('csv_str----'+csv_str);
        Savepoint sp = Database.setSavepoint();
        try{
            List<String> lines_raw = csv_str.split('\n');
            List<String> headers_raw = separateCommas(lines_raw[0]);
            List<List<String>> lines = new List<List<String>>();
            List<CSVHeader> headers = new List<CSVHeader>();
            lines_raw.remove(0);
            
            
            List<Area_Of_Expertise__c> aoeListToInsert = new List<Area_Of_Expertise__c> ();
            List<Competency__c> compListToInsert = new List<Competency__c> ();
             Map<string,string> aoeProgMap = new  Map<string,string> ();//Map Aoe Code with Prog code 
            Map<string,string> compAeoMap = new  Map<string,string> ();//Map Comp Code with AOE code 
            Map<string,string> CompWithProgCodeMap = new  Map<string,string> ();//Map Comp Code with Prog code 
            Set<String>  progCodeSet = new Set<String>();//Set of prog Code
            
            //Loop Each file for UI display
            for(String line : lines_raw) {
                List<String> line_sep = separateCommas(line);
                List<String> fields = new List<String>();
                Boolean makeCompositeField = false;
                String compositeField;
                for(String field : line_sep) {
                    if (field.startsWith('"') && field.endsWith('"')) {
                        fields.add(field.trim().replace('"',''));
                    } else if (field.startsWith('"')) {
                        makeCompositeField = true;
                        compositeField = field;
                    } else if (field.endsWith('"')) {
                        compositeField += ',' + field;
                        fields.add(compositeField.trim().replace('"',''));
                        makeCompositeField = false;
                    } else if (makeCompositeField) {
                        compositeField +=  ',' + field;
                    } else {
                        fields.add(field.trim().replace('"',''));
                    }
                } 
                lines.add(fields);
            } 
            //Loop each line of the CSV file  
            for(List<string> lin: lines){
                Area_Of_Expertise__c aoe = new Area_Of_Expertise__c ();
                Competency__c comp = new Competency__c ();
                if(!compAeoMap.containsKey(lin[8])){
                    compAeoMap.put(lin[8], lin[1]);  
                }
                if(!CompWithProgCodeMap.containsKey(lin[8])){
                    CompWithProgCodeMap.put(lin[8], lin[0]);  
                }
                
                progCodeSet.add(lin[0]);
                //Area Of Expertise 
                if(!compAeoMap.containsKey(lin[1])){
                    aoeProgMap.put(lin[1],lin[0]);
                    compAeoMap.put(lin[1],null);
                    aoe.Name =  lin[2].replace('"','').left(80)+'('+lin[1]+')';
                    aoe.Type__c   = lin[13];                    
                    aoe.Display_Name__c   = lin[2].replace('"','').left(80)+'('+lin[1]+')';
                    aoe.Publish_to_LMS__c   =  true;
                    aoe.Level__c   = lin[3];
                    aoe.Pseudo_Course__c   = boolean.valueOf(lin[6]);
                    aoe.Category__c   = lin[4];
                    aoe.Overview__c  =   lin[7].replace('"','');
                    aoe.Subject_Area__c   = lin[5];
                    aoeListToInsert.add(aoe);
                } 
                
                //Competency 
                comp.Name  =  lin[9].replace('"','').left(80);
                comp.Code__c  = lin[8];            
                comp.Published__c  = true;
                comp.Display_Name__c  =  lin[9].replace('"','');
                comp.Description__c  = lin[12].replace('"','');
                comp.Credit_Equivalency__c  =  decimal.valueOf(lin[10]);
                comp.Type__c = lin[13];
                
                If(lin[11] == 'WP'){
                    comp.Assessment_Type__c  = 'Objective Assessment';
                }else if(lin[11] == 'PT'){
                    comp.Assessment_Type__c  = 'Performance Task';
                }else if(lin[11] == 'SA'){
                    comp.Assessment_Type__c  = 'Short Answer';
                }else if(lin[11] == 'SR'){
                    comp.Assessment_Type__c  = 'Selected Response';
                }else if(lin[11] == 'OA'){
                    comp.Assessment_Type__c  = 'Objective Assessment';
                }else if(lin[11] == 'WR'){
                    comp.Assessment_Type__c  = 'Written Response';
                }
                compListToInsert.add(comp);
            }
            /* */
            insert aoeListToInsert;
            insert compListToInsert;
            /**/
            List<Product2> progLst = new  List<Product2>();
            Map<string,string> progCodeLMSIdMap = new  Map<string,string> ();//Map  Prog Code with Prog LMS id
            Map<string,id> progCodeWithIdMap = new  Map<string,string> ();//Map prog Code with Prog Id
            progLst = [Select Id,name ,ProductCode,LMS_ID__c  from Product2 where ProductCode  In: progCodeSet];
           
            //Loop Program records to get id and LMS Id map 
            For(Product2 prog:progLst){
                if(!progCodeLMSIdMap.containsKey(prog.ProductCode)){
                    progCodeLMSIdMap.put(prog.ProductCode, prog.LMS_ID__c);
                }
                if(!progCodeWithIdMap.containsKey(prog.ProductCode)){
                    progCodeWithIdMap.put(prog.ProductCode, prog.id);
                }
            }
            
            system.debug('progCodeLMSIdMap'+progCodeLMSIdMap);// Prog Code with LMS ID
            List<Program_Expertise__c> progExpToInsert = new  List<Program_Expertise__c>();
            list<Area_Of_Expertise__c> aoeLst= [select id,name,Course_Code__c,LMS_ID__c  from Area_Of_Expertise__c where id IN: aoeListToInsert];
            Map<string,id> aoeIdMap = new  Map<string,id> ();//Map AOE Course Code with AOE Id
            system.debug(aoeLst);
            //Loop AOE records to get id and course code map & Create Program Expertise Records
            for(Area_Of_Expertise__c aoe :aoeLst ){
                Program_Expertise__c progExp = new Program_Expertise__c();
                if(!aoeIdMap.containsKey(aoe.Course_Code__c)){
                    aoeIdMap.put(aoe.Course_Code__c, aoe.id);
                }
                progExp.Area_of_Expertise__c = aoe.id;
                progExp.Program__c = progCodeWithIdMap.get(aoeProgMap.get(aoe.Course_Code__c));
                progExpToInsert.add(progExp);
            }
            
            
            system.debug(aoeIdMap);
            
            List<competency_expertise__c> comExpLst = new  List<competency_expertise__c>();
            List<Competency__c> compListToUpdate = new List<Competency__c> ();
            //Loop Competency records to update Prog LMS ID & Create Competency Expertise Records
            for(competency__c comp: compListToInsert){
                competency_expertise__c comExp = new competency_expertise__c();
                Competency__c com = new Competency__c();
                comExp.Competency__c = comp.id;
                comExp.Area_of_Expertise__c = aoeIdMap.get(compAeoMap.get(comp.Code__c));
                comExp.Credit_Equivalency__c = comp.Credit_Equivalency__c;
                com.id = comp.id;
                com.Program_LMS_ID__c = progCodeLMSIdMap.get(CompWithProgCodeMap.get(comp.Code__c));
                compListToUpdate.add(com);
                comExpLst.add(comExp);
            }
            /* */
            insert comExpLst;
            update compListToUpdate;
            insert progExpToInsert;   
            /**/
            
            return new CSVObject(headers, lines);
        }catch(Exception e){
            Database.rollback(sp);
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
        
    }
    
    
    
}