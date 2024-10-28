/************************************************************************************** 
Apex Class Name     : BatchCreateStudentAuditHistory_Test
Created Date        : 24th January 2019
Function            : Test class for BatchCreateStudentAuditHistory class
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                  
* Ravitej Varada            1/24/2019                Original Version
*************************************************************************************/
@isTest
Private class DeleteStudentAuditHistory_Test{
    
    Private static List<Student_Expertise__c> studExprtiseLst ;
    Private static List<Area_of_Expertise__c> aoeLst ;
    
    private static opportunity opp;
    private static student_program__c stuProg;
    Private static void setup() {
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
        
       createAOE('Core','4000',1, null, 5);
       createAOE('Core','1000',1, null, 5);
       createAOE('Concentration','1000',2, null, 5);
       
       createAOE('General Education','3000',1, 'Mathematics/Natural Sciences', 5);
       createAOE('General Education','3000',1, 'Social Sciences', 5);
       createAOE('General Education','3000',1, 'Written and Oral Communication', 5);
       createAOE('General Education','3000',1, 'Arts and Humanities', 5);
       
       createAOE('General Elective','3000',1, null, 5);


       Test.startTest();
       BatchCreateStudentAuditHistory objB = new BatchCreateStudentAuditHistory();    
       database.executeBatch(objB);
       
       Test.stopTest();
       
       
       List<Student_Expertise__c> seLst = new List<Student_Expertise__c>  ();
       List<Student_Expertise__c> seLstToUpdate = new List<Student_Expertise__c>  ();
       
       seLst = [Select id,isAchieved__c from Student_Expertise__c];
       
       For(Student_Expertise__c se: seLst){
           se.isAchieved__c = false;
           seLstToUpdate.add(se);
           
       }
       if(!seLstToUpdate.isEmpty()){
           update seLstToUpdate;
       }
       
   }
    
     
    
    
   
    public static void  createAOE(string category, string level, integer count,string subArea, integer CE){
        List<Area_of_Expertise__c> aoeLst = new  List<Area_of_Expertise__c>();
        List<Student_Expertise__c> seLst = new  List<Student_Expertise__c>();
        for(integer i=0;i<= count;i++){
             Area_of_Expertise__c aoe = new Area_of_Expertise__c(
                Name = 'Aoe',
                Pseudo_Course__c = true,
                Category__c = category,
                Level__c = level,
                Subject_Area__c = subArea);
            aoeLst.add(aoe);            
        }
        
        insert aoeLst;
        
        
        
         for(Area_of_Expertise__c aoe:aoeLst){
           Student_Expertise__c se = new  Student_Expertise__c(
                 Opportunity__c = opp.id,
                IsAchieved__c  = True,
                Is_Audit_History_Created__c = False,
                Pseudo_CE__c = CE,
                Area_of_Expertise__c = aoe.id,
               
                Student_Program__c = stuProg.id);
            
            seLst.add(se);
            
        }
        
        insert(seLst);
        
        
    }


}