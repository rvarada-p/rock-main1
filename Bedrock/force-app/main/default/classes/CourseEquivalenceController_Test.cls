@isTest
private class CourseEquivalenceController_Test {
    
    static Account acc;
	static Contact con;    
    static Opportunity opp;
    static Area_of_Expertise__c aoeStat3001;
    
    static void setup() {
    	/*acc = TestDataGenerator.createAccount(true);
		cont = TestDataGenerator.createContact(acc, true);
		opp = TestDataGenerator.createOpportunity(acc.Id, cont.Id, 'Walden', true);
        Institution__c institution = TestDataGenerator.createInstitution('Walden', true);
        Product2 prod = new Product2();
        //prod.Parent_Program__c = parentProgramCodeAndIdMap.get(programCodeProgramMap.get(key).parentProgramCode);
        //prod.ProductCode = programCodeProgramMap.get(key).programCode;
        prod.Name = 'Test 1';
        prod.Display_Name__c = 'Test 1'; 
        prod.ProductCode = 'Test_11';
        prod.Outcome__c = 'Bachelor';
        prod.Program_Major__c = 'Project Management';
        prod.Degree_Level__c = 'Undergrad';
        prod.Institution__c = institution.id;
        
        prod.Credit_Type__c = 'Quarter';
        prod.Total_Credits_in_Program__c = 80;
        prod.Credit_Progression_Rate__c = 4.5;
        prod.Maximum_Transfer_Credits__c = 80;
        prod.Required_Upper_Level_Credits__c = 55;
        prod.Required_Institution_Credits__c = 45;
        prod.Required_Transfer_Credits__c = 40;
        prod.Effective_From_Date__c = Date.today(); // not from file
        prod.Effective_To_Date__c = Date.today().addYears(5); //not from file
        prod.Family = 'CBL'; // Not from file
        prod.Publish_to_LMS__c = true; // Not from file
        insert(prod);
     
        Student_Program__c studentProgram = TestDataGenerator.createStudentProgram(opp, cont.Id, 'Walden', false);
        studentProgram.Program__c = prod.id;
        insert(studentProgram);
        
        opp.Student_Program__c = studentProgram.Id;
        update(opp);*/
        
        acc = new Account(name='Test Account');
        insert acc;
     
        con=new Contact(FirstName='fname',LastName = 'lname',Email = 'email@gmail.com',Phone = '9743800309'); 
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
        
        opp = new Opportunity(Account=acc,StageName='New',Name='Opp name',CloseDate=system.today(),Student_Program__c=studentProgram.id, primary_program__c=prod1.id);
        insert opp;
        
        studentProgram.Program__c = prod1.id;
        update studentProgram;
        
        //List<Student_Program__c> studentPrograms = new List<Student_Program__c>();
        //studentPrograms = [select id,name,program__r.degree_level__c from Student_Program__c where id =: studentProgram.id ];
        
        
        aoeStat3001 = new Area_of_Expertise__c(Name='Statistical Methods and Applications (STAT 3001)', Display_name__c='Statistical Methods and Applications (STAT 3001)');
        insert aoeStat3001;
        
        TOC_GenEds_By_Program__c defaultCustomSetngs = new TOC_GenEds_By_Program__c();
        defaultCustomSetngs.Name = 'Programs';
        defaultCustomSetngs.C_BSECS__c = 'MATH 1030,ENGL 1015,STAT 3001';
        insert defaultCustomSetngs;
        
        Competency__c comp1 = TestDataGenerator.createCompetency(true);
        Competency_Expertise__c competencyExpertise1 = TestDataGenerator.createCompetencyExpertise(aoeStat3001.id, comp1.id, 'Walden', true);
        Competency_Expertise__c competencyExpertise2 = TestDataGenerator.createCompetencyExpertise(aoeStat3001.id, comp1.id, 'Walden', true);
	
        List<Area_of_Expertise__c> areaOfExpertiseList = new List<Area_of_Expertise__c>();
        List<Student_Expertise__c> studentExpertiseList = new List<Student_Expertise__c>();
        
		Area_of_Expertise__c areaOfExpertiseAhtr1990 = TestDataGenerator.createAreaOfExpertise(true);
		Student_Expertise__c studentExpertiseAhtr1990 = TestDataGenerator.createCompetencyExpertise(areaOfExpertiseAhtr1990.Id, 'Walden', true);
		areaOfExpertiseAhtr1990.pseudo_course__c = true;
		studentExpertiseAhtr1990.student_program__c = studentProgram.Id;

		Area_of_Expertise__c areaOfExpertiseCotr1990 = TestDataGenerator.createAreaOfExpertise(true);
		Student_Expertise__c studentExpertiseCotr1990 = TestDataGenerator.createCompetencyExpertise(areaOfExpertiseCotr1990.Id, 'Walden', true);
		areaOfExpertiseCotr1990.pseudo_course__c = true;
		studentExpertiseCotr1990.student_program__c = studentProgram.Id;

		Area_of_Expertise__c areaOfExpertiseEduc1101 = TestDataGenerator.createAreaOfExpertise(true);
		Student_Expertise__c studentExpertiseEduc1101 = TestDataGenerator.createCompetencyExpertise(areaOfExpertiseEduc1101.Id, 'Walden', true);
		studentExpertiseEduc1101.student_program__c = studentProgram.Id;

		Area_of_Expertise__c areaOfExpertiseMath1030 = TestDataGenerator.createAreaOfExpertise(true);
		Student_Expertise__c studentExpertiseMath1030 = TestDataGenerator.createCompetencyExpertise(areaOfExpertiseMath1030.Id, 'Walden', true);
		studentExpertiseMath1030.student_program__c = studentProgram.Id;

		Area_of_Expertise__c areaOfExpertiseNurs3020 = TestDataGenerator.createAreaOfExpertise(true);
		Student_Expertise__c studentExpertiseNurs3020 = TestDataGenerator.createCompetencyExpertise(areaOfExpertiseNurs3020.Id, 'Walden', true);
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
        
        update(areaOfExpertiseList);
        update(studentExpertiseList);
        
        Competency__c ahl010 = TestDataGenerator.createCompetency('AHL010', true);
        Competency__c bp1001 = TestDataGenerator.createCompetency('BP1001', true);
        Competency__c cm1001 = TestDataGenerator.createCompetency('CM1001', true);
        Competency__c cm1002 = TestDataGenerator.createCompetency('CM1002', true);
        Competency__c cm1003 = TestDataGenerator.createCompetency('CM1003', true);
        Competency__c cl0010 = TestDataGenerator.createCompetency('CL0010', true);
        Competency__c ha3001 = TestDataGenerator.createCompetency('HA3001', true);
        
        List<Student_Competency__c> studentCompetencies = new  list<Student_Competency__c>();
        Student_Competency__c ahtrSC1 = TestDataGenerator.createStudentCompetency(studentProgram.Id, ahl010.id, 'Walden', true);
        Student_Competency__c cotrSC1 = TestDataGenerator.createStudentCompetency(studentProgram.Id, cl0010.id, 'Walden', true);
        Student_Competency__c educSC1 = TestDataGenerator.createStudentCompetency(studentProgram.Id, bp1001.id, 'Walden', true);
        Student_Competency__c mathSC1 = TestDataGenerator.createStudentCompetency(studentProgram.Id, cm1001.id, 'Walden', true);
        Student_Competency__c mathSC2 = TestDataGenerator.createStudentCompetency(studentProgram.Id, cm1002.id, 'Walden', true);
        Student_Competency__c mathSC3 = TestDataGenerator.createStudentCompetency(studentProgram.Id, cm1003.id, 'Walden', true);
        Student_Competency__c nursSC1 = TestDataGenerator.createStudentCompetency(studentProgram.Id, ha3001.id, 'Walden', true);
        
        ahtrSC1.Student_Expertise__c = studentExpertiseAhtr1990.Id;
        ahtrSC1.Transferring_Institution__c = 'Harvard';
        ahtrSC1.Status__c = 'Registered';
        
        cotrSC1.Student_Expertise__c = studentExpertiseCotr1990.Id;
        cotrSC1.Status__c = 'Preliminary Transfer';
        
        educSC1.Student_Expertise__c = studentExpertiseEduc1101.Id;
        educSC1.Status__c = 'Registered';
        
        mathSC1.Student_Expertise__c = studentExpertiseMath1030.Id;
        mathSC1.Status__c = 'Registered';
        mathSC2.Student_Expertise__c = studentExpertiseMath1030.Id;
        mathSC2.Status__c = 'Preliminary Transfer';
        mathSC3.Student_Expertise__c = studentExpertiseMath1030.Id;
        mathSC3.Status__c = 'Registered';
        
        nursSC1.Student_Expertise__c = studentExpertiseNurs3020.Id;
        nursSC1.Status__c = 'Registered';
        
                
        studentCompetencies.add(ahtrSC1);
        studentCompetencies.add(cotrSC1);
        studentCompetencies.add(mathSC1);
        studentCompetencies.add(mathSC2);
        studentCompetencies.add(mathSC3);
        
        update(studentCompetencies);
    }
	
