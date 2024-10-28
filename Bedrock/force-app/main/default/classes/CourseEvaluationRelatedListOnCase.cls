public with sharing class CourseEvaluationRelatedListOnCase {
    
  public ApexPages.StandardSetController sc {get; set;}
  public Integer currentIndex{get;set;} 
  public Case cs{get;set;}
  public Case caseNum{get;set;}

  public List<CourseEvaluationWrapper> courseWrapList{get;set;}
  public Boolean isClosed{get;set;}

  public CourseEvaluationRelatedListOnCase(ApexPages.StandardController sc) { 
    this.cs = (Case)sc.getRecord();
    caseNum = [Select CaseNumber, Status From Case Where id =: cs.Id];
    isClosed = false;
    if(caseNum.Status == 'Closed') {
        isClosed = true;
    }
    fetchRecords(cs);
  }

  private void fetchRecords(Case cs){
    courseWrapList = new List<CourseEvaluationWrapper>();
    for(Course_By_Course_Evaluation__c cbce : [SELECT Id, Name, Course_Subject__c, Date_Attended__c, U_S_Grades__c,                                                     U_S_Semester_Credits__c, Case__c, Case__r.CaseNumber
                                                    FROM Course_By_Course_Evaluation__c
                                                    WHERE Case__c = :cs.Id]){
        courseWrapList.add(new CourseEvaluationWrapper(cbce));
    }
  }

  public PageReference deleteRecord(){
    if(currentIndex != null){
        CourseEvaluationWrapper ceWrap = courseWrapList.get(currentIndex);    
        if(ceWrap.cbce.Id != null){
            delete ceWrap.cbce;
        }
      courseWrapList.remove(currentIndex);
    }
    currentIndex = null;
    return null;
  }

  public PageReference editRecord(){
    if(currentIndex != null){
      CourseEvaluationWrapper ceWrap = courseWrapList.get(currentIndex);    
      ceWrap.isEdit = true;
    }
    currentIndex = null;
    return null;
  }

  public PageReference addNew(){
    courseWrapList.add(new CourseEvaluationWrapper(cs.Id));
    return null;
  }  

  public PageReference cancel(){
    fetchRecords(cs);
    return null;
  }

  public PageReference save(){
    List<Course_By_Course_Evaluation__c> courseList = new List<Course_By_Course_Evaluation__c>();
    for(CourseEvaluationWrapper ceWrap : courseWrapList){
      courseList.add(ceWrap.cbce);
    }
    upsert courseList;
    fetchRecords(cs);
    return null;
  }  

  public class CourseEvaluationWrapper{
    public boolean isEdit {get; set;}
    public boolean isNew {get; set;}
    public Course_By_Course_Evaluation__c cbce {get; set;}

    public CourseEvaluationWrapper(Id caseId){
        isEdit = true;
        cbce = new Course_By_Course_Evaluation__c(Case__c = caseId);
    }

    public CourseEvaluationWrapper(Course_By_Course_Evaluation__c cbce){
        isEdit = false;
        this.cbce = cbce;
    }
  }
}