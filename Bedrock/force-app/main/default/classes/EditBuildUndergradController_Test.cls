/************************************************************************
Name  : EditBuildUndergradController_Test
Developer: Ravitej Varada, March 21 2018
Description: Apex test class for the EditBuildUndergradController Apex class
*************************************************************************/

@isTest
private class EditBuildUndergradController_Test {
static testMethod void testEditBuildCompCards() {
    // Create Test Data
        Course__c testCourse = TestDataGenerator.createNewCourse('EDU-Test', true);
        Course__c testCourse1 = TestDataGenerator.createNewCourse('EDU-Test1', true);
        Course__c testCourse2 = TestDataGenerator.createNewCourse('EDU-Test2', true);
        list<Competency__c> competencies = new list<Competency__c> ();
        Competency__c  newCompetency1 = TestDataGenerator.createCompetency('Comp1',false);
        Competency__c  newCompetency2 = TestDataGenerator.createCompetency('Comp2',false);
        Competency__c  newCompetency3 = TestDataGenerator.createCompetency('Comp3',false);
        
        competencies.add(newCompetency1);
        competencies.add(newCompetency2);
        competencies.add(newCompetency3);
        insert competencies;
        
        //Create brand configuration
        TestDataGenerator.createBrandConfiguration( 'Test Brand Configuration',
                                  'Messages',
                                  'CLP Status Messages', true);
        
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
        Program_Competency__c testPComo1 = TestDataGenerator.createProgramCompetency(newCompetency1.Id,product2.Id,true,4.0,false);
        testPComo1.average_difficulty_level__c = '1';
        Program_Competency__c testPComo2 = TestDataGenerator.createProgramCompetency(newCompetency1.Id,product2.Id,true,3.0,false);
        testPComo2.average_difficulty_level__c = '2';
        Program_Competency__c testPComo3 = TestDataGenerator.createProgramCompetency(newCompetency1.Id,product2.Id,true,2.0,false);
        testPComo3.average_difficulty_level__c = '3';
        Program_Competency__c testPComo4 = TestDataGenerator.createProgramCompetency(newCompetency3.Id,product2.Id,true,1.0,false);
        testPComo4.average_difficulty_level__c = '4';
        Program_Competency__c testPComo5 = TestDataGenerator.createProgramCompetency(newCompetency3.Id,product2.Id,true,5.0,false);
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
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.IsStudentProgramActive__c = true;
        insert sProg;
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
        Brand_Configuration__c brandConf = TestDataGenerator.createBrandConfiguration(  'Test Brand Configuratiomn', 'TEST','Header', TRUE) ;
        Community_Site_Settings__c defaultCustomSetngs = new Community_Site_Settings__c();
        defaultCustomSetngs.Name = 'Default Settings';
        defaultCustomSetngs.RecordID__c = brandConf.id;
        defaultCustomSetngs.Intercom_Secret_Key__c = 'U8BjsjJnasonsauho32873ashj783HHBS';
        insert defaultCustomSetngs;
            
    
         // create strudent competency
        list<Student_Competency__c> studentCompentencies = new  list<Student_Competency__c>();
        
        
        //--Create area of exprtise
        Area_of_Expertise__c areaOfExpertise1 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExpertise1.Name = 'Test expertise';
        areaOfExpertise1.Display_On_Web__c = TRUE;
        insert areaOfExpertise1;
        
        Area_of_Expertise__c areaOfExpertise2 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExpertise2.Name = 'Test expertise2';
        areaOfExpertise2.Display_On_Web__c = TRUE;
        insert areaOfExpertise2;
        
        Area_of_Expertise__c areaOfExpertise3 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExpertise3.Name = 'Test expertise';
        areaOfExpertise3.Display_On_Web__c = TRUE;
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
    	//sCometency_2.Area_Of_Expertise_Name__c ='Play and Learning for the Preschool Child (EDUC 6684)';
        sCometency_2.Student_Expertise__c = studentExpertise2.id;
        Student_Competency__c sCometency_4 = TestDataGenerator.createStudentCompetency(sProg.id,newCompetency3.id,'Walden', false);
        sCometency_4.Student_Expertise__c = studentExpertise3.id;
        studentCompentencies.add(sCometency_1);
        studentCompentencies.add(sCometency_2);
        studentCompentencies.add(sCometency_4);
        insert studentCompentencies;  

        //create program course
        list<Program_Courses__c> programCourse = new list<Program_Courses__c>();
        Program_Courses__c pc1 = TestDataGenerator.createProgramCourse(sProg.Program__c,testCourse.id, false);
        Program_Courses__c pc2 = TestDataGenerator.createProgramCourse(sProg.Program__c,testCourse1.id, false);
        Program_Courses__c pc3 = TestDataGenerator.createProgramCourse(sProg.Program__c,testCourse2.id, false);
        programCourse.add(pc1);
        programCourse.add(pc2);
        programCourse.add(pc3);
        insert programCourse;

        //Student_Program__c studentProgram = TestDataGenerator.createStudentProgram(opp,testCon.ID, null, true);
        test.startTest();
        PageReference pageRef = Page.EditBuildUndergrad;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',sProg.Id);
        Id cmp_id = 'a0L0S000000bpwZUAQ';
        
        system.debug('student program id is' + sProg.Id);
        system.debug('Calling the controller');
        ApexPages.StandardController sc = new ApexPages.StandardController(sprog);
        
        EditBuildUndergradController EditBuildController = new EditBuildUndergradController(sc);
        Double D1 = 4.5;
        //public compCardDetails(Id, String , Double, String , String , String , String , String SyllabusLink, String Status, String AreaOfExpertise, String areaOfExpertiseDescription) {
        EditBuildController.compCardDetails innerController = new EditBuildController.compCardDetails(sCometency_1.Id,'C0001',D1,'EDUC 6160','SME','DESC','Difficult','Link','Fulfilled','AOE','areaOfExpertiseDesc');
        EditBuildController.selectedComps.add('C0001');
        EditBuildController.selectedComps.add('P0001');
        //EditBuildController.AreaOfExpertiseWithCompetencies aoeController = new EditBuildController.AreaOfExpertiseWithCompetencies();
		//EditBuildController.getLeftCompCards(studentCompentencies);
    	Student_Competency__c areaOfExpt= [Select id,Area_Of_Expertise_Name__c From Student_Competency__c  Where Id IN:studentCompentencies limit 1];
        ApexPages.currentPage().getParameters().put('compID',areaOfExpt.Area_Of_Expertise_Name__c);
        EditBuildController.addCompetencies();
        ApexPages.currentPage().getParameters().put('removedCompID',areaOfExpt.Area_Of_Expertise_Name__c);
        EditBuildController.removeCompetencies();
        EditBuildController.saveCompetencies();
        EditBuildController.firstclick = true;
    
        EditBuildController.addCompetencies();
        EditBuildController.secondclick = true;
        EditBuildController.addCompetencies();
        EditBuildController.thirdclick = true;
        EditBuildController.addCompetencies();
        EditBuildController.updateAgreedToCreditsDate();
        EditBuildController.degreeLevel = 'Graduate';
        EditBuildController.degreeLevelCheck();
        
         System.runAs(usr){
        PageReference pageRef1 = Page.EditBuildUndergrad;
        Test.setCurrentPage(pageRef1);
        ApexPages.currentPage().getParameters().put('id', sProg.Id);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(sprog);
        EditBuildUndergradController EditBuildCont = new EditBuildUndergradController(sc1);
        
        EditBuildUndergradController.compCardDetails cmpdObj = new EditBuildUndergradController.compCardDetails(sProg.Id,'test',2,'test','test','test','test','test','test','test','test',2);
          }
        test.stopTest(); 
         
    }
}