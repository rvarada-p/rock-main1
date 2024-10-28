/*******************************************************************
Name  : UserHelper
Author: Sarah Khalid - Laureate
Date  : October, 2017
Description: Helper class for User trigger and trigger handler
*************************************************************************/
public with sharing class UserHelper {
    public void createUserInBS(list<User> newUsers) {
    	JsonWrapper jsonGenerator = new JsonWrapper();
    	Decimal coachRoleId = D2L__c.getValues('D2L').Coach_Role_ID__c;
    	Decimal smeRoleId = D2L__c.getValues('D2L').SME_Role_ID__c;
    	Decimal parentId = D2L__c.getValues('D2L').Org_Unit_ID__c;
    	String profileName;
    	Decimal roleId;
    	
		for(User u: newUsers) {
			if(u.Profile_Name__c == 'CBL SME Chatter Only')	 {
				roleId = smeRoleId;
			}
			else if(u.Profile_Name__c == 'CBL Coach') {
				roleId = coachRoleId;
			}
			System.debug('Role Id: ' + roleId + ' Parent Id: ' + parentId + ' Profile Name: ' + u.Profile.Name +  '   ' + u.Profile_Name__c);
			String json = jsonGenerator.createUser('', u.FirstName, u.LastName, u.Email, roleId, true);
			BrightSpaceCalls.createUser(json, u.Id);   
		}	 
    }	   
}