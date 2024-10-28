@isTest (SeeAllData=true)
public class UserHelper_Test {
	
    static testMethod void testCreateUserInBS() {
        
        List<User> userList = new List<User>();
        List<Profile> cblCoachProfileId = [SELECT Id, Name FROM Profile WHERE Name = 'CBL Coach' LIMIT 1];
        List<Profile> cblSMEChatterOnlyId = [SELECT Id, Name FROM Profile WHERE Name = 'CBL SME Chatter Only' LIMIT 1];
        List<User> cblCoachList = [SELECT id, Profile_Name__c, Profile.Name, FirstName, LastName, Email 
                    FROM User 
                    WHERE ProfileId =: cblCoachProfileId[0].id LIMIT 1];
        userList.addAll(cblCoachList);
        
        List<User> cblSMEChatterOnlyList = [SELECT id, Profile_Name__c, Profile.Name, FirstName, LastName, Email 
                    FROM User 
                    WHERE ProfileId =: cblSMEChatterOnlyId[0].id LIMIT 1];
        userList.addAll(cblSMEChatterOnlyList);
        
        UserHelper testClass = new UserHelper();
        
        Test.startTest();
        testClass.createUserInBS(userList);
        Test.stopTest();
        
    }
}