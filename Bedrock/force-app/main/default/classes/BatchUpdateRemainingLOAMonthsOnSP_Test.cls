@isTest
private class BatchUpdateRemainingLOAMonthsOnSP_Test {
    
    static Account acc;
	static Contact cont;    
    static Opportunity opp;
    static Student_Program__c studentProgram;
    
    static void setup() {
    	acc = TestDataGenerator.createAccount(true);
		cont = TestDataGenerator.createContact(acc, true);
		opp = TestDataGenerator.createOpportunity(acc.Id, cont.Id, 'Walden', true);
        studentProgram = TestDataGenerator.createStudentProgram(opp, cont.Id, 'Walden', true);
        opp.Student_Program__c = studentProgram.Id;
        
        update(opp);
        
        studentProgram.Total_LOA_Months_Available__c = 5;
        update(studentProgram);
        
        Leave_of_Absence__c loa = new Leave_of_Absence__c();
        Date myDate = Date.today();
        loa.From_Date__c = Date.newInstance(myDate.year() - 1, myDate.month(), myDate.day());
        loa.To_Date__c = Date.newInstance(myDate.year() - 1, myDate.month() + 1, myDate.day());
        loa.Student_Program__c = studentProgram.Id;
        insert(loa);
        loa.To_Date__c = Date.newInstance(myDate.year() - 1, myDate.month() + 1, myDate.day() + 1);
        update(loa);
        
    }
    
    static testMethod void testUpdateRemainingLOAMonthsOnSP() {
        setup();
        Test.startTest();
        	Database.executeBatch(new BatchUpdateRemainingLOAMonthsOnSP());
        Test.stopTest();
    
    }

}