/************************************************************************
Name  : OutOfOfficeTriggerHandler_Test
Author: Vinod, Tom, Vinay (Appirio)
Date  : September 24, 2014
Description: TEst class for OutOfOfficeTriggerHandler


Revision History:
Ravitej Varada      - Oct 21th 2020 -  S-28110 - Update status on Coach Assignment when Out of Office record is inserted and Updated

*************************************************************************/

@isTest
private class OutOfOfficeTriggerHandler_Test {

    @isTest
    static void testOutOfOfficeActive() {


        Profile coachProfile = [SELECT Id FROM Profile WHERE Name = 'CBL Coach'];
        User coachUser = new User(Alias = 'stdCL', Email = 'standardcoachuser@laurate.net',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = coachProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standardcoachuser@laurate.net', LMS_Id__c = 500);
        insert coachUser;


        Coach_Assignment__c coachAss = new Coach_Assignment__c();
        coachAss.Status__C = 'Active';
        coachAss.Program_names__c = 'B.S. in Nursing';
        coachAss.Coach__C = coachUser.id;
        insert coachAss;


        test.startTest();

        Out_of_Office__c ooo = new Out_of_Office__c();

        ooo.Absence_Start_Date__c = system.today();
        ooo.Absence_End_Date__c = system.today() + 1;
        ooo.Reason__c = 'Sick';
        ooo.Coach_Assignment__c = coachAss.id;
        insert ooo;
        ooo.Status__c = 'Active';
        Update ooo;

        test.stopTest();


    }


    static void testOutOfOfficeInactive() {


        Profile coachProfile = [SELECT Id FROM Profile WHERE Name = 'CBL Coach'];
        User coachUser = new User(Alias = 'stdCL', Email = 'standardcoachuser@laurate.net',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = coachProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standardcoachuser@laurate.net', LMS_Id__c = 500);
        insert coachUser;


        Coach_Assignment__c coachAss = new Coach_Assignment__c();
        coachAss.Status__C = 'Active';
        coachAss.Program_names__c = 'B.S. in Nursing';
        coachAss.Coach__C = coachUser.id;
        insert coachAss;


        test.startTest();

        Out_of_Office__c ooo = new Out_of_Office__c();

        ooo.Absence_Start_Date__c = system.today();
        ooo.Absence_End_Date__c = system.today() + 1;
        ooo.Reason__c = 'Sick';
        ooo.Coach_Assignment__c = coachAss.id;

        insert ooo;

        ooo.Status__c = 'Inactive';
        Update ooo;

        test.stopTest();


    }

}