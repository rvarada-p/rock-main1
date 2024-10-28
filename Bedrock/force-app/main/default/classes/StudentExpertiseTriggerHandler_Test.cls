/************************************************************************
Name  : StudentExpertiseTriggerHandler_Test
Author: Ravitej Varada, Laureate
Date  : May 16, 2018
Description: TEst class for StudentExpertiseTriggerHandler class 

Revision History 
Horacio Sanchez - 9/30/2020 - S-25237 Move Existing Pre-req functionality from AoE to PE
*************************************************************************/
@isTest
public class StudentExpertiseTriggerHandler_Test {
    public static student_program__c sProg;

        
    static testMethod void Test_One() {

     Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        product2.ProductCode='RNMSN';
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
        Competency__c comp = TestDataGenerator.createCompetency('NUR1234', false);
        comp.Credit_Equivalency__c = 5.00;
        insert comp;
        
        //Core Upper 
        Area_of_Expertise__c aExper1 = TestDataGenerator.createAreaOfExpertise(false);
        aExper1.Level__c = '3000';
        aExper1.Category__c = 'Core';
        insert aExper1;       
       
        
    
        Competency_Expertise__c compExp1 = TestDataGenerator.createCompetencyExpertise(aExper1.Id, comp.id, null, true);
        opportunity testOpty1 = TestDataGenerator.createOpportunity(acc.id, testCon.id, 'Walden', false);
        insert testOpty1;    
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper1.Id,product2.id,true,4.0, true);
        Program_Competency__c testPComo = TestDataGenerator.createProgramCompetency(comp.Id,product2.Id,pExper.Id,true,4.0, false);
        testPComo.FWK_Id__c = '123';
        testPComo.IsTryBeforeYouBuy__c = true;        
        insert testPComo;
        sProg = TestDataGenerator.createStudentProgram(testOpty1, testCon.id, 'Walden', false);
        sProg.Program__c = product2.id;
        insert sProg;  
        
        //Core Upper 
        Student_Expertise__c stuExp1 = TestDataGenerator.createCompetencyExpertise(aExper1.Id, 'Walden', false);
        stuExp1.Student_Program__c =  sProg.id;
        insert stuExp1;
                
        Student_Audit_History__c stuAudHis = new Student_Audit_History__c();
        stuAudHis.Earned_Back__c = 90;
        stuAudHis.Earned_CE_Concentration__c = 55;
        stuAudHis.Earned_CE_Core__c = 55;
        stuAudHis.Earned_CE_Core_Upper__c= 90;
        stuAudHis.Earned_CE_General_Education__c= 55;
        stuAudHis.Earned_CE_General_Electives__c= 55;
        
        stuAudHis.Total_CE_Concentration__c= 50;
        stuAudHis.Total_CE_Core__c= 50;
        stuAudHis.Total_CE_Core_Upper__c= 50;
        stuAudHis.Total_CE_General_Education__c= 50;
        stuAudHis.Total_CE_General_Electives__c= 50;
        stuAudHis.Student_Program__c = sProg.id;
        insert stuAudHis;
            test.startTest();
      
        stuExp1.IsAchieved__c = true;
        update stuExp1;
        
        Area_of_Expertise__c aExper2 = TestDataGenerator.createAreaOfExpertise(false);
        aExper2.Level__c = '1000';
        aExper2.Category__c = 'General Education';
         aExper2.Pseudo_Course__c = true;
        insert aExper2; 
        
        Student_Expertise__c stuExp2 = TestDataGenerator.createCompetencyExpertise(aExper2.Id, 'Walden', false);
        stuExp2.Student_Program__c =  sProg.id;
        insert stuExp2;
     
        
        //Concentration Upper 
        Area_of_Expertise__c aExper3 = TestDataGenerator.createAreaOfExpertise(false);
        aExper3.Level__c = '1000';
        aExper3.Category__c = 'Concentration';
        insert aExper3;       
       //Concentration 
        Student_Expertise__c stuExp3 = TestDataGenerator.createCompetencyExpertise(aExper3.Id, 'Walden', false);
        stuExp3.Student_Program__c =  sProg.id;
        insert stuExp3;
        
        // %%%%

