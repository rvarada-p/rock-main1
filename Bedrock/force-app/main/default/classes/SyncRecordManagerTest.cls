@isTest
private class SyncRecordManagerTest {
	

	
	/*
		This test class tests the SyncRecordManager class. This is not dependant on any custom objects.

		It uses Account and Contacts as examples and allows you to do the Syncs.
	
		Basically can be deployed in any org without overhead of any custom objects.
	*/
	

	// Basic test method with account as parent and AccountSync as child

	@isTest static void testSyncRecordManager() {
		
		// First create the Object Maps. 

		//SELECT Parent_Sync__c, Source_Record_Types__c, Target_Record_Types__c, Source_Object__c, Target_Object__c, Related_to_Source__c, Child_Relationship_Name__c, Two_way_Sync__c, (SELECT Source_Field__c, Target_Field__c, isReferenceField__c from Field_Mappings__r) from Object_Map__c ';
		Object_Map__c testObj = new Object_Map__c();

		testObj.Source_Object__c = 'Contact'; // Is the best Test 
		testObj.Target_Object__c = 'Brand_Profile__c';
		testObj.Parent_Sync__c = false;
		testObj.Two_way_Sync__c = true;
		testObj.Include_Inserts__c = true;		
		RecordType conRT;
		RecordType nbrandProfileRT;
		try {
			nbrandProfileRT = [Select Id, Name from RecordType where SObjectType='Brand_Profile__c' LIMIT 1];
		}catch(Exception e){

		}

		if(nbrandProfileRT != null)
			testObj.Target_Record_Types__c = nbrandProfileRT.Id;

		try {
			conRT = [Select Id, Name from RecordType where SObjectType='Contact' LIMIT 1];
		}catch(Exception e){

		}

		if(conRT != null)
			testObj.Source_Record_Types__c= conRT.Id;
		
		testObj.Related_to_Source__c = 'Contact__c'; // Brand profile is related to Contact via Contact__c

		insert testObj;
		system.debug('testObj:::::::::::::::;'+testObj);
		List<Field_Mapping__c> fmappings = new List<Field_Mapping__c>();
		
		fmappings.add(new Field_Mapping__c(Object_Mapping__c=testObj.Id,Source_Field__c='Email',Target_Field__c='Email__c'));
		fmappings.add(new Field_Mapping__c(Object_Mapping__c=testObj.Id,Source_Field__c='Phone',Target_Field__c='Phone__c'));

		insert fmappings;

		Test.startTest();
			Account testAcc = TestDataGenerator.createAccount(true);
        	Contact testCon = TestDataGenerator.createContact(testAcc, conRT.Name, false);//new Contact();
			//testCon.AccountId = testAcc.Id;
			testCon.Email = 'test.123456@test.com';
			testCon.Phone = '828-287-2874';
			testCon.RecordTypeId = conRT.ID;
			insert testCon; // I am just populated required fields. rest will be updated via code. 
			// create brand profile record
			Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        	testProfile1.Email__c = 'test12@test12345.Com';
        	testProfile1.Phone__c = '123-133-1444';
        	testProfile1.Contact__c = testCon.ID;
        	testProfile1.RecordTypeId = nbrandProfileRT.ID;
        	insert testProfile1;
			SyncRecordManager manager = new SyncRecordManager(false,1);
			SyncRecordManager.isInsert = true;
			system.debug('clalling doSync::::::::::::::::::::::::::::;');
			manager.doSync(new list<Contact>{testCon}); // This will call the sync method.
			system.debug('Finish doSync::::::::::::::::::::::::::::;');
			Brand_Profile__c updatedProfile1 = [Select ID,Email__c,Phone__c,Contact__c from Brand_Profile__c where id=: testProfile1.ID];
			system.debug('updatedProfile1::::::::::::::::::::::::::::;'+updatedProfile1);
			system.debug('testCon::::::::::::::::::::::::::::;'+testCon);
			system.assertEquals(updatedProfile1.Email__c, testCon.Email); // Assert that sync is done
			system.assertEquals(updatedProfile1.Phone__c,testCon.Phone); // Assert Sync is done.
		Test.stopTest();


	}

