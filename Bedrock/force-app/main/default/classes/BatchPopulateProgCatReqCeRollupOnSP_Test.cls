/************************************************************************************** 
Apex Class Name     : BatchPopulateProgCatReqCeRollupOnSP_Test
Created Date        : 24th January 2019
Function            : Test class for BatchCreateStudentAuditHistory class
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                  
* Ravitej Varada            1/24/2019                Original Version
*************************************************************************************/
@isTest
public class BatchPopulateProgCatReqCeRollupOnSP_Test
{ 
    static testMethod void testMethodFive() 
    {
        List<Student_Expertise__c> studExprtiseLst = new List<Student_Expertise__c>();
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
        Product2 prod = new Product2(Name = 'Laptop X200',Family = 'Hardware',Degree_Level__c='Undergrad',Institution__c=instn.id,
                                     recordtypeid=RecordTypeProduct);
        insert prod;
        
        Id RecordTypeProduct1 =  Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Product2 prod1 = new Product2(Name = 'Laptop X20',Parent_Program__c=prod.id,Institution__c=instn.id,recordtypeid=RecordTypeProduct1,
                                      Degree_Level__c='Undergrad');
        insert prod1;
        
        student_program__c stuProg = new student_program__c(program__c=prod1.id,Student__c=con.id);
        insert stuProg;
        
        List<Program_Category_Requirement__c> categoryReList =new List<Program_Category_Requirement__c>();
        Program_Category_Requirement__c categoryRe1= new Program_Category_Requirement__c(Program__c=prod1.id,Category__c = 'Core',Level__c = 'Upper');
        categoryReList.add(categoryRe1);
        Program_Category_Requirement__c categoryRe2= new Program_Category_Requirement__c(Program__c=prod1.id,Category__c = 'Core',Level__c = 'Lower');
        categoryReList.add(categoryRe2);
        Program_Category_Requirement__c categoryRe3= new Program_Category_Requirement__c(Program__c=prod1.id,Category__c = 'Concentration',Level__c = 'Lower');
        categoryReList.add(categoryRe3);
        Program_Category_Requirement__c categoryRe4= new Program_Category_Requirement__c(Program__c=prod1.id,Category__c = 'General Education',Level__c = 'Lower',Subject_Area_Expertise__c = null);
        categoryReList.add(categoryRe4);
        Program_Category_Requirement__c categoryRe5= new Program_Category_Requirement__c(Program__c=prod1.id,Category__c = 'General Education',Level__c = 'Lower',Subject_Area_Expertise__c ='Arts and Humanities' );
        categoryReList.add(categoryRe5);
        Program_Category_Requirement__c categoryRe6= new Program_Category_Requirement__c(Program__c=prod1.id,Category__c = 'General Education',Level__c = 'Lower',Subject_Area_Expertise__c = 'Written and Oral Communication');
        categoryReList.add(categoryRe6);
        Program_Category_Requirement__c categoryRe7= new Program_Category_Requirement__c(Program__c=prod1.id,Category__c = 'General Education',Level__c = 'Lower',Subject_Area_Expertise__c = 'Mathematics/Natural Sciences');
        categoryReList.add(categoryRe7);
        Program_Category_Requirement__c categoryRe8= new Program_Category_Requirement__c(Program__c=prod1.id,Category__c = 'General Education',Level__c = 'Lower',Subject_Area_Expertise__c = 'Social Sciences');
        categoryReList.add(categoryRe8);
        Program_Category_Requirement__c categoryRe9= new Program_Category_Requirement__c(Program__c=prod1.id,Category__c = 'General Elective',Level__c = 'Lower');
        categoryReList.add(categoryRe9);      
        Program_Category_Requirement__c categoryRe10= new Program_Category_Requirement__c(Program__c=prod1.id,Category__c = 'General Education',Level__c = 'Lower',Subject_Area_Expertise__c = 'Any Category');
        categoryReList.add(categoryRe10);      
        insert categoryReList;
        
        System.assertNotEquals(studExprtiseLst,Null);    
        
        Area_of_Expertise__c areaOfExp8 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Elective',Level__c ='3000',Subject_Area__c ='Social Sciences');
        insert areaOfExp8;	
        Student_Expertise__c studExprtse8 = new  Student_Expertise__c();
        studExprtse8.Opportunity__c = opp.id;
        studExprtse8.IsAchieved__c= True;
        studExprtse8.Is_Audit_History_Created__c = False;
        studExprtse8.Pseudo_CE__c = 66;
        studExprtse8.Area_of_Expertise__c=areaOfExp8.id;
        studExprtse8.Outcome_Category__c = null;
        studExprtse8.Student_Program__c = stuProg.id;
        studExprtse8.Is_Audit_History_Created__c = false;
        studExprtiseLst.add(studExprtse8); 
        
        insert studExprtiseLst;  
        
        Test.startTest();
        BatchPopulateProgCatReqCeRollupOnSP objB = new BatchPopulateProgCatReqCeRollupOnSP();   
        database.executeBatch(objB);
        //String sch = '3 4 2 5 12 ?'; 
        // system.schedule('BatchPopulateProgCatReqCeRollupOnSP', sch, objB); 
        
        Test.stopTest();
    }
}