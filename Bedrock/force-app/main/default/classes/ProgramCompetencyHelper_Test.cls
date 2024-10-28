/*******************************************************************
Name  : ProgramCompetencyHelper_Test
Author: (Appirio)
Date  : October 6, 2014
*************************************************************************/
@isTest
private class ProgramCompetencyHelper_Test {
    private static List<Program_Expertise__c> programExpertises;
    private static List<Program_Competency__c> programCompentencies;
    private static RecordType rt;
    private static RecordType lrt;
    private static void setup(){
        rt = [select id from recordtype where sobjecttype = 'Program_Competency__c' and name = 'Walden' limit 1];
        lrt = [select id from recordtype where sobjecttype = 'Program_Competency__c' and name = 'Laureate' limit 1];
        TestDataGenerator.createRecordTypesForCBLProcesses('pe walden', 'Program_Competency__c','Walden', true);
        List<Product2> products = new List<Product2>();
        products.add(TestDataGenerator.createProduct('test0', 'Walden', false));
        products.add(TestDataGenerator.createProduct('test1', 'Walden', false));
        products.add(TestDataGenerator.createProduct('test2', 'Walden', false));
        insert products;

        List<Area_of_Expertise__c> expertises = new List<Area_of_Expertise__c>();
        expertises.add(TestDataGenerator.createAreaOfExpertise(false));
        expertises.add(TestDataGenerator.createAreaOfExpertise(false));
        insert expertises;

        programExpertises = new List<Program_Expertise__c>();
        programExpertises.add(TestDataGenerator.createProgramExpertise(expertises.get(0).id,products.get(0).id,false,1, false)); 
        programExpertises.add(TestDataGenerator.createProgramExpertise(expertises.get(0).id,products.get(1).id,false,2, false)); 
        programExpertises.add(TestDataGenerator.createProgramExpertise(expertises.get(1).id,products.get(2).id,false,1, false)); 
        insert programExpertises;

        List<Competency__c> competencies = new List<Competency__c>();
        competencies.add(TestDataGenerator.createCompetency(false));
        competencies.add(TestDataGenerator.createCompetency(false));
        competencies.add(TestDataGenerator.createCompetency(false));
        insert competencies;

        programCompentencies = new List<Program_Competency__c>();
        programCompentencies.add(TestDataGenerator.createProgramCompetency(competencies.get(0).id,products.get(0).id,programExpertises.get(0).id,false,1, false));
        programCompentencies.add(TestDataGenerator.createProgramCompetency(competencies.get(1).id,products.get(1).id,programExpertises.get(0).id,false,2, false));
        programCompentencies.add(TestDataGenerator.createProgramCompetency(competencies.get(0).id,products.get(0).id,programExpertises.get(1).id,false,1, false));
        programCompentencies.add(TestDataGenerator.createProgramCompetency(competencies.get(1).id,products.get(1).id,programExpertises.get(1).id,false,2, false));
        programCompentencies.add(TestDataGenerator.createProgramCompetency(competencies.get(2).id,products.get(2).id,programExpertises.get(1).id,false,3, false));
        for(Program_Competency__c pc : programCompentencies){
            pc.recordtypeid = rt.id;
        }

        insert programCompentencies;


    }
    @isTest static void testNoValidationOnNoCBL() {
        setup();

        //test error gets added if match
        Competency__c competency = TestDataGenerator.createCompetency(true);
        Product2 product = TestDataGenerator.createProduct('test0', 'Walden', true);

        Program_Competency__c pc0 = TestDataGenerator.createProgramCompetency(competency.id,product.id,programExpertises.get(0).id,false,1, false);

    }

    
}