    static testMethod void testGetItems() {
        setup();
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
		CourseEquivalenceController controller = new CourseEquivalenceController(sc);
        Test.startTest();
            List<SelectOption> options = controller.getItems();
        Test.stopTest();
    
        System.assertNotEquals(null, options, 'The collection should be instantiated');
        System.assert(!options.isEmpty(), 'The collection should be populated');
    }
    
    static testMethod void testGetConferredDegreeItems() {
     	setup();
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
		CourseEquivalenceController controller = new CourseEquivalenceController(sc);
        Test.startTest();
            List<SelectOption> options = controller.getConferredDegreeItems();
        Test.stopTest();
    
        System.assertNotEquals(null, options, 'The collection should be instantiated');
        System.assert(!options.isEmpty(), 'The collection should be populated');   
    }
    
    static testMethod void testGetGradeValues() {
     	setup();
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
		CourseEquivalenceController controller = new CourseEquivalenceController(sc);
        Test.startTest();
            List<SelectOption> options = controller.getGradeValues();
        Test.stopTest();
    
        System.assertNotEquals(null, options, 'The collection should be instantiated');
        System.assert(!options.isEmpty(), 'The collection should be populated');   
    }
    
    static testMethod void testSetCreditTypeFlag() {
        setup();
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
		CourseEquivalenceController controller = new CourseEquivalenceController(sc);
        Test.startTest();
        	controller.selectedCreditType = 'FLIP TO OFFICIAL TRANSFER';
        	controller.setCreditTypeFlag();
        	System.assertEquals(false, controller.displayInstitutionInput);
        	System.assertEquals(true, controller.isFlipToOfficialTransfer);
	        System.assertEquals(false, controller.isFromMultipleInstitutions);
        	System.assertEquals(false, controller.displayConferredDegreePicklist);
        	System.assertEquals(false, controller.displayMultipleTranscriptsSelect);
        	controller.selectedCreditType = 'NONE';
        	controller.setCreditTypeFlag();
        	System.assertEquals(false, controller.displayInstitutionInput);
        	System.assertEquals(false, controller.isFlipToOfficialTransfer);
	        System.assertEquals(false, controller.isFromMultipleInstitutions);
        	System.assertEquals(false, controller.displayConferredDegreePicklist);
        	System.assertEquals(false, controller.displayMultipleTranscriptsSelect);
        	controller.selectedCreditType = 'Fulfilled';
        	controller.setCreditTypeFlag();
        	System.assertEquals(false, controller.displayInstitutionInput);
        	System.assertEquals(false, controller.isFlipToOfficialTransfer);
	        System.assertEquals(false, controller.isFromMultipleInstitutions);
        	System.assertEquals(true, controller.displayConferredDegreePicklist);
        	System.assertEquals(false, controller.displayMultipleTranscriptsSelect);
        	controller.selectedCreditType = 'ELSE';
        	controller.setCreditTypeFlag();
        	System.assertEquals(false, controller.displayInstitutionInput);
        	System.assertEquals(false, controller.isFlipToOfficialTransfer);
	        System.assertEquals(false, controller.isFromMultipleInstitutions);
        	System.assertEquals(false, controller.displayConferredDegreePicklist);
        	System.assertEquals(false, controller.displayMultipleTranscriptsSelect);
        	controller.selectedCreditType = 'Transferred';
        	controller.selectedMultipleTranscripts = 'Yes';
        	controller.setCreditTypeFlag();
        	System.assertEquals(false, controller.displayInstitutionInput);
        	System.assertEquals(false, controller.isFlipToOfficialTransfer);
	        System.assertEquals(true, controller.isFromMultipleInstitutions);
        	System.assertEquals(false, controller.displayConferredDegreePicklist);
        	System.assertEquals(true, controller.displayMultipleTranscriptsSelect);
        	controller.selectedCreditType = 'Transferred';
        	controller.selectedMultipleTranscripts = 'No';
        	controller.setCreditTypeFlag();
        	System.assertEquals(true, controller.displayInstitutionInput);
        	System.assertEquals(false, controller.isFlipToOfficialTransfer);
	        System.assertEquals(true, controller.isFromMultipleInstitutions);
        	System.assertEquals(false, controller.displayConferredDegreePicklist);
        	System.assertEquals(true, controller.displayMultipleTranscriptsSelect);
        Test.stopTest();
        	
    }
    
