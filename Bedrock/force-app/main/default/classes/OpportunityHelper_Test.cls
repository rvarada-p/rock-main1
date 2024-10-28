/*******************************************************************
Name  : OpportunityHelper_Test
Author: Bryan Leboff (Appirio)
Date  : October 15, 2014
Description: Test for Helper  class for Opportunity
*************************************************************************/  
@isTest
private class OpportunityHelper_Test {
    private static List<Opportunity> opps;
    private static void setup(){
        RecordTypes_For_CBL_Processes__c objCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Subscription', 'Student_Subscription__c','Walden', true);
        //TriggerSettings__c objTrgSetting = TestDataGenerator.createTriggerSettings('StudentSubscriptionTrigger', true, true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);        
        List<Product2> products = new List<Product2>();
        Product2 prod1 = TestDataGenerator.createProduct('test0', 'Walden', false);
        prod1.Parent_Program__c = parentProduct.id;
        products.add(prod1);
        Product2 prod2 = TestDataGenerator.createProduct('test0', 'Walden', false);
        prod2.Parent_Program__c = parentProduct.id;
        products.add(prod2);    
        Product2 prod3 = TestDataGenerator.createProduct('test0', 'Walden', false);
        prod3.Parent_Program__c = parentProduct.id;
        products.add(prod3);                
        insert products;

        opps = new List<Opportunity>();
        Opportunity opp0 = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp0.Primary_Program__c = products.get(0).Id;
        opps.add(opp0);
        Opportunity opp1 = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp1.Primary_Program__c = products.get(1).Id;
        opps.add(opp1); 
        Opportunity opp2 = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp2.Primary_Program__c = products.get(2).Id;
        opps.add(opp2);
        insert opps; 
        

        //create standard pricebook
        Id standardPricebookId = Test.getStandardPricebookId();

        //create standard prices
        Test.startTest();
        List<PriceBookEntry> standardEntries = new List<PricebookEntry>();
        standardEntries.add(TestDataGenerator.createPricebookEntry(parentProduct.id, standardPricebookId, 100, false, false));
        //standardEntries.add(TestDataGenerator.createPricebookEntry(parentProduct.id, standardPricebookId, 100, false, false));
        //standardEntries.add(TestDataGenerator.createPricebookEntry(parentProduct.id, standardPricebookId, 100, false, false));
        //standardEntries.add(TestDataGenerator.createPricebookEntry(parentProduct.id, standardPricebookId, 100, false, false));
        insert standardEntries;

        List<PriceBookEntry> pricebookentries = new List<PricebookEntry>();
        pricebookentries.add(TestDataGenerator.createPricebookEntry(parentProduct.id, opps.get(0).Initial_Price_Book__c, 1000, false, false));
        //pricebookentries.add(TestDataGenerator.createPricebookEntry(parentProduct.id, opps.get(0).Initial_Price_Book__c, 2000, false, false));
        //pricebookentries.add(TestDataGenerator.createPricebookEntry(parentProduct.id, opps.get(1).Initial_Price_Book__c, 3000, false, false));
        //pricebookentries.add(TestDataGenerator.createPricebookEntry(parentProduct.id, opps.get(1).Initial_Price_Book__c, 4000, false, false));
        //pricebookentries.add(TestDataGenerator.createPricebookEntry(parentProduct.id, opps.get(2).Initial_Price_Book__c, 5000, false, false));
        insert pricebookentries;
  
        //now setup exemptions
        List<Exemption__c> exemptions = new List<Exemption__c>();
        exemptions.add(TestDataGenerator.createExemption(0,1,false));
        exemptions.add(TestDataGenerator.createExemption(100,0,false));
        exemptions.add(TestDataGenerator.createExemption(0,2,false));
        insert exemptions;

        //now setup student discounts
        List<Student_Discount__c> studentDiscounts = new List<Student_Discount__c>();
        studentDiscounts.add(TestDataGenerator.createStudentDiscount(opps.get(0), null, exemptions.get(0), false));
        studentDiscounts.add(TestDataGenerator.createStudentDiscount(opps.get(0), null, exemptions.get(1), false));
        studentDiscounts.add(TestDataGenerator.createStudentDiscount(opps.get(1), null, exemptions.get(2), false));
        insert studentDiscounts;
        Test.stopTest();
    }
    
