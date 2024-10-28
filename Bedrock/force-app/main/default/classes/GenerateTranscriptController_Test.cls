/************************************************************************
Name  : GenerateTranscriptController_Test
Author: -------- (Appirio)
Date  : October  17, 2014
Description: Test class of GenerateTranscriptController used in 'Generate Transcript' VF screen + CBL Transcript functionality

* Revision History
* Horacio Sanchez   11/18/2020     S-28164: WAS Accelerated Scan: Cross-Site Request Forgery
*************************************************************************/
@isTest
private class GenerateTranscriptController_Test {

    static testMethod void generateTransriptTest() {
        
        Product2 parentProgram = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProgram.Id;
        product2.Credit_type__c = 'Semester'; 
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

        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);  
        Program_Expertise__c pExperise = TestDataGenerator.createProgramExpertise(aExper.ID,product2.ID,true,5.0,true);
        Competency__c testComp = TestDataGenerator.createCompetency(10, true);
        Program_Competency__c pCompetemcy = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0, true);
        Competency__c testComp2 = TestDataGenerator.createCompetency(10, true);
        Program_Competency__c pCompetemcy2 = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0, true);
        Student_Expertise__c sExpertise = TestDataGenerator.createCompetencyExpertise(aExper.Id,null, false);
        sExpertise.Contact__c = testCon.id;
        sExpertise.Program_Expertise__c = pExperise.ID;
        sExpertise.Student_Program__c = studentProgram.ID;
        insert sExpertise;
        
        Program_Start_Date__c pStartDate = [Select Id, Start_Date__c from Program_Start_Date__c where Id = :tstStartDate.Id];
        Student_Subscription__c stuSub = new Student_Subscription__c();
        stuSub.Student_Program__c = studentProgram.Id;
        stuSub.Start_Date__c = pStartDate.Start_Date__c;
        stuSub.End_Date__c = Utility.getSundayEndDateForStudentSubscription(4,stuSub.Start_Date__c);
        stuSub.Subscription_Status__c = 'RE = Registered';
        insert stuSub;
        
        // create student competency
        list<Student_Competency__c> lstStudentCompetency = new list<Student_Competency__c>();
        Student_Competency__c sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency.Contact__c = testCon.id;
        sCometency.Program_Competency__c = pCompetemcy.ID;
        sCometency.Student_Expertise__c = sExpertise.ID;
        sCometency.Student_Program__c = studentProgram.ID;
        sCometency.Status__c = 'Achieved';
        sCometency.Student_Subscription_Achieved_In__c = stuSub.Id;
        sCometency.IsCompleted__c = true;
        lstStudentCompetency.add(sCometency);
        Student_Competency__c sCometency2 = TestDataGenerator.createStudentCompetency(testComp2.id,'Walden', false);
        sCometency2.Contact__c = testCon.id;
        sCometency2.Student_Expertise__c = sExpertise.ID;
        sCometency2.Program_Competency__c = pCompetemcy2.ID;
        sCometency2.Student_Program__c = studentProgram.ID;
        sCometency2.IsCompleted__c  = true;
        sCometency2.Status__c = 'Achieved';
        lstStudentCompetency.add(sCometency2);
        insert lstStudentCompetency;        
        
        Course__c testCourse = TestDataGenerator.createNewCourse('EDU-Test', true);
        list<Competency__c> competencies = new list<Competency__c> ();
        // Fix 4/10/15 - create competency with credits
        Competency__c  newCompetency1 = TestDataGenerator.createCompetency(12, false);
        Competency__c  newCompetency2 = TestDataGenerator.createCompetency(22, false);
        Competency__c  newCompetency3 = TestDataGenerator.createCompetency(32, false);
        
        competencies.add(newCompetency1);
        competencies.add(newCompetency2);
        competencies.add(newCompetency3);
        insert competencies;
        
        Pricebook2 pb = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);

        list<Course_Competency__c> courseCompetencies = new list<Course_Competency__c>();
        Course_Competency__c crsCompetency1 = TestDataGenerator.createNewCourseCompetency(testCourse.id, testComp.id, false);
        Course_Competency__c crsCompetency2 = TestDataGenerator.createNewCourseCompetency(testCourse.id, testComp.id, false);
        Course_Competency__c crsCompetency3 = TestDataGenerator.createNewCourseCompetency(testCourse.id, testComp.id, false);
        //crsCompetency1.Competency__r.Credit_Equivalency__c = 12;
        //crsCompetency2.Competency__r.Credit_Equivalency__c = 22;
        //crsCompetency3.Competency__r.Credit_Equivalency__c = 32;

        courseCompetencies.add(crsCompetency1);
        courseCompetencies.add(crsCompetency2);
        courseCompetencies.add(crsCompetency3);
        insert courseCompetencies;        
        
        Document document = new Document();
        document.Body = Blob.valueOf('Some Text');
        document.ContentType = 'application/pdf';
        document.DeveloperName = 'Laureate_Logo';
        document.IsPublic = true;
        document.Name = 'LaureateLogo';
        document.FolderId = [select id from folder where name = 'Shared Documents'].id;
        insert document;
        
        Institution__c institution = new Institution__c(Name='Walden');
        insert institution;
        
        Hold_Codes__c bhHoldCode = new Hold_codes__c();
        bhHoldCode.Institution__c = institution.Id;
        bhHoldCode.Name = 'BH';
        bhHoldCode.Description__c = 'BH';
        insert bhHoldCode;
        
        Student_Hold_Code__c bursarHold1 = new Student_Hold_Code__c();
        bursarHold1.Hold_Code__c = 'a0Eo00000027LVj';
        bursarHold1.Student_Program__c = studentProgram.Id;
        bursarHold1.Hold_Close_Date__c = null;
        insert bursarHold1;
        
        ApexPages.StandardController sc = new ApexPages.standardController(studentProgram);
        
        GenerateTranscriptController generateTCtrl = new GenerateTranscriptController(sc);
        
        system.assertequals(generateTCtrl.showList ,  true);
        system.assertequals(generateTCtrl.crsShowList ,  true);         
        
        sCometency.IsCompleted__c = false;     
        update sCometency;
        
        GenerateTranscriptController generateTCtrl1 = new GenerateTranscriptController(sc);
        generateTCtrl1.redirectToCBLTranscript();
        generateTCtrl1.redirectToCourseTranscript();
        generateTCtrl1.redirectToUnofficialCourseTranscript();
        generateTCtrl1.redirectToCourseOnlyTranscript();
    }
}