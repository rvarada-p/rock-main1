/*******************************************************************
Name  : TestProgramExpertiseHelper
Author: Bryan Leboff (Appirio)
Date  : October 15, 2014
Description: Test programexpertise helper
*************************************************************************/  
@isTest
private class ProgramExpertiseHelper_Test {
    private static List<Area_of_Expertise__c> expertises;
    private static List<Product2> products;
    private static List<Program_Expertise__c> programExpertises;
    private static RecordType rt;
    private static D2L__c settings;
    
    static RecordTypes_For_CBL_Processes__c recordtye = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Program Expertise', 'Program_Expertise__c','Walden', true);
    
    private static void setup(){
		//Insert the custom settings for D2L
		D2L__c setting = new D2L__c();
		setting.Name = 'D2L';
		setting.Org_Unit_ID__c = 6606;		
		setting.AoE_Type__c = 101;
 		setting.LP_Version__c = 1.50;
		setting.Create_AoE__c = '/d2l/api/lp/1.5/orgstructure/';
		setting.Create_Course_Template__c = '/d2l/api/lp/1.5/coursetemplates/';
		setting.Create_Competency_Shell__c = '/d2l/api/lp/1.5/courses/';
		insert setting; 
		    	
        rt = [select id from recordtype where sobjecttype = 'Program_Expertise__c' and name = 'Walden' limit 1];
        TestDataGenerator.createRecordTypesForCBLProcesses('pe walden', 'Program_Expertise__c','Walden', true);
        products = new List<Product2>();
        products.add(TestDataGenerator.createProduct('test0', 'Walden', false));
        products.add(TestDataGenerator.createProduct('test1', 'Walden', false));
        products.add(TestDataGenerator.createProduct('test2', 'Walden', false));
        products.add(TestDataGenerator.createProduct('test3', 'Walden', false));
        insert products;

        expertises = new List<Area_of_Expertise__c>();
        expertises.add(TestDataGenerator.createAreaOfExpertise(false));
        expertises.add(TestDataGenerator.createAreaOfExpertise(false));
        expertises.add(TestDataGenerator.createAreaOfExpertise(false));
        expertises.add(TestDataGenerator.createAreaOfExpertise(false));
        insert expertises;

        programExpertises = new List<Program_Expertise__c>();
        programExpertises.add(TestDataGenerator.createProgramExpertise(expertises.get(0).id,products.get(0).id,false,1, false)); 
        programExpertises.add(TestDataGenerator.createProgramExpertise(expertises.get(1).id,products.get(0).id,false,2, false)); 
        programExpertises.add(TestDataGenerator.createProgramExpertise(expertises.get(2).id,products.get(0).id,false,3, false)); 
        programExpertises.add(TestDataGenerator.createProgramExpertise(expertises.get(0).id,products.get(1).id,false,1, false)); 
        programExpertises.add(TestDataGenerator.createProgramExpertise(expertises.get(0).id,products.get(2).id,false,1, false)); 
        for(Program_Expertise__c pe : programExpertises){
            pe.recordtypeid = rt.id;
        }

        insert programExpertises;

    }
    
    @isTest static void testBrightSpaceAPICalls() {
    	setup();
    	Competency__c comp = TestDataGenerator.createCompetency(true); 	
    	comp.Program_LMS_ID__c = '6984';
    	comp.AoE_LMS_ID__c = '7026';
    	comp.Publish_to_LMS__c = true;
    	update comp;
    	
    	
    }
    
