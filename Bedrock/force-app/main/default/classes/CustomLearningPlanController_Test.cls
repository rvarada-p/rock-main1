/*******************************************************************
Name  : CustomLearningPlanController_Test
Author: Virendra (Appirio)
Date  : October 10, 2014
Description: Test Class for CustomLearningPlanController
*************************************************************************/
@isTest
private class CustomLearningPlanController_Test {
    
    static testMethod void testLearningProgram() {
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
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
        sExpertise.Student_Program__c = studentProgram.Id;
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
        
        test.startTest();
           ApexPages.StandardController sc = new ApexPages.StandardController(studentProgram);
           CustomLearningPlanController custLPController  = new CustomLearningPlanController(sc);
           
           System.assertEquals(custLPController.mapStudentWithStudentProgram.size(),1); 
           System.assertEquals(custLPController.mapStudentProgramWithStudentExpertise.size(),1); 
           System.assertEquals(custLPController.mapStudentExpertiseWithStudentCompetency.size(),1); 
          
           PageReference pageRef = Page.CustomLearningPlan;
           Test.setCurrentPage(pageRef);
        test.stopTest();
    }

}