	static testMethod void testGetProgramCourses() {
        setup();
		Test.startTest();
			PageReference pageRef = Page.CourseEquivalence;
           	Test.setCurrentPage(pageRef);
        	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
	        ApexPages.currentPage().getParameters().put('id', opp.Id);
			CourseEquivalenceController controller = new CourseEquivalenceController(sc);
			controller.setInitialValues();
        	controller.selectedCreditType = 'Fulfilled';
        	controller.selectedConferredDegree = 'Yes';
			controller.getProgramCourses();
			System.assertEquals(false, controller.displayGradePicklist);
        	System.assertEquals(5, controller.priorStudentExpertiseList.size());
        	controller.setInitialValues();
          	controller.selectedCreditType = 'Fulfilled';
        	controller.selectedConferredDegree = 'No';
        	controller.getProgramCourses();
        	System.assertEquals(true, controller.displayGradePicklist, 'Display Grade picklist is not true');
        	System.assertEquals(5, controller.priorStudentExpertiseList.size(), 'Prior Student Expertise size is not 5');
		Test.stopTest();
	}
    
    static testMethod void testFlipToTransfer() {
        setup();
        Test.startTest();
        	PageReference pageRef = Page.CourseEquivalence;
           	Test.setCurrentPage(pageRef);
        	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
	        ApexPages.currentPage().getParameters().put('id', opp.Id);
			CourseEquivalenceController controller = new CourseEquivalenceController(sc);
        	controller.setInitialValues();
        	controller.selectedCreditType = 'Preliminary Transfer';
        	controller.getCoursesToFlipToTransfer();
        	System.assertEquals(true, controller.isFlipToOfficialTransfer);
        	System.assertEquals(2, controller.studentCompetencyDetailsList.size());
        	controller.studentCompetencyDetailsList[0].isSelected = true;
        	controller.flipToTransfer();
        Test.stopTest();
    }
    
