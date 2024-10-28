/************************************************************************
Name  : SMEMessages_Test
Developer: Sarah Khalid, Jan 2017
Description: Apex test class for the SMEMessagesController Apex class
*************************************************************************/

@isTest
private class SMEMessages_Test {

    static testMethod void testArchivedMessages() {
        // Create test data
		D2L__c d2L = new D2L__c();
        d2L.Name = 'D2L';
        d2L.Create_User_Endpoint__c = '/d2l/api/lp/(version)/users/';
        d2L.Student_Role_ID__c = 110;
        d2L.Create_Enrollment_Endpoint__c = '/d2l/api/lp/(version)/enrollments/';
        d2L.BS_LMS_URL__c = 'https://tempolearningtest.brightspace.com/d2l/home/';
        d2L.LP_Version__c = 1.18;
        d2L.Org_Unit_ID__c = 6606;
        d2L.Update_User__c = '/d2l/api/lp/(version)/users/(userId)';
        d2L.Unenrolled_Student_Role_ID__c = 116;
        d2L.Unenroll_Section_Endpoint__c = '/d2l/api/lp/(version)/enrollments/orgUnits/(orgUnitId)/users/(userId)';
        insert d2L;
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Competency', 'Student_Competency__c','Walden', true);
        //Create test users
	    User testUser1 = createUser('testSMEFName', 'testSMELName', 'CBL SME Chatter Only', true);
	    Id userId = testUser1.Id;
	        
	    User tempoChatterFreeUser = createUser('testFN', 'testLN', 'Tempo Chatter Free', false);
	    tempoChatterFreeUser.Tempo_Id__c = 'abc123';
	    insert tempoChatterFreeUser;
		
		//Insert the custom settings for error messages	
		SME_Dashboard__c setting = new SME_Dashboard__c();
		setting.Name = 'Current Settings';
		setting.Empty_Dashboard_Error_Message__c = 'Test';		
		insert setting;
            
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
	    Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);        
	    Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
	    product2.Parent_Program__c = parentProduct.Id;
	    insert product2;    
	    
