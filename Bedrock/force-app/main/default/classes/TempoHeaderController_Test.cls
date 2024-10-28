//* Ravitej Varada    03/28/2022     Present a bell icon on tempo student portal when surveys are available


@istest
public class TempoHeaderController_Test {

          private static List<Contact> students;

    
    static testMethod void testHeader() {
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);        
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        insert opp;
        testCon.Email= 'test@walden.test';
        testCon.FirstName= 'Test';
        testCon.LastName= 'Walden';
        testCon.CBL_Student_ID__c= 'CBL01234';
        update testCon;
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
		sProg.IsStudentProgramActive__c = true;
        insert sProg;
		Profile communityProfile = [
                        SELECT Id
                        FROM Profile
                        WHERE Name = 'Tempo Community Users'
                        LIMIT 1 ];
		user usr = new user();
        usr.Username = testCon.email;
        usr.ContactId = testCon.id;
        usr.ProfileId = communityProfile.Id;
        usr.Alias = testCon.FirstName;
        usr.Email = testCon.email + '.Walden';
        usr.FirstName = testCon.FirstName;
        usr.LastName = testCon.LastName;
        usr.FederationIdentifier = testCon.CBL_Student_ID__c;
        usr.TimeZoneSidKey = 'America/New_York';
        usr.LocaleSidKey = 'en_US';
        usr.EmailEncodingKey = 'UTF-8';
        usr.LanguageLocaleKey = 'en_US';
        usr.IsActive = true;
        insert usr;
        prod.Degree_Level__c = 'Graduate';
        prod.Program_Guide_Link__c = 'www.tempo.waldem.edutest';
        prod.name = 'Master of Business Administration';
        prod.Parent_Program__c = parentProduct.Id;
        update prod;
        sProg.Program__c=prod.id;
        update sProg;
        /*Brand_Profile__c brandPro = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        brandPro.Email__c = testCon.Email;
        brandPro.Primary_Program_of_Interest__c = prod.id;
        brandPro.Contact__c  =testCon.id;
        insert brandPro;  
        Community_Site_Settings__c defaultCustomSetngs = new Community_Site_Settings__c();
        defaultCustomSetngs.Name = 'Default Settings';
        defaultCustomSetngs.Sign_Out_URL__c = 'www.testSignOut.com';
        //insert defaultCustomSetngs;*/
        Brand_Configuration__c bc =new Brand_Configuration__c();
        insert bc;
        Community_Site_Settings__c cs = new Community_Site_Settings__c(Name='Default Settings',
        Intercom_Secret_Key__c ='GqgZglOaLiyFgsp6OirOoqzloHGITNr20jkhXrNw',
        RecordID__c = bc.Id);
        insert cs;
        
        List<Competency__c> competencies = new List<Competency__c>();
        for(Integer i = 0; i<1; i++){
            competencies.add(TestDataGenerator.createCompetency(false));   
        }
        insert competencies;
        
        List<Student_Competency__c> studComp = new List<Student_Competency__c>();
                studComp.add(TestDataGenerator.createStudentCompetency(competencies[0].id,'Walden',false));
                studComp.add(TestDataGenerator.createStudentCompetency(competencies[0].id,'Walden',false));
                studComp.add(TestDataGenerator.createStudentCompetency(competencies[0].id,'Walden',false));
        insert studComp;
		studComp[0].Survey_Message_Sent__c = False;
		studComp[0].Student_Program__c = sprog.Id;
		studComp[1].Survey_Message_Sent__c = False;
		studComp[2].Survey_Message_Sent__c = False;
        studComp[0].Status__c = 'Achieved';
        studComp[1].Status__c = 'Achieved';
        studComp[2].Status__c = 'Achieved';
        studComp[0].Contact__c  = testCon.id;
        studComp[1].Contact__c  =testCon.id;
        studComp[2].Contact__c  =testCon.id;
        studComp[0].End_of_Survey_Link__c = 'Achieved';
        studComp[1].End_of_Survey_Link__c = 'Achieved';
        studComp[2].End_of_Survey_Link__c = 'Achieved';
        studComp[1].Student_Program__c = sprog.Id;
        studComp[2].Student_Program__c = sprog.Id;

        update studComp;
     
        
        
        test.startTest();
        System.runAs(usr){
            TempoHeaderController tempoHeadCnt = new TempoHeaderController();
            tempoHeadCnt.studentProgramId=sprog.id;
            tempoHeadCnt.scId= studComp[0].id;
            
            tempoHeadCnt.updateCompSurvey();
            
            prod.Degree_Level__c = 'Undergrad';
            update prod;
            tempoHeadCnt = new TempoHeaderController();
            
            sProg.IsStudentProgramActive__c = false;
            update sProg;
            tempoHeadCnt = new TempoHeaderController();
            
            prod.Degree_Level__c = 'Graduate';
            update prod;
            tempoHeadCnt = new TempoHeaderController();
            tempoHeadCnt.modalBody = '';
            tempoHeadCnt.modalHeader = '';
            tempoHeadCnt.closeModal();
        }
		test.stopTest();        
    }   
}