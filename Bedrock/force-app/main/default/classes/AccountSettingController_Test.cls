/*******************************************************************
Name  : AccountSettingsController_Test
Description: Test class for Controller extension class AccountSettingsController

* Revision History
* Horacio Sanchez   11/26/2020     S-28146: Tempo: View Active Student Hold Codes on Tempo Student Portal
* Horacio Sanchez   05/04/2021     S-50437: L2: Update Tempo Student Id card template
*************************************************************************/
@isTest
public class AccountSettingController_Test {
    static testMethod void testViewCompCards() {

        // Create Test Data
        Course__c testCourse = TestDataGenerator.createNewCourse('EDU-Test', true);
        Course__c testCourse1 = TestDataGenerator.createNewCourse('EDU-Test1', true);
        Course__c testCourse2 = TestDataGenerator.createNewCourse('EDU-Test2', true);
        list<Competency__c> competencies = new list<Competency__c>();
        Competency__c newCompetency1 = TestDataGenerator.createCompetency('Comp1', false);
        newCompetency1.Type__c = 'Academic';
        Competency__c newCompetency2 = TestDataGenerator.createCompetency('Comp2', false);
        Competency__c newCompetency3 = TestDataGenerator.createCompetency('Comp3', false);
        //Competency__c  newCompetency4 = TestDataGenerator.createCompetency('Comp4',false);
        newCompetency1.Code__c = 'PM000';

        newCompetency1.Credit_Equivalency__c = .25;
        newCompetency1.Credit_Equivalency__c = 1.25;
        newCompetency1.Credit_Equivalency__c = 3.25;
        competencies.add(newCompetency1);
        competencies.add(newCompetency2);
        competencies.add(newCompetency3);
        insert competencies;

        list<Course_Competency__c> courseCompetencies = new list<Course_Competency__c>();
        Course_Competency__c crsCompetency1 = TestDataGenerator.createNewCourseCompetency(testCourse.id, newCompetency1.id, false);
        Course_Competency__c crsCompetency2 = TestDataGenerator.createNewCourseCompetency(testCourse.id, newCompetency2.id, false);
        Course_Competency__c crsCompetency3 = TestDataGenerator.createNewCourseCompetency(testCourse.id, newCompetency3.id, false);
        courseCompetencies.add(crsCompetency1);
        courseCompetencies.add(crsCompetency2);
        courseCompetencies.add(crsCompetency3);
        insert courseCompetencies;

        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.Id;
        insert product2;

        list<Program_Competency__c> progCompetencies = new list<Program_Competency__c>();
        Program_Competency__c testPComo1 = TestDataGenerator.createProgramCompetency(newCompetency1.Id, product2.Id, true, 4.0, false);
        testPComo1.average_difficulty_level__c = '1';
        Program_Competency__c testPComo2 = TestDataGenerator.createProgramCompetency(newCompetency1.Id, product2.Id, true, 3.0, false);
        testPComo2.average_difficulty_level__c = '2';
        Program_Competency__c testPComo3 = TestDataGenerator.createProgramCompetency(newCompetency1.Id, product2.Id, true, 2.0, false);
        testPComo3.average_difficulty_level__c = '3';
        Program_Competency__c testPComo4 = TestDataGenerator.createProgramCompetency(newCompetency3.Id, product2.Id, true, 1.0, false);
        testPComo4.average_difficulty_level__c = '4';
        Program_Competency__c testPComo5 = TestDataGenerator.createProgramCompetency(newCompetency3.Id, product2.Id, true, 5.0, false);
        testPComo5.average_difficulty_level__c = '1';

        progCompetencies.add(testPComo1);
        progCompetencies.add(testPComo2);
        progCompetencies.add(testPComo3);
        progCompetencies.add(testPComo4);
        progCompetencies.add(testPComo5);
        insert progCompetencies;

        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, false);
        testCon.MailingState = 'Maryland';
        testCon.MailingStateCode = 'MD';
        insert testCon;
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', true);
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = product2.Id;
        insert opp;
        Area_of_Expertise__c aoe= TestDataGenerator.createAreaOfExpertise(TRUE);
        update aoe;
        Student_Expertise__c stuExpert = TestDataGenerator.createCompetencyExpertise(aoe.id,'Walden', TRUE);
        //insert stuExpert;
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
       	sProg.IsStudentProgramActive__c = true; 
		insert sProg;
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
        