        Opportunity opp1 = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp1.Primary_Program__c = product2.Id;
        insert opp1;
	    
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);  
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Program_Expertise__c pExperise = TestDataGenerator.createProgramExpertise(aExper.ID,product2.ID,true,5.0,true);
        Program_Competency__c pCompetemcy = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0, false);
        pCompetemcy.Program_Expertise__c = pExperise.ID;
        insert pCompetemcy;
        Student_Expertise__c sExpertise = TestDataGenerator.createCompetencyExpertise(aExper.Id,null, false);
        sExpertise.Contact__c = testCon.id;
        sExpertise.Program_Expertise__c = pExperise.ID;
        insert sExpertise;
        
        //create student program
        Student_Program__c sp1 = TestDataGenerator.createStudentProgram(opp1,testCon.ID, 'Walden', false);
        sp1.Application__c = opp1.ID;
        sp1.IsStudentProgramActive__c = true;
        insert sp1;		
       
               
        // create strudent competency
        Student_Competency__c sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency.Contact__c = testCon.id;
        sCometency.Program_Competency__c = pCompetemcy.ID;
        sCometency.Assessment_Submitted__c = true;
        sCometency.Is_Enrolled__c = true;
        sCometency.SME__c = userId;
        sCometency.Student_Program__c = sp1.Id;
        sCometency.IsCompleted__c = true;
        insert sCometency;
        
        //Create ChatterSCMessages
        ChatterSCMessage__c scMsg1 = new ChatterSCMessage__c();
        scMsg1.SME__c = userId;
        scMsg1.Status__c = 'Un-Read';
        scMsg1.Student__c = tempoChatterFreeUser.Id;
        scMsg1.Student_Competency__c = sCometency.Id;
 		insert scMsg1;      
 		 
        ChatterSCMessage__c scMsg2 = new ChatterSCMessage__c();
        scMsg2.SME__c = userId;
        scMsg2.Status__c = 'Un-Read';
        scMsg2.Student__c = tempoChatterFreeUser.Id;
        scMsg2.Student_Competency__c = sCometency.Id;
 		insert scMsg2; 	
 		
 		test.startTest();
 			        
 		System.runAs(testUser1) {
	        PageReference pageRef = Page.SMEMessages;
	        SMEMessagesController controller = new SMEMessagesController();
	        controller.isArchived = 'true';
 		}
 		
 		test.stopTest();
    }

    static testMethod void testNonArchivedMessages() {
        // Create test data
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Competency', 'Student_Competency__c','Walden', true);
        //Create test users
	    User testUser1 = createUser('testSMEFName', 'testSMELName', 'CBL SME Chatter Only', true);
	    Id userId = testUser1.Id;
	        
	    User tempoChatterFreeUser = createUser('testFN', 'testLN', 'Tempo Chatter Free', false);
	    tempoChatterFreeUser.Tempo_Id__c = 'abc123';
	    insert tempoChatterFreeUser;
		
		//Insert the custom settings for error messages	
		SME_Dashboard__c setting = new SME_Dashboard__c();
		setting.Name = 'Current Settings';
		setting.Empty_Dashboard_Error_Message__c = 'Test';		
		insert setting;
            
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
	    Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);        
	    Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
	    product2.Parent_Program__c = parentProduct.Id;
	    insert product2;    
	    
        Opportunity opp1 = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp1.Primary_Program__c = product2.Id;
        insert opp1;
	    
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);  
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Program_Expertise__c pExperise = TestDataGenerator.createProgramExpertise(aExper.ID,product2.ID,true,5.0,true);
        Program_Competency__c pCompetemcy = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0, false);
        pCompetemcy.Program_Expertise__c = pExperise.ID;
        insert pCompetemcy;
        Student_Expertise__c sExpertise = TestDataGenerator.createCompetencyExpertise(aExper.Id,null, false);
        sExpertise.Contact__c = testCon.id;
        sExpertise.Program_Expertise__c = pExperise.ID;
        insert sExpertise;
        
        //create student program
        Student_Program__c sp1 = TestDataGenerator.createStudentProgram(opp1,testCon.ID, 'Walden', false);
        sp1.Application__c = opp1.ID;
        insert sp1;		
        D2L__c d2L = new D2L__c();
        d2L.Name = 'D2L';
        d2L.Create_User_Endpoint__c = '/d2l/api/lp/(version)/users/';
        d2L.Student_Role_ID__c = 110;
        d2L.Create_Enrollment_Endpoint__c = '/d2l/api/lp/(version)/enrollments/';
        d2L.BS_LMS_URL__c = 'https://tempolearningtest.brightspace.com/d2l/home/';
        d2L.LP_Version__c = 1.18;
        d2L.Org_Unit_ID__c = 6606;
        d2L.Update_User__c = '/d2l/api/lp/(version)/users/(userId)';
        d2L.Unenrolled_Student_Role_ID__c = 116;
        d2L.Unenroll_Section_Endpoint__c = '/d2l/api/lp/(version)/enrollments/orgUnits/(orgUnitId)/users/(userId)';
        insert d2L;
        
        sp1.IsStudentProgramActive__c = true;
        update sp1;
        
        // create strudent competency
        Student_Competency__c sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency.Contact__c = testCon.id;
        sCometency.Program_Competency__c = pCompetemcy.ID;
        sCometency.Assessment_Submitted__c = true;
        sCometency.Is_Enrolled__c = true;
        sCometency.SME__c = userId;
        sCometency.Student_Program__c = sp1.Id;
        insert sCometency;
        
        //Create ChatterSCMessages
        ChatterSCMessage__c scMsg1 = new ChatterSCMessage__c();
        scMsg1.SME__c = userId;
        scMsg1.Status__c = 'Un-Read';
        scMsg1.Student__c = tempoChatterFreeUser.Id;
        scMsg1.Student_Competency__c = sCometency.Id;
 		insert scMsg1;      
 		 
        ChatterSCMessage__c scMsg2 = new ChatterSCMessage__c();
        scMsg2.SME__c = userId;
        scMsg2.Status__c = 'Un-Read';
        scMsg2.Student__c = tempoChatterFreeUser.Id;
        scMsg2.Student_Competency__c = sCometency.Id;
 		insert scMsg2; 	
 		
 		test.startTest();
 			        
 		System.runAs(testUser1) {
	        PageReference pageRef = Page.SMEMessages;
	        SMEMessagesController controller = new SMEMessagesController();
	        controller.isArchived = 'false';
 		}
 		
 		test.stopTest();
    }
    
    public static User createUser(String fName, String lName, String profileName, Boolean isInsert) {
      String orgId = UserInfo.getOrganizationId();
      String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
      Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
      String uniqueName = orgId + dateString + randomInt;

      Profile p = [SELECT Id, Name FROM Profile WHERE Name = :profileName limit 1];

      User tuser = new User(
      firstname = fName,
      lastName = lName,
      email = uniqueName + '@test' + orgId + '.org',
      Username = uniqueName + '@test' + orgId + '.tempowalden',
      EmailEncodingKey = 'ISO-8859-1',
      Alias = uniqueName.substring(18, 23),
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      LanguageLocaleKey = 'en_US',
      ProfileId = p.Id
    );

    if(isInsert) {
      insert tuser;
    }
    return tuser;
  } 
  
   @IsTest(SeeAllData=true)
   static  void callControllerMethods() {
        // Create test data
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Competency', 'Student_Competency__c','Walden', true);
        //Create test users
	    User testUser1 = createUser('testSMEFName', 'testSMELName', 'CBL SME Chatter Only', true);
	    Id userId = testUser1.Id;
	        
	    User tempoChatterFreeUser = createUser('testFN', 'testLN', 'Tempo Chatter Free', false);
	    tempoChatterFreeUser.Tempo_Id__c = 'abc123';	    
	    insert tempoChatterFreeUser;
	    
	    User tempoIntegratorUser = [SELECT Id, ProfileId FROM User WHERE ProfileId = '00eo0000001197a' LIMIT 1];
	    String tempoUserId = tempoIntegratorUser!=null ? tempoIntegratorUser.Id : '';
	    System.debug('Tempo User ID : ' + tempoIntegratorUser);
		/*
		//Insert the custom settings for error messages	
		SME_Dashboard__c setting = new SME_Dashboard__c();
		setting.Name = 'Current Settings';
		setting.Search_Error_Message__c = 'Test';
		setting.Message_Thread_Error__c = 'Test';
		setting.Chatter_Message_Error__c = 'Test';		
		insert setting;
        */    
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
	    Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);        
	    Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
	    product2.Parent_Program__c = parentProduct.Id;
	    insert product2;   
	    
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);  
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Program_Expertise__c pExperise = TestDataGenerator.createProgramExpertise(aExper.ID,product2.ID,true,5.0,true);
        Program_Competency__c pCompetemcy = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0, false);
        pCompetemcy.Program_Expertise__c = pExperise.ID;
        insert pCompetemcy;
        Student_Expertise__c sExpertise = TestDataGenerator.createCompetencyExpertise(aExper.Id,null, false);
        sExpertise.Contact__c = testCon.id;
        sExpertise.Program_Expertise__c = pExperise.ID;
        insert sExpertise;
      
        // create strudent competency
        Student_Competency__c sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency.Contact__c = testCon.id;
        sCometency.Program_Competency__c = pCompetemcy.ID;
        sCometency.Assessment_Submitted__c = true;
        sCometency.Is_Enrolled__c = true;
        sCometency.SME__c = userId;
        insert sCometency; 
        
        //Create ChatterSCMessages
	     PrivateChatterMessageController testController = new PrivateChatterMessageController();            
	    //Test Sending New Message
	    String conversationId = PrivateChatterMessageController.processSendNewMessage('Test Message to user2 from tempoIntegratorUser',tempoUserId);
	    String conversationId2 = PrivateChatterMessageController.processSendNewMessage('Test Message to user2 from user1',userId);
	    
        //Create ChatterSCMessages
        ChatterSCMessage__c scMsg1 = new ChatterSCMessage__c();
        scMsg1.SME__c = userId;
        scMsg1.Status__c = 'Un-Read';
        scMsg1.Student__c = tempoChatterFreeUser.Id;
        scMsg1.Student_Competency__c = sCometency.Id;
        scMsg1.MessageID__c = conversationId;
		 
        ChatterSCMessage__c scMsg2 = new ChatterSCMessage__c();
        scMsg2.SME__c = userId;
        scMsg2.Status__c = 'Un-Read';
        scMsg2.Student__c = tempoChatterFreeUser.Id;
        scMsg2.Student_Competency__c = sCometency.Id;
        scMsg2.MessageID__c = conversationId2;

		list<ChatterSCMessage__c> messageList = new list<ChatterSCMessage__c>();
		messageList.add(scMsg1);
		messageList.add(scMsg2);
		insert messageList;
		
		test.startTest();
		
 		System.runAs(testUser1) {
	        PageReference pageRef = Page.SMEMessages;
	        SMEMessagesController controller = new SMEMessagesController();
	        controller.searchString = 'test';
	        controller.selectedSCId = sCometency.Id;
	        controller.isArchived = 'false';
	        controller.loadMessageDetails();
	        Test.setMock(HttpCalloutMock.class, new MockHttpResponseChatter());
			MockHttpResponseChatter test1 = new MockHttpResponseChatter();
			HttpRequest req = new HttpRequest();
	    	String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
	    	String url =  salesforceHost + '/services/data/v26.0/chatter/users/me/messages/';
			req.setEndpoint(url);
			req.setMethod('GET');
 			HttpResponse res = test1.respond(req);
 			
 			
 			
 			SMEMessagesController.res = res;
 			SMEMessagesController.markEngagementMet(sCometency.Id);
 			controller.markMessagesRead(messageList);
	        SMEMessagesController.insertChatterMessage(sCometency.Id, userId, tempoChatterFreeUser.Id, 'Test Message');
	        controller.runSearch();
	        
 		}
 		
 		test.stopTest();  	
  }
  /*
   @IsTest(SeeAllData=true)
   static void callDoSearch() {
        // Create test data
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Competency', 'Student_Competency__c','Walden', true);
        //Create test users
	    User testUser1 = createUser('testSMEFName', 'testSMELName', 'CBL SME Chatter Only', true);
	    Id userId = testUser1.Id;
	        
	    User tempoChatterFreeUser = createUser('testFN', 'testLN', 'Tempo Chatter Free', false);
	    tempoChatterFreeUser.Tempo_Id__c = 'abc123';
	    
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
	    Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);        
	    Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
	    product2.Parent_Program__c = parentProduct.Id;
	    insert product2;    
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);  
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Program_Expertise__c pExperise = TestDataGenerator.createProgramExpertise(aExper.ID,product2.ID,true,5.0,true);
        Program_Competency__c pCompetemcy = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0, false);
        pCompetemcy.Program_Expertise__c = pExperise.ID;
        insert pCompetemcy;
        Student_Expertise__c sExpertise = TestDataGenerator.createCompetencyExpertise(aExper.Id,null, false);
        sExpertise.Contact__c = testCon.id;
        sExpertise.Program_Expertise__c = pExperise.ID;
        insert sExpertise;
        // create strudent competency
        Student_Competency__c sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency.Contact__c = testCon.id;
        sCometency.Program_Competency__c = pCompetemcy.ID;
        sCometency.Assessment_Submitted__c = true;
        sCometency.Is_Enrolled__c = true;
        sCometency.SME__c = userId;
        insert sCometency; 
		//list<ChatterSCMessage__c> messageList = new list<ChatterSCMessage__c>();
                  
	     PrivateChatterMessageController testController = new PrivateChatterMessageController();            
	    //Test Sending New Message
	    String conversationId = PrivateChatterMessageController.processSendNewMessage('Test Message to user2 from user1',userId);
	    system.assert(conversationId <> null);

        //Create ChatterSCMessages
        ChatterSCMessage__c scMsg1 = new ChatterSCMessage__c();
        scMsg1.SME__c = userId;
        scMsg1.Status__c = 'Un-Read';
        scMsg1.Student__c = tempoChatterFreeUser.Id;
        scMsg1.Student_Competency__c = sCometency.Id;
        scMsg1.MessageID__c = conversationId;
 		insert scMsg1;      
 		 
        ChatterSCMessage__c scMsg2 = new ChatterSCMessage__c();
        scMsg2.SME__c = userId;
        scMsg2.Status__c = 'Un-Read';
        scMsg2.Student__c = tempoChatterFreeUser.Id;
        scMsg2.Student_Competency__c = sCometency.Id;
        scMsg2.MessageID__c = conversationId;
 		insert scMsg2; 	
	      
		test.startTest();
		
 		System.runAs(testUser1) {
	        PageReference pageRef = Page.SMEMessages;
	        SMEMessagesController controller = new SMEMessagesController();
	        controller.searchString = 'test';
 	        controller.runSearch();
	        controller.searchString = '1234';
	        controller.runSearch();
	        controller.loadMessageDetails();
 		}
 		
 		test.stopTest();  	
  }  
  */
}