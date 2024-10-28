/*******************************************************************
Name  : TestCourseEquivalencyController
Author: Virendra (Appirio)
Date  : October 9, 2014
Description: Test Class for CourseEquivalencyController
*************************************************************************/
@isTest
private class CourseEquivalencyController_Test {
    
    static testMethod void testViewStudentCompetencies() {
        // Create Test Data
        Course__c testCourse = TestDataGenerator.createNewCourse('EDU-Test', true);
        list<Competency__c> competencies = new list<Competency__c> ();
        Competency__c  newCompetency1 = TestDataGenerator.createCompetency('Comp1',false);
        Competency__c  newCompetency2 = TestDataGenerator.createCompetency('Comp2',false);
        Competency__c  newCompetency3 = TestDataGenerator.createCompetency('Comp3',false);
        
        competencies.add(newCompetency1);
        competencies.add(newCompetency2);
        competencies.add(newCompetency3);
        insert competencies;
        
        list<Course_Competency__c> courseCompetencies = new list<Course_Competency__c>();
        Course_Competency__c crsCompetency1 = TestDataGenerator.createNewCourseCompetency(testCourse.id, newCompetency1.id, false);
        Course_Competency__c crsCompetency2 = TestDataGenerator.createNewCourseCompetency(testCourse.id, newCompetency1.id, false);
        Course_Competency__c crsCompetency3 = TestDataGenerator.createNewCourseCompetency(testCourse.id, newCompetency2.id, false);
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
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', true);
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = product2.Id;
        insert opp;
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', true);
   
         // create strudent competency
        list<Student_Competency__c> studentCompentencies = new  list<Student_Competency__c>();
        Student_Competency__c sCometency1 = TestDataGenerator.createStudentCompetency(sProg.Id,newCompetency1.id,'Walden', false);
        Student_Competency__c sCometency2 = TestDataGenerator.createStudentCompetency(sProg.Id,newCompetency1.id,'Walden', false);
        Student_Competency__c sCometency3 = TestDataGenerator.createStudentCompetency(sProg.Id,newCompetency1.id,'Walden', false);
        Student_Competency__c sCometency4 = TestDataGenerator.createStudentCompetency(sProg.Id,newCompetency3.id,'Walden', false);

        studentCompentencies.add(sCometency1);
        studentCompentencies.add(sCometency2);
        studentCompentencies.add(sCometency3);
        studentCompentencies.add(sCometency4);
        insert studentCompentencies;
        
    
        test.startTest();
          
           PageReference pageRef = Page.Course_Equivalency;
           Test.setCurrentPage(pageRef);
           ApexPages.currentPage().getParameters().put('id',sProg.Id);
           CourseEquivalencyController courseEqController  = new CourseEquivalencyController();
         
           courseEqController.courseCode = 'EDU-Test';
          
           courseEqController.getProgramCourseCompetencies();
           system.assertEquals(courseEqController.programCreditableCompetencies.size(), 2);
           
           courseEqController.getStudentCourseCompetencies();
           system.assertEquals(courseEqController.studentCreditableCompetencies.size(), 2);     
           
           courseEqController.transferInstitution = 'EDU- Tranfer ';
           courseEqController.updateStudentCompetenciesTransferForCredit();   
           courseEqController.getStudentCourseCompetencies();
           sCometency3.Status__c = 'Preliminary Transfer'; 
           update sCometency3;   
           courseEqController.updateStudentCompetenciesConvertPreliminaryTransfers();
           courseEqController.updateStudentCompetenciesPreliminaryTransferOfCredit();
           Opportunity opp1 = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', true);
           Student_Program__c sProg1 = TestDataGenerator.createStudentProgram(opp1, testCon.Id, 'Walden', true);
           
           ApexPages.currentPage().getParameters().put('id',sProg1.Id);
         
           courseEqController  = new CourseEquivalencyController();
           courseEqController.courseCode = 'Fake-Code';
          
           courseEqController.transferInstitution = 'EDU- Tranfer ';
           courseEqController.updateStudentCompetenciesTransferForCredit();  
           
           courseEqController  = new CourseEquivalencyController();
           
           courseEqController.courseCode = 'EDU-Test';
           courseEqController.transferInstitution = 'EDU- Tranfer ';
           courseEqController.updateStudentCompetenciesTransferForCredit();
           courseEqController.updateStudentCompetenciesFulfilled();
           courseEqController.cancel();
        test.stopTest();
         
    }

}