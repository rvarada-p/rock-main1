@isTest
public class SubmitCaseController_test{
 static  Id tirRecordType;
  static testMethod void SubmitCaseController(){
   Product2 parentProgram = TestDataGenerator.createProduct('test', 'Walden', true);
   Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
   product2.Parent_Program__c = parentProgram.Id;
   insert product2;
   
     Program_Start_Date__c tstStartDate  = TestDataGenerator.createProgramStartDate(false);
        tstStartDate.Program__c = product2.Id;
        insert tstStartDate;

   
     Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false);
        opty.Primary_Program__c = product2.Id;
        opty.Program_Start_Date__c = tstStartDate.Id;
        Student_Program__c studentProgram = TestDataGenerator.createStudentProgram(opty,testCon.ID, null, true);
    studentProgram.Program_Start_Date__c = tstStartDate.Id;
    update studentProgram;
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
        
            tirRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Tempo Internal Issues').getRecordTypeId();
       
       
     list<Case> lstCase = new list<Case>();
        Case sCase = new Case();
    
    sCase.Subject = 'Test1';
 	sCase.Type ='Change of Modality';
    sCase.Case_Topic__c ='Course-Based to Tempo';
    sCase.System__c='Tempo Learning';
   
    sCase.Description='test1';
    sCase.ContactId=testCon.Id;
    sCase.RecordTypeId=tirRecordType;
     lstCase.add(sCase);
    
    
    Case sCase2 = new Case();
    sCase2.Subject = 'Test2';
 	sCase2.Type ='Change of Modality';
    sCase2.Case_Topic__c ='Course-Based to Tempo';
    sCase2.System__c='Tempo Learning';
    sCase2.Description='test2';
    sCase2.ContactId=testCon.Id;
    sCase.RecordTypeId=tirRecordType;
     lstCase.add(sCase2);
    
     
    Case sCase3 = new Case();
    sCase3.Subject = 'Test3';
 	sCase3.Type ='Change of Modality';
    sCase3.Case_Topic__c ='Course-Based to Tempo';
    sCase3.System__c='Tempo Learning';
    sCase3.Description='test3';
    sCase3.ContactId=testCon.Id;
    sCase3.RecordTypeId=tirRecordType;
     lstCase.add(sCase3);
    
    insert lstCase;

        test.startTest();
        PageReference pageRef = Page.Report_Issues;
        Test.setCurrentPage(pageRef);
        SubmitCaseController cont = new SubmitCaseController();
        cont.submitCase();
        cont.cancel();
        test.stopTest();
        //ApexPages.StandardController sc = new ApexPages.StandardController(opty);

    
  

  }

   }