	// This method will do the two way sync, means it updates the Contacts and verifies if the Account gets updated by doing sync.

	@isTest static void testSyncRecordManager2() {
		
		// First create the Object Maps. 

		//SELECT Parent_Sync__c, Source_Record_Types__c, Target_Record_Types__c, Source_Object__c, Target_Object__c, Related_to_Source__c, Child_Relationship_Name__c, Two_way_Sync__c, (SELECT Source_Field__c, Target_Field__c, isReferenceField__c from Field_Mappings__r) from Object_Map__c ';
		Object_Map__c testObj = new Object_Map__c();

		testObj.Source_Object__c = 'Contact'; // Is the best Test 
		testObj.Target_Object__c = 'Brand_Profile__c';
		testObj.Parent_Sync__c = false;
		testObj.Two_way_Sync__c = true;
		testObj.Include_Inserts__c = true;
		RecordType brandProfileRT;
		RecordType conRT;
		
		try {
			brandProfileRT = [Select Id, Name from RecordType where SObjectType='Brand_Profile__c' LIMIT 1];
		}catch(Exception e){

		}		

		try {
			conRT = [Select Id, Name from RecordType where SObjectType='Contact' LIMIT 1];
		}catch(Exception e){

		}
		if(conRT != null)
			testObj.Source_Record_Types__c = conRT.Id;
		if(brandProfileRT != null)
			testObj.Target_Record_Types__c = brandProfileRT.Id;
		
		testObj.Related_to_Source__c = 'Contact__c'; // Contact is related to Account via AccountId

		insert testObj;

		List<Field_Mapping__c> fmappings = new List<Field_Mapping__c>();
		
		fmappings.add(new Field_Mapping__c(Object_Mapping__c=testObj.Id,Source_Field__c='Email',Target_Field__c='Email__c'));
		fmappings.add(new Field_Mapping__c(Object_Mapping__c=testObj.Id,Source_Field__c='Phone',Target_Field__c='Phone__c'));

		insert fmappings;

		Test.startTest();

			Account testAcc = TestDataGenerator.createAccount(true);
        	Contact testCon = TestDataGenerator.createContact(testAcc, conRT.Name, false);//new Contact();
			//testCon.AccountId = testAcc.Id;
			testCon.Email = 'test.123456@test.com';
			testCon.Phone = '555-209-0972';
			testCon.RecordTypeId = conRT.ID;
			insert testCon; // I am just populated required fields. rest will be updated via code. 
			// create brand profile record
			Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        	testProfile1.Email__c = 'test12@test12345.Com';
        	testProfile1.Phone__c = '950-744-8622';
        	testProfile1.Contact__c = testCon.ID;
        	testProfile1.RecordTypeId = brandProfileRT.ID;
        	insert testProfile1;
			SyncRecordManager manager = new SyncRecordManager(false,1);
			SyncRecordManager.isInsert = true;
			system.debug('clalling doSync::::::::::::::::::::::::::::;');
			manager.doSync(new list<Contact>{testCon}); // This will call the sync method.
			system.debug('Finish doSync::::::::::::::::::::::::::::;');
			Brand_Profile__c updatedProfile1 = [Select ID,Email__c,Phone__c from Brand_Profile__c where id=: testProfile1.ID];
			system.debug('updatedProfile1::::::::::::::::::::::::::::;'+updatedProfile1);
			system.debug('testCon::::::::::::::::::::::::::::;'+testCon);
			system.assertEquals(updatedProfile1.Email__c, testCon.Email); // Assert that sync is done
			system.assertEquals(updatedProfile1.Phone__c,testCon.Phone); // Assert Sync is done.
			// 2 way sync.
		Test.stopTest();
	}

	
}