/*******************************************************************
Name  : StudentTransactionTriggerHandler
Author: Sarah (Laureate)
Date  : November 11, 2015
Description: Handler class for the Trigger StudentTransactionTrigger

Revision History 
Horacio Sanchez - 03/19/2021 - S-38952: Tempo: Fix Loan Disbursement Apex CPU time Exceed Error
Horacio Sanchez - 05/11/2021 - S-48505: L2: Automatically create new Transaction for Grant Special Credit
*************************************************************************/

public with sharing class StudentTransactionTriggerHandler {
   
    public void onAfterInsert( list<Student_Transaction__c > newStudentTransactions ) {
        System.debug('In after Insert for Student_Transaction__c');
        List<Student_Transaction__c> updatedStudentTransactions = new List<Student_Transaction__c>();
        List<Student_Transaction__c> grantSpecialCreditTransactionList = new List<Student_Transaction__c>();
        
        for (Student_Transaction__c s : newStudentTransactions) {
            //Make sure only Sponsor Payment type Student Transactions are processed by trigger logic
            if (s.Transaction_Type__c == 'Sponsor Payment') {
                updatedStudentTransactions.add(s);
            }
            
            //S-48505: L2: Automatically create new Transaction for Grant Special Credit
            if (!(s.Transaction_Type__c == 'Grant Special Credit' || s.Transaction_Type__c == 'Grant Special Refund to Student')) {
                grantSpecialCreditTransactionList.add(s);
            }
        }
        StudentTransactionTriggerHelper stuTransHelper = new StudentTransactionTriggerHelper();
        stuTransHelper.checkStudentSponsorshipRecordExists(updatedStudentTransactions);
        stuTransHelper.manage1098TRecords(newStudentTransactions);
        
        //S-48505: L2: Automatically create new Transaction for Grant Special Credit
        if (!grantSpecialCreditTransactionList.isEmpty()) {
         	stuTransHelper.updateTotalChargesAndPaymentsInStudentSubscription(grantSpecialCreditTransactionList, new Set<Id>());   
        }        
    }

    
   	public void onBeforeUpdate( list<Student_Transaction__c > newStudentTransactions, map<ID,Student_Transaction__c> oldMap) {
   		list<Student_Transaction__c> updatedStudentTransactions = new list<Student_Transaction__c>();
        List<Student_Transaction__c> updateTotalChargesAndPaymentsSTList = new List<Student_Transaction__c>();
   		for(Student_Transaction__c s : newStudentTransactions) {
   			//Make sure only Sponsor Payment type Student Transactions are processed by trigger logic, if the payment amount has changed or transaction date has changed sync the related student sponsorship transaction record
   			if(s.Transaction_Type__c == 'Sponsor Payment' && (s.Payment_Amount__c != oldMap.get(s.ID).Payment_Amount__c) ||  (s.Transaction_Date__c != oldMap.get(s.ID).Transaction_Date__c)){
   				updatedStudentTransactions.add(s);
   			}
   		}
   		StudentTransactionTriggerHelper stuTransHelper = new StudentTransactionTriggerHelper();
   		stuTransHelper.updateStudentSponsorshipTransactionRecords(updatedStudentTransactions);
        stuTransHelper.manage1098tRecordsInUpdate(newStudentTransactions, oldMap);
        
        // Check if any of the payment/charge field is different between new and old one
        for (Student_Transaction__c st : newStudentTransactions) {
            if (st.Payment_Amount__c != oldMap.get(st.Id).Payment_Amount__c || 
                st.Miscellaneous_Adjustment__c != oldMap.get(st.Id).Miscellaneous_Adjustment__c || 
                st.Grant_Scholarship_Amount__c != oldMap.get(st.Id).Grant_Scholarship_Amount__c ||
                st.Discount_Amount__c != oldMap.get(st.Id).Discount_Amount__c ||
                st.Refund_Amount__c != oldMap.get(st.Id).Refund_Amount__c ||
                st.Payment_or_Charge__c != oldMap.get(st.Id).Payment_or_Charge__c
               ) {
                   updateTotalChargesAndPaymentsSTList.add(st);
               }
        }
        if (!updateTotalChargesAndPaymentsSTList.isEmpty()) {
         	stuTransHelper.updateTotalChargesAndPaymentsInStudentSubscription(newStudentTransactions, new Set<Id>());
        }       	
    }
    
    public void onAfterUpdate(List<Student_Transaction__c> newStudentTransactions, map<Id, Student_Transaction__c> oldMap) {
        StudentTransactionTriggerHelper stuTransHelper = new StudentTransactionTriggerHelper();
        //stuTransHelper.manage1098tRecordsInUpdate(newStudentTransactions, oldMap);
    }
 
    public void onBeforeDelete( list<Student_Transaction__c > newStudentTransactions) {
  		System.debug('In before Delete for Student_Transaction__c');
  		list<Student_Transaction__c> updatedStudentTransactions = new list<Student_Transaction__c>();
  		for(Student_Transaction__c s : newStudentTransactions) {
  			//Make sure only Sponsor Payment type Student Transactions are processed by trigger logic
  			if(s.Transaction_Type__c == 'Sponsor Payment') {
  				updatedStudentTransactions.add(s);
  			} 	
  		}
  		StudentTransactionTriggerHelper stuTransHelper = new StudentTransactionTriggerHelper();
  		stuTransHelper.deleteStudentSponsorshipTransactionRecords(updatedStudentTransactions);
        
        Set<Id> idsToBeRemovedSet = new Set<Id>();
        for (Student_Transaction__c st : newStudentTransactions) {
            idsToBeRemovedSet.add(st.id);
        }
        stuTransHelper.updateTotalChargesAndPaymentsInStudentSubscription(newStudentTransactions, idsToBeRemovedSet);
    }
   
}