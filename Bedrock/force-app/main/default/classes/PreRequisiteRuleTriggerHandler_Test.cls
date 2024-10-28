/*******************************************************************
Name  : PreRequisiteRuleTriggerHandler_Test
Author: Ravitej Varada
Date  : Oct 13, 2018
Description: Test Class for the Handler class PreRequisiteRuleTriggerHandler and trigger PreRequisiteRuleTrigger.
Also Covering the test coverage of the helper class PreRequisiteRuleTriggerHelper
*************************************************************************/
@isTest
private class PreRequisiteRuleTriggerHandler_Test {
    
    public static student_program__c sProg;
    
    // This method will test the AND condition of Pre-Requisite rules
    static testMethod void testAfterUpdate1() {
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        
        Program_Category_Requirement__c  progCatReq1 = new Program_Category_Requirement__c();
        progCatReq1.Category__c =   'General Education';
        progCatReq1.Program__c  = product2.id;
        progCatReq1.Level__c    = 'Any';
        progCatReq1.Total_CE__c = 45.00;
        insert progCatReq1;
        
        Competency__c comp = TestDataGenerator.createCompetency('NUR1234', false);
        comp.Credit_Equivalency__c = 5.00;
        insert comp;
        
        Area_of_Expertise__c aExper1 = TestDataGenerator.createAreaOfExpertise(false);
        aExper1.Level__c = '3000';
        aExper1.Category__c = 'Core';
        aExper1.Type__c = 'Academic';
        aExper1.Condition_Rule__c  = 'OR';
        insert aExper1; 
        
        Area_of_Expertise__c aExper2 = TestDataGenerator.createAreaOfExpertise(false);	
        aExper1.Name ='Test Pre Req';
        aExper2.Type__c = 'Academic';
        aExper2.Condition_Rule__c  = 'OR';
        aExper2.Level__c = '2000';
        aExper2.Category__c = 'Core';
        insert aExper2;   
        
        Pre_requisite_Rules__c preReq = new Pre_requisite_Rules__c();
        preReq.Course_Name__c = aExper2.id;
        preReq.Area_of_Expertise__c = aExper1.id;
        insert preReq; 
        
        Competency_Expertise__c compExp1 = TestDataGenerator.createCompetencyExpertise(aExper1.Id, comp.id, null, true);
        opportunity testOpty1 = TestDataGenerator.createOpportunity(acc.id, testCon.id, 'Walden', false);
        insert testOpty1;    
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper1.Id,product2.id,true,4.0, true);
        Program_Competency__c testPComo = TestDataGenerator.createProgramCompetency(comp.Id,product2.Id,pExper.Id,true,4.0, false);
        testPComo.FWK_Id__c = '123';
        testPComo.IsTryBeforeYouBuy__c = true;        
        insert testPComo;
        sProg = TestDataGenerator.createStudentProgram(testOpty1, testCon.id, 'Walden', false);
        sProg.Program__c = product2.id;
        insert sProg;  
        
        Student_Expertise__c stuExp1 = TestDataGenerator.createCompetencyExpertise(aExper1.Id, 'Walden', false);
        stuExp1.Student_Program__c =  sProg.id;
        stuExp1.Is_Pre_Req_Lock__c  = true;
        stuExp1.Area_of_Expertise__c = aExper1.id;
        insert stuExp1;
        Pre_requisite_Rules__c preReq1 = new Pre_requisite_Rules__c();
        preReq1.Course_Name__c = aExper2.Id;
        preReq1.Area_of_Expertise__c = null;
        preReq1.IsAchieved__c = true;
        preReq1.Student_Expertise__c = stuExp1.id;
        insert preReq1;
        
        Test.startTest();
        	Student_Expertise__c stuExp2 = TestDataGenerator.createCompetencyExpertise(aExper2.Id, 'Walden', true);
            stuExp2.Student_Program__c =  sProg.id;
            update stuExp1;
            
        	stuExp2.IsAchieved__c = true;
            update  stuExp2;
            
            stuExp2.IsAchieved__c = false;
            update  stuExp2;
            