        Brand_Profile__c brandPro = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        brandPro.Email__c = testCon.Email;
        brandPro.Primary_Program_of_Interest__c = prod.id;
        brandPro.Contact__c  =testCon.id;
        insert brandPro; 
        /*
        Program_Start_Date__c tstStartDate  = TestDataGenerator.createProgramStartDate(false);
        tstStartDate.Name = 'testProgramStartdate';
        tstStartDate.Program__c = prod.Id;
        insert tstStartDate;*/
        Brand_Configuration__c brandConf = TestDataGenerator.createBrandConfiguration(  'Test Brand Configuratiomn', 'TEST','Header', TRUE) ;
        Community_Site_Settings__c defaultCustomSetngs = new Community_Site_Settings__c();
        defaultCustomSetngs.Name = 'Default Settings';
        defaultCustomSetngs.Intercom_Secret_Key__c = 'U8BjsjJnasonsauho32873ashj783HHBS';
        defaultCustomSetngs.RecordID__c = brandConf.id;
        defaultCustomSetngs.ECSI_Prefix__c ='@yetvs%';
        defaultCustomSetngs.ECSI_School_Code__c=  'AOPVEU';
        defaultCustomSetngs.ECSI_Suffix__c = 'Bi828i#';
        insert defaultCustomSetngs;
        // create strudent competency
        list<Student_Competency__c> studentCompentencies = new list<Student_Competency__c>();
        Student_Competency__c sCometency1 = TestDataGenerator.createStudentCompetency(sProg.id, newCompetency1.id, 'Walden', false);
        sCometency1.clp_active__c = true;
        sCometency1.IsCompleted__c = true;
        sCometency1.Is_Enrolled__c = true;
        //sCometency1.Competency__c= newCompetency4.id;
        Student_Competency__c sCometency2 = TestDataGenerator.createStudentCompetency(sProg.id, newCompetency2.id, 'Walden', false);
        //Student_Competency__c sCometency3 = TestDataGenerator.createStudentCompetency(sProg.id,newCompetency1.id,'Walden', false);
        Student_Competency__c sCometency4 = TestDataGenerator.createStudentCompetency(sProg.id, newCompetency3.id, 'Walden', false);
        studentCompentencies.add(sCometency1);
        studentCompentencies.add(sCometency2);
        //studentCompentencies.add(sCometency3);
        studentCompentencies.add(sCometency4);
        insert studentCompentencies;

        //create program course
        list<Program_Courses__c> programCourse = new list<Program_Courses__c>();
        Program_Courses__c pc1 = TestDataGenerator.createProgramCourse(sProg.Program__c, testCourse.id, false);
        Program_Courses__c pc2 = TestDataGenerator.createProgramCourse(sProg.Program__c, testCourse1.id, false);
        Program_Courses__c pc3 = TestDataGenerator.createProgramCourse(sProg.Program__c, testCourse2.id, false);
        programCourse.add(pc1);
        programCourse.add(pc2);
        programCourse.add(pc3);
        insert programCourse;
        
         PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  
        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        Double cost = 3000.00;
        PricebookEntry entry = TestDataGenerator.createPricebookEntry(parentProduct.Id, pBook.Id, cost, false, false);
        entry.Available_for_Existing_Students__c = true;
        Student_Subscription__c oldStuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        oldStuSub.Start_Date__c =Date.today().addDays(-10);
        oldStuSub.Number_of_Credits_Completed__c =  50;
        oldStuSub.Agreed_To_Credits__c =3;
        insert oldStuSub;  
     	sProg.Current_Student_Subscription__c =oldStuSub.id;
		sProg.IsStudentProgramActive__c = true; 
        //sProg.Program_Start_Date__c =tstStartDate.id;
		update sProg;
          // create strudent competency
        list<Student_Competency__c> studentCompentencies1 = new  list<Student_Competency__c>();
        
        
        //--Create area of exprtise
        Area_of_Expertise__c areaOfExpertise1 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExpertise1.Name = 'Test expertise';
        insert areaOfExpertise1;
        
