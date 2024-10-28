/*******************************************************************
Name : CustomLearningPlanController
Author: Vinod (Appirio)
Date : September 26, 2014
Description: controller class for the page CustomLearningPlan
*************************************************************************/
public with sharing class CustomLearningPlanController {
	public list<Student> lstAllStudents{get;set;}
	public map<ID,list<Student_Program__c>> mapStudentWithStudentProgram{get;set;}
	public map<ID,list<Student_Expertise__c>> mapStudentProgramWithStudentExpertise{get;set;}
	public map<ID,list<Student_Competency__c>> mapStudentExpertiseWithStudentCompetency{get;set;}
	//
	ID studentProgramid ;
	public CustomLearningPlanController(ApexPages.StandardController stdController){
		studentProgramid = stdController.getRecord().Id;
		lstAllStudents = new list<Student>();
		getAllStudentProgramDetail();
	}
	
	public void getAllStudentProgramDetail(){
		lstAllStudents = new list<Student>();
		id studentId;
	
		mapStudentWithStudentProgram = new map<ID,list<Student_Program__c>>();
		set<ID> allStudentProgram_Ids = new set<id>();
		for(Student_Program__c sProg: [Select Program__r.Name, Program__c, Name,Student__c,Student__r.Name, Id From Student_Program__c where id=:studentProgramid]){
			if(!mapStudentWithStudentProgram.containsKey(sProg.Student__c)){
				mapStudentWithStudentProgram.put(sProg.Student__c,new list<Student_Program__c>());
			}
			if(sProg.Student__c != null){
				studentId = sProg.Student__c;				
			}
			mapStudentWithStudentProgram.get(sProg.Student__c).add(sProg);
			allStudentProgram_Ids.add(sProg.Id);
		}
		for(Contact con:[Select ID,Name from Contact where id=: studentId]){
			lstAllStudents.add(new Student(con));			
		}
		mapStudentProgramWithStudentExpertise = new map<ID,list<Student_Expertise__c>>();
		//
		set<ID> allStudentExpertiseId = new set<Id>();
		for(Student_Expertise__c sExper: [Select Student_Program__c, Name, Learning_Order__c, Id,
										  Area_of_Expertise__r.Name, Area_of_Expertise__c
										  From Student_Expertise__c
										  where Student_Program__c in: allStudentProgram_Ids order by Learning_Order__c asc NULLS LAST]){
			if(!mapStudentProgramWithStudentExpertise.containsKey(sExper.Student_Program__c)){
				mapStudentProgramWithStudentExpertise.put(sExper.Student_Program__c,new list<Student_Expertise__c>());
			}
			mapStudentProgramWithStudentExpertise.get(sExper.Student_Program__c).add(sExper);
			allStudentExpertiseId.add(sExper.id);
		}
		//
		mapStudentExpertiseWithStudentCompetency = new map<ID,list<Student_Competency__c>>();
		for(Student_Competency__c sComp:[Select Status__c, Learning_Order__c, Id, Competency__r.Display_Name__c, Competency__r.Type__c,
										Competency__r.Code__c, Competency__r.Average_Time_in_hours__c, Competency__c,Student_Expertise__c 
										From Student_Competency__c
										where Student_Expertise__c in: allStudentExpertiseId order by Learning_Order__c asc NULLS LAST]){
		
			if(!mapStudentExpertiseWithStudentCompetency.containsKey(sComp.Student_Expertise__c)){
				mapStudentExpertiseWithStudentCompetency.put(sComp.Student_Expertise__c,new list<Student_Competency__c>());
			}
			mapStudentExpertiseWithStudentCompetency.get(sComp.Student_Expertise__c).add(sComp);
		}
	    
	    system.debug('::lstAllStudents:::'+lstAllStudents);
		for(Student std:lstAllStudents){
			// populate student program
			list<StudentProgram> studentProgramLstTemp = new list<StudentProgram>();
			if(mapStudentWithStudentProgram.containsKey(std.student.id)){
				for(Student_Program__c sprog: mapStudentWithStudentProgram.get(std.student.id)){
					//
					StudentProgram studentProgram = new StudentProgram(sprog);
					List<StudentExpertise> studentExpertiseLstTemp = new List<StudentExpertise>();
					if(mapStudentProgramWithStudentExpertise.containsKey(sprog.Id)){
						for(Student_Expertise__c sExper :mapStudentProgramWithStudentExpertise.get(sprog.Id)){
							StudentExpertise newStudentExpertise = new StudentExpertise(sExper);
							List<StudentCompetency> StudentCompetencyLstTemp = new List<StudentCompetency>();
							if(mapStudentExpertiseWithStudentCompetency.containsKey(sExper.Id)){
								for(Student_Competency__c pComp :mapStudentExpertiseWithStudentCompetency.get(sExper.Id)){
									StudentCompetency newStudentCompetency = new StudentCompetency(pComp);
									StudentCompetencyLstTemp.add(newStudentCompetency);
								}
								newStudentExpertise.studentCompetencyLst = StudentCompetencyLstTemp;
								studentExpertiseLstTemp.add(newStudentExpertise);
							}
						}
						
						studentProgram.studentExpertiseLst = studentExpertiseLstTemp;
						studentProgramLstTemp.add(studentProgram);
					}
				}
			}
			std.studentProgramLst = studentProgramLstTemp;
		}
	}
	
	
	public class Student{
		public Contact student{get;set;}
		public List<StudentProgram> studentProgramLst{get;set;}
		public Student(Contact con){
			student = con;
		}
	}
	
	public class StudentProgram{
		public Student_Program__c studentProgram{get;set;}
		public List<StudentExpertise> studentExpertiseLst{get;set;}
		public StudentProgram(Student_Program__c sp){
			studentProgram = sp;
		}
	}
	
	public class StudentExpertise{
		public Student_Expertise__c studentExpertise{get;set;}
		public List<StudentCompetency> studentCompetencyLst{get;set;}
		public StudentExpertise(Student_Expertise__c se){
			studentExpertise = se;
		}
	}
	
	
	public class StudentCompetency{
		public Student_Competency__c studentCompetency{get;set;}
		public studentCompetency(Student_Competency__c sc){
			studentCompetency = sc;
		}
	}
}