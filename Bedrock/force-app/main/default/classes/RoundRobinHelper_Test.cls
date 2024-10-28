/*******************************************************************
Name  : RoundRobinHelper_Test
Author: Vinod Kumar (Appirio JDC)
Date  : January 23, 2015
Description: Test class for the helper class RoundRobinHelper
Related task: T-355768

Revision History
Horacio Sanchez     - Apr 27th 2022 -  S-84371: L2: Keep Tempo Student Assigned to Same Coach if Coach is Part of New Program's Assignment Group
*************************************************************************/  
@isTest
private class RoundRobinHelper_Test {
    /*
test method for the unit test of function getNextRRUsers
*/
    static testMethod void testGetNextRRUsers() {
        // create test data        
        string strRandom = string.valueOf( Math.random());
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        User u1 = new User(Alias = 'standt', Email='standarduser'+strRandom+'@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='yyyywwwwwqq'+strRandom+'@testorg.com');
        insert u1;
        
        strRandom = string.valueOf( Math.random());
        User u2 = new User(Alias = 'user02', Email='standarduser2'+strRandom+'@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='yyyywwwwwqq'+strRandom+'@testorg.com');
        insert u2;
        
        strRandom = string.valueOf( Math.random());
        User u3 = new User(Alias = 'user02', Email='standarduser2'+strRandom+'@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='yyyywwwwwqq'+strRandom+'@testorg.com');
        insert u3;
        
        strRandom = string.valueOf( Math.random());
        User u4 = new User(Alias = 'user02', Email='standarduser2'+strRandom+'@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='yyyywwwwwqq'+strRandom+'@testorg.com');
        insert u4;
        
        system.runAs(u1){
            Institution__c inst = TestDataGenerator.createInstitution('testInst', true); 
            Round_Robin_Queue__c objRR = TestDataGenerator.createRoundRobinQueue('Test group1', inst.ID,true);
            Group newGroup = new Group();
            newGroup.Name = 'Test group1';
            newGroup.DoesIncludeBosses = false; 
            insert newGroup;
            list<GroupMember> lstGmember = new list<GroupMember>();
            GroupMember newMember = new GroupMember();
            newMember.GroupId = newGroup.ID;
            newMember.UserOrGroupId = u1.ID;
            lstGmember.add(newMember);
            GroupMember newMember2 = new GroupMember();
            newMember2.GroupId = newGroup.ID;
            newMember2.UserOrGroupId = u2.ID;
            lstGmember.add(newMember2);
            Group newGroup2 = new Group();
            Round_Robin_Queue__c objRR2 = TestDataGenerator.createRoundRobinQueue('Test group2', inst.ID,true);
            newGroup2.Name = 'Test group2';
            newGroup2.DoesIncludeBosses = false; 
            insert newGroup2;
            GroupMember newMember3 = new GroupMember();
            newMember3.GroupId = newGroup2.ID;
            newMember3.UserOrGroupId = u3.ID;
            lstGmember.add(newMember3);
            GroupMember newMember4 = new GroupMember();
            newMember4.GroupId = newGroup2.ID;
            newMember4.UserOrGroupId = u4.ID;
            lstGmember.add(newMember4);
            insert lstGmember;
            Group newGroup3 = new Group();
            newGroup3.Name = 'Test group3';
            newGroup3.DoesIncludeBosses = false; 
            insert newGroup3;    
            RoundRobinHelper objRRHelper = new RoundRobinHelper();
            list<Id> listUserIds = new list<Id>();
            List<String> listRRGroupNames = new list<string>();
            listRRGroupNames.add('Test group5');
            // test if no group is defined with given name
            try{
                listUserIds = objRRHelper.getNextRRUsers(listRRGroupNames,null);
            }catch(exception ex){
                ex.getMessage().contains('No Queue or Public Group Test group5 defined in Round Robin table');
            }
            listRRGroupNames = new list<string>();
            Round_Robin_Queue__c objRR3 = TestDataGenerator.createRoundRobinQueue('Test group3', inst.ID,true);
            listRRGroupNames.add('Test group3');
            // test if group is defined with given name but no member is there
            try{
                listUserIds = objRRHelper.getNextRRUsers(listRRGroupNames,null);
            }catch(exception ex){
                ex.getMessage().contains('No Queue or Public Group Test group3 defined (or populated with at least 1 user) in Salesforce.');
            }
            listRRGroupNames = new list<string>();
            listRRGroupNames.add('Test group1');
            listRRGroupNames.add('Test group2');
            
            listUserIds = objRRHelper.getNextRRUsers(listRRGroupNames,null);
            system.assert(listUserIds.size() == 2);
            system.assertEquals(listUserIds[0],u1.ID);
            system.assertEquals(listUserIds[1],u3.ID);		
        }
        
    }
    
    
    static testMethod void getNextRRUsersAssignmentGroup() {
        // create test data        
        string strRandom = string.valueOf( Math.random());
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        User u1 = new User(Alias = 'standt', Email='standarduser'+strRandom+'@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='yyyywwwwwqq'+strRandom+'@testorg.com');
        insert u1;
        
        strRandom = string.valueOf( Math.random());
        User u2 = new User(Alias = 'user02', Email='standarduser2'+strRandom+'@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='yyyywwwwwqq'+strRandom+'@testorg.com');
        insert u2;
        
        strRandom = string.valueOf( Math.random());
        User u3 = new User(Alias = 'user02', Email='standarduser2'+strRandom+'@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='yyyywwwwwqq'+strRandom+'@testorg.com');
        insert u3;
        
        strRandom = string.valueOf( Math.random());
        User u4 = new User(Alias = 'user02', Email='standarduser2'+strRandom+'@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='yyyywwwwwqq'+strRandom+'@testorg.com');
        insert u4;
        
        system.runAs(u1){
            Institution__c inst = TestDataGenerator.createInstitution('testInst', true); 
             
            
            Assignment_Group_Name__c  newGroup = new Assignment_Group_Name__c ();
            newGroup.Name = 'Test group1';
            newGroup.Queue_Position__c  = 0; 
            insert newGroup;
            
            
            Assignment_Groups__c mem = new Assignment_Groups__c();
            mem.User__c = u4.id;
            mem.Group_Name__c = newGroup.id;
            insert mem;
            
            
            
            RoundRobinHelper objRRHelper = new RoundRobinHelper();
            list<Id> listUserIds = new list<Id>();
            List<String> listRRGroupNames = new list<string>();
            listRRGroupNames.add('Test group1');
            // test if no group is defined with given name
            try{
                listUserIds = objRRHelper.getNextRRUsersAssignmentGroup(listRRGroupNames,null);
                Boolean notFound = objRRHelper.isCoachInNewSPAssignmentGroup(listRRGroupNames, u3.Id);
                Boolean found = objRRHelper.isCoachInNewSPAssignmentGroup(listRRGroupNames, u4.Id);
            }catch(exception ex){
                ex.getMessage().contains('No Queue or Public Group Test group5 defined in Round Robin table');
            }
       
        }
        
    }
    
}