        Area_of_Expertise__c areaOfExpertise2 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExpertise2.Name = 'Test expertise2';
        insert areaOfExpertise2;
        
        Area_of_Expertise__c areaOfExpertise3 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExpertise3.Name = 'Test expertise';
        insert areaOfExpertise3;
        
        String studentExpertiseRecordTypeId = Schema.SObjectType.Student_Expertise__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        
        Student_Expertise__c studentExpertise1 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise1.id, null , false);
        insert studentExpertise1;
        
        Student_Expertise__c studentExpertise2 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise2.id, null , false);
        insert studentExpertise2;
    
        Student_Expertise__c studentExpertise3 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise3.id, null, false);
        insert studentExpertise3;
       	/*Community_Site_Settings__c comSetting = new Community_Site_Settings__c();
        comSetting.name = 'Default Settings';
        comSetting.RecordID__c = brandPro.id;
        insert comSetting;*/
        
        Student_Program__c studentProgram = TestDataGenerator.createStudentProgram(opp, testCon.ID, null, true);
        test.startTest();
        PageReference pageRef = Page.MyTerm;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', sProg.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(studentProgram);
        AccountSettingsController accountSettingCont = new AccountSettingsController(sc);
        Double D1 = 4.5;
        date setStartDate = date.today();
        date setEndDate = date.today().addDays(90);
              
        Student_Program__c sp = [SELECT Name,student__r.Walden_email__c,student__r.Email,Student_Full_Name__c, Current_Student_Subscription__c,Student__r.firstname,Student__r.lastname, student__r.middle_name__c,
            CurrentSubscriptionStartDate__c, CurrentSubscriptionEndDate__c,Student__r.name,Current_Student_Subscription__r.Agreed_To_Credits__c,
            IsStudentProgramActive__c, Id, CoachEmail__c,Coach__r.Name,Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c,
            First_Start_Date__c,student__r.CBL_Student_ID__c,Program_Start_Date__r.Name,
            Active_Hold_Codes__c, Open_Document_Hold__c, Open_Bursar_Hold__c, Open_C2_Hold__c, Open_BK_Hold__c, Open_Contingency_Hold__c, 
            (SELECT Id FROM Subscriptions__r  where Future_Term__c = false order by createdDate DESC LIMIT 1)
            FROM Student_Program__c
            WHERE Id = :studentProgram.Id];
       
        Student_Competency__c sCometency_1 = TestDataGenerator.createStudentCompetency(sProg.id,newCompetency1.id,'Walden', false);
        sCometency_1.clp_active__c = true;
        sCometency_1.Student_Expertise__c = studentExpertise1.id;
        Student_Competency__c sCometency_2 = TestDataGenerator.createStudentCompetency(sProg.id,newCompetency2.id,'Walden', false);
        sCometency_2.Student_Expertise__c = studentExpertise2.id;
        Student_Competency__c sCometency_4 = TestDataGenerator.createStudentCompetency(sProg.id,newCompetency3.id,'Walden', false);
        sCometency_4.Student_Expertise__c = studentExpertise3.id;
        studentCompentencies1.add(sCometency_1);
        studentCompentencies1.add(sCometency_2);
        studentCompentencies1.add(sCometency_4);
        insert studentCompentencies1;
        accountSettingCont.updateAgreedToCreditsDate();
        System.runAs(usr){
            PageReference pageRef1 = Page.AccountSettings;
            Test.setCurrentPage(pageRef1);
            ApexPages.currentPage().getParameters().put('id', sp.Id);
            ApexPages.StandardController sc1 = new ApexPages.StandardController(sp);
            AccountSettingsController AccountSettingsCont = new AccountSettingsController(sc1);
            System.assertEquals(true, accountSettingsCont.isMarylandState);
        }
        testCon.MailingState = 'Texas';
        testCon.MailingStateCode = 'TX';
        update testCon;
        System.runAs(usr){
            PageReference pageRef1 = Page.AccountSettings;
            Test.setCurrentPage(pageRef1);
            ApexPages.currentPage().getParameters().put('id', sp.Id);
            ApexPages.StandardController sc1 = new ApexPages.StandardController(sp);
            AccountSettingsController AccountSettingsCont = new AccountSettingsController(sc1);
            System.assertEquals(false, accountSettingsCont.isMarylandState);
        }
        
        test.stopTest();
    }
    
    static testMethod void testNotAsUser() {
		// Create Test Data
        Course__c testCourse = TestDataGenerator.createNewCourse('EDU-Test', true);
        Course__c testCourse1 = TestDataGenerator.createNewCourse('EDU-Test1', true);
        Course__c testCourse2 = TestDataGenerator.createNewCourse('EDU-Test2', true);
        list<Competency__c> competencies = new list<Competency__c>();
        Competency__c newCompetency1 = TestDataGenerator.createCompetency('Comp1', false);
        newCompetency1.Type__c = 'Academic';
        Competency__c newCompetency2 = TestDataGenerator.createCompetency('Comp2', false);
        Competency__c newCompetency3 = TestDataGenerator.createCompetency('Comp3', false);
        //Competency__c  newCompetency4 = TestDataGenerator.createCompetency('Comp4',false);
        newCompetency1.Code__c = 'PM000';

        newCompetency1.Credit_Equivalency__c = .25;
        newCompetency1.Credit_Equivalency__c = 1.25;
        newCompetency1.Credit_Equivalency__c = 3.25;
        competencies.add(newCompetency1);
        competencies.add(newCompetency2);
        competencies.add(newCompetency3);
        insert competencies;

        list<Course_Competency__c> courseCompetencies = new list<Course_Competency__c>();
        Course_Competency__c crsCompetency1 = TestDataGenerator.createNewCourseCompetency(testCourse.id, newCompetency1.id, false);
        Course_Competency__c crsCompetency2 = TestDataGenerator.createNewCourseCompetency(testCourse.id, newCompetency2.id, false);
        Course_Competency__c crsCompetency3 = TestDataGenerator.createNewCourseCompetency(testCourse.id, newCompetency3.id, false);
        courseCompetencies.add(crsCompetency1);
        courseCompetencies.add(crsCompetency2);
        courseCompetencies.add(crsCompetency3);
        insert courseCompetencies;

        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.Id;
        insert product2;

        list<Program_Competency__c> progCompetencies = new list<Program_Competency__c>();
        Program_Competency__c testPComo1 = TestDataGenerator.createProgramCompetency(newCompetency1.Id, product2.Id, true, 4.0, false);
        testPComo1.average_difficulty_level__c = '1';
        Program_Competency__c testPComo2 = TestDataGenerator.createProgramCompetency(newCompetency1.Id, product2.Id, true, 3.0, false);
        testPComo2.average_difficulty_level__c = '2';
        Program_Competency__c testPComo3 = TestDataGenerator.createProgramCompetency(newCompetency1.Id, product2.Id, true, 2.0, false);
        testPComo3.average_difficulty_level__c = '3';
        Program_Competency__c testPComo4 = TestDataGenerator.createProgramCompetency(newCompetency3.Id, product2.Id, true, 1.0, false);
        testPComo4.average_difficulty_level__c = '4';
        Program_Competency__c testPComo5 = TestDataGenerator.createProgramCompetency(newCompetency3.Id, product2.Id, true, 5.0, false);
        testPComo5.average_difficulty_level__c = '1';

        progCompetencies.add(testPComo1);
        progCompetencies.add(testPComo2);
        progCompetencies.add(testPComo3);
        progCompetencies.add(testPComo4);
        progCompetencies.add(testPComo5);
        insert progCompetencies;

        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', true);
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = product2.Id;
        insert opp;
        Area_of_Expertise__c aoe= TestDataGenerator.createAreaOfExpertise(TRUE);
        update aoe;
        Student_Expertise__c stuExpert = TestDataGenerator.createCompetencyExpertise(aoe.id,'Walden', TRUE);
        //insert stuExpert;
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
       	sProg.IsStudentProgramActive__c = true; 
		insert sProg;
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
        
        Brand_Profile__c brandPro = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        brandPro.Email__c = testCon.Email;
        brandPro.Primary_Program_of_Interest__c = prod.id;
        brandPro.Contact__c  =testCon.id;
        insert brandPro; 
        /*
        Program_Start_Date__c tstStartDate  = TestDataGenerator.createProgramStartDate(false);
        tstStartDate.Name = 'testProgramStartdate';
        tstStartDate.Program__c = prod.Id;
        insert tstStartDate;*/
        Brand_Configuration__c brandConf = TestDataGenerator.createBrandConfiguration(  'Test Brand Configuratiomn', 'TEST','Header', TRUE) ;
        Community_Site_Settings__c defaultCustomSetngs = new Community_Site_Settings__c();
        defaultCustomSetngs.Name = 'Default Settings';
        defaultCustomSetngs.Intercom_Secret_Key__c = 'U8BjsjJnasonsauho32873ashj783HHBS';
        defaultCustomSetngs.RecordID__c = brandConf.id;
        defaultCustomSetngs.ECSI_Prefix__c ='@yetvs%';
        defaultCustomSetngs.ECSI_School_Code__c=  'AOPVEU';
        defaultCustomSetngs.ECSI_Suffix__c = 'Bi828i#';
        insert defaultCustomSetngs;
        // create strudent competency
        list<Student_Competency__c> studentCompentencies = new list<Student_Competency__c>();
        Student_Competency__c sCometency1 = TestDataGenerator.createStudentCompetency(sProg.id, newCompetency1.id, 'Walden', false);
        sCometency1.clp_active__c = true;
        sCometency1.IsCompleted__c = true;
        sCometency1.Is_Enrolled__c = true;
        //sCometency1.Competency__c= newCompetency4.id;
        Student_Competency__c sCometency2 = TestDataGenerator.createStudentCompetency(sProg.id, newCompetency2.id, 'Walden', false);
        //Student_Competency__c sCometency3 = TestDataGenerator.createStudentCompetency(sProg.id,newCompetency1.id,'Walden', false);
        Student_Competency__c sCometency4 = TestDataGenerator.createStudentCompetency(sProg.id, newCompetency3.id, 'Walden', false);
        studentCompentencies.add(sCometency1);
        studentCompentencies.add(sCometency2);
        //studentCompentencies.add(sCometency3);
        studentCompentencies.add(sCometency4);
        insert studentCompentencies;

        //create program course
        list<Program_Courses__c> programCourse = new list<Program_Courses__c>();
        Program_Courses__c pc1 = TestDataGenerator.createProgramCourse(sProg.Program__c, testCourse.id, false);
        Program_Courses__c pc2 = TestDataGenerator.createProgramCourse(sProg.Program__c, testCourse1.id, false);
        Program_Courses__c pc3 = TestDataGenerator.createProgramCourse(sProg.Program__c, testCourse2.id, false);
        programCourse.add(pc1);
        programCourse.add(pc2);
        programCourse.add(pc3);
        insert programCourse;
        
         PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  
        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        Double cost = 3000.00;
        PricebookEntry entry = TestDataGenerator.createPricebookEntry(parentProduct.Id, pBook.Id, cost, false, false);
        entry.Available_for_Existing_Students__c = true;
        Student_Subscription__c oldStuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        oldStuSub.Start_Date__c =Date.today().addDays(-10);
        oldStuSub.Number_of_Credits_Completed__c =  50;
        oldStuSub.Agreed_To_Credits__c =3;
        insert oldStuSub;  
     	sProg.Current_Student_Subscription__c =oldStuSub.id;
		sProg.IsStudentProgramActive__c = true; 
        //sProg.Program_Start_Date__c =tstStartDate.id;
		update sProg;
          // create strudent competency
        list<Student_Competency__c> studentCompentencies1 = new  list<Student_Competency__c>();
        
        
        //--Create area of exprtise
        Area_of_Expertise__c areaOfExpertise1 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExpertise1.Name = 'Test expertise';
        insert areaOfExpertise1;
        
        Area_of_Expertise__c areaOfExpertise2 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExpertise2.Name = 'Test expertise2';
        insert areaOfExpertise2;
        
        Area_of_Expertise__c areaOfExpertise3 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExpertise3.Name = 'Test expertise';
        insert areaOfExpertise3;
        
        String studentExpertiseRecordTypeId = Schema.SObjectType.Student_Expertise__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        
        Student_Expertise__c studentExpertise1 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise1.id, null , false);
        insert studentExpertise1;
        
        Student_Expertise__c studentExpertise2 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise2.id, null , false);
        insert studentExpertise2;
    
        Student_Expertise__c studentExpertise3 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise3.id, null, false);
        insert studentExpertise3;
       	/*Community_Site_Settings__c comSetting = new Community_Site_Settings__c();
        comSetting.name = 'Default Settings';
        comSetting.RecordID__c = brandPro.id;
        insert comSetting;*/
        
        Student_Program__c studentProgram = TestDataGenerator.createStudentProgram(opp, testCon.ID, null, true);
        test.startTest();
        PageReference pageRef = Page.MyTerm;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', sProg.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(studentProgram);
        AccountSettingsController accountSettingCont = new AccountSettingsController(sc);
        Double D1 = 4.5;
        date setStartDate = date.today();
        date setEndDate = date.today().addDays(90);
        
        List<Hold_Code_Notification__mdt> hcnList = [SELECT id, title__c, description__c, hold_code_Id__c FROM Hold_Code_Notification__mdt];
        
        Institution__c institution = new Institution__c(Name='Walden');
        insert institution;
        
        Hold_codes__c dhHoldCode = new Hold_codes__c();
        dhHoldCode.Institution__c = institution.Id;
        dhHoldCode.Name = 'DH';
        dhHoldCode.Description__c = 'DH';
        insert dhHoldCode;
        
        try {
            Student_Hold_Code__c shc = new Student_Hold_Code__c();
            shc.Student_Program__c = studentProgram.Id;
            shc.Hold_Code__c = hcnList[0].hold_code_id__c;
            insert shc;            
        } catch(Exception e) {
            System.debug('Exception: ' + e.getMessage());
            System.debug('on line: ' + e.getLineNumber());
        }       
        
        Student_Program__c sp = [SELECT Name,student__r.Walden_email__c,student__r.Email,Student_Full_Name__c, Current_Student_Subscription__c,Student__r.firstname,Student__r.lastname, student__r.middle_name__c,
            CurrentSubscriptionStartDate__c, CurrentSubscriptionEndDate__c,Student__r.name,Current_Student_Subscription__r.Agreed_To_Credits__c,
            IsStudentProgramActive__c, Id, CoachEmail__c,Coach__r.Name,Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c,
            First_Start_Date__c,student__r.CBL_Student_ID__c,Program_Start_Date__r.Name,
            Active_Hold_Codes__c, Open_Document_Hold__c, Open_Bursar_Hold__c, Open_C2_Hold__c, Open_BK_Hold__c, Open_Contingency_Hold__c, 
            (SELECT Id FROM Subscriptions__r  where Future_Term__c = false order by createdDate DESC LIMIT 1)
            FROM Student_Program__c
            WHERE Id = :studentProgram.Id];
          Student_Competency__c sCometency_1 = TestDataGenerator.createStudentCompetency(sProg.id,newCompetency1.id,'Walden', false);
        sCometency_1.clp_active__c = true;
        sCometency_1.Student_Expertise__c = studentExpertise1.id;
        Student_Competency__c sCometency_2 = TestDataGenerator.createStudentCompetency(sProg.id,newCompetency2.id,'Walden', false);
        sCometency_2.Student_Expertise__c = studentExpertise2.id;
        Student_Competency__c sCometency_4 = TestDataGenerator.createStudentCompetency(sProg.id,newCompetency3.id,'Walden', false);
        sCometency_4.Student_Expertise__c = studentExpertise3.id;
        studentCompentencies1.add(sCometency_1);
        studentCompentencies1.add(sCometency_2);
        studentCompentencies1.add(sCometency_4);
        insert studentCompentencies1;
        accountSettingCont.updateAgreedToCreditsDate();
        
        PageReference pageRef1 = Page.AccountSettings;
        Test.setCurrentPage(pageRef1);
        ApexPages.currentPage().getParameters().put('id', sp.Id);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(sp);
        AccountSettingsController controller = new AccountSettingsController(sc1);
        test.stopTest();
    }
}