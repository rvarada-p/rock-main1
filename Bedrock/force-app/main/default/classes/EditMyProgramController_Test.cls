/************************************************************************
Name  : EditMyProgramController_Test
Developer: Ravitej Varada, June 2018
Description: Apex test class for the EditMyProgramController Apex class
*************************************************************************/

@isTest
private class EditMyProgramController_Test {
    
    static testMethod void testEditMyProgram() {
  
        Institution__c institution = new Institution__c();
        institution.Name = 'Walden';
        institution.SFDC_System_Name__c = 'Walden';
        insert institution;
        
        Product2 parentProduct = new Product2();
        parentProduct.Institution__c = institution.id;
        parentProduct.Name = 'B.S. in Health Studies';
        parentProduct.IsActive = true;
        parentProduct.Published__c = true;
        parentProduct.Effective_From_Date__c = Date.newInstance(2012,09,01);
        parentProduct.Effective_To_Date__c = Date.newInstance(2042,08,31);
        parentProduct.ProductCode = 'C_BSHS';
        parentProduct.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        insert parentProduct;
        
        Product2 product2 = new Product2();
        product2.Institution__c = institution.id;
        product2.Name = 'B.S. in Health Studies';
        product2.IsActive = true;
        product2.Published__c = true;
        product2.Effective_From_Date__c = Date.newInstance(2012,09,01);
        product2.Effective_To_Date__c = Date.newInstance(2042,08,31);
        product2.ProductCode = 'C_BSHS';
        product2.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        product2.Parent_Program__c = parentProduct.Id;
    	product2.Degree_Level__c = 'Undergrad';
        insert product2; 
    
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', true);
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = product2.Id;
        insert opp;
        
        Id standardPricebookId = Test.getStandardPricebookId();
        Pricebook2 pb = new Pricebook2(ID=standardPricebookId,Subscription_Duration_in_Months__c = 0);
        update pb;
    
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.IsStudentProgramActive__c = true;         
        insert sProg;
    
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg,pb, 'Walden', false);
        stuSub.Start_Date__c = Date.today().addDays(-40);
        stuSub.Subscription_Status__c = 'RE = Registered';
        stuSub.End_Date__c = Date.today().addDays(50);
        stuSub.List_Price__c = 3500;
        stuSub.Future_Term__c = false;
        stuSub.Agreed_To_Credits__c = 2;
        stuSub.Date_Student_Agreed_To_Credits__c = null;
        insert stuSub;
    