        //Generel Education  
        Area_of_Expertise__c aExper4 = TestDataGenerator.createAreaOfExpertise(false);
        aExper4.Level__c = '1000';
        aExper4.Category__c = 'Core';       
        insert aExper4;       
        //Generel Elective 
        Area_of_Expertise__c aExper5 = TestDataGenerator.createAreaOfExpertise(false);
        aExper5.Level__c = '1000';
        aExper5.Category__c = 'General Elective';
        insert aExper5;       
       
        //General Education; General Elective   
        Area_of_Expertise__c aExper7 = TestDataGenerator.createAreaOfExpertise(false);
        aExper7.Level__c = '1000';
        aExper7.Category__c = 'General Education; General Elective';
        aExper7.Pseudo_Course__c = true ;
        insert aExper7; 
        
        
        //General Education 
        Student_Expertise__c stuExp4 = TestDataGenerator.createCompetencyExpertise(aExper4.Id, 'Walden', false);
        stuExp4.Student_Program__c =  sProg.id;
        insert stuExp4;
       
        
        //General Elective 
        Student_Expertise__c stuExp5 = TestDataGenerator.createCompetencyExpertise(aExper5.Id, 'Walden', false);
        stuExp5.Student_Program__c =  sProg.id;
        insert stuExp5;
        
        
        /*/Back 
        Student_Expertise__c stuExp6 = TestDataGenerator.createCompetencyExpertise(aExper6.Id, 'Walden', false);
        stuExp6.Outcome_Category__c =   'Back';
        stuExp6.Student_Program__c =  sProg.id;
        insert stuExp6;
        //Pseudo
        Student_Expertise__c stuExp7 = TestDataGenerator.createCompetencyExpertise(aExper7.Id, 'Walden', false);
        stuExp7.Outcome_Category__c =   'General Elective';
        stuExp7.Student_Program__c =  sProg.id;
        insert stuExp7;
        Student_Expertise__c stuExp8 = TestDataGenerator.createCompetencyExpertise(aExper5.Id, 'Walden', false);
        stuExp8.Outcome_Category__c =   null;
        stuExp8.Student_Program__c =  sProg.id;
        insert stuExp8;*/
        Student_Expertise__c stuExp6 = TestDataGenerator.createCompetencyExpertise(aExper7.Id, 'Walden', false);
        stuExp6.Student_Program__c =  sProg.id;
        insert stuExp6;
        
        stuExp2.IsAchieved__c = true;
        stuExp2.Pseudo_CE__c = 25;
        update stuExp2;
        
        stuExp3.IsAchieved__c = true;
        //update stuExp3;
            
        stuExp4.IsAchieved__c = true;
        update new List<Student_Expertise__c>{stuExp3,stuExp4};
            
        stuExp5.IsAchieved__c = true;
        update stuExp5;
            stuExp6.IsAchieved__c = true;
        update stuExp6;
     
        
        
        
//AFTER DELET AND AFTER UNDELETE TRIGGER 

        delete stuExp2;
        undelete stuExp2;
        
      
     
