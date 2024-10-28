/************************************************************************
Name  : StudentEnrollmentStepsList_Controller
Author: Virendra (Appirio)
Date  : September 24, 2014
Description: Controller  class for the inline Edit vf page StudentEnrollmentStepsList
*************************************************************************/
public with sharing class StudentEnrollmentStepsList_Controller {
	
	public list<Student_Enrollment_Steps__c> studentEnrollments{get;set;}
	public StudentEnrollmentStepsList_Controller(ApexPages.StandardController controller){
		studentEnrollments = new list<Student_Enrollment_Steps__c>();
       //On init get all the related Student_Enrollment_Steps__c
        //check if any studentEnrollments is returned    
        for(Student_Enrollment_Steps__c stdEnrolledSteps:[Select Student_Program__c, Name, Id, Enrollment_Step_Name__c,LastModifiedBy.Name,LastModifiedById , Date_Completed__c,Comment__c
                             From Student_Enrollment_Steps__c s WHERE Student_Program__c =:controller.getId()]){
                studentEnrollments.add(stdEnrolledSteps);              	
        }
                 
        isEmpty = studentEnrollments.isEmpty();
    }
    
	
	public string appSfId{get;set;}
    public Boolean isEmpty{get;set;}
  
   
    /*
    *Updates the field value when the field losses focus
    **/
    public void updateStudentEnrollmentSteps(){
        system.debug('============'+appSfId);
        Student_Enrollment_Steps__c updateStudentEnrollment = null;
        for(Student_Enrollment_Steps__c stdEnroll:studentEnrollments){
            //look for the record to update
            if(appSfId==stdEnroll.Id){              
               updateStudentEnrollment = stdEnroll;
               break;
            }
        } 
        
        if(updateStudentEnrollment != null){
        	update updateStudentEnrollment;
        } 
    }
    
    
  

}