            aExper1.Condition_Rule__c  = 'AND';
            Update aExper1; 
            
            stuExp2.IsAchieved__c = true;
            update stuExp2;
        	
        	preReq.IsAchieved__c = true;
        	update preReq;
        
        	preReq1.IsAchieved__c = false;
        	update preReq1;
        	
        Test.stopTest();
    }
    
    // This method will test the OR condition of Pre-Requisite rules
    static testMethod void testAfterUpdate2() {
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        
        Program_Category_Requirement__c  progCatReq1 = new Program_Category_Requirement__c();
        progCatReq1.Category__c =   'General Education';
        progCatReq1.Program__c  = product2.id;
        progCatReq1.Level__c    = 'Any';
        progCatReq1.Total_CE__c = 45.00;
        insert progCatReq1;
        
        Competency__c comp = TestDataGenerator.createCompetency('NUR1234', false);
        comp.Credit_Equivalency__c = 5.00;
        insert comp;
        
        Area_of_Expertise__c aExper1 = TestDataGenerator.createAreaOfExpertise(false);
        aExper1.Level__c = '3000';
        aExper1.Category__c = 'Core';
        aExper1.Type__c = 'Academic';
        aExper1.Condition_Rule__c  = 'OR';
        insert aExper1; 
        
        Area_of_Expertise__c aExper2 = TestDataGenerator.createAreaOfExpertise(false);	
        aExper1.Name ='Test Pre Req';
        aExper2.Type__c = 'Academic';
        aExper2.Condition_Rule__c  = 'OR';
        aExper2.Level__c = '2000';
        aExper2.Category__c = 'Core';
        insert aExper2;   
        
        Pre_requisite_Rules__c preReq = new Pre_requisite_Rules__c();
        preReq.Course_Name__c = aExper2.id;
        preReq.Area_of_Expertise__c = aExper1.id;
        insert preReq; 
        
        Competency_Expertise__c compExp1 = TestDataGenerator.createCompetencyExpertise(aExper1.Id, comp.id, null, true);
        opportunity testOpty1 = TestDataGenerator.createOpportunity(acc.id, testCon.id, 'Walden', false);
        insert testOpty1;    
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper1.Id,product2.id,true,4.0, true);
        Program_Competency__c testPComo = TestDataGenerator.createProgramCompetency(comp.Id,product2.Id,pExper.Id,true,4.0, false);
        testPComo.FWK_Id__c = '123';
        testPComo.IsTryBeforeYouBuy__c = true;        
        insert testPComo;
        sProg = TestDataGenerator.createStudentProgram(testOpty1, testCon.id, 'Walden', false);
        sProg.Program__c = product2.id;
        insert sProg;  
        
        Student_Expertise__c stuExp1 = TestDataGenerator.createCompetencyExpertise(aExper1.Id, 'Walden', false);
        stuExp1.Student_Program__c =  sProg.id;
        stuExp1.Is_Pre_Req_Lock__c  = true;
        stuExp1.Area_of_Expertise__c = aExper1.id;
        insert stuExp1;
        Pre_requisite_Rules__c preReq1 = new Pre_requisite_Rules__c();
        preReq1.Course_Name__c = aExper2.Id;
        preReq1.Area_of_Expertise__c = null;
        preReq1.IsAchieved__c = false;
        preReq1.Student_Expertise__c = stuExp1.id;
        insert preReq1;
        
        Test.startTest();
        	Student_Expertise__c stuExp2 = TestDataGenerator.createCompetencyExpertise(aExper2.Id, 'Walden', true);
            stuExp2.Student_Program__c =  sProg.id;
            update stuExp1;
            
        	stuExp2.IsAchieved__c = true;
            update  stuExp2;
            
            stuExp2.IsAchieved__c = false;
            update  stuExp2;
            
            aExper1.Condition_Rule__c  = 'OR';
            Update aExper1; 
            
            stuExp2.IsAchieved__c = true;
            update stuExp2;
        	
        	preReq.IsAchieved__c = true;
        	update preReq;
        
        	preReq1.IsAchieved__c = true;
        	update preReq1;
        	
        Test.stopTest();
    }
    
}