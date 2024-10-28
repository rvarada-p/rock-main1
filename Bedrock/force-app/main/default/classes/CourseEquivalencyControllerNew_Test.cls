/************************************************************************
Name  : CourseEquivalencyControllerNew_Test
Developer: Sushant Chaudhari, July 2017
Description: Apex test class for the CourseEquivalencyControllerNew Apex class
*************************************************************************/

@isTest
private class CourseEquivalencyControllerNew_Test {
    private static Competency__c  newCompetency1;
    private static Competency__c  newCompetency2;
    private static Competency__c  newCompetency3;
    private static Contact testCon;
    private static Course__c testCourse;
    private static Course__c testCourse1;
    private static Course__c testCourse2;
    private static Opportunity opp;

    static void setupTestData() {
     // Create Test Data
        testCourse = TestDataGenerator.createNewCourse('EDU-Test', true);
        testCourse1 = TestDataGenerator.createNewCourse('EDU-Test1', true);
        testCourse2 = TestDataGenerator.createNewCourse('EDU-Test2', true);
        list<Competency__c> competencies = new list<Competency__c> ();
        newCompetency1 = TestDataGenerator.createCompetency('Comp1',false);
        newCompetency2 = TestDataGenerator.createCompetency('Comp2',false);
        newCompetency3 = TestDataGenerator.createCompetency('Comp3',false);
        
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
        Program_Competency__c testPComo1 = TestDataGenerator.createProgramCompetency(newCompetency1.Id,product2.Id,true,4.0,false);
        Program_Competency__c testPComo2 = TestDataGenerator.createProgramCompetency(newCompetency1.Id,product2.Id,true,3.0,false);
        Program_Competency__c testPComo3 = TestDataGenerator.createProgramCompetency(newCompetency1.Id,product2.Id,true,2.0,false);
        Program_Competency__c testPComo4 = TestDataGenerator.createProgramCompetency(newCompetency3.Id,product2.Id,true,1.0,false);
        Program_Competency__c testPComo5 = TestDataGenerator.createProgramCompetency(newCompetency3.Id,product2.Id,true,5.0,false);
        
        progCompetencies.add(testPComo1);
        progCompetencies.add(testPComo2);
        progCompetencies.add(testPComo3);
        progCompetencies.add(testPComo4);
        progCompetencies.add(testPComo5);
        insert progCompetencies;
        
        Account acc = TestDataGenerator.createAccount(true);
        testCon = TestDataGenerator.createContact(acc, true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', true);
        opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = product2.Id;
        insert opp;        
    }

    static testMethod void testTOCWithOpportunity() {
         setupTestData();

         test.startTest();
          
         PageReference pageRef = Page.CourseEquivalency;
         Test.setCurrentPage(pageRef);

         ApexPages.currentPage().getParameters().put('id',opp.Id);
         system.debug('Opp id is' + opp.Id);
         
         ApexPages.StandardController sc = new ApexPages.StandardController(opp);
         
         CourseEquivalencyControllerNew courseEqController  = new CourseEquivalencyControllerNew(sc);

         courseEqController.getItems();
         
         courseEqController.SelectedCreditType = 'PRELIMINARY TRANSFER TO TRANSFER';
           
         courseEqController.getDetails();
         
         for(CourseEquivalencyControllerNew.studentCompDetails newobj1: courseEqController.studentCompCredit){
            newobj1.checked = true;
          }
         
         courseEqController.TransferStudent();
         
         courseEqController.SelectedCreditType = 'NONE';
           
         courseEqController.getDetails();
         
         courseEqController.SelectedCreditType = 'FULFILLED';
           
         courseEqController.getDetails();

    }

    static testMethod void testTOCWithSP() {

        setupTestData();

        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', true);
   
         // create strudent competency
        list<Student_Competency__c> studentCompentencies = new  list<Student_Competency__c>();
        
        Student_Competency__c sCometency1 = TestDataGenerator.createStudentCompetency(newCompetency1.id,'Walden', false);

        Student_Competency__c sCometency2 = TestDataGenerator.createStudentCompetency(newCompetency2.id,'Walden', false);
        Student_Competency__c sCometency4 = TestDataGenerator.createStudentCompetency(newCompetency3.id,'Walden', false);
        studentCompentencies.add(sCometency1);
        studentCompentencies.add(sCometency2);
        //studentCompentencies.add(sCometency3);
        studentCompentencies.add(sCometency4);
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
        
        Student_Program__c studentProgram = TestDataGenerator.createStudentProgram(opp,testCon.ID, null, true);
        
         test.startTest();
          
         PageReference pageRef = Page.CourseEquivalency;
         Test.setCurrentPage(pageRef);
         ApexPages.currentPage().getParameters().put('id',sProg.Id);
         system.debug('student program id is' + sProg.Id);
         
         ApexPages.StandardController sc = new ApexPages.StandardController(studentProgram);
         
         CourseEquivalencyControllerNew courseEqController  = new CourseEquivalencyControllerNew(sc);
         courseEqController.transferInstitution = 'MIT';

         courseEqController.getItems();
         
         courseEqController.SelectedCreditType = 'PRELIMINARY TRANSFER TO TRANSFER';
           
         courseEqController.getDetails();
         
         for(CourseEquivalencyControllerNew.studentCompDetails newobj1: courseEqController.studentCompCredit){
            newobj1.checked = true;
          }
         
         courseEqController.TransferStudent();
         
         courseEqController.SelectedCreditType = 'NONE';
           
         courseEqController.getDetails();
         
         courseEqController.SelectedCreditType = 'FULFILLED';
           
         courseEqController.getDetails();
                 
          for(CourseEquivalencyControllerNew.ProgramCourseDetails newobj: courseEqController.programCourses){
            newobj.selected = true;
            newobj.competencyName = 'test';
            newobj.courseId = testCourse.Id;
            //newobj.courseId = 'a0Ao0000005FZ2rEAG';
          }
        
         
         courseEqController.updateRecords();
         
         courseEqController.SelectedCreditType = 'Preliminary Transfer';
           
         courseEqController.getDetails();
         
         courseEqController.saveRecords();

         courseEqController.undoChanges();

         system.debug('>>>courseEqController.programCourses::' + courseEqController.programCourses);
         
         courseEqController.objType = '' ;
         
         CourseEquivalencyControllerNew courseEqController1  = new CourseEquivalencyControllerNew(sc);
         Double D1 = 4.5;
		 courseEqController1.setCreditTypeFlag();
         //CourseEquivalencyControllerNew.ProgramCourseDetails innerController = new CourseEquivalencyControllerNew.ProgramCourseDetails('Theories of Child Development','EDUC 6160','a0Ao0000005FZ2rEAG','Fulfilled','A',D1,'a0R0S0000007EczUAE');
         
         test.stopTest();
        
    }

   static testMethod void testTOCWithSPFlipToTransfer() {

        setupTestData();

        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', true);
   
         // create strudent competency
        list<Student_Competency__c> studentCompentencies = new  list<Student_Competency__c>();
        
        Student_Competency__c sCometency1 = TestDataGenerator.createStudentCompetency(newCompetency1.id,'Walden', false);
        sCometency1.Status__c = 'Preliminary Transfer';
        sCometency1.Student_Program__c = sProg.Id;
        Student_Competency__c sCometency2 = TestDataGenerator.createStudentCompetency(newCompetency2.id,'Walden', false);
        sCometency2.Status__c = 'Preliminary Transfer';
        sCometency2.Student_Program__c = sProg.Id;
        Student_Competency__c sCometency4 = TestDataGenerator.createStudentCompetency(newCompetency3.id,'Walden', false);
        sCometency4.Status__c = 'Preliminary Transfer';
        sCometency4.Student_Program__c = sProg.Id;
        studentCompentencies.add(sCometency1);
        studentCompentencies.add(sCometency2);
        studentCompentencies.add(sCometency4);
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
        
        Student_Program__c studentProgram = TestDataGenerator.createStudentProgram(opp,testCon.ID, null, true);
        
         test.startTest();
          
         PageReference pageRef = Page.CourseEquivalency;
         Test.setCurrentPage(pageRef);
         ApexPages.currentPage().getParameters().put('id',sProg.Id);
         system.debug('student program id is' + sProg.Id);
         
         ApexPages.StandardController sc = new ApexPages.StandardController(studentProgram);
         
         CourseEquivalencyControllerNew courseEqController  = new CourseEquivalencyControllerNew(sc);
         courseEqController.transferInstitution = 'MIT';
         courseEqController.getItems();
         
         courseEqController.SelectedCreditType = 'FLIP TO OFFICIAL TRANSFER';
           
         courseEqController.getDetails();
         
         for(CourseEquivalencyControllerNew.studentCompDetails newobj1: courseEqController.studentCompCredit){
            newobj1.checked = true;
          }
         
  
         
         courseEqController.TransferStudent();
         
         courseEqController.SelectedCreditType = 'NONE';
           
         courseEqController.getDetails();
         
         courseEqController.SelectedCreditType = 'FULFILLED';
           
         courseEqController.getDetails();
         
          //newobj.selected = true;
          
          for(CourseEquivalencyControllerNew.ProgramCourseDetails newobj: courseEqController.programCourses){
            newobj.selected = true;
            newobj.competencyName = 'test';
            newobj.courseId = testCourse.Id;
          }
         
           courseEqController.updateRecords();
         
         courseEqController.SelectedCreditType = 'Preliminary Transfer';
           
         courseEqController.getDetails();
         
         system.debug('>>>courseEqController.programCourses::' + courseEqController.programCourses);
         
         courseEqController.objType = '' ;
         
         CourseEquivalencyControllerNew courseEqController1  = new CourseEquivalencyControllerNew(sc);
         Double D1 = 4.5;
         courseEqController1.setCreditTypeFlag();
         //CourseEquivalencyControllerNew.ProgramCourseDetails innerController = new CourseEquivalencyControllerNew.ProgramCourseDetails('Theories of Child Development','EDUC 6160','a0Ao0000005FZ2rEAG','Fulfilled','A',D1,'a0R0S0000007EczUAE');
       
         test.stopTest();
        
    }    
}