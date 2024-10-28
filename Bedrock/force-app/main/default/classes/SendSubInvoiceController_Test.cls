/*******************************************************************
Name  : SendSubInvoiceController_Test
Author: Tom (Appirio)
Date  : Feb 18, 2015
Description: Test class for SendSubInvoiceController
*************************************************************************/ 

@isTest
private class SendSubInvoiceController_Test {
	
  public static Student_Subscription__c studentSub;

	@isTest static void testSendSubInvoice() {
	Account testAcc = TestDataGenerator.createAccount(true);
    Contact testCon = TestDataGenerator.createContact(testAcc, false); 
    testCon.Email = 'test12@test12345.Com';
    insert testCon;        
	Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
    Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
    product2.Parent_Program__c = parentProduct.id;
    insert product2;
    Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
    psd.Program__c = product2.Id;
    psd.Start_Date__c = TestDataGenerator.getFirstMondayOfMonth(Date.today()+31);
    psd.Accepting_New_Students__c = true;
    insert psd;
    Id pricebookId = Test.getStandardPricebookId();
    PricebookEntry pbEntryStd = TestDataGenerator.createPricebookEntry(parentProduct.id, pricebookId, 100, false,false);
    pbEntryStd.Available_for_Existing_Students__c = true;
    insert pbEntryStd;
    Pricebook2 pb = TestDataGenerator.createSubscrptPricebook('testpb', 3, 'Walden', true);
    PricebookEntry pbEntry = TestDataGenerator.createPricebookEntry(parentProduct.id, pb.id, 200, false,false);
    pbEntry.Available_for_Existing_Students__c = true;
    insert pbEntry;

    // This should give us a Lead/Contact/Opportunity/ChatterFree User as well 
    // New opp's PrimaryProgram and InitialPriceBook should be populated via triggers
    Brand_Profile__c studentBP = TestDataGenerator.createBrandProfile('Tempo', 'test', 'user', false);
    studentBP.Email__c = 'SendSubInvoice@test.com';
    studentBP.Phone__c = '123-123-2132';
    studentBP.Primary_Program_of_Interest__c = product2.Id;
    insert studentBP;
  	opportunity opty = TestDataGenerator.createOpportunity(testAcc.id, testCon.id, 'Walden', false);
    opty.Brand_Profile__c = studentBP.id;
    insert opty;
    // This update should create a Student Program and Student Subscription
    opty.Program_Start_Date__c = psd.Id;
    opty.StageName = 'Recommend Admit';
    opty.Admissions_Status_Code__c = 'AD';
    update opty;
    opty.StageName = 'Student';
    opty.Contact__c = testCon.id;
    update opty;
    Student_Program__c sProg = TestDataGenerator.createStudentProgram(opty,opty.Contact__c, 'Walden', false);
    sProg.Program_Start_Date__c = opty.Program_Start_Date__c;
    sProg.Application__c = opty.ID;
    sProg.Student__c = opty.Contact__c;
    insert sProg;
    Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription( sProg, pb, 'Walden', false);
    stuSub.Start_Date__c = psd.Start_Date__c;
    insert stuSub;
    system.assert(stuSub.Start_Date__c == TestDataGenerator.getFirstMondayOfMonth(Date.today()+31) );
 
    PageReference pageRef = Page.SendSubInvoice;
    Test.setCurrentPage(pageRef);   
    ApexPages.StandardController sc = new ApexPages.StandardController(stuSub);
    SendSubInvoiceController controller  = new SendSubInvoiceController(sc); 
    controller.sendEmail();
  }
    
    
    @isTest static void testSendSubInvoice1() {
	
    Account testAcc = TestDataGenerator.createAccount(true);
    Contact testCon = TestDataGenerator.createContact(testAcc, false); 
    testCon.Email = 'test12@test12345.Com';
    testCon.Walden_Email__c = 'test12@test12345.Com.walden';
    insert testCon;  
	Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
    Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
    product2.Parent_Program__c = parentProduct.id;
    insert product2;
    Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
    psd.Program__c = product2.Id;
    psd.Start_Date__c = date.today().addDays(-70);
    psd.Accepting_New_Students__c = true;
    insert psd;
    Id pricebookId = Test.getStandardPricebookId();
    PricebookEntry pbEntryStd = TestDataGenerator.createPricebookEntry(parentProduct.id, pricebookId, 100, false,false);
    pbEntryStd.Available_for_Existing_Students__c = true;
    insert pbEntryStd;
    Pricebook2 pb = TestDataGenerator.createSubscrptPricebook('testpb', 3, 'Walden', true);
    PricebookEntry pbEntry = TestDataGenerator.createPricebookEntry(parentProduct.id, pb.id, 200, false,false);
    pbEntry.Available_for_Existing_Students__c = true;
    insert pbEntry;

    // This should give us a Lead/Contact/Opportunity/ChatterFree User as well 
    // New opp's PrimaryProgram and InitialPriceBook should be populated via triggers
    Brand_Profile__c studentBP = TestDataGenerator.createBrandProfile('Tempo', 'test', 'user', false);
    studentBP.Email__c = 'SendSubInvoice@test.com';
    studentBP.Phone__c = '123-123-2132';
    studentBP.Primary_Program_of_Interest__c = product2.Id;
    insert studentBP;
	opportunity opty = TestDataGenerator.createOpportunity(testAcc.id, testCon.id, 'Walden', false);
    opty.Brand_Profile__c = studentBP.id;
    insert opty;
    opty.Program_Start_Date__c = psd.Id;
    opty.StageName = 'Recommend Admit';
    opty.Admissions_Status_Code__c = 'AD';
    update opty;
    opty.StageName = 'Student';
    opty.Contact__c = testCon.id;
    update opty;
    
    Student_Program__c sProg = TestDataGenerator.createStudentProgram(opty,opty.Contact__c, 'Walden', false);
    sProg.Program_Start_Date__c = opty.Program_Start_Date__c;
    sProg.Application__c = opty.ID;
    sProg.Student__c = opty.Contact__c;
    sProg.Sponsor_Billing__c = true;
    insert sProg;
    Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription( sProg, pb, 'Walden', false);
    stuSub.Start_Date__c = psd.Start_Date__c;
    insert stuSub;
    system.assert(stuSub.Start_Date__c == date.today().addDays(-70) );
        User thisUser = [select Id from User where Id = :UserInfo.getUserId()]; 
	System.runAs(thisUser)  
	{ 

    EmailTemplate validEmailTemplate = new EmailTemplate();
    validEmailTemplate.isActive = true;
    validEmailTemplate.Name = 'TestTemplate';
    validEmailTemplate.DeveloperName = 'Invoice_Email_Walden';
    validEmailTemplate.TemplateType = 'text';
	validEmailTemplate.FolderId = UserInfo.getUserId();  
    insert validEmailTemplate;
    } 
    PageReference pageRef = Page.SendSubInvoice;
    Test.setCurrentPage(pageRef);   
    ApexPages.StandardController sc = new ApexPages.StandardController(stuSub);
    
    SendSubInvoiceController controller  = new SendSubInvoiceController(sc); 
     
    controller.sendEmail();
        
   
  }
  
    
    @isTest static void testSendSubInvoice2() {
		/*
    RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Competency', 'Student_Competency__c','Walden', true);
    RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Student Subscription', 'Student_Subscription__c','Walden', true);
    RecordTypes_For_CBL_Processes__c objeCb3 = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c','Walden', true);
    RecordTypes_For_CBL_Processes__c objeCb4 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity','Walden', true);
    */
    Account testAcc = TestDataGenerator.createAccount(true);
    Contact testCon = TestDataGenerator.createContact(testAcc, false); 
    testCon.Email = 'test12@test12345.Com';
    insert testCon;  
	Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
    Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
    product2.Parent_Program__c = parentProduct.id;
    insert product2;
    Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
    psd.Program__c = product2.Id;
    psd.Start_Date__c = date.today().addDays(70);
    psd.Accepting_New_Students__c = true;
    insert psd;
    /*
    Pricebook2 pbStd = [select id, Subscription_Duration_in_Months__c from Pricebook2 where IsStandard = true limit 1];
    if(pbStd.Subscription_Duration_in_Months__c == null){
      pbStd.Subscription_Duration_in_Months__c = 0;
      update pbStd;
    }*/
    Id pricebookId = Test.getStandardPricebookId();
    PricebookEntry pbEntryStd = TestDataGenerator.createPricebookEntry(parentProduct.id, pricebookId, 100, false,false);
    //PricebookEntry pbEntryStd = TestDataGenerator.createPricebookEntry(product2.id, pbStd.id, 100, false,false);
    pbEntryStd.Available_for_Existing_Students__c = true;
    insert pbEntryStd;
    Pricebook2 pb = TestDataGenerator.createSubscrptPricebook('testpb', 3, 'Walden', true);
    PricebookEntry pbEntry = TestDataGenerator.createPricebookEntry(parentProduct.id, pb.id, 200, false,false);
    pbEntry.Available_for_Existing_Students__c = true;
    insert pbEntry;

    // This should give us a Lead/Contact/Opportunity/ChatterFree User as well 
    // New opp's PrimaryProgram and InitialPriceBook should be populated via triggers
    Brand_Profile__c studentBP = TestDataGenerator.createBrandProfile('Tempo', 'test', 'user', false);
    studentBP.Email__c = 'SendSubInvoice@test.com';
    studentBP.Phone__c = '123-123-2132';
    studentBP.Primary_Program_of_Interest__c = product2.Id;
    insert studentBP;
	opportunity opty = TestDataGenerator.createOpportunity(testAcc.id, testCon.id, 'Walden', false);
    opty.Brand_Profile__c = studentBP.id;
    opty.Contact__c = testCon.id;
    insert opty;
    opty.Program_Start_Date__c = psd.Id;
    opty.StageName = 'Recommend Admit';
    opty.Admissions_Status_Code__c = 'AD';
    update opty;
    opty.StageName = 'Student';
    update opty;
    Student_Program__c sProg = TestDataGenerator.createStudentProgram(opty,opty.Contact__c, 'Walden', false);
    sProg.Program_Start_Date__c = opty.Program_Start_Date__c;
    sProg.Application__c = opty.ID;
    sProg.Sponsor_Billing__c = true;

    insert sProg;
        
    //Student_Program__c sProg = [SELECT Id FROM Student_Program__c WHERE Application__c = :opty.Id];
    //Student_Subscription__c stuSub = [SELECT Id FROM Student_Subscription__c WHERE Student_Program__c = :sProg.Id];
    Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription( sProg, pb, 'Walden', false);
    stuSub.Start_Date__c = psd.Start_Date__c;
    insert stuSub;
    Learner_Outcome__c lerOut = new Learner_Outcome__c();
    lerOut.Student_Program__c = sProg.id;
    lerOut.Program__c= product2.Id;
    lerOut.Outcome_Status__c = 'AW';
	insert lerOut;
    system.assert(stuSub.Start_Date__c == date.today().addDays(70) );
 
    PageReference pageRef = Page.SendSubInvoice;
    Test.setCurrentPage(pageRef);   
    ApexPages.StandardController sc = new ApexPages.StandardController(stuSub);
    
    SendSubInvoiceController controller  = new SendSubInvoiceController(sc); 
    controller.isWaldenEmail = true;    

  }
   
	
}