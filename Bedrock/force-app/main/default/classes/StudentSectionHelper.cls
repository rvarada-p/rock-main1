/*******************************************************************
Name  : StudentSectionHelper
Author: Sarah Khalid - Laureate
Date  : October 13, 2017
Description: Helper class for Student Section trigger and trigger handler
*************************************************************************/

public with sharing class StudentSectionHelper {
   public void enrollInBS(list<Student_Sections__c> studentSections) {
    	JsonWrapper jsonGenerator = new JsonWrapper();
    	Decimal studentRoleId = D2L__c.getValues('D2L').Student_Role_ID__c;
 		
		for(Student_Sections__c ss: studentSections) {
			Decimal studentLMSId = ss.Student_LMS_ID__c; 
			Decimal compShell = ss.Competency_Shell_ID__c!=null ? Decimal.valueOf(ss.Competency_Shell_ID__c) : null;
			Decimal smeSection = ss.LMS_Section_ID__c !=null ? ss.LMS_Section_ID__c : null; 
			Id scId = ss.Student_Competency__c !=null ? ss.Student_Competency__c : null;
			if(compShell!=null && studentLMSId!=null && studentRoleId!=null) {
				String json = jsonGenerator.createEnrollmentData(compShell, studentLMSId, studentRoleId);
				BrightSpaceCalls.createEnrollment(json, ss.Id, smeSection, studentLMSId, studentRoleId, scId);
			}
			if(smeSection!=null && studentLMSId!=null && studentRoleId!=null) {
				//String jsonSection = jsonGenerator.createEnrollmentData(smeSection, studentLMSId, studentRoleId);
				//BrightSpaceCalls.createEnrollment(jsonSection, ss.Id, scId); 
			}			
			
		}    
		 
   }
}