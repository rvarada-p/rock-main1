/************************************************************************
Name  : StudentCompleteAPIHelper
Author: Sarah Khalid, Laureate
Date  : Jan 20, 2017
Description: Helper class for Student Complete API
*************************************************************************/

public with sharing class StudentCompleteAPIHelper  {

    public StudentCompleteAPIHelper() {
        
     } 
     
     //This method marks a Student as Complete in the LMS by un-enrolling them from the Section and Course Offering
     public void markCompeteInLMS(list<Student_Sections__c> lstStudentSections) {
       
        //Loop through the Student Sections  
        for(Student_Sections__c ss : lstStudentSections) {
         Decimal competencyShellID = ss.Competency_Shell_ID__c!=null ? Decimal.valueOf(ss.Competency_Shell_ID__c) : null;
         Integer studentLMSID = ss.Student_LMS_ID__c!=null ? Integer.valueOf(ss.Student_LMS_ID__c) : null;
         Integer sectionID = ss.LMS_Section_ID__c!=null ? Integer.valueOf(ss.LMS_Section_ID__c) : null;
         id ssId =ss.id;
        //Un-enroll the student from Bright Space section
      //  BrightSpaceCalls.markStudentCompleteInLMS(ssId, studentLMSID, competencyShellID, sectionID);

        }
       
     }
     
}