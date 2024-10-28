/************************************************************************
Name  : EditMyProgramRNMSNController_Test
Author: Horacio Sanchez
Date: June 18, 2021
Description: Apex test class for the EditMyProgramRNMSNController Apex class
*************************************************************************/

@isTest
public class EditMyProgramRNMSNController_Test {

    static testMethod void testEditMyProgramRNMSN() {
  
        Institution__c institution = new Institution__c();
        institution.Name = 'Walden';
        institution.SFDC_System_Name__c = 'Walden';
        insert institution;
        
        Product2 parentProduct = new Product2();
        parentProduct.Institution__c = institution.id;
        parentProduct.Name = 'M.S in Nursing Informatics - RN to MSN';
        parentProduct.IsActive = true;
        parentProduct.Published__c = true;
        parentProduct.Effective_From_Date__c = Date.newInstance(2012,09,01);
        parentProduct.Effective_To_Date__c = Date.newInstance(2042,08,31);
        parentProduct.ProductCode = 'C_MSN_Info_RNMSN';
        parentProduct.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        insert parentProduct;
        
        Product2 product2 = new Product2();
        product2.Institution__c = institution.id;
        product2.Name = 'M.S in Nursing Informatics - RN to MSN';
        product2.IsActive = true;
        product2.Published__c = true;
        product2.Effective_From_Date__c = Date.newInstance(2012,09,01);
        product2.Effective_To_Date__c = Date.newInstance(2042,08,31);
        product2.ProductCode = 'C_MSN_Info_RNMSN';
        product2.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        product2.Parent_Program__c = parentProduct.Id;
    	product2.Degree_Level__c = 'Graduate';
        insert product2; 
    
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        
        Id standardPricebookId = Test.getStandardPricebookId();
        Pricebook2 pb = new Pricebook2(ID=standardPricebookId,Subscription_Duration_in_Months__c = 0);
        update pb;
        
        Student_Program__c sProg = new student_program__c(Student__c=testCon.id);
        sProg.Program__c = product2.id;
        insert sProg;
        
        Opportunity opp = new Opportunity(Account=acc,StageName='New', Name='Opp name', CloseDate=system.today(), Student_Program__c=sProg.id, primary_program__c=product2.id);
        insert opp;
        
        Program_Version__c programVersion = new Program_Version__c(Active__c=true, Program_Lookup__c=product2.id, Total_Credits_in_Program__c=133.00, Credit_Progression_Rate__c=6.6250);
        insert programVersion;
        
        sProg.Program__c = product2.id;
        sProg.Program_Version__c = programVersion.Id;
        update sProg;
        
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg,pb, 'Walden', false);
        stuSub.Start_Date__c = Date.today().addDays(-40);
        stuSub.Subscription_Status__c = 'RE = Registered';
        stuSub.End_Date__c = Date.today().addDays(50);
        stuSub.List_Price__c = 3500;
        stuSub.Future_Term__c = false;
        stuSub.Agreed_To_Credits__c = 2;
        stuSub.Date_Student_Agreed_To_Credits__c = null;
        insert stuSub;
    
