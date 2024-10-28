/*******************************************************************
Name  : StudentProgramHelper_Test
Author: Samarth Mathur (Appirio)
Modified By: Vinod Kumar
Date  : October 07 , 2014
Description: Test Class for the Handler class StudentProgramTriggerHandler and trigger StudentProgramTrigger.
            Also Covering the test coverage of the helper class StudentProgramHelper

* Revision History
*************************************************************************/

@isTest
private class StudentProgramHelper_Test {
    // test after insert triggger and createStudentEnrollmentSteps method from StudentProgramHelper class
    static testMethod void testCreateStudentEnrollmentSteps(){
        //Create Test Data    
        //Create Institutions to make enrollment steps
        Institution__c insti1 = new Institution__c();
        insti1.Name = 'Walden';
        insert insti1;
        list<Enrollment_Steps__c> lstEnrollmentSteps = new list<Enrollment_Steps__c>();
        Enrollment_Steps__c es1 = new Enrollment_Steps__c ();
        es1.Enrollment_Step_Name__c = 'I1 Step1';
        es1.Institution__c = insti1.id; 
        lstEnrollmentSteps.add(es1);    
        Enrollment_Steps__c es3 = new Enrollment_Steps__c ();
        es3.Enrollment_Step_Name__c = 'I1 Step2';
        es3.Institution__c = insti1.id;
        lstEnrollmentSteps.add(es3);
        insert lstEnrollmentSteps;      
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c','Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        product2.Institution__c = insti1.id;
        product2.ProductCode='RNMSN';
        insert product2;
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c =product2.id;
        insert opty;
        Student_Program__c sp1 = TestDataGenerator.createStudentProgram(opty,testCon.ID, null, true);
        // test Student_Enrollment_Steps__c is created or not
        List<Student_Enrollment_Steps__c> newSES1 = [Select id, Name from Student_Enrollment_Steps__c where Student_Program__c =:sp1.ID];
        system.assertEquals(newSES1.size(), 2);     
    }
    // test after insert triggger and bindStudentDiscountWithStudentProgram method from StudentProgramHelper class
    /*static testMethod void testBindStudentDiscountWithStudentProgram(){
        //Create Test Data    
        //Create Institutions to make enrollment steps
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c','Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = product2.Id;
        psd.Start_Date__c = TestDataGenerator.getFirstMondayOfMonth(Date.today()+31);
        psd.Accepting_New_Students__c = true;
        insert psd;
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c =product2.id;
        insert opty;
        opty.Program_Start_Date__c = psd.Id;
        opty.Admissions_Status__c = 'AD Admitted';
        opty.Admissions_Status_Code__c = 'AD';
        opty.StageName = 'Recommend Admit';
        opty.opportunity_status_auto_values__c = 'Admitted';
        update opty;
        Exemption__c exc = new Exemption__c();
        exc.Name= 'Discount 1';
       exc.Fee_Type__c = 'Tech Fee';
        exc.Flat_Rate_Amount__c=300.50;
        exc.Institution__c = TestDataGenerator.createInstitution('Walden', true).Id;
        exc.Life_of_Program__c = true;
        exc.Exemption_Category__c = 'Standard Reduction';
        exc.Active__c = true;
        insert exc; 
        // create student discount
        Student_Discount__c sdc = TestDataGenerator.createStudentDiscount(opty,null,exc, true );    
        Student_Discount__c sdc2 = TestDataGenerator.createStudentDiscount(opty,null,exc, true );   
        
        Student_Program__c sp1 = TestDataGenerator.createStudentProgram(opty,testCon.ID, null, true);
        List<Student_Discount__c>  SD1 = [Select id, Name from Student_Discount__c where Student_Program__c =: sp1.ID];
        System.assertEquals(SD1.size(), 2);
                
    }*/
    // test after update triggger and updatesToStudentProgramUponOpportunityWin method from StudentProgramHelper class
    static testMethod void testUpdatesToStudentProgramUponOpportunityWin(){
        //Create Test Data    
        //Create Institutions to make enrollment steps
         
        
        Script_Settings__c settings = new Script_Settings__c();
        settings.name = 'Current Settings';
        settings.Coach_Assignment_Limit__c = 100;
        insert settings;
        
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Student Program', 'Student_Program__c','Walden', true);
        RecordTypes_For_CBL_Processes__c objeCb2 = TestDataGenerator.createRecordTypesForCBLProcesses('Opportunity', 'Opportunity','Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        product2.ProductCode='RNMSN';
        insert product2;
        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = product2.Id;
        psd.Start_Date__c = TestDataGenerator.getFirstMondayOfMonth(Date.today()+31);
        psd.Accepting_New_Students__c = true;
        insert psd;    
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, 'Walden', false);
        opty.Initial_Price_Book__c = pb.id;
        opty.Primary_Program__c =product2.id;   
        opty.Program_Start_Date__c = psd.Id;    
        insert opty;
        Student_Program__c sp1 = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', true);
        sp1.Program_Start_Date__c = psd.Id;
        update sp1;
        opty.StageName = 'Student';
        opty.Student_Program__c = sp1.id;
        opty.Contact__c = testCon.Id;
        update opty;
        Student_Subscription__c stdSubObj = new Student_Subscription__c(Student_Program__c = sp1.Id,Start_Date__c = System.today());
        insert stdSubObj;
        Student_Program__c updatedProgram =[Select id,Student_Enrollment_Status__c,(Select Id,Start_Date__c,Change_Reason__c From Subscriptions__r limit 2) from Student_Program__c where id =: sp1.ID];         
        System.assertEquals(updatedProgram.Student_Enrollment_Status__c,'Eligible to Register (EL)');  
        System.debug('updatedProgram---'+updatedProgram.Subscriptions__r.size());
        
        StudentProgramHelper hlprObj = new StudentProgramHelper();   
        hlprObj.populateStartDateOnStudentSubscription(new Set<Id>{sp1.Id});
        
        Institution__c insObj = TestDataGenerator.createInstitution('Walden',true);
        Product2 product3 = new Product2();
        product3 = [select id,Institution__c,Name,IsActive,Published__c,Effective_From_Date__c,Effective_To_Date__c,RecordTypeId,Parent_Program__c from Product2 where id=:product2.Id];
        
        Engagement_Rule__c engObj = TestDataGenerator.createEngagementRule('Met with Faculty Coach', product3.Institution__c, true, true);
        Engagement_Rule__c engObj2 = TestDataGenerator.createEngagementRule('Submitted or Updated Plan', product3.Institution__c, true, true);
        Student_Engagement_Rule__c serObj = new Student_Engagement_Rule__c();
        serObj = TestDataGenerator.createStudentEngagementRule(sp1.Id, engObj.Id, true, true);
        Student_Engagement_Rule__c serObj2 = TestDataGenerator.createStudentEngagementRule(sp1.Id, engObj2.Id, true, true);

        hlprObj.logStudentEngagementByType(new List<Id>{sp1.Id}, 'Met with Faculty Coach', new Map<Id, Date>{sp1.Id=>system.today()});
        //StudentProgramHelper.assignCoachInBS(new List<Student_Program__c>{sp1});
        hlprObj.createStudentEngagementRules(new List<Student_Program__c>{sp1});
    }
    
