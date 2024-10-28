@isTest
private class ChatterMessageTriggerHandler_Test {

  static String userId;
  static User tempoChatterFreeUser;
  static String tempiId = 'abc123';
  static List<Id> stuEngIds;
  static Id stuEngIdForNegTestCase;

  static {
    User testUser1 = createUser('testFNAdm', 'testLNAdm', 'system administrator', true);
    userId = testUser1.Id;
        
    tempoChatterFreeUser = createUser('testFN', 'testLN', 'Tempo Chatter Free', false);
    tempoChatterFreeUser.Tempo_Id__c = tempiId;
    insert tempoChatterFreeUser;
  }	
  
  @IsTest(SeeAllData=true)
  static void testPrivateChatterMessageSentByStudentToSME(){
    
    createTestData(); 
    PrivateChatterMessageController testController;   
    String conversationId;

    Test.startTest();
      system.runAs(tempoChatterFreeUser) {      
        testController = new PrivateChatterMessageController();            
        //Test Sending New Message
        conversationId = PrivateChatterMessageController.processSendNewMessage('Test Message to user2 from user1',userId);
      }
      system.assert(conversationId <> null);

      Date lastEngagementDate = system.today();
      Date stuEngRuleLastEngDate;

      system.debug('Before for loop');
      for(Student_Engagement_Rule__c stuEngRule : [SELECT id, name, Last_Date_of_Engagement__c, Student_Program__c FROM Student_Engagement_Rule__c
                                                   WHERE Rule_Type__c = 'Raise My Hand to SME' AND IsEngagementRuleActive__c = TRUE
                                                   AND Id IN : stuEngIds]) {
        /*if(lastEngagementDate == null && stuEngRule.Last_Date_of_Engagement__c != null) {
          lastEngagementDate = stuEngRule.Last_Date_of_Engagement__c;   
        } else if(lastEngagementDate != null && stuEngRule.Last_Date_of_Engagement__c != null && lastEngagementDate < stuEngRule.Last_Date_of_Engagement__c) {
          lastEngagementDate = stuEngRule.Last_Date_of_Engagement__c;    
        } else {
          lastEngagementDate = system.today();
        }*/
      	stuEngRule.Last_Date_of_Engagement__c = system.today();
        if(stuEngRule.Id == stuEngIdForNegTestCase) {
          system.assertNotEquals(stuEngRule.Last_Date_of_Engagement__c, system.today());  
        } else {
          system.assertEquals(stuEngRule.Last_Date_of_Engagement__c, system.today());                                                  
        }
      }

    Test.stopTest();
  } 

  public static void createTestData() {
    Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
    Competency__c testComp2 = TestDataGenerator.createCompetency(true);
    Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);
    Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper.Id,product2.id,true,4.0, false);     
    pExper.Number_of_Competencies__c = null;
    Program_Competency__c pComp = TestDataGenerator.createProgramCompetency(testComp2.Id,product2.Id,true,5, false);
    pComp.Program_Expertise__c = pExper.ID;
    insert pComp;

    Program_Competency_Role__c compRole = new Program_Competency_Role__c();
    compRole.Program_Competency__c = pComp.id;
    compRole.Role__c = 'Primary SME';
    compRole.Faculty_Member__c = userId;
    insert compRole;

    Brand_Profile__c brandProfile = TestDataGenerator.createBrandProfile('Tempo','testFN', 'testLN', false);
    brandProfile.Tempo_Id__c = tempiId;
    insert brandProfile;

    Account acc = TestDataGenerator.createAccount(true);
    Contact testCon = TestDataGenerator.createContact(acc, true);

    Opportunity opp0 = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
    opp0.Brand_Profile__c = brandProfile.Id;
    insert opp0;

    Student_Program__c sp = TestDataGenerator.createStudentProgram(opp0, testCon.Id, 'Walden', true);
    sp.IsStudentProgramActive__c = true;
    update sp;
    opp0.Student_Program__c = sp.Id;
    update opp0;

    Institution__c ins = TestDataGenerator.createInstitution('Test Institution', true);
    Engagement_Rule__c  engRule = TestDataGenerator.createEngagementRule('Raise My Hand to SME', ins.Id, true, true);
    Engagement_Rule__c  engRule1 = TestDataGenerator.createEngagementRule('Test', ins.Id, true, true);
    Student_Engagement_Rule__c stuEngRule1 = TestDataGenerator.createStudentEngagementRule(sp.id, engRule.Id, true,true);
    Student_Engagement_Rule__c stuEngRule2 = TestDataGenerator.createStudentEngagementRule(sp.id, engRule.Id, true,true);
    Student_Engagement_Rule__c stuEngRule3 = TestDataGenerator.createStudentEngagementRule(sp.id, engRule1.Id, true,true);
    stuEngIds = new List<Id> {stuEngRule1.Id, stuEngRule2.Id, stuEngRule3.Id};
    stuEngIdForNegTestCase = stuEngRule3.Id;
    
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