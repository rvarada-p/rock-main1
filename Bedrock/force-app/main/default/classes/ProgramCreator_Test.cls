@isTest
public class ProgramCreator_Test {
    
    static testMethod void Test_getCSVObject() {
        String simulatedLines = 'Parent Program ,Program Code,Program Name,Outcome,Program Major,' + 
            'Degree Level,Specialization,Institution,Credit Type,Total Credits in Program,Credit Progression Rate,Maximum Transfer Credits,' +
            'Required Transfer Credits,Required Upper Level Credits,Required Institution Credits,Category,Level,Total CE,Subject Area Expertise,\n' +
            'P_TEST,C_TEST20,B.S. in Testology,Bachelors,Project Management,Graduate,,Walden,Quarter,,4.5,80,15,45,40,Core,Lower,36,,\n' +
            'P_TEST,C_TEST3,B.S. in Testology,Bachelors,Project Management,Graduate,,Walden,Quarter,80,,80,,45,40,Core,Upper,30,,\n' +
            'P_TEST,C_TEST3,B.S. in Testology,Bachelors,Project Management,Graduate,,Walden,Quarter,80,4.5,,,45,40,General Elective,Any,70,,\n' +
            'P_TEST,C_TEST3,B.S. in Testology,Bachelors,Project Management,Graduate,,Walden,Quarter,80,4.5,80,,45,40,General Education,Any,45,,\n' +
            'P_TEST,C_TEST3,B.S. in Testology,Bachelors,Project Management,Graduate,,Walden,Quarter,80,4.5,80,,,40,General Education,Any,10,Written and Oral Communication,\n' +
            'P_TEST,C_TEST3,B.S. in Testology,Bachelors,Project Management,Graduate,,Walden,Quarter,80,4.5,80,,45,,General Education,Any,10,Mathematics/Natural Sciences,\n' +
            'P_TEST,C_TEST3,B.S. in Testology,Bachelors,Project Management,Graduate,,Walden,Quarter,80,4.5,80,,45,40,General Education,Any,10,Social Sciences,\n' +
            'P_TEST,C_TEST3,B.S. in Testology,Bachelors,Project Management,Graduate,,Walden,Quarter,,,,,,,General Education,Any,10,Arts and Humanities,\n' +
            'P_TEST,C_TEST3,B.S. in Testology,Bachelors,Project Management,Graduate,,Walden,Quarter,80,4.5,80,,45,40,General Education,Any,,Any Category,';
        Test.startTest();
            
        // Insert the custom settings for D2L
        D2L__c setting = new D2L__c();
        setting.Name = 'D2L';
        setting.Org_Unit_ID__c = 6606;
        setting.Program_Type__c = 102;
        setting.LP_Version__c = 1.50;
        setting.Create_AoE__c = '/d2l/api/lp/1.5/courses/';
        insert setting; 
        
        // Insert Parent Program
        /*Product2 parentProgram = new Product2();
        parentProgram.productCode = 'P_TEST';
        parentProgram.Name = 'M.S. in Testology';
        insert parentProgram;*/
        
        // Insert Walden Institution
        Institution__c institution = new Institution__c();
        institution.name = 'Walden';
        insert institution;
        
        ProgramCreator.getCSVObject(simulatedLines);
        Test.stopTest();
    }

}