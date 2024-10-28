/**=====================================================================
 * Appirio, Inc
 * Name: CourseEvaluationRelatedListOnCase
 * Description: [94% of EditMyOrphansDocsExtensions]
 * Created Date: [09/23/2015]
 * Created By: [Himshikha Agrawal] (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * [MON DD, YYYY]               [FirstName LastName]         [Short description for changes]
 =====================================================================*/
@isTest
private class CourseEvaluationRelatedListOnCaseTest {
  
  private static testmethod void testCourseEvaluation(){
    
    //Case cs = TestUtility.createCase('test', false);
    Case cs = new Case();
    cs.Status = 'Requested';
 	cs.Type ='Change of Modality';
    cs.Case_Topic__c ='Course-Based to Tempo';
    insert cs;
    Course_By_Course_Evaluation__c ce = new Course_By_Course_Evaluation__c(Case__c=cs.Id);
    insert ce;
  
    ApexPages.StandardController sc = new ApexPages.StandardController(cs);
    CourseEvaluationRelatedListOnCase obj = new CourseEvaluationRelatedListOnCase(sc);
    
    obj.currentIndex = 0;
    obj.editRecord();
    system.assertEquals(obj.currentIndex, null);
    
    obj.save();
    obj.addNew();
    obj.cancel();
    
    obj.currentIndex = 0;
        obj.deleteRecord();
        system.assertEquals(obj.currentIndex, null);
    
  }
}