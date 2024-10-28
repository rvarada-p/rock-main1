/************************************************************************
Name  : MyTermUndergradController_Test
Developer: Ravitej varada , March  2018
Description: Apex test class for the MyTermUndergradController Apex class
*************************************************************************/

@isTest
private class MyTermUndergradController_Test {
 
    
    static testMethod void testViewCompCards() {
        //Insert the custom settings for D2L
        D2L__c setting = new D2L__c();
        setting.Name = 'D2L';
        setting.Org_Unit_ID__c = 6606;      
        setting.AoE_Type__c = 101;
        setting.LP_Version__c = 1.50;
        setting.Create_AoE__c = '/d2l/api/lp/1.5/orgstructure/';
        setting.Create_Course_Template__c = '/d2l/api/lp/1.5/coursetemplates/';
        setting.Create_Competency_Shell__c = '/d2l/api/lp/1.5/courses/';
        setting.BS_LMS_URL__c  = 'https://tempolearningtest.brightspace.com/d2l/home/';
        insert setting; 
        
        // Create Test Data
        Course__c testCourse = TestDataGenerator.createNewCourse('EDU-Test', true);
        Course__c testCourse1 = TestDataGenerator.createNewCourse('EDU-Test1', true);
        Course__c testCourse2 = TestDataGenerator.createNewCourse('EDU-Test2', true);
        list<Competency__c> competencies = new list<Competency__c>();
        Competency__c newCompetency1 = TestDataGenerator.createCompetency('SP001', false);
        newCompetency1.Type__c = 'Academic';
        Competency__c newCompetency2 = TestDataGenerator.createCompetency('SP002', false);
        Competency__c newCompetency3 = TestDataGenerator.createCompetency('SP003', false);
        //Competency__c  newCompetency4 = TestDataGenerator.createCompetency('Comp4',false);

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
        product2.Degree_Level__c  = 'Graduate';
        insert product2;

        Program_Start_Date__c tstStartDate  = TestDataGenerator.createProgramStartDate(false);
        tstStartDate.Name = 'testProgramStartdate';
        tstStartDate.Program__c = product2.Id;
        tstStartDate.Start_Date__c = system.today();
        insert tstStartDate;
        
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
        aoe.Display_On_Web__c = TRUE;
        update aoe;
        Student_Expertise__c stuExpert = TestDataGenerator.createCompetencyExpertise(aoe.id,'Walden', TRUE);
        //insert stuExpert;
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.IsStudentProgramActive__c = true;
        //sProg.Program_Start_Date__c =  tstStartDate.id;
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
        Brand_Configuration__c brandConf = TestDataGenerator.createBrandConfiguration(  'Test Brand Configuratiomn', 'TEST','Header', TRUE) ;
        Community_Site_Settings__c defaultCustomSetngs = new Community_Site_Settings__c();
        defaultCustomSetngs.Name = 'Default Settings';
        defaultCustomSetngs.RecordID__c = brandConf.id;
        defaultCustomSetngs.Intercom_Secret_Key__c = 'U8BjsjJnasonsauho32873ashj783HHBS';
        insert defaultCustomSetngs;

        // create strudent competency
        list<Student_Competency__c> studentCompentencies = new list<Student_Competency__c>();
        Student_Competency__c sCometency1 = TestDataGenerator.createStudentCompetency(sProg.id, newCompetency1.id, 'Walden', false);
        sCometency1.clp_active__c = true;
        sCometency1.IsCompleted__c = true;
        sCometency1.Is_Enrolled__c = true;
        sCometency1.Student_Expertise__c=stuExpert.id;      
        studentCompentencies.add(sCometency1);
        insert studentCompentencies;
 
        system.debug('###sCometency_Competency_Code__c'+sCometency1.Competency_Code__c);

        Sections__c section = new Sections__c();
        section.SME__c = usr.id;
        section.Competency__c = newCompetency2.Id;
        section.LMS_Section_ID__c = 4343;
        insert section;
        
        Student_Sections__c studentSection = new Student_Sections__c();
        studentSection.Section__c = section.Id;
        studentSection.Student_Competency__c = sCometency1.Id;
        insert studentSection;

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
        update sProg;
        

        Student_Program__c studentProgram = TestDataGenerator.createStudentProgram(opp, testCon.ID, null, true);
        test.startTest();
        PageReference pageRef = Page.MyTermUndergrad;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', sProg.Id);
        system.debug('student program id is' + sProg.Id);
        system.debug('Calling the controller');
        ApexPages.StandardController sc = new ApexPages.StandardController(studentProgram);

        MyTermUndergradController MyTermController = new MyTermUndergradController(sc);
        Double D1 = 4.5;
        date setStartDate = date.today();
        date setEndDate = date.today().addDays(90);
        MyTermController.compCardDetails comp = new MyTermController.compCardDetails('PM000', D1, 'Academic Profile', 'SMEAssignment', 'Academic Profile', 'Non-Academic', 'SyllabusLink', 'Achieved', setStartDate, setEndDate, true, false);
        MyTermController.selectedDate = '10-10-2017';
        MyTermController.dateType = 'start';
        MyTermController.daysRemaining = 0;
        MyTermController.selectedCompCode = sCometency1.competency_code__c ;
        
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
           Student_Competency__c sCometency_1 = TestDataGenerator.createStudentCompetency(sProg.id,newCompetency1.id,'Walden', false);
        sCometency_1.clp_active__c = true;
        sCometency_1.Student_Expertise__c = studentExpertise1.id;

        Student_Competency__c sCometency_2 = TestDataGenerator.createStudentCompetency(sProg.id,newCompetency2.id,'Walden', false);
        sCometency_2.Student_Expertise__c = studentExpertise1.id;
        Student_Competency__c sCometency_4 = TestDataGenerator.createStudentCompetency(sProg.id,newCompetency3.id,'Walden', false);
        sCometency_4.Student_Expertise__c = studentExpertise2.id;
        studentCompentencies1.add(sCometency_1);
        studentCompentencies1.add(sCometency_2);
        studentCompentencies1.add(sCometency_4);
        insert studentCompentencies1;
        
        

        //MyTermController.checkSelfAssessmentSubmittedFlag();       
        MyTermController.updateAgreedToCreditsDate();
        MyTermController.degreeLevelCheck();
        MyTermController.updateDateToDB();
        MyTermController.updateWelcomeMessage();
        
        Student_Competency__c stuComp = [ Select id,name,Assessment_Submitted__c,
                                         Competency_Code__c
                                          from Student_Competency__c 
                                          where Student_Program__c = :sProg.Id 
                                          LIMIT 1 ];
        MyTermController.selectedCompCode = stuComp.Competency_Code__c;
        MyTermController.checkSelfAssessmentSubmittedFlag();       

        
          System.runAs(usr){
          PageReference pageRef1 = Page.MyTerm;
        Test.setCurrentPage(pageRef1);
        ApexPages.currentPage().getParameters().put('id', sProg.Id);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(studentProgram);
        MyTermUndergradController MyTermCon = new MyTermUndergradController(sc1);
          }
        test.stopTest();
    }
}