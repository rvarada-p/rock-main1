@isTest
public class StudentHoldCodeTriggerHelper_Test {
    
    private static Student_Program__c studentProgram;
    private static Institution__c institution;
    private static Hold_codes__c bhHoldCode;
    private static Hold_codes__c dhHoldCode;
    private static Hold_codes__c bkHoldCode;
    private static Hold_codes__c c2HoldCode;
    
    static void setup() {
        Account acc = new Account(name='Test Account');
        insert acc;
     
        Contact con=new Contact(FirstName='fname',LastName = 'lname',Email = 'email@gmail.com',Phone = '9743800309'); 
        insert con;
        
        institution = new Institution__c(Name='Walden');
        insert institution;
        
        Id RecordTypeProduct =  Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Product2 prod = new Product2(Name = 'P_BSECS', ProductCode='P_BSECS', Family = 'Family 1',Degree_Level__c='Undergrad',Institution__c=institution.id,recordtypeid=RecordTypeProduct);
        insert prod;
        
        Product2 prod1 = new Product2(Name = 'C_BSECS', ProductCode='C_BSECS', Parent_Program__c=prod.id,Institution__c=institution.id,recordtypeid=RecordTypeProduct,Degree_Level__c='Undergrad');
        insert prod1;
        
        studentProgram = new student_program__c(Student__c=con.id);
        studentProgram.Program__c = prod1.id;
        insert studentProgram;
        
        Opportunity opp = new Opportunity(Account=acc,StageName='New',Name='Opp name',CloseDate=system.today(),Student_Program__c=studentProgram.id, primary_program__c=prod1.id);
        insert opp;
        
        studentProgram.Program__c = prod1.id;
        update studentProgram;
        
        bhHoldCode = new Hold_codes__c();
        bhHoldCode.Institution__c = institution.Id;
        bhHoldCode.Name = 'BH';
        bhHoldCode.Description__c = 'BH';
        insert bhHoldCode;
        
        dhHoldCode = new Hold_codes__c();
        dhHoldCode.Institution__c = institution.Id;
        dhHoldCode.Name = 'DH';
        dhHoldCode.Description__c = 'DH';
        insert dhHoldCode;
        
        bkHoldCode = new Hold_codes__c();
        bkHoldCode.Institution__c = institution.Id;
        bkHoldCode.Name = 'BK';
        bkHoldCode.Description__c = 'BK Hold Code';
        insert bkHoldCode;
        
        c2HoldCode = new Hold_codes__c();
        c2HoldCode.Institution__c = institution.Id;
        c2HoldCode.Name = 'C2';
        c2HoldCode.Description__c = 'C2 Hold Code';
        insert c2HoldCode;
        
    }
    
    public static testMethod void testProcessBKHoldCodeInsert() {
        setup();
        
        Student_Hold_Code__c dhStudentHoldCode = new Student_Hold_Code__c();
        dhStudentHoldCode.Hold_Code__c = dhHoldCode.Id;
        dhStudentHoldCode.Student_Program__c = studentProgram.Id;
        dhStudentHoldCode.Hold_Close_Date__c = null;
        insert dhStudentHoldCode;
        
        Student_Hold_Code__c bkStudentHoldCode = new Student_Hold_Code__c();
        bkStudentHoldCode.Hold_Code__c = bkHoldCode.Id;
        bkStudentHoldCode.Student_Program__c = studentProgram.Id;
        bkStudentHoldCode.Hold_Close_Date__c = null;
        
        Test.startTest();
        insert bkStudentHoldCode;
        Test.stopTest();
    }
    
    public static testMethod void testProcessC2HoldCodeInsert() {
        setup();
        
        Student_Hold_Code__c bhStudentHoldCode = new Student_Hold_Code__c();
        bhStudentHoldCode.Hold_Code__c = bhHoldCode.Id;
        bhStudentHoldCode.Student_Program__c = studentProgram.Id;
        bhStudentHoldCode.Hold_Close_Date__c = null;
        insert bhStudentHoldCode;
        
        Student_Hold_Code__c c2StudentHoldCode = new Student_Hold_Code__c();
        c2StudentHoldCode.Hold_Code__c = c2HoldCode.Id;
        c2StudentHoldCode.Student_Program__c = studentProgram.Id;
        c2StudentHoldCode.Hold_Close_Date__c = null;
        
        Test.startTest();
        insert c2StudentHoldCode;
        Test.stopTest();
    }

}