global class BatchPopulateGPAOnStudentProgram  implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
    
    global String Query;
    global Database.QueryLocator start(Database.BatchableContext BC){
        query = 'Select id, GPA__c, (select id, Grade_Value__c, Grade__c from Student_Expertise__r where IsAchieved__c = true) from Student_Program__c where Program__r.Degree_Level__c = \'Undergrad\'';
	    //query = 'Select id, GPA__c, (select id, Grade_Value__c, Grade__c from Student_Expertise__r where IsAchieved__c = true) from Student_Program__c where Program__r.Degree_Level__c = \'Undergrad\' aND name = \'SP-6369\'';
        return Database.getQueryLocator(query);
    }
      
    global void execute(SchedulableContext SC) { 
        BatchPopulateGPAOnStudentProgram objBatch = new BatchPopulateGPAOnStudentProgram(); 
        ID batchprocessid = Database.executeBatch(objBatch, 100);
    }
 
     global void execute(Database.BatchableContext BC, List<Student_Program__c> stdntPrmList){
        List<Student_Expertise__c> stdntExprtsList = new List<Student_Expertise__c>();
        Set<Id> spIDSet = new Set<Id>();
        
        
        for(Student_Program__c spObj : stdntPrmList){
            spIDSet.add(spObj.Id);
            if(!spObj.Student_Expertise__r.isEmpty()){
                stdntExprtsList.addAll(spObj.Student_Expertise__r);
            }
        }
        if(!stdntExprtsList.isEmpty()){
            map<ID,list<Student_Competency__c>> mapStudentExpWithStudentCompetency = new map<ID,list<Student_Competency__c>>();
            
            for(Student_Competency__c sComp:[Select ID,Student_Expertise__c,Competency_Credit_Equivalency__c,status__c from Student_Competency__c where Student_Expertise__c in:stdntExprtsList]){
                if(!mapStudentExpWithStudentCompetency.containsKey(sComp.Student_Expertise__c)){
                    mapStudentExpWithStudentCompetency.put(sComp.Student_Expertise__c,new list<Student_Competency__c>());
                }
                mapStudentExpWithStudentCompetency.get(sComp.Student_Expertise__c).add(sComp);
            }           
            //map for status value 
            map<String,decimal> gradeEque = new map<String,decimal>();
            gradeEque.put('Transferred',0);
            gradeEque.put('Achieved',3);
            gradeEque.put('Mastered',4);   
            
            For(Student_Expertise__c stuExp : stdntExprtsList){
                
                decimal compCEvalue = 0;
                decimal sumCEValueStatus = 0 ;
                decimal totalCE = 0 ;
                decimal gradeValue = 0 ;
                string grade = '' ;
                boolean isTransferred = false;
                boolean isFulfilled = false;
                
                if(!mapStudentExpWithStudentCompetency.isEmpty()){
                    if(mapStudentExpWithStudentCompetency.containsKey(stuExp.id)){
                        
                        // Calculation Logic for grade value.
                        for(Student_Competency__c sComp : mapStudentExpWithStudentCompetency.get(stuExp.id)){
                            
                            if (sComp.status__c == 'Mastered' || sComp.status__c == 'Achieved' ||  sComp.status__c == 'Transferred' ){
                                sumCEValueStatus += sComp.Competency_Credit_Equivalency__c * gradeEque.get(sComp.status__c);
                                totalCE += sComp.Competency_Credit_Equivalency__c;
                                if(sComp.status__c == 'Transferred'){
                                    isTransferred = True;
                                }
                            }else if(sComp.status__c == 'Fulfilled'){
                                system.debug('%%%%%%5status'+sComp.status__c);
                                
                                isFulfilled = True;
                            }
                        } 
                        
                        
                        if(totalCE > 0 && isFulfilled == False){
                            gradeValue = sumCEValueStatus/totalCE;
                        }else if(isFulfilled){
                            gradeValue = stuExp.Grade_Value__c;
                        }
                        //Populate the Grade based on grade value.
                        if(gradeValue >= 3.5){
                            grade = 'A';
                        }else if(gradeValue >= 3 && gradeValue <= 3.49){                    
                            grade = 'B';
                        }else if(isTransferred ){
                            grade = 'TR';
                        }else if(isFulfilled ){
                            grade = stuExp.Grade__c;
                        }
                        
                        stuExp.Grade_Value__c = gradeValue;
                        stuExp.Grade__c = grade;       
                        
                    }
                }     
            }
            if(!stdntExprtsList.isEmpty())
                update stdntExprtsList;
           StudentExpertiseHelper.calculateGrandGPAOnStudentProgram(spIDSet);
        }  
        
    }
    
    global void finish(Database.BatchableContext BC){
    }
}