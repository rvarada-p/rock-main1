@istest

public class LearnerProfileController_test{

     static  Id tirRecordType;
    static Contact testCon;
    static Student_Program__c sProg;
 
  static void setup() {
       Product2 parentProgram = TestDataGenerator.createProduct('test', 'Walden', true);
       Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
       product2.Parent_Program__c = parentProgram.Id;
       insert product2;
       
        Program_Start_Date__c tstStartDate  = TestDataGenerator.createProgramStartDate(false);
        tstStartDate.Program__c = product2.Id;
        insert tstStartDate;

   
        Account acc = TestDataGenerator.createAccount(true);
        testCon = TestDataGenerator.createContact(acc,true);
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false);
        opty.Primary_Program__c = product2.Id;
        opty.Program_Start_Date__c = tstStartDate.Id;
      	opty.Contact__c = testCon.id;
        insert opty;
        sProg = TestDataGenerator.createStudentProgram(opty,testCon.ID, null, true);
        sProg.Program_Start_Date__c = tstStartDate.Id;
        sProg.Student_Enrollment_Status__c = 'Eligible to Register (EL)';
        sProg.Student_Enrollment_Status__c   = 'Eligible to Register (EL)';
        update sProg;
        opty.StageName = 'Student';
        update opty;
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);  
        Program_Expertise__c pExperise = TestDataGenerator.createProgramExpertise(aExper.ID,product2.ID,true,5.0,true);
        Competency__c testComp = TestDataGenerator.createCompetency(10, true);
        Program_Competency__c pCompetemcy = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0, true);
        Competency__c testComp2 = TestDataGenerator.createCompetency(10, true);
        Program_Competency__c pCompetemcy2 = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0, true);
        Student_Expertise__c sExpertise = TestDataGenerator.createCompetencyExpertise(aExper.Id,null, false);
        sExpertise.Contact__c = testCon.id;
        sExpertise.Program_Expertise__c = pExperise.ID;
        insert sExpertise;
        
        
         //create list of surveys
    
        list<SurveyMonkeyApp__Response__c> lstSMR = new list<SurveyMonkeyApp__Response__c>();
        SurveyMonkeyApp__Response__c sMonRespo = new SurveyMonkeyApp__Response__c();
        
        //record1
        sMonRespo.Student_Program_Id__c  = sProg.ID;
        sMonRespo.SurveyMonkeyApp__Page_ID__c = '59812231';
        sMonRespo.SurveyMonkeyApp__Collector_ID__c  = '163955830';
        sMonRespo.SurveyMonkeyApp__Survey_ID__c = '223745117';
        sMonRespo.SurveyMonkeyApp__Survey_Name__c = 'Learner Profile';
        sMonRespo.SurveyMonkeyApp__Collector_Name__c = 'Web Link 1';
        sMonRespo.SurveyMonkeyApp__Collector_ID__c = '223745117';
        sMonRespo.SurveyMonkeyApp__Question_ID__c = '200974613';
        sMonRespo.SurveyMonkeyApp__Response_Text__c = 'None';
        
        insert sMonRespo;
        
        
        
        
  

        tirRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Walden').getRecordTypeId();     
  }
  
   static testMethod void LearnerProfileController(){
   setup();

     list<Student_Program__c> lstSP = new list<Student_Program__c>();
     Student_Program__c sStudProg = new Student_Program__c();
     
     LearnerProfileController lp = new LearnerProfileController (new ApexPages.StandardController(new Student_Program__c()));

     //getsurveyList5(sProg.ID);
     test.startTest();
     PageReference pageRef = Page.LearnerProfile;
     Test.setCurrentPage(pageRef);
     lp.currentspid = sProg.ID;
     lp.cancel();
     lp.getsurveyList5(lp.currentspid);
     
     test.stopTest();
     
    
   
   
   
   }
  
}