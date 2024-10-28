/*******************************************************************
Name  : StudentCompetencyHelper_Test
Author: Bryan Leboff (Appirio)
Date  : October 20, 2014
Description: Test for Helper class for student competencies
*************************************************************************/  
@isTest
private class StudentCompetencyHelper_Test {
    private static List<Contact> students;
    private static List<Program_Competency__c> skillCompetencies;
    private static List<Program_Competency__c> dependentCompetencies;
    private static List<Competency__c> competencies;
    static void setup() {
         RecordTypes_For_CBL_Processes__c objCbl = TestDataGenerator.createRecordTypesForCBLProcesses('student competency walden', 'Student_Competency__c','Walden', true);
        // Implement test code
        //create some students
        Account a = TestDataGenerator.createAccount(true);
        students = TestDataGenerator.createContacts(a, 3, null, true);

        //create some competencies that will be the dependents
        Product2 parentProduct = TestDataGenerator.createProduct('testprod', null, true);        
        Product2 product = TestDataGenerator.createProduct('testprod', null, false);
        product.Parent_Program__c = parentProduct.id;
        insert product;
        competencies = new List<Competency__c>();
        for(Integer i = 0; i<12; i++){
            competencies.add(TestDataGenerator.createCompetency(false));
            if(i < 4){
                competencies[i].type__c = 'Skill';
            }
        }
        insert competencies;

        skillCompetencies = new List<Program_Competency__c>();
        for(Integer i = 0; i<4; i++){
            skillCompetencies.add(TestDataGenerator.createProgramCompetency(competencies[i].id, product.id, false, i, false));
        }
        dependentCompetencies = new List<Program_Competency__c>();
        for(Integer i = 4; i<10; i++){
            dependentCompetencies.add(TestDataGenerator.createProgramCompetency(competencies[i].id, product.id, false, i, false));
        }
        insert skillCompetencies;
        insert dependentCompetencies;

        //set some up as skill competencies and give them dependent competencies
        //skill competency 0 gets 0, 1, 2 as dependents
        //skill competency 1 gets 3 as a dependent 
        //skill competnecy 2 gets 4,5 as dependents 
        //skill competency 3 gets no dependents 
        List<Program_Competency_Join__c> skillCompetencyDependents = new List<Program_Competency_Join__c>();
        skillCompetencyDependents.add(new Program_Competency_Join__c(Parent_Competency__c = skillCompetencies[0].id, Dependent_Competency__c= dependentCompetencies[0].id)); 
        skillCompetencyDependents.add(new Program_Competency_Join__c(Parent_Competency__c = skillCompetencies[0].id, Dependent_Competency__c= dependentCompetencies[1].id)); 
        skillCompetencyDependents.add(new Program_Competency_Join__c(Parent_Competency__c = skillCompetencies[0].id, Dependent_Competency__c= dependentCompetencies[2].id)); 
        skillCompetencyDependents.add(new Program_Competency_Join__c(Parent_Competency__c = skillCompetencies[1].id, Dependent_Competency__c= dependentCompetencies[3].id)); 
        skillCompetencyDependents.add(new Program_Competency_Join__c(Parent_Competency__c = skillCompetencies[2].id, Dependent_Competency__c= dependentCompetencies[4].id)); 
        skillCompetencyDependents.add(new Program_Competency_Join__c(Parent_Competency__c = skillCompetencies[2].id, Dependent_Competency__c= dependentCompetencies[5].id)); 
        insert skillCompetencyDependents;

    }
    
    @isTest static void testSkillCompetencyCompleted() {
        setup();
        //give student 0 student competency 0 and 1 in completed and then insert 2 as completed
        Contact student = students[0];
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true); 
        Student_Expertise__c sExpertise = TestDataGenerator.createCompetencyExpertise(aExper.Id,null, true);
        List<Student_Competency__c> studentComepetencies = new List<Student_Competency__c>();
        studentComepetencies.add(TestDataGenerator.createStudentCompetency(skillCompetencies[0], student.id, true, 'Walden', false ,sExpertise));
        studentComepetencies.add(TestDataGenerator.createStudentCompetency(dependentCompetencies[0], student.id, true, 'Walden', false,sExpertise));
        studentComepetencies.add(TestDataGenerator.createStudentCompetency(dependentCompetencies[1], student.id, true, 'Walden', false,sExpertise));

        insert studentComepetencies;

