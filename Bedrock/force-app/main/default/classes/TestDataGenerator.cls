/*******************************************************************
Name  : TestData
Author: Vinod (Appirio)
Date  : August 12, 2014
Description: Utility class to create test data
*************************************************************************/
public with sharing class TestDataGenerator {
  
      
  //public static Boolean disableSubEndDateValidation = true;
  //public static Boolean disableSubMondayValidation = true;
  //public static Boolean CheckDateOnSubscriptionRenewalVerification = false;  // false=allow SubscriptionRenewalVerification to run any day of month

  /**************************************************************
         Method to create account test data
    **************************************************************/
    public static List<Account> createAccounts(Integer numAccounts, String recordTypeName,boolean isInsert) {
        // when ever recordtye will created we will assigne default recordtye
    String defaultAccountRecordType = null;
    Id recordType = null;
    if (recordTypeName != null) {
      recordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }else if(defaultAccountRecordType != null){
      recordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(defaultAccountRecordType).getRecordTypeId();
    }
    List<Account> accounts = new List<Account>();
    for (Integer i = 0; i < numAccounts; i++) {
      Account a = new Account(Name = 'Test Account '+i, BillingStreet = '123 NE 12th ST', BillingCity = 'Portland'
                              ,  BillingPostalCode = '70021', BillingStateCode='NY', BillingCountryCode='US'); 
     /*if (recordType != null) {
          a.RecordTypeId = recordType; 
      }*/
      accounts.add(a);
    }
    if(isInsert){
        insert accounts;
    }
    return accounts;
  }


  /**************************************************************
         Method to create account test data
    **************************************************************/
    public static Account createSponsorAccount(String recordTypeName,boolean isInsert) {
        // when ever recordtye will created we will assigne default recordtye
    String defaultAccountRecordType = null;
    Id recordType = null;
    if (recordTypeName != null) {
      recordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }else if(defaultAccountRecordType != null){
      recordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get(defaultAccountRecordType).getRecordTypeId();
    }
       Account a = new Account(Name = 'Test Account ', BillingStreet = '123 NE 12th ST', BillingCity = 'Portland'
                              ,  BillingPostalCode = '70021', BillingStateCode='NY', BillingCountryCode='US'); 
     if (recordType != null) {
          a.RecordTypeId = recordType; 
      }
 
    if(isInsert){
        insert a;
    }
    return a;
  }

  public static Account createAccount(String recordTypeName,boolean isInsert) {
    return createAccounts(1, recordTypeName,isInsert).get(0);
  }

  public static Account createAccount(boolean isInsert) {
    return createAccounts(1, null,isInsert).get(0);
  }

    /**************************************************************
      Method to create Contact test data
   **************************************************************/
  public static List<Contact> createContacts(List<Account> accounts, Integer numContacts, String recordTypeName,boolean isInsert) {
    // when ever recordtye will be created we will assigne the default recordtye name
    String defaultContactRecordType = null;
    Id recordType = null;
    List<Contact> contacs = new List<Contact>();
    if (recordTypeName != null) {
        recordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }else if(defaultContactRecordType != null){
        recordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(defaultContactRecordType).getRecordTypeId();
    }
    for (Account a : accounts) {
      for (Integer i = 0; i < numContacts; i++) {
          Contact c = new Contact( AccountId = a.Id, FirstName = 'Test', LastName = 'Contact'
                                  , MailingStreet='123 NE 12th st', MailingCity='Vancouver', MailingStateCode='NY', MailingCountryCode='US'
                                  , MailingPostalCode='12345', email='conrfd@capgroup.com', phone='9490000000', Walden_Email__c='conrfd@capgroup.com');
          
          /*if (recordType != null) {
              c.RecordTypeId = recordType;
          }*/
          contacs.add(c);
      }
    }
    if(isInsert){
        insert contacs;  
    } 
    return contacs;
  }

  public static List<Contact> createContacts(Account account, Integer numContacts, String recordTypeName, boolean isInsert) {
    List<Account> accounts = new List<Account>();
    accounts.add(account);
    return createContacts(accounts, numContacts, recordTypeName,isInsert);
  }

  public static Contact createContact(Account account, String recordTypeName,boolean isInsert) {
    return createContacts(account, 1, recordTypeName,isInsert).get(0);
  }

  public static Contact createContact(Account account,boolean isInsert) {
    return createContacts(account, 1, null,isInsert).get(0);
  }
    
  /*******************************************************************
    Method to create Opportunity records
    ********************************************************************/
    public static Opportunity createOpportunity(ID accID,Id contactID,String recordTypeName, boolean isInsert){
        Id recordType = null;
    if (recordTypeName != null) {
      recordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }
        Opportunity newOpty = new Opportunity();
        //newOpty.Contact__c = contactID;
        newOpty.Name = 'Test Opty';
        newOpty.StageName = 'Prospecting';
        newOpty.CloseDate = date.today().addDays(90);
        newOpty.AccountID= accID;
        if(recordType != null){
      newOpty.RecordTypeId = recordType;
    }
    // after a validation rule on
    PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);
    newOpty.Initial_Price_Book__c = pb.ID;
    if(isInsert){
        insert newOpty;  
    } 
    return newOpty;
    }

  /**************************************************************
       Method to create Brand_Profile__c test data
  **************************************************************/
  public static Brand_Profile__c createBrandProfile(String recordTypeName,string firstName, string lastName, boolean isInsert){
    Id recordType = null;
    if (recordTypeName != null) {
      recordType = Schema.SObjectType.Brand_Profile__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }
    Brand_Profile__c bProfile = new Brand_Profile__c();
    bProfile.First_Name__c = firstName;
    bProfile.Last_Name__c = lastName;
    if(recordType != null){
        bProfile.RecordTypeId = recordType;
    }
    if(isInsert){
      insert bProfile;  
    } 
    return bProfile;    
  }
  
  /**************************************************************
       Method to create Institution test data
  **************************************************************/
  public static Institution__c createInstitution(string strName, boolean isInsert) {
    Institution__c institution = new Institution__c();
    institution.Name = strName;
    institution.SFDC_System_Name__c = strName;
    if(isInsert){
      insert institution;
    }     
    return institution;
  }

  /**************************************************************
       Method to create Product test data
  **************************************************************/
  public static Product2 createProduct(string strName, string recordTypeName, boolean isInsert) {
    Product2 prod = new Product2();
    
    // all Walden today
    prod.Institution__c = createInstitution('Walden', true).Id;
    
    prod.Name = strName;
    prod.IsActive = true;
    prod.Published__c = true;
    prod.Effective_From_Date__c = Date.newInstance(2012,09,01);
    prod.Effective_To_Date__c = Date.newInstance(2042,08,31);
    if (recordTypeName != null) {
      prod.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }
    if(isInsert){
        insert prod;
    }       
    return prod;
    }

    /**************************************************************
       Method to create Competency__c test data
  **************************************************************/
  public static Competency__c createCompetency( boolean isInsert) {
    Competency__c comp = new Competency__c();
    comp.Code__c = 'test';
    comp.Description__c = 'Test Competency';
    comp.Type__c = 'Academic';
    comp.Credit_Equivalency__c = 0.0;
    comp.Published__c = true;
    if(isInsert){
        insert comp;
    }       
    return comp;
    }
    
    /**************************************************************
       Method to create Competency__c test data
  **************************************************************/
  public static Competency__c createCompetency(String code, boolean isInsert) {
    Competency__c comp = new Competency__c();
    comp.Code__c = code;
    comp.Description__c = 'Test Competency';
    comp.Type__c = 'Academic';
    comp.Credit_Equivalency__c = 0.0;  
    comp.Published__c = true;  
    if(isInsert){
        insert comp;
    }       
    return comp;
    }
    
  // Fix 4/10/15 - create competency with credits
  public static Competency__c createCompetency(Decimal credits, boolean isInsert) {
    Competency__c comp = new Competency__c();
    //comp.Code__c = 'test';
    comp.Description__c = 'Test Competency';
    comp.Type__c = 'Academic';
    comp.Credit_Equivalency__c = credits;
    comp.Published__c = true;
    if(isInsert){
      insert comp;
    }     
    return comp;
  }
  
  
    /**************************************************************
       Method to create Program_Competency__c test data
  **************************************************************/
  public static Program_Competency__c createProgramCompetency(id compaetencyId,id productId,boolean isTryBeforeYouBuy,decimal learningOrder, boolean isInsert) {
    Program_Competency__c pComp = new Program_Competency__c();
    pComp.Competency__c = compaetencyId;
    pComp.IsTryBeforeYouBuy__c = isTryBeforeYouBuy;
    pComp.Learning_Order__c = learningOrder;
    pComp.Product__c = productId;
    if(isInsert){
        insert pComp;
    }       
    return pComp;
    }
  public static Program_Competency__c createProgramCompetency(id compaetencyId,id productId,id programexpertiseid, boolean isTryBeforeYouBuy,decimal learningOrder, boolean isInsert) {
    Program_Competency__c pComp = new Program_Competency__c();
    pComp.Competency__c = compaetencyId;
    pComp.Program_Expertise__c = programexpertiseid;
    pComp.IsTryBeforeYouBuy__c = isTryBeforeYouBuy;
    pComp.Learning_Order__c = learningOrder;
    pComp.Product__c = productId;
    if(isInsert){
      insert pComp;
    }     
    return pComp;
  }
    /**************************************************************
       Method to create Program_Competency__c test data
  **************************************************************/
  public static Area_of_Expertise__c createAreaOfExpertise(boolean isInsert) {
    Area_of_Expertise__c aExpertise = new Area_of_Expertise__c();
    aExpertise.Description__c = 'Test Expertise';
    aExpertise.Display_Name__c = 'Test Expertise';
    aExpertise.Type__c = 'Academic';
    aExpertise.RecordTypeId = Schema.SObjectType.Area_of_Expertise__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
    if(isInsert){
        insert aExpertise;
    }       
    return aExpertise;
    }
    
   /**************************************************************
       Method to create Area_of_Expertise__c test data
  **************************************************************/
  public static Area_of_Expertise__c createAreaOfExpertiseBS(boolean isInsert) {
    Area_of_Expertise__c aExpertise = new Area_of_Expertise__c();
    aExpertise.Name = 'Dynamic Leadership (WMBA 6000)';
    aExpertise.Description__c = 'Dynamic Leadership (WMBA 6000)';
    aExpertise.Display_Name__c = 'Dynamic Leadership (WMBA 6000)';
    aExpertise.Type__c = 'Academic';
    aExpertise.RecordTypeId = Schema.SObjectType.Area_of_Expertise__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
    if(isInsert){
        insert aExpertise;
    }       
    return aExpertise;
    }
        
    /**************************************************************
       Method to create Program_Expertise__c test data
  **************************************************************/
  public static Program_Expertise__c createProgramExpertise(id expertiseId,id productId,boolean isTryBeforeYouBuy,decimal learningOrder, boolean isInsert) {
    Program_Expertise__c pExp = new Program_Expertise__c();
    pExp.Area_of_Expertise__c = expertiseId;
    pExp.IsTryBeforeYouBuy__c = isTryBeforeYouBuy;
    pExp.Learning_Order__c = learningOrder;
    pExp.Program__c = productId;
    if(isInsert){
        insert pExp;
    }       
    return pExp;
    }
    /**************************************************************
       Method to create Competency_Expertise__c test data
  **************************************************************/
  public static Competency_Expertise__c createCompetencyExpertise(id expertiseId,id competencyID,string recordTypeName, boolean isInsert) {
    Competency_Expertise__c cExp = new Competency_Expertise__c();
    cExp.Area_of_Expertise__c = expertiseId;
    cExp.Competency__c = competencyID;
    if (recordTypeName != null) {
          cExp.RecordTypeId = Schema.SObjectType.Competency_Expertise__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
      }
    if(isInsert){
        insert cExp;
    }       
    return cExp;
    }
    /**************************************************************
       Method to create Student_Expertise__c test data
  **************************************************************/
  public static Student_Expertise__c createCompetencyExpertise(id expertiseId,string recordTypeName, boolean isInsert) {
    Student_Expertise__c sExp = new Student_Expertise__c();
    sExp.Area_of_Expertise__c = expertiseId;
    if (recordTypeName != null) {
          sExp.RecordTypeId = Schema.SObjectType.Student_Expertise__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
      }
    if(isInsert){
        insert sExp;
    }       
    return sExp;
    }
    /**************************************************************
       Method to create Student_Competency__c test data
  **************************************************************/
  public static Student_Competency__c createStudentCompetency( Program_Competency__c programCompetency, 
                                                               id studentID, boolean iscompleted, 
                                                               string recordTypeName, boolean isInsert,
                                                               Student_Expertise__c StudentExpertise ) {
    Student_Competency__c sComp = new Student_Competency__c();
    scomp.program_competency__c = programCompetency.id;
    sComp.Competency__c =programCompetency.competency__c;
    sComp.Contact__c = studentID;
    sComp.IsCompleted__c = iscompleted;
    sComp.Student_Expertise__c = StudentExpertise.id;                                                        
    if (recordTypeName != null) {
          sComp.RecordTypeId = Schema.SObjectType.Student_Competency__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
      }
    if(isInsert){
      insert sComp;
    }     
    return sComp;
  }
  public static Student_Competency__c createStudentCompetency(id competencyID,string recordTypeName, boolean isInsert) {
    Student_Competency__c sComp = new Student_Competency__c();
    sComp.Competency__c = competencyID;
    if (recordTypeName != null) {
          sComp.RecordTypeId = Schema.SObjectType.Student_Competency__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
      }
    if(isInsert){
        insert sComp;
    }       
    return sComp;
    }


   /**************************************************************
       Method to create Student_Competency__c test data
  **************************************************************/
  public static Student_Competency__c createStudentCompetency(id studentProgram,id competencyID,string recordTypeName, boolean isInsert) {
    Student_Competency__c sComp = new Student_Competency__c();
    sComp.Competency__c = competencyID;
    sComp.Student_Program__c = studentProgram;
    if (recordTypeName != null) {
          sComp.RecordTypeId = Schema.SObjectType.Student_Competency__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
      }
    if(isInsert){
        insert sComp;
    }       
    return sComp;
    }
    
  
    
     /**************************************************************
       Method to create Program_Course test data
  **************************************************************/
  public static Program_Courses__c createProgramCourse(id studentProgram,String courseId, boolean isInsert) {
    Program_Courses__c pCourse = new Program_Courses__c();
    pCourse.Program__c = studentProgram;
    pCourse.Course__c = courseId;
    if(isInsert){
        insert pCourse;
    }       
    return pCourse;
    }
    
    
    /**************************************************************
       Method to create RecordTypes_For_CBL_Processes__c test data
  **************************************************************/
  public static RecordTypes_For_CBL_Processes__c createRecordTypesForCBLProcesses(string name, string objectApiName,string recordTypeName, boolean isInsert) {
    RecordTypes_For_CBL_Processes__c newRcord = new RecordTypes_For_CBL_Processes__c();
    newRcord.Name = name;
    newRcord.Object_API_Name__c = objectApiName;
    newRcord.RecordType_Name__c = recordTypeName;
    if(isInsert){
        insert newRcord;
    }       
    return newRcord;
    }
  /**************************************************************
       Method to create TriggerSettings test data
  **************************************************************/
  public static TriggerSettings__c createTriggerSettings(string name, Boolean isActive, boolean isInsert) {
    TriggerSettings__c newRcord = new TriggerSettings__c();
    newRcord.Name = name;
    newRcord.IsActive__c = true;
    newRcord.IsTestMode__c = true;
    if(isInsert){
      insert newRcord;
    }     
    return newRcord;
  }
    /**************************************************************
       Method to create Lead test data
  **************************************************************/
  public static Lead createLead(string fName, string lName,string  compnyName,string recordTypeName, boolean isInsert) {
    Lead newLead = new Lead();
    newLead.FirstName = fname;
    newLead.LastName = lname;
    newLead.Company = compnyName;       
    if (recordTypeName != null) {
          newLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
      }
    if(isInsert){
        insert newLead;
    }       
    return newLead;
    }
  /**************************************************************
       Method to create Pricebook test data
  **************************************************************/
  
  public static Pricebook2 createSubscrptPricebook(String strName, Integer subscriptionduration, String recordTypeName, Boolean isInsert) {
    Pricebook2 pbook = new Pricebook2();
    pbook.Name = strName;
    pbook.IsActive = true;
    pbook.Subscription_Duration_in_Months__c = subscriptionduration;
    if (recordTypeName != null) {
      pbook.RecordTypeId = Schema.SObjectType.Pricebook2.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }
    if(isInsert){
      insert pbook;
    }     
    return pbook;
  }
  /**************************************************************
       Method to create PricebookEntry test data
  **************************************************************/
  public static PricebookEntry createPricebookEntry(Id prodId, Id pbookId, Double cost, Boolean useStd, Boolean isInsert) {
    PricebookEntry entry = new PricebookEntry();
    entry.IsActive = true;
    entry.Product2Id = prodId;
    entry.Pricebook2Id = pbookId;
    entry.UnitPrice = cost;
    entry.UseStandardPrice = useStd;
    if(isInsert){
      insert entry;
    }     
    return entry;
  }
  /**************************************************************
       Method to create Student_Subscription__c test data
  **************************************************************/
  
  public static Student_Subscription__c createStudentSubscription( Student_Program__c sProg, Pricebook2 pBook, String recordTypeName, Boolean isInsert, 
                                                                   Date sDate, Integer comCompleted, Integer credCompleted) {
    Student_Subscription__c sub = new Student_Subscription__c();
    sub.Student_Program__c = sProg.Id;
    sub.Term_Price_Book__c = pBook.Id;
    sub.Subscription_Status__c = 'RE = Registered';
    sub.Start_Date__c = sDate;
    sub.Number_of_Competencies_Completed__c = comCompleted;
    sub.Number_of_Credits_Completed__c = credCompleted;
    
    if (recordTypeName != null) {
      sub.RecordTypeId = Schema.SObjectType.Student_Subscription__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }
    if(isInsert){
      insert sub;
    }     
    return sub;
  }

  /*******************************************************************
       Method to create Student_Subscription_Exemption__c test data
  ********************************************************************/
  
  public static Student_Subscription_Exemptions__c createStudentSubscriptionExemption( Student_Discount__c stuDiscount, Student_Subscription__c stuSubscription, 
                                                                           String recordTypeName, Boolean isInsert) {
    
    Student_Subscription_Exemptions__c stuSubExemption = new Student_Subscription_Exemptions__c();
    stuSubExemption.Student_Discount__c = stuDiscount.Id;
    stuSubExemption.Student_Subscription__c = stuSubscription.Id;

    if (recordTypeName != null) {
      stuSubExemption.RecordTypeId = Schema.SObjectType.Student_Subscription_Exemptions__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }
    if(isInsert){
      insert stuSubExemption;
    }     
    return stuSubExemption;
  }

  /**************************************************************
       Method to create Student_Subscription__c test data
  **************************************************************/
  
  public static Student_Subscription__c createStudentSubscription( Student_Program__c sProg, Pricebook2 pBook, String recordTypeName, Boolean isInsert) {
    Student_Subscription__c sub = new Student_Subscription__c();
    sub.Student_Program__c = sProg.Id;
    sub.Term_Price_Book__c = pBook.Id;
    sub.Subscription_Status__c = 'RE = Registered';
    if (recordTypeName != null) {
      sub.RecordTypeId = Schema.SObjectType.Student_Subscription__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }
    if(isInsert){
      insert sub;
    }     
    return sub;
  }

  /**************************************************************
       Method to create Student_Program__c test data
  **************************************************************/
  public static Student_Program__c createStudentProgram(Opportunity opp, Id contId, String recordTypeName, boolean isInsert) {
    Student_Program__c sProg = new Student_Program__c();
    sProg.Application__c = opp.Id;
    sProg.Brand_Profile__c = opp.Brand_Profile__c;
    sProg.Program__c = opp.Primary_Program__c;
    sProg.Student__c = contId;
    sProg.IsStudentProgramActive__c = true;
    if (recordTypeName != null) {
      sProg.RecordTypeId = Schema.SObjectType.Student_Program__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }
    if(isInsert){
      insert sProg;
    }     
    return sProg;
  }

  /**************************************************************
       Method to create Student_Program__c test data
  **************************************************************/
  public static Student_Program__c createStudentProgram(Opportunity opp, Id contId, String recordTypeName, boolean isInsert,
                                                        String academicStanding, Boolean isProgActive, id progStartDate) {
    Student_Program__c sProg = new Student_Program__c();
    sProg.Application__c = opp.Id;
    sProg.Brand_Profile__c = opp.Brand_Profile__c;
    sProg.Program__c = opp.Primary_Program__c;
    sProg.Student__c = contId;
    //sProg.Academic_Standing__c = academicStanding;
    sProg.IsStudentProgramActive__c = isProgActive;
    if(progStartDate != null) {
      sProg.Program_Start_Date__c = progStartDate;
    }
    if (recordTypeName != null) {
      sProg.RecordTypeId = Schema.SObjectType.Student_Program__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }
    if(isInsert){
      insert sProg;
    }     
    return sProg;
  }


  /**************************************************************
       Method to create Student_Program__c test data
  **************************************************************/
  public static Student_Program__c createStudentProgramModalitySwitcher(Opportunity opp, Id contId, String recordTypeName, boolean isInsert,
                                                        String academicStanding, Boolean isProgActive, id progStartDate) {
    Student_Program__c sProg = new Student_Program__c();
    sProg.Application__c = opp.Id;
    sProg.Brand_Profile__c = opp.Brand_Profile__c;
    sProg.Program__c = opp.Primary_Program__c;
    sProg.Student__c = contId;
    //sProg.Academic_Standing__c = academicStanding;
    sProg.IsStudentProgramActive__c = isProgActive;
    sProg.SAP_Code__c = 'W - Warning';
    sProg.Modality_Switcher__c = 'Course-Base to Tempo';
    if(progStartDate != null) {
      sProg.Program_Start_Date__c = progStartDate;
    }
    if (recordTypeName != null) {
      sProg.RecordTypeId = Schema.SObjectType.Student_Program__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }
    if(isInsert){
      insert sProg;
    }     
    return sProg;
  }
  /**************************************************************
       Method to create Student_Discount__c test data
  **************************************************************/
  public static Student_Discount__c createStudentDiscount(Opportunity opp, Student_Program__c sprogram, Exemption__c exmp, boolean isInsert) {
    Student_Discount__c sdisc = new Student_Discount__c();
    sdisc.Exemption__c = exmp.id;
    sdisc.Opportunity__c = opp.id;
    sdisc.Exemption_Approved__c = true;
    if(sprogram!=null)
    sdisc.Student_Program__c = sprogram.id;
   
    if(isInsert){
      insert sdisc;
    }     
    return sdisc;
  }


  /**************************************************************
       Method to create Exemption__c test data
  **************************************************************/
  public static Exemption__c createExemption(decimal fRate,decimal pDiscount,boolean isInsert) {
    Exemption__c newEx = new Exemption__c();
    newEx.Description__c = 'Test Exemption';
    newEx.Fee_Type__c = 'Tech Fee';
    if(fRate != 0) {
      newEx.Flat_Rate_Amount__c = fRate;
    }
    if(pDiscount!=0) {
      newEx.Percentage_Discount__c = pDiscount;
    }
    newEx.Active__c = true;
    newEx.Exemption_Category__c = 'Standard Reduction';
    newEx.Institution__c = createInstitution('Walden', true).Id;
    newEx.Life_of_Program__c = true;
    if(isInsert){
      insert newEx;
    }     
    return newEx;
  }
  
  /**************************************************************
       Method to create Exemption__c test data
  **************************************************************/
  public static Exemption__c createExemption(string category, string subType, boolean lifeOfProgram, Decimal noTerms, Product2 program, 
                                             boolean isActive, decimal fRate,decimal pDiscount,boolean isInsert,
                                             Program_Start_Date__c startDate, Program_Start_Date__c endDate) {
    Exemption__c newEx = new Exemption__c();
    newEx.Description__c = 'Test Exemption';
    if(fRate != 0) {
      newEx.Flat_Rate_Amount__c = fRate;
    }
    if(pDiscount!=0) {
      newEx.Percentage_Discount__c = pDiscount;
    }   
	newEx.Fee_Type__c = 'Tech Fee'; 
    newEx.Exemption_Category__c = category;
    newEx.Exemption_Sub_type__c = subType;
    newEx.Active__c = isActive;
    newEx.no_of_Terms__c = noTerms;
    newEx.Program__c = program.Id;
    newEx.Term_Start_Date__c = startDate.Id;
    newEx.Term_End_Date__c = endDate.Id;

    newEx.Institution__c = createInstitution('Walden', true).Id;

    if(isInsert){
      insert newEx;
    }     
    return newEx;
  }

  /**************************************************************
       Method to create Course  test data
  **************************************************************/
  public static Course__c createNewCourse(String courseName,boolean isInsert){
    Course__c newCourse = new Course__c();
    newCourse.name = courseName;
    if(isInsert){
        insert newCourse;
    }
    return newCourse;
  }
  
  /**************************************************************
       Method to create Course_Competency__c  test data
  **************************************************************/
  public static Course_Competency__c createNewCourseCompetency(String courseId,id competencyId,boolean isInsert){
    Course_Competency__c courseCompetency = new Course_Competency__c();
    courseCompetency.Competency__c = competencyId;
    courseCompetency.Course__c = courseId;
    if(isInsert){
        insert courseCompetency;
    }
    return courseCompetency;
  }
  /**************************************************************
       Method to create Student_Assessment__c  test data
  **************************************************************/
  public static Student_Assessment__c createNewStudentAssessment(id studentCompetencyId,string strGrade,String recordTypeName,String status,boolean isInsert){
    Student_Assessment__c sa = new Student_Assessment__c();
    sa.Student_Competency__c = studentCompetencyId;
    sa.Grade__c = strGrade;
    sa.Status__c = status;
    if (recordTypeName != null) {
        sa.RecordTypeId = Schema.SObjectType.Student_Assessment__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
      }
    if(isInsert){
        insert sa;
    }
    return sa;
  }
  
  /**************************************************************
       Method to create Student_Enrollment_Steps__c  test data
  **************************************************************/
  public static Student_Enrollment_Steps__c createStudentEnrollmentSteps(id studentProgramId,boolean isInsert){
    Student_Enrollment_Steps__c studentEnrollmentSteps = new Student_Enrollment_Steps__c();
    studentEnrollmentSteps.Student_Program__c = studentProgramId;
    studentEnrollmentSteps.Comment__c = 'Test Comment';
    studentEnrollmentSteps.Date_Completed__c = System.today();
    studentEnrollmentSteps.Enrollment_Step_Name__c = 'Test Name';

    if(isInsert){
        insert studentEnrollmentSteps;
    }
    return studentEnrollmentSteps;
  }
  /**************************************************************
       Method to create Hold_Codes__c  test data
  **************************************************************/
  public static Hold_Codes__c createHoldCode(boolean isInsert){
    Hold_Codes__c objNew = new Hold_Codes__c();
    objNew.Enrollment__c = true;
    objNew.Graduation__c = true;        
    objNew.Description__c = 'Test Hold Code';

    objNew.Institution__c = createInstitution('Walden', true).Id; 

    if(isInsert){
        insert objNew;
    }
    return objNew;
  }
  /**************************************************************
       Method to create Student_Hold_Code__c  test data
  **************************************************************/
  public static Student_Hold_Code__c createStudentHoldCode(id holdCodeID,id studentProgramId,boolean isInsert){
    Student_Hold_Code__c objNew = new Student_Hold_Code__c();
    objNew.Hold_Code__c = holdCodeID;
    objNew.Student_Program__c = studentProgramId;       
    if(isInsert){
        insert objNew;
    }
    return objNew;
  }
  /**************************************************************
       Method to create Program_Start_Date__c  test data
  **************************************************************/
  public static Program_Start_Date__c createProgramStartDate(boolean isInsert){
    Program_Start_Date__c objNew = new Program_Start_Date__c();
    objNew.Name = 'test';
    objNew.Accepting_New_Students__c = true;
    objNew.Start_Date__c = getFirstMondayOfMonth(Date.today());
    
    if(isInsert){
        insert objNew;
    }
    
    return objNew;
  }  
  
  
  /***********************************************************************
   Get Fist Monday of Given Date 
   **********************************************************************/
   public static Date getFirstMondayOfMonth(Date startDate) {
    Date dtMonthtStartdate = startDate.toStartOfMonth();
    Date dtWeekStartDate = dtMonthtStartdate.toStartOfWeek();
    Date dtFirstMondayDate = dtWeekStartDate.addDays(1);
    if(dtFirstMondayDate < dtMonthtStartdate){
      // week start before the month start and the monday also before the begning of the month
      // so we will move to next monday     
      dtFirstMondayDate = dtFirstMondayDate.addDays(7);
    }
    return dtFirstMondayDate;
    /*
    Date dtFirstMondayDate ;
    if(dtWeekStartDate >= dtMonthtStartdate){
        // week start into in the month so we will add only 1 day to get first monday date
        dtFirstMondayDate = dtWeekStartDate.addDays(1);
    }else{
        // week start into in the previous month so we will add only 8 day to get first monday date
        dtFirstMondayDate = dtWeekStartDate.addDays(8);
    }
    return dtFirstMondayDate;
    */
  }  
  
  /*****************************************************************************
    Create New Object Map
  ************************************************************************************/
    public static Object_Map__c createObjectMap(boolean isInsert){
        Object_Map__c objectMap = new Object_Map__c();
        
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Id   contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Custom Person Account Contact').getRecordTypeId();
        Id   brandRecordTypeId = Schema.SObjectType.Brand_Profile__c.getRecordTypeInfosByName().get('Tempo').getRecordTypeId();
        testCon.RecordTypeId = contactRecordTypeId;
        update testCon;
    
        Brand_Profile__c testProfile = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile.Email__c = 'test12@test12345.Com';
        testProfile.RecordTypeId = brandRecordTypeId;
        insert testProfile;
        
        objectMap.Source_Object__c = 'Contact';
        objectMap.Target_Object__c = 'Brand_Profile__c';
        objectMap.Source_Record_Types__c = contactRecordTypeId;
        objectMap.Target_Record_Types__c = brandRecordTypeId;
        objectMap.Related_to_Source__c = 'Contact__c';
        //objectMap.Two_way_Sync__c = true;
        if(isInsert){
            insert objectMap;
        }
        return objectMap;
     }
     
    /*****************************************************************************
      Create New Field Mapping
     ************************************************************************************/
    public static Field_Mapping__c  createNewFieldMapping(boolean isInsert,Id objectMapId,String srcField,String targetField){
        Field_Mapping__c fieldMapping = new Field_Mapping__c();
        fieldMapping.Source_Field__c = srcField;
        fieldMapping.Target_Field__c = targetField;
        fieldMapping.Object_Mapping__c = objectMapId;
        if(isInsert){
            insert fieldMapping;
        }
        return fieldMapping;
    }
    /*****************************************************************************
      Create New Academic_History__c records 
    ************************************************************************************/
    public static Academic_History__c  createAcademicHistory(id contactID,boolean isInsert){
        Academic_History__c obj = new Academic_History__c();
        obj.Contact__c = contactID;
        if(isInsert){
            insert obj;
        }
        return obj;
    }
    /*****************************************************************************
      Create New Employment_History__c records 
    ************************************************************************************/
    public static Employment_History__c  createEmploymentHistory(id contactID,boolean isInsert){
        Employment_History__c obj = new Employment_History__c();
        obj.Contact__c = contactID;
        if(isInsert){
            insert obj;
        }
        return obj;
    }
    
    /*****************************************************************************
      Create New Program_Application_Requirement__c records 
    ************************************************************************************/
    public static Program_Application_Requirement__c  createProgramApplicationRequirement(boolean isInsert){
        Program_Application_Requirement__c obj = new Program_Application_Requirement__c();
        obj.Name = 'Test';
        if(isInsert){
            insert obj;
        }
        return obj;
    }  
    /*****************************************************************************
      Create New Student_Application_Requirement__c records 
    ************************************************************************************/
    public static Student_Application_Requirement__c  createStudentApplicationRequirement(id optyID, id programAppID,boolean isInsert){
        Student_Application_Requirement__c obj = new Student_Application_Requirement__c();
        obj.Opportunity__c = optyID;
        obj.Program_Application_Requirement__c = programAppID;
        if(isInsert){
            insert obj;
        }
        return obj;
    }
    /*****************************************************************************
      Create New Round_Robin_Queue__c records 
    ************************************************************************************/
    public static Round_Robin_Queue__c  createRoundRobinQueue(string strName, id InstitutionId,boolean isInsert){
        Round_Robin_Queue__c obj = new Round_Robin_Queue__c();
        obj.Queue_Position__c = 0;
        obj.Institution__c = InstitutionId;
        obj.Name = strName;
        if(isInsert){
            insert obj;
        }
        return obj;
    }
    
    public static Student_Loan_Disbursement__c createStudentLoanDisbursement(Id studentProgramId, Decimal da, 
                                                                             date loanStartDate, date asOfDate, 
                                                                             date loanEndDate, boolean isInsert) {
        Student_Loan_Disbursement__c loan = new Student_Loan_Disbursement__c();
        loan.Student_Program__c = studentProgramId;
        loan.Disbursement_Amount__c = da;
        loan.Loan_Start_Date__c = loanStartDate;
        loan.As_of_Date__c = asOfDate;
        loan.Loan_End_Date__c = loanEndDate;
        loan.Unique_Key__c = 'Key' + String.valueOf(math.random());
        if(isInsert){
            insert loan;
        }
        return loan;
    }

    /*****************************************************************************
      Create New Engagement_Rule__c records 
    ************************************************************************************/
    public static Engagement_Rule__c  createEngagementRule(string ruleType, id InstitutionId, boolean isActive, boolean isInsert){
        Engagement_Rule__c obj = new Engagement_Rule__c();
        obj.Name = ruleType;
        obj.Institution__c = InstitutionId;
        obj.Rule_Type__c = ruleType;
        obj.IsActive__c = isActive;
        if(isInsert){
            insert obj;
        }
        return obj;
    }  

    /*****************************************************************************
      Create New Student_Engagement_Rule__c records 
    ************************************************************************************/
    public static Student_Engagement_Rule__c  createStudentEngagementRule(id stuProgramId, id engRuleId, boolean isActive, boolean isInsert){
        Student_Engagement_Rule__c obj = new Student_Engagement_Rule__c();
        obj.Student_Program__c = stuProgramId;
        obj.Engagement_Rule__c = engRuleId;
        obj.IsEngagementRuleActive__c = isActive;
        if(isInsert){
            insert obj;
        }
        return obj;
    }          
    
    /*****************************************************************************
      Create New Student_Sponsorship__c records 
    ************************************************************************************/
    public static Student_Sponsorship__c createStudentSponsorship(Id subscriptionId, Id accountId, decimal paymentAmount, date invoiceDueDate, boolean isInsert) {
        Student_Sponsorship__c obj = new Student_Sponsorship__c();
        obj.Student_Subscription__c = subscriptionId;
        obj.Account__c = accountId;
        obj.Invoice_Due_Date__c = invoiceDueDate;
        obj.Sponsorship_Amount__c = paymentAmount;
        if(isInsert) {
            insert obj;
        }
        return obj;         
    }
    
   /*****************************************************************************
      Create New Student_Transaction__c records 
    ************************************************************************************/
    public static Student_Transaction__c createStudentTransaction(Id subscriptionId, Id accountId, decimal paymentAmount, String transactionType, date transactionDate, boolean isInsert) {
        Student_Transaction__c obj = new Student_Transaction__c();
        obj.Student_Subscription__c = subscriptionId;
        obj.Sponsor__c = accountId;
        obj.Payment_Amount__c = paymentAmount;
        obj.Transaction_Type__c = transactionType;
        obj.Transaction_Date__c = transactionDate;
        if(isInsert) {
            insert obj;
        }
        return obj;
    }
  /*****************************************************************************
      Create New Student_Sponsorship_Transaction__c records 
    ************************************************************************************/
    public static Student_Sponsorship_Transaction__c createStudentSponsorshipTransaction(Id sponsorshipId, Id transactionId, date transactionDate, decimal paymentAmount, boolean isInsert) {
        Student_Sponsorship_Transaction__c obj = new Student_Sponsorship_Transaction__c();
        obj.Student_Sponsorship__c = sponsorshipId;
        obj.Student_Transaction__c = transactionId;
        obj.Transaction_Date__c = transactionDate;
        obj.Payment_Amount__c = paymentAmount;
        if(isInsert) {
            insert obj;
        }
        return obj;
    }
    
    /*****************************************************************************
      Create New Student_Sponsorship_Transaction__c records 
    ************************************************************************************/
    public static Brand_Configuration__c createBrandConfiguration( String name, 
                                                                   String type,
                                                                   String subType, 
                                                                   Boolean isInsert) {
        Brand_Configuration__c obj = new Brand_Configuration__c();
        obj.Name = name;
        obj.sub_type__c = subType;
        obj.Type__c = type;
        if(isInsert) {
            insert obj;
        }
        return obj;
    }
    

}