@isTest
private class MapperExtTest {
	
	@isTest static void testMapperExt() {
		
		// Initialize
		Object_Map__c testObj = new Object_Map__c();

		// Build the StandardController for test
		ApexPages.StandardController testCon = new ApexPages.StandardController(testObj);

		Test.startTest();

			MapperExt testExt = new MapperExt(testCon);

			testExt.getObjects(); // Getter for all the objects

			testExt.listTargetObjects(); // This will not select anything, but will throw apex page message

			testExt.selectedObject1 = 'Account'; // Select Account Object

			testExt.listTargetObjects(); // List the target objects for Selected Object thats account.

			testExt.selectedObject2 = 'Contact'; // This is a sample hence using Contact as its in any Salesforce org.

			testExt.getObjectFields(); // Get the fields of selected objects

			// Gets the fields for both source and targets.
			testExt.getFields();
			testExt.gettargetFields();

			// Get the record Types
			testExt.getSourceRTs();
			testExt.getTargetRTs();

			// Build the mappers
			testExt.buildMappers();

			//Do the Automatch
			testExt.autoMatch(); // OwnerId should match.

			system.assertEquals(true,testExt.isAutomatchSelected); // Assert the Automatch is selected.

			for(MapperExt.wrapFields wf : testExt.wfields){
				wf.sourceField = 'Name';
				wf.targetField = 'FirstName';
				break;
			}

			testExt.getDataTypes();

			testExt.createMaps(); // Inserts the Object Map and Field Maps.

			testObj = [SELECT Parent_Sync__c, Source_Record_Types__c, Target_Record_Types__c, Source_Object__c, Target_Object__c, Related_to_Source__c, Child_Relationship_Name__c, Two_way_Sync__c, (SELECT Source_Field__c, Target_Field__c, isReferenceField__c from Field_Mappings__r) from Object_Map__c];
			
			// Assert that the Object Map is inserted.
			system.assertEquals('Account',testObj.Source_Object__c);
			system.assertEquals('Contact',testObj.Target_Object__c); 

			testExt.reset();

		Test.stopTest();


	}

	@isTest static void testMapperExt2() {
		
		// Initialize
		Object_Map__c testObj = new Object_Map__c();

		// Build the StandardController for test
		ApexPages.StandardController testCon = new ApexPages.StandardController(testObj);

		Test.startTest();

			MapperExt testExt = new MapperExt(testCon);

			testExt.getObjects(); // Getter for all the objects

			testExt.selectedObject1 = 'Opportunity'; // Select Account Object

			testExt.listTargetObjects(); // List the target objects for Selected Object thats account.

			testExt.selectedObject2 = 'Account'; // This is a sample hence using Contact as its in any Salesforce org.

			testExt.getObjectFields(); // Get the fields of selected objects

			// Gets the fields for both source and targets.
			testExt.getFields();
			testExt.gettargetFields();

			// Get the record Types
			testExt.getSourceRTs();
			testExt.getTargetRTs();

			// Build the mappers
			testExt.buildMappers();

			//Do the Automatch
			testExt.autoMatch(); // OwnerId should match.

			system.assertEquals(true,testExt.isAutomatchSelected); // Assert the Automatch is selected.

			for(MapperExt.wrapFields wf : testExt.wfields){
				wf.sourceField = 'Name';
				wf.targetField = 'Name';
				break;
			}

			testExt.getDataTypes();

			testExt.createMaps(); // Inserts the Object Map and Field Maps.

			testObj = [SELECT Parent_Sync__c, Source_Record_Types__c, Target_Record_Types__c, Source_Object__c, Target_Object__c, Related_to_Source__c, Child_Relationship_Name__c, Two_way_Sync__c, (SELECT Source_Field__c, Target_Field__c, isReferenceField__c from Field_Mappings__r) from Object_Map__c];
			
			// Assert that the Object Map is inserted.
			system.assertEquals('Opportunity',testObj.Source_Object__c);
			system.assertEquals('Account',testObj.Target_Object__c); 

			testExt.reset();

		Test.stopTest();


	}

	@isTest static void testMapperExt3() {
		
		// Initialize
		Object_Map__c testObj = new Object_Map__c();

		// Build the StandardController for test
		ApexPages.StandardController testCon = new ApexPages.StandardController(testObj);

		Test.startTest();

			MapperExt testExt = new MapperExt(testCon);

			testExt.getObjects(); // Getter for all the objects

			testExt.selectedObject1 = 'Case'; // Select Account Object

			testExt.listTargetObjects(); // List the target objects for Selected Object thats account.

			testExt.selectedObject2 = 'CaseComment'; // This is a sample hence using Contact as its in any Salesforce org.

			testExt.getObjectFields(); // Get the fields of selected objects

			// Gets the fields for both source and targets.
			testExt.getFields();
			testExt.gettargetFields();

			// Get the record Types
			testExt.getSourceRTs();
			testExt.getTargetRTs();

			// Build the mappers
			testExt.buildMappers();

			//Do the Automatch
			testExt.autoMatch(); // Nothing should match.

			system.assertEquals(false,testExt.isAutomatchSelected); // Assert the Automatch is selected.

			for(MapperExt.wrapFields wf : testExt.wfields){
				wf.sourceField = 'Description'; // Maps the Case Description to comment body
				wf.targetField = 'CommentBody';
				break;
			}

			testExt.getDataTypes();

			testExt.createMaps(); // Inserts the Object Map and Field Maps.

			testObj = [SELECT Parent_Sync__c, Source_Record_Types__c, Target_Record_Types__c, Source_Object__c, Target_Object__c, Related_to_Source__c, Child_Relationship_Name__c, Two_way_Sync__c, (SELECT Source_Field__c, Target_Field__c, isReferenceField__c from Field_Mappings__r) from Object_Map__c];
			
			// Assert that the Object Map is inserted.
			system.assertEquals('Case',testObj.Source_Object__c);
			system.assertEquals('CaseComment',testObj.Target_Object__c); 

			testExt.reset();

		Test.stopTest();


	}
	
}