@isTest
public class ProgramTriggerHandler_Test {
    
    
    
    @isTest static void testMethod_One() {
        // create test data
        
        D2L__c setting = new D2L__c();
        setting.Name = 'D2L';
        setting.Org_Unit_ID__c = 6606;
        setting.Program_Type__c = 101;
        setting.LP_Version__c = 1.50;
        setting.Create_AoE__c = '/d2l/api/lp/1.5/courses/';
        insert setting; 
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_BsOrgUnit400());
        
        test.startTest();
        Product2 parentProduct = TestDataGenerator.createProduct('Program', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('Test Program', 'Walden', false);
        product2.Parent_Program__c = parentProduct.Id;
        product2.ProductCode = 'C_TEST';
        product2.Publish_to_LMS__c = true;
        product2.Display_Name__c = 'Test Program';
        insert product2;
        
        Product2 product3 = TestDataGenerator.createProduct('Test Program 2', 'Walden', false);
        product3.Parent_Program__c = parentProduct.Id;
        product3.ProductCode = 'C_TEST2';
        product3.Display_Name__c = 'Test Program 2';
        insert product3;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_BsOrgUnit());
        product3.Publish_to_LMS__c = true;
        update product3;
        test.stopTest();
        
    }
    
    
    
    
    
    
}