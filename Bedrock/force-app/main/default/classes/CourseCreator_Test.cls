@isTest
public class CourseCreator_Test {
    
    static testMethod void Test_getCSVObject() {
        String simulatedLines = 'Program Code,AOE Course Code,AOE Name,Level,Category,Subject Area,Pseudo Course,AOE Overview,Competency Code,Competency Title,Credit Equivalency,Assessment Type,Description,Type,\n ' +
            'C_TEST,MHRM 6701,Strategic Positioning and Social Change,6000,Core,,FALSE,,PN001,Human Resources: Strategic,0.75,WP,Describe the strategic nature and impact of the work of Human Resources (HR).,Academic,\n' +
            'C_TEST,MHRM 6701,Strategic Positioning and Social Change,6000,Core,,FALSE,,PN002,"Human Resource Management: Theories, Models, and Frameworks",0.75,PT,"Analyze theories, models, and frameworks of strategic human resource management (HRM).",Academic,\n' +
            'C_TEST,MHRM 6701,Strategic Positioning and Social Change,6000,Core,,FALSE,,PN003,Human Resources: Global,0.75,SA,"Analyze opportunities, challenges, and issues related to global HRM.",Academic,\n' +
            'C_TEST,MHRM 6701,Strategic Positioning and Social Change,6000,Core,,FALSE,,PN004,"Human Resources: Organization Innovation, Quality, and Social Change",0.75,SR,"Evaluate HR best practices that drive innovation, quality, and social change in an organization.",Academic,\n' +
            'C_TEST2,MHRM 6751,Global and Cultural Effectiveness,6000,Core,,FALSE,,GL001,Global Environment,0.75,OA,Explain the global business environment and its implications for organizations.,Academic,\n' +
            'C_TEST2,MHRM 6751,Global and Cultural Effectiveness,6000,Core,,FALSE,,GL002,Human Resources: The Global Role and Operating Challenges,0.75,WR,Examine the unique human resource (HR) challenges of operating globally.,Academic,\n' +
            'C_TEST2,MHRM 6751,Global and Cultural Effectiveness,6000,Core,,FALSE,,GL003,Human Resources Role in Building Capacity,0.75,WR,Analyze Human Resource’s expanded role for creating organizational capacity in a global environment.,Academic,\n' +
            'C_TEST2,MHRM 6751,Global and Cultural Effectiveness,6000,Core,,FALSE,,GL004,Human Resources Role in Creating Organizational Leverage,0.75,SR,Analyze Human Resource’s opportunities to create competitive advantage through a globally diverse workforce.,Academic,\n';
        Test.startTest();
        
        Product2 parentProduct = TestDataGenerator.createProduct('P_TEST', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('C_TEST', 'Walden', false);
        product2.Parent_Program__c = parentProduct.Id;
        product2.ProductCode = 'C_TEST';
        
        product2.LMS_ID__c = '74374';
        insert product2;
        Product2 product3 = TestDataGenerator.createProduct('C_TEST2', 'Walden', false);
        product3.Parent_Program__c = parentProduct.Id;
        product3.ProductCode = 'C_TEST2';
        product3.LMS_ID__c = '74374';
        insert product3;
        
        D2L__c setting = new D2L__c();
        setting.Name = 'D2L';
        setting.Org_Unit_ID__c = 6606;
        setting.AOE_Type__c = 101;
        setting.LP_Version__c = 1.50;
        setting.Create_AoE__c = '/d2l/api/lp/1.5/courses/';
        insert setting; 
        
             
        CSVHeader obj = new CSVHeader( 'column_name',  'column_type');
        CSVHeader obj1 = new CSVHeader( 'column_name');
        
        CourseCreator.getCSVObject(simulatedLines);
        Test.stopTest();
    }
    
}