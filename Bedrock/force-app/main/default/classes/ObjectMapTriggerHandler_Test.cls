/************************************************************************
Name  : ObjectMapTriggerHandler_Test 
Author: Virendra (Appirio)
Date  : November 11, 2014
Description: test class for the ObjectMapTriggerHandler and Trigger
*************************************************************************/
@isTest
private class ObjectMapTriggerHandler_Test {
	
	  static testMethod void testObjectMaperTrigger() {
	  	Object_Map__c objectMap = TestDataGenerator.createObjectMap(true);
	    Field_Mapping__c fieldMapping =  TestDataGenerator.createNewFieldMapping(true,objectMap.Id,'FirstName','First_Name__c');
	    Field_Mapping__c fieldMapping1 =  TestDataGenerator.createNewFieldMapping(true,objectMap.Id,'LastName','Last_Name__c');
	  
	    update objectMap;
	    update fieldMapping1;
	  }
}