    static testMethod void testCreatCapstoneProject() {
        Account acc = new Account(name='Test Account');
        insert acc;
     
        Contact con = new Contact(FirstName='fname',LastName = 'lname',Email = 'email@gmail.com',Phone = '9743800309'); 
        insert con;
        
        Institution__c instn = new Institution__c(Name='Walden');
        insert instn;
        Id RecordTypeProduct =  Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Product2 prod = new Product2(Name = 'P_BSECS', ProductCode='P_BSECS', Family='Family 1', Degree_Level__c='Graduate', Institution__c=instn.id,recordtypeid=RecordTypeProduct);
        insert prod;
        
        Product2 prod1 = new Product2(Name = 'M.S. in Human Resource Management', ProductCode='C_MSHRM', Parent_Program__c=prod.id, Institution__c=instn.id, recordtypeid=RecordTypeProduct, Degree_Level__c='Graduate');
        insert prod1;
        
        Student_Program__c studentProgram = new student_program__c(Student__c=con.id);
        studentProgram.Program__c = prod1.id;
        insert studentProgram;
        
        Opportunity opp = new Opportunity(Account=acc,StageName='New', Name='Opp name', CloseDate=system.today(), Student_Program__c=studentProgram.id, primary_program__c=prod1.id);
        insert opp;
        
        studentProgram.Program__c = prod1.id;
        update studentProgram;
        
        Area_of_Expertise__c aoe1 = new Area_of_Expertise__c(Name='Capstone Option 1: Strategic(MHRM 6901)', Display_name__c='Capstone Option 1: Strategic(MHRM 6901)');
        insert aoe1;
        
        Area_of_Expertise__c aoe2 = new Area_of_Expertise__c(Name='Capstone Option 2: Meeting SHRM Competencies(MHRM 6902)', Display_name__c='Capstone Option 2: Meeting SHRM Competencies(MHRM 6902)');
        insert aoe2;
        
        Competency__c comp1 = TestDataGenerator.createCompetency(true);
        Competency__c comp2 = TestDataGenerator.createCompetency(true);
        Competency__c comp3 = TestDataGenerator.createCompetency(true);
        Competency__c comp4 = TestDataGenerator.createCompetency(true);
        
        List<Competency_Expertise__c> compExpList = new List<Competency_Expertise__c>();
        Competency_Expertise__c compExp1 = new Competency_Expertise__c(Area_of_Expertise__c=aoe1.id, Competency__c=comp1.id);
        Competency_Expertise__c compExp2 = new Competency_Expertise__c(Area_of_Expertise__c=aoe1.id, Competency__c=comp2.id);
        Competency_Expertise__c compExp3 = new Competency_Expertise__c(Area_of_Expertise__c=aoe2.id, Competency__c=comp3.id);
        Competency_Expertise__c compExp4 = new Competency_Expertise__c(Area_of_Expertise__c=aoe2.id, Competency__c=comp4.id);
        compExpList.add(compExp1);
        compExpList.add(compExp2);
        compExpList.add(compExp3);
        compExpList.add(compExp4);
        insert compExpList;
                
        studentProgram.HRM_Capstone_Selection__c = 'Capstone 1';
        update studentProgram;
        
        studentProgram.HRM_Capstone_Selection__c = 'Capstone 2';
        update studentProgram;
        
        studentProgram.HRM_Capstone_Selection__c = 'Capstone 1';
        update studentProgram;
        
    }
}