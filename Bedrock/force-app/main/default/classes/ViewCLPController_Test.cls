/*******************************************************************
Name  : ViewCLPController
Author: Sarah (Laureate)
Date  : December 16, 2015
Description: Test Class for ViewCLPController
*************************************************************************/

@isTest
private class ViewCLPController_Test {
    static testMethod void testViewCLPController() {
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
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
        
        // create student competency
        list<Student_Competency__c> lstStudentCompetency = new list<Student_Competency__c>();
        Student_Competency__c sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency.Contact__c = testCon.id;
        sCometency.Program_Competency__c = pCompetemcy.ID;
        sCometency.Student_Expertise__c = sExpertise.ID;
        sCometency.Student_Program__c = studentProgram.ID;
        sCometency.Status__c = 'Achieved';
        sCometency.IsCompleted__c = true;
        sCometency.clp_active__c = true;
        lstStudentCompetency.add(sCometency);
        Student_Competency__c sCometency2 = TestDataGenerator.createStudentCompetency(testComp2.id,'Walden', false);
        sCometency2.Contact__c = testCon.id;
        sCometency2.Student_Expertise__c = sExpertise.ID;
        sCometency2.Program_Competency__c = pCompetemcy2.ID;
        sCometency2.Student_Program__c = studentProgram.ID;
        sCometency2.IsCompleted__c  = true;
        sCometency2.Status__c = 'Registered';
        sCometency2.clp_active__c  = true;
        lstStudentCompetency.add(sCometency2);
        insert lstStudentCompetency;

        
        ApexPages.StandardController sc = new ApexPages.standardController(studentProgram);
        
        ViewCLPController generateTCtrl = new ViewCLPController(sc);
        generateTCtrl.TBYBCredits1 = 3.0; 
        generateTCtrl.calculateSAP();         
    }
}