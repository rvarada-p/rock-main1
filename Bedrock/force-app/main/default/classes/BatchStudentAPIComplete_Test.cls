@istest
public class BatchStudentAPIComplete_Test {

         private static List<Contact> students;
    private static D2L__c D2L;

    private static Student_Competency__c sCometency;
    private static User smeUser;
    private static Sections__c section;     public static void setup() {
         
        //Insert the custom settings for D2L
        D2L__c  D2L = new D2L__c ();
        D2L.Name = 'D2L';
        D2L.LP_Version__c = 1.0;
        D2L.Update_User__c = '/d2l/api/lp/(version)/users/(userId)';
        D2L.Unenrolled_Student_Role_ID__c = 444;
        D2L.Create_Enrollment_Endpoint__c = '/d2l/api/lp/(version)/enrollments/';
        insert D2L;      
    }

    
    static testMethod void testMethod1(){
       setup();
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

        update studComp;
      

        Decimal smeRoleId = D2L__c.getValues('D2L').SME_Role_ID__c;
        smeUser = [SELECT Id FROM User WHERE Profile.Name = 'CBL SME Chatter Only' LIMIT 1];
        section = new Sections__c();
        section.SME__c = smeUser.id;
        section.Competency__c = competencies[0].id;
        section.LMS_Section_ID__c = 4343;
        insert section;  
        
        Student_Sections__c stuSec = new Student_Sections__c ();
        stuSec.Section__c = section.id;       
        stuSec.Student_Competency__c = studComp[0].id;
        stuSec.Unenroll_from_LMS__c = true;
        stuSec.Unenrolled_from_LMS__c = false;
        insert stuSec ; 
        
        //JsonWrapper jsonGenerator = new JsonWrapper();
        //String json = jsonGenerator.createEnrollmentData(4343.0, 433, smeRoleId);
      
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_IntercomApi());
        BatchStudentCompleteAPI bc = new BatchStudentCompleteAPI();
        Database.executeBatch(bc);
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

       String CRON_EXP = '0 0 0 15 3 ? *';
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_IntercomApiNegative());
        BatchStudentCompleteAPI bc = new BatchStudentCompleteAPI();
        Database.executeBatch(bc);
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new BatchStudentCompleteAPI());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
        Test.StopTest();   
        
    }


}