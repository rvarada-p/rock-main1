/*******************************************************************
Name  : SendStudentAssessmentResult
Author: Sarah Khalid - Laureate 
Date  : August 12, 2015
Description: Class used for copying down the email address 
			 from the student level down to the Student 
			 Assessment level via Process Builder
*************************************************************************/

public class SendStudentAssessmentResult {	
	@InvocableMethod
	public static void updateEmailAddress(List<Id> assessmentIds) {
		
		List<Student_Assessment__c> assessments = [Select Id, Student_Competency__r.Contact__r.Walden_Email__c 
										  from Student_Assessment__c
										  where Id in :assessmentIds];
										  System.debug('Student Walden Email >>> ' + assessments);
		for(Student_Assessment__c sa: assessments) {
			sa.Student_Email__c = sa.Student_Competency__r.Contact__r.Walden_Email__c;
		}
		update assessments;
										  
	}
	
}