/*******************************************************************
Name  : ProgramHelper
Author: Ravitej Varada - Laureate
Date  : Feb 27, 2020
Description: Helper class for Program trigger
*************************************************************************/

public with sharing class ProgramHelper {
	
    public void createProgramInBS(list<product2> progs) {
    	JsonWrapper jsonGenerator = new JsonWrapper();
    	Decimal parentId = D2L__c.getValues('D2L').Org_Unit_ID__c;
    	Decimal progTypeId = D2L__c.getValues('D2L').Program_Type__c;
		for(product2 prog: progs) {
			String json = jsonGenerator.createOrgUnitCreateData(progTypeId, prog.Display_Name__c, prog.ProductCode.trim(), new list<Decimal>{parentId});
			system.debug('json'+json);
            BrightSpaceCalls.createProgram(json, prog.Id);
		}	
    }
    
}