    @isTest static void testCalculateAmountAfterDiscount() {
        setup();
        OpportunityHelper.calculateAmountAfterDiscount(opps);
        
        //System.assertEquals(890, opps.get(0).amount);
        //System.assertEquals(2940, opps.get(1).amount);
        //System.assertEquals(5000, opps.get(2).amount);

    }

    @isTest static void testConstructor() {
        test.startTest();
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Opportunity opp0 = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', true);

        OpportunityHelper oh = new OpportunityHelper(opp0);
        OpportunityHelper ohno = new OpportunityHelper();
        System.assertEquals(opp0.id, oh.getOpp().id);
        System.assertNotEquals(null, ohno);
        test.stopTest();
    }

 @isTest
  static void testRunNullRoundRobin()
  {

        RecordTypes_For_CBL_Processes__c objCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Subscription', 'Student_Subscription__c','Walden', true);
        //TriggerSettings__c objTrgSetting = TestDataGenerator.createTriggerSettings('StudentSubscriptionTrigger', true, true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);               
        Product2 testProd =  TestDataGenerator.createProduct('test0', 'Walden', false);
        testProd.Parent_Program__c = parentProduct.id;
        insert testProd;
        Opportunity opp0 = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp0.Primary_Program__c = testProd.Id;
        opp0.RunRoundRobin__c = true;
        insert opp0;

       // Opp = [Select id, Ownerid from Opportunity where id=:Opp.id LIMIT 1];
       // System.assertEquals(Opp.Ownerid, UserInfo.getUserId());

  }

  @isTest
  static void tesStandardRoundRobin()
  {
        
        string strRandom = string.valueOf( Math.random());
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser'+strRandom+'@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='yyyywwwwwqq'+strRandom+'@testorg.com');
        insert u;
        
        // Implement test code
        Assignment_Group_Name__c AG = new Assignment_Group_Name__c(name='test');
        insert AG;

        Assignment_Groups__c GroupMem= new Assignment_Groups__c(Group_Name__c=AG.id);
        GroupMem.Active__c='True';
        GroupMem.Last_Assignment__c = datetime.now();
        GroupMem.User__c = u.id;
        insert GroupMem;

        Opportunity_Assignment_Rule__c NewRule = new Opportunity_Assignment_Rule__c(NAme='testrule', Is_Active__c=true);
        insert NewRule;

        Assignment_Rule_Entry__c NewEntry = new Assignment_Rule_Entry__c(Opportunity_Assignment_Rule__c=NewRule.id, Order_Number__c=1, Assign_to_Assignment_Group__c=ag.id);
        insert NewEntry;

        //Account a = new account(name='test');
        //insert a;

        Account a = TestDataGenerator.createAccount(true);
      
        List<Assignment_Rule_Entry_Condition__c> conditions = new List<Assignment_Rule_Entry_Condition__c>();
        Assignment_Rule_Entry_Condition__c Condition = new Assignment_Rule_Entry_Condition__c(Assignment_Rule_Entry__c = NewEntry.id);
        Condition.LineNumber__c = 1;
        Condition.Field_API_Name__c = 'Createddate';
        Condition.Field_Type__c = 'DATETIME';
        Condition.Operator__c = 'greater than';
        Condition.Value__c = '2005-10-08 01:02:03';
        Condition.Value_SOAP_Type__c = 'DATETIME';
        conditions.add(condition);

        Assignment_Rule_Entry_Condition__c Condition2 = new Assignment_Rule_Entry_Condition__c(Assignment_Rule_Entry__c = NewEntry.id);
        Condition2.LineNumber__c = 2;
        Condition2.Field_API_Name__c = 'StageName';
        Condition2.Field_Type__c = 'STRING';
        Condition2.Operator__c = 'equals';
        Condition2.Value__c = 'Qualified';
        Condition2.Value_SOAP_Type__c = 'STRING';
        conditions.add(condition2);

        /*
        Assignment_Rule_Entry_Condition__c Condition3 = new Assignment_Rule_Entry_Condition__c(Assignment_Rule_Entry__c = NewEntry.id);
        Condition3.LineNumber__c = 3;
        Condition3.Field_API_Name__c = 'Primary_Program__r.Name';
        Condition3.Assignment_Rule_Entry__c =NewEntry.id;
        Condition3.Field_Type__c = 'STRING';
        Condition3.Operator__c = 'equals';
        Condition3.Value__c = 'test0';
        Condition3.Value_SOAP_Type__c = 'STRING';
        conditions.add(condition3);*/
        

