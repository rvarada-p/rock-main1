@istest
public class SMEAssignmentToolController_Test {
    Public static Student_Program__c sProg;
    Public static opportunity opp;
    Public static contact testCon;
    Public static Product2 prod;
    Public static Pricebook2 pBook;    
    Public static Sections__c section;    
    
    
    static void setup() {
        
        //Insert the custom settings for D2L
        D2L__c setting = new D2L__c();
        setting.Name = 'D2L';
        setting.Section_Initialization__c = '6606';      
        setting.Enrollment_Style__c = 110;
        setting.LP_Version__c = 1.18;
        setting.Enrollment_Quantity__c = 110;
        setting.SME_Role_ID__c = 333;
        setting.Create_Enrollment_Endpoint__c = '/user/app/tesr/';
        insert setting; 
        
        
        Course__c testCourse = TestDataGenerator.createNewCourse('EDU-Test', true);
        list<Competency__c> competencies = new list<Competency__c>();
        Competency__c newCompetency1 = TestDataGenerator.createCompetency('SP001', false);
        newCompetency1.Type__c = 'Academic';
        newCompetency1.Credit_Equivalency__c = .25;
        newCompetency1.Competency_Shell_ID__c ='9328';
        competencies.add(newCompetency1);
        
        insert competencies;
        
        
        List<Competency_Version__c> compVerLst = new List<Competency_Version__c>();
        
        Competency_Version__c compVer = new Competency_Version__c();
        compVer.Active__c = true;
        compVer.Competency_Shell_ID__c = '94924';
        compVer.Competency__c = newCompetency1.id;
        compVerLst.add(compVer);
        
        insert compVerLst;
        
        list<Course_Competency__c> courseCompetencies = new list<Course_Competency__c>();
        Course_Competency__c crsCompetency1 = TestDataGenerator.createNewCourseCompetency(testCourse.id, newCompetency1.id, false);
        courseCompetencies.add(crsCompetency1);
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
        
        
        progCompetencies.add(testPComo1);
        progCompetencies.add(testPComo2);
        
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
        usr.lms_id__c = 333;
        insert usr;
        
        
        // create strudent competency
        list<Student_Competency__c> studentCompentencies = new list<Student_Competency__c>();
        Student_Competency__c sCometency1 = TestDataGenerator.createStudentCompetency(sProg.id, newCompetency1.id, 'Walden', false);
        sCometency1.clp_active__c = true;
        sCometency1.IsCompleted__c = true;
        sCometency1.Is_Enrolled__c = true;
        sCometency1.Student_Expertise__c=stuExpert.id;      
        studentCompentencies.add(sCometency1);
        insert studentCompentencies; 
        
        section = new Sections__c();
        section.SME__c = usr.id;
        section.Competency__c = newCompetency1.Id;
        //section.LMS_Section_ID__c = 4343; 
        //section.Competency_Shell_ID__c = 4343;
        insert section;
        
        Student_Sections__c studentSection = new Student_Sections__c();
        studentSection.Section__c = section.Id;
        studentSection.Student_Competency__c = sCometency1.Id;
        
        insert studentSection;
        
        
        
        
    }
    static testMethod  void testMethodtwo() {
        setup();
        List<String> secId = new   List<String> ();
        secId.add(section.id);        
        system.debug('secList'+section);
        
        Test.startTest();
        SMEAssignmentToolController.getAllSection ();
        
        section.Enrolled_in_LMS__c = false;
        section.LMS_Section_ID__c = 333;
        
        update section;
        
        
        SMEAssignmentToolController.getAllSections ();
        
        
        Test.stopTest();
    }
    
    static testMethod void testMethodOne() {
        
        setup();
        List<String> secId = new   List<String> ();
        secId.add(section.id);        
        system.debug('secList'+section);
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new Mock_HttpResponse_SMEAssignment());
        SMEAssignmentToolController.createSections(secId);
        
        Test.stopTest();
    } 
    static testMethod void testMethodThree() {
        
        setup();
        List<String> secId = new   List<String> ();
        secId.add(section.id);        
        system.debug('secList'+section);
        
        section.LMS_Section_ID__c = 333;
        section.Enrolled_in_LMS__c  = false;
        update section;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new Mock_HttpResponse_SMEAssignment());
        SMEAssignmentToolController.enrollSMEsToSections(secId);
        
        
        Test.stopTest();
    } 
    
    
    static testMethod void testMethodFour() {
        
        setup();
        List<String> secId = new   List<String> ();
        secId.add(section.id);        
        system.debug('secList'+section);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock_HttpResponse_SMEAssignment_400());
        SMEAssignmentToolController.createSections(secId);
        
        Test.stopTest();
        
    } 
    
    
    
}