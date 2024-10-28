/*******************************************************************
Name  : StudentAssessmentHelper
Author: Vinod (Appirio)
Date  : October 9, 2014
Related task: T-324881
Description: Helper class for the class StudentAssessmentTriggerHandler
*************************************************************************/
public with sharing class StudentAssessmentHelper {
	/* Constructor */
	public StudentAssessmentHelper(){	    
	}	  
    
	
  /*******************************************************************
  Method to roll up total number of Student Assessment attempt on the parent StudentCompetency
  Related task: T-324881
  ********************************************************************/
  public void rollUpNumberOfStudentAssessmentAttemptOnStudentCompetency(set<ID>setStudentCompetencyIds) {
    // get all related student competency
    map<ID,list<Student_Assessment__c>> mapStudentCompetencyWithStudentAssessment = new map<ID,list<Student_Assessment__c>>();
    for(Student_Assessment__c sa:[Select ID,Status__c,Grade__c,Student_Competency__c
                    from Student_Assessment__c
                    where Student_Competency__c in :setStudentCompetencyIds 
                    and Status__c != 'Submitted' ]){
      if(!mapStudentCompetencyWithStudentAssessment.containsKey(sa.Student_Competency__c)){
        mapStudentCompetencyWithStudentAssessment.put(sa.Student_Competency__c, new list<Student_Assessment__c>());
      }
      mapStudentCompetencyWithStudentAssessment.get(sa.Student_Competency__c).add(sa);
    }
    list<Student_Competency__c> lstStudentCompetency = new list<Student_Competency__c>();
    for(ID sCompetencyID : setStudentCompetencyIds){          
      Student_Competency__c sCompetency = new Student_Competency__c(ID = sCompetencyID);
      decimal totalNumberOfAssessment = 0;
      if(mapStudentCompetencyWithStudentAssessment.containsKey(sCompetencyID)){
        totalNumberOfAssessment = (decimal)mapStudentCompetencyWithStudentAssessment.get(sCompetencyID).size();  
      }
      sCompetency.Number_of_Assessment_Attempts__c = totalNumberOfAssessment;      
      lstStudentCompetency.add(sCompetency);      
    }
    update lstStudentCompetency;
  }
  /*******************************************************************
  Method to make parent competency as completed if newly created Assessment has grade of Mastered
  Related task: T-324881
  ********************************************************************/
  public void markParentStudentCompetencyAsCompleted(map<ID,Student_Assessment__c>mapStudentCompetencyWithStudentAssessment) {
    list<Student_Competency__c> lstStudentCompetency = new list<Student_Competency__c>();
    for(ID sCompetencyID : mapStudentCompetencyWithStudentAssessment.keySet()){
      Student_Assessment__c newAssessment = mapStudentCompetencyWithStudentAssessment.get(sCompetencyID);
      Student_Competency__c sCompetency = new Student_Competency__c(ID = sCompetencyID);
      if(newAssessment.Status__c == 'Mastered'){
        sCompetency.IsCompleted__c = true;
        sCompetency.Completed_Date__c = newAssessment.Assessment_Submitted_Date__c!=null ? newAssessment.Assessment_Submitted_Date__c : newAssessment.CreatedDate.date(); // Date.today();
        sCompetency.Status__c = 'Mastered';
      }else if(newAssessment.Status__c == 'Achieved'){
        sCompetency.IsCompleted__c = true;
        sCompetency.Completed_Date__c = newAssessment.Assessment_Submitted_Date__c!=null ? newAssessment.Assessment_Submitted_Date__c : newAssessment.CreatedDate.date(); // Date.today();
        sCompetency.Status__c = 'Achieved';
      }else if(newAssessment.Status__c == 'Submitted'){
        sCompetency.Status__c = 'Assessment Submitted';
      } else if(newAssessment.Status__c == 'Returned for Resubmission') {
      	sCompetency.Status__c = 'Returned for Resubmission';
      }
      else{
        sCompetency.IsCompleted__c = false;
        sCompetency.Status__c = 'Not Achieved';
      } 
      lstStudentCompetency.add(sCompetency);    
    }
    update lstStudentCompetency;
  }
  /*******************************************************************
  Method to make parent competency as completed if newly created Assessment has grade of Mastered
  Related task: T-324881
  ********************************************************************/
  public void changeParentStudentCompetencyStatusOnChildAssessmentDelete(set<ID>setStudentCompetencyIds) {
    //get latest created assessment and check the grade and Passed to make parent competency as completed 
    list<Student_Competency__c> lstStudentCompetency = new list<Student_Competency__c>();
    map<ID,Student_Assessment__c> mapStudentCompetencyWithStudentAssessment = new map<ID,Student_Assessment__c>();
    for(Student_Assessment__c sa :[Select ID,Grade__c, Status__c,Student_Competency__c, Assessment_Submitted_Date__c, CreatedDate from Student_Assessment__c where Student_Competency__c in:setStudentCompetencyIds order by CreatedDate desc ]){
      if(!mapStudentCompetencyWithStudentAssessment.containsKey(sa.Student_Competency__c)){
        mapStudentCompetencyWithStudentAssessment.put(sa.Student_Competency__c,sa);
      }
    }
    for(ID sCompetencyID :setStudentCompetencyIds){
      Student_Competency__c sCompetency = new Student_Competency__c(ID = sCompetencyID);
      if(mapStudentCompetencyWithStudentAssessment.containsKey(sCompetencyID)){
        Student_Assessment__c newAssessment = mapStudentCompetencyWithStudentAssessment.get(sCompetencyID);
        if(newAssessment.Status__c == 'Mastered'){
          sCompetency.IsCompleted__c = true;
          sCompetency.Completed_Date__c = newAssessment.Assessment_Submitted_Date__c!=null ? newAssessment.Assessment_Submitted_Date__c : newAssessment.CreatedDate.date();
          sCompetency.Status__c = 'Mastered';
        }else if(newAssessment.Status__c == 'Achieved'){
          sCompetency.IsCompleted__c = true;
          sCompetency.Completed_Date__c = newAssessment.Assessment_Submitted_Date__c!=null ? newAssessment.Assessment_Submitted_Date__c : newAssessment.CreatedDate.date();
          sCompetency.Status__c = 'Achieved'; 
        }else if(newAssessment.Status__c == 'Submitted'){
          sCompetency.Status__c = 'Assessment Submitted';
        }
        else if(newAssessment.Status__c == 'Returned for Resubmission') {
            sCompetency.Status__c = 'Returned for Resubmission';
        }
        else{
          sCompetency.IsCompleted__c = false;
          sCompetency.Status__c = 'Not Achieved';
        }
      }else{
        sCompetency.IsCompleted__c = false;
        sCompetency.Status__c = 'Not Achieved';
      }      
      lstStudentCompetency.add(sCompetency);  
    }    
    update lstStudentCompetency;
  }
}