    static testMethod void testGoToConfirmationUpdatePage() {
        setup();
        Test.startTest();
        	PageReference pageRef = Page.CourseEquivalence;
           	Test.setCurrentPage(pageRef);
        	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
	        ApexPages.currentPage().getParameters().put('id', opp.Id);
			CourseEquivalenceController controller = new CourseEquivalenceController(sc);
        	controller.setInitialValues();
        	controller.selectedCreditType = 'Fulfilled';
        	controller.selectedMultipleTranscripts = 'Yes';
        	controller.getProgramCourses();
        	System.assertEquals(5, controller.studentExpertiseDetailsList.size());
            controller.studentExpertiseDetailsList[0].isSelected = true;
        	controller.studentExpertiseDetailsList[0].grade = 'A';
        	controller.confirmationPage();
        Test.stopTest();
    }
    
    static testMethod void testGoToConfirmationDeletePage() {
        setup();
        Test.startTest();
        	PageReference pageRef = Page.CourseEquivalence;
           	Test.setCurrentPage(pageRef);
        	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
	        ApexPages.currentPage().getParameters().put('id', opp.Id);
			CourseEquivalenceController controller = new CourseEquivalenceController(sc);
        	controller.setInitialValues();
        	controller.selectedCreditType = 'Fulfilled';
        	controller.selectedMultipleTranscripts = 'Yes';
        	controller.getProgramCourses();
        	System.assertEquals(5, controller.studentExpertiseDetailsList.size());
            controller.studentExpertiseDetailsList[0].isSelected = true;
        	controller.studentExpertiseDetailsList[0].grade = 'A';
        	controller.confirmationDeletePage();
        Test.stopTest();
    }
    
