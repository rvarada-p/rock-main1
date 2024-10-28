/************************************************************************
Name  : BatchManageLoanDisbursementFile
Author: Horacio Sanchez
Date  : March 19, 2021
Description: batch class that hepls in the File Import process of Student Loan Disbursement entries.
*************************************************************************/
public class BatchManageLoanDisbursementFile implements Database.Batchable<sObject>, Database.Stateful {
    
    public List<Student_Loan_Disbursement__c> studentLoansDisbursementToParseSet = new List<Student_Loan_Disbursement__c>();
    public List<String> successfullyInsertedList = new List<String>();
    public List<String> failedInsertedList = new List<String>();
    
    public BatchManageLoanDisbursementFile(List<Student_Loan_Disbursement__c> studentLoansDisbursementToParseGet) {
        successfullyInsertedList = new List<String>();
    	failedInsertedList = new List<String>();
        studentLoansDisbursementToParseSet = studentLoansDisbursementToParseGet;
    }
    
    public List<Student_Loan_Disbursement__c> start(Database.BatchableContext BC) {
        return studentLoansDisbursementToParseSet;
    }
    
    public void execute(Database.BatchableContext BC, List<Student_Loan_Disbursement__c> scope) {
        // DML statement
        Database.SaveResult[] srList = Database.insert(scope, false);
         
        // Iterate through each returned result
        for (Integer i = 0; i < srList.size(); i++) {
            if (srList.get(i).isSuccess()) {
                successfullyInsertedList.add('Student Loan Disbursement inserted: ' + srList.get(i).Id + ', for ' + scope[i].CBL_Student_ID__c);
            } else {
                Database.Error errors =  srList.get(i).getErrors().get(0);
                System.debug('Error processing record with CBL ID: ' + scope[i].CBL_Student_ID__c + '. Error: ' + errors.getMessage());
                System.debug('scope: ' + scope[i].CBL_Student_ID__c);
                failedInsertedList.add('Failed to insert record for ' + scope[i].CBL_Student_ID__c + ': ' + errors.getMessage());
            }
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CompletedDate FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        System.debug('**Batch finished**');
        System.debug('Total job items: ' + a.TotalJobItems);
        System.debug('Jobs processed: ' + a.JobItemsProcessed);
        System.debug('Failures: ' + a.NumberOfErrors);
        System.debug('Successfully Inserted: ');
        
        String successSummaryString = '';
        for (String success : successfullyInsertedList) {
            System.debug(success);
            successSummaryString += (success + '\n');
        }
        
        System.debug('Failed: ');
        String failedSummaryString = '';
        for (String failure : failedInsertedList) {
            System.debug(failure);
            failedSummaryString += (failure + '\n');
        }
        
        String batchSummaryString = '**Batch process finished**';
        batchSummaryString += ('\nTotal job items: ' + a.TotalJobItems);
        batchSummaryString += ('\nJobs processed: ' + a.JobItemsProcessed);
        batchSummaryString += ('\nCompleted Date: ' + a.CompletedDate);
        batchSummaryString += ('\n\nRecords inserted (' + successfullyInsertedList.size() + ')\n');
        batchSummaryString += successSummaryString;
        batchSummaryString += ('\n\nRecords that failed to insert (' + failedInsertedList.size() + ')\n');
        batchSummaryString += failedSummaryString;        
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] emailDirections = Label.StudentLoanDisbursementBatchSummaryEmails.split(';');
        if (emailDirections != null && emailDirections.size() > 0) {
            mail.setBccAddresses(emailDirections);
        } else {
            List<String> sendTo = new List<String>();
            sendTo.add('TheIterators@laureate.net');
            mail.setToAddresses(sendTo);
        }
        
        mail.setSenderDisplayName('Batch Processing');
        if (failedInsertedList.size() == 0) {
            mail.setSubject('New Loan disbursement file Imported Successfully');
        } else {
            mail.setSubject('New Loan Disbursement file Imported with Errors. Contact your Salesforce Admin.');
        }
        
        mail.setPlainTextBody(batchSummaryString);
         
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}