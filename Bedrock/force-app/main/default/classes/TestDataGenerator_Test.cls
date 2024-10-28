@isTest
private class TestDataGenerator_Test {
    
    
    @isTest static void createAccounts() {
        system.assertEquals(TestDataGenerator.createAccounts(1,'Custom Person Account',true).size(), 1);
    }
    @isTest static void createAccount() {
        system.assert(TestDataGenerator.createAccount('Custom Person Account',true)!=null);
    }
    @isTest static void createAccount2() {
        system.assert(TestDataGenerator.createAccount(true)!=null);
    }
    @isTest static void createSponsorAccounts() {
        system.assert(TestDataGenerator.createSponsorAccount('Custom Person Account',true)!=null);
    }
    @isTest static void createContacts() {
        system.assertEquals(TestDataGenerator.createContacts(TestDataGenerator.createAccounts(1,'Custom Person Account',true)
                                                             ,1,'Custom Person Account Contact',true).size(), 1);
    }  
    @isTest static void createContacts2() {
        system.assertEquals(TestDataGenerator.createContacts(TestDataGenerator.createAccount('Custom Person Account',true)
                                                             ,1,'Custom Person Account Contact',true).size(), 1);
    }
    @isTest static void createContacts3() {
        system.assert(TestDataGenerator.createContact(TestDataGenerator.createAccount('Custom Person Account',true)
                                                      ,'Custom Person Account Contact',true)!=null);
    }
    @isTest static void createContacts4() {
        system.assert(TestDataGenerator.createContact(TestDataGenerator.createAccount('Custom Person Account',true),true)!=null);
    }
    @isTest static void createCompetency() {
        Competency__c comp = TestDataGenerator.createCompetency('C0d3',true);
        system.assert(comp!=null);
        comp.Description__c = 'test';
        comp.Published__c = false;
        update comp;
        system.assert(comp!=null);
        comp.Published__c = true;
        update comp;
    }
    @isTest static void createOpportunity() {
        Account testAcc = TestDataGenerator.createAccount('Custom Person Account',true);
        Contact testCon = TestDataGenerator.createContact(testAcc, true); 
        Opportunity opty = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, 'Walden', true);
        system.assert(opty != null);
    }  
    @isTest static void createBrandProfile() {
        Brand_Profile__c testProfile1 = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', true);
        system.assert(testProfile1 != null);
    } 
    @isTest static void createProduct() {
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        system.assert(product2 != null);
    } 
    @isTest static void createCompetency2() {
        Competency__c comp = TestDataGenerator.createCompetency(true);
        system.assert(comp != null);
    } 
    @isTest static void createCompetency3() {
        Competency__c comp = TestDataGenerator.createCompetency(2.5, true);
        system.assert(comp != null);
    }   
    @isTest static void createProgramCompetency() {
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true); 
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Program_Expertise__c pExperise = TestDataGenerator.createProgramExpertise(aExper.ID,product2.ID,true,5.0,true);
        Program_Competency__c pCompetemcy = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0, false);
        pCompetemcy.Program_Expertise__c = pExperise.ID;
        insert pCompetemcy;
        system.assert(pCompetemcy != null);
        Program_Competency__c pCompetemcy2 = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,pExperise.Id,true,4.0, true);
    } 
    @isTest static void createAreaOfExpertise() {
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true); 
        system.assert(aExper != null);
    } 
    @isTest static void createProgramExpertise() {
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true); 
        Program_Expertise__c pExperise = TestDataGenerator.createProgramExpertise(aExper.ID,product2.ID,true,5.0,true);
        system.assert(pExperise != null);
    }
    @isTest static void createCompetencyExpertise() {
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true); 
        Competency__c comp = TestDataGenerator.createCompetency('C0d3',true);
        Competency_Expertise__c compex = TestDataGenerator.createCompetencyExpertise(aExper.Id,comp.ID,'Walden', true);
        system.assert(compex != null);
    }
    @isTest static void createCompetencyExpertise2() {
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true); 
        Student_Expertise__c sExpertise = TestDataGenerator.createCompetencyExpertise(aExper.Id,null, true);
        //sExpertise.Contact__c = testCon.id;
        //sExpertise.Program_Expertise__c = pExperise.ID;
        //insert sExpertise;
        system.assert(sExpertise != null);
    }
    @isTest static void createStudentCompetency() {
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true); 
        Student_Expertise__c sExpertise = TestDataGenerator.createCompetencyExpertise(aExper.Id,null, true);
        Account testAcc = TestDataGenerator.createAccount('Custom Person Account',true);
        Contact testCon = TestDataGenerator.createContact(testAcc, true); 
        Opportunity opty = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, 'Walden', true);
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        // create strudent competency
        Student_Competency__c sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency.Contact__c = testCon.id;
        insert sCometency;
        system.assert(sCometency != null);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Program_Expertise__c pExperise = TestDataGenerator.createProgramExpertise(aExper.ID,product2.ID,true,5.0,true);
        Program_Competency__c pCompetemcy = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0, false);
        pCompetemcy.Program_Expertise__c = pExperise.ID;
        insert pCompetemcy;
        Student_Competency__c finalDependency = TestDataGenerator.createStudentCompetency(pCompetemcy, testCon.id, true, 'Walden', true,sExpertise);
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', true); 
        Student_Competency__c finalDependency2 = TestDataGenerator.createStudentCompetency( testComp.id, 'Walden', true);
    }
    @isTest static void createRecordTypesForCBLProcesses() {
        RecordTypes_For_CBL_Processes__c objeCbl = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Student Assessment', 'Student_Assessment__c','Walden', true); 
        system.assert(objeCbl != null);
    } 
    @isTest static void createTriggerSettings() {
        TriggerSettings__c objTrgSetting = TestDataGenerator.createTriggerSettings('StudentSubscriptionTrigger', true, true); 
        system.assert(objTrgSetting != null);
    } 
    @isTest static void createLead() {
        Lead newLead = TestDataGenerator.createLead('Test', 'Lead','Test Comp', 'Walden', false);
        newLead.Email = 'test@test.com';
        insert newLead; 
        system.assert(newLead != null);
    } 
    @isTest static void createSubscrptPricebook() {
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);
        system.assert(pb != null);
    }
    @isTest static void createPricebookEntry() {
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        PricebookEntry pbEntery = TestDataGenerator.createPricebookEntry(product2.id, pb.id, 200, false,false);
        system.assert(pbEntery != null);
    }
    @isTest static void createStudentSubscription() {
        Account testAcc = TestDataGenerator.createAccount('Custom Person Account',true);
        Contact testCon = TestDataGenerator.createContact(testAcc, true); 
        Opportunity opty = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, 'Walden', true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false); 
        sProg.IsStudentProgramActive__c = true;
        sprog.Program__c = product2.ID;
        insert sprog;
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, false);
        pb.Subscription_Duration_in_Months__c = 0;
        insert pb;
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pb, 'Walden', false);
        stuSub.Start_Date__c = Date.today();
        insert stuSub;
        system.assert(stuSub != null);
    }
    @isTest static void createStudentSubscription2() {
        Account testAcc = TestDataGenerator.createAccount('Custom Person Account',true);
        Contact testCon = TestDataGenerator.createContact(testAcc, true); 
        Opportunity opty = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, 'Walden', true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false); 
        sProg.IsStudentProgramActive__c = true;
        sprog.Program__c = product2.ID;
        insert sprog;
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, false);
        pb.Subscription_Duration_in_Months__c = 0;
        insert pb;
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pb, 'Walden', false, System.today(), 1, 1);
        stuSub.Start_Date__c = Date.today();
        insert stuSub;
        system.assert(stuSub != null);
    }  
    @isTest static void createStudentProgram() {
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        Account testAcc = TestDataGenerator.createAccount('Custom Person Account',true);
        Contact testCon = TestDataGenerator.createContact(testAcc, true); 
        Opportunity opty = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, 'Walden', true);
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false); 
        sProg.IsStudentProgramActive__c = true;
        sprog.Program__c = product2.ID;
        insert sprog;
        system.assert(sprog != null);
    }
    @isTest static void createStudentProgram2() {
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        Account testAcc = TestDataGenerator.createAccount('Custom Person Account',true);
        Contact testCon = TestDataGenerator.createContact(testAcc, true); 
        Opportunity opty = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, 'Walden', true);
        Program_Start_Date__c psd =  TestDataGenerator.createProgramStartDate(true);
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false, 'Test', true, psd.Id); 
        sprog.Program__c = product2.ID;
        insert sprog;
        system.assert(sprog != null);
    }  
    @isTest static void createStudentProgramModalitySwitcher() {
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        Account testAcc = TestDataGenerator.createAccount('Custom Person Account',true);
        Contact testCon = TestDataGenerator.createContact(testAcc, true); 
        Opportunity opty = TestDataGenerator.createOpportunity(testAcc.id, testCon.ID, 'Walden', true);
        Program_Start_Date__c psd =  TestDataGenerator.createProgramStartDate(true);
        Student_Program__c sProg = TestDataGenerator.createStudentProgramModalitySwitcher(opty,testCon.ID, 'Walden', false, 'Test', true, psd.Id); 
        sprog.Program__c = product2.ID;
        insert sprog;
        system.assert(sprog != null);
    }   
    @isTest static void createStudentDiscount() {
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false);
        opty.Primary_Program__c =product2.id;
        insert opty;
        Exemption__c exc = new Exemption__c();
        exc.Name= 'Discount 1';
        exc.Flat_Rate_Amount__c=300.50;
        exc.fee_type__c = 'Tech Fee';
        exc.Institution__c = TestDataGenerator.createInstitution('Walden', true).Id;
        exc.Life_of_Program__c = true;
        exc.Active__c = true;
        insert exc; 
        // create student discount
        Student_Discount__c sdc = TestDataGenerator.createStudentDiscount(opty,null,exc, true );
        system.assert(sdc != null);
    }
    @isTest static void createExemption() {
        Exemption__c testExemp = TestDataGenerator.createExemption(100,null,true);
        system.assert(testExemp != null);
    }
    @isTest static void createExemption2() {
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        Program_Start_Date__c sd = TestDataGenerator.createProgramStartDate(true);
        Program_Start_Date__c ed = TestDataGenerator.createProgramStartDate(true);
        Exemption__c testExemp = TestDataGenerator.createExemption('Standard Reduction', 'Employee', true, 0, product2, true, 0, 100, true,sd,ed);
        system.assert(testExemp != null);
    }  
    @isTest static void createStudentSubscriptionExemption() {
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false);
        opty.Primary_Program__c =product2.id;
        insert opty;
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false); 
        sProg.IsStudentProgramActive__c = true;
        sprog.Program__c = product2.ID;
        insert sprog;   
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, false);
        pb.Subscription_Duration_in_Months__c = 0;
        insert pb;     
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pb, 'Walden', false);
        stuSub.Start_Date__c = Date.today();
        insert stuSub;    
        Exemption__c exc = new Exemption__c();
        exc.Name= 'Discount 1';
        exc.fee_type__c = 'Tech Fee';
        exc.Flat_Rate_Amount__c=300.50;
        exc.Institution__c = TestDataGenerator.createInstitution('Walden', true).Id;
        exc.Life_of_Program__c = true;
        exc.Active__c = true;
        insert exc; 
        // create student discount
        Student_Discount__c sdc = TestDataGenerator.createStudentDiscount(opty,null,exc, true );
        sdc.Student_Program__c = sprog.id;
        update sdc;
        Student_Subscription_Exemptions__c sse = TestDataGenerator.createStudentSubscriptionExemption(sdc, stuSub, 'Walden',true);
        system.assert(sse != null);
    }  
    @isTest static void createNewCourse() {
        Course__c testCourse = TestDataGenerator.createNewCourse('EDU-Test', true);
        system.assert(testCourse != null);
    }
    @isTest static void createNewCourseCompetency() {
        Course__c testCourse = TestDataGenerator.createNewCourse('EDU-Test', true);
        Competency__c  newCompetency1 = TestDataGenerator.createCompetency('Comp1',true);
        Course_Competency__c crsCompetency1 = TestDataGenerator.createNewCourseCompetency(testCourse.id, newCompetency1.id, true);
        system.assert(crsCompetency1 != null);
    }
    @isTest static void createNewStudentAssessment() {
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true); 
        Account testAcc = TestDataGenerator.createAccount('Custom Person Account',true);
        Contact testCon = TestDataGenerator.createContact(testAcc, true); 
        
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        Program_Competency__c pCompetemcy = TestDataGenerator.createProgramCompetency(testComp.Id,product2.Id,true,4.0, true);
        // create student competency
        Student_Competency__c sCometency = TestDataGenerator.createStudentCompetency(testComp.id,'Walden', false);
        sCometency.Program_Competency__c = pCompetemcy.Id;
        
        sCometency.Contact__c = testCon.id;
        insert sCometency;
        Student_Assessment__c sa1 = TestDataGenerator.createNewStudentAssessment(sCometency.Id,'A','Walden','Mastered',true);
        system.assert(sa1 != null);
    }
    @isTest static void createStudentEnrollmentSteps() {
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', false);
        prod.Parent_Program__c = parentProduct.id;
        insert prod;
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = prod.Id;
        insert opp;
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', true);
        Student_Enrollment_Steps__c stdEnrollmentSp1 = TestDataGenerator.createStudentEnrollmentSteps(sProg.Id, true);
        system.assert(stdEnrollmentSp1 != null);
    }
    @isTest static void createHoldCode() {
        Hold_Codes__c hCode = TestDataGenerator.createHoldCode(true);
        system.assert(hCode != null);
    }
    @isTest static void createStudentHoldCode() {
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', false);
        prod.Parent_Program__c = parentProduct.id;
        insert prod;
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = prod.Id;
        insert opp;
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', true);
        Hold_Codes__c hCode = TestDataGenerator.createHoldCode(true);
        Student_Hold_Code__c sHoldCode = TestDataGenerator.createStudentHoldCode(hCode.id ,sProg.id ,false);
        sHoldCode.Hold_Close_Date__c = Date.today().addDays(2);
        insert sHoldCode;
        system.assert(sHoldCode != null);
    }
    @isTest static void createProgramStartDate() {
        Program_Start_Date__c psd = TestDataGenerator.createProgramStartDate(true);
        system.assert(psd != null);
    }
    @isTest static void createAcademicHistory() {
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);  	
        Academic_History__c academicHistory = TestDataGenerator.createAcademicHistory(testCon.Id, true);
        system.assert(academicHistory != null);
    }  
    @isTest static void createEmploymentHistory() {
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);  	
        Employment_History__c employmentHistory = TestDataGenerator.createEmploymentHistory(testCon.Id, true);
        system.assert(employmentHistory != null);
    }  
    @isTest static void createProgramApplicationRequirement() {
        Program_Application_Requirement__c progAppRequirement = TestDataGenerator.createProgramApplicationRequirement(true);
        system.assert(progAppRequirement != null);
    } 
    @isTest static void createStudentApplicationRequirement() {
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('parent', 'Walden', true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', false);
        prod.Parent_Program__c = parentProduct.id;
        insert prod;
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = prod.Id;
        insert opp;  	
        Program_Application_Requirement__c progAppRequirement = TestDataGenerator.createProgramApplicationRequirement(true);
        Student_Application_Requirement__c studentAppRequirement = TestDataGenerator.createStudentApplicationRequirement(opp.Id,progAppRequirement.Id,true);
        system.assert(studentAppRequirement != null);
    }      
    @isTest static void createRoundRobinQueue() {
        Institution__c institution = TestDataGenerator.createInstitution('Walden', true); 	
        Round_Robin_Queue__c rr = TestDataGenerator.createRoundRobinQueue('Test',institution.Id,true);
        system.assert(rr != null);
    }   
    /*
@isTest static void createStudentLoanDisbursement() {
Account acc = TestDataGenerator.createAccount(true);
Contact testCon = TestDataGenerator.createContact(acc, true);
Product2 prod = TestDataGenerator.createProduct('test', 'Walden', true);
Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
opp.Primary_Program__c = prod.Id;
insert opp;
Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
sProg.IsStudentProgramActive__c = true; 
insert sProg;
Student_Loan_Disbursement__c studLoanDisbursement = TestDataGenerator.createStudentLoanDisbursement(sProg.Id,100,System.today(),System.today().addDays(2),System.today().addDays(60),true);
system.assert(studLoanDisbursement!=null);
}
*/     
    @isTest static void createEngagementRule() {
        Institution__c institution = TestDataGenerator.createInstitution('Walden', true); 	
        Engagement_Rule__c engagementRule = TestDataGenerator.createEngagementRule('Test',institution.Id,true,true);
        system.assert(engagementRule != null);
    }        
    @isTest static void createStudentEngagementRule() {
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('parent', 'Walden', true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', false);
        prod.Parent_Program__c = parentProduct.id;
        insert prod;
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = prod.Id;
        insert opp;
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', true);
        Institution__c institution = TestDataGenerator.createInstitution('Walden', true);  
        Engagement_Rule__c engagementRule = TestDataGenerator.createEngagementRule('Test',institution.Id,true,true);   	
        Student_Engagement_Rule__c studEngagementRule = TestDataGenerator.createStudentEngagementRule(sProg.Id,engagementRule.Id,true,true);
        system.assert(studEngagementRule != null);
    } 
    @isTest static void createStudentSponsorship() {
        Account a = TestDataGenerator.createSponsorAccount('Custom Person Account',true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false);
        opty.Primary_Program__c =product2.id;
        insert opty;
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false); 
        sProg.IsStudentProgramActive__c = true;
        sprog.Program__c = product2.ID;
        insert sprog;   
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, false);
        pb.Subscription_Duration_in_Months__c = 0;
        insert pb;     
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pb, 'Walden', false);
        stuSub.Start_Date__c = Date.today();
        insert stuSub;    
        Student_Sponsorship__c studentSponsorship = TestDataGenerator.createStudentSponsorship(stuSub.Id,a.Id,100,System.today(),true);
        system.assert(studentSponsorship != null);
    }        
    @isTest static void createStudentTransaction() {
        Account a = TestDataGenerator.createSponsorAccount('Sponsor',true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false);
        opty.Primary_Program__c =product2.id;
        insert opty;
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false); 
        sProg.IsStudentProgramActive__c = true;
        sprog.Program__c = product2.ID;
        insert sprog;   
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, false);
        pb.Subscription_Duration_in_Months__c = 0;
        insert pb;     
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pb, 'Walden', false);
        stuSub.Start_Date__c = Date.today();
        insert stuSub;    
        Student_Transaction__c studentTransaction = TestDataGenerator.createStudentTransaction(stuSub.Id,a.Id,100,'Payment - CC',System.today(),true);
        system.assert(studentTransaction!=null);
    }          
    @isTest static void createStudentSponsorshipTransaction() {
        Account a = TestDataGenerator.createSponsorAccount('Sponsor',true);
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.id;
        insert product2;
        Opportunity opty = TestDataGenerator.createOpportunity(acc.id, testCon.ID, null, false);
        opty.Primary_Program__c =product2.id;
        insert opty;
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opty,testCon.ID, 'Walden', false); 
        sProg.IsStudentProgramActive__c = true;
        sprog.Program__c = product2.ID;
        insert sprog;   
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, false);
        pb.Subscription_Duration_in_Months__c = 0;
        insert pb;     
        Student_Subscription__c stuSub = TestDataGenerator.createStudentSubscription(sProg, pb, 'Walden', false);
        stuSub.Start_Date__c = Date.today();
        insert stuSub;    
        Student_Transaction__c studentTransaction = TestDataGenerator.createStudentTransaction(stuSub.Id,a.Id,100,'Payment - CC',System.today(),true);
        Student_Sponsorship__c studentSponsorship = TestDataGenerator.createStudentSponsorship(stuSub.Id,a.Id,100,System.today(),true);
        Student_Sponsorship_Transaction__c studentSponsorTransaction = TestDataGenerator.createStudentSponsorshipTransaction(studentSponsorship.Id,studentTransaction.Id,system.today(),100,true);
        system.assert(studentSponsorTransaction!=null);		
    }    
    @isTest static void createObjectMap() {
        Object_Map__c om = TestDataGenerator.createObjectMap(true);
        system.assert(om != null);
    }
    @isTest static void createFieldMapping() {
        Object_Map__c om = TestDataGenerator.createObjectMap(true);
        Field_Mapping__c fm = TestDataGenerator.createNewFieldMapping(true, om.Id, 'test1','test2');
        system.assert(fm != null);
    }    
    
}