    static testMethod void testUpdateRecords() {
        setup();
        Test.startTest();
        	PageReference pageRef = Page.CourseEquivalence;
           	Test.setCurrentPage(pageRef);
        	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
	        ApexPages.currentPage().getParameters().put('id', opp.Id);
			CourseEquivalenceController controller = new CourseEquivalenceController(sc);
        	controller.setInitialValues();
        	controller.selectedCreditType = 'Fulfilled';
        	controller.selectedMultipleTranscripts = 'Yes';
        	controller.getProgramCourses();
        	System.assertEquals(5, controller.studentExpertiseDetailsList.size());
            controller.studentExpertiseDetailsList[0].isSelected = true;
        	controller.studentExpertiseDetailsList[0].grade = 'A';
        	controller.updateRecords();        	
        	System.assertEquals(1, controller.studentCompetencyDetailsList.size());
        	System.assertEquals(1, controller.updateStudentExpertiseList.size());
        	System.assertEquals(4, controller.updateStudentExpertiseList[0].grade_value__c);
        Test.stopTest();
    }
    
    static testMethod void testRestoreRecords() {
        setup();
        Test.startTest();
        	PageReference pageRef = Page.CourseEquivalence;
           	Test.setCurrentPage(pageRef);
        	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
	        ApexPages.currentPage().getParameters().put('id', opp.Id);
			CourseEquivalenceController controller = new CourseEquivalenceController(sc);
        	controller.setInitialValues();
        	controller.selectedCreditType = 'Fulfilled';
        	controller.selectedMultipleTranscripts = 'Yes';
        	controller.getProgramCourses();
        	System.assertEquals(5, controller.studentExpertiseDetailsList.size());
            controller.studentExpertiseDetailsList[0].isSelected = true;
        	controller.studentExpertiseDetailsList[0].grade = 'A';
        	controller.studentExpertiseDetailsList[1].isSelected = true;
        	controller.studentExpertiseDetailsList[1].grade = 'A';
        	controller.studentExpertiseDetailsList[2].isSelected = true;
        	controller.studentExpertiseDetailsList[2].grade = 'A';
        	//controller.updateRecords();
        	controller.confirmationDeletePage();
        	controller.deleteOrRestoreEntries();
        Test.stopTest();
    }
    
    static testMethod void testAddPseudoCourse() {
        setup();
        Test.startTest();
        	PageReference pageRef = Page.CourseEquivalence;
           	Test.setCurrentPage(pageRef);
        	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
	        ApexPages.currentPage().getParameters().put('id', opp.Id);
			CourseEquivalenceController controller = new CourseEquivalenceController(sc);
        	controller.setInitialValues();
        	controller.selectedCreditType = 'Transferred';
        	controller.getProgramCourses();
        	controller.duplicateSeCourseName = controller.studentExpertiseDetailsList[0].aoeCourseCode;
        	controller.addPseudoCourse();
        	System.assertEquals(6, controller.studentExpertiseDetailsList.size());
        Test.stopTest();
    }
    
    static testMethod void testUpdatePseudoCE() {
        setup();
        Test.startTest();
        	PageReference pageRef = Page.CourseEquivalence;
           	Test.setCurrentPage(pageRef);
        	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
	        ApexPages.currentPage().getParameters().put('id', opp.Id);
			CourseEquivalenceController controller = new CourseEquivalenceController(sc);
        	controller.setInitialValues();
        	controller.selectedCreditType = 'Transferred';
        	controller.selectedMultipleTranscripts = 'Yes';
        	controller.getProgramCourses();
        	System.assertEquals(5, controller.studentExpertiseDetailsList.size());
        	controller.studentExpertiseDetailsList[0].isSelected = true;
        	controller.studentExpertiseDetailsList[0].grade = 'A';
        	controller.updateRecords();        	
        	System.assertEquals(1, controller.studentCompetencyDetailsList.size());
        	controller.studentCompetencyDetailsList[0].pseudoCE = 10.0;
        	controller.updatePseudoCE();
        Test.stopTest();
    }
    
