/*******************************************************************
Name  : NoteTriggerHandler_Test
Author: Tom (Appirio)
Date  : Feb 09, 2015
Description: test class for NoteTriggerHandler
*************************************************************************/

@isTest
private class NoteTriggerHandler_Test {

  @isTest static void testCBLEditDeletePrevention() {
    Account acct = TestDataGenerator.createAccount('Custom Person Account',true);
    Note nt = new Note(ParentId=acct.Id
                      ,Body='test'
                      ,Title='testTitle'
                      ,IsPrivate=false);
    insert nt;

    String strRandom = string.valueOf( Math.random());
    Profile p = [SELECT Id FROM Profile WHERE Name='CBL Bursar'];
    User uNegative = new User( Alias = 'standt', Email='standarduser'+strRandom+'@testorg.com', 
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, 
                        TimeZoneSidKey='America/Los_Angeles', UserName='yyyywwwwwqq'+strRandom+'@testorg.com');
    insert uNegative;
    
    strRandom = string.valueOf( Math.random());
    p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
    User uPositive = new User( Alias = 'standt', Email='standarduser'+strRandom+'@testorg.com', 
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, 
                        TimeZoneSidKey='America/Los_Angeles', UserName='yyyywwwwwqq'+strRandom+'@testorg.com');
    insert uPositive;

    system.runAs(uNegative){
      nt.Body='editting';
      try { 
        update nt;
      } catch (DmlException ex) {
        system.assert(ex.getDmlMessage(0)==Label.CBL_Note_Restriction);
      }
      try { 
        delete nt;
      } catch (DmlException ex) {
        system.assert(ex!=null);
      }
    }

    system.runAs(uPositive){
      nt.Body='editting';
      update nt;
      system.assert('editting'==[SELECT Body FROM Note WHERE Id = :nt.Id][0].Body);
      delete nt;
    }


  }
	
}