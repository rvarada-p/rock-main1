/*******************************************************************
Name  : StudentSectionTriggerHandler
Author: Sarah Khalid - Laureate
Date  : October 13, 2017
Description: Trigger handler class for Student Sections trigger
*************************************************************************/
public with sharing class StudentSectionTriggerHandler {
  public void onAfterInsert(list<Student_Sections__c> newStudentSections){
    ID waldenRecordTypeId = Schema.SObjectType.Student_Sections__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
    list<Student_Sections__c> ssList = new list<Student_Sections__c>();
    StudentSectionHelper objHelper = new StudentSectionHelper();
    for(Student_Sections__c ss: newStudentSections){
 	  //make sure the AoE is ready to be published to the LMS  	
 	  System.debug('Org Unit ID: ' + ss.LMS_Section_ID__c + ' User ID: ' + ss.User_LMS_ID__c);
      if(ss.RecordTypeId == waldenRecordTypeId && ss.LMS_Section_ID__c!=null && ss.User_LMS_ID__c!=null){
      	System.debug('publishing to LMS');
        ssList.add(ss);
      }
    }
    if(!ssList.isEmpty()){
      objHelper.enrollInBS(ssList); 
    } 
  }       	    
}