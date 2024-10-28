@isTest
public class CloneSEUtility_Test {

    public static testMethod void testCloneSE() {
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
        
        Area_of_Expertise__c aoeStat3001 = new Area_of_Expertise__c(Name='Statistical Methods and Applications (STAT 3001)', Display_name__c='Statistical Methods and Applications (STAT 3001)');
        insert aoeStat3001;
        
        Student_Expertise__c studentExpertise1 = new Student_Expertise__c(Area_of_Expertise__c=aoeStat3001.Id, recordTypeId=Schema.SObjectType.Student_Expertise__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId());
        insert studentExpertise1;
        
        Competency__c competency1 = new Competency__c(Code__c='CODE01', Description__c='Description', Type__c='Academic', Published__c=true);
        insert competency1;
        
        Student_Competency__c studentCompetency1 = new Student_Competency__c(Competency__c=competency1.Id, Student_Program__c=studentProgram.id, Student_Expertise__c=studentExpertise1.id);
        insert studentCompetency1;
        
        List<Student_Expertise__c> studentExpsLst = new List<Student_Expertise__c>();
        Map<Id,Integer> seIdPseudoCeMap = new Map<Id, Integer>();
        
        studentExpsLst.add(studentExpertise1);
        seIdPseudoCeMap.put(studentExpertise1.Id, 15);
            
        Test.startTest();
        	CloneSEUtility.cloneSe(studentExpsLst, seIdPseudoCeMap);
        Test.stopTest();
    }
}