        Assignment_Rule_Entry_Condition__c Condition4 = new Assignment_Rule_Entry_Condition__c(Assignment_Rule_Entry__c = NewEntry.id);
        Condition4.LineNumber__c = 4;
        Condition4.Field_API_Name__c = 'TotalOpportunityQuantity';
        Condition4.Field_Type__c = 'DOUBLE';
        Condition4.Operator__c = 'equals';
        Condition4.Value__c = '1';
        Condition4.Value_SOAP_Type__c = 'DOUBLE';
        conditions.add(Condition4);
        
        Assignment_Rule_Entry_Condition__c Condition5 = new Assignment_Rule_Entry_Condition__c(Assignment_Rule_Entry__c = NewEntry.id);
        Condition5.LineNumber__c = 5;
        Condition5.Field_API_Name__c = 'CloseDate';
        Condition5.Field_Type__c = 'DATE';
        Condition5.Operator__c = 'less than';
        Condition5.Value__c = String.valueof(Date.Today().addMOnths(2)) +' 00:00:00';
        Condition5.Value_SOAP_Type__c = 'DATE';
        conditions.add(Condition5);
        

        Assignment_Rule_Entry_Condition__c Condition6 = new Assignment_Rule_Entry_Condition__c(Assignment_Rule_Entry__c = NewEntry.id);
        Condition6.LineNumber__c = 5;
        Condition6.Field_API_Name__c = 'AccountId';
        Condition6.Field_Type__c = 'ID';
        Condition6.Operator__c = 'equals';
        Condition6.Value__c = String.valueof(a.id);
        Condition6.Value_SOAP_Type__c = 'ID';
        conditions.add(Condition6);
        insert conditions;

         RecordTypes_For_CBL_Processes__c objCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Subscription', 'Student_Subscription__c','Walden', true);
        //TriggerSettings__c objTrgSetting = TestDataGenerator.createTriggerSettings('StudentSubscriptionTrigger', true, true);
        Contact testCon = TestDataGenerator.createContact(a, true);

        Product2 testProd =  TestDataGenerator.createProduct('test0', 'Walden', false);
 
        Opportunity opp0 = TestDataGenerator.createOpportunity(a.Id, testCon.Id, 'Walden', false);
        opp0.Primary_Program__c = testProd.Id;
        opp0.StageName = 'Qualified';
        opp0.CloseDate = Date.Today().addMOnths(2);
        opp0.TotalOpportunityQuantity = 1;
        opp0.RunRoundRobin__c = true;

