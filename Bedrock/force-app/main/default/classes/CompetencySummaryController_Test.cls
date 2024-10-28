@istest
public class CompetencySummaryController_Test {
    Public static Student_Program__c sProg;
    Public static opportunity opp;
    Public static contact testCon;
    Public static Account acc;
    Public static Product2 prod;
    Public static Pricebook2 pBook;    
    
    static void setup() {
        
        acc = TestDataGenerator.createAccount(true);
        testCon = TestDataGenerator.createContact(acc, false);
        testCon.Carry_Over_Amount__c = 77;
        testCon.SSN__c = '238328923';
        insert testCon;
        
        Product2 parentProd = TestDataGenerator.createProduct('test', 'Walden', true);
        prod = TestDataGenerator.createProduct('test', 'Walden', false);
        prod.Parent_Program__c = parentProd.id;
        insert prod;
        
        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(false);
        psd.Program__c = prod.Id;
        psd.Accepting_New_Students__c = true;
        insert psd;
        
        opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = prod.Id;
        opp.Program_Start_Date__c = psd.Id;
        insert opp;
        
        sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.Program__c =prod.id;
        insert sProg;
        
        Id standardPricebookId = Test.getStandardPricebookId();
        PricebookEntry stdEntry = new PricebookEntry();
        stdEntry.IsActive = true;
        stdEntry.Product2Id = parentProd.Id;
        stdEntry.Pricebook2Id = standardPricebookId;
        stdEntry.UnitPrice = 5555.00;
        insert stdEntry;
        pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        
        
    }
    
    static testMethod void testMethodOne() {
        setup();
        
        Competency__c testComp = TestDataGenerator.createCompetency(2, true);
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);  
        
        Program_Expertise__c pExperise = TestDataGenerator.createProgramExpertise(aExper.ID,prod.ID,true,5.0,true);
        Program_Competency__c pCompetency = TestDataGenerator.createProgramCompetency(testComp.Id,prod.Id,true,4.0, false);
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, true);
        Student_Program__c studentProgram = TestDataGenerator.createStudentProgram(opty,testCon.ID, null, true);
        pCompetency.Program_Expertise__c = pExperise.ID;
        insert pCompetency;
        
        Program_Start_Date__c psDate = TestDataGenerator.createProgramStartDate(false); 
        psDate.Accepting_New_Students__c = true;
        psDate.Program__c = prod.ID;
        insert psDate;
        
        
        Student_Subscription__c currentSubscription = new Student_Subscription__c();
        currentSubscription.Student_Program__c = studentProgram.Id;
        currentSubscription.Start_Date__c = psDate.Start_Date__c;
        currentSubscription.End_Date__c = Utility.getSundayEndDateForStudentSubscription(4,currentSubscription.Start_Date__c);
        insert currentSubscription;
        
        
        Student_Expertise__c sExpertise = TestDataGenerator.createCompetencyExpertise(aExper.Id,null, false);
        list<Student_Competency__c> lstStudentCompetency = new list<Student_Competency__c>();
        Student_Competency__c sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency.Contact__c = testCon.id;
        sCometency.Program_Competency__c = pCompetency.ID;
        sCometency.Student_Expertise__c = sExpertise.ID;        
        sCometency.Student_Program__c = studentProgram.ID;
        sCometency.Status__c = 'Achieved';
        sCometency.IsCompleted__c =  true;
        sCometency.Completed_Date__c =  system.today().addDays(-3);
        sCometency.Student_Subscription_Achieved_In__c =  currentSubscription.id;
        lstStudentCompetency.add(sCometency);
        Student_Competency__c sCometency2 = TestDataGenerator.createStudentCompetency(pCompetency,testCon.id,true,'Walden', false, sExpertise);
        sCometency2.Contact__c = testCon.id;
        sCometency2.Student_Expertise__c = sExpertise.ID;
        sCometency2.Program_Competency__c = pCompetency.ID;
        sCometency2.Student_Program__c = studentProgram.ID;
        sCometency2.Status__c = 'Achieved';
        sCometency2.Student_Subscription_Achieved_In__c =  currentSubscription.id;
        sCometency2.IsCompleted__c =  true;
        sCometency2.Completed_Date__c =  system.today().addDays(+3);
        sCometency2.Completed_date__c  = system.today();


        lstStudentCompetency.add(sCometency2);
        insert lstStudentCompetency;
        
        Test.startTest();
        System.assert(CompetencySummaryController.getStudentProgramsFromCompetencies(testCon.Id).size()>0);
        CompetencySummaryController.getStudentCompetencies (testCon.Id,studentProgram.id,system.today().addDays(-3),system.today().addDays(+3),'Achieved','init');
        
        Test.stopTest();
    }
    
}