@isTest
public class SubmitGradApplicationController_test{

    static  Id tirRecordType;
    static Contact testCon;
    static Student_Program__c sProg;
 
  static void setup() {
       Product2 parentProgram = TestDataGenerator.createProduct('test', 'Walden', true);
       Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
       product2.Parent_Program__c = parentProgram.Id;
       insert product2;
       
        Program_Start_Date__c tstStartDate  = TestDataGenerator.createProgramStartDate(false);
        tstStartDate.Program__c = product2.Id;
        insert tstStartDate;

   
        Account acc = TestDataGenerator.createAccount(true);
        testCon = TestDataGenerator.createContact(acc,true);
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false);
        opty.Primary_Program__c = product2.Id;
        opty.Program_Start_Date__c = tstStartDate.Id;
      	opty.Contact__c = testCon.Id;
        insert opty;
        sProg = TestDataGenerator.createStudentProgram(opty,testCon.ID, null, true);
        sProg.Program_Start_Date__c = tstStartDate.Id;
        sProg.Student_Enrollment_Status__c = 'Eligible to Register (EL)';
        sProg.Graduation_Application_Submitted__c = False;
        sProg.Student_Enrollment_Status__c   = 'Eligible to Register (EL)';
      	update sProg;
        opty.StageName = 'Student';
        update opty;
      	Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);  
        Program_Expertise__c pExperise = TestDataGenerator.createProgramExpertise(aExper.ID,product2.ID,true,5.0,true);
        Competency__c testComp = TestDataGenerator.createCompetency(10, true);
        Program_Competency__c pCompetemcy = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0, true);
        Competency__c testComp2 = TestDataGenerator.createCompetency(10, true);
        Program_Competency__c pCompetemcy2 = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0, true);
        Student_Expertise__c sExpertise = TestDataGenerator.createCompetencyExpertise(aExper.Id,null, false);
        sExpertise.Contact__c = testCon.id;
        sExpertise.Program_Expertise__c = pExperise.ID;
        insert sExpertise;

        tirRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Walden').getRecordTypeId();     
  }

  static testMethod void SubmitGradApplicationController(){

     setup();

     list<Graduation_Application__C> lstGA = new list<Graduation_Application__c>();
     Graduation_Application__c sGradApp = new Graduation_Application__c();
     
     
     sGradApp.Full_Name__c = 'NULL';
     sGradApp.Student_Id_Number__c = 'CBL123123';
     sGradApp.Mailing_Address__c = 'Test Mailing Address';
     sGradApp.Street_Address_1__c = 'Test Address 1';
     sGradApp.Street_Address_2__c = 'Test Address 2';
     sGradApp.Street_Address_3__c = 'Test Address 3';
     sGradApp.Street_Address_4__c = 'Address4';


     sGradApp.Walden_Email_Address__c = 'test@waldenu.edu';
     sGradApp.Country__c = 'United States';
     sGradApp.Employer_Email__c = 'teste@email.com';
     sGradApp.Student_Program_Name__c = sProg.Id;
     insert sGradApp;
     
    test.startTest();
    PageReference pageRef = Page.Graduation_Application;
    Test.setCurrentPage(pageRef);
    SubmitGradApplicationController grad = new SubmitGradApplicationController (new ApexPages.StandardController(new Graduation_Application__c()));
    grad.cblId = testCon.CBL_Student_ID__c;
    grad.submitForm();
    grad.cancel();
    test.stopTest();
    
    list<Graduation_Application__c> gradApp = new list<Graduation_Application__c>([SELECT ID FROM Graduation_Application__c WHERE Student_Program_Name__c = :sProg.Id]);
    System.debug('Grad App: ' + gradApp);
    System.assert(gradApp.size()>0);
        //ApexPages.StandardController sc = new ApexPages.StandardController(opty);

   }


    static testMethod void testNonMatchingCBLId() {
        setup();
        test.startTest();
        PageReference pageRef = Page.Graduation_Application;
        Test.setCurrentPage(pageRef);
        SubmitGradApplicationController grad = new SubmitGradApplicationController (new ApexPages.StandardController(new Graduation_Application__c()));
        grad.cblId = 'CBL-121212';
        grad.submitForm();
       // grad.cancel();
        test.stopTest();
        
    }


}