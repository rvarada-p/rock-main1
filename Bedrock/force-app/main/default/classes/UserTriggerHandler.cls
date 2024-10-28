/*******************************************************************
Name  : UserTriggerHandler
Author: Sarah Khalid - Laureate
Date  : October, 2017
Description: Trigger handler class for User trigger
*************************************************************************/
public with sharing class UserTriggerHandler {

  public void onBeforeUpdate(list<User> newUsers, map<ID,User> oldMap){

    list<User> userList = new list<User>();
    UserHelper objHelper = new UserHelper();
    for(User u: newUsers){
    	if(u.Publish_to_LMS__c==true && oldMap.get(u.id).Publish_to_LMS__c!=true && (u.Profile_Name__c == 'CBL Coach') || (u.Profile_Name__c == 'CBL SME Chatter Only')) {    	
			userList.add(u);
    	}
    }
    if(!userList.isEmpty()){ 
      objHelper.createUserInBS(userList); 
    }
  }   
  
}