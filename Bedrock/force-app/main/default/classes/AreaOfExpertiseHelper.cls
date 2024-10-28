/*******************************************************************
Name  : AreaOfExpertiseHelper
Author: Sarah Khalid - Laureate
Date  : September 15, 2017
Description: Helper class for Area of Expertise trigger and trigger handler
*************************************************************************/
public with sharing class AreaOfExpertiseHelper {
	
    public void createAreaOfExpertiseInBS(list<Area_of_Expertise__c> aoes) {
    	JsonWrapper jsonGenerator = new JsonWrapper();
    	Decimal parentId = D2L__c.getValues('D2L').Org_Unit_ID__c;
    	Decimal aoeTypeId = D2L__c.getValues('D2L').AoE_Type__c;
		for(Area_of_Expertise__c aoe: aoes) {
			String json = jsonGenerator.createOrgUnitCreateData(aoeTypeId, aoe.Display_Name__c, aoe.Course_Code__c.trim(), new list<Decimal>{parentId});
			BrightSpaceCalls.createAreaOfExpertise(json, aoe.Id);
		}	
    }
    
}