        insert opp0;
        //Opp = [Select id, Ownerid from Opportunity where id=:Opp.id LIMIT 1];
        //System.assertEquals(Opp.Ownerid, u.id);

  }

   @isTest
  static void testCustomLookupRoundRobin()
  {
        /*
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorglaureate.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorglaureate.com');
        insert u;
        */
        string strRandom = string.valueOf( Math.random());
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser'+strRandom+'@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='yyyywwwwwqq'+strRandom+'@testorg.com', Assignment_Group_Active__c = true);
        insert u;

        // Implement test code
        Assignment_Group_Name__c AG = new Assignment_Group_Name__c(name='test');
        insert AG;

        Assignment_Groups__c GroupMem= new Assignment_Groups__c(Group_Name__c=AG.id);
        GroupMem.Active__c='True';
        GroupMem.Last_Assignment__c = datetime.now();
        GroupMem.User__c = u.id;
        insert GroupMem;

        Opportunity_Assignment_Rule__c NewRule = new Opportunity_Assignment_Rule__c(NAme='testrule', Is_Active__c=true);
        insert NewRule;

        Assignment_Rule_Entry__c NewEntry = new Assignment_Rule_Entry__c(Opportunity_Assignment_Rule__c=NewRule.id, Order_Number__c=1, Assign_to_Assignment_Group__c=ag.id);
        insert NewEntry;

        RecordTypes_For_CBL_Processes__c objCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Subscription', 'Student_Subscription__c','Walden', true);
        //TriggerSettings__c objTrgSetting = TestDataGenerator.createTriggerSettings('StudentSubscriptionTrigger', true, true);
        //Account acc = TestDataGenerator.createAccount(true);
        Account a = TestDataGenerator.createAccount(true);

      
        List<Assignment_Rule_Entry_Condition__c> conditions = new List<Assignment_Rule_Entry_Condition__c>();
        
        Assignment_Rule_Entry_Condition__c Condition = new Assignment_Rule_Entry_Condition__c(Assignment_Rule_Entry__c = NewEntry.id);
        Condition.LineNumber__c = 1;
        Condition.Field_API_Name__c = 'createddate';
        Condition.Field_Type__c = 'DATETIME';
        Condition.Operator__c = 'greater or equal';
        Condition.Value__c = '2005-10-08 01:02:03';
        Condition.Value_SOAP_Type__c = 'DATETIME';
        conditions.add(condition);

        Assignment_Rule_Entry_Condition__c Condition2 = new Assignment_Rule_Entry_Condition__c(Assignment_Rule_Entry__c = NewEntry.id);
        Condition2.LineNumber__c = 2;
       Condition2.Assignment_Rule_Entry__c=NewEntry.id;
        Condition2.Field_API_Name__c = 'Name';
        Condition2.Field_Type__c = 'STRING';
        Condition2.Operator__c = 'equals';
        Condition2.Value__c = 'Test Opty';
        Condition2.Value_SOAP_Type__c = 'STRING';
        conditions.add(condition2);

         // insert conditions;
        Assignment_Rule_Entry_Condition__c Condition3 = new Assignment_Rule_Entry_Condition__c(Assignment_Rule_Entry__c = NewEntry.id);
        Condition3.LineNumber__c = 3;
        Condition3.Field_API_Name__c = 'Primary_Program__r.Name';
        Condition3.Assignment_Rule_Entry__c =NewEntry.id;
        Condition3.Field_Type__c = 'STRING';
        Condition3.Operator__c = 'equals';
        Condition3.Value__c = 'test0';
        Condition3.Value_SOAP_Type__c = 'STRING';
        conditions.add(condition3);
        
        Assignment_Rule_Entry_Condition__c Condition6 = new Assignment_Rule_Entry_Condition__c(Assignment_Rule_Entry__c = NewEntry.id);
        Condition6.LineNumber__c = 5;
        Condition6.Field_API_Name__c = 'Contact__r.FirstName';
        Condition6.Field_Type__c = 'STRING';
        Condition6.Operator__c = 'equals';
        Condition6.Value__c = String.valueof(a.id);
        Condition6.Value_SOAP_Type__c = 'ID';
        conditions.add(Condition6);
        //insert conditions;
        
        Assignment_Rule_Entry_Condition__c Condition7 = new Assignment_Rule_Entry_Condition__c(Assignment_Rule_Entry__c = NewEntry.id);
        Condition7.LineNumber__c = 5;
        Condition7.Field_API_Name__c = 'createdBy.name';
        Condition7.Field_Type__c = 'STRING';
        Condition7.Operator__c = 'equals';
        Condition7.Value__c = 'Test Data';
        Condition7.Value_SOAP_Type__c = 'STRING';
        conditions.add(Condition7);
      
        Assignment_Rule_Entry_Condition__c Condition8 = new Assignment_Rule_Entry_Condition__c(Assignment_Rule_Entry__c = NewEntry.id);
        Condition8.LineNumber__c = 5;
        Condition8.Field_API_Name__c = 'createdBy.name';
        Condition8.Field_Type__c = 'ID';
        Condition8.Operator__c = 'equals';
        Condition8.Value__c = 'Test Data Test DataTest DataTest DataTest DataTest Data';
        Condition8.Value_SOAP_Type__c = 'STRING';
        conditions.add(Condition8); 
        insert conditions;
        Contact testCon = TestDataGenerator.createContact(a, true);

        Product2 testProd =  TestDataGenerator.createProduct('test0', 'Walden', false);
 
        Opportunity opp0 = TestDataGenerator.createOpportunity(a.Id, testCon.Id, 'Walden', false);
        opp0.StageName = 'Qualified';
        opp0.Primary_Program__c = testProd.Id; 
        insert opp0;
        System.debug('Opportunity Round Robin :::: '  + opp0 + ' Created Date ::: ' + opp0.createddate + 
            ' Account ID :::: ' + opp0.Contact__r.AccountId);
        opp0 = [Select id, Enrollment_Advisor__c from Opportunity where id=:opp0.id LIMIT 1];
        //System.assert(opp0.Enrollment_Advisor__c != null);
    set<id> oppids = new set<id>();
      oppids.add(opp0.id);
      //OpportunityAssignment_Helper oppAssHel = new OpportunityAssignment_Helper();
        OpportunityAssignment_Helper.OpportunitytoGroupMatch(oppids);
        Opportunityhelper.manageroundrobin(oppids);
  }

    
    @isTest
  static void testCustomLookupRoundRobin_One()
  {
        /*
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorglaureate.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorglaureate.com');
        insert u;
        */
        string strRandom = string.valueOf( Math.random());
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser'+strRandom+'@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='yyyywwwwwqq'+strRandom+'@testorg.com', Assignment_Group_Active__c = true);
        insert u;

        // Implement test code
        Assignment_Group_Name__c AG = new Assignment_Group_Name__c(name='test');
        insert AG;

        Assignment_Groups__c GroupMem= new Assignment_Groups__c(Group_Name__c=AG.id);
        GroupMem.Active__c='True';
        GroupMem.Last_Assignment__c = datetime.now();
        GroupMem.User__c = u.id;
        insert GroupMem;

        Opportunity_Assignment_Rule__c NewRule = new Opportunity_Assignment_Rule__c(NAme='testrule', Is_Active__c=true);
        insert NewRule;

        Assignment_Rule_Entry__c NewEntry = new Assignment_Rule_Entry__c(Opportunity_Assignment_Rule__c=NewRule.id, Order_Number__c=1, Assign_to_Assignment_Group__c=ag.id);
        insert NewEntry;

        RecordTypes_For_CBL_Processes__c objCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Subscription', 'Student_Subscription__c','Walden', true);
        //TriggerSettings__c objTrgSetting = TestDataGenerator.createTriggerSettings('StudentSubscriptionTrigger', true, true);
        //Account acc = TestDataGenerator.createAccount(true);
        Account a = TestDataGenerator.createAccount(true);

      
        List<Assignment_Rule_Entry_Condition__c> conditions = new List<Assignment_Rule_Entry_Condition__c>();
                


         // insert conditions;
        Assignment_Rule_Entry_Condition__c Condition3 = new Assignment_Rule_Entry_Condition__c(Assignment_Rule_Entry__c = NewEntry.id);
        Condition3.LineNumber__c = 1;
        Condition3.Field_API_Name__c = 'name';
        Condition3.Assignment_Rule_Entry__c =NewEntry.id;
        Condition3.Field_Type__c = 'STRING';
        Condition3.Operator__c = 'equals';
        Condition3.Value__c = 'Test Opty';
        Condition3.Value_SOAP_Type__c = 'STRING';
        conditions.add(condition3);
      
        insert conditions;
        Contact testCon = TestDataGenerator.createContact(a, true);

        Product2 testProd =  TestDataGenerator.createProduct('test0', 'Walden', false);
        system.debug('the product is '+testprod);        
        
        Opportunity opp0 = TestDataGenerator.createOpportunity(a.Id, testCon.Id, 'Walden', false);
        opp0.StageName = 'Prospecting';
        opp0.Primary_Program__c = testProd.Id; 
        
        system.debug('before insert'+opp0);
        insert opp0;
        System.debug('Opportunity Round Robin :::: '  + opp0 + ' Created Date ::: ' + opp0.createddate + 
            ' Account ID :::: ' + opp0.Contact__r.AccountId);
        opp0 = [Select id, Enrollment_Advisor__c from Opportunity where id=:opp0.id LIMIT 1];
        //System.assert(opp0.Enrollment_Advisor__c != null);
        set<id> oppids = new set<id>();
        oppids.add(opp0.id);
      //OpportunityAssignment_Helper oppAssHel = new OpportunityAssignment_Helper();
        OpportunityAssignment_Helper.OpportunitytoGroupMatch(oppids);
        Opportunityhelper.manageroundrobin(oppids);
  }
  
  @isTest
  static void testOppHelper()
  {
      Account a = TestDataGenerator.createAccount(true);
      
      Contact testCon = TestDataGenerator.createContact(a, true);

      Product2 testProd =  TestDataGenerator.createProduct('test0', 'Walden', false);
      
      Brand_Profile__c bpObj = TestDataGenerator.createBrandProfile(null,'test','test',false);
      bpObj.Contact__c = testCon.Id;
      insert bpObj;
      
      Opportunity opp0 = TestDataGenerator.createOpportunity(a.Id, testCon.Id, 'Walden', false);
      opp0.StageName = 'Prospecting';
      opp0.Primary_Program__c = testProd.Id; 
      opp0.Brand_Profile__c = bpObj.Id;
      opp0.Contact__c = testCon.Id;
      
      system.debug('before insert'+opp0);
      insert opp0;
      
      Opportunity opp1 = opp0;
      
      Program_Application_Requirement__c parObj = TestDataGenerator.createProgramApplicationRequirement(false);
      parObj.Program__c = testProd.Id;
      insert parObj;
      
      Student_Program__c sp = TestDataGenerator.createStudentProgram(opp0,testCon.Id,null,true);

      
      OpportunityHelper oppHObj1 = new OpportunityHelper();
      OpportunityHelper oppHObj2 = new OpportunityHelper(opp0);
      oppHObj2.getOpp();
      OpportunityHelper.markOppForCOSBeforeAdmitted(new List<Opportunity>{opp0});
      OpportunityHelper.updateProgramOnBrandProfile(new List<Opportunity>{opp0});
      OpportunityHelper.calculateAmountAfterDiscount(new List<Opportunity>{opp0});
      OpportunityHelper.createStudentApplicationRequirements(new List<Opportunity>{opp0});
      OpportunityHelper.updateProgramOnBrandProfile(new List<Opportunity>{opp0});
      OpportunityHelper.updateOppsWithCBLwithContactFields(new List<Opportunity>{opp0}, new map<ID,Opportunity>{opp0.Id=>opp0});
      OpportunityHelper.checkAndAssociateExistingBP(new List<Opportunity>{opp0});
      //OpportunityHelper.PricebookProductMap opphlprPrcObj = new OpportunityHelper.PricebookProductMap();
      opp0.Student_Program__c = sp.Id;
      opp0.StageName = 'Student';
      update opp0;
      oppHObj2.updatesUponOpportunityAdmitOrWin(new List<Opportunity>{opp0}, new map<ID,Opportunity>{opp1.Id=>opp1});
       
  }
  @isTest(seeAllData = true)
  static void testOppHelper1()
  {
      Account a = TestDataGenerator.createAccount(true);
      Contact testCon = TestDataGenerator.createContact(a, true);

      Product2 parentProgram = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProgram.Id;
        insert product2;
              Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = product2.Id;
        psd.Start_Date__c = TestDataGenerator.getFirstMondayOfMonth(Date.today()+31);
        psd.Accepting_New_Students__c = true;
        insert psd;
      Opportunity opp0 = TestDataGenerator.createOpportunity(a.Id, testCon.Id, 'Walden', false);
      opp0.StageName = 'Prospecting';
      opp0.Primary_Program__c = product2.Id; 
      insert opp0;
      
      opp0.StageName = 'Admitted' ;
   	  opp0.Admissions_Status__c = 'AD Admitted';
      opp0.Admissions_Status_Code__c = 'AD';
      opp0.StageName = 'Recommend Admit';
      opp0.opportunity_status_auto_values__c = 'Admitted';  
      opp0.Program_Start_Date__c = psd.id;
      opp0.Contact__c = testCon.Id;
      update opp0;
      opp0.StageName = 'Student' ;
      update opp0;
      
      system.debug('8888888888888%%%%'+opp0.Student_Program__c);
      
      Area_of_Expertise__c aoe= TestDataGenerator.createAreaOfExpertise(TRUE);
      //OpportunityHelper.updateBEToFulfilled(new List<Opportunity>{opp0});
  }

  /*
  @isTest
  static void testStandardLookupRoundRobin()
  {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorglaureate.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorglaureate.com');
        insert u; 
        // Implement test code
        Assignment_Group_Name__c AG = new Assignment_Group_Name__c(name='test');
        insert AG;

        Assignment_Groups__c GroupMem= new Assignment_Groups__c(Group_Name__c=AG.id);
        GroupMem.Active__c='True';
        GroupMem.Last_Assignment__c = datetime.now();
        GroupMem.User__c = u.id;
        insert GroupMem;

        Opportunity_Assignment_Rule__c NewRule = new Opportunity_Assignment_Rule__c(NAme='testrule', Is_Active__c=true);
        insert NewRule;

        Assignment_Rule_Entry__c NewEntry = new Assignment_Rule_Entry__c(Opportunity_Assignment_Rule__c=NewRule.id, Order_Number__c=1, Assign_to_Assignment_Group__c=ag.id);
        insert NewEntry;

        RecordTypes_For_CBL_Processes__c objCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Subscription', 'Student_Subscription__c','Walden', true);
        //TriggerSettings__c objTrgSetting = TestDataGenerator.createTriggerSettings('StudentSubscriptionTrigger', true, true);
        Account acc = TestDataGenerator.createAccount(true);


        List<Assignment_Rule_Entry_Condition__c> conditions = new List<Assignment_Rule_Entry_Condition__c>();
        Assignment_Rule_Entry_Condition__c Condition = new Assignment_Rule_Entry_Condition__c(Assignment_Rule_Entry__c = NewEntry.id);
        Condition.LineNumber__c = 1;
        Condition.Field_API_Name__c = 'Account.createddate';
        Condition.Field_Type__c = 'DATETIME';
        Condition.Operator__c = 'greater or equal';
        Condition.Value__c = '2005-10-08 01:02:03';
        Condition.Value_SOAP_Type__c = 'DATETIME';
        conditions.add(condition);

        Assignment_Rule_Entry_Condition__c Condition2 = new Assignment_Rule_Entry_Condition__c(Assignment_Rule_Entry__c = NewEntry.id);
        Condition2.LineNumber__c = 2;
        Condition2.Field_API_Name__c = 'Account.name';
        Condition2.Field_Type__c = 'STRING';
        Condition2.Operator__c = 'excludes';
        Condition2.Value__c = 'demo';
        Condition2.Value_SOAP_Type__c = 'STRING';
        conditions.add(condition2);

        Assignment_Rule_Entry_Condition__c Condition3 = new Assignment_Rule_Entry_Condition__c(Assignment_Rule_Entry__c = NewEntry.id);
        Condition3.LineNumber__c = 3;
        Condition3.Field_API_Name__c = 'Account.IsDeleted';
        Condition3.Field_Type__c = 'BOOLEAN';
        Condition3.Operator__c = 'equals';
        Condition3.Value__c = 'false';
        Condition3.Value_SOAP_Type__c = 'BOOLEAN';
        conditions.add(condition3);


        Assignment_Rule_Entry_Condition__c Condition6 = new Assignment_Rule_Entry_Condition__c(Assignment_Rule_Entry__c = NewEntry.id);
        Condition6.LineNumber__c = 5;
        Condition6.Field_API_Name__c = 'Account.ID';
        Condition6.Field_Type__c = 'ID';
        Condition6.Operator__c = 'equals';
        Condition6.Value__c = String.valueof(acc.id);
        Condition6.Value_SOAP_Type__c = 'ID';
        conditions.add(Condition6);
        insert conditions;

        Contact testCon = TestDataGenerator.createContact(acc, true);

        Product2 testProd =  TestDataGenerator.createProduct('test0', 'Walden', false);
 
        Opportunity opp0 = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp0.Primary_Program__c = testProd.Id;
        opp0.RunRoundRobin__c = true;
        insert opp0;


        //Opp = [Select id, Ownerid from Opportunity where id=:Opp.id LIMIT 1];
        //System.assertEquals(Opp.Ownerid, u.id);

  }
  
  

  @isTest
  static void testMiscOpperators()
  {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorglaureate.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorglaureate.com');
        insert u;
        // Implement test code
        Assignment_Group_Name__c AG = new Assignment_Group_Name__c(name='test');
        insert AG;

        Assignment_Groups__c GroupMem= new Assignment_Groups__c(Group_Name__c=AG.id);
        GroupMem.Active__c='True';
        GroupMem.Last_Assignment__c = datetime.now();
        GroupMem.User__c = u.id;
        insert GroupMem;

        Opportunity_Assignment_Rule__c NewRule = new Opportunity_Assignment_Rule__c(NAme='testrule', Is_Active__c=true);
        insert NewRule;

        Assignment_Rule_Entry__c NewEntry = new Assignment_Rule_Entry__c(Opportunity_Assignment_Rule__c=NewRule.id, Order_Number__c=1, Assign_to_Assignment_Group__c=ag.id);
        insert NewEntry;

        RecordTypes_For_CBL_Processes__c objCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Subscription', 'Student_Subscription__c','Walden', true);
        //TriggerSettings__c objTrgSetting = TestDataGenerator.createTriggerSettings('StudentSubscriptionTrigger', true, true);
        Account acc = TestDataGenerator.createAccount(true);

      
        List<Assignment_Rule_Entry_Condition__c> conditions = new List<Assignment_Rule_Entry_Condition__c>();
        Assignment_Rule_Entry_Condition__c Condition = new Assignment_Rule_Entry_Condition__c(Assignment_Rule_Entry__c = NewEntry.id);
        Condition.LineNumber__c = 1;
        Condition.Field_API_Name__c = 'Account.createddate';
        Condition.Field_Type__c = 'DATETIME';
        Condition.Operator__c = 'not equals to';
        Condition.Value__c = '2005-10-08 01:02:03';
        Condition.Value_SOAP_Type__c = 'DATETIME';
        conditions.add(condition);



        Assignment_Rule_Entry_Condition__c Condition2 = new Assignment_Rule_Entry_Condition__c(Assignment_Rule_Entry__c = NewEntry.id);
        Condition2.LineNumber__c = 2;
        Condition2.Field_API_Name__c = 'StageName';
        Condition2.Field_Type__c = 'STRING';
        Condition2.Operator__c = 'starts with';
        Condition2.Value__c = 'Qual';
        Condition2.Value_SOAP_Type__c = 'STRING';
        conditions.add(condition2);

        Assignment_Rule_Entry_Condition__c Condition3 = new Assignment_Rule_Entry_Condition__c(Assignment_Rule_Entry__c = NewEntry.id);
        Condition3.LineNumber__c = 3;
        Condition3.Field_API_Name__c = 'StageName';
        Condition3.Field_Type__c = 'STRING';
        Condition3.Operator__c = 'equals';
        Condition3.Value__c = 'Qualified, Closed';
        Condition3.Value_SOAP_Type__c = 'STRING';
        conditions.add(Condition3);

        Assignment_Rule_Entry_Condition__c Condition4 = new Assignment_Rule_Entry_Condition__c(Assignment_Rule_Entry__c = NewEntry.id);
        Condition4.LineNumber__c = 4;
        Condition4.Field_API_Name__c = 'StageName';
        Condition4.Field_Type__c = 'STRING';
        Condition4.Operator__c = 'contains';
        Condition4.Value__c = 'Qualified';
        Condition4.Value_SOAP_Type__c = 'STRING';
        conditions.add(Condition4);

        Assignment_Rule_Entry_Condition__c Condition6 = new Assignment_Rule_Entry_Condition__c(Assignment_Rule_Entry__c = NewEntry.id);
        Condition6.LineNumber__c = 6;
        Condition6.Field_API_Name__c = 'StageName';
        Condition6.Field_Type__c = 'STRING';
        Condition6.Operator__c = 'does not contain';
        Condition6.Value__c = 'Closed';
        Condition6.Value_SOAP_Type__c = 'STRING';
        conditions.add(Condition6);

        insert conditions;

         Contact testCon = TestDataGenerator.createContact(acc, true);

        Product2 testProd =  TestDataGenerator.createProduct('test0', 'Walden', false);
 
        Opportunity opp0 = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp0.Primary_Program__c = testProd.Id;
        opp0.RunRoundRobin__c = true;
        insert opp0;
        //Opp = [Select id, Ownerid from Opportunity where id=:Opp.id LIMIT 1];
        //System.assertEquals(Opp.Ownerid, u.id);

  }
  */    
    /*
    Test method for the unit test of the function cblEAAssignment
    
    @isTest static void testCblEAAssignment() {

        string strRandom = string.valueOf( Math.random());
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'standt', Email='standarduser'+strRandom+'@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='yyyywwwwwqq'+strRandom+'@testorg.com');
        insert u1;
        system.runAs(u1){

            test.startTest();
            RecordTypes_For_CBL_Processes__c objCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity','Walden', true);
            Account acc = TestDataGenerator.createAccount(true);
            Contact testCon = TestDataGenerator.createContact(acc, true);        
            Institution__c inst = TestDataGenerator.createInstitution('testInst', true); 
            Round_Robin_Queue__c objRR = TestDataGenerator.createRoundRobinQueue('RR Walden EAs', inst.ID,true);
            Group newGroup = new Group();
            newGroup.Name = 'RR Walden EAs';
            newGroup.DoesIncludeBosses = false; 
            insert newGroup;
            GroupMember newMember=new GroupMember();
            newMember.GroupId = newGroup.ID;
            newMember.UserOrGroupId = u1.Id;
            insert newMember;
            Opportunity opp0 = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', true);
            Opportunity updatedOpty = [select id,Enrollment_Advisor__c from Opportunity where id=:opp0.ID];
            System.assert(updatedOpty.Enrollment_Advisor__c != null);
            test.stopTest();

        }
   }
    */ 

}