@isTest
private class BatchPopulateGPAOnStudentProgram_Test {
    static testMethod void testPopulateGPAStudentPrgmBatch() {
        Account acc = TestDataGenerator.createAccount(true);
        
        Contact testCon = TestDataGenerator.createContact(acc, true);
        
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.Id;
        insert product2;
        
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', true);
        
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = Product2.Id;
        insert opp;
        
        Area_of_Expertise__c aoe= TestDataGenerator.createAreaOfExpertise(TRUE);
        update aoe;
        
        list<Competency__c> competencies = new list<Competency__c>();
        Competency__c newCompetency1 = TestDataGenerator.createCompetency('Comp1', false);
        newCompetency1.Type__c = 'Academic';
        Competency__c newCompetency2 = TestDataGenerator.createCompetency('Comp2', false);
        Competency__c newCompetency3 = TestDataGenerator.createCompetency('Comp3', false);
        newCompetency1.Code__c = 'PM000';
        newCompetency1.Credit_Equivalency__c = .25;
        newCompetency1.Published__c = false;
        newCompetency2.Credit_Equivalency__c = 3.25;
        newCompetency2.Published__c = false;
        newCompetency3.Credit_Equivalency__c = 3.75;
        newCompetency3.Published__c = false;
        competencies.add(newCompetency1);
        competencies.add(newCompetency2);
        competencies.add(newCompetency3);
        insert competencies;
        
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.IsStudentProgramActive__c = true; 
        insert sProg;
        
        Student_Expertise__c stuExpert = TestDataGenerator.createCompetencyExpertise(aoe.id,'Walden', false);
        stuExpert.Student_Program__c = sProg.Id;
        stuExpert.IsAchieved__c = true;
        insert stuExpert;
        
        list<Student_Competency__c> studentCompentencies = new list<Student_Competency__c>();
        Student_Competency__c sCompetency1 = TestDataGenerator.createStudentCompetency(sProg.id, newCompetency1.id, 'Walden', false);
        sCompetency1.clp_active__c = true;
        sCompetency1.IsCompleted__c = true;
        sCompetency1.Is_Enrolled__c = true;
        sCompetency1.Student_Expertise__c = stuExpert.Id;
        sCompetency1.status__c = 'Transferred';
        Student_Competency__c sCompetency2 = TestDataGenerator.createStudentCompetency(sProg.id, newCompetency2.id, 'Walden', false);
        sCompetency2.Student_Expertise__c = stuExpert.Id;
        sCompetency2.status__c = 'Achieved';
        Student_Competency__c sCompetency3 = TestDataGenerator.createStudentCompetency(sProg.id, newCompetency3.id, 'Walden', false);
        sCompetency3.Student_Expertise__c = stuExpert.Id;
        sCompetency3.status__c = 'Mastered';
        studentCompentencies.add(sCompetency1);
        studentCompentencies.add(sCompetency2);
        studentCompentencies.add(sCompetency3);
        insert studentCompentencies;
        
        Test.startTest();
        Database.executeBatch(new BatchPopulateGPAOnStudentProgram());
        Test.stopTest();   
    }
    static testMethod void testPopulateGPAStudentPrgmBatch2() {
        Account acc = TestDataGenerator.createAccount(true);
        
        Contact testCon = TestDataGenerator.createContact(acc, true);
        
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.Id;
        insert product2;
        
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', true);
        
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = Product2.Id;
        insert opp;
        
        Area_of_Expertise__c aoe= TestDataGenerator.createAreaOfExpertise(TRUE);
        update aoe;
        
        list<Competency__c> competencies = new list<Competency__c>();
        Competency__c newCompetency1 = TestDataGenerator.createCompetency('Comp1', false);
        newCompetency1.Type__c = 'Academic';
        Competency__c newCompetency2 = TestDataGenerator.createCompetency('Comp2', false);
        Competency__c newCompetency3 = TestDataGenerator.createCompetency('Comp3', false);
        newCompetency1.Code__c = 'PM000';
        newCompetency1.Credit_Equivalency__c = .25;
        newCompetency1.Published__c = false;
        newCompetency2.Credit_Equivalency__c = 5.25;
        newCompetency2.Published__c = false;
        newCompetency3.Credit_Equivalency__c = 12.75;
        newCompetency3.Published__c = false;
        competencies.add(newCompetency1);
        competencies.add(newCompetency2);
        competencies.add(newCompetency3);
        insert competencies;
        
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.IsStudentProgramActive__c = true; 
        sProg.GPA__c = null;
        insert sProg;
        
        Student_Expertise__c stuExpert = TestDataGenerator.createCompetencyExpertise(aoe.id,'Walden', false);
        stuExpert.Student_Program__c = sProg.Id;
        stuExpert.IsAchieved__c = true;
        insert stuExpert;
        
        list<Student_Competency__c> studentCompentencies = new list<Student_Competency__c>();
        Student_Competency__c sCompetency1 = TestDataGenerator.createStudentCompetency(sProg.id, newCompetency1.id, 'Walden', false);
        sCompetency1.clp_active__c = true;
        sCompetency1.IsCompleted__c = true;
        sCompetency1.Is_Enrolled__c = true;
        sCompetency1.Student_Expertise__c = stuExpert.Id;
        sCompetency1.status__c = 'Transferred';
        Student_Competency__c sCompetency2 = TestDataGenerator.createStudentCompetency(sProg.id, newCompetency2.id, 'Walden', false);
        sCompetency2.Student_Expertise__c = stuExpert.Id;
        sCompetency2.status__c = 'Achieved';
       
         Student_Competency__c sCompetency3 = TestDataGenerator.createStudentCompetency(sProg.id, newCompetency3.id, 'Walden', false);
        sCompetency3.Student_Expertise__c = stuExpert.Id;
        sCompetency3.status__c = 'Mastered';
        Student_Competency__c sCompetency4 = TestDataGenerator.createStudentCompetency(sProg.id, newCompetency3.id, 'Walden', false);
        sCompetency4.Student_Expertise__c = stuExpert.Id;
        sCompetency4.status__c = 'Fulfilled';
        studentCompentencies.add(sCompetency1);
        studentCompentencies.add(sCompetency2);
        studentCompentencies.add(sCompetency3);
        studentCompentencies.add(sCompetency4);
        insert studentCompentencies;
        
        sProg.GPA__c = null;
        update sProg;
        
        Test.startTest();        
        Database.executeBatch(new BatchPopulateGPAOnStudentProgram());
        Test.stopTest();       
    }
}