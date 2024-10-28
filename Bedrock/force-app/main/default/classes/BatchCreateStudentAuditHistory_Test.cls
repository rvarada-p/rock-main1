/************************************************************************************** 
Apex Class Name     : BatchCreateStudentAuditHistory_Test
Created Date        : 24th January 2019
Function            : Test class for BatchCreateStudentAuditHistory class
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                  
* Ravitej Varada            1/24/2019                Original Version
 *
Revision History :

* Ravitej Varada      - Jan 18th 2021 -  S-39026 -  Test method to handle 'Statistics'  subject area expetise in Gen Ed.
*************************************************************************************/
@isTest
Private class BatchCreateStudentAuditHistory_Test{
    
    Private static List<Student_Expertise__c> studExprtiseLst ;
    Private static List<Area_of_Expertise__c> aoeLst ;
    
    private static opportunity opp;
    private static student_program__c stuProg;
    Private static void setup() {
        system.debug('222222');
        Account acc = new Account(name='Test Account');
        insert acc;
        
        opp = new Opportunity(Account=acc,StageName='New',Name='ooo',CloseDate=system.today());
        insert opp;
        
        Contact con=new Contact(FirstName='fname',LastName = 'lname',Email = 'email@gmail.com',Phone = '9743800309'); 
        insert con;
        
        Area_of_Expertise__c areaOfExp = new Area_of_Expertise__c(Name='SSS');
        insert areaOfExp;
        
        Institution__c instn = new Institution__c(Name='Walden');
        insert instn;
        
        Id RecordTypeProduct =  Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Product2 prod = new Product2(Name = 'Laptop X200',Family = 'Hardware',Degree_Level__c='Undergrad',Institution__c=instn.id,
                                     recordtypeid=RecordTypeProduct);
        insert prod;
        
        Id RecordTypeProduct1 =  Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Product2 prod1 = new Product2(Name = 'Laptop X20',Parent_Program__c=prod.id,Institution__c=instn.id,recordtypeid=RecordTypeProduct1,
                                      Degree_Level__c='Undergrad');
        insert prod1;
        
        stuProg = new student_program__c(program__c=prod1.id,Student__c=con.id);
        insert stuProg;
        
        
        
        List<Program_Category_Requirement__c> categoryReList =new List<Program_Category_Requirement__c>();
        Program_Category_Requirement__c categoryRe1= new Program_Category_Requirement__c(Program__c=prod1.id,Category__c = 'Core',Level__c = 'Upper', Total_CE__c = 10);
        categoryReList.add(categoryRe1);
        Program_Category_Requirement__c categoryRe2= new Program_Category_Requirement__c(Program__c=prod1.id,Category__c = 'Core',Level__c = 'Lower', Total_CE__c = 10);
        categoryReList.add(categoryRe2);
        Program_Category_Requirement__c categoryRe3= new Program_Category_Requirement__c(Program__c=prod1.id,Category__c = 'Concentration',Level__c = 'Lower', Total_CE__c = 10);
        categoryReList.add(categoryRe3);
        Program_Category_Requirement__c categoryRe4= new Program_Category_Requirement__c(Program__c=prod1.id,Category__c = 'General Education',Level__c = 'Lower',Subject_Area_Expertise__c = null, Total_CE__c = 25);
        categoryReList.add(categoryRe4);
        Program_Category_Requirement__c categoryRe5= new Program_Category_Requirement__c(Program__c=prod1.id,Category__c = 'General Education',Level__c = 'Lower',Subject_Area_Expertise__c ='Arts and Humanities' , Total_CE__c = 5);
        categoryReList.add(categoryRe5);
        Program_Category_Requirement__c categoryRe6= new Program_Category_Requirement__c(Program__c=prod1.id,Category__c = 'General Education',Level__c = 'Lower',Subject_Area_Expertise__c = 'Written and Oral Communication', Total_CE__c = 5);
        categoryReList.add(categoryRe6);
        Program_Category_Requirement__c categoryRe7= new Program_Category_Requirement__c(Program__c=prod1.id,Category__c = 'General Education',Level__c = 'Lower',Subject_Area_Expertise__c = 'Mathematics/Natural Sciences', Total_CE__c = 5);
        categoryReList.add(categoryRe7);
        Program_Category_Requirement__c categoryRe8= new Program_Category_Requirement__c(Program__c=prod1.id,Category__c = 'General Education',Level__c = 'Lower',Subject_Area_Expertise__c = 'Social Sciences', Total_CE__c = 5);
        categoryReList.add(categoryRe8);
        Program_Category_Requirement__c categoryRe9= new Program_Category_Requirement__c(Program__c=prod1.id,Category__c = 'General Elective',Level__c = 'Lower' , Total_CE__c = 10);
        categoryReList.add(categoryRe9);
        Program_Category_Requirement__c categoryRe10= new Program_Category_Requirement__c(Program__c=prod1.id,Category__c = 'General Education',Level__c = 'Lower',Subject_Area_Expertise__c = 'Any Category' , Total_CE__c = 5);
        categoryReList.add(categoryRe10);   
        insert categoryReList;
        
        
        
    }
    
    @isTest  static  void testMethodOne() {
        setup();
        
        aoeLst = new List<Area_of_Expertise__c>();
        
        Area_of_Expertise__c areaOfExp1 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExp1.Level__c = '3000';
        areaOfExp1.Category__c = 'Core';
        areaOfExp1.Pseudo_Course__c = true;
        aoeLst.add(areaOfExp1); 
         
        Area_of_Expertise__c areaOfExp2 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExp2.Level__c = '3000';
        areaOfExp2.Category__c = 'Core';
        areaOfExp2.Pseudo_Course__c = true;
        aoeLst.add(areaOfExp2); 
        
        
        insert aoeLst;
        
        
        studExprtiseLst = new List<Student_Expertise__c>();
        
        Student_Expertise__c studExprtse1 = new  Student_Expertise__c();
        studExprtse1.Opportunity__c = opp.id;
        studExprtse1.IsAchieved__c= True;
        studExprtse1.Is_Audit_History_Created__c = False;
        studExprtse1.Pseudo_CE__c = 4;
        studExprtse1.Area_of_Expertise__c=areaOfExp1.id;
        studExprtse1.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse1);
        
        
        Student_Expertise__c studExprtse2 = new  Student_Expertise__c();
        studExprtse2.Opportunity__c = opp.id;
        studExprtse2.IsAchieved__c= True;
        studExprtse2.Is_Audit_History_Created__c = False;
        studExprtse2.Pseudo_CE__c = 4;
        studExprtse2.Area_of_Expertise__c=areaOfExp2.id;
        studExprtse2.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse2);
        
        
        Area_of_Expertise__c areaOfExp3 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Core',Level__c ='4000');
        insert areaOfExp3;	
        Student_Expertise__c studExprtse3 = new  Student_Expertise__c();
        studExprtse3.Opportunity__c = opp.id;
        studExprtse3.IsAchieved__c= True;
        studExprtse3.Is_Audit_History_Created__c = False;
        studExprtse3.Pseudo_CE__c = 4;
        studExprtse3.Area_of_Expertise__c=areaOfExp3.id;
        studExprtse3.Outcome_Category__c = null;
        studExprtse3.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse3);
        
        Area_of_Expertise__c areaOfExp4 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Core',Level__c ='4000');
        insert areaOfExp4;	
        Student_Expertise__c studExprtse4 = new  Student_Expertise__c();
        studExprtse4.Opportunity__c = opp.id;
        studExprtse4.IsAchieved__c= True;
        studExprtse4.Is_Audit_History_Created__c = False;
        studExprtse4.Pseudo_CE__c = 4;
        studExprtse4.Area_of_Expertise__c=areaOfExp4.id;
        studExprtse4.Outcome_Category__c = null;
        studExprtse4.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse4);
        
        Area_of_Expertise__c areaOfExp5 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Core',Level__c ='4000');
        insert areaOfExp5;	
        Student_Expertise__c studExprtse5 = new  Student_Expertise__c();
        studExprtse5.Opportunity__c = opp.id;
        studExprtse5.IsAchieved__c= True;
        studExprtse5.Is_Audit_History_Created__c = False;
        studExprtse5.Pseudo_CE__c = 4;
        studExprtse5.Area_of_Expertise__c=areaOfExp5.id;
        studExprtse5.Outcome_Category__c = null;
        studExprtse5.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse5);
        
        Area_of_Expertise__c areaOfExp6 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Core',Level__c ='4000');
        insert areaOfExp6;	
        Student_Expertise__c studExprtse6 = new  Student_Expertise__c();
        studExprtse6.Opportunity__c = opp.id;
        studExprtse6.IsAchieved__c= True;
        studExprtse6.Is_Audit_History_Created__c = False;
        studExprtse6.Pseudo_CE__c = 4;
        studExprtse6.Area_of_Expertise__c=areaOfExp6.id;
        studExprtse6.Outcome_Category__c = null;
        studExprtse6.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse6);
        
        Area_of_Expertise__c areaOfExp7 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Core',Level__c ='4000');
        insert areaOfExp7;	
        Student_Expertise__c studExprtse7 = new  Student_Expertise__c();
        studExprtse7.Opportunity__c = opp.id;
        studExprtse7.IsAchieved__c= True;
        studExprtse7.Is_Audit_History_Created__c = False;
        studExprtse7.Pseudo_CE__c = 4;
        studExprtse7.Area_of_Expertise__c=areaOfExp7.id;
        studExprtse7.Outcome_Category__c = null;
        studExprtse7.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse7);
        
        Area_of_Expertise__c areaOfExp8 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Core',Level__c ='4000');
        insert areaOfExp8;	
        Student_Expertise__c studExprtse8 = new  Student_Expertise__c();
        studExprtse8.Opportunity__c = opp.id;
        studExprtse8.IsAchieved__c= True;
        studExprtse8.Is_Audit_History_Created__c = False;
        studExprtse8.Pseudo_CE__c = 4;
        studExprtse8.Area_of_Expertise__c=areaOfExp8.id;
        studExprtse8.Outcome_Category__c = null;
        studExprtse8.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse8);        
         
        Area_of_Expertise__c areaOfExp9 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Core',Level__c ='4000');
        insert areaOfExp9;
        Student_Expertise__c studExprtse9 = new  Student_Expertise__c();
        studExprtse9.Opportunity__c = opp.id;
        studExprtse9.IsAchieved__c= True;
        studExprtse9.Is_Audit_History_Created__c = False;
        studExprtse9.Pseudo_CE__c = 4;
        studExprtse9.Area_of_Expertise__c=areaOfExp9.id;
        studExprtse9.Outcome_Category__c = null;
        studExprtse9.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse9);
        
          Area_of_Expertise__c areaOfExp10 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Core',Level__c ='4000');
        insert areaOfExp10;
        Student_Expertise__c studExprtse11 = new  Student_Expertise__c();
        studExprtse11.Opportunity__c = opp.id;
        studExprtse11.IsAchieved__c= True;
        studExprtse11.Is_Audit_History_Created__c = False;
        studExprtse11.Pseudo_CE__c = 4;
        studExprtse11.Area_of_Expertise__c=areaOfExp10.id;
        studExprtse11.Outcome_Category__c = null;
        studExprtse11.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse11);
        
        insert studExprtiseLst;  
        
        Test.startTest();
        BatchCreateStudentAuditHistory objB = new BatchCreateStudentAuditHistory();    
        String sch = '3 4 2 5 6 ?'; 
        system.schedule('BatchCreateStudentAuditHistory1', sch, objB); 
        
        Test.stopTest();
    }
    @isTest  static  void testMethodTwo() {
        setup();
        
        aoeLst = new List<Area_of_Expertise__c>();
        
        Area_of_Expertise__c areaOfExp1 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExp1.Level__c = '1000';
        areaOfExp1.Category__c = 'Core';
        areaOfExp1.Pseudo_Course__c = true;
        aoeLst.add(areaOfExp1); 
         
        Area_of_Expertise__c areaOfExp2 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExp2.Level__c = '1000';
        areaOfExp2.Category__c = 'Core';
        areaOfExp2.Pseudo_Course__c = true;
        aoeLst.add(areaOfExp2); 
        
        
        insert aoeLst;
        
        
        studExprtiseLst = new List<Student_Expertise__c>();
        
        Student_Expertise__c studExprtse1 = new  Student_Expertise__c();
        studExprtse1.Opportunity__c = opp.id;
        studExprtse1.IsAchieved__c= True;
        studExprtse1.Is_Audit_History_Created__c = False;
        studExprtse1.Pseudo_CE__c = 4;
        studExprtse1.Area_of_Expertise__c=areaOfExp1.id;
        studExprtse1.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse1);
        
        
        Student_Expertise__c studExprtse2 = new  Student_Expertise__c();
        studExprtse2.Opportunity__c = opp.id;
        studExprtse2.IsAchieved__c= True;
        studExprtse2.Is_Audit_History_Created__c = False;
        studExprtse2.Pseudo_CE__c = 4;
        studExprtse2.Area_of_Expertise__c=areaOfExp2.id;
        studExprtse2.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse2);
        
        
        Area_of_Expertise__c areaOfExp3 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Core',Level__c ='1000');
        insert areaOfExp3;	
        Student_Expertise__c studExprtse3 = new  Student_Expertise__c();
        studExprtse3.Opportunity__c = opp.id;
        studExprtse3.IsAchieved__c= True;
        studExprtse3.Is_Audit_History_Created__c = False;
        studExprtse3.Pseudo_CE__c = 4;
        studExprtse3.Area_of_Expertise__c=areaOfExp3.id;
        studExprtse3.Outcome_Category__c = null;
        studExprtse3.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse3);
        
        Area_of_Expertise__c areaOfExp4 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Core',Level__c ='1000');
        insert areaOfExp4;	
        Student_Expertise__c studExprtse4 = new  Student_Expertise__c();
        studExprtse4.Opportunity__c = opp.id;
        studExprtse4.IsAchieved__c= True;
        studExprtse4.Is_Audit_History_Created__c = False;
        studExprtse4.Pseudo_CE__c = 4;
        studExprtse4.Area_of_Expertise__c=areaOfExp4.id;
        studExprtse4.Outcome_Category__c = null;
        studExprtse4.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse4);
        
        Area_of_Expertise__c areaOfExp5 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Core',Level__c ='1000');
        insert areaOfExp5;	
        Student_Expertise__c studExprtse5 = new  Student_Expertise__c();
        studExprtse5.Opportunity__c = opp.id;
        studExprtse5.IsAchieved__c= True;
        studExprtse5.Is_Audit_History_Created__c = False;
        studExprtse5.Pseudo_CE__c = 4;
        studExprtse5.Area_of_Expertise__c=areaOfExp5.id;
        studExprtse5.Outcome_Category__c = null;
        studExprtse5.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse5);
        
        Area_of_Expertise__c areaOfExp6 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Core',Level__c ='1000');
        insert areaOfExp6;	
        Student_Expertise__c studExprtse6 = new  Student_Expertise__c();
        studExprtse6.Opportunity__c = opp.id;
        studExprtse6.IsAchieved__c= True;
        studExprtse6.Is_Audit_History_Created__c = False;
        studExprtse6.Pseudo_CE__c = 4;
        studExprtse6.Area_of_Expertise__c=areaOfExp6.id;
        studExprtse6.Outcome_Category__c = null;
        studExprtse6.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse6);
        
        Area_of_Expertise__c areaOfExp7 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Core',Level__c ='1000');
        insert areaOfExp7;	
        Student_Expertise__c studExprtse7 = new  Student_Expertise__c();
        studExprtse7.Opportunity__c = opp.id;
        studExprtse7.IsAchieved__c= True;
        studExprtse7.Is_Audit_History_Created__c = False;
        studExprtse7.Pseudo_CE__c = 4;
        studExprtse7.Area_of_Expertise__c=areaOfExp7.id;
        studExprtse7.Outcome_Category__c = null;
        studExprtse7.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse7);
        
        Area_of_Expertise__c areaOfExp8 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Core',Level__c ='1000');
        insert areaOfExp8;	
        Student_Expertise__c studExprtse8 = new  Student_Expertise__c();
        studExprtse8.Opportunity__c = opp.id;
        studExprtse8.IsAchieved__c= True;
        studExprtse8.Is_Audit_History_Created__c = False;
        studExprtse8.Pseudo_CE__c = 4;
        studExprtse8.Area_of_Expertise__c=areaOfExp8.id;
        studExprtse8.Outcome_Category__c = null;
        studExprtse8.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse8);        
         
        Area_of_Expertise__c areaOfExp9 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Core',Level__c ='1000');
        insert areaOfExp9;
        Student_Expertise__c studExprtse9 = new  Student_Expertise__c();
        studExprtse9.Opportunity__c = opp.id;
        studExprtse9.IsAchieved__c= True;
        studExprtse9.Is_Audit_History_Created__c = False;
        studExprtse9.Pseudo_CE__c = 4;
        studExprtse9.Area_of_Expertise__c=areaOfExp9.id;
        studExprtse9.Outcome_Category__c = null;
        studExprtse9.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse9);
        
          Area_of_Expertise__c areaOfExp10 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Core',Level__c ='1000');
        insert areaOfExp10;
        Student_Expertise__c studExprtse11 = new  Student_Expertise__c();
        studExprtse11.Opportunity__c = opp.id;
        studExprtse11.IsAchieved__c= True;
        studExprtse11.Is_Audit_History_Created__c = False;
        studExprtse11.Pseudo_CE__c = 4;
        studExprtse11.Area_of_Expertise__c=areaOfExp10.id;
        studExprtse11.Outcome_Category__c = null;
        studExprtse11.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse11);
        
        insert studExprtiseLst;   
        
        Test.startTest();
        BatchCreateStudentAuditHistory objB = new BatchCreateStudentAuditHistory();    
        String sch = '3 4 2 5 6 ?'; 
        system.schedule('BatchCreateStudentAuditHistory1', sch, objB); 
        
        Test.stopTest();
    }
    @isTest  static  void testMethodThree() {
        setup();
        
        
        

        aoeLst = new List<Area_of_Expertise__c>();
        
        Area_of_Expertise__c areaOfExp1 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExp1.Level__c = '1000';
        areaOfExp1.Category__c = 'Concentration';
        areaOfExp1.Pseudo_Course__c = true;
        aoeLst.add(areaOfExp1); 
         
        Area_of_Expertise__c areaOfExp2 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExp2.Level__c = '1000';
        areaOfExp2.Category__c = 'Concentration';
        areaOfExp2.Pseudo_Course__c = true;
        aoeLst.add(areaOfExp2); 
        
        
        insert aoeLst;
        
        
        studExprtiseLst = new List<Student_Expertise__c>();
        
        Student_Expertise__c studExprtse1 = new  Student_Expertise__c();
        studExprtse1.Opportunity__c = opp.id;
        studExprtse1.IsAchieved__c= True;
        studExprtse1.Is_Audit_History_Created__c = False;
        studExprtse1.Pseudo_CE__c = 4;
        studExprtse1.Area_of_Expertise__c=areaOfExp1.id;
        studExprtse1.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse1);
        
        
        Student_Expertise__c studExprtse2 = new  Student_Expertise__c();
        studExprtse2.Opportunity__c = opp.id;
        studExprtse2.IsAchieved__c= True;
        studExprtse2.Is_Audit_History_Created__c = False;
        studExprtse2.Pseudo_CE__c = 4;
        studExprtse2.Area_of_Expertise__c=areaOfExp2.id;
        studExprtse2.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse2);
        
        
        Area_of_Expertise__c areaOfExp3 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Concentration',Level__c ='1000');
        insert areaOfExp3;	
        Student_Expertise__c studExprtse3 = new  Student_Expertise__c();
        studExprtse3.Opportunity__c = opp.id;
        studExprtse3.IsAchieved__c= True;
        studExprtse3.Is_Audit_History_Created__c = False;
        studExprtse3.Pseudo_CE__c = 4;
        studExprtse3.Area_of_Expertise__c=areaOfExp3.id;
        studExprtse3.Outcome_Category__c = null;
        studExprtse3.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse3);
        
        Area_of_Expertise__c areaOfExp4 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Concentration',Level__c ='1000');
        insert areaOfExp4;	
        Student_Expertise__c studExprtse4 = new  Student_Expertise__c();
        studExprtse4.Opportunity__c = opp.id;
        studExprtse4.IsAchieved__c= True;
        studExprtse4.Is_Audit_History_Created__c = False;
        studExprtse4.Pseudo_CE__c = 4;
        studExprtse4.Area_of_Expertise__c=areaOfExp4.id;
        studExprtse4.Outcome_Category__c = null;
        studExprtse4.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse4);
        
        Area_of_Expertise__c areaOfExp5 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Concentration',Level__c ='1000');
        insert areaOfExp5;	
        Student_Expertise__c studExprtse5 = new  Student_Expertise__c();
        studExprtse5.Opportunity__c = opp.id;
        studExprtse5.IsAchieved__c= True;
        studExprtse5.Is_Audit_History_Created__c = False;
        studExprtse5.Pseudo_CE__c = 4;
        studExprtse5.Area_of_Expertise__c=areaOfExp5.id;
        studExprtse5.Outcome_Category__c = null;
        studExprtse5.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse5);
        
        Area_of_Expertise__c areaOfExp6 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Concentration',Level__c ='1000');
        insert areaOfExp6;	
        Student_Expertise__c studExprtse6 = new  Student_Expertise__c();
        studExprtse6.Opportunity__c = opp.id;
        studExprtse6.IsAchieved__c= True;
        studExprtse6.Is_Audit_History_Created__c = False;
        studExprtse6.Pseudo_CE__c = 4;
        studExprtse6.Area_of_Expertise__c=areaOfExp6.id;
        studExprtse6.Outcome_Category__c = null;
        studExprtse6.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse6);
        
        Area_of_Expertise__c areaOfExp7 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Concentration',Level__c ='1000');
        insert areaOfExp7;	
        Student_Expertise__c studExprtse7 = new  Student_Expertise__c();
        studExprtse7.Opportunity__c = opp.id;
        studExprtse7.IsAchieved__c= True;
        studExprtse7.Is_Audit_History_Created__c = False;
        studExprtse7.Pseudo_CE__c = 4;
        studExprtse7.Area_of_Expertise__c=areaOfExp7.id;
        studExprtse7.Outcome_Category__c = null;
        studExprtse7.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse7);
        
        
        
        insert studExprtiseLst;   
        
        
        
     
        
        Test.startTest();
        BatchCreateStudentAuditHistory objB = new BatchCreateStudentAuditHistory();    
        String sch = '3 4 2 5 6 ?'; 
        system.schedule('BatchCreateStudentAuditHistory1', sch, objB); 
        
        Test.stopTest();
    }
    @isTest  static  void testMethodfour() {
        setup();
        
        
        

        aoeLst = new List<Area_of_Expertise__c>();
        
        Area_of_Expertise__c areaOfExp1 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExp1.Level__c = '1000';
        areaOfExp1.Category__c = 'General Elective';
        areaOfExp1.Pseudo_Course__c = true;
        aoeLst.add(areaOfExp1); 
         
        Area_of_Expertise__c areaOfExp2 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExp2.Level__c = '1000';
        areaOfExp2.Category__c = 'General Elective';
        areaOfExp2.Pseudo_Course__c = true;
        aoeLst.add(areaOfExp2); 
        
        
        insert aoeLst;
        
        
        studExprtiseLst = new List<Student_Expertise__c>();
        
        Student_Expertise__c studExprtse1 = new  Student_Expertise__c();
        studExprtse1.Opportunity__c = opp.id;
        studExprtse1.IsAchieved__c= True;
        studExprtse1.Is_Audit_History_Created__c = False;
        studExprtse1.Pseudo_CE__c = 4;
        studExprtse1.Area_of_Expertise__c=areaOfExp1.id;
        studExprtse1.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse1);
        
        
        Student_Expertise__c studExprtse2 = new  Student_Expertise__c();
        studExprtse2.Opportunity__c = opp.id;
        studExprtse2.IsAchieved__c= True;
        studExprtse2.Is_Audit_History_Created__c = False;
        studExprtse2.Pseudo_CE__c = 4;
        studExprtse2.Area_of_Expertise__c=areaOfExp2.id;
        studExprtse2.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse2);
        
        
        Area_of_Expertise__c areaOfExp3 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Elective',Level__c ='1000');
        insert areaOfExp3;	
        Student_Expertise__c studExprtse3 = new  Student_Expertise__c();
        studExprtse3.Opportunity__c = opp.id;
        studExprtse3.IsAchieved__c= True;
        studExprtse3.Is_Audit_History_Created__c = False;
        studExprtse3.Pseudo_CE__c = 4;
        studExprtse3.Area_of_Expertise__c=areaOfExp3.id;
        studExprtse3.Outcome_Category__c = null;
        studExprtse3.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse3);
        
        Area_of_Expertise__c areaOfExp4 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Elective',Level__c ='1000');
        insert areaOfExp4;	
        Student_Expertise__c studExprtse4 = new  Student_Expertise__c();
        studExprtse4.Opportunity__c = opp.id;
        studExprtse4.IsAchieved__c= True;
        studExprtse4.Is_Audit_History_Created__c = False;
        studExprtse4.Pseudo_CE__c = 4;
        studExprtse4.Area_of_Expertise__c=areaOfExp4.id;
        studExprtse4.Outcome_Category__c = null;
        studExprtse4.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse4);
        
        Area_of_Expertise__c areaOfExp5 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Elective',Level__c ='1000');
        insert areaOfExp5;	
        Student_Expertise__c studExprtse5 = new  Student_Expertise__c();
        studExprtse5.Opportunity__c = opp.id;
        studExprtse5.IsAchieved__c= True;
        studExprtse5.Is_Audit_History_Created__c = False;
        studExprtse5.Pseudo_CE__c = 4;
        studExprtse5.Area_of_Expertise__c=areaOfExp5.id;
        studExprtse5.Outcome_Category__c = null;
        studExprtse5.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse5);
        
        Area_of_Expertise__c areaOfExp6 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Elective',Level__c ='1000');
        insert areaOfExp6;	
        Student_Expertise__c studExprtse6 = new  Student_Expertise__c();
        studExprtse6.Opportunity__c = opp.id;
        studExprtse6.IsAchieved__c= True;
        studExprtse6.Is_Audit_History_Created__c = False;
        studExprtse6.Pseudo_CE__c = 4;
        studExprtse6.Area_of_Expertise__c=areaOfExp6.id;
        studExprtse6.Outcome_Category__c = null;
        studExprtse6.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse6);
        
        Area_of_Expertise__c areaOfExp7 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Elective',Level__c ='1000');
        insert areaOfExp7;	
        Student_Expertise__c studExprtse7 = new  Student_Expertise__c();
        studExprtse7.Opportunity__c = opp.id;
        studExprtse7.IsAchieved__c= True;
        studExprtse7.Is_Audit_History_Created__c = False;
        studExprtse7.Pseudo_CE__c = 4;
        studExprtse7.Area_of_Expertise__c=areaOfExp7.id;
        studExprtse7.Outcome_Category__c = null;
        studExprtse7.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse7);
        
        
        
        insert studExprtiseLst;   
        
        
        
                
        Test.startTest();
        BatchCreateStudentAuditHistory objB = new BatchCreateStudentAuditHistory();    
        String sch = '3 4 2 5 6 ?'; 
        system.schedule('BatchCreateStudentAuditHistory1', sch, objB); 
        
        Test.stopTest();
    }
    @isTest  static  void testMethodFive() {
        setup();
        aoeLst = new List<Area_of_Expertise__c>();
        
        Area_of_Expertise__c areaOfExp1 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExp1.Level__c = '1000';
        areaOfExp1.Category__c = 'General Education';
        areaOfExp1.Subject_Area__c = 'Arts and Humanities';
        areaOfExp1.Pseudo_Course__c = true;
        aoeLst.add(areaOfExp1); 
        
        Area_of_Expertise__c areaOfExp2 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExp2.Level__c = '1000';
        areaOfExp1.Category__c = 'General Education';
        areaOfExp1.Subject_Area__c = 'Arts and Humanities';        
        areaOfExp2.Pseudo_Course__c = true;
        aoeLst.add(areaOfExp2); 
        
        
        insert aoeLst;
        
        
        studExprtiseLst = new List<Student_Expertise__c>();
        
        Student_Expertise__c studExprtse1 = new  Student_Expertise__c();
        studExprtse1.Opportunity__c = opp.id;
        studExprtse1.IsAchieved__c= True;
        studExprtse1.Is_Audit_History_Created__c = False;
        studExprtse1.Pseudo_CE__c = 4;
        studExprtse1.Area_of_Expertise__c=areaOfExp1.id;
        studExprtse1.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse1);
        
        
        Student_Expertise__c studExprtse2 = new  Student_Expertise__c();
        studExprtse2.Opportunity__c = opp.id;
        studExprtse2.IsAchieved__c= True;
        studExprtse2.Is_Audit_History_Created__c = False;
        studExprtse2.Pseudo_CE__c = 4;
        studExprtse2.Area_of_Expertise__c=areaOfExp2.id;
        studExprtse2.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse2);
        
        
        Area_of_Expertise__c areaOfExp3 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education', Pseudo_Course__c=true, Subject_Area__c = 'Arts and Humanities',Level__c ='1000');
        insert areaOfExp3;	
        Student_Expertise__c studExprtse3 = new  Student_Expertise__c();
        studExprtse3.Opportunity__c = opp.id;
        studExprtse3.IsAchieved__c= True;
        studExprtse3.Is_Audit_History_Created__c = False;
        studExprtse3.Pseudo_CE__c = 4;
        studExprtse3.Area_of_Expertise__c=areaOfExp3.id;
        studExprtse3.Outcome_Category__c = null;
        studExprtse3.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse3);
        
        Area_of_Expertise__c areaOfExp4 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education', Pseudo_Course__c=true,Subject_Area__c = 'Arts and Humanities',Level__c ='1000');
        insert areaOfExp4;	
        Student_Expertise__c studExprtse4 = new  Student_Expertise__c();
        studExprtse4.Opportunity__c = opp.id;
        studExprtse4.IsAchieved__c= True;
        studExprtse4.Is_Audit_History_Created__c = False;
        studExprtse4.Pseudo_CE__c = 4;
        studExprtse4.Area_of_Expertise__c=areaOfExp4.id;
        studExprtse4.Outcome_Category__c = null;
        studExprtse4.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse4);
        
        Area_of_Expertise__c areaOfExp5 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education' ,Pseudo_Course__c=true,Subject_Area__c = 'Arts and Humanities',Level__c ='1000');
        insert areaOfExp5;	
        Student_Expertise__c studExprtse5 = new  Student_Expertise__c();
        studExprtse5.Opportunity__c = opp.id;
        studExprtse5.IsAchieved__c= True;
        studExprtse5.Is_Audit_History_Created__c = False;
        studExprtse5.Pseudo_CE__c = 4;
        studExprtse5.Area_of_Expertise__c=areaOfExp5.id;
        studExprtse5.Outcome_Category__c = null;
        studExprtse5.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse5);
        
        Area_of_Expertise__c areaOfExp6 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education', Pseudo_Course__c=true,Subject_Area__c = 'Arts and Humanities',Level__c ='1000');
        insert areaOfExp6;	
        Student_Expertise__c studExprtse6 = new  Student_Expertise__c();
        studExprtse6.Opportunity__c = opp.id;
        studExprtse6.IsAchieved__c= True;
        studExprtse6.Is_Audit_History_Created__c = False;
        studExprtse6.Pseudo_CE__c = 4;
        studExprtse6.Area_of_Expertise__c=areaOfExp6.id;
        studExprtse6.Outcome_Category__c = null;
        studExprtse6.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse6);
        
        Area_of_Expertise__c areaOfExp7 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education', Pseudo_Course__c=true,Subject_Area__c = 'Arts and Humanities',Level__c ='1000');
        insert areaOfExp7;	
        Student_Expertise__c studExprtse7 = new  Student_Expertise__c();
        studExprtse7.Opportunity__c = opp.id;
        studExprtse7.IsAchieved__c= True;
        studExprtse7.Is_Audit_History_Created__c = False;
        studExprtse7.Pseudo_CE__c = 4;
        studExprtse7.Area_of_Expertise__c=areaOfExp7.id;
        studExprtse7.Outcome_Category__c = null;
        studExprtse7.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse7);
        
        
        
        insert studExprtiseLst;  
        
        
        
        
        
        Test.startTest();
        BatchCreateStudentAuditHistory objB = new BatchCreateStudentAuditHistory();    
        String sch = '3 4 2 5 6 ?'; 
        system.schedule('BatchCreateStudentAuditHistory1', sch, objB); 
        
        Test.stopTest();
    }  
    @isTest  static  void testMethodSix() {
        setup();
        
         aoeLst = new List<Area_of_Expertise__c>();
        
        Area_of_Expertise__c areaOfExp1 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExp1.Level__c = '1000';
        areaOfExp1.Category__c = 'General Education';
        areaOfExp1.Subject_Area__c = 'Mathematics/Natural Sciences';
        areaOfExp1.Pseudo_Course__c = true;
        aoeLst.add(areaOfExp1); 
        
        Area_of_Expertise__c areaOfExp2 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExp2.Level__c = '1000';
        areaOfExp1.Category__c = 'General Education';
        areaOfExp1.Subject_Area__c = 'Mathematics/Natural Sciences';        
        areaOfExp2.Pseudo_Course__c = true;
        aoeLst.add(areaOfExp2); 
        
        
        insert aoeLst;
        
        
        studExprtiseLst = new List<Student_Expertise__c>();
        
        Student_Expertise__c studExprtse1 = new  Student_Expertise__c();
        studExprtse1.Opportunity__c = opp.id;
        studExprtse1.IsAchieved__c= True;
        studExprtse1.Is_Audit_History_Created__c = False;
        studExprtse1.Pseudo_CE__c = 4;
        studExprtse1.Area_of_Expertise__c=areaOfExp1.id;
        studExprtse1.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse1);
        
        
        Student_Expertise__c studExprtse2 = new  Student_Expertise__c();
        studExprtse2.Opportunity__c = opp.id;
        studExprtse2.IsAchieved__c= True;
        studExprtse2.Is_Audit_History_Created__c = False;
        studExprtse2.Pseudo_CE__c = 4;
        studExprtse2.Area_of_Expertise__c=areaOfExp2.id;
        studExprtse2.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse2);
        
        
        Area_of_Expertise__c areaOfExp3 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education', Pseudo_Course__c=true, Subject_Area__c = 'Mathematics/Natural Sciences',Level__c ='1000');
        insert areaOfExp3;	
        Student_Expertise__c studExprtse3 = new  Student_Expertise__c();
        studExprtse3.Opportunity__c = opp.id;
        studExprtse3.IsAchieved__c= True;
        studExprtse3.Is_Audit_History_Created__c = False;
        studExprtse3.Pseudo_CE__c = 4;
        studExprtse3.Area_of_Expertise__c=areaOfExp3.id;
        studExprtse3.Outcome_Category__c = null;
        studExprtse3.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse3);
        
        Area_of_Expertise__c areaOfExp4 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education', Pseudo_Course__c=true,Subject_Area__c = 'Mathematics/Natural Sciences',Level__c ='1000');
        insert areaOfExp4;	
        Student_Expertise__c studExprtse4 = new  Student_Expertise__c();
        studExprtse4.Opportunity__c = opp.id;
        studExprtse4.IsAchieved__c= True;
        studExprtse4.Is_Audit_History_Created__c = False;
        studExprtse4.Pseudo_CE__c = 4;
        studExprtse4.Area_of_Expertise__c=areaOfExp4.id;
        studExprtse4.Outcome_Category__c = null;
        studExprtse4.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse4);
        
        Area_of_Expertise__c areaOfExp5 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education' ,Pseudo_Course__c=true,Subject_Area__c = 'Mathematics/Natural Sciences',Level__c ='1000');
        insert areaOfExp5;	
        Student_Expertise__c studExprtse5 = new  Student_Expertise__c();
        studExprtse5.Opportunity__c = opp.id;
        studExprtse5.IsAchieved__c= True;
        studExprtse5.Is_Audit_History_Created__c = False;
        studExprtse5.Pseudo_CE__c = 4;
        studExprtse5.Area_of_Expertise__c=areaOfExp5.id;
        studExprtse5.Outcome_Category__c = null;
        studExprtse5.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse5);
        
        Area_of_Expertise__c areaOfExp6 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education', Pseudo_Course__c=true,Subject_Area__c = 'Mathematics/Natural Sciences',Level__c ='1000');
        insert areaOfExp6;	
        Student_Expertise__c studExprtse6 = new  Student_Expertise__c();
        studExprtse6.Opportunity__c = opp.id;
        studExprtse6.IsAchieved__c= True;
        studExprtse6.Is_Audit_History_Created__c = False;
        studExprtse6.Pseudo_CE__c = 4;
        studExprtse6.Area_of_Expertise__c=areaOfExp6.id;
        studExprtse6.Outcome_Category__c = null;
        studExprtse6.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse6);
        
        Area_of_Expertise__c areaOfExp7 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education', Pseudo_Course__c=true,Subject_Area__c = 'Mathematics/Natural Sciences',Level__c ='1000');
        insert areaOfExp7;	
        Student_Expertise__c studExprtse7 = new  Student_Expertise__c();
        studExprtse7.Opportunity__c = opp.id;
        studExprtse7.IsAchieved__c= True;
        studExprtse7.Is_Audit_History_Created__c = False;
        studExprtse7.Pseudo_CE__c = 4;
        studExprtse7.Area_of_Expertise__c=areaOfExp7.id;
        studExprtse7.Outcome_Category__c = null;
        studExprtse7.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse7);
        
        
        
        insert studExprtiseLst;  
        
        
        
        
        Test.startTest();
        BatchCreateStudentAuditHistory objB = new BatchCreateStudentAuditHistory();    
        String sch = '3 4 2 5 6 ?'; 
        system.schedule('BatchCreateStudentAuditHistory1', sch, objB); 
        
        Test.stopTest();
    }  
    @isTest  static  void testMethodSeven() {
        setup();
          aoeLst = new List<Area_of_Expertise__c>();
        
        Area_of_Expertise__c areaOfExp1 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExp1.Level__c = '1000';
        areaOfExp1.Category__c = 'General Education';
        areaOfExp1.Subject_Area__c = 'Social Sciences';
        areaOfExp1.Pseudo_Course__c = true;
        aoeLst.add(areaOfExp1); 
        
        Area_of_Expertise__c areaOfExp2 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExp2.Level__c = '1000';
        areaOfExp1.Category__c = 'General Education';
        areaOfExp1.Subject_Area__c = 'Social Sciences';        
        areaOfExp2.Pseudo_Course__c = true;
        aoeLst.add(areaOfExp2); 
        
        
        insert aoeLst;
        
        
        studExprtiseLst = new List<Student_Expertise__c>();
        
        Student_Expertise__c studExprtse1 = new  Student_Expertise__c();
        studExprtse1.Opportunity__c = opp.id;
        studExprtse1.IsAchieved__c= True;
        studExprtse1.Is_Audit_History_Created__c = False;
        studExprtse1.Pseudo_CE__c = 4;
        studExprtse1.Area_of_Expertise__c=areaOfExp1.id;
        studExprtse1.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse1);
        
        
        Student_Expertise__c studExprtse2 = new  Student_Expertise__c();
        studExprtse2.Opportunity__c = opp.id;
        studExprtse2.IsAchieved__c= True;
        studExprtse2.Is_Audit_History_Created__c = False;
        studExprtse2.Pseudo_CE__c = 4;
        studExprtse2.Area_of_Expertise__c=areaOfExp2.id;
        studExprtse2.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse2);
        
        
        Area_of_Expertise__c areaOfExp3 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education', Pseudo_Course__c=true, Subject_Area__c = 'Social Sciences',Level__c ='1000');
        insert areaOfExp3;	
        Student_Expertise__c studExprtse3 = new  Student_Expertise__c();
        studExprtse3.Opportunity__c = opp.id;
        studExprtse3.IsAchieved__c= True;
        studExprtse3.Is_Audit_History_Created__c = False;
        studExprtse3.Pseudo_CE__c = 4;
        studExprtse3.Area_of_Expertise__c=areaOfExp3.id;
        studExprtse3.Outcome_Category__c = null;
        studExprtse3.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse3);
        
        Area_of_Expertise__c areaOfExp4 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education', Pseudo_Course__c=true,Subject_Area__c = 'Social Sciences',Level__c ='1000');
        insert areaOfExp4;	
        Student_Expertise__c studExprtse4 = new  Student_Expertise__c();
        studExprtse4.Opportunity__c = opp.id;
        studExprtse4.IsAchieved__c= True;
        studExprtse4.Is_Audit_History_Created__c = False;
        studExprtse4.Pseudo_CE__c = 4;
        studExprtse4.Area_of_Expertise__c=areaOfExp4.id;
        studExprtse4.Outcome_Category__c = null;
        studExprtse4.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse4);
        
        Area_of_Expertise__c areaOfExp5 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education' ,Pseudo_Course__c=true,Subject_Area__c = 'Social Sciences',Level__c ='1000');
        insert areaOfExp5;	
        Student_Expertise__c studExprtse5 = new  Student_Expertise__c();
        studExprtse5.Opportunity__c = opp.id;
        studExprtse5.IsAchieved__c= True;
        studExprtse5.Is_Audit_History_Created__c = False;
        studExprtse5.Pseudo_CE__c = 4;
        studExprtse5.Area_of_Expertise__c=areaOfExp5.id;
        studExprtse5.Outcome_Category__c = null;
        studExprtse5.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse5);
        
        Area_of_Expertise__c areaOfExp6 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education', Pseudo_Course__c=true,Subject_Area__c = 'Social Sciences',Level__c ='1000');
        insert areaOfExp6;	
        Student_Expertise__c studExprtse6 = new  Student_Expertise__c();
        studExprtse6.Opportunity__c = opp.id;
        studExprtse6.IsAchieved__c= True;
        studExprtse6.Is_Audit_History_Created__c = False;
        studExprtse6.Pseudo_CE__c = 4;
        studExprtse6.Area_of_Expertise__c=areaOfExp6.id;
        studExprtse6.Outcome_Category__c = null;
        studExprtse6.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse6);
        
        Area_of_Expertise__c areaOfExp7 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education', Pseudo_Course__c=true,Subject_Area__c = 'Social Sciences',Level__c ='1000');
        insert areaOfExp7;	
        Student_Expertise__c studExprtse7 = new  Student_Expertise__c();
        studExprtse7.Opportunity__c = opp.id;
        studExprtse7.IsAchieved__c= True;
        studExprtse7.Is_Audit_History_Created__c = False;
        studExprtse7.Pseudo_CE__c = 4;
        studExprtse7.Area_of_Expertise__c=areaOfExp7.id;
        studExprtse7.Outcome_Category__c = null;
        studExprtse7.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse7);
        
        
        
        insert studExprtiseLst;  
        
        Test.startTest();
        BatchCreateStudentAuditHistory objB = new BatchCreateStudentAuditHistory();    
        String sch = '3 4 2 5 6 ?'; 
        system.schedule('BatchCreateStudentAuditHistory1', sch, objB); 
        
        Test.stopTest();
    } 
    @isTest  static  void testMethodEight() {
        setup();
        
         aoeLst = new List<Area_of_Expertise__c>();
        
        Area_of_Expertise__c areaOfExp1 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExp1.Level__c = '1000';
        areaOfExp1.Category__c = 'General Education';
        areaOfExp1.Subject_Area__c = 'Written and Oral Communication';
        areaOfExp1.Pseudo_Course__c = true;
        aoeLst.add(areaOfExp1); 
        
        Area_of_Expertise__c areaOfExp2 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExp2.Level__c = '1000';
        areaOfExp1.Category__c = 'General Education';
        areaOfExp1.Subject_Area__c = 'Written and Oral Communication';        
        areaOfExp2.Pseudo_Course__c = true;
        aoeLst.add(areaOfExp2); 
        
        
        insert aoeLst;
        
        
        studExprtiseLst = new List<Student_Expertise__c>();
        
        Student_Expertise__c studExprtse1 = new  Student_Expertise__c();
        studExprtse1.Opportunity__c = opp.id;
        studExprtse1.IsAchieved__c= True;
        studExprtse1.Is_Audit_History_Created__c = False;
        studExprtse1.Pseudo_CE__c = 4;
        studExprtse1.Area_of_Expertise__c=areaOfExp1.id;
        studExprtse1.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse1);
        
        
        Student_Expertise__c studExprtse2 = new  Student_Expertise__c();
        studExprtse2.Opportunity__c = opp.id;
        studExprtse2.IsAchieved__c= True;
        studExprtse2.Is_Audit_History_Created__c = False;
        studExprtse2.Pseudo_CE__c = 4;
        studExprtse2.Area_of_Expertise__c=areaOfExp2.id;
        studExprtse2.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse2);
        
        
        Area_of_Expertise__c areaOfExp3 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education', Pseudo_Course__c=true, Subject_Area__c = 'Written and Oral Communication',Level__c ='1000');
        insert areaOfExp3;	
        Student_Expertise__c studExprtse3 = new  Student_Expertise__c();
        studExprtse3.Opportunity__c = opp.id;
        studExprtse3.IsAchieved__c= True;
        studExprtse3.Is_Audit_History_Created__c = False;
        studExprtse3.Pseudo_CE__c = 4;
        studExprtse3.Area_of_Expertise__c=areaOfExp3.id;
        studExprtse3.Outcome_Category__c = null;
        studExprtse3.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse3);
        
        Area_of_Expertise__c areaOfExp4 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education', Pseudo_Course__c=true,Subject_Area__c = 'Written and Oral Communication',Level__c ='1000');
        insert areaOfExp4;	
        Student_Expertise__c studExprtse4 = new  Student_Expertise__c();
        studExprtse4.Opportunity__c = opp.id;
        studExprtse4.IsAchieved__c= True;
        studExprtse4.Is_Audit_History_Created__c = False;
        studExprtse4.Pseudo_CE__c = 4;
        studExprtse4.Area_of_Expertise__c=areaOfExp4.id;
        studExprtse4.Outcome_Category__c = null;
        studExprtse4.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse4);
        
        Area_of_Expertise__c areaOfExp5 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education' ,Pseudo_Course__c=true,Subject_Area__c = 'Written and Oral Communication',Level__c ='1000');
        insert areaOfExp5;	
        Student_Expertise__c studExprtse5 = new  Student_Expertise__c();
        studExprtse5.Opportunity__c = opp.id;
        studExprtse5.IsAchieved__c= True;
        studExprtse5.Is_Audit_History_Created__c = False;
        studExprtse5.Pseudo_CE__c = 4;
        studExprtse5.Area_of_Expertise__c=areaOfExp5.id;
        studExprtse5.Outcome_Category__c = null;
        studExprtse5.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse5);
        
        Area_of_Expertise__c areaOfExp6 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education', Pseudo_Course__c=true,Subject_Area__c = 'Written and Oral Communication',Level__c ='1000');
        insert areaOfExp6;	
        Student_Expertise__c studExprtse6 = new  Student_Expertise__c();
        studExprtse6.Opportunity__c = opp.id;
        studExprtse6.IsAchieved__c= True;
        studExprtse6.Is_Audit_History_Created__c = False;
        studExprtse6.Pseudo_CE__c = 4;
        studExprtse6.Area_of_Expertise__c=areaOfExp6.id;
        studExprtse6.Outcome_Category__c = null;
        studExprtse6.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse6);
        
        Area_of_Expertise__c areaOfExp7 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education', Pseudo_Course__c=true,Subject_Area__c = 'Written and Oral Communication',Level__c ='1000');
        insert areaOfExp7;	
        Student_Expertise__c studExprtse7 = new  Student_Expertise__c();
        studExprtse7.Opportunity__c = opp.id;
        studExprtse7.IsAchieved__c= True;
        studExprtse7.Is_Audit_History_Created__c = False;
        studExprtse7.Pseudo_CE__c = 4;
        studExprtse7.Area_of_Expertise__c=areaOfExp7.id;
        studExprtse7.Outcome_Category__c = null;
        studExprtse7.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse7);
        
        
        
        insert studExprtiseLst;  
        
        
        Test.startTest();
        BatchCreateStudentAuditHistory objB = new BatchCreateStudentAuditHistory();    
        String sch = '3 4 2 5 6 ?'; 
        system.schedule('BatchCreateStudentAuditHistory1', sch, objB); 
        
        Test.stopTest();
    }
