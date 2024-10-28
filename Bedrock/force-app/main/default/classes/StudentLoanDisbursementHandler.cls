/*
 * Revision History
 * Horacio Sanchez  -  Feb 08, 2022 	-	User Story 78307: L2: Loan Disbursement Reversal logic update
 * Horacio Sanchez  -  Mar 04, 2022     -   Prod Defect 83051: Modify logic for reversals in tempo
 */
public with sharing class StudentLoanDisbursementHandler {

    public static boolean calledOnce = false;
    private Schema.DescribeSObjectResult describe;

    public StudentLoanDisbursementHandler() {
        if (calledOnce == false)
            calledOnce = true;
        describe = Student_Loan_Disbursement__c.SObjectType.getDescribe();
    }


    // Map imported Disbursement records to respective Student Programs, throw error if no match
    public void onBeforeInsert (List<Student_Loan_Disbursement__c> listSLD) {
        List<String> listStuIds = new List<String>();
        for (Student_Loan_Disbursement__c mySLD: listSLD) {
            listStuIds.add(mySLD.CBL_Student_ID__c);
        }

        // TBD: must query 'active' SP only - is this enough?
        // TBD: question for FinAid - we assume only disburse to active students
        // 11/23/2015 (Sarah) - We will allow negative amounts/reversals to inactive students as well
        Map<String,List<String>> mapStuID_SPId = new Map<String,List<String>>();
        
        // S-78307 Changed the Map's value to be a List of Ids instead of just a single ID
        for(Student_Program__c myStuPro : [SELECT Id, Student__r.CBL_Student_ID__c FROM Student_Program__c WHERE Student__r.CBL_Student_ID__c in :listStuIds]) {
                                            //where IsStudentProgramActive__c = true
                                            //AND Student__r.CBL_Student_ID__c in :listStuIds])
            if (mapStuID_SPId.containsKey(myStuPro.Student__r.CBL_Student_ID__c)) {
                mapStuID_SPId.get(myStuPro.Student__r.CBL_Student_ID__c).add(myStuPro.Id);
            } else {
                mapStuID_SPId.put(myStuPro.Student__r.CBL_Student_ID__c, new List<Id>{myStuPro.Id} );
            }            
            system.debug('>>> Mapping: SP ID:'+myStuPro.Id+'  CBL Student ID:'+myStuPro.Student__r.CBL_Student_ID__c);
        }
        
        // Check all CBL IDs that have more than one SP and get the SP Ids
        Set<String> spIdSet = new Set<String>();
        for (String cblId : mapStuID_SPId.keySet()) {
            if (mapStuID_SPId.get(cblId).size() > 1) {
                for (String spId : mapStuID_SPId.get(cblId)) {
                    spIdSet.add(spId);
                }
            }
        }
        
        // Get the Student Loan Disbursement records for the SPs that correspond to same CBL. This will help us know under which SP to insert reversal amount
        // if there exists multiple SPs for one CBL
        Map<String, List<Student_Loan_Disbursement__c>> spIdLoanDisbursementListMap = new Map<String, List<Student_Loan_Disbursement__c>>();
        for (Student_Loan_Disbursement__c loanDisbursement : [SELECT Id, Student_Program__c, Loan_ID__c, Disbursement_Number__c, Sequence_Number__c, Disbursement_Amount__c 
                                                              FROM Student_Loan_Disbursement__c
                                                              WHERE Student_Program__c IN :spIdSet]) {
            if (spIdLoanDisbursementListMap.containsKey(loanDisbursement.Student_Program__c)) {
                spIdLoanDisbursementListMap.get(loanDisbursement.Student_Program__c).add(loanDisbursement);
            } else {
                spIdLoanDisbursementListMap.put(loanDisbursement.Student_Program__c, new List<Student_Loan_Disbursement__c>{loanDisbursement});
            }
        }

        // thrown error message embedded in APEX error text, very hard to read, how to present clean error message?
        for (Student_Loan_Disbursement__c mySLD: listSLD) {
            if (mapStuID_SPId.containsKey(mySLD.CBL_Student_ID__c)) {
                if (mapStuID_SPId.get(mySLD.CBL_Student_ID__c).size() > 1) {
                    if (mySLD.Disbursement_Amount__c < 0) {
                        Boolean reversalFound = false;
                        for (String spId : mapStuID_SPId.get(mySLD.CBL_Student_ID__c)) {
                            if (spIdLoanDisbursementListMap.get(spId) != null) {
                                for (Student_Loan_Disbursement__c loan : spIdLoanDisbursementListMap.get(spId)) {
                                    if (loan.Student_Program__c == spId) {
                                        if (loan.Loan_ID__c == mySLD.Loan_ID__c && loan.Disbursement_Number__c == mySLD.Disbursement_Number__c) {
                                            mySLD.Student_Program__c = spId;
                                            reversalFound = true;
                                            break;
                                        }
                                    }
                                }
                            }                            
                        }
                        if (!reversalFound) {
                            mySLD.Student_Program__c = mapStuID_SPId.get(mySLD.CBL_Student_ID__c)[mapStuID_SPId.get(mySLD.CBL_Student_ID__c).size() - 1];
                        }
                    } else {
                        mySLD.Student_Program__c = mapStuID_SPId.get(mySLD.CBL_Student_ID__c)[mapStuID_SPId.get(mySLD.CBL_Student_ID__c).size() - 1];
                    }                    
                } else if (mapStuID_SPId.get(mySLD.CBL_Student_ID__c).size() == 1) {
                    mySLD.Student_Program__c = mapStuID_SPId.get(mySLD.CBL_Student_ID__c)[0];
                }                
            } else {
                //throw new MyException('Import Error. No active Student Program found for Student ID:'+mySLD.CBL_Student_ID__c);
                mySLD.addError('Import Error. No active Student Program found for Student ID: '+ mySLD.CBL_Student_ID__c);
            }
        }        
        populateRecordType(listSLD);
    }
    
    // Create Student Transactions to pay off past / current debt, tie to SLD record    
    public void onAfterInsert (List<Student_Loan_Disbursement__c> listSLD) {

        List<Id> listStuDisIds = new List<Id>();
        for (Student_Loan_Disbursement__c mySLD: listSLD) {
            listStuDisIds.add(mySLD.Student_Program__c);
        }

        Map<Id,list<Student_Subscription__c>> mapSPId_listStuSub = new map<Id,list<Student_Subscription__c>>();

        for (Student_Subscription__c myStuSub1 : [SELECT Id, Name, Student_Program__c, Student_Program__r.Student__c, Student_Program__r.IsStudentProgramActive__c, 
                                            	 Current_Subscription_Balance__c, Start_Date__c, End_Date__c, CreatedDate 
                                            	 FROM Student_Subscription__c
                                            	 WHERE Student_Program__c in :listStuDisIds
                                                 ORDER BY Start_Date__c]) {        
            System.debug('>>> Student Subscription: ID:'+myStuSub1.Id+
                '  Student_Program__r:'+myStuSub1.Student_Program__r+
                '  Student_Program__r.Student__c:'+myStuSub1.Student_Program__r.Student__c+
                '  Current_Subscription_Balance__c:'+myStuSub1.Current_Subscription_Balance__c+
                '  Start_Date__c:'+myStuSub1.Start_Date__c +
                '  IsStudentProgramActive ' + myStuSub1.Student_Program__r.IsStudentProgramActive__c);

            myStuSub1.Temp_Balance__c = myStuSub1.Current_Subscription_Balance__c;

            if (mapSPId_listStuSub.containsKey(myStuSub1.Student_Program__c)) {
                mapSPId_listStuSub.get(myStuSub1.Student_Program__c).add(myStuSub1);
                //system.debug('** Adding sub:'+myStuSub1.Id+'  to SP:'+myStuSub1.Student_Program__c);
            } else {
                mapSPId_listStuSub.put(myStuSub1.Student_Program__c, new List<Student_Subscription__c>());
                mapSPId_listStuSub.get(myStuSub1.Student_Program__c).add(myStuSub1);
                //system.debug('** Adding sub:'+myStuSub1.Id+'  to new SP in map:'+myStuSub1.Student_Program__c);
            }
        }

        // TBD: inner class
        //      > subID
        //      > balance        
        List<Student_Transaction__c> listNewStuTrans = new List<Student_Transaction__c>();
        List<Student_Loan_Disbursement__c> listnewSLD = new List<Student_Loan_Disbursement__c>();

        for (Student_Loan_Disbursement__c mySLD: listSLD) {
            Decimal remainingLoanAmt = mySLD.Disbursement_Amount__c;

            // negative disbursement = a reverse charge.  Apply to latest subscription first
            if (remainingLoanAmt < 0) {
                List<Student_Subscription__c> studentSubscriptionList = new List<Student_Subscription__c>();
                if (mapSPId_listStuSub.get(mySLD.Student_Program__c) != null) {
                    studentSubscriptionList = mapSPId_listStuSub.get(mySLD.Student_Program__c);
                }
                
                processReversal(remainingLoanAmt, mySLD, studentSubscriptionList, listNewStuTrans);
                
                continue;
            }

            // Get all subsritpions for that SP. Using Temp_Balance__c field to track new subscription balance
            for (Student_Subscription__c myStuSub: mapSPId_listStuSub.get(mySLD.Student_Program__c)) {
                Decimal transactionAmt;

                // IF subscription balance > 0, remaining loan amount > 0
                //   AND
                //   (loan start date AND loan end date intersect with a subscription start / end ) OR sub balance < $200                
                if (myStuSub.Temp_Balance__c > 0.0 && remainingLoanAmt > 0.0 && ((mySLD.Loan_Start_Date__c <= myStuSub.End_Date__c && mySLD.Loan_End_Date__c >= myStuSub.Start_Date__c) || myStuSub.Temp_Balance__c < 200)) {                    
                    System.debug('** FinAid Transaction BEFORE. mySLD:'+mySLD.name+
                        '  myStuSub:'+myStuSub.name+
                        '  remainingLoanAmt:'+remainingLoanAmt+
                        '  Current_Subscription_Balance__c:'+myStuSub.Current_Subscription_Balance__c+
                        '  myStuSub.Temp_Balance__c:'+myStuSub.Temp_Balance__c
                        );

                    if (remainingLoanAmt >= myStuSub.Temp_Balance__c) {
                        // remaining loan amount is sufficient - pay off full balance of this subscription
                        transactionAmt = myStuSub.Temp_Balance__c;
                        remainingLoanAmt -= myStuSub.Temp_Balance__c;
                        myStuSub.Temp_Balance__c = 0.0;
                    } else {
                        // remaining loan amount not sufficient - only pay off part of the balance
                        transactionAmt = remainingLoanAmt;
                        remainingLoanAmt = 0.0;             
                        myStuSub.Temp_Balance__c -= transactionAmt;
                    }

                    system.debug('    >> FinAid Transaction AFTER. transactionAmt:'+transactionAmt+
                        '  remainingLoanAmt:'+remainingLoanAmt+
                        '  myStuSub.Temp_Balance__c:'+myStuSub.Temp_Balance__c
                        );

                    Student_Transaction__c newTrans = new Student_Transaction__c();
                    newTrans.Student_Subscription__c = myStuSub.Id;
                    newTrans.Payment_Amount__c = transactionAmt;
                    newTrans.Transaction_Type__c = 'FinAid Payment';
                    newTrans.Transaction_Date__c = system.today();
                    newTrans.Transaction_Note__c = mySLD.Fund_Name_Long__c;
                    // link Transaction to the SLD
                    newTrans.Student_Loan_Disbursement__c = mySLD.Id;
                    listNewStuTrans.add(newTrans);
                }
            }

            // Add two final transactions into the most recent student subscription
            if (remainingLoanAmt >= 0) {

                list<Student_Subscription__c> ListSS = new list<Student_Subscription__c>();
                ListSS = mapSPId_listStuSub.get(mySLD.Student_Program__c);
                Id MostRecentSSID = ListSS[ListSS.size()-1].Id;

                Student_Transaction__c newTrans = new Student_Transaction__c();
                newTrans.Student_Subscription__c = MostRecentSSID; 
                newTrans.Payment_Amount__c = remainingLoanAmt;
                newTrans.Transaction_Type__c = 'FinAid Student Credit';
                newTrans.Transaction_Date__c = system.today();
                newTrans.Transaction_Note__c = mySLD.Fund_Name_Long__c;
                // link Transaction to the SLD
                newTrans.Student_Loan_Disbursement__c = mySLD.Id;
                listNewStuTrans.add(newTrans);

                Student_Transaction__c newTrans2 = new Student_Transaction__c();
                newTrans2.Student_Subscription__c = MostRecentSSID; 
                //Record FinAid refunds as positive refund amounts. Refund = a check paid out to a student, NOT a negative adjustment to the student balance.
                newTrans2.Refund_Amount__c = remainingLoanAmt;
                newTrans2.Transaction_Type__c = 'FinAid Refund to Student';
                newTrans2.Transaction_Date__c = system.today();
                newTrans2.Transaction_Note__c = mySLD.Fund_Name_Long__c;
                // link Transaction to the SLD
                newTrans2.Student_Loan_Disbursement__c = mySLD.Id;
                listNewStuTrans.add(newTrans2);
            }


            // update Student_Loan_Disbursement__c to show 'remaining balance' after disbursements made 
            Student_Loan_Disbursement__c newSLD = new Student_Loan_Disbursement__c();
            newSLD.Id = mySLD.Id;
            newSLD.Remaining_Balance__c = remainingLoanAmt;
            listnewSLD.add(newSLD);
        }

        // insert all the student transactions to pay off current / past balances
        insert listNewStuTrans;
        // update Student_Loan_Disbursement__c to show 'remaining balance' after disbursements made
        update listnewSLD;

    }
    
    public void populateRecordType(List<Student_Loan_Disbursement__c> listSLD) {
	  	List<Id> stuProgs = new List<Id>();
      	Map<Id, String> stuProgInstitutionMap = new Map<Id, String>();
        
      	for (Student_Loan_Disbursement__c stuLoan : listSLD) {
        	if (stuLoan.Student_Program__c != null) {
          		stuProgs.add(stuLoan.Student_Program__c); 
        	}
      	} 
      
      	stuProgInstitutionMap = populateStuProgInstitutionMap(stuProgs);
      
      	List<Schema.RecordTypeInfo> stuLoanDisRecordTypes = describe.getRecordTypeInfos();
      	Map<String, Id> stuLoanDisRecordTypeMap = new Map<String, Id>();
    
      	for (Schema.RecordTypeInfo rt : stuLoanDisRecordTypes) {
        	stuLoanDisRecordTypeMap.put(rt.Name, rt.RecordTypeId); 
      	}
      
      	for (Student_Loan_Disbursement__c stuLoan : listSLD) {
        	stuLoan.RecordTypeId = stuLoanDisRecordTypeMap.get(stuProgInstitutionMap.get(stuLoan.Student_Program__c));
        	system.debug('stuLoan.RecordTypeId ' + stuLoan.RecordTypeId);  
    	}
    }
    
    public Map<Id, String> populateStuProgInstitutionMap(List<Id> stuProgs) {

      	Map<Id, Id> progInstitutionMap = new Map<Id, Id>();
      	Map<Id, Id> stuProgProdMap = new Map<Id, Id>();
      	Map<Id, String> stuProgInstitutionMap = new Map<Id, String>();
      	Map<Id, String> institutionIdNameMap = new Map<Id, String>();  
        
      	for (Student_Program__c stProg : [SELECT id, Program__c FROM Student_Program__c WHERE id IN : stuProgs]) {
        	if (stProg.Program__c != null) {
          		stuProgProdMap.put(stProg.id, stProg.Program__c);      
        	}
      	}
        
      	for (Product2 prod : [SELECT id, Institution__c FROM Product2 WHERE Id IN : stuProgProdMap.values()]) {
        	if (prod.Institution__c != null) {
          		progInstitutionMap.put(prod.id, prod.Institution__c); 
        	}
      	}
      
      	for (Institution__c ins : [SELECT Id, Name FROM Institution__c WHERE id IN : progInstitutionMap.values()]) {
        	institutionIdNameMap.put(ins.id, ins.Name);      
      	}
        
        for (Id stuProg : stuProgProdMap.keySet()) {
        	if (stuProgProdMap.containsKey(stuProg) && progInstitutionMap.containsKey(stuProgProdMap.get(stuProg))
           	&& institutionIdNameMap.containsKey(progInstitutionMap.get(stuProgProdMap.get(stuProg)))) {
          		stuProgInstitutionMap.put(stuProg, institutionIdNameMap.get(progInstitutionMap.get(stuProgProdMap.get(stuProg))));
        	}
      	}
        
      	return stuProgInstitutionMap;  
    }
    
    
    /************************************************************************
     * User Story 22937
     * Method that process Reversal entries 
     ************************************************************************/ 
    private void processReversal(Decimal remainingAmount, Student_Loan_Disbursement__c studentLoanEntry, List<Student_Subscription__c> studentSubscriptionList, List<Student_Transaction__c> listNewStuTrans) {
        List<Student_Transaction__c> studentTransactionList = new List<Student_Transaction__c>();
        Set<Id> studentSubscriptionIdSet = new Set<Id>();
        remainingAmount = remainingAmount * -1;
        List<Student_Transaction__c> reversedStudentTransactionsList = new List<Student_Transaction__c>();
        Map<Id, Student_Subscription__c> idStudentSubscriptionMap = new Map<Id, Student_Subscription__c>();
        
        for (Student_Subscription__c studentSubscription : studentSubscriptionList) {
            studentSubscriptionIdSet.add(studentSubscription.Id);
            idStudentSubscriptionMap.put(studentSubscription.id, studentSubscription);
        }
        
        studentTransactionList = [SELECT Id, Transaction_Date__c, Transaction_Type__c, Refund_Amount__c, Student_Subscription__c, Payment_Amount__c, Transaction_Note__c,
                                         Student_Subscription__r.End_Date__c, Student_Subscription__r.Start_Date__c, Student_Subscription__r.Name, 
                                  		 Student_Loan_Disbursement__r.Fund_Name__c, Student_Loan_Disbursement__r.Disbursement_Number__c, Student_Loan_Disbursement__r.Loan_ID__c
                                  FROM Student_Transaction__c 
                                  WHERE Student_Subscription__c IN :studentSubscriptionIdSet
                                  ORDER BY Student_Subscription__r.CreatedDate DESC];
        
        // First, create a Map for the Student Transactions that fall within the loan period
        Map<Id, Student_Transaction__c> studentTransactionMap = new Map<Id, Student_Transaction__c>();
        for (Student_Transaction__c studentTransaction : studentTransactionList) {
            if (studentTransaction.Student_Subscription__r.Start_Date__c < studentLoanEntry.Loan_end_date__c || studentLoanEntry.Loan_Start_date__c < studentTransaction.Student_Subscription__r.End_Date__c) {
                studentTransactionMap.put(studentTransaction.Id, studentTransaction);
            }
        }
        
        Set<Id> discartedStudentTransactionIdSet = new Set<Id>();
        
        for (Id key : studentTransactionMap.keySet()) {
            Student_Transaction__c studentTransaction = studentTransactionMap.get(key);
            System.debug('*****: ' + studentTransaction);
            if (studentTransaction.Transaction_Type__c == 'FinAid Payment' 
            	&& studentTransaction.Payment_Amount__c > 0 
            	&& studentTransaction.Transaction_Note__c == studentLoanEntry.Fund_Name_Long__c
            	&& studentTransaction.Student_Loan_Disbursement__r.Loan_ID__c == studentLoanEntry.Loan_ID__c
            	&& studentTransaction.Student_Loan_Disbursement__r.Disbursement_Number__c == studentLoanEntry.Disbursement_Number__c
               ) {
                   System.debug('+++++: ' + idStudentSubscriptionMap.get(studentTransaction.Student_Subscription__c).Name + ', ' + idStudentSubscriptionMap.get(studentTransaction.Student_Subscription__c).Temp_Balance__c + ', ' + studentLoanEntry.Loan_ID__c + ', ' + studentLoanEntry.Disbursement_Number__c);
                   Student_Transaction__c reversedStudentTransaction = new Student_Transaction__c();
                   reversedStudentTransaction.Student_Subscription__c = studentTransaction.Student_Subscription__c;
                   reversedStudentTransaction.Transaction_Type__c = 'FinAid Payment';
                   reversedStudentTransaction.Transaction_Note__c = 'Reversal: ' + studentLoanEntry.Fund_Name_Long__c;
                   reversedStudentTransaction.Student_Loan_Disbursement__c = studentLoanEntry.Id;
                   if (studentTransaction.Payment_Amount__c <= remainingAmount) {
                       reversedStudentTransaction.Payment_Amount__c = studentTransaction.Payment_Amount__c * -1;
                       remainingAmount = remainingAmount - studentTransaction.Payment_Amount__c;
                   } else { // this means that Refund Amount is greater than remaining loan amount
                       reversedStudentTransaction.Payment_Amount__c = remainingAmount * -1;
                       remainingAmount = 0;
                   }
                   idStudentSubscriptionMap.get(studentTransaction.Student_Subscription__c).Temp_Balance__c -= reversedStudentTransaction.Payment_Amount__c;
                   System.debug('11111: ' + idStudentSubscriptionMap.get(studentTransaction.Student_Subscription__c).Name + ', ' + idStudentSubscriptionMap.get(studentTransaction.Student_Subscription__c).Temp_Balance__c + ', ' + studentLoanEntry.Loan_ID__c + ', ' + studentLoanEntry.Disbursement_Number__c);
                   listNewStuTrans.add(reversedStudentTransaction);
                   discartedStudentTransactionIdSet.add(key);
               }
        }
        
        
        // Process FinAid Payment Student Transactions first
        /*for (Id key : studentTransactionMap.keySet()) {
            //if (remainingAmount <= 0) break;
            Student_Transaction__c studentTransaction = studentTransactionMap.get(key);
            if (studentTransaction.Transaction_Type__c == 'FinAid Payment' 
            	&& studentTransaction.Payment_Amount__c > 0 
            	&& studentTransaction.Transaction_Note__c == studentLoanEntry.Fund_Name_Long__c
            	&& studentTransaction.Student_Loan_Disbursement__r.Loan_ID__c == studentLoanEntry.Loan_ID__c
            	&& studentTransaction.Student_Loan_Disbursement__r.Disbursement_Number__c == studentLoanEntry.Disbursement_Number__c
               ) {
                System.debug('*****: ' + idStudentSubscriptionMap.get(studentTransaction.Student_Subscription__c).Name + ', ' + idStudentSubscriptionMap.get(studentTransaction.Student_Subscription__c).Temp_Balance__c + ', ' + studentLoanEntry.Loan_ID__c + ', ' + studentLoanEntry.Disbursement_Number__c);
                Student_Transaction__c reversedStudentTransaction = new Student_Transaction__c();
                reversedStudentTransaction.Student_Subscription__c = studentTransaction.Student_Subscription__c;
                reversedStudentTransaction.Transaction_Type__c = 'FinAid Payment';
                reversedStudentTransaction.Transaction_Note__c = 'Reversal: ' + studentLoanEntry.Fund_Name_Long__c;
                reversedStudentTransaction.Student_Loan_Disbursement__c = studentLoanEntry.Id;
                if (studentTransaction.Payment_Amount__c <= remainingAmount) {
                    reversedStudentTransaction.Payment_Amount__c = studentTransaction.Payment_Amount__c * -1;
                    remainingAmount = remainingAmount - studentTransaction.Payment_Amount__c;
                } else { // this means that Refund Amount is greater than remaining loan amount
                    reversedStudentTransaction.Payment_Amount__c = remainingAmount * -1;
                	remainingAmount = 0;
                }
                idStudentSubscriptionMap.get(studentTransaction.Student_Subscription__c).Temp_Balance__c -= reversedStudentTransaction.Payment_Amount__c;
                System.debug('+++++: ' + idStudentSubscriptionMap.get(studentTransaction.Student_Subscription__c).Name + ', ' + idStudentSubscriptionMap.get(studentTransaction.Student_Subscription__c).Temp_Balance__c + ', ' + studentLoanEntry.Loan_ID__c + ', ' + studentLoanEntry.Disbursement_Number__c);
                reversedStudentTransactionsList.add(reversedStudentTransaction);
                discartedStudentTransactionIdSet.add(key);
            }            
        }*/
        
        // Remove processed (and reversed) Student Transactions from Map
        for (Id studentTransactionId : discartedStudentTransactionIdSet) {
            studentTransactionMap.remove(studentTransactionId);
        }
        
        // Will check now for Refunds and create reversals for those
        for (Id key : studentTransactionMap.keySet()) {
            //if (remainingAmount <= 0) break;
            Student_Transaction__c studentTransaction = studentTransactionMap.get(key);
            if (studentTransaction.Transaction_Type__c == 'FinAid Refund to Student' 
                && studentTransaction.Refund_Amount__c > 0 
                && studentTransaction.Transaction_Note__c == studentLoanEntry.Fund_Name_Long__c
               	&& studentTransaction.Student_Loan_Disbursement__r.Loan_ID__c == studentLoanEntry.Loan_ID__c
            	&& studentTransaction.Student_Loan_Disbursement__r.Disbursement_Number__c == studentLoanEntry.Disbursement_Number__c
               ) {
                Student_Transaction__c reversedStudentTransaction = new Student_Transaction__c();
                reversedStudentTransaction.Student_Subscription__c = studentTransaction.Student_Subscription__c;
                reversedStudentTransaction.Transaction_Type__c = 'FinAid Payment';
                reversedStudentTransaction.Transaction_Note__c = 'Reversal: ' + studentLoanEntry.Fund_Name_Long__c;
                reversedStudentTransaction.Student_Loan_Disbursement__c = studentLoanEntry.Id;
                if (studentTransaction.Refund_Amount__c <= remainingAmount) {
                    reversedStudentTransaction.Payment_Amount__c = studentTransaction.Refund_Amount__c * -1;
                    remainingAmount = remainingAmount - studentTransaction.Refund_Amount__c;
                } else { // this means that Refund Amount is greater than remaining loan amount
                    reversedStudentTransaction.Payment_Amount__c = remainingAmount * -1;
                    remainingAmount = 0;
                }
                idStudentSubscriptionMap.get(studentTransaction.Student_Subscription__c).Temp_Balance__c -= reversedStudentTransaction.Payment_Amount__c;
                listNewStuTrans.add(reversedStudentTransaction);                
            }            
        }
        
    }
}