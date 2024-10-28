/************************************************************************
Name  : BursarHoldHelper
Author: Sarah Khalid, Laureate
Date  : August 15, 2017
Description: Helper class for Applying and Removing Bursar Holds
*************************************************************************/

public with sharing class BursarHoldHelper {
    
    public integer totalNumberOfSuccess;
    public integer totalNumberOfFailure;
    
	public BursarHoldHelper() {
		
	}
	
	public void applyBusarHolds(list<Student_Program__c> lstStudentProgram) {
	    totalNumberOfSuccess = 0;
	    totalNumberOfFailure = 0;
	    Id bursarHoldCodeId;
	    list<Student_Hold_Code__c> lstStudentHoldCodes = new list<Student_Hold_Code__c>();
		list<Hold_codes__c> lstHoldCodes = new list<Hold_codes__c>([SELECT Id FROM Hold_codes__c WHERE Name = 'BH']);
		if(lstHoldCodes.size()>0) {
			bursarHoldCodeId = lstHoldCodes[0].Id;
		}		
		
		for(Student_Program__c sp : lstStudentProgram) {
            //S-679860
            if(!(sp.Sponsor_Billing__c && sp.Student_Sponsor_Name__r.Name=='Bright Horizons (EdAssist)')) {
                Student_Hold_Code__c studentHoldCode = new Student_Hold_Code__c();
                studentHoldCode.Hold_Code__c = bursarHoldCodeId;
                studentHoldCode.Student_Program__c = sp.Id;
                lstStudentHoldCodes.add(studentHoldCode);
            }
		}
		
        if (lstStudentHoldCodes.size() > 0) {
            Set<Id> failureIdsSet;
            Database.SaveResult[] srList = Database.insert(lstStudentHoldCodes, false);
            
            // Iterate through each returned result 
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('*****: ' + 'Fields: ' + err.getFields() + ', Status Code: ' + err.getStatusCode() + ': ' + err.getMessage());                        
                    }
                }
            }
        }       
	}
	
	//This method looks automatically removes a Bursar Hold (BH) code on Student records so that future subscriptions can be renewed 
	public void removeBursarHolds(list<Student_Program__c> lstStudentProgram) {
	    totalNumberOfSuccess = 0;
	    totalNumberOfFailure = 0;
	    Id bursarHoldCodeId;
	    List<Id> lstSPIds = new List<Id>();
		list<Hold_codes__c> lstHoldCodes = new list<Hold_codes__c>([SELECT Id FROM Hold_codes__c WHERE Name = 'BH']);
		if(lstHoldCodes.size()>0) {
			bursarHoldCodeId = lstHoldCodes[0].Id;
		}
			    
	    for(Student_Program__c sp : lstStudentProgram) {
	    	lstSPIds.add(sp.Id);
	    }
	    
	    list<Student_Hold_Code__c> lstToUpdate = new list<Student_Hold_Code__c>();
	    list<Student_Hold_Code__c> lstStudentHoldCodes = new list<Student_Hold_Code__c>([SELECT Id FROM Student_Hold_Code__c WHERE Student_Program__c IN :lstSPIds AND Hold_Close_Date__c = null AND Hold_Code__c = :bursarHoldCodeId]);
		for(Student_Hold_Code__c shc : lstStudentHoldCodes) {
			shc.Hold_Close_Date__c = System.today();
			lstToUpdate.add(shc);
		}
		update lstToUpdate; 
		
		System.debug('Bursar Hold codes to be removed : '  + lstStudentHoldCodes);
		
	}
	
}