        Student_Competency__c skillCompetency = [select id, iscompleted__c from Student_Competency__c where id =: studentComepetencies[0].id];

       // System.assert(!skillCompetency.iscompleted__c);

        Student_Competency__c finalDependency = TestDataGenerator.createStudentCompetency(dependentCompetencies[2], student.id, true, 'Walden', true,sExpertise);

        skillCompetency = [select id, iscompleted__c from Student_Competency__c where id =: studentComepetencies[0].id];
       // System.assert(skillCompetency.iscompleted__c);

    }
    @isTest static void testSkillCompetencyIncomplete() {
        setup();
        //give student 0 student competency 0 and 1 in completed and then insert 2 as completed
        Contact student = students[0];
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true); 
        Student_Expertise__c sExpertise = TestDataGenerator.createCompetencyExpertise(aExper.Id,null, true);
        List<Student_Competency__c> studentComepetencies = new List<Student_Competency__c>();
        studentComepetencies.add(TestDataGenerator.createStudentCompetency(skillCompetencies[0], student.id, true, 'Walden', false,sExpertise));
        studentComepetencies.add(TestDataGenerator.createStudentCompetency(dependentCompetencies[0], student.id, true, 'Walden', false,sExpertise));

        insert studentComepetencies;

        Student_Competency__c skillCompetency = [select id, iscompleted__c from Student_Competency__c where id =: studentComepetencies[0].id];

        //System.assert(!skillCompetency.iscompleted__c);

        Student_Competency__c finalDependency = TestDataGenerator.createStudentCompetency(dependentCompetencies[2], student.id, true, 'Walden', true,sExpertise);

        skillCompetency = [select id, iscompleted__c from Student_Competency__c where id =: studentComepetencies[0].id];
      //  System.assert(!skillCompetency.iscompleted__c);
        // Implement test code
    }
    @isTest static void testSkillCompetencyNoSubCompetencies() {
        setup();
        //give student 0 student competency 0 and 1 in completed and then insert 2 as completed
        Contact student = students[0];
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true); 
        Student_Expertise__c sExpertise = TestDataGenerator.createCompetencyExpertise(aExper.Id,null, true);
        List<Student_Competency__c> studentComepetencies = new List<Student_Competency__c>();
        studentComepetencies.add(TestDataGenerator.createStudentCompetency(skillCompetencies[3], student.id, false, 'Walden', false,sExpertise));
        insert studentComepetencies;

        Student_Competency__c skillCompetency = [select id, iscompleted__c from Student_Competency__c where id =: studentComepetencies[0].id];

        //System.assert(!skillCompetency.iscompleted__c);
    }
    @isTest static void testSkillCompetencyUncompletedByUpdate() {
        setup();
        //give student 0 student competency 0 and 1 in completed and then insert 2 as completed
        Contact student = students[0];
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true); 
        Student_Expertise__c sExpertise = TestDataGenerator.createCompetencyExpertise(aExper.Id,null, true);
        List<Student_Competency__c> studentComepetencies = new List<Student_Competency__c>();
        studentComepetencies.add(TestDataGenerator.createStudentCompetency(skillCompetencies[0], student.id, true, 'Walden', false,sExpertise));
        studentComepetencies.add(TestDataGenerator.createStudentCompetency(dependentCompetencies[0], student.id, true, 'Walden', false,sExpertise));
        studentComepetencies.add(TestDataGenerator.createStudentCompetency(dependentCompetencies[1], student.id, true, 'Walden', false,sExpertise));
        studentComepetencies.add(TestDataGenerator.createStudentCompetency(dependentCompetencies[2], student.id, true, 'Walden', false,sExpertise));
        insert studentComepetencies;

        Student_Competency__c skillCompetency = [select id, iscompleted__c from Student_Competency__c where id =: studentComepetencies[0].id];
       // System.assert(skillCompetency.iscompleted__c);

        studentComepetencies[2].iscompleted__c = false;
        update studentComepetencies[2];

        skillCompetency = [select id, iscompleted__c from Student_Competency__c where id =: studentComepetencies[0].id];
       // System.assert(!skillCompetency.iscompleted__c);


    }
    @isTest static void testSkillCompetencyByDelete() {
        setup();
        //give student 0 student competency 0 and 1 in completed and then insert 2 as completed
        Contact student = students[0];
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true); 
        Student_Expertise__c sExpertise = TestDataGenerator.createCompetencyExpertise(aExper.Id,null, true);
        List<Student_Competency__c> studentComepetencies = new List<Student_Competency__c>();
        studentComepetencies.add(TestDataGenerator.createStudentCompetency(skillCompetencies[0], student.id, true, 'Walden', false,sExpertise));
        studentComepetencies.add(TestDataGenerator.createStudentCompetency(dependentCompetencies[0], student.id, true, 'Walden', false,sExpertise));
        studentComepetencies.add(TestDataGenerator.createStudentCompetency(dependentCompetencies[1], student.id, true, 'Walden', false,sExpertise));
        studentComepetencies.add(TestDataGenerator.createStudentCompetency(dependentCompetencies[2], student.id, true, 'Walden', false,sExpertise));
        insert studentComepetencies;

        Student_Competency__c skillCompetency = [select id, iscompleted__c from Student_Competency__c where id =: studentComepetencies[0].id];
        //System.assert(skillCompetency.iscompleted__c);

        delete studentComepetencies[2];

        skillCompetency = [select id, iscompleted__c from Student_Competency__c where id =: studentComepetencies[0].id];
        //System.assert(!skillCompetency.iscompleted__c);

        undelete studentComepetencies[2];

        skillCompetency = [select id, iscompleted__c from Student_Competency__c where id =: studentComepetencies[0].id];
       // System.assert(skillCompetency.iscompleted__c);

    }
    @isTest static void testSkillCompetencyCompletedByUpdate() {
        setup();
        //give student 0 student competency 0 and 1 in completed and then insert 2 as completed
        Contact student = students[0];
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true); 
        Student_Expertise__c sExpertise = TestDataGenerator.createCompetencyExpertise(aExper.Id,null, true);
        List<Student_Competency__c> studentComepetencies = new List<Student_Competency__c>();
        studentComepetencies.add(TestDataGenerator.createStudentCompetency(skillCompetencies[0], student.id, true, 'Walden', false,sExpertise));
        studentComepetencies.add(TestDataGenerator.createStudentCompetency(dependentCompetencies[0], student.id, true, 'Walden', false,sExpertise));
        studentComepetencies.add(TestDataGenerator.createStudentCompetency(dependentCompetencies[1], student.id, true, 'Walden', false,sExpertise));
        studentComepetencies.add(TestDataGenerator.createStudentCompetency(dependentCompetencies[2], student.id, false, 'Walden', false,sExpertise));
        insert studentComepetencies;

        Student_Competency__c skillCompetency = [select id, iscompleted__c from Student_Competency__c where id =: studentComepetencies[0].id];
       // System.assert(!skillCompetency.iscompleted__c);

        
        studentComepetencies[3].iscompleted__c = true;
        update studentComepetencies[3];

        skillCompetency = [select id, iscompleted__c from Student_Competency__c where id =: studentComepetencies[0].id];
       // System.assert(skillCompetency.iscompleted__c);
    }
    
     // test method to test rollUpNumberOfCompletedCompetenciesInTrial
     /*Commented out as we don't have TBYB competencies now 
    static testMethod void testrollUpNumberOfCompletedCompetenciesInTrial() {
        // test method to test onBeforeInsert function
        // create test data
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('BrandbProfile', 'Brand_Profile__c','Tempo', true);
        RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity','Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb3 = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c','Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb4 = TestDataGenerator.createRecordTypesForCBLProcesses('Student Competency', 'Student_Competency__c','Walden', true);
        Account testAcc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(testAcc, false); 
        testCon.Email = 'test12@test12345.Com';
        insert testCon;
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);        
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.Id;
        insert product2;            
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper.Id,product2.id,true,4.0, true);
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Program_Competency__c testPComo = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0,true);
        Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        testProfile1.Primary_Program_of_Interest__c = product2.id;
        testProfile1.Email__c = 'test12@test12345.Com';
        insert testProfile1;
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);
        list<Opportunity> lstOpportunity = [Select ID, StageName,Competencies_Completed_in_Trial__c, Brand_Profile__c from Opportunity where Brand_Profile__c =:testProfile1.ID];
        Opportunity opty = lstOpportunity[0];
        list<Student_Competency__c> lstSComp = [select ID,Student_Program__c,Opportunity__c,Status__c,Completed_Date__c,
                                        Student_Program__r.First_Start_Date__c,Competency_Type__c
                                        from Student_Competency__c
                                        where Opportunity__c =: opty.id limit 1];
        system.assertEquals(opty.Competencies_Completed_in_Trial__c, null);
        lstSComp[0].Status__c = 'Mastered';
        lstSComp[0].Completed_Date__c = Date.today();
        //lstSComp[0].Competency_Type__c = 'Academic';
        update lstSComp;
        Opportunity updatedOpportunity = [Select ID, Competencies_Completed_in_Trial__c  from Opportunity where id =:opty.ID];
        //system.assertEquals(updatedOpportunity.Competencies_Completed_in_Trial__c, 1);                                      
          
    }    
    */
    
    private static Student_Program__c studentProgram;
    private static User user1;
    private static List<Student_Competency__c> studentCompetencyList;
    private static Assignment_Group_CST__c assignmentGroupName;
    private static SME_Cohort__c smeCohort;
    private static Student_Competency__c studentCompetency10 = new Student_Competency__c();
    
    static void setup2() {
        Account acc = new Account(name='Test Account');
        insert acc;
     
        Contact con=new Contact(FirstName='fname', LastName='lname', Email='email@gmail.com', Phone='9743800309'); 
        insert con;
        
        /*Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1 ];        
        
        user1 = new User(username=con.email, ContactId=con.id, ProfileId=communityProfile.Id, Alias=con.FirstName, Email=con.Email+'.Walden', 
                            FirstName=con.FirstName, LastName=con.LastName, FederationIdentifier=con.CBL_Student_ID__c,
                            TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', IsActive=true);
        insert user1;*/
        
        string strRandom = string.valueOf( Math.random());
        Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        user1 = new User(Alias = 'standt', Email='standarduser'+strRandom+'@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profile.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='yyyywwwwwqq'+strRandom+'@testorg.com', Assignment_Group_Active__c = true);
        insert user1;
        
        User user2 = new User(Alias = 'standt', Email='enrollmentManager'+strRandom+'@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Enrollment', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profile.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='enrollmentManager'+strRandom+'@testorg.com', Assignment_Group_Active__c = true);
        insert user2;
        
        assignmentGroupName = new Assignment_Group_CST__c(name='TEST01 SME Group');
        insert assignmentGroupName;
       
        
        Assignment_Group_CST__c   assignmentGroupName2 = new Assignment_Group_CST__c(name='TEST02 SME Group');
        insert assignmentGroupName2;
        
        
        smeCohort = new sme_cohort__c(SME_Assignment_Group__c =assignmentGroupName.id, License_Type__c  ='Non-Cohort');
        insert smeCohort;
        
        
        sme_cohort__c   smeCohort2 = new sme_cohort__c(SME_Assignment_Group__c =assignmentGroupName2.id, License_Type__c  = 'Non-Cohort');
        insert smeCohort2;
        
        Customer_Support_Team__c customerSupportTeam = new Customer_Support_Team__c(SME_Cohort_Group__c	= smeCohort.id, Status__c='Active', User__c=user1.Id);
        insert customerSupportTeam;
        
        
          Customer_Support_Team__c customerSupportTeam1 = new Customer_Support_Team__c(SME_Cohort_Group__c	= smeCohort.id, Status__c='Active', User__c=user1.Id);
        insert customerSupportTeam1;
        
          Customer_Support_Team__c customerSupportTeam2 = new Customer_Support_Team__c(SME_Cohort_Group__c	= smeCohort2.id, Status__c='Active', User__c=user1.Id);
        insert customerSupportTeam2;
        
        
          Customer_Support_Team__c customerSupportTeam3 = new Customer_Support_Team__c(SME_Cohort_Group__c	= smeCohort2.id, Status__c='Active', User__c=user1.Id);
        insert customerSupportTeam3;
        
        Institution__c instn = new Institution__c(Name='Walden');
        insert instn;
        Id RecordTypeProduct =  Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Product2 prod = new Product2(Name = 'P_BSECS', ProductCode='P_BSECS', Family = 'Family 1',Degree_Level__c='Undergrad',Institution__c=instn.id,recordtypeid=RecordTypeProduct);
        insert prod;
        
        Product2 prod1 = new Product2(Name = 'C_BSECS', ProductCode='C_BSECS', Parent_Program__c=prod.id,Institution__c=instn.id,recordtypeid=RecordTypeProduct,Degree_Level__c='Undergrad');
        insert prod1;
        
        studentProgram = new student_program__c(Student__c=con.id);
        studentProgram.Program__c = prod1.id;
        insert studentProgram;
        
        Opportunity opp = new Opportunity(Account=acc,StageName='New',Name='Opp name',CloseDate=system.today(),Student_Program__c=studentProgram.id, primary_program__c=prod1.id);
        insert opp;
        
        studentProgram.Program__c = prod1.id;
        update studentProgram;
        
        Pricebook2 pricebook = TestDataGenerator.createSubscrptPricebook('Pricebook', 3, 'Walden', true);
        Student_Subscription__c studentSubscription = TestDataGenerator.createStudentSubscription(studentProgram, pricebook, 'Walden', true, Date.today(), 10, 5);
        
        Id areaOfExpertiseRecordTypeId = Schema.SObjectType.Area_of_Expertise__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Area_Of_Expertise__c areaOfExpertise1 = new Area_Of_Expertise__c(Name='Test Area of Expertise1', Description__c='Area of Expertise 1 description', Display_On_Web__c=true,
                                                                         Display_Name__c='Test Area of Expertise1', Type__c='Academic', RecordTypeId=areaOfExpertiseRecordTypeId);
        insert areaOfExpertise1;
        Area_Of_Expertise__c areaOfExpertise2 = new Area_Of_Expertise__c(Name='Test Area of Expertise2', Description__c='Area of Expertise 2 description', Display_On_Web__c=true,
                                                                         Display_Name__c='Test Area of Expertise2', Type__c='Academic', RecordTypeId=areaOfExpertiseRecordTypeId,
                                                                         Pseudo_Course__c=true);
        insert areaOfExpertise2;
        
        Competency__c competency1 = new Competency__c(Assignment_Group_CST__c = assignmentGroupName.id ,Code__c='TEST01', Description__c='Competency description', Type__c='Academic', Credit_Equivalency__c=5.0, Published__c=true);
        insert competency1;
        Competency__c competency2 = new Competency__c(Assignment_Group_CST__c  = assignmentGroupName2.id,Code__c='TEST02', Description__c='Competency 2 description', Type__c='Academic', Credit_Equivalency__c=5.0, Published__c=true);
        insert competency2;
        Competency__c competency3 = new Competency__c(Assignment_Group_CST__c  = assignmentGroupName2.id,Code__c='TEST02', Description__c='Competency 3 description', Type__c='Academic', Credit_Equivalency__c=5.0, Published__c=true, Assessment_Type__c='Written Response');
        insert competency3;
        
        Sections__c section1 = new Sections__c(Competency__c=competency1.id, SME__c=user1.Id, Current_Section__c=true);
        insert section1;
        
        Id studentExpertiseRecordTypeId = Schema.SObjectType.Student_Expertise__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Student_Expertise__c studentExpertise1 = new Student_Expertise__c(Area_of_Expertise__c=areaOfExpertise1.id, Student_Program__c=studentProgram.Id, recordTypeId=studentExpertiseRecordTypeId);
        insert studentExpertise1;
        Student_Expertise__c studentExpertise2 = new Student_Expertise__c(Area_of_Expertise__c=areaOfExpertise2.id, Student_Program__c=studentProgram.Id, recordTypeId=studentExpertiseRecordTypeId,
                                                                          Pseudo_CE__c=5);
        insert studentExpertise2;
        
        List<Student_Competency__c> studetCompetencyInsertList = new List<Student_Competency__c>();
        Id studentCompetencyRecordTypeId = Schema.SObjectType.Student_Competency__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Student_Competency__c studentCompetency1 = new Student_Competency__c(Student_Program__c=studentProgram.id, competency__c=competency1.id, RecordTypeId=studentCompetencyRecordTypeId,
                                                                             Student_Expertise__c=studentExpertise1.id);        
        Student_Competency__c studentCompetency2 = new Student_Competency__c(Student_Program__c=studentProgram.id, competency__c=competency1.id, RecordTypeId=studentCompetencyRecordTypeId,
                                                                             Student_Expertise__c=studentExpertise1.id);        
        Student_Competency__c studentCompetency3 = new Student_Competency__c(Student_Program__c=studentProgram.id, competency__c=competency2.id, RecordTypeId=studentCompetencyRecordTypeId,
                                                                             Student_Expertise__c=studentExpertise1.id, IsCompleted__c=true, Status__c='Fulfilled');
        Student_Competency__c studentCompetency4 = new Student_Competency__c(Student_Program__c=studentProgram.id, competency__c=competency2.id, RecordTypeId=studentCompetencyRecordTypeId,
                                                                             Student_Expertise__c=studentExpertise2.id, IsCompleted__c=true, Status__c='Transferred');
        Student_Competency__c studentCompetency5 = new Student_Competency__c(Student_Program__c=studentProgram.id, competency__c=competency2.id, RecordTypeId=studentCompetencyRecordTypeId,
                                                                             Student_Expertise__c=studentExpertise2.id, IsCompleted__c=true, Status__c='Transferred', Pseudo_CE__c=5);
        Student_Competency__c studentCompetency6 = new Student_Competency__c(Student_Program__c=studentProgram.id, competency__c=competency2.id, RecordTypeId=studentCompetencyRecordTypeId,
                                                                             Student_Expertise__c=studentExpertise2.id, IsCompleted__c=true, Status__c='Fulfilled', Pseudo_CE__c=5);
        Student_Competency__c studentCompetency7 = new Student_Competency__c(Student_Program__c=studentProgram.id, competency__c=competency2.id, RecordTypeId=studentCompetencyRecordTypeId,
                                                                             Student_Expertise__c=studentExpertise1.id, IsCompleted__c=true, Status__c='Transferred');
        Student_Competency__c studentCompetency8 = new Student_Competency__c(Student_Program__c=studentProgram.id, competency__c=competency2.id, RecordTypeId=studentCompetencyRecordTypeId,
                                                                             Student_Expertise__c=studentExpertise2.id, IsCompleted__c=true, Status__c='Mastered', Student_Subscription_Achieved_In__c = null);
        Student_Competency__c studentCompetency9 = new Student_Competency__c(Student_Program__c=studentProgram.id, competency__c=competency2.id, RecordTypeId=studentCompetencyRecordTypeId,
                                                                             Student_Expertise__c=studentExpertise2.id, IsCompleted__c=true, Status__c='Achieved', Student_Subscription_Achieved_In__c=studentSubscription.id);
        studentCompetency10 = new Student_Competency__c(Student_Program__c=studentProgram.id, competency__c=competency3.id, RecordTypeId=studentCompetencyRecordTypeId,
                                                                             Student_Expertise__c=studentExpertise2.id, IsCompleted__c=true, Status__c='Registered', Student_Subscription_Achieved_In__c=studentSubscription.id);
        studetCompetencyInsertList.add(studentCompetency1);
        studetCompetencyInsertList.add(studentCompetency2);
        studetCompetencyInsertList.add(studentCompetency3);
        studetCompetencyInsertList.add(studentCompetency4);
        studetCompetencyInsertList.add(studentCompetency5);
        studetCompetencyInsertList.add(studentCompetency6);
        studetCompetencyInsertList.add(studentCompetency7);
        studetCompetencyInsertList.add(studentCompetency8);
        studetCompetencyInsertList.add(studentCompetency9);
        studetCompetencyInsertList.add(studentCompetency10);
        insert studetCompetencyInsertList;
        
        studentCompetencyList = new List<Student_Competency__c>();
        studentCompetencyList.add(studentCompetency1);
        studentCompetencyList.add(studentCompetency2);
        
    }
    
    static testMethod void testGroupAssignment() {
        setup2();
        Test.startTest();
        StudentCompetencyHelper helper = new StudentCompetencyHelper();
        helper.groupAssignment(studentCompetencyList, assignmentGroupName.Id);
        Test.stopTest();
    }
    
    static testMethod void testRollUpNumberOfCompetenciesOnStudentProgram() {
        setup2();
        Test.startTest();
        StudentCompetencyHelper helper = new StudentCompetencyHelper();
        helper.rollUpNumberOfCompetenciesOnStudentProgram(new Set<Id>{studentProgram.id});
        Test.stopTest();
    }
    
    static testMethod void testUpdateFirstCompetencyStartedCount() {
        List<Student_Competency__c> updateFirstCompetencyStudentCompetencyList = new List<Student_Competency__c>();
        setup2();
        Test.startTest();
        StudentCompetencyHelper helper = new StudentCompetencyHelper();
        Student_Competency__c testStudentCompetency = new Student_Competency__c();
        testStudentCompetency.Id = studentCompetency10.Id;
        testStudentCompetency.Status__c = 'Mastered';
        updateFirstCompetencyStudentCompetencyList.add(testStudentCompetency);
        update updateFirstCompetencyStudentCompetencyList;
        Test.stopTest();
    }
    
}