                test.stopTest();

        
    }
    
    
    
    static testMethod void Test_two() {

     Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        product2.ProductCode='RNMSN';
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
        Competency__c comp = TestDataGenerator.createCompetency('NUR1234', false);
        comp.Credit_Equivalency__c = 5.00;
        insert comp;
        
        //Core Upper 
        Area_of_Expertise__c aExper1 = TestDataGenerator.createAreaOfExpertise(false);
        aExper1.Level__c = '2000';
        aExper1.Category__c = 'General Education; General Elective';
        insert aExper1;       
       
        
    
        Competency_Expertise__c compExp1 = TestDataGenerator.createCompetencyExpertise(aExper1.Id, comp.id, null, true);
        opportunity testOpty1 = TestDataGenerator.createOpportunity(acc.id, testCon.id, 'Walden', false);
        insert testOpty1;    
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper1.Id,product2.id,true,4.0, true);
        Program_Competency__c testPComo = TestDataGenerator.createProgramCompetency(comp.Id,product2.Id,pExper.Id,true,4.0, false);
        testPComo.FWK_Id__c = '123';
        testPComo.IsTryBeforeYouBuy__c = true;        
        insert testPComo;
        sProg = TestDataGenerator.createStudentProgram(testOpty1, testCon.id, 'Walden', false);
        sProg.Program__c = product2.id;
        insert sProg;  
        
        //Core Upper 
        Student_Expertise__c stuExp1 = TestDataGenerator.createCompetencyExpertise(aExper1.Id, 'Walden', false);
        stuExp1.Student_Program__c =  sProg.id;
        stuExp1.Program_Expertise__c =  pExper.id;
        insert stuExp1;
                
        Pre_requisite_Rules__c preReqRulsObj = new Pre_requisite_Rules__c(Course_Name__c = aExper1.Id, 
                                                                          Area_of_Expertise__c = aExper1.Id,
                                                                          Student_Expertise__c = stuExp1.Id);
        insert preReqRulsObj;
            
      
        stuExp1.IsAchieved__c = true;
        stuExp1.Fulfilled_Course_from_a_Conferred_Degree__c = false;
        update stuExp1;

        aExper1.Level__c = '4000';
        aExper1.Category__c = 'Core';
        update aExper1;
         stuExp1.IsAchieved__c = false;
        update stuExp1;
         stuExp1.IsAchieved__c = true;
        update stuExp1;
        
        Area_of_Expertise__c aExper2 = TestDataGenerator.createAreaOfExpertise(false);
        aExper2.Level__c = '1000';
        aExper2.Category__c = 'General Education';
         aExper2.Pseudo_Course__c = true;
        insert aExper2; 
        
        Student_Expertise__c stuExp2 = TestDataGenerator.createCompetencyExpertise(aExper2.Id, 'Walden', false);
        stuExp2.Student_Program__c =  sProg.id;
        insert stuExp2;
     
         test.startTest();
        
        //Concentration Upper 
        Area_of_Expertise__c aExper3 = TestDataGenerator.createAreaOfExpertise(false);
        aExper3.Level__c = '1000';
        aExper3.Category__c = 'Concentration';
        insert aExper3;       
       //Concentration 
        Student_Expertise__c stuExp3 = TestDataGenerator.createCompetencyExpertise(aExper3.Id, 'Walden', false);
        stuExp3.Student_Program__c =  sProg.id;
        insert stuExp3;
        
        // %%%%

        //Generel Education  
        Area_of_Expertise__c aExper4 = TestDataGenerator.createAreaOfExpertise(false);
        aExper4.Level__c = '1000';
        aExper4.Category__c = 'Core';
        insert aExper4;       
        //Generel Elective 
        Area_of_Expertise__c aExper5 = TestDataGenerator.createAreaOfExpertise(false);
        aExper5.Level__c = '1000';
        aExper5.Category__c = 'General Elective';
        insert aExper5;       
       
        //General Education; General Elective   
        Area_of_Expertise__c aExper7 = TestDataGenerator.createAreaOfExpertise(false);
        aExper7.Level__c = '1000';
        aExper7.Category__c = 'General Education; General Elective';
        insert aExper7; 
        
        
        //General Education 
        Student_Expertise__c stuExp4 = TestDataGenerator.createCompetencyExpertise(aExper4.Id, 'Walden', false);
        stuExp4.Student_Program__c =  sProg.id;
        insert stuExp4;
       
        
        //General Elective 
        Student_Expertise__c stuExp5 = TestDataGenerator.createCompetencyExpertise(aExper5.Id, 'Walden', false);
        stuExp5.Student_Program__c =  sProg.id;
        insert stuExp5;
        
        
        /*/Back 
        Student_Expertise__c stuExp6 = TestDataGenerator.createCompetencyExpertise(aExper6.Id, 'Walden', false);
        stuExp6.Outcome_Category__c =   'Back';
        stuExp6.Student_Program__c =  sProg.id;
        insert stuExp6;
        //Pseudo
        Student_Expertise__c stuExp7 = TestDataGenerator.createCompetencyExpertise(aExper7.Id, 'Walden', false);
        stuExp7.Outcome_Category__c =   'General Elective';
        stuExp7.Student_Program__c =  sProg.id;
        insert stuExp7;
        Student_Expertise__c stuExp8 = TestDataGenerator.createCompetencyExpertise(aExper5.Id, 'Walden', false);
        stuExp8.Outcome_Category__c =   null;
        stuExp8.Student_Program__c =  sProg.id;
        insert stuExp8;*/
        Student_Expertise__c stuExp6 = TestDataGenerator.createCompetencyExpertise(aExper7.Id, 'Walden', false);
        stuExp6.Student_Program__c =  sProg.id;
        insert stuExp6;
        
        stuExp2.IsAchieved__c = true;
        stuExp2.Pseudo_CE__c = 25;
        update stuExp2;
        
        stuExp3.IsAchieved__c = true;
        update stuExp3;
            
        stuExp4.IsAchieved__c = true;
        update stuExp4;
            
        stuExp5.IsAchieved__c = true;
        update stuExp5;
            stuExp6.IsAchieved__c = true;
        update stuExp6;   
        stuExp6.IsAchieved__c = false;
        update stuExp6;
           
        
 		System.assertNotEquals(stuExp6,Null);
     
        test.stopTest();        
    }
    
    /*******************************************************************
    Method to test Update Pre-requisite; updates SE Pre-Requisite Rule object and Is_PreLock field on SE; testing single pre req and OR Condition
    Related Story : S-25237
    Created By: Horacio
    Event : After Update
    ********************************************************************/
    static testMethod void testPreReqRuleCreation_1() {
        List<Student_Expertise__c> studExprtiseLst = new List<Student_Expertise__c>();
        List<Student_Expertise__c> studExprtiseLst2 = new List<Student_Expertise__c>();
        Account acc = new Account(name='Test Account');
        insert acc;
        
        Opportunity opp = new Opportunity(Account=acc,StageName='New',Name='ooo',CloseDate=system.today());
        insert opp;
        
        Contact con=new Contact(FirstName='fname',LastName = 'lname',Email = 'email@gmail.com',Phone = '9743800309'); 
        insert con;
        
        Brand_Profile__c brandProf = new Brand_Profile__c(Contact__c=con.id,First_Name__c='AAAA', Last_Name__c='ZZZZ');
        insert brandProf;
        
        Area_of_Expertise__c areaOfExp = new Area_of_Expertise__c(Name='SSS');
        insert areaOfExp;
        
        Institution__c instn = new Institution__c(Name='Walden');
        insert instn;
        
        Id RecordTypeProduct =  Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Product2 prod = new Product2(Name='B.S. in Healthcare Management',Family='CBL',Degree_Level__c='Undergrad',Institution__c=instn.id,recordtypeid=RecordTypeProduct,ProductCode='RNMSN');
        insert prod;
        
        Id RecordTypeProduct1 =  Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Product2 prod1 = new Product2(Name='B.S. in Healthcare Management',Parent_Program__c=prod.id,Institution__c=instn.id,recordtypeid=RecordTypeProduct1, Degree_Level__c='Undergrad',ProductCode='RNMSN');
        insert prod1;
        
        Student_program__c stuProg = new student_program__c(program__c=prod1.id,Student__c=con.id);
        insert stuProg;
        
        Area_of_Expertise__c areaOfExpertise1Master = new Area_of_Expertise__c(Name='Context of Healthcare Delivery(HLTH 1005)',Pseudo_Course__c=false, Category__c='Core', Level__c ='1000');
        insert areaOfExpertise1Master;        
        Program_Expertise__c programExpertise1Master = new Program_Expertise__c(Area_of_Expertise__c=areaOfExpertise1Master.Id, IsTryBeforeYouBuy__c=false, Learning_Order__c=4.0, Program__c=prod1.Id);
        insert programExpertise1Master;        
        Student_Expertise__c studentExpertise1Master = new Student_Expertise__c(Opportunity__c=opp.Id, IsAchieved__c=false, Is_Pre_Req_Lock__c=true, Is_Audit_History_Created__c=false, Area_of_Expertise__c=areaOfExpertise1Master.Id, Program_Expertise__c=programExpertise1Master.Id);
        insert studentExpertise1Master;
        
        Area_of_Expertise__c areaOfExpertise1Detail = new Area_of_Expertise__c(Name='Concepts of Health Promotion(HLTH 1000)',Pseudo_Course__c=false, Category__c='Core', Level__c ='1000');
        insert areaOfExpertise1Detail;        
        Program_Expertise__c programExpertise1Detail = new Program_Expertise__c(Area_of_Expertise__c=areaOfExpertise1Detail.Id, IsTryBeforeYouBuy__c=false, Learning_Order__c=4.0, Program__c=prod1.Id);
        insert programExpertise1Detail;        
        Student_Expertise__c studentExpertise1Detail = new Student_Expertise__c(Opportunity__c=opp.Id, IsAchieved__c=false, Is_Audit_History_Created__c=false, Area_of_Expertise__c=areaOfExpertise1Detail.Id, Program_Expertise__c=programExpertise1Detail.Id);
        insert studentExpertise1Detail;
        
        PE_Pre_Requisite_Rule__c pePreReqRule11 = new PE_Pre_Requisite_Rule__c();
        pePreReqRule11.Program_Expertise__c = programExpertise1Master.Id;
        pePreReqRule11.Pre_Requisite_Course__c = programExpertise1Detail.Id;
        insert pePreReqRule11;
        
        SE_Pre_Requisite_Rule__c sePreReqRule11 = new SE_Pre_Requisite_Rule__c();
        sePreReqRule11.Student_Expertise__c = studentExpertise1Master.Id;
        sePreReqRule11.Pre_Requisite_Course__c = studentExpertise1Detail.Id;
        sePreReqRule11.Is_Achieved__c = false;
        insert sePreReqRule11;
        
        // Setup AND case
        Area_of_Expertise__c areaOfExpertise2Master = new Area_of_Expertise__c(Name='Strategic Planning & Marketing in Healthcare (HLTH 4115)',Pseudo_Course__c=false, Category__c='Core', Level__c ='1000');
        insert areaOfExpertise2Master;        
        Program_Expertise__c programExpertise2Master = new Program_Expertise__c(Area_of_Expertise__c=areaOfExpertise2Master.Id, IsTryBeforeYouBuy__c=false, Learning_Order__c=4.0, Program__c=prod1.Id, Pre_Req_Condition_Rule__c='OR');
        insert programExpertise2Master;        
        Student_Expertise__c studentExpertise2Master = new Student_Expertise__c(Opportunity__c=opp.Id, IsAchieved__c=false, Is_Pre_Req_Lock__c=true, Is_Audit_History_Created__c=false, Area_of_Expertise__c=areaOfExpertise2Master.Id, Program_Expertise__c=programExpertise2Master.Id);
        insert studentExpertise2Master;
        
        Area_of_Expertise__c areaOfExpertise21Detail = new Area_of_Expertise__c(Name='Healthcare Organization Theory and Behavior (HLTH 4100)',Pseudo_Course__c=false, Category__c='Core', Level__c ='1000');
        insert areaOfExpertise21Detail;        
        Program_Expertise__c programExpertise21Detail = new Program_Expertise__c(Area_of_Expertise__c=areaOfExpertise21Detail.Id, IsTryBeforeYouBuy__c=false, Learning_Order__c=4.0, Program__c=prod1.Id);
        insert programExpertise21Detail;        
        Student_Expertise__c studentExpertise21Detail = new Student_Expertise__c(Opportunity__c=opp.Id, IsAchieved__c=false, Is_Audit_History_Created__c=false, Area_of_Expertise__c=areaOfExpertise21Detail.Id, Program_Expertise__c=programExpertise21Detail.Id);
        insert studentExpertise21Detail;
        
        Area_of_Expertise__c areaOfExpertise22Detail = new Area_of_Expertise__c(Name='Healthcare Quality and Safety (HLTH 4110)',Pseudo_Course__c=false, Category__c='Core', Level__c ='1000');
        insert areaOfExpertise22Detail;        
        Program_Expertise__c programExpertise22Detail = new Program_Expertise__c(Area_of_Expertise__c=areaOfExpertise22Detail.Id, IsTryBeforeYouBuy__c=false, Learning_Order__c=4.0, Program__c=prod1.Id);
        insert programExpertise22Detail;        
        Student_Expertise__c studentExpertise22Detail = new Student_Expertise__c(Opportunity__c=opp.Id, IsAchieved__c=false, Is_Audit_History_Created__c=false, Area_of_Expertise__c=areaOfExpertise22Detail.Id, Program_Expertise__c=programExpertise22Detail.Id);
        insert studentExpertise22Detail;
        
        PE_Pre_Requisite_Rule__c pePreReqRule21 = new PE_Pre_Requisite_Rule__c();
        pePreReqRule21.Program_Expertise__c = programExpertise2Master.Id;
        pePreReqRule21.Pre_Requisite_Course__c = programExpertise21Detail.Id;
        insert pePreReqRule21;
        PE_Pre_Requisite_Rule__c pePreReqRule22 = new PE_Pre_Requisite_Rule__c();
        pePreReqRule22.Program_Expertise__c = programExpertise2Master.Id;
        pePreReqRule22.Pre_Requisite_Course__c = programExpertise22Detail.Id;
        insert pePreReqRule22;
        
        SE_Pre_Requisite_Rule__c sePreReqRule21 = new SE_Pre_Requisite_Rule__c();
        sePreReqRule21.Student_Expertise__c = studentExpertise2Master.Id;
        sePreReqRule21.Pre_Requisite_Course__c = studentExpertise21Detail.Id;
        sePreReqRule21.Is_Achieved__c = false;
        insert sePreReqRule21;
        SE_Pre_Requisite_Rule__c sePreReqRule22 = new SE_Pre_Requisite_Rule__c();
        sePreReqRule22.Student_Expertise__c = studentExpertise2Master.Id;
        sePreReqRule22.Pre_Requisite_Course__c = studentExpertise22Detail.Id;
        sePreReqRule22.Is_Achieved__c = false;
        insert sePreReqRule22;
        
        test.startTest();
        
        // Testing single pre-req
        studentExpertise1Detail.IsAchieved__c = true;
        update studentExpertise1Detail;
        
        studentExpertise21Detail.IsAchieved__c = true;
        update studentExpertise21Detail;
        studentExpertise22Detail.IsAchieved__c = true;
        update studentExpertise22Detail;
        
        test.stopTest();        
    }
    
    /*******************************************************************
    Method to test Update Pre-requisite; updates SE Pre-Requisite Rule object and Is_PreLock field on SE; Testing AND Pre-req
    Related Story : S-25237
    Created By: Horacio
    Event : After Update
    ********************************************************************/
    static testMethod void testPreReqRuleCreation_2() {
        List<Student_Expertise__c> studExprtiseLst = new List<Student_Expertise__c>();
        List<Student_Expertise__c> studExprtiseLst2 = new List<Student_Expertise__c>();
        Account acc = new Account(name='Test Account');
        insert acc;
        
        Opportunity opp = new Opportunity(Account=acc,StageName='New',Name='ooo',CloseDate=system.today());
        insert opp;
        
        Contact con=new Contact(FirstName='fname',LastName = 'lname',Email = 'email@gmail.com',Phone = '9743800309'); 
        insert con;
        
        Brand_Profile__c brandProf = new Brand_Profile__c(Contact__c=con.id,First_Name__c='AAAA', Last_Name__c='ZZZZ');
        insert brandProf;
        
        Area_of_Expertise__c areaOfExp = new Area_of_Expertise__c(Name='SSS');
        insert areaOfExp;
        
        Institution__c instn = new Institution__c(Name='Walden');
        insert instn;
        
        Id RecordTypeProduct =  Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Product2 prod = new Product2(Name='B.S. in Healthcare Management',Family='CBL',Degree_Level__c='Undergrad',Institution__c=instn.id,recordtypeid=RecordTypeProduct,ProductCode='RNMSN');
        insert prod;
        
        Id RecordTypeProduct1 =  Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Product2 prod1 = new Product2(Name='B.S. in Healthcare Management',Parent_Program__c=prod.id,Institution__c=instn.id,recordtypeid=RecordTypeProduct1, Degree_Level__c='Undergrad',ProductCode='RNMSN');
        insert prod1;
        
        Student_program__c stuProg = new student_program__c(program__c=prod1.id,Student__c=con.id);
        insert stuProg;
        
        // Setup AND case
        Area_of_Expertise__c areaOfExpertise2Master = new Area_of_Expertise__c(Name='Strategic Planning & Marketing in Healthcare (HLTH 4115)',Pseudo_Course__c=false, Category__c='Core', Level__c ='1000');
        insert areaOfExpertise2Master;        
        Program_Expertise__c programExpertise2Master = new Program_Expertise__c(Area_of_Expertise__c=areaOfExpertise2Master.Id, IsTryBeforeYouBuy__c=false, Learning_Order__c=4.0, Program__c=prod1.Id, Pre_Req_Condition_Rule__c='AND');
        insert programExpertise2Master;        
        Student_Expertise__c studentExpertise2Master = new Student_Expertise__c(Opportunity__c=opp.Id, IsAchieved__c=false, Is_Pre_Req_Lock__c=true, Is_Audit_History_Created__c=false, Area_of_Expertise__c=areaOfExpertise2Master.Id, Program_Expertise__c=programExpertise2Master.Id);
        insert studentExpertise2Master;
        
        Area_of_Expertise__c areaOfExpertise21Detail = new Area_of_Expertise__c(Name='Healthcare Organization Theory and Behavior (HLTH 4100)',Pseudo_Course__c=false, Category__c='Core', Level__c ='1000');
        insert areaOfExpertise21Detail;        
        Program_Expertise__c programExpertise21Detail = new Program_Expertise__c(Area_of_Expertise__c=areaOfExpertise21Detail.Id, IsTryBeforeYouBuy__c=false, Learning_Order__c=4.0, Program__c=prod1.Id);
        insert programExpertise21Detail;        
        Student_Expertise__c studentExpertise21Detail = new Student_Expertise__c(Opportunity__c=opp.Id, IsAchieved__c=false, Is_Audit_History_Created__c=false, Area_of_Expertise__c=areaOfExpertise21Detail.Id, Program_Expertise__c=programExpertise21Detail.Id);
        insert studentExpertise21Detail;
        
        Area_of_Expertise__c areaOfExpertise22Detail = new Area_of_Expertise__c(Name='Healthcare Quality and Safety (HLTH 4110)',Pseudo_Course__c=false, Category__c='Core', Level__c ='1000');
        insert areaOfExpertise22Detail;        
        Program_Expertise__c programExpertise22Detail = new Program_Expertise__c(Area_of_Expertise__c=areaOfExpertise22Detail.Id, IsTryBeforeYouBuy__c=false, Learning_Order__c=4.0, Program__c=prod1.Id);
        insert programExpertise22Detail;        
        Student_Expertise__c studentExpertise22Detail = new Student_Expertise__c(Opportunity__c=opp.Id, IsAchieved__c=false, Is_Audit_History_Created__c=false, Area_of_Expertise__c=areaOfExpertise22Detail.Id, Program_Expertise__c=programExpertise22Detail.Id);
        insert studentExpertise22Detail;
        
        PE_Pre_Requisite_Rule__c pePreReqRule21 = new PE_Pre_Requisite_Rule__c();
        pePreReqRule21.Program_Expertise__c = programExpertise2Master.Id;
        pePreReqRule21.Pre_Requisite_Course__c = programExpertise21Detail.Id;
        insert pePreReqRule21;
        PE_Pre_Requisite_Rule__c pePreReqRule22 = new PE_Pre_Requisite_Rule__c();
        pePreReqRule22.Program_Expertise__c = programExpertise2Master.Id;
        pePreReqRule22.Pre_Requisite_Course__c = programExpertise22Detail.Id;
        insert pePreReqRule22;
        
        SE_Pre_Requisite_Rule__c sePreReqRule21 = new SE_Pre_Requisite_Rule__c();
        sePreReqRule21.Student_Expertise__c = studentExpertise2Master.Id;
        sePreReqRule21.Pre_Requisite_Course__c = studentExpertise21Detail.Id;
        sePreReqRule21.Is_Achieved__c = false;
        insert sePreReqRule21;
        SE_Pre_Requisite_Rule__c sePreReqRule22 = new SE_Pre_Requisite_Rule__c();
        sePreReqRule22.Student_Expertise__c = studentExpertise2Master.Id;
        sePreReqRule22.Pre_Requisite_Course__c = studentExpertise22Detail.Id;
        sePreReqRule22.Is_Achieved__c = false;
        insert sePreReqRule22;
        
        test.startTest();

        studentExpertise21Detail.IsAchieved__c = true;
        update studentExpertise21Detail;
        studentExpertise22Detail.IsAchieved__c = true;
        update studentExpertise22Detail;
        
        test.stopTest();        
    }
		   
}