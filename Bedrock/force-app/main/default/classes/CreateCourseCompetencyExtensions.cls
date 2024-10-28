/*******************************************************************
Name  : CreateCourseCompetencyExtensions
Author: Vinod (Appirio)
Date  : September 25, 2014
Description: Extensions class for the vf page CreateCourseCompetency
*************************************************************************/	
public with sharing class CreateCourseCompetencyExtensions {
	public string selectedCompetencyID {get;set;}
	public Course_Competency__c newCourseCompetency {get;set;}
	public Course__c selectedCourse {get;set;}
	ID CourseID;
	string courseName{get;set;}
	public CreateCourseCompetencyExtensions(ApexPages.StandardController stdController){
		newCourseCompetency = (Course_Competency__c)stdController.getRecord();	
		if(Apexpages.currentpage().getparameters().containsKey('CourseID')){
			CourseID = Apexpages.currentpage().getparameters().get('CourseID');
			getCourseDetail();
		}	
	}
	private void getCourseDetail(){
		for(Course__c corse:[select ID,Name from Course__c where id=:CourseID]){
			selectedCourse = corse;
		}
	}
	public pageReference save(){
		pagereference pg ;
	 	system.debug('selectedCompetencyID:::::::::::::::::::'+selectedCompetencyID);
	 	if(selectedCompetencyID == '' || selectedCompetencyID == null){
	 		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Select at least one cometency '));
            pg = null;
	 	}else{
		 	list<Course_Competency__c> lstCourseCompetency = new list<Course_Competency__c>();
		 	// create multiple Course_Competency__c
		 	for(string strCompetencyID : selectedCompetencyID.split(',')){
		 		Course_Competency__c compCourse = new Course_Competency__c();
		 		compCourse.Competency__c = strCompetencyID;
		 		compCourse.Course__c = CourseID;
		 		lstCourseCompetency.add(compCourse);
		 	}
		 	if(lstCourseCompetency.size() > 0){
		 		insert lstCourseCompetency;
		 		pg = new pageReference('/'+CourseID);
		 	}
	 	}
	 	return pg;
	}
	public pageReference cancel(){
		return new pageReference('/'+CourseID);
	}
		 	
}