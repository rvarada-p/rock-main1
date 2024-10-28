/*******************************************************************
Name  : StudentPaymentPlanTriggerHandler_Test
Author: Ravitej Varada
Date  : Oct 13, 2018
Description: Test Class for the Handler class PreRequisiteRuleTriggerHandler and trigger PreRequisiteRuleTrigger.
Also Covering the test coverage of the helper class PreRequisiteRuleTriggerHelper

Revision History
* Horacio Sanchez 	- 	Jul 15, 2021 	- 	User Story 58473: L2: Create Payment Plan identifier on SP
*************************************************************************/
@isTest
private class StudentPaymentPlanTriggerHandler_Test {

    public static student_program__c sProg;

    static testMethod void testStudentPaymentPlanonSPTrue(){
        
        Account acc = new Account(name='Test Account');
        insert acc;
     
        Contact con = new Contact(FirstName='fname',LastName = 'lname',Email = 'email@gmail.com',Phone = '9743800309'); 
        insert con;
        
        Institution__c instn = new Institution__c(Name='Walden');
        insert instn;
        Id RecordTypeProduct =  Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Product2 prod = new Product2(Name = 'M.S in Nursing', ProductCode='P_MSN', Family='CBL', Degree_Level__c='Graduate', Institution__c=instn.id,recordtypeid=RecordTypeProduct);
        insert prod;
        
        Product2 prod1 = new Product2(Name = 'M.S in Nursing Informatics - RN to MSN', ProductCode='C_MSN_Info_RNMSN', Parent_Program__c=prod.id, Institution__c=instn.id, 
                                      recordtypeid=RecordTypeProduct, Degree_Level__c='Graduate', Total_Credits_in_Program__c=133.00);
        insert prod1;
        
        Program_Version__c programVersion = new Program_Version__c(Active__c=true, Program_Lookup__c=prod1.id, Total_Credits_in_Program__c=133.00, Credit_Progression_Rate__c=6.6250);
        insert programVersion;
        
        Student_Program__c studentProgram = new student_program__c(Student__c=con.id);
        studentProgram.Program__c = prod1.id;
        studentProgram.Program_Version__c = programVersion.Id;
        insert studentProgram;
        
        Opportunity opp = new Opportunity(Account=acc,StageName='New', Name='Opp name', CloseDate=system.today(), Student_Program__c=studentProgram.id, primary_program__c=prod1.id);
        insert opp;
        
        Student_Payment_Plan__c sPlan  = new Student_Payment_Plan__c();
        sPlan.Student_Program__c = studentProgram.id;
        sPlan.Action__c = 'Create';
        sPlan.Type_of_Plan__c = 'Enrollment in Automatic Payment';

        Insert sPlan;

    }


    static testMethod void testStudentPaymentPlanonSPFalse (){

        Account acc = new Account(name='Test Account');
        insert acc;
     
        Contact con = new Contact(FirstName='fname',LastName = 'lname',Email = 'email@gmail.com',Phone = '9743800309'); 
        insert con;
        
        Institution__c instn = new Institution__c(Name='Walden');
        insert instn;
        Id RecordTypeProduct =  Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Product2 prod = new Product2(Name = 'M.S in Nursing', ProductCode='P_MSN', Family='CBL', Degree_Level__c='Graduate', Institution__c=instn.id,recordtypeid=RecordTypeProduct);
        insert prod;
        
        Product2 prod1 = new Product2(Name = 'M.S in Nursing Informatics - RN to MSN', ProductCode='C_MSN_Info_RNMSN', Parent_Program__c=prod.id, Institution__c=instn.id, 
                                      recordtypeid=RecordTypeProduct, Degree_Level__c='Graduate', Total_Credits_in_Program__c=133.00);
        insert prod1;
        
        Program_Version__c programVersion = new Program_Version__c(Active__c=true, Program_Lookup__c=prod1.id, Total_Credits_in_Program__c=133.00, Credit_Progression_Rate__c=6.6250);
        insert programVersion;
        
        Student_Program__c studentProgram = new student_program__c(Student__c=con.id);
        studentProgram.Program__c = prod1.id;
        studentProgram.Program_Version__c = programVersion.Id;
        insert studentProgram;
        
        Opportunity opp = new Opportunity(Account=acc,StageName='New', Name='Opp name', CloseDate=system.today(), Student_Program__c=studentProgram.id, primary_program__c=prod1.id);
        insert opp;
        
        Student_Payment_Plan__c sPlan  = new Student_Payment_Plan__c();
        sPlan.Student_Program__c = studentProgram.id;
        sPlan.Action__c = 'Cancel';
        sPlan.Type_of_Plan__c = 'Enrollment in Automatic Payment';

        Insert sPlan;

    }
    
    static testMethod void testStudentPaymentPlanOnInsert(){

        Account acc = new Account(name='Test Account');
        insert acc;
     
        Contact con = new Contact(FirstName='fname',LastName = 'lname',Email = 'email@gmail.com',Phone = '9743800309'); 
        insert con;
        
        Institution__c instn = new Institution__c(Name='Walden');
        insert instn;
        Id RecordTypeProduct =  Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Product2 prod = new Product2(Name = 'M.S in Nursing', ProductCode='P_MSN', Family='CBL', Degree_Level__c='Graduate', Institution__c=instn.id,recordtypeid=RecordTypeProduct);
        insert prod;
        
        Product2 prod1 = new Product2(Name = 'M.S in Nursing Informatics - RN to MSN', ProductCode='C_MSN_Info_RNMSN', Parent_Program__c=prod.id, Institution__c=instn.id, 
                                      recordtypeid=RecordTypeProduct, Degree_Level__c='Graduate', Total_Credits_in_Program__c=133.00);
        insert prod1;
        
        Program_Version__c programVersion = new Program_Version__c(Active__c=true, Program_Lookup__c=prod1.id, Total_Credits_in_Program__c=133.00, Credit_Progression_Rate__c=6.6250);
        insert programVersion;
        
        Student_Program__c studentProgram = new student_program__c(Student__c=con.id);
        studentProgram.Program__c = prod1.id;
        studentProgram.Program_Version__c = programVersion.Id;
        insert studentProgram;
        
        Opportunity opp = new Opportunity(Account=acc,StageName='New', Name='Opp name', CloseDate=system.today(), Student_Program__c=studentProgram.id, primary_program__c=prod1.id);
        insert opp;

        Student_Payment_Plan__c sPlan = new Student_Payment_Plan__c();
        sPlan.Student_Program__c = studentProgram.id;
        sPlan.Action__c = 'Create';
        sPlan.Type_of_Plan__c = 'PaymentPlan';

        Insert sPlan;
        
        Student_Payment_Plan__c sPlan2 = new Student_Payment_Plan__c();
        sPlan2.Student_Program__c = studentProgram.id;
        sPlan2.Action__c = 'Cancel';
        sPlan2.Type_of_Plan__c = 'PaymentPlan';
        
        insert sPlan2;

    }

}