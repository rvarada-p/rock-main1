/*******************************************************************
Name  : OpenLookupPopupController_Test
Author: Virendra (Appirio)
Date  : October 10, 2014
Description: Test Class for OpenLookupPopupController
*************************************************************************/
@isTest
private class OpenLookupPopupController_Test {
    
    static testMethod void testLookUp() {
        Course__c testCourse = TestDataGenerator.createNewCourse('EDU-Test', true);
        list<Competency__c> competencies = new list<Competency__c> ();
        Competency__c  newCompetency1 = TestDataGenerator.createCompetency('Comp1',false);
        Competency__c  newCompetency2 = TestDataGenerator.createCompetency('Comp2',false);
        Competency__c  newCompetency3 = TestDataGenerator.createCompetency('Comp3',false);
        
        newCompetency1.name='Test1';
        newCompetency2.name='Test2';
        newCompetency3.name='Test3';
        
        competencies.add(newCompetency1);
        competencies.add(newCompetency2);
        competencies.add(newCompetency3);
        insert competencies;
        
         test.startTest();
           
            PageReference pageRef = Page.OpenLookupPopup;
            pageRef.getParameters().put('Object', 'Competency__c');
            pageRef.getParameters().put('fieldName', 'Name');
            pageRef.getParameters().put('searchText', 'Test');
            pageRef.getParameters().put('fieldSetName', 'account_search_result');
            Test.setCurrentPage(pageRef);
         
            OpenLookupPopupController cController  = new OpenLookupPopupController();
            
            system.assertEquals(cController.listRecords.size(),3); 
            
         test.stopTest();
    }

}