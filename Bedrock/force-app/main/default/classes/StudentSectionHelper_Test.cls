/************************************************************************************ 
 Apex Class Name     : StudentSectionHelper_Test
 Created Date        : 27th January 2019
 Function            : test class for StudentSectionHelper
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ravitej Varada            01/27/2019                Original Version
*************************************************************************************/
@isTest
public class StudentSectionHelper_Test 
{
	static testMethod void enrollInBS()
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
        	stuSecLst.add(stuSec);
        }
        insert stuSecLst;
        
        System.assertNotEquals(stuSecLst, Null);
        
        D2L__c setting = new D2L__c();
        setting.Name = 'D2L';
        setting.Student_Role_ID__c = 12.34;
        insert setting;
        
        Test.StartTest();
        StudentSectionHelper stuSecHelpr = new StudentSectionHelper();
        stuSecHelpr.enrollInBS(stuSecLst);
        Test.StopTest();
    }
}