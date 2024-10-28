/*******************************************************************
Name  : ProcessCOPController
Author: Sarah (Laureate)
Date  : March 25, 2016
Description: Controller extension class for ProcessCOP Page
*************************************************************************/

public with sharing class ProcessCOPController {

	public Opportunity application { get; set; }
	public String selectedValue { get;set; }
	public String fromProgram { get; set; }
	public String toProgram { get; set; }
	public String applicantToProgram { get; set; }
	
	public ProcessCOPController(ApexPages.StandardController controller){
		if(!test.isRunningTest()) {
			controller.addFields(new List<String>{'Id', 'Parent_Program__c', 'StageName', 'Name', 'Brand_Profile__c', 'Brand_Profile__r.Primary_Program_of_Interest__c' , 'Brand_Profile__r.Primary_Program_of_Interest__c', 'L1_EA_Name__c', 'LeadSource'});		
		}
		application  = (Opportunity)controller.getRecord();		
	}
	
	public List<SelectOption> getAllPrograms() {
		List<SelectOption> options = new List<SelectOption>();
		List<Product2> allPrograms = new List<Product2>([SELECT Id, Parent_Program__c, Name FROM Product2 WHERE IsActive = true AND Parent_Program__c!=null AND Parent_Program__c != :application.Parent_Program__c]);
		for(Product2 currProgram : allPrograms) {
			options.add(new SelectOption(currProgram.Id, currProgram.Name));
		}
		return options;
	}
	
 
	public PageReference processApplicantCOP() {
		String applicationStage = application.stagename;
		system.debug('Application Stage ' + applicationStage);
		//Only proceed with COP if the stagename is Incomplete App / Active or later
		if(applicationStage!=null && (applicationStage != 'Admitted' || applicationStage != 'Student' )) {
			System.debug('Primary Program of Interest ' + application.Brand_Profile__r.Primary_Program_of_Interest__c + ' New Selected Program ' + applicantToProgram);
			String brandProfileId =  application.Brand_Profile__c;
			if(brandProfileId==null) {
				 Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'There is no Brand Profile record associated with this student'));				
			} 
			//If the user selects the same primary program as the current one throw an error
			if(application.Brand_Profile__r.Primary_Program_of_Interest__c!=null && application.Brand_Profile__r.Primary_Program_of_Interest__c == applicantToProgram) {
				 Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'Please select a different program, this program is already associated with this students application'));
			}
			else if(brandProfileId != null && applicantToProgram!=null) {
				//Attach new program to this user's brand profile
				Brand_Profile__c bp = new Brand_Profile__c(Id = brandProfileId, Primary_Program_of_Interest__c = applicantToProgram, Change_of_Program__c = true, COP_Related_Opportunity__c = application.Id, L1_EA_Name__c = application.L1_EA_Name__c, Lead_Source__c = application.LeadSource);
				update bp;
				//Close existing opportunity
				application.stagename = 'Closed';
				application.Close_Reason__c = 'Change of Program';
				update application;
				Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'Change of Program processed successfully'));
			}
			
		}
  
		return null;		
	}
}