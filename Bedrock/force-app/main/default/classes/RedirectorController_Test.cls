@isTest
public class RedirectorController_Test {
    
    static testMethod void testRedirect() {
        Account acc = new Account(name='Test Account');
        insert acc;
     
        Contact con=new Contact(FirstName='fname',LastName = 'lname',Email = 'email@gmail.com',Phone = '9743800309'); 
        insert con;
        
        Institution__c instn = new Institution__c(Name='Walden');
        insert instn;
        Id RecordTypeProduct =  Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Product2 prod = new Product2(Name = 'P_BSECS', ProductCode='P_BSECS', Family = 'Family 1',Degree_Level__c='Undergrad',Institution__c=instn.id,recordtypeid=RecordTypeProduct);
        insert prod;
        
        Product2 prod1 = new Product2(Name = 'C_BSECS', ProductCode='C_BSECS', Parent_Program__c=prod.id,Institution__c=instn.id,recordtypeid=RecordTypeProduct,Degree_Level__c='Undergrad');
        insert prod1;
        
        Student_Program__c studentProgram = new student_program__c(Student__c=con.id);
        studentProgram.Program__c = prod1.id;
        insert studentProgram;
        
        Opportunity opp = new Opportunity(Account=acc,StageName='New',Name='Opp name',CloseDate=system.today(),Student_Program__c=studentProgram.id, primary_program__c=prod1.id);
        insert opp;
        
        studentProgram.Program__c = prod1.id;
        update studentProgram;
        
        RedirectorController controller = new RedirectorController(new ApexPages.StandardController(opp));
        Test.startTest();
            ApexPages.currentPage().getParameters().put('id', studentProgram.Id);
            controller.redirect();
            
        	// Changing program's degree level to test else condition in redirect method in controller
            prod.Degree_Level__c = 'Graduate';
            update prod;
            
            prod1.Degree_Level__c = 'Graduate';
            update prod1;
        
        	controller.redirect();
        Test.stopTest();
    }
    
    static testMethod void testRedirectMSN_RNProgram() {
        Account acc = new Account(name='Test Account');
        insert acc;
     
        Contact con=new Contact(FirstName='fname',LastName = 'lname',Email = 'email@gmail.com',Phone = '9743800309'); 
        insert con;
        
        Institution__c instn = new Institution__c(Name='Walden');
        insert instn;
        Id RecordTypeProduct =  Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Product2 prod = new Product2(Name = 'C_MSN_Edu_RNMSN', ProductCode='C_MSN_Edu_RNMSN', Family = 'Family 1',Degree_Level__c='Graduate',Institution__c=instn.id,recordtypeid=RecordTypeProduct);
        insert prod;
        
        Product2 prod1 = new Product2(Name = 'C_MSN_Edu_RNMSN', ProductCode='C_MSN_Edu_RNMSN', Parent_Program__c=prod.id,Institution__c=instn.id,recordtypeid=RecordTypeProduct,Degree_Level__c='Graduate');
        insert prod1;
        
        Student_Program__c studentProgram = new student_program__c(Student__c=con.id);
        studentProgram.Program__c = prod1.id;
        insert studentProgram;
        
        Opportunity opp = new Opportunity(Account=acc,StageName='New',Name='Opp name',CloseDate=system.today(),Student_Program__c=studentProgram.id, primary_program__c=prod1.id);
        insert opp;
        
        studentProgram.Program__c = prod1.id;
        update studentProgram;
        
        Grad_Programs_for_GenEd_and_GenElective__c customSetting = new Grad_Programs_for_GenEd_and_GenElective__c();
        customSetting.Name = 'C_MSN_Edu_RNMSN';
        insert customSetting;
        
        RedirectorController controller = new RedirectorController(new ApexPages.StandardController(opp));
        Test.startTest();
            ApexPages.currentPage().getParameters().put('id', studentProgram.Id);
            controller.redirect();
            
        	// Changing program's degree level to test else condition in redirect method in controller
            prod.Degree_Level__c = 'Graduate';
            update prod;
            
            prod1.Degree_Level__c = 'Graduate';
            update prod1;
        
        	controller.redirect();
        Test.stopTest();
    }

}