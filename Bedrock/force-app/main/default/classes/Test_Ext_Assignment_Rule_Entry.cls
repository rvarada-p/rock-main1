@isTest
private class Test_Ext_Assignment_Rule_Entry {
	
	@isTest static void NewRule() {
		// Implement test code
		Assignment_Group_Name__c AG = new Assignment_Group_Name__c(name='test');
  		insert AG;

  		Opportunity_Assignment_Rule__c NewRule = new Opportunity_Assignment_Rule__c(NAme='testrule', Is_Active__c=true);
  		insert NewRule;

  		Assignment_Rule_Entry__c AR = New Assignment_Rule_Entry__c(Opportunity_Assignment_Rule__c =NewRule.id, Assign_to_Assignment_Group__c=AG.id);

  		Test.setCurrentPage(Page.AssignmentRuleEntry);

  		ApexPages.StandardController sc = new ApexPages.StandardController(AR);
  		Ext_Assignment_Rule_Entry Ext = new Ext_Assignment_Rule_Entry(sc);

  		//get options for opperator
  		Ext.getOpperatorValues();


  		Ext.conditions[0].Field_API_Name__c = 'CreatedDate';
  		Ext.conditions[0].Operator__c = 'Equals';
  		Ext.conditions[0].Value__c = '01/12/2015 10:37 PM';

  		Ext.conditions[1].Field_API_Name__c = 'Birthdate__c';
  		Ext.conditions[1].Operator__c = 'Equals';
  		Ext.conditions[1].Value__c = '01/12/2015';

  		Ext.save();

  		//reset the page to edit
  		sc = new ApexPages.StandardController(AR);
  		Ext = new Ext_Assignment_Rule_Entry(sc);

  		Ext.addrow();

  		System.assertEquals(Ext.picklistoptions.size(),0);
  		
  		ApexPages.currentPage().getParameters().put('selectedfield','stagename');
  		Ext.resetpicklistvalue();

  		//Javascript remoting test

  		String type1 = Ext_Assignment_Rule_Entry.getFieldType('name');
  		String type2 =Ext_Assignment_Rule_Entry.getFieldType('Contact__r.firstname');



	}
	
	
}