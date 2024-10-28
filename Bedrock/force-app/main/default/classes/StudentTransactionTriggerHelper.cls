/*******************************************************************
Name  : StudentTransactionTriggerHelper
Author: Sarah (Laureate)
Date  : November 11, 2015
Description: Helper class for Student_Transaction__c

Revision History
Horacio Sanchez - 05/11/2021 - S-48505: L2: Automatically create new Transaction for Grant Special Credit
*************************************************************************/

public with sharing class StudentTransactionTriggerHelper {

    public void checkStudentSponsorshipRecordExists(list<Student_Transaction__c > newStudentTransaction){
        set<Id> stuSubscriptionSet = new set<Id>();
        set<Id> stuSponsorSet = new set<Id>();

        for(Student_Transaction__c tran:newStudentTransaction) {
            stuSubscriptionSet.add(tran.Student_Subscription__c);
        }

        for(Student_Transaction__c tran:newStudentTransaction) {
            stuSponsorSet.add(tran.Sponsor__c);
        }

        list<Student_Sponsorship__c> stuSponsorList = [ SELECT Account__c, Student_Subscription__c FROM Student_Sponsorship__c
        WHERE Student_Subscription__c IN :stuSubscriptionSet
        AND Account__c IN :stuSponsorSet ];


        System.debug('Student Sponsorship List :::: ' + stuSponsorList);

        //Map that contains the Student Sponsorships against a Student Subscription
        map<Id,Student_Sponsorship__c> mapStudentSubsciptionSponsor = new map<Id,Student_Sponsorship__c>();

        //Map that contains the Student Tranasctions against a Student Sponsorship record, used for creating the Student Transaction records
        map<Id, Student_Transaction__c> mapStudentSponsorshipsForStudentTransactions = new Map<Id, Student_Transaction__c>();

        for(Student_Transaction__c tran:newStudentTransaction) {
            if(stuSponsorList.isEmpty()) {
                tran.addError('Student Sponsorship record does not exist for this Sponsor.  Please create the Student Sponsorship record first before applying a Sponsor Payment');
            }
        }


        for(Student_Sponsorship__c ss : stuSponsorList) {
            if(!mapStudentSubsciptionSponsor.containsKey(ss.Student_Subscription__c)) {
                mapStudentSubsciptionSponsor.put(ss.Student_Subscription__c, ss);
            }
        }

        System.debug('Student Subscription -->> Student Sponsorship Map ::::: ' + mapStudentSubsciptionSponsor);

        for(Student_Transaction__c sub:newStudentTransaction) {
            if(mapStudentSubsciptionSponsor.containsKey(sub.Student_Subscription__c)) {
                Student_Sponsorship__c progSub = mapStudentSubsciptionSponsor.get(sub.Student_Subscription__c);
                if(progSub.Account__c != sub.Sponsor__c) {
                    sub.addError('Student Sponsorship record does not exist for this Sponsor.  Please create the Student Sponsorship record first before applying a Sponsor Payment');
                }
                else {
                    if(!mapStudentSponsorshipsForStudentTransactions.containsKey(progSub.Id)) {
                        mapStudentSponsorshipsForStudentTransactions.put(progSub.Id, sub);
                    }
                }
            }
        }

        //Insert the Student Sponsorship Transaction records if the map is populated
        if(mapStudentSponsorshipsForStudentTransactions.size()>0)
            createStudentSponsorshipTransactionRecords(mapStudentSponsorshipsForStudentTransactions);
    }

    public void createStudentSponsorshipTransactionRecords(map<Id,Student_Transaction__c>  mapStudentSponsorshipsForStudentTransactions) {
        list<Student_Sponsorship_Transaction__c> stuTrans = new list<Student_Sponsorship_Transaction__c>();

        for (Id studentSponsorshipId : mapStudentSponsorshipsForStudentTransactions.keySet()) {
            Student_Sponsorship_Transaction__c studentSponsorTransaction = new Student_Sponsorship_Transaction__c();
            Student_Transaction__c trans = mapStudentSponsorshipsForStudentTransactions.get(studentSponsorshipId);
            studentSponsorTransaction.Payment_Amount__c = trans.Payment_Amount__c;
            studentSponsorTransaction.Transaction_Date__c = trans.Transaction_Date__c;
            studentSponsorTransaction.Student_Sponsorship__c = studentSponsorshipId;
            studentSponsorTransaction.Student_Transaction__c = trans.Id;
            stuTrans.add(studentSponsorTransaction);
        }

        if(!stuTrans.isEmpty())
            insert stuTrans;
    }


    public void updateStudentSponsorshipTransactionRecords(list<Student_Transaction__c > newStudentTransaction){
        set<Id> setStudentTransactions = new set<Id>();

        for(Student_Transaction__c tran:newStudentTransaction) {
            setStudentTransactions.add(tran.Id);
        }

        //Get list of all the student sponsorship transactions against these student transactions
        list<Student_Sponsorship_Transaction__c> studentSponsorshipTransactions = [SELECT Id, Student_Transaction__c, Payment_Amount__c, Transaction_Date__c FROM Student_Sponsorship_Transaction__c WHERE Student_Transaction__c IN :setStudentTransactions];
        //list of Student Sponsorship Transactions to be updated
        list<Student_Sponsorship_Transaction__c> updatedStudentSponsorshipTransactions = new list<Student_Sponsorship_Transaction__c>();


        System.debug('List of all Student Sponsorships Transactions ::: ' + studentSponsorshipTransactions);

        if(studentSponsorshipTransactions.size()>0) {
            //Map that contains the Student Sponsorship Transactions against a Student Subscription
            map<Id,Student_Sponsorship_Transaction__c> mapStudentSubsciptionSponsorTransactions = new map<Id,Student_Sponsorship_Transaction__c>();
            for(Student_Sponsorship_Transaction__c sst : studentSponsorshipTransactions) {
                if(!mapStudentSubsciptionSponsorTransactions.containsKey(sst.Student_Transaction__c)) {
                    mapStudentSubsciptionSponsorTransactions.put(sst.Student_Transaction__c, sst);
                }
            }

            for(Student_Transaction__c sub:newStudentTransaction) {
                if(mapStudentSubsciptionSponsorTransactions.containsKey(sub.Id)) {
                    Student_Sponsorship_Transaction__c studentSponsorTransaction = mapStudentSubsciptionSponsorTransactions.get(sub.Id);

                    System.debug('Student Sponsorship Transaction to be Updated :::: ' + studentSponsorTransaction);
                    if(studentSponsorTransaction!=null) {
                        studentSponsorTransaction.Payment_Amount__c = sub.Payment_Amount__c;
                        studentSponsorTransaction.Transaction_Date__c = sub.Transaction_Date__c;
                        updatedStudentSponsorshipTransactions.add(studentSponsorTransaction);
                    }
                }
            }

            //If there are student sponsorship transactions to be updated then update them
            if(updatedStudentSponsorshipTransactions.size()>0) {
                update updatedStudentSponsorshipTransactions;
            }
        }
    }

    public void deleteStudentSponsorshipTransactionRecords(list<Student_Transaction__c > newStudentTransaction){

        set<Id> setStudentTransactions = new set<Id>();

        for(Student_Transaction__c tran:newStudentTransaction) {
            setStudentTransactions.add(tran.Id);
        }

        //Get list of all the student sponsorship transactions against these student transactions
        list<Student_Sponsorship_Transaction__c> studentSponsorshipTransactions = [SELECT Id, Student_Transaction__c, Payment_Amount__c, Transaction_Date__c FROM Student_Sponsorship_Transaction__c WHERE Student_Transaction__c IN :setStudentTransactions];


        if(studentSponsorshipTransactions.size()>0) {
            delete studentSponsorshipTransactions;
        }
    }
	
    /*********************************************************************************
     * Story 7100 Tempo : Roll-up field for SFP portal
     * Sprint 2020.1.4
     * 
     * onAfterInsert, onAfterUpdate, onBeforeDelete
     * 
     * created by: Horacio Sanchez
     * 
     * This method keeps the field Total_Payments_and_Charges__c, in Student Subscription, updated. 
     * It adds all existing transactions into this total payments and charges.
     * The second parameter is the list of transactions that were deleted, so those transactions are 
     * not added for the total
     * 
    **********************************************************************************/
    public void updateTotalChargesAndPaymentsInStudentSubscription(List<Student_Transaction__c> studentTransactionList, Set<Id> idsToBeRemovedSet) {
        Set<Id> studentSubscriptionIdSet = new Set<Id>();
        Map<Id, Student_Transaction__c> fullStudentTransactionMap = new Map<Id, Student_Transaction__c>();
        Map<Id, Decimal> studentSubscriptionAmountToUpdateMap = new Map<Id, Decimal>();
        Map<Id, Decimal> studentTotalChargeAmountToUpdateMap = new Map<Id, Decimal>();
        Map<Id, Decimal> studentTotalPaymentAmountToUpdateMap = new Map<Id, Decimal>();
        for (Student_Transaction__c st : studentTransactionList) {
            studentSubscriptionIdSet.add(st.student_subscription__c);            
        }

        List<Student_Transaction__c> studentTransactionWithSubscriptionList = [SELECT id, Is_Post_SFP_Release__c, Payment_Amount__c, Miscellaneous_Adjustment__c,
                Grant_Scholarship_Amount__c, Discount_Amount__c, Refund_Amount__c, Payment_or_Charge__c, Transaction_Type__c,
                student_subscription__r.id, student_subscription__r.Total_Payments_and_Charges__c
        FROM Student_Transaction__c
        WHERE student_subscription__r.id IN :studentSubscriptionIdSet];
        for (Student_Transaction__c st : studentTransactionWithSubscriptionList) {
            if (!fullStudentTransactionMap.containsKey(st.id)) {
                fullStudentTransactionMap.put(st.id, st);
            }
        }

        for (Student_Transaction__c st : studentTransactionWithSubscriptionList) {
            //S-48505: L2: Automatically create new Transaction for Grant Special Credit
            if (st.Transaction_Type__c == 'Grant Special Credit' || st.Transaction_Type__c == 'Grant Special Refund to Student') {
            	continue;
            }
            decimal totalCharge = 0;
            decimal totalPayments = 0;

            Decimal counterAggregate = 0.0;
            for (Id studentTransactionId : idsToBeRemovedSet) {
                if (studentTransactionId == st.id) {
                    if (st.Payment_Amount__c != null) {
                        if (st.Payment_or_Charge__c == 'P') {
                            counterAggregate += st.Payment_Amount__c;
                        } else {
                            counterAggregate -= st.Payment_Amount__c;
                        }
                    }
                    if (st.Miscellaneous_Adjustment__c != null) {
                        if (st.Payment_or_Charge__c == 'P') {
                            counterAggregate += st.Miscellaneous_Adjustment__c;
                        } else {
                            counterAggregate -= st.Miscellaneous_Adjustment__c;
                        }

                    }
                    if (st.Grant_Scholarship_Amount__c != null) {
                        if (st.Payment_or_Charge__c == 'P') {
                            counterAggregate += st.Grant_Scholarship_Amount__c;
                        } else {
                            counterAggregate -= st.Grant_Scholarship_Amount__c;
                        }
                    }
                    if (st.Discount_Amount__c != null) {
                        if (st.Payment_or_Charge__c == 'P') {
                            counterAggregate += st.Discount_Amount__c;
                        } else {
                            counterAggregate -= st.Discount_Amount__c;
                        }

                    }
                    if (st.Refund_Amount__c != null) {
                        if (st.Payment_or_Charge__c == 'P') {
                            counterAggregate += st.Refund_Amount__c;
                        } else {
                            counterAggregate -= st.Refund_Amount__c;
                        }
                    }
                }
            }
            for (Student_Transaction__c studentTransaction : studentTransactionList) {
                if (studentTransaction.id == st.id) {
                    st = fullStudentTransactionMap.get(st.id);
                    st.Is_Post_SFP_Release__c = studentTransaction.Is_Post_SFP_Release__c;
                    st.Payment_Amount__c = studentTransaction.Payment_Amount__c;
                    st.Miscellaneous_Adjustment__c = studentTransaction.Miscellaneous_Adjustment__c;
                    st.Grant_Scholarship_Amount__c = studentTransaction.Grant_Scholarship_Amount__c;
                    st.Discount_Amount__c = studentTransaction.Discount_Amount__c;
                    st.Refund_Amount__c = studentTransaction.Refund_Amount__c;
                }
            }
            //if (st.Is_Post_SFP_Release__c) {
            Decimal aggregateAmount = 0.0;
            if (st.Payment_Amount__c != null) {
                if (st.Payment_or_Charge__c == 'P') {
                    aggregateAmount += st.Payment_Amount__c;
                    totalPayments += st.Payment_Amount__c;
                } else {
                    aggregateAmount -= st.Payment_Amount__c;
                    totalCharge += st.Payment_Amount__c;
                }
            }
            if (st.Miscellaneous_Adjustment__c != null) {
                if (st.Payment_or_Charge__c == 'P') {
                    aggregateAmount += st.Miscellaneous_Adjustment__c;
                    totalPayments += st.Miscellaneous_Adjustment__c;
                } else {
                    aggregateAmount -= st.Miscellaneous_Adjustment__c;
                    totalCharge += st.Miscellaneous_Adjustment__c;
                }
            }
            if (st.Grant_Scholarship_Amount__c != null) {
                if (st.Payment_or_Charge__c == 'P') {
                    aggregateAmount += st.Grant_Scholarship_Amount__c;
                    totalPayments += st.Grant_Scholarship_Amount__c;
                } else {
                    aggregateAmount -= st.Grant_Scholarship_Amount__c;
                    totalCharge += st.Grant_Scholarship_Amount__c;
                }
            }
            if (st.Discount_Amount__c != null) {
                if (st.Payment_or_Charge__c == 'P') {
                    aggregateAmount += st.Discount_Amount__c;
                    totalPayments += st.Discount_Amount__c;
                } else {
                    aggregateAmount -= st.Discount_Amount__c;
                    totalCharge += st.Discount_Amount__c;
                }

            }
            if (st.Refund_Amount__c != null) {
                if (st.Payment_or_Charge__c == 'P') {
                    aggregateAmount += st.Refund_Amount__c;
                    totalPayments += st.Refund_Amount__c;
                } else {
                    aggregateAmount -= st.Refund_Amount__c;
                    totalCharge += st.Refund_Amount__c;
                }
            }

            Id studentSubscriptionId = fullStudentTransactionMap.get(st.id).student_subscription__r.id;
            if (!studentSubscriptionAmountToUpdateMap.containsKey(st.student_subscription__r.id)) {
                studentSubscriptionAmountToUpdateMap.put(st.student_subscription__r.id, aggregateAmount - counterAggregate);
                studentTotalChargeAmountToUpdateMap.put(st.student_subscription__r.id,totalCharge);
                studentTotalPaymentAmountToUpdateMap.put(st.student_subscription__r.id,totalPayments);
            } else {
                studentSubscriptionAmountToUpdateMap.put(st.student_subscription__r.id, studentSubscriptionAmountToUpdateMap.get(st.student_subscription__r.id) + aggregateAmount - counterAggregate);
                studentTotalChargeAmountToUpdateMap.put(st.student_subscription__r.id, studentSubscriptionAmountToUpdateMap.get(st.student_subscription__r.id) +totalCharge);
                studentTotalPaymentAmountToUpdateMap.put(st.student_subscription__r.id, studentSubscriptionAmountToUpdateMap.get(st.student_subscription__r.id) + totalPayments);
            }
            //}
        }




        List<Student_Subscription__c> studentSubscriptionList = new List<Student_Subscription__c>();
        for (Id key : studentSubscriptionAmountToUpdateMap.keySet()) {
            Student_Subscription__c ss = new Student_Subscription__c();
            ss.id = key;
            ss.Total_Payments_and_Charges__c = studentSubscriptionAmountToUpdateMap.get(key);
            ss.Total_Payments__c = studentTotalPaymentAmountToUpdateMap.get(key);
            ss.Total_Charges__c =studentTotalChargeAmountToUpdateMap.get(key);
            studentSubscriptionList.add(ss);
        }

        if (!studentSubscriptionList.isEmpty()) {
            update studentSubscriptionList;
        }
    }

    /*******************************************************************
    Method that assigns the new Student Transaction to its corresponding 1098t object, if alreadu exists; if 1098t
    object does not exists, then this is created and the Student Transaction is linked to it
    Related Story : S-57736
    Created By: Horacio Sanchez
    Event : After Insert 
    ********************************************************************/
    public void manage1098TRecords(List<Student_Transaction__c> studentTransactionList) {
        Set<Id> setStudentTransactions = new Set<Id>();
        Set<String> setYears = new Set<String>();
        Set<Id> setContacts = new Set<Id>();

        List<Student_Transaction__c> studentTransactionsToUpdate = new List<Student_Transaction__c>();
        List<Student_Transaction__c> pendingStudentTransactions = new List<Student_Transaction__c>();
        List<x1098t__c> x1098tToInsert = new List<x1098t__c>();
        List<X1098T__c> x1098tToUpdate = new List<x1098t__c>();
        Map<Id, List<x1098t__c>> contactId1098t = new Map<Id, List<x1098t__c>>();

        for (Student_Transaction__c studentTransaction : studentTransactionList) {
            setStudentTransactions.add(studentTransaction.Id);
            setYears.add(''+ studentTransaction.Transaction_Date__c.year());
        }

        List<Student_Transaction__c> groomedStudentTransactionList = getGroomedList(setStudentTransactions);

        for (Student_Transaction__c studentTransaction : groomedStudentTransactionList) {
            setContacts.add(studentTransaction.Student_Subscription__r.student_program__r.student__r.id);
        }

        List<x1098t__c> x1098tList = [SELECT id, year__c, student__c, Calculations_are_Up_to_Date__c FROM x1098t__c WHERE Student__c IN :setContacts AND year__c IN :setYears];

        Set<String> contactIdYearSet = new Set<String>();
        for (Student_Transaction__c studentTransaction : groomedStudentTransactionList) {
            Boolean x1098tFound = false;
            for (x1098t__c x1098t : x1098tList) {
                if (studentTransaction.Student_Subscription__r.student_program__r.student__r.id == x1098t.Student__c && (''+studentTransaction.Transaction_Date__c.year()) == x1098t.Year__c) {
                    x1098tFound = true;
                    studentTransaction.Year_1098T__c = x1098t.id;
                    x1098t.Calculations_are_Up_to_Date__c = false;
                    x1098tToUpdate.add(x1098t);
                    studentTransactionsToUpdate.add(studentTransaction);
                }
            }
            if (!x1098tFound) {
                pendingStudentTransactions.add(studentTransaction);
                if (!contactIdYearSet.contains('' + studentTransaction.Student_Subscription__r.student_program__r.student__r.id + studentTransaction.Transaction_Date__c.year())) {
                    contactIdYearSet.add('' + studentTransaction.Student_Subscription__r.student_program__r.student__r.id + studentTransaction.Transaction_Date__c.year());
                    x1098t__c new1098t = new x1098t__c();
                    new1098t.Student__c = studentTransaction.Student_Subscription__r.student_program__r.student__r.id;
                    new1098t.year__c = ''+studentTransaction.Transaction_Date__c.year();
                    new1098t.Calculations_are_Up_to_Date__c = false;
                    if (contactId1098t.get(studentTransaction.Student_Subscription__r.student_program__r.student__r.id) != null) {
                        contactId1098t.get(studentTransaction.Student_Subscription__r.student_program__r.student__r.id).add(new1098t);
                    } else {
                        contactId1098t.put(studentTransaction.Student_Subscription__r.student_program__r.student__r.id, new List<x1098t__c>{new1098t});
                    }
                }
            }
        }

        for (Id key : contactId1098t.keySet()) {
            x1098tToInsert.addAll(contactId1098t.get(key));
        }

        if (!x1098tToInsert.isEmpty()) {
            insert(x1098tToInsert);
        }

        x1098tList = [SELECT id, year__c, student__c, Calculations_are_Up_to_Date__c FROM x1098t__c WHERE Student__c IN :setContacts AND year__c IN :setYears];

        for (Student_Transaction__c studentTransaction : pendingStudentTransactions) {
            for (x1098t__c x1098t : x1098tList) {
                if (studentTransaction.Student_Subscription__r.student_program__r.student__r.id == x1098t.Student__c && (''+studentTransaction.Transaction_Date__c.year()) == x1098t.Year__c) {
                    studentTransaction.Year_1098T__c = x1098t.id;
                    studentTransactionsToUpdate.add(studentTransaction);
                    x1098t.Calculations_are_Up_to_Date__c = false;
                    x1098tToUpdate.add(x1098t);
                }
            }
        }
        try {
            if (studentTransactionsToUpdate != null && !studentTransactionsToUpdate.isEmpty()) {
                Set<Student_Transaction__c> studentTransactionSet = new Set<Student_Transaction__c>();
                List<Student_Transaction__c> studentTransactionListClean = new List<Student_Transaction__c>();
                studentTransactionSet.addAll(studentTransactionsToUpdate);
                studentTransactionListClean.addAll(studentTransactionSet);
                update studentTransactionListClean;
            }
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
        if (x1098tToUpdate != null && !x1098tToUpdate.isEmpty()) {
            Set<x1098t__c> x1098tSet = new Set<x1098t__c>();
            List<x1098t__c> x1098tListClean = new List<x1098t__c>();
            x1098tSet.addAll(x1098tToUpdate);
            x1098tListClean.addAll(x1098tSet);
            update x1098tListClean;
        }
    }

    /*******************************************************************
    Method that updates 1098t object to corresponding Student Transaction if the Transaction Date year is changed
    Related Story : S-57736
    Created By: Horacio Sanchez
    Event : Before Update
    ********************************************************************/
    public void manage1098tRecordsInUpdate(List<Student_Transaction__c> newStudentTransactionsList, map<Id, Student_Transaction__c> oldStudentTransanctionsMap) {
        Script_Settings__c scriptSettings = Script_Settings__c.getValues('Current Settings');
        Date cutOfDate = null;
        Integer cutOfDateYear = 0;
        if (scriptSettings != null ) {
            cutOfDate = scriptSettings.x1098T_cut_of_date__c;
            cutOfDateYear = cutOfDate.year();
        }

        boolean moveToSecondPart = false;

        List<Student_Transaction__c> studentTransactionsWithRemoved1098t = new List<Student_Transaction__c>();
        Map<Id, Student_Transaction__c> idStudentTransactionMap = new Map<Id, Student_transaction__c>();
        List<x1098t__c> x1098tToUpdate = new List<x1098t__c>();

        for (Student_Transaction__c studentTransaction : newStudentTransactionsList) {
            // Verifying if there is a difference in transaction date
            if (studentTransaction.Transaction_Date__c.year() != oldStudentTransanctionsMap.get(studentTransaction.Id).transaction_date__c.year()) {
                // studentTransaction.LastModifiedDate is DateTime, we only need Date
                Date formattedLastModifiedDate = Date.newInstance(studentTransaction.LastModifiedDate.year(), studentTransaction.LastModifiedDate.month(), studentTransaction.LastModifiedDate.day());

                if (studentTransaction.Transaction_Date__c.year() > oldStudentTransanctionsMap.get(studentTransaction.Id).transaction_date__c.year()) {
                    // new Transaction Date is higher (e.i. 2020 > 2019)
                    Date actualCutOfDate = Date.newInstance(studentTransaction.transaction_date__c.year(), cutOfDate.month(), cutOfDate.day()); // Jan 6, 2020

                    // Verify if lastModifiedDate is after or before the cut of date
                    if (formattedLastModifiedDate <= actualCutOfDate) {
                        // remove from 2020 and change it to 2019
                        x1098t__c current1098t = new x1098t__c();
                        current1098t.id = studentTransaction.Year_1098T__c;
                        current1098t.Calculations_are_Up_to_Date__c = false;
                        x1098tToUpdate.add(current1098t);

                        studentTransaction.Year_1098T__c = null;
                        studentTransactionsWithRemoved1098t.add(studentTransaction);
                        idStudentTransactionMap.put(oldStudentTransanctionsMap.get(studentTransaction.Id).id, studentTransaction);
                        moveToSecondPart = true;
                    }
                } else {
                    // new Transaction Date is lower (sooner e.i.2019 > 2020) 
                    // In this case, we get the cut of date and apply this old transaction year
                    Date actualCutOfDate = Date.newInstance(oldStudentTransanctionsMap.get(studentTransaction.Id).transaction_date__c.year(), cutOfDate.month(), cutOfDate.day()); // Jan 6, 2020

                    // Verify if lastModifiedDate is after or before the cut of date
                    if (formattedLastModifiedDate <= actualCutOfDate) {
                        // remove from 2020 and change it to 2019
                        x1098t__c current1098t = new x1098t__c();
                        current1098t.id = studentTransaction.Year_1098T__c;
                        current1098t.Calculations_are_Up_to_Date__c = false;
                        x1098tToUpdate.add(current1098t);

                        studentTransaction.Year_1098T__c = null;
                        studentTransactionsWithRemoved1098t.add(studentTransaction);
                        idStudentTransactionMap.put(oldStudentTransanctionsMap.get(studentTransaction.Id).id, studentTransaction);
                        moveToSecondPart = true;
                    }
                }
            }
        }

        if (!x1098tToUpdate.isEmpty()) {
            for (x1098t__c x : x1098tToUpdate) {
                System.debug('**** ' + x.id + ', ' + x.year__c);
            }
            update x1098tToUpdate;
        }

        if (moveToSecondPart) {
            Set<Id> setStudentTransactions = new Set<Id>();
            Set<String> setYears = new Set<String>();
            Set<Id> setContacts = new Set<Id>();

            List<Student_Transaction__c> studentTransactionsToUpdate = new List<Student_Transaction__c>();
            List<Student_Transaction__c> pendingStudentTransactions = new List<Student_Transaction__c>();
            List<x1098t__c> x1098tToInsert = new List<x1098t__c>();
            Map<Id, List<x1098t__c>> contactId1098t = new Map<Id, List<x1098t__c>>();

            for (Student_Transaction__c studentTransaction : studentTransactionsWithRemoved1098t) {
                setStudentTransactions.add(studentTransaction.Id);
                setYears.add(''+ studentTransaction.Transaction_Date__c.year());
            }

            List<Student_Transaction__c> groomedStudentTransactionList = getGroomedList(setStudentTransactions);

            Map<Id, Student_Transaction__c> groomedMap = new Map<Id, Student_Transaction__c>();
            for (Student_Transaction__c studentTransaction : groomedStudentTransactionList) {
                setContacts.add(studentTransaction.Student_Subscription__r.student_program__r.student__r.id);
                groomedMap.put(studentTransaction.id, studentTransaction);
            }

            List<x1098t__c> x1098tList = [SELECT id, year__c, student__c FROM x1098t__c WHERE Student__c IN :setContacts AND year__c IN :setYears];
            x1098tToUpdate = new List<x1098t__c>();

            Set<String> contactIdYearSet = new Set<String>();
            for (Student_Transaction__c studentTransaction : newStudentTransactionsList) {
                Boolean x1098tFound = false;
                for (x1098t__c x1098t : x1098tList) {
                    if (groomedMap.get(studentTransaction.id).Student_Subscription__r.student_program__r.student__r.id == x1098t.Student__c && (''+studentTransaction.Transaction_Date__c.year()) == x1098t.Year__c) {
                        x1098tFound = true;
                        x1098t.Calculations_are_Up_to_Date__c = false;
                        x1098tToUpdate.add(x1098t);
                        idStudentTransactionMap.get(studentTransaction.Id).year_1098t__c = x1098t.id;
                    }
                }
                if (!x1098tFound) {
                    pendingStudentTransactions.add(studentTransaction);
                    if (!contactIdYearSet.contains('' + groomedMap.get(studentTransaction.id).Student_Subscription__r.student_program__r.student__r.id + studentTransaction.Transaction_Date__c.year())) {
                        contactIdYearSet.contains('' + groomedMap.get(studentTransaction.id).Student_Subscription__r.student_program__r.student__r.id + studentTransaction.Transaction_Date__c.year());
                        x1098t__c new1098t = new x1098t__c();
                        new1098t.Student__c = groomedMap.get(studentTransaction.id).Student_Subscription__r.student_program__r.student__r.id;
                        new1098t.year__c = ''+studentTransaction.Transaction_Date__c.year();
                        new1098t.Calculations_are_Up_to_Date__c = false;
                        if (contactId1098t.get(groomedMap.get(studentTransaction.id).Student_Subscription__r.student_program__r.student__r.id) != null) {
                            contactId1098t.get(groomedMap.get(studentTransaction.id).Student_Subscription__r.student_program__r.student__r.id).add(new1098t);
                        } else {
                            contactId1098t.put(groomedMap.get(studentTransaction.id).Student_Subscription__r.student_program__r.student__r.id, new List<x1098t__c>{new1098t});
                        }
                    }
                }
            }

            for (Id key : contactId1098t.keySet()) {
                x1098tToInsert.addAll(contactId1098t.get(key));
            }

            if (!x1098tToInsert.isEmpty()) {
                insert(x1098tToInsert);
            }

            x1098tList = [SELECT id, year__c, student__c, Calculations_are_Up_to_Date__c FROM x1098t__c WHERE Student__c IN :setContacts AND year__c IN :setYears];

            for (Student_Transaction__c studentTransaction : pendingStudentTransactions) {
                for (x1098t__c x1098t : x1098tList) {
                    if (groomedMap.get(studentTransaction.id).Student_Subscription__r.student_program__r.student__r.id == x1098t.Student__c && (''+studentTransaction.Transaction_Date__c.year()) == x1098t.Year__c) {
                        idStudentTransactionMap.get(studentTransaction.Id).year_1098t__c = x1098t.id;
                        x1098t.Calculations_are_Up_to_Date__c = false;
                        x1098tToUpdate.add(x1098t);
                    }
                }
            }

            if (!x1098tToUpdate.isEmpty()) {
                Set<x1098t__c> x1098tSet = new Set<x1098t__c>();
                List<x1098t__c> x1098tListClean = new List<x1098t__c>();
                x1098tSet.addAll(x1098tToUpdate);
                x1098tListClean.addAll(x1098tSet);
                update x1098tListClean;
            }
        }
    }

    /*
     *  *************** Private methods **********************
     */

    /*******************************************************************
    Returns a List of Student Transactions with its associated Contact information.    
    ********************************************************************/
    private List<Student_Transaction__c> getGroomedList(Set<Id> setStudentTransactions) {
        return [SELECT id, Transaction_Date__c, student_subscription__r.student_program__r.student__r.id, student_subscription__r.student_program__r.student__r.firstName,
                student_subscription__r.student_program__r.student__r.lastName, student_subscription__r.student_program__r.student__r.mailingStreet,
                student_subscription__r.student_program__r.student__r.mailingCity, student_subscription__r.student_program__r.student__r.mailingState,
                student_subscription__r.student_program__r.student__r.mailingCountry, student_subscription__r.student_program__r.student__r.mailingPostalCode
        FROM Student_Transaction__c
        WHERE id IN :setStudentTransactions];
    }

}