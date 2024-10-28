/*******************************************************************
Name  : AreaOfExpertiseTriggerHandler_Test
Author: Sarah Khalid - Laureate
Date  : September 21, 2017
Description: Test Class for the Handler class AreaOfExpertiseTriggerHandler and trigger AreaOfExpertiseTrigger.
             Covering the test coverage of the helper class AreaOfExpertiseHelper
*************************************************************************/

@istest 
private class AreaOfExpertiseTriggerHandler_Test {
    private static Product2 product2;
    private static Area_of_Expertise__c aExper;
    private static D2L__c settings;
    
    public static void setup() {
        product2 = TestDataGenerator.createProduct('test', 'Walden', true);
        aExper = TestDataGenerator.createAreaOfExpertiseBS(true);        
         
        //Insert the custom settings for D2L
        D2L__c setting = new D2L__c();
        setting.Name = 'D2L';
        setting.Org_Unit_ID__c = 6606;      
        setting.AoE_Type__c = 101;
        setting.LP_Version__c = 1.50;
        setting.Create_AoE__c = '/d2l/api/lp/1.50/orgstructure/';
        
        insert setting; 
        
    }

    static testMethod void testOnBeforeUpdate() {
         setup();
         aExper.Publish_To_LMS__c = true;
         update aExper;
         
         List<Area_of_Expertise__c> createdAoes = [SELECT ID, RecordTypeId, Publish_to_LMS__c, LMS_ID__c FROM Area_of_Expertise__c WHERE Id = :aExper.Id];
         system.assert(createdAoes.size() == 1);
    }
    
    static testmethod void testHttpCallout() {
        setup();
        
        Decimal parentId = D2L__c.getValues('D2L').Org_Unit_ID__c;
        Decimal aoeTypeId = D2L__c.getValues('D2L').AoE_Type__c;

                             
        JsonWrapper jsonGenerator = new JsonWrapper();
        System.debug('Parent ID: ' + parentId + ' AoE Type ID: ' + aExper + ' AoE Code ' + aExper.Course_Code__c);  
        String json = jsonGenerator.createOrgUnitCreateData(aoeTypeId, aExper.Display_Name__c, 'TEST', new list<Decimal>{parentId});
            
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_BSAPI());
        HttpResponse  response = New HttpResponse();
        
        //Test.startTest();
        BrightSpaceCalls.createAreaOfExpertise(json, aExper.Id);
        //Test.stopTest();
    }
    
      static testmethod void testHttpCallout_NegativeCondition() {
     setup();
     
      Decimal parentId = D2L__c.getValues('D2L').Org_Unit_ID__c;
      Decimal aoeTypeId = D2L__c.getValues('D2L').AoE_Type__c;

                         
      JsonWrapper jsonGenerator = new JsonWrapper();
      System.debug('Parent ID: ' + parentId + ' AoE Type ID: ' + aExper + ' AoE Code ' + aExper.Course_Code__c);  
    String json = jsonGenerator.createOrgUnitCreateData(aoeTypeId, aExper.Display_Name__c, 'TEST', new list<Decimal>{parentId});
      
      Test.setMock(HttpCalloutMock.class, new MockHttpResponse_BSNegative());
      HttpResponse  response = New HttpResponse();
      
      //Test.startTest();
      BrightSpaceCalls.createAreaOfExpertise(json, aExper.Id);
      //Test.stopTest();
    }
    
     static testmethod void testHttpCalloutException() {
        setup();
        
        Decimal parentId = D2L__c.getValues('D2L').Org_Unit_ID__c;
        Decimal aoeTypeId = D2L__c.getValues('D2L').AoE_Type__c;

                             
        JsonWrapper jsonGenerator = new JsonWrapper();
        System.debug('Parent ID: ' + parentId + ' AoE Type ID: ' + aExper + ' AoE Code ' + aExper.Course_Code__c);  
        String json = jsonGenerator.createOrgUnitCreateData(aoeTypeId, aExper.Display_Name__c, 'TEST', new list<Decimal>{parentId});
            
        //Test.startTest();
        BrightSpaceCalls.createAreaOfExpertise(json, aExper.Id);
        //Test.stopTest();
    }   
    
}