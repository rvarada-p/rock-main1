/*******************************************************************
Name  : ProgramStartDateHelper
Author: Vinod Kumar (Appirio)
Date  : November 7, 20
Description: Helper class for the object Program_Start_Date__c
*************************************************************************/
public with sharing class ProgramStartDateHelper {
    /*******************************************************************
    Method to calculate the name field value using the start date
    So example if Start_Date__c = '2014-12-31", then Program_Start_Date__r.Name would equal "Dec31,2014"
    Related task: T-331867
    Modified Task: T-337055
    Modified Reason: Now name should be "February 2nd, 2015" instead of the current "Feb2,2015"
    ********************************************************************/
    public void calculateName(list<Program_Start_Date__c> newList){
        for(Program_Start_Date__c spDate: newList){
            DateTime dtStartDate = DateTime.newInstance(spDate.Start_Date__c,DateTime.now().time());
            integer day = dtStartDate.day();
            string strDay = '';
            if(day == 1 || day== 21 || day== 31){
                strDay = string.valueOf(day)+'st';
            }else if(day == 2 || day== 22){
                strDay = string.valueOf(day)+'nd';
            }else if(day == 3 || day== 23){
                strDay = string.valueOf(day)+'rd';
            }else{
                strDay = string.valueOf(day)+'th';
            }
            string strMonth = dtStartDate.format('MMMMM'); 
            string strName = strMonth + ' '+ strDay + ', '+string.valueOf(dtStartDate.year());
            spDate.Name = strName;
        }
    }
}