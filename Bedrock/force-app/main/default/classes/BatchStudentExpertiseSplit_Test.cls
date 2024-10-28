/************************************************************************************** 
Apex Class Name     : BatchStudentExpertiseSplit_Test
Created Date        : 24th January 2019
Function            : Test class for BatchStudentExpertiseSplit class
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                  
* Ravitej Varada            1/24/2019                Original Version
*************************************************************************************/
@isTest
Private class BatchStudentExpertiseSplit_Test{
    
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
        areaOfExp1.Category__c = 'General Education; General Elective';
        areaOfExp1.Pseudo_Course__c = true;
        aoeLst.add(areaOfExp1); 
         
        Area_of_Expertise__c areaOfExp2 = TestDataGenerator.createAreaOfExpertise(false);
        areaOfExp2.Level__c = '3000';
        areaOfExp2.Category__c = 'General Education; General Elective';
        areaOfExp2.Pseudo_Course__c = true;
        aoeLst.add(areaOfExp2); 
        
        
        insert aoeLst;
        
        
        Competency__c comp = new Competency__c();
        comp.Code__c = 'code';
        comp.Description__c = 'Test Competency';
        comp.Type__c = 'Academic';
        comp.Credit_Equivalency__c = 0.0;  
        comp.Published__c = true;  
        insert comp;
        studExprtiseLst = new List<Student_Expertise__c>();
        
        Student_Expertise__c studExprtse1 = new  Student_Expertise__c();
        studExprtse1.Opportunity__c = opp.id;
        studExprtse1.IsAchieved__c= True;
        studExprtse1.Is_Audit_History_Created__c = False;
        studExprtse1.Pseudo_CE__c = 30;
        studExprtse1.Total_Applied_Earned_CE_Outcome__c = 10;
        studExprtse1.Area_of_Expertise__c=areaOfExp1.id;
        studExprtse1.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse1);
        
        
        insert studExprtiseLst;  
        
        List<Student_Competency__c> studComList = new List<Student_Competency__c>();
        Student_Competency__c compObj1 = new Student_Competency__c(Student_Expertise__c=studExprtse1.Id,Competency__c=comp.Id,status__c = 'Transferred');
        studComList.add(compObj1);
        Student_Competency__c compObj2 = new Student_Competency__c(Student_Expertise__c=studExprtse1.Id,Competency__c=comp.Id,status__c = 'Transferred');
        studComList.add(compObj2);
        insert studComList;
        
        Test.startTest();
        BatchStudentExpertiseSplit objB = new BatchStudentExpertiseSplit();    
        String sch = '3 4 2 5 6 ?'; 
        system.schedule('BatchStudentExpertiseSplit1', sch, objB); 
        
        Test.stopTest();
    }
    
}