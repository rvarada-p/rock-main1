/*******************************************************************
Name  : CreateCourseCompetencyExtensions_Test
Author: Virendra (Appirio)
Date  : October 10, 2014
Description: Test Class for TestCreateCourseCompetencyExtensions
*************************************************************************/
@isTest
private class CreateCourseCompetencyExtensions_Test {
    
    static testMethod void testCourseDetais() {
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
        
        Course_Competency__c crsCompetency1 = TestDataGenerator.createNewCourseCompetency(testCourse.id, newCompetency1.id, true);
     
      
        
          test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(crsCompetency1);
            PageReference pageRef = Page.CreateCourseCompetency;
            pageRef.getParameters().put('CourseID', String.valueOf(testCourse.Id));
            Test.setCurrentPage(pageRef);
         
            CreateCourseCompetencyExtensions cExtensions  = new CreateCourseCompetencyExtensions(sc);
            cExtensions.selectedCompetencyID = newCompetency1.id+','+newCompetency2.id;
         
            
            cExtensions.save();
            
            list<Course_Competency__c> courseCompetencies = [Select id from Course_Competency__c where Course__c =:testCourse.Id];
            system.assertEquals(courseCompetencies.size(), 3);
            
            
        
            cExtensions  = new CreateCourseCompetencyExtensions(sc);
            try{   
                cExtensions.save();
            }catch(Exception ex){
                String errMsg = ex.getMessage(); 
                system.assertEquals(errMsg.contains('Select at least one cometency'), true);
            }
            
          test.stopTest(); 
    }

}