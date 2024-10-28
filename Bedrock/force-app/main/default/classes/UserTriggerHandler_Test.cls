/*******************************************************************
Name  : UserTriggerHandler_Test
Author: Sarah Khalid - Laureate
Date  : October, 2017
Description: Test Class for the Handler class AreaOfExpertiseTriggerHandler and trigger AreaOfExpertiseTrigger.
             Covering the test coverage of the helper class AreaOfExpertiseHelper
*************************************************************************/

@isTest (SeeAllData=true)
private class UserTriggerHandler_Test {
    static User smeUser;
        
    static testMethod void testOnBeforeUpdate() {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;

        User coachUser = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'CBL Coach'].Id,
             FirstName = 'test',
             LastName = 'Coach',
             Email = 'coachtestuser@test.com',
             Username = 'coachtestuser@test.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US',
             UserRoleId = r.Id
        );
        
        insert coachUser;       
        
        coachUser.Publish_to_LMS__c = true;
        update coachUser;
        
            smeUser = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'CBL SME Chatter Only'].Id,
             FirstName = 'test',
             LastName = 'SME',
             Email = 'smetestuser@test.com',
             Username = 'smetestuser@test.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US',
             UserRoleId = r.Id
        );
        
        insert smeUser;     
        
        smeUser.Publish_to_LMS__c = true;
        update smeUser;     
        
        Decimal coachRoleId = D2L__c.getValues('D2L').Coach_Role_ID__c;
        Decimal smeRoleId = D2L__c.getValues('D2L').SME_Role_ID__c;
        Decimal parentId = D2L__c.getValues('D2L').Org_Unit_ID__c;
                             
        JsonWrapper jsonGenerator = new JsonWrapper();
        
        String json = jsonGenerator.createUser(parentId, smeUser.FirstName, smeUser.LastName, smeUser.Email, smeRoleId, true);
            
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_BSUser());
        HttpResponse  response = New HttpResponse();
        
        BrightSpaceCalls.createUser(json, smeUser.Id);          
        
    }
    
    static testMethod void testOnBeforeUpdate_NegativeCondition() {
    UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
    insert r;

    User coachUser = new User(
         ProfileId = [SELECT Id FROM Profile WHERE Name = 'CBL Coach'].Id,
         FirstName = 'test',
         LastName = 'Coach',
         Email = 'coachtestuser@test.com',
         Username = 'coachtestuser@test.com' + System.currentTimeMillis(),
         CompanyName = 'TEST',
         Title = 'title',
         Alias = 'alias',
         TimeZoneSidKey = 'America/Los_Angeles',
         EmailEncodingKey = 'UTF-8',
         LanguageLocaleKey = 'en_US',
         LocaleSidKey = 'en_US',
         UserRoleId = r.Id
    );
    
    insert coachUser;    
    
    coachUser.Publish_to_LMS__c = true;
    update coachUser;
    
      smeUser = new User(
         ProfileId = [SELECT Id FROM Profile WHERE Name = 'CBL SME Chatter Only'].Id,
         FirstName = 'test',
         LastName = 'SME',
         Email = 'smetestuser@test.com',
         Username = 'smetestuser@test.com' + System.currentTimeMillis(),
         CompanyName = 'TEST',
         Title = 'title',
         Alias = 'alias',
         TimeZoneSidKey = 'America/Los_Angeles',
         EmailEncodingKey = 'UTF-8',
         LanguageLocaleKey = 'en_US',
         LocaleSidKey = 'en_US',
         UserRoleId = r.Id
    );
    
    insert smeUser;    
    
    smeUser.Publish_to_LMS__c = true;
    update smeUser;    
       
       Decimal coachRoleId = D2L__c.getValues('D2L').Coach_Role_ID__c;
      Decimal smeRoleId = D2L__c.getValues('D2L').SME_Role_ID__c;
    Decimal parentId = D2L__c.getValues('D2L').Org_Unit_ID__c;
                         
      JsonWrapper jsonGenerator = new JsonWrapper();
      
    String json = jsonGenerator.createUser(parentId, smeUser.FirstName, smeUser.LastName, smeUser.Email, smeRoleId, true);
      
      Test.setMock(HttpCalloutMock.class, new MockHttpResponse_BSNegative());
      HttpResponse  response = New HttpResponse();
      
      BrightSpaceCalls.createUser(json, smeUser.Id);       
    
    }
     
    
}