        sProg.Current_Student_Subscription__c = stuSub.Id;
        update sProg;            
        Profile communityProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Tempo Community Users'
            LIMIT 1 ];
        user usr = new user();
        usr.Username = testCon.email;
        usr.ContactId = testCon.id;
        usr.ProfileId = communityProfile.Id;
        usr.Alias = testCon.FirstName;
        usr.Email = testCon.email + '.Walden';
        usr.FirstName = testCon.FirstName;
        usr.LastName = testCon.LastName;
        usr.FederationIdentifier = testCon.CBL_Student_ID__c;
        usr.TimeZoneSidKey = 'America/New_York';
        usr.LocaleSidKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        usr.IsActive = true;
        insert usr;
        Brand_Configuration__c brandConf = TestDataGenerator.createBrandConfiguration('Test Brand Configuratiomn', 'TEST','Header', true) ;
        Community_Site_Settings__c defaultCustomSetngs = new Community_Site_Settings__c();
        defaultCustomSetngs.Name = 'Default Settings';
        defaultCustomSetngs.RecordID__c = brandConf.id;
        defaultCustomSetngs.Intercom_Secret_Key__c = 'U8BjsjJnasonsauho32873ashj783HHBS';
        insert defaultCustomSetngs;       
        
        //--Create area of exprtise
        Area_of_Expertise__c areaOfExpertise1 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExpertise1.Name = 'Interpersonal Communication(COMM 1004C)';
        areaOfExpertise1.Display_Name__c = 'Interpersonal Communication(COMM 1004C)';
        areaOfExpertise1.Display_on_Program_Edit__c  = TRUE;
        areaOfExpertise1.Display_on_web__c = TRUE;
        areaOfExpertise1.category__c = 'General Education';
        areaOfExpertise1.overview__c= 'TEST DESCRIPTION';
        areaOfExpertise1.LMS_ID__c = '1001';
        insert areaOfExpertise1;
        
        Area_of_Expertise__c areaOfExpertise2 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExpertise2.Name = 'Psychology(PSYC 1001)';
        areaOfExpertise2.Display_Name__c = 'Psychology(PSYC 1001)';
        areaOfExpertise2.Display_on_Program_Edit__c  = TRUE;
        areaOfExpertise2.Display_on_web__c = TRUE;
        areaOfExpertise2.category__c = 'General Education; General Elective';
        areaOfExpertise2.overview__c= 'TEST DESCRIPTION';
        areaOfExpertise2.LMS_ID__c = '1002';
        insert areaOfExpertise2;
        
        Area_of_Expertise__c areaOfExpertise3 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExpertise3.Name = 'World Religions (RELG 2001)';
        areaOfExpertise3.Display_Name__c = 'World Religions (RELG 2001)';
        areaOfExpertise3.Display_on_Program_Edit__c  = TRUE;
        areaOfExpertise3.category__c = 'General Education';
        areaOfExpertise3.overview__c= 'TEST DESCRIPTION';
        areaOfExpertise3.Display_on_web__c = TRUE;
        areaOfExpertise3.LMS_ID__c = '1003';
        insert areaOfExpertise3;
        
        // Inserting Master AoEs
        Master_AoE__c masterAOE1 = new Master_AoE__c();
        masterAOE1.Course__c = areaOfExpertise1.Id;
        masterAOE1.Program__c = product2.Id;
        insert masterAOE1;
        
        Master_AoE__c masterAOE2 = new Master_AoE__c();
        masterAOE2.Course__c = areaOfExpertise2.Id;
        masterAOE2.Program__c = product2.Id;
        insert masterAOE2;
        
        Master_AoE__c masterAOE3 = new Master_AoE__c();
        masterAOE3.Course__c = areaOfExpertise3.Id;
        masterAOE3.Program__c = product2.Id;
        insert masterAOE3;
        
        // Creating Competency objects
        List<Competency__c> competenciesList = new List<Competency__c>();
        Competency__c IC1001 = new Competency__c(Name='Basics of Communication',                AoE_LMS_ID__c='1001', Code__c='IC1001');
        Competency__c IC1002 = new Competency__c(Name='Describing Interpersonal Relationships', AoE_LMS_ID__c='1002', Code__c='IC1001');
        Competency__c IC1003 = new Competency__c(Name='Listening Effectively',                  AoE_LMS_ID__c='1003', Code__c='IC1001');
        Competency__c IC1004 = new Competency__c(Name='Effective Communication',                AoE_LMS_ID__c='1004', Code__c='IC1001');
        Competency__c IC1005 = new Competency__c(Name='Becoming a More Effective Communicator', AoE_LMS_ID__c='1005', Code__c='IC1001');
        competenciesList.add(IC1001);
        competenciesList.add(IC1002);
        competenciesList.add(IC1003);
        competenciesList.add(IC1004);
        competenciesList.add(IC1005);
        insert competenciesList;
        
        // Creating Competency Expertise objects
        List<Competency_Expertise__c> ceList = new List<Competency_Expertise__c>(); 
        Competency_Expertise__c ceIC1001 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise1.ID, IC1001.Id, null, true);
        Competency_Expertise__c ceIC1002 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise1.ID, IC1002.Id, null, true);
        Competency_Expertise__c ceIC1003 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise1.ID, IC1003.Id, null, true);
        Competency_Expertise__c ceIC1004 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise1.ID, IC1004.Id, null, true);
        Competency_Expertise__c ceIC1005 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise1.ID, IC1005.Id, null, true);
               
        // Create Program Expertise Test data 
        Program_Expertise__c pe1 = TestDataGenerator.createProgramExpertise(areaOfExpertise1.Id, product2.id, false, 1.0, false);
        pe1.category__c = 'General Education';
        insert pe1;
        Program_Expertise__c pe2 = TestDataGenerator.createProgramExpertise(areaOfExpertise2.Id, product2.id, false, 1.0, false);
        pe2.category__c = 'Core';
        insert pe2;
        Program_Expertise__c pe3 = TestDataGenerator.createProgramExpertise(areaOfExpertise3.Id, product2.id, false, 1.0, false);
        pe3.category__c = 'General Education; General Elective';
        insert pe3;
       
        // Create Student Expertise Test data 
        String studentExpertiseRecordTypeId = Schema.SObjectType.Student_Expertise__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Student_Expertise__c studentExpertise1 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise1.id, null , false);
        studentExpertise1.Program_Expertise__c = pe1.id;
        studentExpertise1.Student_Program__c = sProg.id;
        studentExpertise1.Is_Added_from_Program_Plan__c = true;
        studentExpertise1.Contact__c = testCon.Id;
        insert studentExpertise1;
        Student_Expertise__c studentExpertise2 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise2.id, null , false);
        studentExpertise2.Program_Expertise__c = pe2.id;
        studentExpertise2.Student_Program__c = sProg.id;
        studentExpertise2.Contact__c = testCon.Id;
        insert studentExpertise2;
        Student_Expertise__c studentExpertise3 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise3.id, null, false);
        studentExpertise3.Program_Expertise__c = pe3.id;
        studentExpertise3.Student_Program__c = sProg.id;   
        studentExpertise3.Contact__c = testCon.Id;
        insert studentExpertise3;
         
        // Creating Student Competency objects
        List<Student_Competency__c> scList = new List<Student_Competency__c>();
        Student_Competency__c scIC1001 = new student_competency__c(Student_Expertise__c=studentExpertise1.Id, Competency__c=IC1001.Id);
        Student_Competency__c scIC1002 = new student_competency__c(Student_Expertise__c=studentExpertise1.Id, Competency__c=IC1002.Id);
        Student_Competency__c scIC1003 = new student_competency__c(Student_Expertise__c=studentExpertise1.Id, Competency__c=IC1003.Id);
        Student_Competency__c scIC1004 = new student_competency__c(Student_Expertise__c=studentExpertise1.Id, Competency__c=IC1004.Id);
        Student_Competency__c scIC1005 = new student_competency__c(Student_Expertise__c=studentExpertise1.Id, Competency__c=IC1005.Id);     
        scList.add(scIC1001);
        scList.add(scIC1002);
        scList.add(scIC1003);
        scList.add(scIC1004);
        scList.add(scIC1005);
        insert scList;
        
        Pre_requisite_Rules__c preReqRulsObj = new Pre_requisite_Rules__c(Course_Name__c = areaOfExpertise1.Id, 
                                                                          Area_of_Expertise__c = areaOfExpertise1.Id);
        insert preReqRulsObj;
        
        test.startTest();
        System.runAs(usr) {
            PageReference pageRef = Page.EditMyProgram;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', sProg.Id);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(sProg);
            
            EditMyProgramController controller = new EditMyProgramController();
            ApexPages.currentPage().getParameters().put('selectedExpertiseIdToAdd', areaOfExpertise1.id);
            controller.addAreaOfExpertise();
            ApexPages.currentPage().getParameters().put('selectedExpertiseIdToRemove', areaOfExpertise1.id);
            controller.removeAreaOfExpertise();
            ApexPages.currentPage().getParameters().put('selectedExpertiseIdToAdd', areaOfExpertise2.id);
            controller.addAreaOfExpertise();
            ApexPages.currentPage().getParameters().put('selectedExpertiseIdToAdd', areaOfExpertise1.id);
            controller.addAreaOfExpertise();
            controller.saveCompetencies();
            controller.editMyProgramCancel();
            
        }        
        test.stopTest();         
    }
    
    static testMethod void testEditMyProgramRNMSN() {
  
        Institution__c institution = new Institution__c();
        institution.Name = 'Walden';
        institution.SFDC_System_Name__c = 'Walden';
        insert institution;
        
        Product2 parentProduct = new Product2();
        parentProduct.Institution__c = institution.id;
        parentProduct.Name = 'M.S in Nursing Informatics - RN to MSN';
        parentProduct.IsActive = true;
        parentProduct.Published__c = true;
        parentProduct.Effective_From_Date__c = Date.newInstance(2012,09,01);
        parentProduct.Effective_To_Date__c = Date.newInstance(2042,08,31);
        parentProduct.ProductCode = 'C_MSN_Info_RNMSN';
        parentProduct.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        insert parentProduct;
        
        Product2 product2 = new Product2();
        product2.Institution__c = institution.id;
        product2.Name = 'M.S in Nursing Informatics - RN to MSN';
        product2.IsActive = true;
        product2.Published__c = true;
        product2.Effective_From_Date__c = Date.newInstance(2012,09,01);
        product2.Effective_To_Date__c = Date.newInstance(2042,08,31);
        product2.ProductCode = 'C_MSN_Info_RNMSN';
        product2.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        product2.Parent_Program__c = parentProduct.Id;
    	product2.Degree_Level__c = 'Graduate';
        insert product2; 
    
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', true);
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = product2.Id;
        insert opp;
        
        Id standardPricebookId = Test.getStandardPricebookId();
        Pricebook2 pb = new Pricebook2(ID=standardPricebookId,Subscription_Duration_in_Months__c = 0);
        update pb;
    
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.IsStudentProgramActive__c = true;         
        insert sProg;
    
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg,pb, 'Walden', false);
        stuSub.Start_Date__c = Date.today().addDays(-40);
        stuSub.Subscription_Status__c = 'RE = Registered';
        stuSub.End_Date__c = Date.today().addDays(50);
        stuSub.List_Price__c = 3500;
        stuSub.Future_Term__c = false;
        stuSub.Agreed_To_Credits__c = 2;
        stuSub.Date_Student_Agreed_To_Credits__c = null;
        insert stuSub;
    
        sProg.Current_Student_Subscription__c = stuSub.Id;
        update sProg;            
        Profile communityProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Tempo Community Users'
            LIMIT 1 ];
        user usr = new user();
        usr.Username = testCon.email;
        usr.ContactId = testCon.id;
        usr.ProfileId = communityProfile.Id;
        usr.Alias = testCon.FirstName;
        usr.Email = testCon.email + '.Walden';
        usr.FirstName = testCon.FirstName;
        usr.LastName = testCon.LastName;
        usr.FederationIdentifier = testCon.CBL_Student_ID__c;
        usr.TimeZoneSidKey = 'America/New_York';
        usr.LocaleSidKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        usr.IsActive = true;
        insert usr;
        Brand_Configuration__c brandConf = TestDataGenerator.createBrandConfiguration('Test Brand Configuratiomn', 'TEST','Header', true) ;
        Community_Site_Settings__c defaultCustomSetngs = new Community_Site_Settings__c();
        defaultCustomSetngs.Name = 'Default Settings';
        defaultCustomSetngs.RecordID__c = brandConf.id;
        defaultCustomSetngs.Intercom_Secret_Key__c = 'U8BjsjJnasonsauho32873ashj783HHBS';
        insert defaultCustomSetngs;       
        
        //--Create area of exprtise
        Area_of_Expertise__c areaOfExpertise1 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExpertise1.Name = 'Interpersonal Communication(COMM 1004C)';
        areaOfExpertise1.Display_Name__c = 'Interpersonal Communication(COMM 1004C)';
        areaOfExpertise1.Display_on_Program_Edit__c  = TRUE;
        areaOfExpertise1.Display_on_web__c = TRUE;
        areaOfExpertise1.category__c = 'General Education';
        areaOfExpertise1.overview__c= 'TEST DESCRIPTION';
        areaOfExpertise1.LMS_ID__c = '1001';
        insert areaOfExpertise1;
        
        Area_of_Expertise__c areaOfExpertise2 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExpertise2.Name = 'Psychology(PSYC 1001)';
        areaOfExpertise2.Display_Name__c = 'Psychology(PSYC 1001)';
        areaOfExpertise2.Display_on_Program_Edit__c  = TRUE;
        areaOfExpertise2.Display_on_web__c = TRUE;
        areaOfExpertise2.category__c = 'General Education; General Elective';
        areaOfExpertise2.overview__c= 'TEST DESCRIPTION';
        areaOfExpertise2.LMS_ID__c = '1002';
        insert areaOfExpertise2;
        
        Area_of_Expertise__c areaOfExpertise3 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExpertise3.Name = 'World Religions (RELG 2001)';
        areaOfExpertise3.Display_Name__c = 'World Religions (RELG 2001)';
        areaOfExpertise3.Display_on_Program_Edit__c  = TRUE;
        areaOfExpertise3.category__c = 'General Education';
        areaOfExpertise3.overview__c= 'TEST DESCRIPTION';
        areaOfExpertise3.Display_on_web__c = TRUE;
        areaOfExpertise3.LMS_ID__c = '1003';
        insert areaOfExpertise3;
        
        // Inserting Master AoEs
        Master_AoE__c masterAOE1 = new Master_AoE__c();
        masterAOE1.Course__c = areaOfExpertise1.Id;
        masterAOE1.Program__c = product2.Id;
        insert masterAOE1;
        
        Master_AoE__c masterAOE2 = new Master_AoE__c();
        masterAOE2.Course__c = areaOfExpertise2.Id;
        masterAOE2.Program__c = product2.Id;
        insert masterAOE2;
        
        Master_AoE__c masterAOE3 = new Master_AoE__c();
        masterAOE3.Course__c = areaOfExpertise3.Id;
        masterAOE3.Program__c = product2.Id;
        insert masterAOE3;
        
        // Creating Competency objects
        List<Competency__c> competenciesList = new List<Competency__c>();
        Competency__c IC1001 = new Competency__c(Name='Basics of Communication',                AoE_LMS_ID__c='1001', Code__c='IC1001');
        Competency__c IC1002 = new Competency__c(Name='Describing Interpersonal Relationships', AoE_LMS_ID__c='1001', Code__c='IC1001');
        Competency__c IC1003 = new Competency__c(Name='Listening Effectively',                  AoE_LMS_ID__c='1001', Code__c='IC1001');
        Competency__c IC1004 = new Competency__c(Name='Effective Communication',                AoE_LMS_ID__c='1001', Code__c='IC1001');
        Competency__c IC1005 = new Competency__c(Name='Becoming a More Effective Communicator', AoE_LMS_ID__c='1001', Code__c='IC1001');
        competenciesList.add(IC1001);
        competenciesList.add(IC1002);
        competenciesList.add(IC1003);
        competenciesList.add(IC1004);
        competenciesList.add(IC1005);
        Competency__c PY1001 = new Competency__c(Name='Psychology as a Science',                    AoE_LMS_ID__c='1002', Code__c='PY1001');
        Competency__c PY1002 = new Competency__c(Name='Sensing and Perceiving',                     AoE_LMS_ID__c='1002', Code__c='PY1002');
        Competency__c PY1003 = new Competency__c(Name='Learning and Memory',                        AoE_LMS_ID__c='1002', Code__c='PY1003');
        Competency__c PY1004 = new Competency__c(Name='Personality and Social Behaviors',           AoE_LMS_ID__c='1002', Code__c='PY1004');
        Competency__c PY1005 = new Competency__c(Name='Human Development, Motivation, and Emotion', AoE_LMS_ID__c='1002', Code__c='PY1005');
        Competency__c PY1006 = new Competency__c(Name='	Psychological Disorders and Treatment',     AoE_LMS_ID__c='1002', Code__c='PY1006');
        competenciesList.add(PY1001);
        competenciesList.add(PY1002);
        competenciesList.add(PY1003);
        competenciesList.add(PY1004);
        competenciesList.add(PY1005);
        competenciesList.add(PY1006);
        insert competenciesList;
        
        // Creating Competency Expertise objects
        List<Competency_Expertise__c> ceList = new List<Competency_Expertise__c>(); 
        Competency_Expertise__c ceIC1001 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise1.ID, IC1001.Id, null, true);
        Competency_Expertise__c ceIC1002 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise1.ID, IC1002.Id, null, true);
        Competency_Expertise__c ceIC1003 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise1.ID, IC1003.Id, null, true);
        Competency_Expertise__c ceIC1004 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise1.ID, IC1004.Id, null, true);
        Competency_Expertise__c ceIC1005 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise1.ID, IC1005.Id, null, true);
        Competency_Expertise__c cePY1001 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise2.ID, PY1001.Id, null, true);
        Competency_Expertise__c cePY1002 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise2.ID, PY1002.Id, null, true);
        Competency_Expertise__c cePY1003 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise2.ID, PY1003.Id, null, true);
        Competency_Expertise__c cePY1004 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise2.ID, PY1004.Id, null, true);
        Competency_Expertise__c cePY1005 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise2.ID, PY1005.Id, null, true);
        Competency_Expertise__c cePY1006 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise2.ID, PY1006.Id, null, true);
               
        // Create Program Expertise Test data 
        Program_Expertise__c pe1 = TestDataGenerator.createProgramExpertise(areaOfExpertise1.Id, product2.id, false, 1.0, false);
        pe1.category__c = 'General Education';
        insert pe1;
        Program_Expertise__c pe2 = TestDataGenerator.createProgramExpertise(areaOfExpertise2.Id, product2.id, false, 1.0, false);
        pe2.category__c = 'General Education';
        insert pe2;
        Program_Expertise__c pe3 = TestDataGenerator.createProgramExpertise(areaOfExpertise3.Id, product2.id, false, 1.0, false);
        pe3.category__c = 'General Education; General Elective';
        insert pe3;
       
        // Create Student Expertise Test data 
        String studentExpertiseRecordTypeId = Schema.SObjectType.Student_Expertise__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Student_Expertise__c studentExpertise1 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise1.id, null , false);
        studentExpertise1.Program_Expertise__c = pe1.id;
        studentExpertise1.Student_Program__c = sProg.id;
        studentExpertise1.Is_Removed_from_Program_Plan__c = true;
        studentExpertise1.Contact__c = testCon.Id;
        insert studentExpertise1;
        Student_Expertise__c studentExpertise2 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise2.id, null , false);
        studentExpertise2.Program_Expertise__c = pe2.id;
        studentExpertise2.Student_Program__c = sProg.id;
        studentExpertise2.Contact__c = testCon.Id;
        studentExpertise2.Is_Added_from_Program_Plan__c = false;
        studentExpertise2.Is_Removed_from_Program_Plan__c = false;
        insert studentExpertise2;
        Student_Expertise__c studentExpertise3 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise3.id, null, false);
        studentExpertise3.Program_Expertise__c = pe3.id;
        studentExpertise3.Student_Program__c = sProg.id;   
        studentExpertise3.Contact__c = testCon.Id;
        insert studentExpertise3;
         
        // Creating Student Competency objects
        List<Student_Competency__c> scList = new List<Student_Competency__c>();
        Student_Competency__c scIC1001 = new student_competency__c(Student_Expertise__c=studentExpertise1.Id, Competency__c=IC1001.Id);
        Student_Competency__c scIC1002 = new student_competency__c(Student_Expertise__c=studentExpertise1.Id, Competency__c=IC1002.Id);
        Student_Competency__c scIC1003 = new student_competency__c(Student_Expertise__c=studentExpertise1.Id, Competency__c=IC1003.Id);
        Student_Competency__c scIC1004 = new student_competency__c(Student_Expertise__c=studentExpertise1.Id, Competency__c=IC1004.Id);
        Student_Competency__c scIC1005 = new student_competency__c(Student_Expertise__c=studentExpertise1.Id, Competency__c=IC1005.Id);     
        scList.add(scIC1001);
        scList.add(scIC1002);
        scList.add(scIC1003);
        scList.add(scIC1004);
        scList.add(scIC1005);
        Student_Competency__c scPY1001 = new student_competency__c(Student_Expertise__c=studentExpertise2.Id, Competency__c=PY1001.Id, Is_Enrolled__c=true);
        Student_Competency__c scPY1002 = new student_competency__c(Student_Expertise__c=studentExpertise2.Id, Competency__c=PY1002.Id, Is_Enrolled__c=true);
        Student_Competency__c scPY1003 = new student_competency__c(Student_Expertise__c=studentExpertise2.Id, Competency__c=PY1003.Id, Is_Enrolled__c=true);
        Student_Competency__c scPY1004 = new student_competency__c(Student_Expertise__c=studentExpertise2.Id, Competency__c=PY1004.Id, Is_Enrolled__c=true);
        Student_Competency__c scPY1005 = new student_competency__c(Student_Expertise__c=studentExpertise2.Id, Competency__c=PY1005.Id, Is_Enrolled__c=true);
        Student_Competency__c scPY1006 = new student_competency__c(Student_Expertise__c=studentExpertise2.Id, Competency__c=PY1006.Id, Is_Enrolled__c=true);
        scList.add(scPY1001);
        scList.add(scPY1002);
        scList.add(scPY1003);
        scList.add(scPY1004);
        scList.add(scPY1005);
        scList.add(scPY1006);
        insert scList;
        
        // Custom setting
        List<Grad_Programs_for_GenEd_and_GenElective__c> gradProgramsForGenEdGenElectiveList = new List<Grad_Programs_for_GenEd_and_GenElective__c>();
        gradProgramsForGenEdGenElectiveList.add(new Grad_Programs_for_GenEd_and_GenElective__c(Name='C_MSN_Info_RNMSN'));
        insert gradProgramsForGenEdGenElectiveList;
        
        List<Nurs_Courses_for_MSN_RN__c> nursCoursesList = new List<Nurs_Courses_for_MSN_RN__c>();
        nursCoursesList.add(new Nurs_Courses_for_MSN_RN__c(Name='NURS 3020'));
        insert nursCoursesList;
        
        Pre_requisite_Rules__c preReqRulsObj = new Pre_requisite_Rules__c(Course_Name__c = areaOfExpertise1.Id, 
                                                                          Area_of_Expertise__c = areaOfExpertise1.Id);
        insert preReqRulsObj;
        
        test.startTest();
        System.runAs(usr) {
            PageReference pageRef = Page.EditMyProgram;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', sProg.Id);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(sProg);
            
            EditMyProgramController controller = new EditMyProgramController();
            ApexPages.currentPage().getParameters().put('selectedExpertiseIdToAdd', areaOfExpertise1.id);
            controller.addAreaOfExpertise();
            ApexPages.currentPage().getParameters().put('selectedExpertiseIdToRemove', areaOfExpertise1.id);
            controller.removeAreaOfExpertise();
            ApexPages.currentPage().getParameters().put('selectedExpertiseIdToAdd', areaOfExpertise2.id);
            controller.addAreaOfExpertise();
            ApexPages.currentPage().getParameters().put('selectedExpertiseIdToAdd', areaOfExpertise1.id);
            controller.addAreaOfExpertise();
            controller.saveCompetencies();
            controller.editMyProgramCancel();
            
        }        
        test.stopTest();         
    }
}