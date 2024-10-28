@isTest
private class TOCCurrentStateController_Test {
    
    static Account acc;
	static Contact cont;    
    static Opportunity opp;
    static Student_Program__c studentProgram;
    
    static void setup(String degreeLevel) {
        Product2 prod2 = TestDataGenerator.createProduct('Program', 'Walden', true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        
    	acc = TestDataGenerator.createAccount(true);
		cont = TestDataGenerator.createContact(acc, true);
		opp = TestDataGenerator.createOpportunity(acc.Id, cont.Id, 'Walden', true);
        studentProgram = TestDataGenerator.createStudentProgram(opp, cont.Id, 'Walden', true);
        prod2.Degree_Level__c = degreeLevel;
        prod2.Program_Guide_Link__c = 'www.tempo.waldem.edutest';
        prod2.name = 'BSN in Nursing';
        prod2.Parent_Program__c = parentProduct.id;
        update(prod2);
        
        studentProgram.program__c = prod2.id;
        update(studentProgram);
        
        opp.Student_Program__c = studentProgram.Id;
       
        update(opp);
	
        List<Area_of_Expertise__c> areaOfExpertiseList = new List<Area_of_Expertise__c>();
        List<Student_Expertise__c> studentExpertiseList = new List<Student_Expertise__c>();
        
		Area_of_Expertise__c areaOfExpertiseAhtr1990 = TestDataGenerator.createAreaOfExpertise(true);
		Student_Expertise__c studentExpertiseAhtr1990 = TestDataGenerator.createCompetencyExpertise(areaOfExpertiseAhtr1990.Id, 'Walden', true);
		areaOfExpertiseAhtr1990.pseudo_course__c = true;
        areaOfExpertiseAhtr1990.Display_Name__c = 'Arts and Humanities (AHTR 1990)';
        studentExpertiseAhtr1990.Pseudo_CE__c = 10.0;
		studentExpertiseAhtr1990.student_program__c = studentProgram.Id;

		Area_of_Expertise__c areaOfExpertiseCotr1990 = TestDataGenerator.createAreaOfExpertise(true);
		Student_Expertise__c studentExpertiseCotr1990 = TestDataGenerator.createCompetencyExpertise(areaOfExpertiseCotr1990.Id, 'Walden', true);
		areaOfExpertiseCotr1990.pseudo_course__c = true;
        areaOfExpertiseCotr1990.Display_Name__c = 'Communications (COTR 1990)';
        studentExpertiseCotr1990.Pseudo_CE__c = 15.0;
		studentExpertiseCotr1990.student_program__c = studentProgram.Id;

		Area_of_Expertise__c areaOfExpertiseEduc1101 = TestDataGenerator.createAreaOfExpertise(true);
		Student_Expertise__c studentExpertiseEduc1101 = TestDataGenerator.createCompetencyExpertise(areaOfExpertiseEduc1101.Id, 'Walden', true);
		areaOfExpertiseEduc1101.Pseudo_Course__c = false;
        areaOfExpertiseEduc1101.Display_Name__c = 'Becoming an Early Childhood Professional (EDUC 1101)';
        studentExpertiseEduc1101.pseudo_ce__c = 0.0;
        studentExpertiseEduc1101.student_program__c = studentProgram.Id;

		Area_of_Expertise__c areaOfExpertiseMath1030 = TestDataGenerator.createAreaOfExpertise(true);
		Student_Expertise__c studentExpertiseMath1030 = TestDataGenerator.createCompetencyExpertise(areaOfExpertiseMath1030.Id, 'Walden', true);
        areaOfExpertiseMath1030.pseudo_course__c = false;
        areaOfExpertiseMath1030.Display_Name__c = 'College Math(MATH 1030)';
        studentExpertiseMath1030.pseudo_ce__c = 0.0;
		studentExpertiseMath1030.student_program__c = studentProgram.Id;

		Area_of_Expertise__c areaOfExpertiseNurs3020 = TestDataGenerator.createAreaOfExpertise(true);
		Student_Expertise__c studentExpertiseNurs3020 = TestDataGenerator.createCompetencyExpertise(areaOfExpertiseNurs3020.Id, 'Walden', true);
        areaOfExpertiseNurs3020.Pseudo_Course__c = false;
        areaOfExpertiseNurs3020.Display_Name__c = 'Health Assessment (NURS 3020)';
        studentExpertiseNurs3020.Pseudo_CE__c = 0.0;
		studentExpertiseNurs3020.student_program__c = studentProgram.Id;

        areaOfExpertiseList.add(areaOfExpertiseAhtr1990);
        areaOfExpertiseList.add(areaOfExpertiseCotr1990);
        areaOfExpertiseList.add(areaOfExpertiseEduc1101);
        areaOfExpertiseList.add(areaOfExpertiseMath1030);
        areaOfExpertiseList.add(areaOfExpertiseNurs3020);
        
		studentExpertiseList.add(studentExpertiseAhtr1990);
		studentExpertiseList.add(studentExpertiseCotr1990);
		studentExpertiseList.add(studentExpertiseEduc1101);
		studentExpertiseList.add(studentExpertiseMath1030);
		studentExpertiseList.add(studentExpertiseNurs3020);
        
        //update(areaOfExpertiseList);
        //update(studentExpertiseList);
        
        List<Program_Expertise__c> programExpertiseList = new List<Program_Expertise__c>();
        
        Program_Expertise__c programExpertise1 = TestDataGenerator.createProgramExpertise(areaOfExpertiseAhtr1990.id, prod2.id, true, 1.0, true);
        programExpertise1.Category__c = 'General Education';
        
        Program_Expertise__c programExpertise2 = TestDataGenerator.createProgramExpertise(areaOfExpertiseCotr1990.id, prod2.id, true, 1.0, true);
        programExpertise2.Category__c = 'General Elective';
        
        Program_Expertise__c programExpertiseCore = TestDataGenerator.createProgramExpertise(areaOfExpertiseEduc1101.id, prod2.id, true, 1.0, true);
        programExpertiseCore.Category__c = 'Core';
        
        Program_Expertise__c programExpertise3 = TestDataGenerator.createProgramExpertise(areaOfExpertiseMath1030.id, prod2.id, true, 1.0, true);
        programExpertise3.Category__c = 'General Education';
        
        Program_Expertise__c programExpertiseGeneralElective = TestDataGenerator.createProgramExpertise(areaOfExpertiseNurs3020.id, prod2.id, true, 1.0, true);
        programExpertiseGeneralElective.Category__c = 'General Elective';
        
        programExpertiseList.add(programExpertise1);
        programExpertiseList.add(programExpertise2);
        programExpertiseList.add(programExpertiseCore);
        programExpertiseList.add(programExpertise3);
        programExpertiseList.add(programExpertiseGeneralElective);
        
        update(programExpertiseList);
        
        studentExpertiseAhtr1990.program_expertise__c = programExpertise1.id;
        studentExpertiseCotr1990.program_Expertise__c = programExpertise2.id;
        studentExpertiseEduc1101.program_Expertise__c = programExpertiseCore.id;
        studentExpertiseMath1030.program_Expertise__c = programExpertise3.id;
        studentExpertiseNurs3020.program_Expertise__c = programExpertiseGeneralElective.id;
        
        update(areaOfExpertiseList);
        update(studentExpertiseList);        
        
        Competency__c ahl010 = TestDataGenerator.createCompetency('AHL010', true);
        ahl010.Credit_Equivalency__c = 3.0;
        Competency__c bp1001 = TestDataGenerator.createCompetency('BP1001', true);
        bp1001.Credit_Equivalency__c = 3.0;
        Competency__c cm1001 = TestDataGenerator.createCompetency('CM1001', true);
        cm1001.Credit_Equivalency__c = 0.5;
        Competency__c cm1002 = TestDataGenerator.createCompetency('CM1002', true);
        cm1002.Credit_Equivalency__c = 0.5;
        Competency__c cm1003 = TestDataGenerator.createCompetency('CM1003', true);
        cm1003.Credit_Equivalency__c = 0.5;
        Competency__c cl0010 = TestDataGenerator.createCompetency('CL0010', true);
        cl0010.Credit_Equivalency__c = 0.75;
        Competency__c ha3001 = TestDataGenerator.createCompetency('HA3001', true);
        ha3001.Credit_Equivalency__c = 1;
                
        List<Student_Competency__c> studentCompetencies = new  List<Student_Competency__c>();
        Student_Competency__c ahtrSC1 = TestDataGenerator.createStudentCompetency(studentProgram.Id, ahl010.id, 'Walden', true);
        Student_Competency__c cotrSC1 = TestDataGenerator.createStudentCompetency(studentProgram.Id, cl0010.id, 'Walden', true);
        Student_Competency__c educSC1 = TestDataGenerator.createStudentCompetency(studentProgram.Id, bp1001.id, 'Walden', true);
        Student_Competency__c mathSC1 = TestDataGenerator.createStudentCompetency(studentProgram.Id, cm1001.id, 'Walden', true);
        Student_Competency__c mathSC2 = TestDataGenerator.createStudentCompetency(studentProgram.Id, cm1002.id, 'Walden', true);
        Student_Competency__c mathSC3 = TestDataGenerator.createStudentCompetency(studentProgram.Id, cm1003.id, 'Walden', true);
        Student_Competency__c nursSC1 = TestDataGenerator.createStudentCompetency(studentProgram.Id, ha3001.id, 'Walden', true);
        
        ahtrSC1.Student_Expertise__c = studentExpertiseAhtr1990.Id;
        ahtrSC1.Transferring_Institution__c = 'Harvard';
        ahtrSC1.Status__c = 'Transferred';
        
        cotrSC1.Student_Expertise__c = studentExpertiseCotr1990.Id;
        cotrSC1.Transferring_Institution__c = 'UoP';
        cotrSC1.Status__c = 'Preliminary Transfer';
        
        educSC1.Student_Expertise__c = studentExpertiseEduc1101.Id;
        educSC1.transferring_institution__c = 'Capella';
        educSC1.Status__c = 'Fulfilled';
        
        mathSC1.Student_Expertise__c = studentExpertiseMath1030.Id;
        mathSC1.Transferring_Institution__c = 'TEC';
        mathSC1.Status__c = 'Fulfilled';
        mathSC2.Student_Expertise__c = studentExpertiseMath1030.Id;
        mathSC2.Transferring_Institution__c = 'Oxford';
        mathSC2.Status__c = 'Fulfilled';
        mathSC3.Student_Expertise__c = studentExpertiseMath1030.Id;
        mathSC3.Transferring_Institution__c = 'Cambridge';
        mathSC3.Status__c = 'Fulfilled';
        
        nursSC1.Student_Expertise__c = studentExpertiseNurs3020.Id;
        nursSC1.Transferring_Institution__c = 'MIT';
        nursSC1.Status__c = 'Fulfilled';
        
        studentCompetencies.add(ahtrSC1);
        studentCompetencies.add(cotrSC1);
        studentCompetencies.add(educSC1);
        studentCompetencies.add(mathSC1);
        studentCompetencies.add(mathSC2);
        studentCompetencies.add(mathSC3);
        studentCompetencies.add(nursSC1);
        
        update(studentCompetencies);
        
        List<Competency_Expertise__c> competencyExpertiseList = new List<Competency_Expertise__c>();
        Competency_Expertise__c competencyExpertise1 = 
            TestDataGenerator.createCompetencyExpertise(areaOfExpertiseEduc1101.id , bp1001.id, 'Walden', true);
        competencyExpertise1.Credit_Equivalency__c = 2.0;
        Competency_Expertise__c competencyExpertise2 = 
            TestDataGenerator.createCompetencyExpertise(areaOfExpertiseMath1030.id , cm1001.id, 'Walden', true);
        competencyExpertise2.Credit_Equivalency__c = 1.5;
        Competency_Expertise__c competencyExpertise3 = 
            TestDataGenerator.createCompetencyExpertise(areaOfExpertiseMath1030.id , cm1002.id, 'Walden', true);
        competencyExpertise3.Credit_Equivalency__c = 1.0;
        Competency_Expertise__c competencyExpertise4 = 
            TestDataGenerator.createCompetencyExpertise(areaOfExpertiseMath1030.id , cm1003.id, 'Walden', true);
        competencyExpertise4.Credit_Equivalency__c = 0.75;
        Competency_Expertise__c competencyExpertise5 = 
            TestDataGenerator.createCompetencyExpertise(areaOfExpertiseNurs3020.id , ha3001.id, 'Walden', true);
        competencyExpertise5.Credit_Equivalency__c = 2.0;
        
        competencyExpertiseList.add(competencyExpertise1);
        competencyExpertiseList.add(competencyExpertise2);
        competencyExpertiseList.add(competencyExpertise3);
        competencyExpertiseList.add(competencyExpertise4);
        competencyExpertiseList.add(competencyExpertise5);
        
        update(competencyExpertiseList);
        update(areaOfExpertiseList);
    }
    
    static testMethod void testGetView() {
        setup('Undergrad');
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        ApexPages.currentPage().getParameters().put('spId', studentProgram.Id);
		Test.startTest();
        	TOCCurrentStateController controller = new TOCCurrentStateController(sc);
       	Test.stopTest();
        
        System.assertEquals(3, controller.categoryGroupingList.size());
        System.assertEquals(0.0, controller.totalPreliminaryTransferCE);
        System.assertEquals(0.0, controller.totalTransferredCE);
        System.assertEquals(7.25, controller.totalFulfilledCE);
    }
    
    static testMethod void testGetViewGraduate() {
        setup('Graduate');
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        ApexPages.currentPage().getParameters().put('spId', studentProgram.Id);
		Test.startTest();
        	TOCCurrentStateController controller = new TOCCurrentStateController(sc);
       	Test.stopTest();
        
        System.assertEquals(1, controller.categoryGroupingList.size());
    }

}