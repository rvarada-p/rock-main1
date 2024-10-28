/************************************************************************************** 
Apex Class Name     : BatchUpdateAnticipatedGradDateOnSP_Test
Created Date        : 24th January 2019
Function            : Test class for BatchUpdateAnticipatedGradDateOnSP class
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                  
* Horacio Sanchez            01/15/2021                Original Version
*************************************************************************************/
@isTest
public class BatchUpdateAnticipatedGradDateOnSP_Test {
    
    static testMethod void testExecution() {
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
        
        Program_Start_Date__c psDate = TestDataGenerator.createProgramStartDate(false);
        psDate.Accepting_New_Students__c = true;
        psDate.Program__c = prod.ID;
        insert psDate;
        
        stuProg.Program_Start_Date__c = psDate.ID;
        update stuProg;
        
        Test.startTest();
        BatchUpdateAnticipatedGradDateOnSP objB = new BatchUpdateAnticipatedGradDateOnSP();   
        database.executeBatch(objB);
        
        Test.stopTest();
    }
}