    @isTest static void testOneProgramInsertUniqueness() {
        setup();

        //test error gets added if match
        Program_Expertise__c pe0 = TestDataGenerator.createProgramExpertise(expertises.get(0).id,products.get(0).id,false,1, false);
        pe0.recordtypeid = rt.id;
        Database.SaveResult sr = Database.insert(pe0, false);

        System.assert(!sr.isSuccess());

        for(Database.Error e : sr.getErrors()){
            System.assertEquals(Label.Program_Expertise_Duplicate_Learning_Order_Error, e.getMessage());
        }
    }
    @isTest static void testMultipleProgramInsertUniqueness() {
        setup();

        //test error gets added if match
        List<Program_Expertise__c> pExpertises = new List<Program_Expertise__c>();
        pExpertises.add(TestDataGenerator.createProgramExpertise(expertises.get(0).id,products.get(0).id,false,2, false));
        pExpertises.add(TestDataGenerator.createProgramExpertise(expertises.get(0).id,products.get(0).id,false,3, false));
        for(Program_Expertise__c pe : pExpertises){
            pe.recordtypeid = rt.id;
        }

        List<Database.SaveResult> srList = Database.insert(pExpertises, false);


        for(Database.SaveResult sr : srList){
            System.assert(!sr.isSuccess());
            for(Database.Error e : sr.getErrors()){
                System.assertEquals(Label.Program_Expertise_Duplicate_Learning_Order_Error, e.getMessage());
            }
        }
    }
    @isTest static void testMultipleProgramInsertUniquenessInSet() {
        setup();

        //test error gets added if match
        List<Program_Expertise__c> pExpertises = new List<Program_Expertise__c>();
        pExpertises.add(TestDataGenerator.createProgramExpertise(expertises.get(0).id,products.get(1).id,false,2, false));
        pExpertises.add(TestDataGenerator.createProgramExpertise(expertises.get(0).id,products.get(1).id,false,2, false));
        for(Program_Expertise__c pe : pExpertises){
            pe.recordtypeid = rt.id;
        }

        List<Database.SaveResult> srList = Database.insert(pExpertises, false);

        //make sure at least one fails, and has the message
        Boolean allSuccess = true;
        String errorMsg;
        for(Database.SaveResult sr : srList){
            if(!sr.isSuccess()){
                allSuccess = false;
                for(Database.Error e : sr.getErrors()){
                    errorMsg = e.getMessage();
                }
            }
        }

        System.assert(!allSuccess);
        System.assertEquals(Label.Program_Expertise_Duplicate_Learning_Order_Error, errorMsg);
    }
    @isTest static void testOneProgramUpdateUniqueness() {
        setup();

        //test error gets added if match
        Program_Expertise__c pe0 = programExpertises.get(0);
        pe0.Learning_Order__c = 2;

        Database.SaveResult sr = Database.update(pe0, false);

        System.assert(!sr.isSuccess());

        for(Database.Error e : sr.getErrors()){
            System.assertEquals(Label.Program_Expertise_Duplicate_Learning_Order_Error, e.getMessage());
        }
    }
    @isTest static void testMultipleProgramUpdateUniqueness() {
        setup();

        //test error gets added if match
        List<Program_Expertise__c> pExpertises = new List<Program_Expertise__c>();
        Program_Expertise__c pe0 = programExpertises.get(0);
        Program_Expertise__c pe1 = programExpertises.get(1);
        pe0.Learning_Order__c = 3;
        pe1.Learning_Order__c = 3;
        pExpertises.add(pe0);
        pExpertises.add(pe1);

        List<Database.SaveResult> srList = Database.update(pExpertises, false);


        for(Database.SaveResult sr : srList){
            System.assert(!sr.isSuccess());
            for(Database.Error e : sr.getErrors()){
                System.assertEquals(Label.Program_Expertise_Duplicate_Learning_Order_Error, e.getMessage());
            }
        }
    }
    @isTest static void testMultipleProgramUpdateUniquenessInSet() {
        setup();

        //test error gets added if match
        List<Program_Expertise__c> pExpertises = new List<Program_Expertise__c>();
        Program_Expertise__c pe0 = programExpertises.get(0);
        Program_Expertise__c pe1 = programExpertises.get(1);
        pe0.Learning_Order__c = 4;
        pe1.Learning_Order__c = 4;
        pExpertises.add(pe0);
        pExpertises.add(pe1);

        List<Database.SaveResult> srList = Database.update(pExpertises, false);

        //make sure at least one fails, and has the message
        Boolean allSuccess = true;
        String errorMsg;
        for(Database.SaveResult sr : srList){
            if(!sr.isSuccess()){
                allSuccess = false;
                for(Database.Error e : sr.getErrors()){
                    errorMsg = e.getMessage();
                }
            }
        }

        System.assert(!allSuccess);
        System.assertEquals(Label.Program_Expertise_Duplicate_Learning_Order_Error, errorMsg);
    }
    static RecordTypes_For_CBL_Processes__c recordtye2 = TestDataGenerator.createRecordTypesForCBLProcesses('Walden Program Competency', 'Program_Competency__c','Walden', true);
    static RecordTypes_For_CBL_Processes__c recordtye3 = TestDataGenerator.createRecordTypesForCBLProcesses('Competency', 'Competency__c','Walden', true);    
    static testMethod void testrollUpProgramExpertiseTotalHoursToCompleteAllCompetencies() {
        // create test data       
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);        
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Competency_Expertise__c comExper = TestDataGenerator.createCompetencyExpertise(aExper.Id,testComp.id,'Walden', true);
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper.Id,product2.id,true,4.0, false);     
        pExper.Number_of_Competencies__c = null;
        insert pExper;    
        testComp.Average_Time_in_hours__c = 4;
        update testComp;        
    }
    static testMethod void testremoveChildProgramCompetencyTBYB() {
        // create test data       
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        Area_of_Expertise__c aExper = TestDataGenerator.createAreaOfExpertise(true);        
        Competency__c testComp = TestDataGenerator.createCompetency(true);
        Competency_Expertise__c comExper = TestDataGenerator.createCompetencyExpertise(aExper.Id,testComp.id,'Walden', true);
        Program_Expertise__c  pExper = TestDataGenerator.createProgramExpertise(aExper.Id,product2.id,true,4.0, false);     
        pExper.Number_of_Competencies__c = null;
        pExper.IsTryBeforeYouBuy__c = true;
        insert pExper;    
        list<Program_Competency__c> lstPComp = [select ID,IsTryBeforeYouBuy__c from  Program_Competency__c where Program_Expertise__c =: pExper.ID];
        Program_Competency__c pComp = lstPComp[0];
        
        pExper.IsTryBeforeYouBuy__c = false;
        update pExper;
        Program_Competency__c updatedPComp =  [select id,IsTryBeforeYouBuy__c from Program_Competency__c where id =: pComp.ID];    
         System.assertEquals(updatedPComp.IsTryBeforeYouBuy__c,false);
    }
}