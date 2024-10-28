@isTest
private class ObjectMapTests {
/*	
	@isTest static void objectMapHandlerTest1() {
		
		// Load Object Maps	
		Object_Map__c testObj = new Object_Map__c();

		testObj.Source_Object__c = 'Account'; // Is the best Test 
		testObj.Target_Object__c = 'Contact';
		testObj.Parent_Sync__c = false;
		testObj.Two_way_Sync__c = true;
		testObj.Include_Inserts__c = true;
		RecordType acctRT;
		RecordType conRT;
		
		try {
			acctRT = [Select Id, Name from RecordType where SObjectType='Account' LIMIT 1];
		}catch(Exception e){

		}

		if(acctRT != null)
			testObj.Source_Record_Types__c = acctRT.Id;

		try {
			conRT = [Select Id, Name from RecordType where SObjectType='Contact' LIMIT 1];
		}catch(Exception e){

		}

		if(conRT != null)
			testObj.Target_Record_Types__c = conRT.Id;
		
		testObj.Related_to_Source__c = 'AccountId'; // Contact is related to Account via AccountId

		insert testObj;

		List<Field_Mapping__c> fmappings = new List<Field_Mapping__c>();
		
		fmappings.add(new Field_Mapping__c(Object_Mapping__c=testObj.Id,Source_Field__c='Name',Target_Field__c='FirstName'));
		fmappings.add(new Field_Mapping__c(Object_Mapping__c=testObj.Id,Source_Field__c='BillingCity',Target_Field__c='MailingCity'));

		insert fmappings;

		// Load actual records
		Account testAcc = TestDataGenerator.createAccount(acctRT.Name, false);
		if(acctRT != null){
			testAcc.RecordTypeId = acctRT.Id;
		}
		testAcc.Name = 'Test Account';
		testAcc.BillingCity = 'Boston';
		testAcc.AccountSource = 'TestClass';
		testAcc.BillingStreet = '1 Main St';

		insert testAcc; // inserts but since there are no contacts to sync, it ignores them, will update only if the ones are inserted at same time or via child relations

		Contact testCon = TestDataGenerator.createContact(testAcc, conRT.Name, false);
		testCon.LastName = 'TestLast';

		insert testCon; // I am just populated required fields. rest will be updated via code. 

		Test.startTest();

			// Add a field Mapping
			Field_Mapping__c newFieldMap = new Field_Mapping__c(Object_Mapping__c=testObj.Id,Source_Field__c='BillingStreet',Target_Field__c='MailingStreet');
			insert newFieldMap; // This will fire the trigger. and do the sync

		Test.stopTest();

		testCon = [Select Id, FirstName, LastName, MailingCity,MailingStreet from Contact where Id = :testCon.Id];
		system.assertEquals(testAcc.Name, testCon.FirstName); // Assert that sync is done
		system.assertEquals(testAcc.BillingCity,testCon.MailingCity); // Assert Sync is done.
		system.assertEquals(testAcc.BillingStreet,testCon.MailingStreet); // Assert Sync is done.

	}
	
	@isTest static void objectMapHandlerTest2() {
		// Load Object Maps	
		Object_Map__c testObj = new Object_Map__c();

		testObj.Source_Object__c = 'Account'; // Is the best Test 
		testObj.Target_Object__c = 'Contact';
		testObj.Parent_Sync__c = false;
		testObj.Two_way_Sync__c = true;
		testObj.Include_Inserts__c = true;
		RecordType acctRT;
		RecordType conRT;
		
		try {
			acctRT = [Select Id, Name from RecordType where SObjectType='Account' LIMIT 1];
		}catch(Exception e){

		}

		if(acctRT != null)
			testObj.Source_Record_Types__c = acctRT.Id;

		try {
			conRT = [Select Id, Name from RecordType where SObjectType='Contact' LIMIT 1];
		}catch(Exception e){

		}

		if(conRT != null)
			testObj.Target_Record_Types__c = conRT.Id;
		
		testObj.Related_to_Source__c = 'AccountId'; // Contact is related to Account via AccountId

		insert testObj;

		List<Field_Mapping__c> fmappings = new List<Field_Mapping__c>();
		
		fmappings.add(new Field_Mapping__c(Object_Mapping__c=testObj.Id,Source_Field__c='Name',Target_Field__c='FirstName'));
		fmappings.add(new Field_Mapping__c(Object_Mapping__c=testObj.Id,Source_Field__c='BillingCity',Target_Field__c='MailingCity'));

		insert fmappings;

		// Load actual records
		Account testAcc = TestDataGenerator.createAccount(acctRT.Name, false);
		if(acctRT != null){
			testAcc.RecordTypeId = acctRT.Id;
		}
		testAcc.Name = 'Test Account';
		testAcc.BillingCity = 'Boston';
		testAcc.AccountSource = 'TestClass';
		testAcc.BillingStreet = '1 Main St';

		insert testAcc; // inserts but since there are no contacts to sync, it ignores them, will update only if the ones are inserted at same time or via child relations

		Contact testCon = TestDataGenerator.createContact(testAcc, conRT.Name, false);
		testCon.LastName = 'TestLast';

		insert testCon; // I am just populated required fields. rest will be updated via code. 

		Test.startTest();

			// Update field mappings
			fmappings[1].Source_Field__c = 'BillingStreet';
			fmappings[1].Target_Field__c = 'MailingStreet';
			update fmappings[1]; // This will fire the trigger. and do the sync

		Test.stopTest();

		testCon = [Select Id, FirstName, LastName, MailingCity,MailingStreet from Contact where Id = :testCon.Id];
		system.assertEquals(testAcc.Name, testCon.FirstName); // Assert that sync is done
		system.assertEquals(testAcc.BillingStreet,testCon.MailingStreet); // Assert Sync is done.
	}
*/	
}