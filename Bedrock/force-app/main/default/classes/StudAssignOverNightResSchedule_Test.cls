/*******************************************************************
Name  : StudAssignOverNightResSchedule_Test
Author: Sarah Khalid - Laureate
Modified By: 
Date  : November 14 , 2017
Description: test class for the test coverage of the class StudAssignOverNightOutOfOffResSchedule
*************************************************************************/

@isTest (SeeAllData=true)
private class StudAssignOverNightResSchedule_Test {

    static testMethod void myUnitTest() {
        CustomerSupportTeamReset team = new CustomerSupportTeamReset();
        team.OvernightReset();
    }
    
    static testMethod void testScheduledJob() {
    	Test.startTest();
		StudAssignOverNightOutOfOffResSchedule sh1 = new StudAssignOverNightOutOfOffResSchedule();
		String sch = '0 0 23 * * ?'; 
		System.schedule('Reset Student Assignment', sch, sh1); 
		Test.stopTest();  
    }
}