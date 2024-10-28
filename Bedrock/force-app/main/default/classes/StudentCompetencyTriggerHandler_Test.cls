/*******************************************************************
Name  : StudentCompetencyTriggerHandler
Author: Vinod (Appirio)
Date  : September 22, 2014
Description: Test Class for the Handler class StudentCompetencyTriggerHandler and trigger StudentCompetencyTrigger.
            Also Covering the test coverage of the helper class StudentCompetencyHelper
*************************************************************************/
@isTest
private class StudentCompetencyTriggerHandler_Test {

    public static list<Student_Competency__c> studentCompetencies;

    static testMethod void testBeforeInsert() {
        // Create test data
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Competency', 'Student_Competency__c','Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
	    Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);        
	    Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
	    product2.Parent_Program__c = parentProduct.Id;
	    insert product2;    
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);  
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Program_Expertise__c pExperise = TestDataGenerator.createProgramExpertise(aExper.ID,product2.ID,true,5.0,true);
        Program_Competency__c pCompetemcy = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0, false);
        pCompetemcy.Program_Expertise__c = pExperise.ID;
        insert pCompetemcy;
        Student_Expertise__c sExpertise = TestDataGenerator.createCompetencyExpertise(aExper.Id,null, false);
        sExpertise.Contact__c = testCon.id;
        sExpertise.Program_Expertise__c = pExperise.ID;
        insert sExpertise;
        // create strudent competency
        Student_Competency__c sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency.Contact__c = testCon.id;
        sCometency.Program_Competency__c = pCompetemcy.ID;
        insert sCometency;
        // check Student_Expertise__c is populated or not
        Student_Competency__c updatedStudentCometency = [Select ID,Student_Expertise__c from Student_Competency__c where id = :sCometency.ID];
        system.assertEquals(updatedStudentCometency.Student_Expertise__c, sExpertise.ID);
    }
    static testMethod void testAfterUpdate() {
        // Create test data
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Competency', 'Student_Competency__c','Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
	    Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);        
	    Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
	    product2.Parent_Program__c = parentProduct.Id;
	    insert product2;    
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);  
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Program_Expertise__c pExperise = TestDataGenerator.createProgramExpertise(aExper.ID,product2.ID,true,5.0,true);
        Program_Competency__c pCompetemcy = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0, false);
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, true);
        Student_Program__c studentProgram = TestDataGenerator.createStudentProgram(opty,testCon.ID, null, true);
        pCompetemcy.Program_Expertise__c = pExperise.ID;
        insert pCompetemcy;
        Student_Expertise__c sExpertise = TestDataGenerator.createCompetencyExpertise(aExper.Id,null, false);
        sExpertise.Contact__c = testCon.id;
        sExpertise.Program_Expertise__c = pExperise.ID;
        insert sExpertise;
        // create strudent competency
        list<Student_Competency__c> lstStudentCompetency = new list<Student_Competency__c>();
        Student_Competency__c sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency.Contact__c = testCon.id;
        sCometency.Program_Competency__c = pCompetemcy.ID;
        sCometency.Student_Expertise__c = sExpertise.ID;
        sCometency.Student_Program__c = studentProgram.ID;
        lstStudentCompetency.add(sCometency);
        Student_Competency__c sCometency2 = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency2.Contact__c = testCon.id;
        sCometency2.Student_Expertise__c = sExpertise.ID;
        sCometency2.Program_Competency__c = pCompetemcy.ID;
        sCometency2.Student_Program__c = studentProgram.ID;
        lstStudentCompetency.add(sCometency2);
        insert lstStudentCompetency;
        // update the status of the first competency
        sCometency.Status__c = 'Achieved';
        sCometency.IsCompleted__c = true;
        update sCometency;
        Student_Expertise__c updatedSExpertise = [Select ID,Number_of_Competencies_Completed__c from Student_Expertise__c where id = :sExpertise.ID];
        system.assert(updatedSExpertise.Number_of_Competencies_Completed__c == 1);
        // update the status of the second competency
        sCometency2.Status__c = 'Achieved';
        sCometency2.IsCompleted__c = true;
        sCometency2.Target_Date__c = system.today();
        update sCometency2;
        updatedSExpertise = [Select ID,Number_of_Competencies_Completed__c from Student_Expertise__c where id = :sExpertise.ID];
        system.assert(updatedSExpertise.Number_of_Competencies_Completed__c == 2);
    }
    static testMethod void testAfterDelete() {
        // Create test data
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Competency', 'Student_Competency__c','Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
	    Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);        
	    Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
	    product2.Parent_Program__c = parentProduct.Id;
	    insert product2;    
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);  
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, true);
        Program_Expertise__c pExperise = TestDataGenerator.createProgramExpertise(aExper.ID,product2.ID,true,5.0,true);
        Program_Competency__c pCompetemcy = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0, false);
        pCompetemcy.Program_Expertise__c = pExperise.ID;
        insert pCompetemcy;
        Student_Program__c studentProgram = TestDataGenerator.createStudentProgram(opty,testCon.ID, null, true);
        Student_Expertise__c sExpertise = TestDataGenerator.createCompetencyExpertise(aExper.Id,null, false);
        sExpertise.Contact__c = testCon.id;
        sExpertise.Program_Expertise__c = pExperise.ID;
        insert sExpertise;
        // create strudent competency
        list<Student_Competency__c> lstStudentCompetency = new list<Student_Competency__c>();
        Student_Competency__c sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency.Contact__c = testCon.id;
        sCometency.Program_Competency__c = pCompetemcy.ID;
        sCometency.Student_Expertise__c = sExpertise.ID;
        sCometency.Status__c = 'Achieved';
        sCometency.IsCompleted__c = true;
        sCometency.Student_Program__c = studentProgram.ID;
        lstStudentCompetency.add(sCometency);
        Student_Competency__c sCometency2 = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency2.Contact__c = testCon.id;
        sCometency2.Student_Expertise__c = sExpertise.ID;
        sCometency2.Program_Competency__c = pCompetemcy.ID;
        sCometency2.Status__c = 'Achieved';
        sCometency2.IsCompleted__c = true;
        sCometency2.Student_Program__c = studentProgram.ID;
        lstStudentCompetency.add(sCometency2);
        insert lstStudentCompetency;
        // delete sCometency2
        delete sCometency2;        
        Student_Program__c updatedStudentProgram = [Select ID,Number_of_Competencies__c from Student_Program__c where id = : studentProgram.ID];
        system.debug('updatedStudentProgram.Number_of_Competencies__c::::::::'+updatedStudentProgram.Number_of_Competencies__c);
        system.assert(updatedStudentProgram.Number_of_Competencies__c == 1);
    }
    static testMethod void testRollUpNumberOfCompletedCompetenciesOnCurrentStudentSubscription() {
        // Create test data
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Competency', 'Student_Competency__c','Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
	    Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);        
	    Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
	    product2.Parent_Program__c = parentProduct.Id;
	    insert product2;    
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);
        // Fix 4/10/15 - create competency with credits
        Competency__c testComp = TestDataGenerator.createCompetency(2, true);
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false);
        opty.Primary_Program__c = product2.Id;
        //opty.Actual_Start_Date__c = Date.today();        
        Program_Start_Date__c tstStartDate  = TestDataGenerator.createProgramStartDate(false);
        tstStartDate.Program__c = product2.Id;
        insert tstStartDate;
        opty.Program_Start_Date__c = tstStartDate.Id;
        insert opty;
        Program_Expertise__c pExperise = TestDataGenerator.createProgramExpertise(aExper.ID,product2.ID,true,5.0,true);
        Program_Competency__c pCompetemcy = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0, false);
        pCompetemcy.Program_Expertise__c = pExperise.ID;
        insert pCompetemcy;
        Student_Program__c studentProgram = TestDataGenerator.createStudentProgram(opty,testCon.ID, null, false);
        studentProgram.Program_Start_Date__c = tstStartDate.Id;
        insert studentProgram;
        Student_Expertise__c sExpertise = TestDataGenerator.createCompetencyExpertise(aExper.Id,null, false);
        sExpertise.Contact__c = testCon.id;
        sExpertise.Program_Expertise__c = pExperise.ID;
        insert sExpertise;
        //
        Program_Start_Date__c pStartDate = [Select Id, Start_Date__c from Program_Start_Date__c where Id = :tstStartDate.Id];
        Student_Subscription__c currentSubscription = new Student_Subscription__c();
        currentSubscription.Student_Program__c = studentProgram.Id;
        currentSubscription.Start_Date__c = pStartDate.Start_Date__c;
        currentSubscription.End_Date__c = Utility.getSundayEndDateForStudentSubscription(4,currentSubscription.Start_Date__c);
        insert currentSubscription;
        // create strudent competency
        list<Student_Competency__c> lstStudentCompetency = new list<Student_Competency__c>();
        Student_Competency__c sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency.Contact__c = testCon.id;
        sCometency.Program_Competency__c = pCompetemcy.ID;
        sCometency.Student_Expertise__c = sExpertise.ID;        
        sCometency.Student_Program__c = studentProgram.ID;
        lstStudentCompetency.add(sCometency);
        Student_Competency__c sCometency2 = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency2.Contact__c = testCon.id;
        sCometency2.Student_Expertise__c = sExpertise.ID;
        sCometency2.Program_Competency__c = pCompetemcy.ID;
        sCometency2.Student_Program__c = studentProgram.ID;
        lstStudentCompetency.add(sCometency2);
        insert lstStudentCompetency;
        sCometency2.Status__c = 'Achieved';
        sCometency2.IsCompleted__c = true;
        sCometency2.Completed_Date__c = currentSubscription.Start_Date__c;
        update sCometency2;
        Student_Subscription__c updatedStudentSubscription = [Select ID,Number_of_Competencies_Completed__c from Student_Subscription__c where id = : currentSubscription.ID];
        //system.assert(updatedStudentSubscription.Number_of_Competencies_Completed__c == 1);
        system.debug(updatedStudentSubscription.Number_of_Competencies_Completed__c);
        sCometency.Status__c = 'Achieved';
        sCometency.IsCompleted__c = true;
        sCometency.Completed_Date__c = currentSubscription.Start_Date__c;
        update sCometency;
        updatedStudentSubscription = [Select ID,Number_of_Competencies_Completed__c from Student_Subscription__c where id = : currentSubscription.ID];
        //system.assert(updatedStudentSubscription.Number_of_Competencies_Completed__c == 2);
        system.debug(updatedStudentSubscription.Number_of_Competencies_Completed__c);
    }

    /*static testMethod void testNonAcademicStudentCompetencyCompletedChecked() {
        
        Integer index= 0;

        createTestData();
        
        List<Student_Competency__c> studentCompetency = [SELECT Id, IsCompleted__c, Student_Program__c 
                                                         FROM Student_Competency__c];
        Test.startTest();

        for(Student_Competency__c stuComp : studentCompetency) {
            if(math.mod(index, 2) == 0) {
                stuComp.IsCompleted__c = true;
            }
        }

        update studentCompetency;

        for(Student_Program__c studentPrograms : [SELECT Id, Non_Academic_Competencies_Completed__c FROM Student_Program__c]) {
            system.assertEquals(studentPrograms.Non_Academic_Competencies_Completed__c, 5);
        }

        for(Student_Competency__c stuComp : studentCompetency) {
            if(math.mod(index, 2) == 0) {
                stuComp.IsCompleted__c = false;
            }
        }

        update studentCompetency;

        for(Student_Program__c studentPrograms : [SELECT Id, Non_Academic_Competencies_Completed__c FROM Student_Program__c]) {
            //system.assertEquals(studentPrograms.Non_Academic_Competencies_Completed__c, 0);
        }

        Test.stopTest();
    }*/

    public static void createTestData() {
        studentCompetencies = new list<Student_Competency__c>();
        
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Competency', 'Student_Competency__c','Walden', true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
	    Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);        
	    Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
	    product2.Parent_Program__c = parentProduct.Id;
	    insert product2;    
	            
        Competency__c testComp1 = TestDataGenerator.createCompetency(2, false);
        Competency__c testComp2 = TestDataGenerator.createCompetency(false);
        testComp2.Type__c = 'Skill';

        List<Competency__c> competencies = new List<Competency__c>{testComp1, testComp2};
        insert competencies;
        
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false);
        opty.Primary_Program__c = product2.Id;
        
        Program_Start_Date__c tstStartDate  = TestDataGenerator.createProgramStartDate(false);
        tstStartDate.Program__c = product2.Id;
        insert tstStartDate;
        
        opty.Program_Start_Date__c = tstStartDate.Id;
        insert opty;
        
        Student_Program__c studentProgram1 = TestDataGenerator.createStudentProgram(opty,testCon.ID, null, false);
        studentProgram1.Program_Start_Date__c = tstStartDate.Id;
        
        Student_Program__c studentProgram2 = TestDataGenerator.createStudentProgram(opty,testCon.ID, null, false);
        studentProgram2.Program_Start_Date__c = tstStartDate.Id;
        List<Student_Program__c> studentPrograms = new List<Student_Program__c>{studentProgram1, studentProgram2};
        insert studentPrograms;
        
        Program_Start_Date__c pStartDate = [Select Id, Start_Date__c from Program_Start_Date__c where Id = :tstStartDate.Id];

        // create strudent competency
        
        Student_Competency__c sCometency1;

        for(Integer i = 0; i <  10; i++) {
            if(i < 5) {
                sCometency1 = TestDataGenerator.createStudentCompetency(testComp1.id,'Walden', false);
                sCometency1.Contact__c = testCon.id;
                sCometency1.Student_Program__c = studentProgram1.ID;
            } else {
                sCometency1 = TestDataGenerator.createStudentCompetency(testComp2.id,'Walden', false);
                sCometency1.Contact__c = testCon.id;
                sCometency1.Student_Program__c = studentProgram1.ID;
            }
            studentCompetencies.add(sCometency1);
        }
        
        for(Integer i = 0; i <  10; i++) {
            if(i < 5) {
                sCometency1 = TestDataGenerator.createStudentCompetency(testComp1.id,'Walden', false);
                sCometency1.Contact__c = testCon.id;
                sCometency1.Student_Program__c = studentProgram2.ID;
            } else {
                sCometency1 = TestDataGenerator.createStudentCompetency(testComp2.id,'Walden', false);
                sCometency1.Contact__c = testCon.id;
                sCometency1.Student_Program__c = studentProgram2.ID;
            }
            studentCompetencies.add(sCometency1);
        }

        
        insert studentCompetencies;
    }
}