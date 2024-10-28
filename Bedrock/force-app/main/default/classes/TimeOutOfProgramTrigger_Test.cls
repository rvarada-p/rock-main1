/************************************************************************
Name  : TimeOutOfProgramTrigger_Test
Author: Horacio Sanchez
Date  : October 15, 2020
Description: Test class for TimeOutOfProgramTrigger Trigger, TimeOutOfProgramTriggerHandler and TimeOutOfProgramTriggerHelper classes 
*************************************************************************/

@isTest
public class TimeOutOfProgramTrigger_Test {
    
    static Account acc;
	static Contact cont;    
    static Opportunity opp;
    static Student_Program__c studentProgram;
    
    static testMethod void testUpdateGAPMonthsOnSP() {
        acc = TestDataGenerator.createAccount(true);
		cont = TestDataGenerator.createContact(acc, true);
		opp = TestDataGenerator.createOpportunity(acc.Id, cont.Id, 'Walden', true);
        studentProgram = TestDataGenerator.createStudentProgram(opp, cont.Id, 'Walden', true);
        opp.Student_Program__c = studentProgram.Id;
        
        update(opp);
        
        studentProgram.Total_LOA_Months_Available__c = 5;
        update(studentProgram);
        
        Time_out_of_Program__c toop = new Time_out_of_Program__c();
        Date myDate = Date.today();
        toop.From_Date__c = Date.newInstance(myDate.year() - 1, myDate.month(), myDate.day());
        toop.To_Date__c = Date.newInstance(myDate.year() - 1, myDate.month() + 1, myDate.day());
        toop.Student_Program__c = studentProgram.Id;
        
        Test.startTest();
        insert(toop);
        toop.To_Date__c = Date.newInstance(myDate.year() - 1, myDate.month() + 3, myDate.day() + 1);
        update(toop);
        Test.stopTest();
    
    }

}