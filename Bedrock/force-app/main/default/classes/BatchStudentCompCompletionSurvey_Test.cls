@istest
public class BatchStudentCompCompletionSurvey_Test {
         private static List<Contact> students;

    static testMethod void testMethod1(){
       
       Account acc = TestDataGenerator.createAccount(true);
       students = TestDataGenerator.createContacts(acc, 1, null, true);
       List<Competency__c> competencies = new List<Competency__c>();
        for(Integer i = 0; i<1; i++){
            competencies.add(TestDataGenerator.createCompetency(false));   
        }
        insert competencies;
        
        List<Student_Competency__c> studComp = new List<Student_Competency__c>();
                studComp.add(TestDataGenerator.createStudentCompetency(competencies[0].id,'Walden',false));
                studComp.add(TestDataGenerator.createStudentCompetency(competencies[0].id,'Walden',false));
                studComp.add(TestDataGenerator.createStudentCompetency(competencies[0].id,'Walden',false));
        insert studComp;
		studComp[0].Survey_Message_Sent__c = False;
		studComp[1].Survey_Message_Sent__c = False;
		studComp[2].Survey_Message_Sent__c = False;
        studComp[0].Status__c = 'Achieved';
        studComp[1].Status__c = 'Achieved';
        studComp[2].Status__c = 'Achieved';
        studComp[0].Contact__c  = students[0].id;
		studComp[1].Contact__c  = students[0].id;
		studComp[2].Contact__c  = students[0].id;
        studComp[0].End_of_Survey_Link__c = 'Achieved';
        studComp[1].End_of_Survey_Link__c = 'Achieved';
        studComp[2].End_of_Survey_Link__c = 'Achieved';

		update studComp;
        Community_Site_Settings__c defaultCustomSetngs = new Community_Site_Settings__c();
        defaultCustomSetngs.Name = 'Default Settings';
        defaultCustomSetngs.IntercomEndPointUrl__c = 'http://intercom.io';
        defaultCustomSetngs.Intercom_Access_Token__c = '12345678901234567890';
        insert defaultCustomSetngs;

      
        Test.StartTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse_IntercomApi());
        BatchStudentCompetencyCompletionSurvey bc = new BatchStudentCompetencyCompletionSurvey();
        Database.executeBatch(bc);
        
     	BatchStudentCompetencyCompletionSurvey objB = new BatchStudentCompetencyCompletionSurvey();    
        String sch = '0 0 2 * * ?'; 
        system.schedule('BatchStudentCompetencyCompletionSurvey', sch, objB); 

        Test.StopTest();   
        
    }
    //test method to handle Status code other than 200 
    static testMethod void testMethod2(){
       
       Account acc = TestDataGenerator.createAccount(true);
       students = TestDataGenerator.createContacts(acc, 1, null, true);
       List<Competency__c> competencies = new List<Competency__c>();
        for(Integer i = 0; i<1; i++){
            competencies.add(TestDataGenerator.createCompetency(false));   
        }
        insert competencies;
        
        List<Student_Competency__c> studComp = new List<Student_Competency__c>();
                studComp.add(TestDataGenerator.createStudentCompetency(competencies[0].id,'Walden',false));
                studComp.add(TestDataGenerator.createStudentCompetency(competencies[0].id,'Walden',false));
                studComp.add(TestDataGenerator.createStudentCompetency(competencies[0].id,'Walden',false));
        insert studComp;
		studComp[0].Survey_Message_Sent__c = False;
		studComp[1].Survey_Message_Sent__c = False;
		studComp[2].Survey_Message_Sent__c = False;
        studComp[0].Status__c = 'Achieved';
        studComp[1].Status__c = 'Mastered';
        studComp[2].Status__c = 'Achieved';
        studComp[0].Contact__c  = students[0].id;
		studComp[1].Contact__c  = students[0].id;
		studComp[2].Contact__c  = students[0].id;

		update studComp;
        Community_Site_Settings__c defaultCustomSetngs = new Community_Site_Settings__c();
        defaultCustomSetngs.Name = 'Default Settings';
        defaultCustomSetngs.IntercomEndPointUrl__c = 'http://intercom.io';
        defaultCustomSetngs.Intercom_Access_Token__c = 'U8BjsjJnasonsauho32873ashj783HHBS';
        insert defaultCustomSetngs;
		
        System.assertNotEquals(defaultCustomSetngs,Null);
      
        Test.StartTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse_IntercomApiNegative());
        BatchStudentCompetencyCompletionSurvey bc = new BatchStudentCompetencyCompletionSurvey();
        Database.executeBatch(bc);
        Test.StopTest();   

    }

    //test method to handle Status code other than 200 
  static testMethod void testMethod3(){
       
       Account acc = TestDataGenerator.createAccount(true);
       students = TestDataGenerator.createContacts(acc, 1, null, true);
       List<Competency__c> competencies = new List<Competency__c>();
        for(Integer i = 0; i<1; i++){
            competencies.add(TestDataGenerator.createCompetency(false));   
        }
        insert competencies;
        
        List<Student_Competency__c> studComp = new List<Student_Competency__c>();
                studComp.add(TestDataGenerator.createStudentCompetency(competencies[0].id,'Walden',false));
                studComp.add(TestDataGenerator.createStudentCompetency(competencies[0].id,'Walden',false));
                studComp.add(TestDataGenerator.createStudentCompetency(competencies[0].id,'Walden',false));
        insert studComp;
		studComp[0].Survey_Message_Sent__c = False;
		studComp[1].Survey_Message_Sent__c = False;
		studComp[2].Survey_Message_Sent__c = False;
        studComp[0].Status__c = 'Achieved';
        studComp[1].Status__c = 'Achieved';
        studComp[2].Status__c = 'Achieved';
        studComp[0].Contact__c  = students[0].id;
		studComp[1].Contact__c  = students[0].id;
		studComp[2].Contact__c  = students[0].id;
        studComp[0].End_of_Survey_Link__c = 'Achieved';
        studComp[1].End_of_Survey_Link__c = 'Achieved';
        studComp[2].End_of_Survey_Link__c = 'Achieved';

		update studComp;
        Community_Site_Settings__c defaultCustomSetngs = new Community_Site_Settings__c();
        defaultCustomSetngs.Name = 'Default Settings';
        defaultCustomSetngs.IntercomEndPointUrl__c = 'http://intercom.io';
        defaultCustomSetngs.Intercom_Access_Token__c = '12345678901234567890';
        insert defaultCustomSetngs;

      
        Test.StartTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse_IntercomApiNegative());
        BatchStudentCompetencyCompletionSurvey bc = new BatchStudentCompetencyCompletionSurvey();
        Database.executeBatch(bc);
        
     	BatchStudentCompetencyCompletionSurvey objB = new BatchStudentCompetencyCompletionSurvey();    
        String sch = '0 0 2 * * ?'; 
        system.schedule('BatchStudentCompetencyCompletionSurvey', sch, objB); 

        Test.StopTest();   
        
    }
}