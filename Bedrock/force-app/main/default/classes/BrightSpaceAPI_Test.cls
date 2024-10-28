/*******************************************************************
Name  : BrightSpaceAPI_Test
Author: Sarah Khalid - Laureate
Date  : November 15, 2017
Description: Test Class for the class BrightSpaceCalls
*************************************************************************/

@isTest
private class BrightSpaceAPI_Test {

    static testMethod void myUnitTest() {
    	  BrightSpaceCalls.exceededLimits = true;
		  BrightSpaceCalls.checkAPILimits('','');      
    }
}