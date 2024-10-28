/************************************************************************
Name  : SMEDashboard_Test
Developer: Sarah Khalid, Jan 2017
Description: Apex test class for the SMEDashboardController Apex class
*************************************************************************/

@isTest
private class SMEDashboard_Test {

    static testMethod void smeDashboardPage() {
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
        Student_Program__c sp1 = TestDataGenerator.createStudentProgram(opp1,testCon.ID, 'Walden', false);
        sp1.Application__c = opp1.ID;
        sp1.IsStudentProgramActive__c = true;
        insert sp1;		
	          
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
        sCometency.Student_Program__c = sp1.Id;
        insert sCometency;
        //create another student competency
        Student_Competency__c sCometency2 = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency2.Contact__c = testCon.id;        
        sCometency2.Program_Competency__c = pCompetemcy.ID;
        sCometency2.Assessment_Submitted__c = true;
        sCometency2.Is_Enrolled__c = true;
        sCometency2.SME__c = userId;
        sCometency2.IsCompleted__c = true;
        sCometency2.Student_Program__c = sp1.Id;
        insert sCometency2;        
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
 	
 		
 		system.debug('SCs: ' + sCometency + ' isstudentprogramactive ');	 
 		System.debug('SP: ' + sp1 + ' isstudentprogramactive ' + sp1.IsStudentProgramActive__c);       
 		System.runAs(testUser1) {
 			System.debug('running as : ' + testUser1);
 			Test.startTest(); 			
	        PageReference pageRef = Page.SMEDashboard;
	        SMEDashboardController controller = new SMEDashboardController();
	        Test.stopTest();
 		}
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
      Username = uniqueName + '@test' + orgId + '.org',
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
}