    static testMethod void testUndoOperation() {
        setup();
        Test.startTest();
        	PageReference pageRef = Page.CourseEquivalence;
           	Test.setCurrentPage(pageRef);
        	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
	        ApexPages.currentPage().getParameters().put('id', opp.Id);
			CourseEquivalenceController controller = new CourseEquivalenceController(sc);
        	controller.setInitialValues();
        	controller.selectedCreditType = 'Fulfilled';
        	controller.selectedConferredDegree = 'No';
        	controller.getProgramCourses();
        	System.assertEquals(5, controller.studentExpertiseDetailsList.size());
            controller.studentExpertiseDetailsList[0].isSelected = true;
        	controller.studentExpertiseDetailsList[0].grade = 'A';
        	controller.updateRecords();
        	System.assertEquals('Walden University', controller.studentCompetencyDetailsList[0].transferringInstitution);
        	controller.undoOperation();
        	System.assertEquals('Harvard', controller.studentCompetencyDetailsList[0].transferringInstitution);
        Test.stopTest();
    }

    static testMethod void testAddUniqueDuplicate() {
        setup();
        Test.startTest();
        	PageReference pageRef = Page.CourseEquivalence;
           	Test.setCurrentPage(pageRef);
        	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
	        ApexPages.currentPage().getParameters().put('id', opp.Id);
			CourseEquivalenceController controller = new CourseEquivalenceController(sc);
        	controller.setInitialValues();
        	controller.selectedCreditType = 'Transferred';
        	controller.getProgramCourses();
        	controller.duplicateSeCourseName = controller.studentExpertiseDetailsList[0].aoeCourseCode;
        	controller.addPseudoCourse();
        	System.assertEquals(6, controller.studentExpertiseDetailsList.size());
        	controller.studentExpertiseDetailsList[0].isSelected = true;
        	controller.studentExpertiseDetailsList[1].isSelected = true;
        	controller.updateRecords();
        	//System.assertEquals(6, controller.priorStudentExpertiseList.size());
        Test.stopTest();
    }
    
    static testMethod void testUpdateRecordsWithGenEd() {
        setup();
        Test.startTest();
        	PageReference pageRef = Page.CourseEquivalence;
           	Test.setCurrentPage(pageRef);
        	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
	        ApexPages.currentPage().getParameters().put('id', opp.Id);
			CourseEquivalenceController controller = new CourseEquivalenceController(sc);
        	controller.setInitialValues();
        	controller.selectedCreditType = 'Fulfilled';
        	controller.selectedMultipleTranscripts = 'Yes';
        	controller.getProgramCourses();
        	controller.studentExpertiseDetailsList = new List<CourseEquivalenceController.StudentExpertiseDetails>();
            CourseEquivalenceController.StudentExpertiseDetails studentExpertiseDetails1 = new CourseEquivalenceController.StudentExpertiseDetails();
            studentExpertiseDetails1.isSelected = true;
            studentExpertiseDetails1.isGenEd = true;
            studentExpertiseDetails1.aoeCourseCode = 'STAT 3001';
            studentExpertiseDetails1.areaOfExpertiseId = aoeStat3001.id;
            studentExpertiseDetails1.opportunityId = opp.id;
            studentExpertiseDetails1.contactId = con.id;
            studentExpertiseDetails1.totalCE = 5.0;
            studentExpertiseDetails1.transferringInstitution = 'Walden';
            studentExpertiseDetails1.isPseudoCourse = false;
            studentExpertiseDetails1.areaOfExpertiseName = 'Statistical Methods and Applications';
            controller.studentExpertiseDetailsList.add(studentExpertiseDetails1);
        	controller.updateRecords();        	
        	System.assertEquals(2, controller.studentCompetencyDetailsList.size());
        	System.assertEquals(1, controller.updateStudentExpertiseList.size());
        Test.stopTest();
    }
}