/*******************************************************************
Name  : AccountCustomPersonHelper_Test
Author: Tom (Appirio)
Date  : March 20, 2015
Description: Test class for AccountCustomPersonHelper and AccountTriggerHandler
*************************************************************************/
@isTest
private class AccountCustomPersonHelper_Test {
	
	@isTest static void testUpdateCustomPersonContact() {
		Account acct = TestDataGenerator.createAccount('Custom Person Account', true);
    Contact testCon = TestDataGenerator.createContact(acct, 'Custom Person Account Contact', true);
    testCon.MailingStreet = 'mailStreet';
    testCon.MailingCity = 'mailCity';
    testCon.MailingCountryCode = 'US';
    testCon.MailingStateCode = 'NY';
    testCon.MailingPostalCode = '11111';
    testCon.Mailing_Non_US_State__c = 'nonUsStatia';
    testCon.Phone = '888-777-0009';
    update testCon;
    acct.BillingStreet = 'billStreet';
    acct.BillingCity = 'billville';
    acct.BillingCountryCode = 'US';
    acct.BillingStateCode = 'CA';
    acct.BillingPostalCode = '99999';
    acct.Billing_Non_US_State__c = 'nonUsStatian';
    acct.Phone = '222-444-2424';
    update acct;
    Contact con = [SELECT MailingStreet,MailingCity,MailingCountryCode,MailingStateCode,MailingPostalCode,Mailing_Non_US_State__c,Phone 
                  FROM Contact WHERE Id =:testCon.Id];
    system.assertEquals('billStreet',con.MailingStreet);
    system.assertEquals('billville',con.MailingCity);
    system.assertEquals('US',con.MailingCountryCode);
    system.assertEquals('CA',con.MailingStateCode);
    system.assertEquals('99999',con.MailingPostalCode);
    system.assertEquals('nonUsStatian',con.Mailing_Non_US_State__c);
    system.assertEquals('222-444-2424',con.Phone);
	}
	
}