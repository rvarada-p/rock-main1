/*
 * Revision History
 * Horacio Sanchez   -   May 09, 2022    -   S-90888 Portal to present the CLP edit page on the first day of a new subscription term
 * 											 Added code coverage
 * 
 */ 

@istest
public class TempoLandingController_Test {

    
    static testMethod void testlandingNewATC() {
    	
        // Create Test Data
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
        prod.Automate_Agree_to_Credit__c = true;
        update prod;
        
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  
        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        
        Student_Subscription__c oldStuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        oldStuSub.Start_Date__c =Date.today().addDays(-10);
        //oldStuSub.Number_of_Credits_Completed__c =  50;
        //oldStuSub.Agreed_To_Credits__c =3;
        insert oldStuSub;
          
        sProg.Program__c = prod.id;
        sProg.Current_Student_Subscription__c = oldStuSub.id;
        update sProg;
        
        Brand_Profile__c brandPro = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        brandPro.Email__c = testCon.Email;
        brandPro.Primary_Program_of_Interest__c = prod.id;
        brandPro.Contact__c  =testCon.id;
        insert brandPro; 
        
        Brand_Configuration__c brandConf = TestDataGenerator.createBrandConfiguration(  'Test Brand Configuratiomn', 'TEST','Header', TRUE) ;
        Community_Site_Settings__c defaultCustomSetngs = new Community_Site_Settings__c();
        defaultCustomSetngs.Name = 'Default Settings';
        defaultCustomSetngs.Intercom_App_Id__c = '183jjd9';
        defaultCustomSetngs.Intercom_Secret_Key__c = 'U8BjsjJnasonsauho32873ashj783HHBS';
        insert defaultCustomSetngs;
        
        test.startTest();
            System.runAs(usr) {
                TempoLandingController tempoLandCnt = new  TempoLandingController();
                tempoLandCnt.currentUserId = usr.id;
                tempoLandCnt.Router();
                
                oldStuSub.Number_of_Credits_Completed__c =  50;
        		oldStuSub.Agreed_To_Credits__c =3;
                update oldStuSub;
                prod.Automate_Agree_to_Credit__c = false;
                update prod;
                sProg.Program__c = prod.Id;
                sProg.Current_Student_Subscription__c = oldStuSub.Id;
                tempoLandCnt = new  TempoLandingController();
            }
        test.stopTest();
	}
    
    static testMethod void testlandingGraduate() {
    	
        // Create Test Data
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
        prod.Automate_Agree_to_Credit__c = false;
        update prod;
        
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  
        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        
        Student_Subscription__c oldStuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        oldStuSub.Start_Date__c =Date.today().addDays(-10);
        oldStuSub.Number_of_Credits_Completed__c =  50;
        oldStuSub.Agreed_To_Credits__c =3;
        insert oldStuSub;
          
        sProg.Program__c = prod.id;
        sProg.Current_Student_Subscription__c = oldStuSub.id;
        update sProg;
        
        Brand_Profile__c brandPro = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        brandPro.Email__c = testCon.Email;
        brandPro.Primary_Program_of_Interest__c = prod.id;
        brandPro.Contact__c  =testCon.id;
        insert brandPro; 
        
        Brand_Configuration__c brandConf = TestDataGenerator.createBrandConfiguration(  'Test Brand Configuratiomn', 'TEST','Header', TRUE) ;
        Community_Site_Settings__c defaultCustomSetngs = new Community_Site_Settings__c();
        defaultCustomSetngs.Name = 'Default Settings';
        defaultCustomSetngs.Intercom_App_Id__c = '183jjd9';
        defaultCustomSetngs.Intercom_Secret_Key__c = 'U8BjsjJnasonsauho32873ashj783HHBS';
        insert defaultCustomSetngs;
        
        test.startTest();
            System.runAs(usr) {
                TempoLandingController tempoLandCnt = new  TempoLandingController();
                tempoLandCnt.currentUserId = usr.id;
                tempoLandCnt.Router();
            }
        test.stopTest();
	}
    
    static testMethod void testlandingUndergrad() {
    	
        // Create Test Data
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
        
        prod.Degree_Level__c = 'Undergrad';
        prod.Program_Guide_Link__c = 'www.tempo.waldem.edutest';
        prod.name = 'Master of Business Administration';
        prod.Parent_Program__c = parentProduct.Id;
        prod.Automate_Agree_to_Credit__c = false;
        update prod;
        
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, null, true);  
        Pricebook2 pBook = TestDataGenerator.createSubscrptPricebook('testBook', 4, 'Walden', false);
        insert pBook;
        
        Student_Subscription__c oldStuSub = TestDataGenerator.createStudentSubscription(sProg, pBook, 'Walden', false);
        oldStuSub.Start_Date__c =Date.today().addDays(-10);
        oldStuSub.Number_of_Credits_Completed__c =  50;
        oldStuSub.Agreed_To_Credits__c =3;
        insert oldStuSub;
          
        sProg.Program__c = prod.id;
        sProg.Current_Student_Subscription__c = oldStuSub.id;
        update sProg;
        
        Brand_Profile__c brandPro = TestDataGenerator.createBrandProfile('Tempo', 'test', 'profile', false);
        brandPro.Email__c = testCon.Email;
        brandPro.Primary_Program_of_Interest__c = prod.id;
        brandPro.Contact__c  =testCon.id;
        insert brandPro; 
        
        Brand_Configuration__c brandConf = TestDataGenerator.createBrandConfiguration(  'Test Brand Configuratiomn', 'TEST','Header', TRUE) ;
        Community_Site_Settings__c defaultCustomSetngs = new Community_Site_Settings__c();
        defaultCustomSetngs.Name = 'Default Settings';
        defaultCustomSetngs.Intercom_App_Id__c = '183jjd9';
        defaultCustomSetngs.Intercom_Secret_Key__c = 'U8BjsjJnasonsauho32873ashj783HHBS';
        insert defaultCustomSetngs;
        
        test.startTest();
            System.runAs(usr) {
                TempoLandingController tempoLandCnt = new  TempoLandingController();
                tempoLandCnt.currentUserId = usr.id;
                tempoLandCnt.Router();
            }
        test.stopTest();
	}
    
}