        sProg.Current_Student_Subscription__c = stuSub.Id;
        update sProg;            
        Profile communityProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Tempo Community Users'
            LIMIT 1 ];
        user usr = new user();
        usr.Username = testCon.email;
        usr.ContactId = testCon.id;
        usr.ProfileId = communityProfile.Id;
        usr.Alias = testCon.FirstName;
        usr.Email = testCon.email + '.Walden';
        usr.FirstName = testCon.FirstName;
        usr.LastName = testCon.LastName;
        usr.FederationIdentifier = testCon.CBL_Student_ID__c;
        usr.TimeZoneSidKey = 'America/New_York';
        usr.LocaleSidKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        usr.IsActive = true;
        insert usr;
        Brand_Configuration__c brandConf = TestDataGenerator.createBrandConfiguration('Test Brand Configuratiomn', 'TEST','Header', true) ;
        Community_Site_Settings__c defaultCustomSetngs = new Community_Site_Settings__c();
        defaultCustomSetngs.Name = 'Default Settings';
        defaultCustomSetngs.RecordID__c = brandConf.id;
        defaultCustomSetngs.Intercom_Secret_Key__c = 'U8BjsjJnasonsauho32873ashj783HHBS';
        insert defaultCustomSetngs;       
        
        //--Create area of exprtise
        Area_of_Expertise__c areaOfExpertise1 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExpertise1.Name = 'Interpersonal Communication(COMM 1004C)';
        areaOfExpertise1.Display_Name__c = 'Interpersonal Communication(COMM 1004C)';
        areaOfExpertise1.Display_on_Program_Edit__c  = TRUE;
        areaOfExpertise1.Display_on_web__c = TRUE;
        areaOfExpertise1.category__c = 'General Education';
        areaOfExpertise1.overview__c= 'TEST DESCRIPTION';
        areaOfExpertise1.LMS_ID__c = '1001';
        insert areaOfExpertise1;
        
        Area_of_Expertise__c areaOfExpertise2 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExpertise2.Name = 'Psychology(PSYC 1001)';
        areaOfExpertise2.Display_Name__c = 'Psychology(PSYC 1001)';
        areaOfExpertise2.Display_on_Program_Edit__c  = TRUE;
        areaOfExpertise2.Display_on_web__c = TRUE;
        areaOfExpertise2.category__c = 'General Education; General Elective';
        areaOfExpertise2.overview__c= 'TEST DESCRIPTION';
        areaOfExpertise2.LMS_ID__c = '1002';
        insert areaOfExpertise2;
        
        Area_of_Expertise__c areaOfExpertise3 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExpertise3.Name = 'World Religions (RELG 2001)';
        areaOfExpertise3.Display_Name__c = 'World Religions (RELG 2001)';
        areaOfExpertise3.Display_on_Program_Edit__c  = TRUE;
        areaOfExpertise3.category__c = 'General Education';
        areaOfExpertise3.overview__c= 'TEST DESCRIPTION';
        areaOfExpertise3.Display_on_web__c = TRUE;
        areaOfExpertise3.LMS_ID__c = '1003';
        insert areaOfExpertise3;
        
        Area_of_Expertise__c areaOfExpertiseTMSN3 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExpertiseTMSN3.Name = 'Modern Popular Culture (HMNT 3001)';
        areaOfExpertiseTMSN3.Display_Name__c = 'Modern Popular Culture (HMNT 3001)';
        areaOfExpertiseTMSN3.Display_on_Program_Edit__c  = TRUE;
        areaOfExpertiseTMSN3.category__c = 'General Education; General Elective';
        areaOfExpertiseTMSN3.overview__c= 'TEST DESCRIPTION';
        areaOfExpertiseTMSN3.Display_on_web__c = TRUE;
        areaOfExpertiseTMSN3.LMS_ID__c = '2001';
        insert areaOfExpertiseTMSN3;
        
        Area_of_Expertise__c areaOfExpertiseTMSN4 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExpertiseTMSN4.Name = 'Ethics(PHIL 2001)';
        areaOfExpertiseTMSN4.Display_Name__c = 'Ethics(PHIL 2001)';
        areaOfExpertiseTMSN4.Display_on_Program_Edit__c  = TRUE;
        areaOfExpertiseTMSN4.category__c = 'General Education; General Elective';
        areaOfExpertiseTMSN4.overview__c= 'TEST DESCRIPTION';
        areaOfExpertiseTMSN4.Display_on_web__c = TRUE;
        areaOfExpertiseTMSN4.LMS_ID__c = '2002';
        insert areaOfExpertiseTMSN4;
        
        Area_of_Expertise__c areaOfExpertiseTMSN5 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExpertiseTMSN5.Name = 'American Government (POLI 1001)';
        areaOfExpertiseTMSN5.Display_Name__c = 'American Government (POLI 1001)';
        areaOfExpertiseTMSN5.Display_on_Program_Edit__c  = TRUE;
        areaOfExpertiseTMSN5.category__c = 'General Education; General Elective';
        areaOfExpertiseTMSN5.overview__c= 'TEST DESCRIPTION';
        areaOfExpertiseTMSN5.Display_on_web__c = TRUE;
        areaOfExpertiseTMSN5.LMS_ID__c = '2003';
        insert areaOfExpertiseTMSN5;
        
        Area_of_Expertise__c areaOfExpertiseTMSN6 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExpertiseTMSN6.Name = 'Microeconomics(ECON 1002)';
        areaOfExpertiseTMSN6.Display_Name__c = 'Microeconomics(ECON 1002)';
        areaOfExpertiseTMSN6.Display_on_Program_Edit__c  = TRUE;
        areaOfExpertiseTMSN6.category__c = 'General Education; General Elective';
        areaOfExpertiseTMSN6.overview__c= 'TEST DESCRIPTION';
        areaOfExpertiseTMSN6.Display_on_web__c = TRUE;
        areaOfExpertiseTMSN6.LMS_ID__c = '2004';
        insert areaOfExpertiseTMSN6;
        
        // Inserting Master AoEs
        Master_AoE__c masterAOE1 = new Master_AoE__c();
        masterAOE1.Course__c = areaOfExpertise1.Id;
        masterAOE1.Program__c = product2.Id;
        insert masterAOE1;
        
        Master_AoE__c masterAOE2 = new Master_AoE__c();
        masterAOE2.Course__c = areaOfExpertise2.Id;
        masterAOE2.Program__c = product2.Id;
        insert masterAOE2;
        
        Master_AoE__c masterAOE3 = new Master_AoE__c();
        masterAOE3.Course__c = areaOfExpertise3.Id;
        masterAOE3.Program__c = product2.Id;
        insert masterAOE3;
        
        // Creating Competency objects
        List<Competency__c> competenciesList = new List<Competency__c>();
        Competency__c IC1001 = new Competency__c(Name='Basics of Communication',                AoE_LMS_ID__c='1001', Code__c='IC1001');
        Competency__c IC1002 = new Competency__c(Name='Describing Interpersonal Relationships', AoE_LMS_ID__c='1001', Code__c='IC1001');
        Competency__c IC1003 = new Competency__c(Name='Listening Effectively',                  AoE_LMS_ID__c='1001', Code__c='IC1001');
        Competency__c IC1004 = new Competency__c(Name='Effective Communication',                AoE_LMS_ID__c='1001', Code__c='IC1001');
        Competency__c IC1005 = new Competency__c(Name='Becoming a More Effective Communicator', AoE_LMS_ID__c='1001', Code__c='IC1001');
        competenciesList.add(IC1001);
        competenciesList.add(IC1002);
        competenciesList.add(IC1003);
        competenciesList.add(IC1004);
        competenciesList.add(IC1005);
        Competency__c PY1001 = new Competency__c(Name='Psychology as a Science',                    AoE_LMS_ID__c='1002', Code__c='PY1001');
        Competency__c PY1002 = new Competency__c(Name='Sensing and Perceiving',                     AoE_LMS_ID__c='1002', Code__c='PY1002');
        Competency__c PY1003 = new Competency__c(Name='Learning and Memory',                        AoE_LMS_ID__c='1002', Code__c='PY1003');
        Competency__c PY1004 = new Competency__c(Name='Personality and Social Behaviors',           AoE_LMS_ID__c='1002', Code__c='PY1004');
        Competency__c PY1005 = new Competency__c(Name='Human Development, Motivation, and Emotion', AoE_LMS_ID__c='1002', Code__c='PY1005');
        Competency__c PY1006 = new Competency__c(Name='	Psychological Disorders and Treatment',     AoE_LMS_ID__c='1002', Code__c='PY1006');
        competenciesList.add(PY1001);
        competenciesList.add(PY1002);
        competenciesList.add(PY1003);
        competenciesList.add(PY1004);
        competenciesList.add(PY1005);
        competenciesList.add(PY1006);
        Competency__c MC3001 = new Competency__c(Name='What is Popular Culture?',                                                  AoE_LMS_ID__c='2001', Code__c='MC3001');
        Competency__c MC3002 = new Competency__c(Name='Popular Culture Audiences',                                                 AoE_LMS_ID__c='2001', Code__c='MC3002');
        Competency__c MC3003 = new Competency__c(Name='Access to Popular Culture',                                                 AoE_LMS_ID__c='2001', Code__c='MC3003');
        Competency__c MC3004 = new Competency__c(Name='Societal Values and Popular Culture',                                       AoE_LMS_ID__c='2001', Code__c='MC3004');
        Competency__c MC3005 = new Competency__c(Name='The Power and Impact of Popular Culture on Social and Individual Identity', AoE_LMS_ID__c='2001', Code__c='MC3005');
        competenciesList.add(MC3001);
        competenciesList.add(MC3002);
        competenciesList.add(MC3003);
        competenciesList.add(MC3004);
        competenciesList.add(MC3005);
        Competency__c ET2001 = new Competency__c(Name='Introduction to Ethics',              AoE_LMS_ID__c='2002', Code__c='ET2001');
        Competency__c ET2002 = new Competency__c(Name='Egoism vs Altruism',                  AoE_LMS_ID__c='2002', Code__c='ET2002');
        Competency__c ET2003 = new Competency__c(Name='Consequentialism and Utilitarianism', AoE_LMS_ID__c='2002', Code__c='ET2003');
        Competency__c ET2004 = new Competency__c(Name='Deontology and Kant’s Moral Theory',  AoE_LMS_ID__c='2002', Code__c='ET2004');
        Competency__c ET2005 = new Competency__c(Name='Ethics for Positive Social Change',   AoE_LMS_ID__c='2002', Code__c='ET2005');
        competenciesList.add(ET2001);
        competenciesList.add(ET2002);
        competenciesList.add(ET2003);
        competenciesList.add(ET2004);
        competenciesList.add(ET2005);
        Competency__c AG1001 = new Competency__c(Name='Foundations of American Government',                 AoE_LMS_ID__c='2003', Code__c='AG1001');
        Competency__c AG1002 = new Competency__c(Name='Civil Rights and Civil Liberties',                   AoE_LMS_ID__c='2003', Code__c='AG1002');
        Competency__c AG1003 = new Competency__c(Name='Divisions of Government',                            AoE_LMS_ID__c='2003', Code__c='AG1003');
        Competency__c AG1004 = new Competency__c(Name='Politics in Action',                                 AoE_LMS_ID__c='2003', Code__c='AG1004');
        Competency__c AG1005 = new Competency__c(Name='Public Policy',                                      AoE_LMS_ID__c='2003', Code__c='AG1005');
        Competency__c AG1006 = new Competency__c(Name='Political Participation and Positive Social Change', AoE_LMS_ID__c='2003', Code__c='AG1006');
        competenciesList.add(AG1001);
        competenciesList.add(AG1002);
        competenciesList.add(AG1003);
        competenciesList.add(AG1004);
        competenciesList.add(AG1005);
        competenciesList.add(AG1006);
        Competency__c MS1001 = new Competency__c(Name='Economic Decision Making',              AoE_LMS_ID__c='2004', Code__c='MS1001');
        Competency__c MS1002 = new Competency__c(Name='Supply and Demand',                     AoE_LMS_ID__c='2004', Code__c='MS1002');
        Competency__c MS1003 = new Competency__c(Name='Industry Structure and Strategy',       AoE_LMS_ID__c='2004', Code__c='MS1003');
        Competency__c MS1004 = new Competency__c(Name='Role of Government and Global Markets', AoE_LMS_ID__c='2004', Code__c='MS1004');
        competenciesList.add(MS1001);
        competenciesList.add(MS1002);
        competenciesList.add(MS1003);
        competenciesList.add(MS1004);
        insert competenciesList;
        
        // Creating Competency Expertise objects
        List<Competency_Expertise__c> ceList = new List<Competency_Expertise__c>(); 
        Competency_Expertise__c ceIC1001 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise1.ID, IC1001.Id, null, true);
        Competency_Expertise__c ceIC1002 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise1.ID, IC1002.Id, null, true);
        Competency_Expertise__c ceIC1003 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise1.ID, IC1003.Id, null, true);
        Competency_Expertise__c ceIC1004 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise1.ID, IC1004.Id, null, true);
        Competency_Expertise__c ceIC1005 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise1.ID, IC1005.Id, null, true);
        Competency_Expertise__c cePY1001 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise2.ID, PY1001.Id, null, true);
        Competency_Expertise__c cePY1002 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise2.ID, PY1002.Id, null, true);
        Competency_Expertise__c cePY1003 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise2.ID, PY1003.Id, null, true);
        Competency_Expertise__c cePY1004 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise2.ID, PY1004.Id, null, true);
        Competency_Expertise__c cePY1005 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise2.ID, PY1005.Id, null, true);
        Competency_Expertise__c cePY1006 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise2.ID, PY1006.Id, null, true);
               
        // Create Program Expertise Test data 
        Program_Expertise__c pe1 = TestDataGenerator.createProgramExpertise(areaOfExpertise1.Id, product2.id, false, 1.0, false);
        pe1.category__c = 'General Education';
        insert pe1;
        Program_Expertise__c pe2 = TestDataGenerator.createProgramExpertise(areaOfExpertise2.Id, product2.id, false, 1.0, false);
        pe2.category__c = 'General Education';
        insert pe2;
        Program_Expertise__c pe3 = TestDataGenerator.createProgramExpertise(areaOfExpertise3.Id, product2.id, false, 1.0, false);
        pe3.category__c = 'General Education; General Elective';
        insert pe3;
       
        // Create Student Expertise Test data 
        String studentExpertiseRecordTypeId = Schema.SObjectType.Student_Expertise__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Student_Expertise__c studentExpertise1 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise1.id, null , false);
        studentExpertise1.Program_Expertise__c = pe1.id;
        studentExpertise1.Student_Program__c = sProg.id;
        studentExpertise1.Is_Removed_from_Program_Plan__c = true;
        studentExpertise1.Contact__c = testCon.Id;
        insert studentExpertise1;
        Student_Expertise__c studentExpertise2 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise2.id, null , false);
        studentExpertise2.Program_Expertise__c = pe2.id;
        studentExpertise2.Student_Program__c = sProg.id;
        studentExpertise2.Contact__c = testCon.Id;
        studentExpertise2.Is_Added_from_Program_Plan__c = false;
        studentExpertise2.Is_Removed_from_Program_Plan__c = false;
        insert studentExpertise2;
        Student_Expertise__c studentExpertise3 = TestDataGenerator.createCompetencyExpertise(areaOfExpertise3.id, null, false);
        studentExpertise3.Program_Expertise__c = pe3.id;
        studentExpertise3.Student_Program__c = sProg.id;   
        studentExpertise3.Contact__c = testCon.Id;
        insert studentExpertise3;
        Student_Expertise__c studentExpertiseTMSN3 = TestDataGenerator.createCompetencyExpertise(areaOfExpertiseTMSN3.id, null, false);
        studentExpertiseTMSN3.Student_Program__c = sProg.id;   
        studentExpertiseTMSN3.Contact__c = testCon.Id;
        insert studentExpertiseTMSN3;
        Student_Expertise__c studentExpertiseTMSN4 = TestDataGenerator.createCompetencyExpertise(areaOfExpertiseTMSN4.id, null, false);
        studentExpertiseTMSN4.Student_Program__c = sProg.id;   
        studentExpertiseTMSN4.Contact__c = testCon.Id;
        insert studentExpertiseTMSN4;
         
        // Creating Student Competency objects
        List<Student_Competency__c> scList = new List<Student_Competency__c>();
        Student_Competency__c scIC1001 = new student_competency__c(Student_Expertise__c=studentExpertise1.Id, Competency__c=IC1001.Id);
        Student_Competency__c scIC1002 = new student_competency__c(Student_Expertise__c=studentExpertise1.Id, Competency__c=IC1002.Id);
        Student_Competency__c scIC1003 = new student_competency__c(Student_Expertise__c=studentExpertise1.Id, Competency__c=IC1003.Id);
        Student_Competency__c scIC1004 = new student_competency__c(Student_Expertise__c=studentExpertise1.Id, Competency__c=IC1004.Id);
        Student_Competency__c scIC1005 = new student_competency__c(Student_Expertise__c=studentExpertise1.Id, Competency__c=IC1005.Id);     
        scList.add(scIC1001);
        scList.add(scIC1002);
        scList.add(scIC1003);
        scList.add(scIC1004);
        scList.add(scIC1005);
        Student_Competency__c scPY1001 = new student_competency__c(Student_Expertise__c=studentExpertise2.Id, Competency__c=PY1001.Id, Is_Enrolled__c=true);
        Student_Competency__c scPY1002 = new student_competency__c(Student_Expertise__c=studentExpertise2.Id, Competency__c=PY1002.Id, Is_Enrolled__c=true);
        Student_Competency__c scPY1003 = new student_competency__c(Student_Expertise__c=studentExpertise2.Id, Competency__c=PY1003.Id, Is_Enrolled__c=true);
        Student_Competency__c scPY1004 = new student_competency__c(Student_Expertise__c=studentExpertise2.Id, Competency__c=PY1004.Id, Is_Enrolled__c=true);
        Student_Competency__c scPY1005 = new student_competency__c(Student_Expertise__c=studentExpertise2.Id, Competency__c=PY1005.Id, Is_Enrolled__c=true);
        Student_Competency__c scPY1006 = new student_competency__c(Student_Expertise__c=studentExpertise2.Id, Competency__c=PY1006.Id, Is_Enrolled__c=true);
        scList.add(scPY1001);
        scList.add(scPY1002);
        scList.add(scPY1003);
        scList.add(scPY1004);
        scList.add(scPY1005);
        scList.add(scPY1006);
        Student_Competency__c scMC3001 = new student_competency__c(Student_Expertise__c=studentExpertiseTMSN3.Id, Competency__c=MC3001.Id, Is_Enrolled__c=true);
        Student_Competency__c scMC3002 = new student_competency__c(Student_Expertise__c=studentExpertiseTMSN3.Id, Competency__c=MC3002.Id, Is_Enrolled__c=true);
        Student_Competency__c scMC3003 = new student_competency__c(Student_Expertise__c=studentExpertiseTMSN3.Id, Competency__c=MC3003.Id, Is_Enrolled__c=true);
        Student_Competency__c scMC3004 = new student_competency__c(Student_Expertise__c=studentExpertiseTMSN3.Id, Competency__c=MC3004.Id, Is_Enrolled__c=true);
        Student_Competency__c scMC3005 = new student_competency__c(Student_Expertise__c=studentExpertiseTMSN3.Id, Competency__c=MC3005.Id, Is_Enrolled__c=true);
        scList.add(scMC3001);
        scList.add(scMC3002);
        scList.add(scMC3003);
        scList.add(scMC3004);
        scList.add(scMC3005);
        Student_Competency__c scET2001 = new student_competency__c(Student_Expertise__c=studentExpertiseTMSN4.Id, Competency__c=ET2001.Id, Is_Enrolled__c=true);
        Student_Competency__c scET2002 = new student_competency__c(Student_Expertise__c=studentExpertiseTMSN4.Id, Competency__c=ET2002.Id, Is_Enrolled__c=true);
        Student_Competency__c scET2003 = new student_competency__c(Student_Expertise__c=studentExpertiseTMSN4.Id, Competency__c=ET2003.Id, Is_Enrolled__c=true);
        Student_Competency__c scET2004 = new student_competency__c(Student_Expertise__c=studentExpertiseTMSN4.Id, Competency__c=ET2004.Id, Is_Enrolled__c=true);
        Student_Competency__c scET2005 = new student_competency__c(Student_Expertise__c=studentExpertiseTMSN4.Id, Competency__c=ET2005.Id, Is_Enrolled__c=true);
        scList.add(scET2001);
        scList.add(scET2002);
        scList.add(scET2003);
        scList.add(scET2004);
        scList.add(scET2005);
        insert scList;
        
        // Custom setting
        List<Attribute_Rules__c> attributeRulesList = new List<Attribute_Rules__c>();
        attributeRulesList.add(new Attribute_Rules__c(Name='TMSN0',
                                                      Subject_Area_Name__c='Electives',
                                                      Category__c='General Education; General Elective;',
                                                      Course_Name__c='Elective Gen Ed',
                                                      Create_Course__c=false,
                                                      Required_Credits__c=5.0,
                                                      Subject_Matter_Expertise__c='Elective',
                                                      Course_Codes_Pool__c='HMNT 3001;PHIL 1001S; PHIL 2001; RELG 2001;BIOL 1001;MATH 1030;POLI 1001;PSYC 1001;SOCI 1001S;ECON 1002;SOCI 4080;ANTH 3001;COMM 1004C;ENGL 2002;COMM 4001;COMM 1008')
                              );
        attributeRulesList.add(new Attribute_Rules__c(Name='TMSN2',
                                                      Subject_Area_Name__c='Communication',
                                                      Category__c='General Education; General Elective;',
                                                      Course_Name__c='Written and Oral Communications Gen Ed',
                                                      Create_Course__c=false,
                                                      Required_Credits__c=5.0,
                                                      Subject_Matter_Expertise__c='Written and Oral Communication',
                                                      Course_Codes_Pool__c='COMM 1004C; ENGL 2002; COMM 4001; COMM 1008')
                              );
        attributeRulesList.add(new Attribute_Rules__c(Name='TMSN3',
                                                      Subject_Area_Name__c='Humanities',
                                                      Category__c='General Education; General Elective;',
                                                      Course_Name__c='Humanities Gen Ed I',
                                                      Create_Course__c=false,
                                                      Required_Credits__c=5.0,
                                                      Subject_Matter_Expertise__c='Arts and Humanities',
                                                      Course_Codes_Pool__c='HMNT 3001;PHIL 1001S; PHIL 2001; RELG 2001')
                              );
        attributeRulesList.add(new Attribute_Rules__c(Name='TMSN4',
                                                      Subject_Area_Name__c='Humanities',
                                                      Category__c='General Education; General Elective;',
                                                      Course_Name__c='Humanities Gen Ed II',
                                                      Create_Course__c=false,
                                                      Required_Credits__c=5.0,
                                                      Subject_Matter_Expertise__c='Arts and Humanities',
                                                      Course_Codes_Pool__c='HMNT 3001;PHIL 1001S; PHIL 2001; RELG 2001')
                              );
        attributeRulesList.add(new Attribute_Rules__c(Name='TMSN5',
                                                      Subject_Area_Name__c='Social/Behavioral Sciences',
                                                      Category__c='General Education; General Elective;',
                                                      Course_Name__c='Social Science Gen Ed I',
                                                      Create_Course__c=false,
                                                      Required_Credits__c=5.0,
                                                      Subject_Matter_Expertise__c='Social Sciences',
                                                      Course_Codes_Pool__c='POLI 1001; PSYC 1001; SOCI 1001S; ECON 1002; SOCI 4080; ANTH 3001')
                              );
        attributeRulesList.add(new Attribute_Rules__c(Name='TMSN6',
                                                      Subject_Area_Name__c='Social/Behavioral Sciences',
                                                      Category__c='General Education; General Elective;',
                                                      Course_Name__c='Social Science Gen Ed II',
                                                      Create_Course__c=false,
                                                      Required_Credits__c=5.0,
                                                      Subject_Matter_Expertise__c='Social Sciences',
                                                      Course_Codes_Pool__c='POLI 1001; PSYC 1001; SOCI 1001S; ECON 1002; SOCI 4080; ANTH 3001')
                              );
        
        insert attributeRulesList;
        
        List<Admission_Attributes__c> aaList = new List<Admission_Attributes__c>();
        Admission_Attributes__c aa0 = new Admission_Attributes__c();
        aa0.Name = 'TMSN0';
        aa0.Opportunity__c = opp.Id;
        //aaList.add(aa0);
        insert aa0;
        
        Admission_Attributes__c aa2 = new Admission_Attributes__c();
        aa2.Name = 'TMSN2';
        aa2.Opportunity__c = opp.Id;
        //aaList.add(aa2);
        insert aa2;
        
        /*Admission_Attributes__c aa3 = new Admission_Attributes__c();
        aa3.Name = 'TMSN3';
        aa3.Opportunity__c = opp.Id;
        //aaList.add(aa3);
        insert aa3;
        
        Admission_Attributes__c aa4 = new Admission_Attributes__c();
        aa4.Name = 'TMSN4';
        aa4.Opportunity__c = opp.Id;
        //aaList.add(aa4);
        insert aa4;        
        
        Admission_Attributes__c aa5 = new Admission_Attributes__c();
        aa5.Name = 'TMSN5';
        aa5.Opportunity__c = opp.Id;
        //aaList.add(aa5);
        insert aa5;        
        
        Admission_Attributes__c aa6 = new Admission_Attributes__c();
        aa6.Name = 'TMSN6';
        aa6.Opportunity__c = opp.Id;
        //aaList.add(aa6);
        insert aa6;
        */
        //insert aaList;

        Pre_requisite_Rules__c preReqRulsObj = new Pre_requisite_Rules__c(Course_Name__c = areaOfExpertise1.Id, 
                                                                          Area_of_Expertise__c = areaOfExpertise1.Id);
        insert preReqRulsObj;
        
        Student_Program__c sp = [SELECT Id FROM Student_Program__c WHERE Id =: sProg.Id LIMIT 1];
        
        test.startTest();
        
        PageReference pageRef = Page.EditMyProgram;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', sProg.Id);
        
        EditMyProgramRNMSNController controller = new EditMyProgramRNMSNController();
        ApexPages.currentPage().getParameters().put('selectedExpertiseIdToAdd', areaOfExpertise1.id);
        ApexPages.currentPage().getParameters().put('selectedSubjectAreaNameToAdd', 'Communication');
        controller.addAreaOfExpertise();
        ApexPages.currentPage().getParameters().put('selectedExpertiseIdToAdd', areaOfExpertise2.id);
        ApexPages.currentPage().getParameters().put('selectedSubjectAreaNameToAdd', 'Electives');
        controller.addAreaOfExpertise();
        
        ApexPages.currentPage().getParameters().put('selectedExpertiseIdToRemove', areaOfExpertise1.id);
        ApexPages.currentPage().getParameters().put('selectedSubjectAreaNameToRemove', 'Communication');
        controller.removeAreaOfExpertise();
        ApexPages.currentPage().getParameters().put('selectedExpertiseIdToRemove', areaOfExpertise2.id);
        ApexPages.currentPage().getParameters().put('selectedSubjectAreaNameToRemove', 'Electives');
        controller.removeAreaOfExpertise();
        
        controller.editMyProgramCancel();
        
        /*ApexPages.currentPage().getParameters().put('selectedExpertiseIdToAdd', areaOfExpertiseTMSN3.id);
        ApexPages.currentPage().getParameters().put('selectedSubjectAreaNameToAdd', 'Humanities');
        controller.addAreaOfExpertise();
        ApexPages.currentPage().getParameters().put('selectedExpertiseIdToAdd', areaOfExpertiseTMSN4.id);
        ApexPages.currentPage().getParameters().put('selectedSubjectAreaNameToAdd', 'Humanities');
        controller.addAreaOfExpertise();
        
        controller.saveCompetencies();
        
        ApexPages.currentPage().getParameters().put('selectedExpertiseIdToAdd', areaOfExpertiseTMSN5.id);
        ApexPages.currentPage().getParameters().put('selectedSubjectAreaNameToAdd', 'Social/Behavioral Sciences');
        controller.addAreaOfExpertise();
        ApexPages.currentPage().getParameters().put('selectedExpertiseIdToAdd', areaOfExpertiseTMSN6.id);
        ApexPages.currentPage().getParameters().put('selectedSubjectAreaNameToAdd', 'Social/Behavioral Sciences');
        controller.addAreaOfExpertise();
        
        controller.saveCompetencies();
        
        ApexPages.currentPage().getParameters().put('selectedExpertiseIdToRemove', areaOfExpertiseTMSN5.id);
        ApexPages.currentPage().getParameters().put('selectedSubjectAreaNameToRemove', 'Social/Behavioral Sciences');
        controller.removeAreaOfExpertise();
        ApexPages.currentPage().getParameters().put('selectedExpertiseIdToRemove', areaOfExpertiseTMSN6.id);
        ApexPages.currentPage().getParameters().put('selectedSubjectAreaNameToRemove', 'Social/Behavioral Sciences');
        controller.removeAreaOfExpertise();
        */
        controller.saveCompetencies();
            
        test.stopTest();         
    }
}