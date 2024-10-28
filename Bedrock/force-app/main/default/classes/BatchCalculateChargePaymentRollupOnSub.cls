/************************************************************************
Name  : BatchCalculateChargePaymentRollupOnSub
Author: Ravitej Varada, Laureate
Date  : July 24, 2020
Description: Batch class to handle Total charge and Payment  Rollup on Sub
             (One Time Run)
*************************************************************************/

global class BatchCalculateChargePaymentRollupOnSub implements Database.Batchable<sObject> {
    global String soql;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        soql = 'Select id,(SELECT id,Is_Post_SFP_Release__c,Payment_Amount__c,Miscellaneous_Adjustment__c,Grant_Scholarship_Amount__c,Discount_Amount__c,Refund_Amount__c,Student_Subscription__c From Student_Payments__r LIMIT 1) FROM Student_Subscription__c';
        return Database.getQueryLocator(soql);
    }


    global void execute(Database.BatchableContext BC, list<Student_Subscription__c> scope) {
        List<Student_Transaction__c> studentTransList = new List<Student_Transaction__c>();
        for (Student_Subscription__c sub : scope) {

            if (sub.Student_Payments__r.size() > 0) {
                for (Student_Transaction__c tran : sub.Student_Payments__r) {
                    studentTransList.add(tran);
                }
            }
        }
        StudentTransactionTriggerHelper obj = new StudentTransactionTriggerHelper();
        obj.updateTotalChargesAndPaymentsInStudentSubscription(studentTransList, new Set<Id>());
    }

    global void finish(Database.BatchableContext BC) {

    }

}