//S-39026
    @isTest  static  void testMethodNice() {
        setup();

        aoeLst = new List<Area_of_Expertise__c>();

        Area_of_Expertise__c areaOfExp1 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExp1.Level__c = '1000';
        areaOfExp1.Category__c = 'General Education';
        areaOfExp1.Subject_Area__c = 'Statistics';
        areaOfExp1.Pseudo_Course__c = true;
        aoeLst.add(areaOfExp1);

        Area_of_Expertise__c areaOfExp2 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExp2.Level__c = '1000';
        areaOfExp1.Category__c = 'General Education';
        areaOfExp1.Subject_Area__c = 'Statistics';
        areaOfExp2.Pseudo_Course__c = true;
        aoeLst.add(areaOfExp2);


        insert aoeLst;


        studExprtiseLst = new List<Student_Expertise__c>();

        Student_Expertise__c studExprtse1 = new  Student_Expertise__c();
        studExprtse1.Opportunity__c = opp.id;
        studExprtse1.IsAchieved__c= True;
        studExprtse1.Is_Audit_History_Created__c = False;
        studExprtse1.Pseudo_CE__c = 4;
        studExprtse1.Area_of_Expertise__c=areaOfExp1.id;
        studExprtse1.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse1);


        Student_Expertise__c studExprtse2 = new  Student_Expertise__c();
        studExprtse2.Opportunity__c = opp.id;
        studExprtse2.IsAchieved__c= True;
        studExprtse2.Is_Audit_History_Created__c = False;
        studExprtse2.Pseudo_CE__c = 4;
        studExprtse2.Area_of_Expertise__c=areaOfExp2.id;
        studExprtse2.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse2);


        Area_of_Expertise__c areaOfExp3 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education', Pseudo_Course__c=true, Subject_Area__c = 'Statistics',Level__c ='1000');
        insert areaOfExp3;
        Student_Expertise__c studExprtse3 = new  Student_Expertise__c();
        studExprtse3.Opportunity__c = opp.id;
        studExprtse3.IsAchieved__c= True;
        studExprtse3.Is_Audit_History_Created__c = False;
        studExprtse3.Pseudo_CE__c = 4;
        studExprtse3.Area_of_Expertise__c=areaOfExp3.id;
        studExprtse3.Outcome_Category__c = null;
        studExprtse3.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse3);

        Area_of_Expertise__c areaOfExp4 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education', Pseudo_Course__c=true,Subject_Area__c = 'Statistics',Level__c ='1000');
        insert areaOfExp4;
        Student_Expertise__c studExprtse4 = new  Student_Expertise__c();
        studExprtse4.Opportunity__c = opp.id;
        studExprtse4.IsAchieved__c= True;
        studExprtse4.Is_Audit_History_Created__c = False;
        studExprtse4.Pseudo_CE__c = 4;
        studExprtse4.Area_of_Expertise__c=areaOfExp4.id;
        studExprtse4.Outcome_Category__c = null;
        studExprtse4.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse4);

        Area_of_Expertise__c areaOfExp5 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education' ,Pseudo_Course__c=true,Subject_Area__c = 'Statistics',Level__c ='1000');
        insert areaOfExp5;
        Student_Expertise__c studExprtse5 = new  Student_Expertise__c();
        studExprtse5.Opportunity__c = opp.id;
        studExprtse5.IsAchieved__c= True;
        studExprtse5.Is_Audit_History_Created__c = False;
        studExprtse5.Pseudo_CE__c = 4;
        studExprtse5.Area_of_Expertise__c=areaOfExp5.id;
        studExprtse5.Outcome_Category__c = null;
        studExprtse5.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse5);

        Area_of_Expertise__c areaOfExp6 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education', Pseudo_Course__c=true,Subject_Area__c = 'Statistics',Level__c ='1000');
        insert areaOfExp6;
        Student_Expertise__c studExprtse6 = new  Student_Expertise__c();
        studExprtse6.Opportunity__c = opp.id;
        studExprtse6.IsAchieved__c= True;
        studExprtse6.Is_Audit_History_Created__c = False;
        studExprtse6.Pseudo_CE__c = 4;
        studExprtse6.Area_of_Expertise__c=areaOfExp6.id;
        studExprtse6.Outcome_Category__c = null;
        studExprtse6.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse6);

        Area_of_Expertise__c areaOfExp7 = new Area_of_Expertise__c(Name='SSS',Category__c = 'General Education', Pseudo_Course__c=true,Subject_Area__c = 'Statistics',Level__c ='1000');
        insert areaOfExp7;
        Student_Expertise__c studExprtse7 = new  Student_Expertise__c();
        studExprtse7.Opportunity__c = opp.id;
        studExprtse7.IsAchieved__c= True;
        studExprtse7.Is_Audit_History_Created__c = False;
        studExprtse7.Pseudo_CE__c = 4;
        studExprtse7.Area_of_Expertise__c=areaOfExp7.id;
        studExprtse7.Outcome_Category__c = null;
        studExprtse7.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse7);



        insert studExprtiseLst;


        Test.startTest();
        BatchCreateStudentAuditHistory objB = new BatchCreateStudentAuditHistory();
        String sch = '3 4 2 5 6 ?';
        system.schedule('BatchCreateStudentAuditHistory1', sch, objB);

        Test.stopTest();
    }
}