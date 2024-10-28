public with sharing class LearnerProfileController {

public String currentspid; 
public list<Student_Program__c> surveyList1 {get;set;}
public list<Student_Program__c> surveyList2 {get;set;}
public list<Student_Program__c> surveyList3 {get;set;}
public list<Student_Program__c> surveyList4 {get;set;}
public list<Student_Program__c> surveyList5 {get;set;}



   public LearnerProfileController(ApexPages.StandardController controller) {
   
   currentspid = ApexPages.currentPage().getParameters().get('ID');
   
 
   
   getsurveyList1(currentspid);
   getsurveyList2(currentspid);
   getsurveyList3(currentspid);
   getsurveyList4(currentspid);
   getsurveyList5(currentspid);
   }
   
   public PageReference cancel() {
   
   currentspid = ApexPages.currentPage().getParameters().get('ID');
   
        PageReference newocp1 = new PageReference('/'+currentspid);
       return newocp1;
    }
   
   public void getsurveyList1(string spid){
   
   surveyList1 = [Select id, name, (select 
                                    id,name,Student_Program_Id__c,SurveyMonkeyApp__Choice_Name__c,SurveyMonkeyApp__Row_Name__c ,SurveyMonkeyApp__Response_Text__c, 
                                    SurveyMonkeyApp__Question_Name__c,SurveyMonkeyApp__Row_ID__c from SurveyMonkey_Responses__r 
                                    where SurveyMonkeyApp__Row_ID__c <= '1390694191' AND SurveyMonkeyApp__Row_ID__c >= '1368590056' ) 
                  from Student_Program__c where id =: spid];
                  
    }
    
    public void getsurveyList2(string spid){
    
    surveyList2 = [Select id, name, (select 
                                    id,name,Student_Program_Id__c,SurveyMonkeyApp__Choice_Name__c,SurveyMonkeyApp__Row_Name__c ,SurveyMonkeyApp__Response_Text__c, 
                                    SurveyMonkeyApp__Question_Name__c,SurveyMonkeyApp__Row_ID__c from SurveyMonkey_Responses__r 
                                    where SurveyMonkeyApp__Row_ID__c <= '1390704657' AND SurveyMonkeyApp__Row_ID__c >= '1390704655' ) 
                  from Student_Program__c where id =: spid];
   //system.debug(surveyList2[0]);
   }
   
   public void getsurveyList3(string spid){
   
    surveyList3 = [Select id, name, (select 
                                    id,name,Student_Program_Id__c,SurveyMonkeyApp__Choice_Name__c,SurveyMonkeyApp__Row_Name__c ,SurveyMonkeyApp__Response_Text__c, 
                                    SurveyMonkeyApp__Question_Name__c,SurveyMonkeyApp__Row_ID__c , SurveyMonkeyApp__Page_ID__c , SurveyMonkeyApp__Question_ID__c from SurveyMonkey_Responses__r 
                                    where (SurveyMonkeyApp__Question_ID__c >= '200963813' AND SurveyMonkeyApp__Question_ID__c <= '200970415') OR (SurveyMonkeyApp__Question_ID__c = '200973330') OR (
                                    SurveyMonkeyApp__Question_ID__c = '250084802')
                                    order by SurveyMonkeyApp__Page_ID__c ) 
                  from Student_Program__c where id =: spid];
   
   
   }
   
   
  

   public void getsurveyList4(string spid){
   
    surveyList4 = [Select id, name, (select 
                                    id,name,Student_Program_Id__c,SurveyMonkeyApp__Choice_Name__c,SurveyMonkeyApp__Row_Name__c ,SurveyMonkeyApp__Response_Text__c, 
                                    SurveyMonkeyApp__Question_Name__c,SurveyMonkeyApp__Row_ID__c , SurveyMonkeyApp__Page_ID__c , SurveyMonkeyApp__Question_ID__c, SurveyMonkeyApp__Other_Text__c 
                                    from SurveyMonkey_Responses__r 
                                    where (SurveyMonkeyApp__Question_ID__c = '200971877')
                                    order by Name) 
                  from Student_Program__c where id =: spid];
   
   }
   
   public void getsurveyList5(string spid){
   
    surveyList5 = [Select id, name, (select 
                                    id,name,Student_Program_Id__c,SurveyMonkeyApp__Choice_Name__c,SurveyMonkeyApp__Row_Name__c ,SurveyMonkeyApp__Response_Text__c, 
                                    SurveyMonkeyApp__Question_Name__c,SurveyMonkeyApp__Row_ID__c , SurveyMonkeyApp__Page_ID__c , SurveyMonkeyApp__Question_ID__c, SurveyMonkeyApp__Other_Text__c 
                                    from SurveyMonkey_Responses__r 
                                    where (SurveyMonkeyApp__Question_ID__c = '200974613') OR (SurveyMonkeyApp__Question_ID__c = '200974393') OR
                                    (SurveyMonkeyApp__Question_ID__c = '250085528')
                                    order by SurveyMonkeyApp__Question_ID__c) 
                  from Student_Program__c where id =: spid];
   
   }
  
  
  
 
   
}