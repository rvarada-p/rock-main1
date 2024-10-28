/******************************************************************************** 
 Apex Class Name     : DegreeAuditController_Test
 Created Date        : 17th June 2018
 Function            : test class for DegreeAuditcontroller
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ravitej Varada            06/17/2018                Original Version
*************************************************************************************/
@isTest
public without sharing class DegreeAuditGRController_Test {

    public static student_program__c sProg;
    public static Student_Subscription__c ss;
    public static Contact testCon;

    static testMethod void setup() {
        
        Account acc = TestDataGenerator.createAccount(true);
         testCon = TestDataGenerator.createContact(acc, true);
        
        
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
       
        Program_Category_Requirement__c  progCatReq1 = new Program_Category_Requirement__c();
        progCatReq1.Category__c =   'General Education';
        progCatReq1.Program__c  = product2.id;
        progCatReq1.Level__c    = 'Any';
        progCatReq1.Total_CE__c = 45.00;
        insert progCatReq1;
        Program_Category_Requirement__c  progCatReq2 = new Program_Category_Requirement__c();
        progCatReq2.Category__c =   'Core';
        progCatReq2.Level__c    = 'Upper';
        progCatReq2.Total_CE__c = 45.00;
        progCatReq2.Program__c  = product2.id;
        insert progCatReq2;
        Program_Category_Requirement__c  progCatReq3 = new Program_Category_Requirement__c();
        progCatReq3.Category__c =   'Core';
        progCatReq3.Level__c    = 'Lower';
        progCatReq3.Total_CE__c = 45.00;
        progCatReq3.Program__c  = product2.id;
        insert progCatReq3;
        Program_Category_Requirement__c  progCatReq4 = new Program_Category_Requirement__c();
        progCatReq4.Category__c =   'General Elective';
        progCatReq4.Level__c    = 'Any';
        progCatReq4.Total_CE__c = 45.00;
        progCatReq4.Program__c  = product2.id;
        insert progCatReq4;
        Program_Category_Requirement__c  progCatReq5 = new Program_Category_Requirement__c();
        progCatReq5.Category__c =   'Concentration';
        progCatReq5.Level__c    = 'Any';
        progCatReq5.Total_CE__c = 45.00;
        progCatReq5.Program__c  = product2.id;
        insert progCatReq5;
        
        //Core Upper 
        Area_of_Expertise__c aExper1 = TestDataGenerator.createAreaOfExpertise(false);
        aExper1.Level__c = '3000';
        aExper1.Category__c = 'Core';
        insert aExper1;       
        //Core Lower 
        Area_of_Expertise__c aExper2 = TestDataGenerator.createAreaOfExpertise(false);
        aExper2.Level__c = '1000';
        aExper2.Category__c = 'Core';
        insert aExper2;       
        //Concentration Upper 
        Area_of_Expertise__c aExper3 = TestDataGenerator.createAreaOfExpertise(false);
        aExper3.Level__c = '1000';
        aExper3.Category__c = 'Concentration';
        insert aExper3;       
        //Generel Education  
        Area_of_Expertise__c aExper4 = TestDataGenerator.createAreaOfExpertise(false);
        aExper4.Level__c = '1000';
        aExper4.Category__c = 'General Education';
        insert aExper4;       
        //Generel Elective 
        Area_of_Expertise__c aExper5 = TestDataGenerator.createAreaOfExpertise(false);
        aExper5.Level__c = '1000';
        aExper5.Category__c = 'General Elective';
        insert aExper5;       
        //Back 
        Area_of_Expertise__c aExper6 = TestDataGenerator.createAreaOfExpertise(false);
        aExper6.Level__c = '1000';
        insert aExper6; 
        //Pseudo_Course__c  
        Area_of_Expertise__c aExper7 = TestDataGenerator.createAreaOfExpertise(false);
        aExper7.Level__c = '1000';
        aExper7.Category__c = 'General Elective';
        aExper7.Pseudo_Course__c = true ;
        insert aExper7; 
        //General Education; General Elective'  
        Area_of_Expertise__c aExper8 = TestDataGenerator.createAreaOfExpertise(false);
        aExper8.Level__c = '3000';
        aExper8.Category__c = 'General Education; General Elective';
        insert aExper8; 
        
        Competency__c comp = TestDataGenerator.createCompetency('NUR1234', false);
        comp.Credit_Equivalency__c = 5.00;
        insert comp;
        
        Competency_Expertise__c compExp1 = TestDataGenerator.createCompetencyExpertise(aExper1.Id, comp.id, null, true);
        Competency_Expertise__c compExp2 = TestDataGenerator.createCompetencyExpertise(aExper2.Id, comp.id, null, true);
        Competency_Expertise__c compExp3 = TestDataGenerator.createCompetencyExpertise(aExper3.Id, comp.id, null, true);
        Competency_Expertise__c compExp4 = TestDataGenerator.createCompetencyExpertise(aExper4.Id, comp.id, null, true);
        Competency_Expertise__c compExp5 = TestDataGenerator.createCompetencyExpertise(aExper5.Id, comp.id, null, true);
        Competency_Expertise__c compExp6 = TestDataGenerator.createCompetencyExpertise(aExper6.Id, comp.id, null, true);
        Competency_Expertise__c compExp7 = TestDataGenerator.createCompetencyExpertise(aExper7.Id, comp.id, null, true);
        
        opportunity testOpty1 = TestDataGenerator.createOpportunity(acc.id, testCon.id, 'Walden', false);
        insert testOpty1;             
        
        sProg = TestDataGenerator.createStudentProgram(testOpty1, testCon.id, 'Walden', false);
        sProg.Program__c = product2.id;
        insert sProg;  
        
        ss = new Student_Subscription__c(Student_Program__c = sProg.Id,Start_Date__c=system.today());
        insert ss; 
        
        sProg.Current_Student_Subscription__c= ss.Id;
        update sProg;
        
        //Core Upper 
        Student_Expertise__c stuExp1 = TestDataGenerator.createCompetencyExpertise(aExper1.Id, 'Walden', false);
        stuExp1.Outcome_Category__c =   null;
        stuExp1.Student_Program__c =  sProg.id;
        insert stuExp1;
        //Core Lower 
        Student_Expertise__c stuExp2 = TestDataGenerator.createCompetencyExpertise(aExper2.Id, 'Walden', false);
        stuExp2.Outcome_Category__c =   null;
        stuExp2.Student_Program__c =  sProg.id;
        insert stuExp2;
        //Concentration 
        Student_Expertise__c stuExp3 = TestDataGenerator.createCompetencyExpertise(aExper3.Id, 'Walden', false);
        stuExp3.Outcome_Category__c =   null;
        stuExp3.Student_Program__c =  sProg.id;
        insert stuExp3;
        //General Education 
        Student_Expertise__c stuExp4 = TestDataGenerator.createCompetencyExpertise(aExper4.Id, 'Walden', false);
        stuExp4.Outcome_Category__c =   'General Education';
        stuExp4.Student_Program__c =  sProg.id;
        insert stuExp4;
        //General Elective 
        Student_Expertise__c stuExp5 = TestDataGenerator.createCompetencyExpertise(aExper5.Id, 'Walden', false);
        stuExp5.Outcome_Category__c =   'General Elective';
        stuExp5.Student_Program__c =  sProg.id;
        insert stuExp5;
        //Back 
        Student_Expertise__c stuExp6 = TestDataGenerator.createCompetencyExpertise(aExper6.Id, 'Walden', false);
        stuExp6.Outcome_Category__c =   'Back';
        stuExp6.Student_Program__c =  sProg.id;
        insert stuExp6;
        //Pseudo
        Student_Expertise__c stuExp7 = TestDataGenerator.createCompetencyExpertise(aExper7.Id, 'Walden', false);
        stuExp7.Outcome_Category__c =   'General Elective';
        stuExp7.Student_Program__c =  sProg.id;
        stuExp7.Pseudo_CE__c = 20;
        insert stuExp7;
        Student_Expertise__c stuExp8 = TestDataGenerator.createCompetencyExpertise(aExper5.Id, 'Walden', false);
        stuExp8.Outcome_Category__c =   null;
        stuExp8.Student_Program__c =  sProg.id;
        stuExp8.Pseudo_CE__c = 20;
        insert stuExp8;
        Student_Expertise__c stuExp9 = TestDataGenerator.createCompetencyExpertise(aExper8.Id, 'Walden', false);
        stuExp9.Outcome_Category__c =   'General Education; General Elective';
        stuExp9.Student_Program__c =  sProg.id;
        insert stuExp9;
        
        Brand_Configuration__c bc =new Brand_Configuration__c();
        insert bc;
        Community_Site_Settings__c cs = new Community_Site_Settings__c(Name='Default Settings',
        Intercom_Secret_Key__c ='GqgZglOaLiyFgsp6OirOoqzloHGITNr20jkhXrNw',
        RecordID__c = bc.Id);
        insert cs;
        
    }
  
    
    static testMethod void testDegreeAudit_one() {
        setup();
        Test.StartTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(sProg);
        DegreeAuditGRController testAccPlan = new DegreeAuditGRController(sc);
        
        PageReference pageRef = Page.DegreeAuditGR;
        pageRef.getParameters().put('id',sProg.Id);
        Test.setCurrentPage(pageRef); 
        Test.StopTest();
    }
    
    static testMethod void testDegreeAudit_two() {
    
        setup();    
        Student_Audit_History__c stuAudHis = new Student_Audit_History__c();
        stuAudHis.Earned_Back__c = 90;
        stuAudHis.Earned_CE_Concentration__c = 55;
        stuAudHis.Earned_CE_Core__c = 50;
        stuAudHis.Earned_CE_Core_Upper__c= 50;
        stuAudHis.Earned_CE_General_Education__c= 50;
        stuAudHis.Earned_CE_General_Electives__c= 50;
        stuAudHis.Total_CE_Concentration__c= 50;
                    
        stuAudHis.Total_CE_Core__c= 50;
        stuAudHis.Total_CE_Core_Upper__c= 50;
        stuAudHis.Total_CE_General_Education__c= 50;
        stuAudHis.Total_CE_General_Electives__c= 50;
        stuAudHis.Student_Program__c = sProg.id;
        insert stuAudHis;
        
        System.assertNotEquals(stuAudHis, Null);
        
     
        Apexpages.StandardController stdController = new Apexpages.StandardController(sProg); 
        DegreeAuditGRController DgrAuditContrler = new DegreeAuditGRController(stdController);

        
        Test.StartTest();
        PageReference pageRef = Page.DegreeAuditGR;
        pageRef.getParameters().put('id',sProg.Id);
        Test.setCurrentPage(pageRef); 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(sProg);
        DegreeAuditGRController testAccPlan = new DegreeAuditGRController(sc);
        
        
        testAccPlan.studentProgram = sProg;
        testAccPlan.updateAgreedToCreditsDate();
        testAccPlan.displayModalWindow();
        testAccPlan.updateWelcomeMessage();
        ss.Date_Student_Agreed_To_Credits__c = system.today();
        update ss;
        sProg.Current_Student_Subscription__c =ss.Id;
        update sProg;
        testAccPlan.studentProgram = sProg;
        testAccPlan.displayModalWindow();
        testAccPlan.degreeLevel = 'xxx';
        testAccPlan.currentUserId = 'xxx';
        testAccPlan.contactId  = 'xxx'; 
        testAccPlan.waldenEmailHash= 'xxx'; 
        testAccPlan.waldenEmail= 'xxx';    
        
           
        opportunity testOpty1 = TestDataGenerator.createOpportunity(testCon.accountId, testCon.id, 'Walden', false);
        insert testOpty1; 
        
        Profile pfl = [Select id from Profile where name='Tempo Community Users'];
        User uObj = new User(Alias = 'standtn', Email='Communityuser1@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = pfl.Id, 
                             TimeZoneSidKey='America/Los_Angeles', UserName='Communityuser@testorg.com',ContactId=testCon.Id);
        insert uObj;
        Brand_Configuration__c bc =new Brand_Configuration__c();
        insert bc;
        Community_Site_Settings__c cs = new Community_Site_Settings__c(Name='Default Settings',
                                                                       Intercom_Secret_Key__c ='GsqgZglOaLiyFgsp6OirOoqzloHGITNr20jkhXrNw',
                                                                       RecordID__c = bc.Id);
        insert cs;
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(sProg);
        DegreeAuditGRController testAccPlan1 = new DegreeAuditGRController(sc1 );
        
        
        Student_Program__c sProg = new Student_Program__c();
        sProg.Student__c = testCon.Id;
        sProg.IsStudentProgramActive__c = true;
        insert sProg; 
        PageReference pageRef2 = Page.DegreeAuditGR;
        pageRef2.getParameters().put('id',sProg.Id);
        Test.setCurrentPage(pageRef); 
        Test.StopTest();
        
        
    }
    
    
}