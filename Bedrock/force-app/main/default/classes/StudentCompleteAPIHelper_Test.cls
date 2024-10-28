/************************************************************************************ 
 Apex Class Name     : StudentCompleteAPIHelper_Test
 Created Date        : 25th January 2019
 Function            : test class for StudentCompleteAPIHelper
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ravitej Varada            01/25/2019                Original Version
*************************************************************************************/
@isTest
public class StudentCompleteAPIHelper_Test 
{
	static testMethod void markCompeteInLMSTest() 
    {
        List<Student_Sections__c> stuSecLst = new List<Student_Sections__c>();
        
        Sections__c	sectns = new Sections__c(Current_Section__c=True);
        insert sectns;
        
        Competency__c com = new Competency__c(Name='ASD');
        insert com;
        
        Student_Competency__c stuCom = new Student_Competency__c(Competency__c=com.id);
        insert stuCom;
        
        Competency_Version__c comVer = new Competency_Version__c(Active__c=true,Competency_Shell_ID__c='ggg');
        insert comVer;

        for(Integer i=0 ;i<200;i++)
        {
            Student_Sections__c stuSec = new Student_Sections__c();
            stuSec.Section__c = sectns.id;
            stuSec.Student_Competency__c = stuCom.id;
            //stuSec.Competency_Shell_ID__c= comVer.id;
        	stuSecLst.add(stuSec);
        }
        insert stuSecLst; 
        
        System.assertNotEquals(stuSecLst, Null);
    
    Test.startTest();
    StudentCompleteAPIHelper stuComAPIHel = new StudentCompleteAPIHelper();
    stuComAPIHel.markCompeteInLMS(stuSecLst);
    Test.stopTest();
        
   }
}