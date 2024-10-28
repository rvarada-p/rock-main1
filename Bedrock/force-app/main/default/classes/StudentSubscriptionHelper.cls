/*******************************************************************
Name  : StudentSubscriptionHelper
Author: Tom (Appirio)
Date  : September 30, 2014
Description: Helper class for Student_Subscription__c
Name: Sarah Khalid - Laureate
Date: June 14, 2016
Description: Made changes for Program hierarchy

* Revision History
* Horacio Sanchez	-	Aug 12, 2021	-	User Story 58882: L2: Trigger Automatic Email invoice when Student Subscription is Manually created
*************************************************************************/
public with sharing class StudentSubscriptionHelper {
    
    //Constructor
    public StudentSubscriptionHelper(){
        
    }
    
    public void populateSubscriptionBaseCostAndEndDate(list<Student_Subscription__c > newStudentSubscriptions, Boolean isInsert){
        set<Id> pBookIdSet = new set<Id>();
        set<Id> studProgIdSet = new set<Id>();
        for(Student_Subscription__c sub:newStudentSubscriptions) {
            pBookIdSet.add(sub.Term_Price_Book__c);
            studProgIdSet.add(sub.Student_Program__c);
        }
        map<Id,Student_Program__c> mapId_StudentProgam = new map<Id,Student_Program__c>([SELECT Id, Parent_Program__c, Program__c, Number_of_Enrolled_Terms__c,
                                                                                         Student__r.Email, Student__r.Walden_Email__c
                                                                                         FROM Student_Program__c WHERE Id IN :studProgIdSet]);
        set<Id> prodIdSet = new set<Id>();
        for(Student_Program__c stuProg:mapId_StudentProgam.values()) {
            if(stuProg.Parent_Program__c!=null) {
                prodIdSet.add(stuProg.Parent_program__c);
            }
            else {
                prodIdSet.add(stuProg.Program__c);
            }
        }
        
        map<Id,Pricebook2> mapId_Pricebook = new map<Id,Pricebook2>([SELECT Id, Subscription_Duration_in_Months__c 
                                                                     FROM Pricebook2 WHERE Id IN :pBookIdSet ]);
        
        system.debug('Pricebook ID Set ' + pBookIdSet);
        System.debug('Map Pricebook ' + mapId_Pricebook);      
        System.debug('prodIdSet ' + prodIdSet);                                                        
        if(!mapId_Pricebook.isEmpty()) {
            for(PricebookEntry pbEntry : [ SELECT UnitPrice,Tech_Fee__c,Tuition__c, Product2Id, Pricebook2Id
                                          FROM PricebookEntry WHERE Pricebook2Id IN :pBookIdSet 
                                          AND Product2Id IN :prodIdSet 
                                          AND (Available_for_Existing_Students__c = TRUE 
                                               OR IsActive = TRUE) ]) {
                                                   System.debug('pbEntry ' + pbEntry);                                  
                                                   for(Student_Subscription__c sub : newStudentSubscriptions) {
                                                       System.debug('Student Sub to be inserted : ' + sub + ' SP: ' + sub.Student_Program__c);
                                                       // Populate email fields on subscription
                                                       
                                                       sub.Student_Primary_Email__c = mapId_StudentProgam.get(sub.Student_Program__c).Student__r.Email;
                                                       sub.Student_Institution_Email__c = mapId_StudentProgam.get(sub.Student_Program__c).Student__r.Walden_Email__c;
                                                       
                                                       if(sub.Term_Price_Book__c == pbEntry.Pricebook2Id 
                                                          &&  (mapId_StudentProgam.get(sub.Student_Program__c).Parent_Program__c == pbEntry.Product2Id) ) {
                                                              System.debug('Map Student Program ::: ' + mapId_StudentProgam.get(sub.Student_Program__c).Parent_Program__c);
                                                              system.debug('Pricebook Product Entry ::: ' + pbEntry.Product2Id);
                                                              if(isInsert){
                                                                  sub.List_Price__c = pbEntry.UnitPrice; 
                                                                  if(pbEntry.Tech_Fee__c != null){
                                                                      sub.Tech_Fee__c = pbEntry.Tech_Fee__c;
                                                                  }if(pbEntry.Tuition__c != null){
                                                                      sub.Tuition__c  = pbEntry.Tuition__c; 
                                                                  }
                                                                  System.debug('On Insert: for Sub ' + sub + ' Unit Price: ' + pbEntry.UnitPrice + ' PB: '+ pbEntry);
                                                              }         
                                                              
                                                              if(!Test.isRunningTest() && Script_Settings__c.getValues('Current Settings').disableSubEndDateValidation__c!=null && !Script_Settings__c.getValues('Current Settings').disableSubEndDateValidation__c) {
                                                                  sub.End_Date__c = Utility.getSundayEndDateForStudentSubscription(Integer.valueOf(mapId_Pricebook.get(sub.Term_Price_Book__c).Subscription_Duration_in_Months__c)
                                                                                                                                   , sub.Start_Date__c);
                                                              }                                                          
                                                          }
                                                   }
                                               }
        } 
        
    }
    
    public void enforceSingleSubscriptionPerPeriodPerStudentProgram(list<Student_Subscription__c > newStudentSubscriptions){
        set<Id> stuProgIdSet = new set<Id>();
        for(Student_Subscription__c sub:newStudentSubscriptions) {
            stuProgIdSet.add(sub.Student_Program__c);
        }
        
        list<Student_Subscription__c> stuSubList = [ SELECT Start_Date__c, End_Date__c, Student_Program__c, Subscription_Status__c FROM Student_Subscription__c 
                                                    WHERE Student_Program__c IN :stuProgIdSet 
                                                    AND Subscription_Status__c = 'RE = Registered'
                                                    AND Id NOT IN :newStudentSubscriptions ];
        map<Id,list<Student_Subscription__c>> mapStuProgId_StuSubList = new map<Id,list<Student_Subscription__c>>();
        for(Student_Subscription__c sub : stuSubList) {
            if(!mapStuProgId_StuSubList.containsKey(sub.Student_Program__c)) {
                mapStuProgId_StuSubList.put(sub.Student_Program__c, new list<Student_Subscription__c>());
            } 
            mapStuProgId_StuSubList.get(sub.Student_Program__c).add(sub);
        }
        
        for(Student_Subscription__c sub:newStudentSubscriptions) {
            if(mapStuProgId_StuSubList.containsKey(sub.Student_Program__c)) {
                for(Student_Subscription__c progSub : mapStuProgId_StuSubList.get(sub.Student_Program__c)) {
                    System.debug('New Subscription :: ' + sub.Subscription_Status__c);
                    System.debug('Old Subscription :: ' + progSub.Subscription_Status__c); 
                    
                    
                    if(progSub.End_Date__c >= sub.Start_Date__c && progSub.Start_Date__c <= sub.End_Date__c && (sub.Subscription_Status__c!='DD = Subscription Drop/Delete' && sub.Subscription_Status__c!='WD = Subscription Withdrawal' && progSub.Subscription_Status__c!='DD = Subscription Drop/Delete' && progSub.Subscription_Status__c!='WD = Subscription Withdrawal')) {
                        sub.addError('A Student Subscription already exists for this Subscription Period for the Student Program.');
                    }
                }
            }
        }
        
    }
    
    // Insert each approved discount as a Student Subscription Exemption line item
    public void insertStudentSubscriptionExemptions(List<Student_Subscription__c> subscriptions, set<Id> setStudentProgramId) {
        
        List<Student_Subscription_Exemptions__c> studentSubscriptionExemptions = new List<Student_Subscription_Exemptions__c>();
        
        map<ID,list<Student_Discount__c>> mapStudentProgramWithStudentDiscount = new map<ID,list<Student_Discount__c>>();
        for(Student_Discount__c sd:[Select id,Student_Program__c, Exemption__r.Life_of_Program__c, Exemption__c,
                                    Exemption__r.no_of_Terms__c, Exemption__r.Exemption_Start_Date__c, Exemption__r.Percentage_Discount__c, Exemption__r.Flat_Rate_Amount__c
                                    from Student_Discount__c 
                                    where Student_Program__c in: setStudentProgramId
                                    and Exemption_Approved__c = true
                                    and Active__c = true]){
                                        if(!mapStudentProgramWithStudentDiscount.containsKey(sd.Student_Program__c)){
                                            mapStudentProgramWithStudentDiscount.put(sd.Student_Program__c,new list<Student_Discount__c>());
                                        }
                                        mapStudentProgramWithStudentDiscount.get(sd.Student_Program__c).add(sd);
                                    }   
        System.debug('Map Student Program with Student Discounts ' + mapStudentProgramWithStudentDiscount);
        //Loop through the Student Subscription records and find matching exemptions applicable via the map above
        for(Student_Subscription__c subscription : subscriptions){
            
            if(mapStudentProgramWithStudentDiscount.containsKey(subscription.Student_Program__c)){
                // get all the discount
                for(Student_Discount__c sd: mapStudentProgramWithStudentDiscount.get(subscription.Student_Program__c)){
                    Student_Subscription_Exemptions__c studentSubscriptionExemption = new Student_Subscription_Exemptions__c(Student_Discount__c = sd.Id, Student_Subscription__c = subscription.Id, Exemption__c = sd.Exemption__c);
                    studentSubscriptionExemptions.add(studentSubscriptionExemption);
                }
            }
        }
        
        if(studentSubscriptionExemptions.size()>0) {
            insert studentSubscriptionExemptions;
        }           
    }
    
    
            /* Sarah - Removed this method as part of Discount automation
        // Insert each approved discount as a Transaction line item
        public void insertSubscriptionDiscountLineItems(list<Student_Subscription__c > newStudentSubscriptions){
        
        set<Id> stuProgIdSet = new set<Id>();
        for(Student_Subscription__c sub:newStudentSubscriptions) {
        stuProgIdSet.add(sub.Student_Program__c);
        }
        system.debug('size of stuProgIdSet ' + stuProgIdSet.size());
        
        list<Student_Discount__c> listStuDisc = new list<Student_Discount__c>(
        [SELECT Student_Program__c, Exemption_Description__c, Exemption__r.Flat_Rate_Amount__c, Exemption__r.Percentage_Discount__c,
        Exemption__r.Description__c
        FROM Student_Discount__c
        WHERE Student_Program__c IN :stuProgIdSet
        AND Exemption_Approved__c = true]);
        system.debug('size of listStuDisc ' + listStuDisc.size());
        
        // Insert Discount line items into Student Transaction table
        list<Student_Transaction__c> stuTrans = new list<Student_Transaction__c>();
        
        for(Student_Subscription__c sub : newStudentSubscriptions) {
        for(Student_Discount__c stuDis : listStuDisc) {
        if (sub.Student_Program__c == stuDis.Student_Program__c) {
        system.debug('found match sub.Student_Program__c == stuDis.Student_Program__c');
        
        Decimal listPrice = sub.List_Price__c;
        Decimal discountAmount = 0.0;
        
        if (listPrice == null) listPrice = 0;
        if (stuDis.Exemption__r.Flat_Rate_Amount__c > 0) {
        discountAmount = stuDis.Exemption__r.Flat_Rate_Amount__c;
        }
        else if (stuDis.Exemption__r.Percentage_Discount__c > 0) {
        discountAmount = stuDis.Exemption__r.Percentage_Discount__c * listPrice / 100;
        }
        else
        discountAmount = 0.0;
        
        system.debug('>>> Discount: inserting discount: $'+discountAmount+' for program: '+sub.Student_Program__c);
        system.debug('>>> dis.Exemption_Description__c: '+stuDis.Exemption_Description__c);
        stuTrans.add(new Student_Transaction__c(Student_Subscription__c = sub.Id, Transaction_Type__c = 'Subscription Reduction',
        Transaction_Date__c = sub.Start_Date__c, Discount_Amount__c = discountAmount, Transaction_Note__c = stuDis.Exemption_Description__c));
        }
        }
        }
        insert stuTrans;
        }
        */
            
    // method to verify the Start_Date__c is always the first Monday of the given month (in the Start Date)
    // related task: T-331925
    // created by: vinod kumar
    public void verifyStartDateAsFirstMondayOfTheGivenMonth(list<Student_Subscription__c > newStudentSubscriptions){   
        for(Student_Subscription__c sub : newStudentSubscriptions) {
            if(sub.Start_Date__c != null && !Utility.isFirstMondayOfMonth(sub.Start_Date__c)){
                //if(!TestDataGenerator.disableSubMondayValidation){
                system.debug('>> TestDataGenerator.disableSubMondayValidation__c:' + Script_Settings__c.getValues('Current Settings').disableSubMondayValidation__c);
                
                if(!Script_Settings__c.getValues('Current Settings').disableSubMondayValidation__c && Script_Settings__c.getValues('Current Settings').disableSubMondayValidation__c!=null) {
                    sub.addError('Start date should be on the first Monday of the month.');
                }
            }
        }
        
    }
    
    /*******************************************************************
    Method that creates a new Student Transaction whenever the Drop Withdrawal Effective Date is changed and not equals to null
    If there is already a Student Transaction created due to this, this Student Transaction is updated
    Related Story : S-58663
    Created By: Horacio Sanchez
    Event : After Update 
    ********************************************************************/
    public void upsertStudentTransactionFromWithdrawDate(List<Student_Subscription__c> studentSubscriptionList) {        
        Set<Id> studentSubscriptionIdsSet = new set<Id>();
        Map<Id, Student_Subscription__c> idStudentSubscriptionMap = new Map<Id, Student_Subscription__c>();
        Set<Id> subscriptionsWithGrantsSet = new Set<Id>();
        
        for(Student_Subscription__c sub : studentSubscriptionList) {
            studentSubscriptionIdsSet.add(sub.Id);
            idStudentSubscriptionMap.put(sub.id, sub);
            if (sub.Total_Grant_Scholarship__c > 0.0 && 
                ((sub.Subscription_Status__c == 'WD = Subscription Withdrawal' || 
                  sub.Subscription_Status__c == 'WM = Withdrawal- Maryland Student' || 
                  sub.Subscription_Status__c == 'WN = Withdrawal-North Dakota Student' || 
                  sub.Subscription_Status__c == 'WT = Withdrawal - Tennessee Student') && (sub.Start_Date__c).daysBetween(sub.Subscription_DP_WD_Effective_Date__c) > 14)) {
                subscriptionsWithGrantsSet.add(sub.Id);
            }
        }
        
        List<Student_Transaction__c> studentTransactionsList = new List<Student_Transaction__c>();
        studentTransactionsList = [SELECT Id, Transaction_Type__c, Drop_Withdrawal_Effective_Date__c, Student_Subscription__c, 
                                          Transaction_Date__c, Miscellaneous_Adjustment__c, Discount_Amount__c, LastModifiedDate, 
                                   		  Grant_Scholarship_Amount__c, Student_Subscription__r.Subscription_Status__c, Student_Subscription__r.Total_Grant_Scholarship__c,
                                   		  Student_Subscription__r.Start_Date__c, Student_Subscription__r.Subscription_DP_WD_Effective_Date__c, Student_Subscription__r.student_state__c
                                   FROM Student_Transaction__c
                                   WHERE Student_Subscription__c IN :studentSubscriptionIdsSet
                                   ORDER BY LastModifiedDate DESC];
        
        // Filtering the list to obtain only the ones with DD Status
        // Reverting Scholarship and Grant
        List<Student_Transaction__c> subscriptionDropDeleteList = new List<Student_Transaction__c>();
        for (Student_Transaction__c studentTransaction : studentTransactionsList) {
            if (studentTransaction.Student_Subscription__r.Total_Grant_Scholarship__c > 0.0 && 
               ((studentTransaction.Student_Subscription__r.Subscription_Status__c == 'DD = Subscription Drop/Delete' || 
                 studentTransaction.Student_Subscription__r.Subscription_Status__c == 'DW = Web Drop') || 
               (studentTransaction.Student_Subscription__r.Start_Date__c).daysBetween(studentTransaction.Student_Subscription__r.Subscription_DP_WD_Effective_Date__c) < 15)) {
               		subscriptionDropDeleteList.add(studentTransaction);
            }
        }
        revertTransactionRecords(subscriptionDropDeleteList, 'Grant');
        revertTransactionRecords(subscriptionDropDeleteList, 'Scholarship');
        
        Set<Id> notToUpdateStudentSubsIdSet = new Set<Id>();
        List<Student_Transaction__c> updateStudentTransactionsList = new List<Student_Transaction__c>();
        
        revertTuitionAdjustment(studentTransactionsList);
        
        List<Student_Transaction__c> studentTransactionsFullRefundList = new List<Student_Transaction__c>();
        List<Student_Transaction__c> studentTransactions08RefundList = new List<Student_Transaction__c>();
        List<Student_Transaction__c> studentTransactions06RefundList = new List<Student_Transaction__c>();
        List<Student_Transaction__c> studentTransactions04RefundList = new List<Student_Transaction__c>();
        List<Student_Transaction__c> studentTransactions02RefundList = new List<Student_Transaction__c>();
        for (Student_Transaction__c studentTransaction : studentTransactionsList) {
            if (studentTransaction.Student_Subscription__r.Subscription_Status__c == 'DD = Subscription Drop/Delete' || 
                studentTransaction.Student_Subscription__r.Subscription_Status__c == 'DW = Web Drop' ||
                studentTransaction.Student_Subscription__r.Start_Date__c.daysBetween(studentTransaction.Student_Subscription__r.Subscription_DP_WD_Effective_Date__c) < 15) {
                	studentTransactionsFullRefundList.add(studentTransaction);
                } else if (studentTransaction.Student_Subscription__r.Subscription_Status__c == 'WD = Subscription Withdrawal' || 
                  studentTransaction.Student_Subscription__r.Subscription_Status__c == 'WM = Withdrawal- Maryland Student' || 
                  studentTransaction.Student_Subscription__r.Subscription_Status__c == 'WN = Withdrawal-North Dakota Student' || 
                  studentTransaction.Student_Subscription__r.Subscription_Status__c == 'WT = Withdrawal - Tennessee Student') {
                      if (studentTransaction.Student_Subscription__r.Start_Date__c.daysBetween(studentTransaction.Student_Subscription__r.Subscription_DP_WD_Effective_Date__c) < 22) {
                          studentTransactions08RefundList.add(studentTransaction);
                      } else if (studentTransaction.Student_Subscription__r.Start_Date__c.daysBetween(studentTransaction.Student_Subscription__r.Subscription_DP_WD_Effective_Date__c) < 29) {
                          studentTransactions06RefundList.add(studentTransaction);
                      } else if (studentTransaction.Student_Subscription__r.Start_Date__c.daysBetween(studentTransaction.Student_Subscription__r.Subscription_DP_WD_Effective_Date__c) < 34 && studentTransaction.Student_Subscription__r.student_state__c == 'Maryland') {
                          studentTransactions04RefundList.add(studentTransaction);
                      } else if (studentTransaction.Student_Subscription__r.Start_Date__c.daysBetween(studentTransaction.Student_Subscription__r.Subscription_DP_WD_Effective_Date__c) < 51 && studentTransaction.Student_Subscription__r.student_state__c == 'Maryland') {
                          studentTransactions02RefundList.add(studentTransaction);
                      }                          
                }
        }
        
        revertSubscriptionReductions(studentTransactionsFullRefundList, 1.0);
        revertSubscriptionReductions(studentTransactions08RefundList, 0.8);
        revertSubscriptionReductions(studentTransactions06RefundList, 0.6);
        revertSubscriptionReductions(studentTransactions04RefundList, 0.4);
        revertSubscriptionReductions(studentTransactions02RefundList, 0.2);
       
        for (Id key : idStudentSubscriptionMap.keySet()) {
            Student_Transaction__c studentTransaction = new Student_Transaction__c();
            studentTransaction.Student_Subscription__c = key;
            studentTransaction.Transaction_Type__c = 'Tuition Adjustment';
            studentTransaction.Transaction_Date__c = Date.today();
            studentTransaction.Drop_Withdrawal_Effective_Date__c = idStudentSubscriptionMap.get(key).Subscription_DP_WD_Effective_Date__c;
            studentTransaction.Miscellaneous_Adjustment__c = calculateTuitionRefund(idStudentSubscriptionMap.get(key));
            updateStudentTransactionsList.add(studentTransaction);
        }
        
        if (!updateStudentTransactionsList.isEmpty()) {
            insert updateStudentTransactionsList;
        }
        
        processGrantStudentTransactions(subscriptionsWithGrantsSet);
    }
    
    /***
     * 
     * 
     ***/
    private void revertTuitionAdjustment(List<Student_Transaction__c> studentTransactionsList) {
        List<Student_Transaction__c> studentTransactionsToRevertList = new List<Student_Transaction__c>();
        Map<Id, List<Student_Transaction__c>> subscriptionIdTransactionListMap = new Map<Id, List<Student_Transaction__c>>();
        
        for (Student_Transaction__c studentTransaction : studentTransactionsList) {
            System.debug('+++++: ' + studentTransaction.Transaction_Type__c + ', ' + studentTransaction.Miscellaneous_Adjustment__c);
            if (studentTransaction.Transaction_Type__c == 'Tuition Adjustment' && studentTransaction.Miscellaneous_Adjustment__c != 0.0) {
                Double test = studentTransaction.Miscellaneous_Adjustment__c * -1;
                if (subscriptionIdTransactionListMap.get(studentTransaction.Student_Subscription__c) != null) {
                    subscriptionIdTransactionListMap.get(studentTransaction.Student_Subscription__c).add(studentTransaction);
                } else {
                    subscriptionIdTransactionListMap.put(studentTransaction.Student_Subscription__c, new List<Student_Transaction__c>{studentTransaction});
                }
            }
        }
        
        for (Id key : subscriptionIdTransactionListMap.keySet()) {
            if (subscriptionIdTransactionListMap.get(key).size() > 1) {
                Integer size = subscriptionIdTransactionListMap.get(key).size();
                for (Integer i = size - 1; i >= 1 ; i--) {
                    for (Integer j = size - 2;  j >= 0;  j--) {
                        try {
                        	if (subscriptionIdTransactionListMap.get(key)[i].Drop_Withdrawal_Effective_Date__c == subscriptionIdTransactionListMap.get(key)[j].Drop_Withdrawal_Effective_Date__c &&
                           		subscriptionIdTransactionListMap.get(key)[i].Miscellaneous_Adjustment__c == (subscriptionIdTransactionListMap.get(key)[j].Miscellaneous_Adjustment__c * -1)
                               ) {
                                    subscriptionIdTransactionListMap.get(key).remove(i);
                                    subscriptionIdTransactionListMap.get(key).remove(j);
                                    break;
                               }    
                        } catch(Exception ex) {
                            break;
                        }
                    }
                }
            }
            for (Student_Transaction__c studentTransaction : subscriptionIdTransactionListMap.get(key)){
                Student_Transaction__c st = new Student_Transaction__c();
                st.Student_Subscription__c = key;
                st.Transaction_Type__c = 'Tuition Adjustment';
                st.Transaction_Date__c = Date.today();
                st.Drop_Withdrawal_Effective_Date__c = studentTransaction.Drop_Withdrawal_Effective_Date__c;
                System.debug('*****: ' + studentTransaction);
                st.Miscellaneous_Adjustment__c = studentTransaction.Miscellaneous_Adjustment__c * -1;
                studentTransactionsToRevertList.add(st);
            }
        }
        
        if (!studentTransactionsToRevertList.isEmpty()) {
            insert studentTransactionsToRevertList;
        }
    }
	
    /*
     * USER STORY 5782 in Azure DevOps (2020.1.3)
     */ 
    private void processGrantStudentTransactions(Set<Id> subscriptionsWithGrantsSet) {
		Map<Id, List<Student_Transaction__c>> studentSubscriptionIdStudentTransactionMap = new Map<Id, List<Student_Transaction__c>>();
        List<Student_Transaction__c> studentTransactionList = new List<Student_Transaction__c>();
        
        for (Student_Transaction__c studentTransaction : [SELECT Id, Grant_Scholarship_Amount__c, Student_Subscription__c, Transaction_type__c,
                                                          		 Student_Subscription__r.Id, Student_Subscription__r.Total_Grant_Scholarship__c, Student_Subscription__r.Current_Subscription_Balance__c,
                                                          		 Student_Subscription__r.Tech_Fee__c, Student_Subscription__r.Tuition__c, Student_Subscription__r.Total_Miscellaneous_Adjustment__c,
                                                          		 Student_Subscription__r.Total_Discount_1__c
                                                          FROM Student_Transaction__c 
                                                          WHERE Student_Subscription__r.Id IN :subscriptionsWithGrantsSet
                                                          AND (Transaction_Type__c = 'Grant' OR Transaction_Type__c = 'Scholarship')]) {
            if (!studentSubscriptionIdStudentTransactionMap.containsKey(studentTransaction.Student_Subscription__r.Id)) {
                studentSubscriptionIdStudentTransactionMap.put(studentTransaction.Student_Subscription__r.Id, new List<Student_Transaction__c>{studentTransaction});
            } else {
                studentSubscriptionIdStudentTransactionMap.get(studentTransaction.Student_Subscription__r.Id).add(studentTransaction);
            }
        }
        
        for (Id key : studentSubscriptionIdStudentTransactionMap.keySet()) {
            if (studentSubscriptionIdStudentTransactionMap.get(key)[0].Student_Subscription__r.Tuition__c - Math.abs(studentSubscriptionIdStudentTransactionMap.get(key)[0].Student_Subscription__r.Total_Miscellaneous_Adjustment__c) < studentSubscriptionIdStudentTransactionMap.get(key)[0].Student_Subscription__r.Total_Grant_Scholarship__c) {
                if (studentSubscriptionIdStudentTransactionMap.get(key).size() == 1) {
                    Student_Transaction__c st = new Student_Transaction__c();
                    st.Student_Subscription__c = studentSubscriptionIdStudentTransactionMap.get(key)[0].Student_Subscription__r.id;
                    st.Grant_Scholarship_Amount__c = studentSubscriptionIdStudentTransactionMap.get(key)[0].Grant_Scholarship_Amount__c - (studentSubscriptionIdStudentTransactionMap.get(key)[0].Student_Subscription__r.Tuition__c - Math.abs(studentSubscriptionIdStudentTransactionMap.get(key)[0].Student_Subscription__r.Total_Miscellaneous_Adjustment__c) -  Math.abs(studentSubscriptionIdStudentTransactionMap.get(key)[0].Student_Subscription__r.Total_Discount_1__c));
                    st.Grant_Scholarship_Amount__c *= -1;
                    st.Transaction_Type__c = studentSubscriptionIdStudentTransactionMap.get(key)[0].Transaction_Type__c;
                    studentTransactionList.add(st);
                } else {
                    for (Student_Transaction__c studentTransaction : studentSubscriptionIdStudentTransactionMap.get(key)) {
                        if (studentTransaction.Student_Subscription__r.Total_Grant_Scholarship__c == studentTransaction.Grant_Scholarship_Amount__c) {
                            Student_Transaction__c st = new Student_Transaction__c();
                            st.Student_Subscription__c = studentTransaction.Student_Subscription__r.id;
                            st.Grant_Scholarship_Amount__c = studentTransaction.Grant_Scholarship_Amount__c - (studentTransaction.Student_Subscription__r.Tuition__c - Math.abs(studentTransaction.Student_Subscription__r.Total_Miscellaneous_Adjustment__c) - Math.abs(studentTransaction.Student_Subscription__r.Total_Discount_1__c));
                            st.Grant_Scholarship_Amount__c *= -1;
                            st.Transaction_Type__c = studentTransaction.Transaction_Type__c;
                            studentTransactionList.add(st);
                            break;
                        }
                    }
                }
            }
        }
        
        if (!studentTransactionList.isEmpty()) {
            insert studentTransactionList;
        }
	}

    /*
     * 
     */
    private void revertTransactionRecords(List<Student_Transaction__c> studentTransactionsList, String transactionType) {
        List<Student_Transaction__c> studentTransactionsToRevertList = new List<Student_Transaction__c>();
        Map<Id, List<Student_Transaction__c>> subscriptionIdTransactionListMap = new Map<Id, List<Student_Transaction__c>>();
        
        for (Student_Transaction__c studentTransaction : studentTransactionsList) {
            if (subscriptionIdTransactionListMap.get(studentTransaction.Student_Subscription__c) != null) {
                subscriptionIdTransactionListMap.get(studentTransaction.Student_Subscription__c).add(studentTransaction);
            } else {
                subscriptionIdTransactionListMap.put(studentTransaction.Student_Subscription__c, new List<Student_Transaction__c>{studentTransaction});
            }            
        }
        
        for (Id key : subscriptionIdTransactionListMap.keySet()) {
            Double totalDiscountAmount = 0.0;
            List<Student_Transaction__c> tempList = new List<Student_Transaction__c>();
            for (Student_Transaction__c studentTransaction : subscriptionIdTransactionListMap.get(key)) {
                if (studentTransaction.Transaction_Type__c == transactionType) {
                    Student_Transaction__c st = new Student_Transaction__c();
                    st.Student_Subscription__c = key;
                    st.Transaction_Type__c = studentTransaction.Transaction_Type__c;
                    st.Transaction_Date__c = Date.today();
                    switch on transactionType {
                        /*when 'Subscription Reduction' {
                            totalDiscountAmount += studentTransaction.Discount_Amount__c;
                            st.Discount_Amount__c = studentTransaction.Discount_Amount__c * -1;
                            if (studentTransaction.Discount_Amount__c != 0.0) {
                                tempList.add(st);
                            }
                        }*/
                        when 'Scholarship', 'Grant' {
                            totalDiscountAmount += studentTransaction.Grant_Scholarship_Amount__c;
                            st.Grant_Scholarship_Amount__c = studentTransaction.Grant_Scholarship_Amount__c * -1;
                            if (studentTransaction.Grant_Scholarship_Amount__c != 0.0) {
                                tempList.add(st);
                            }
                        }
                    }
                }
            }
            if (totalDiscountAmount != 0.0) {
                studentTransactionsToRevertList.addAll(tempList);
            }
        }
        
        if (!studentTransactionsToRevertList.isEmpty()) {
            insert studentTransactionsToRevertList;
        }
    }

	/*
	 * 
	 * */    
    private void revertSubscriptionReductions(List<Student_Transaction__c> studentTransactionsList, Decimal percentRefund) {
        List<Student_Transaction__c> studentTransactionsToRevertList = new List<Student_Transaction__c>();
        Map<Id, List<Student_Transaction__c>> subscriptionIdTransactionListMap = new Map<Id, List<Student_Transaction__c>>();
        
        for (Student_Transaction__c studentTransaction : studentTransactionsList) {
            if (subscriptionIdTransactionListMap.get(studentTransaction.Student_Subscription__c) != null) {
                subscriptionIdTransactionListMap.get(studentTransaction.Student_Subscription__c).add(studentTransaction);
            } else {
                subscriptionIdTransactionListMap.put(studentTransaction.Student_Subscription__c, new List<Student_Transaction__c>{studentTransaction});
            }            
        }
        
        for (Id key : subscriptionIdTransactionListMap.keySet()) {
            Integer positiveNegativeRatio = 0;
            List<Student_Transaction__c> tempList = new List<Student_Transaction__c>();
            for (Student_Transaction__c studentTransaction : subscriptionIdTransactionListMap.get(key)) {
                if (studentTransaction.Transaction_Type__c == 'Subscription Reduction') {
                    if (studentTransaction.Discount_Amount__c > 0) {
                        positiveNegativeRatio += 1;
                    } else if (studentTransaction.Discount_Amount__c < 0) {
                        positiveNegativeRatio -= 1;
                    }
                    if (studentTransaction.Discount_Amount__c != 0.0) {
                        Student_Transaction__c st = new Student_Transaction__c();
                        st.Student_Subscription__c = key;
                        st.Transaction_Type__c = 'Subscription Reduction';
                        st.Transaction_Date__c = Date.today();
                        st.Discount_Amount__c = studentTransaction.Discount_Amount__c * percentRefund * -1;
                        tempList.add(st);
                    }
                }
            }
            if (positiveNegativeRatio != 0) {
                studentTransactionsToRevertList.addAll(tempList);
            }
        }
        
        /*for (Id key : subscriptionIdTransactionListMap.keySet()) {
            Double totalDiscountAmount = 0.0;
            List<Student_Transaction__c> tempList = new List<Student_Transaction__c>();
            for (Student_Transaction__c studentTransaction : subscriptionIdTransactionListMap.get(key)) {
                if (studentTransaction.Transaction_Type__c == 'Subscription Reduction') {
                    totalDiscountAmount += studentTransaction.Discount_Amount__c;
                    if (studentTransaction.Discount_Amount__c != 0.0) {
                        Student_Transaction__c st = new Student_Transaction__c();
                        st.Student_Subscription__c = key;
                        st.Transaction_Type__c = 'Subscription Reduction';
                        st.Transaction_Date__c = Date.today();
                        st.Discount_Amount__c = studentTransaction.Discount_Amount__c * percentRefund * -1;
                        tempList.add(st);
                    }
                }
            }
            if (totalDiscountAmount != 0.0) {
                studentTransactionsToRevertList.addAll(tempList);
            }
        }*/
        
        if (!studentTransactionsToRevertList.isEmpty()) {
            insert studentTransactionsToRevertList;
        }
    }
    
    private Double calculateTuitionRefund(Student_Subscription__c studentSubscription) {
        
        if (studentSubscription.Start_Date__c == null) {
            throw new MyCustomException('Error: the student subscription has no Start Date defined.');
        } else {
            Integer daysDifference = (studentSubscription.Start_Date__c).daysBetween(studentSubscription.Subscription_DP_WD_Effective_Date__c);
            Double percentRefund = 0.0;
            if (daysDifference < 15) {
                percentRefund = 1.0;
            }  else if (daysDifference < 22) {
                percentRefund = 0.8;
            } else if (daysDifference < 29) {
                percentRefund = 0.6;
            } else if (daysDifference < 34 && studentSubscription.student_state__c == 'Maryland') {
                percentRefund = 0.4;
            } else if (daysDifference < 51 && studentSubscription.Student_State__c == 'Maryland') {
                percentRefund = 0.2;
            }
            
            if (studentSubscription.Subscription_Status__c == 'DD = Subscription Drop/Delete' || studentSubscription.Subscription_Status__c == 'DW = Web Drop' || daysDifference < 15) {
            	return ((percentRefund * studentSubscription.Tuition__c) + studentSubscription.Tech_Fee__c) * -1;     
            } else {
                return (percentRefund * studentSubscription.Tuition__c) * -1; 
            }
            
        }
    }
    
    //S-58882: L2: Trigger Automatic Email invoice when Student Subscription is Manually created
    public void handleManuallyCreatedSubs(Set<Id> newSubsIdSet) {
        List<Student_Subscription__c> studentSubscriptionList = [SELECT Id, Name, Student_Program__c, Student_Program__r.Student_s_Walden_Email__c, Student_Program__r.Student__c, Student_ID__c, 
                                                                        Total_Outstanding_Balance__c, Total_Grant_special_refund_to_student__c, Days_Past_Due__c, Student_Program__r.Sponsor_Billing__c, 
                                                                        Student_Program__r.Learner_Outcome__c, Student_Program__r.Student__r.Email, Student_Program__r.Student__r.Walden_Email__c,
                                                                 		Student_Program__r.Total_Outstanding_Balance__c, Current_Subscription_Balance__c
                                                                 FROM Student_Subscription__c
                                                                 WHERE Id IN :newSubsIdSet
                                                                 AND Student_Program__r.Student_s_Walden_Email__c != NULL
                                                                 AND Student_Program__r.Student_s_Walden_Email__c != ''                                                                 
                                                                 AND Student_Program__r.Open_BK_Hold__c = 0
                                                                 AND Student_Program__r.Sponsor_Billing__c = FALSE 
                       						 AND Student_Program__r.Student_Sponsor_Name__c = NULL
                                                                 AND Write_Off__c = FALSE
                                                                 AND Start_Date__c <= NEXT_N_DAYS:30
                                                                 AND Subscription_Status__c NOT IN ('DD = Subscription Drop/Delete','DW = Web Drop' ,'RW = Web Registered')
                                                                 AND (Student_Program__r.Last_Invoice_Sent_Date__c = NULL OR (Student_Program__r.Last_Invoice_Sent_Date__c != NULL AND Student_Program__r.Last_Invoice_Sent_Date__c < LAST_N_DAYS:7))];
                
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Map<Id,Id> mapContextStuSubIdToStuProgramId = new Map<Id,Id>();
        
        if (!studentSubscriptionList.isEmpty()) {
            Id emailTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Invoice_Email_Walden'].Id;
            
            for (Student_Subscription__c stuSub : studentSubscriptionList) {
                if ((stuSub.Student_Program__r.Total_Outstanding_Balance__c + stuSub.Current_Subscription_Balance__c) > 0) {
                    List<String> sendTo = new List<String>();
                    sendTo.add(stuSub.Student_Program__r.Student_s_Walden_Email__c);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(sendTo);
                    mail.setReplyTo('cblbilling@waldenu.edu');
                    mail.setSenderDisplayName('Invoice emails');
                    mail.setWhatId(stuSub.Id);
                    mail.setTemplateId(emailTemplateId);  		
                    mail.setTargetObjectId(stuSub.Student_ID__c); 
                    mail.setSaveAsActivity(false);
                    mails.add(mail);                    
                    mapContextStuSubIdToStuProgramId.put(stuSub.Id, stuSub.Student_Program__c);
                }
            }
        }
        
        if (!mails.isEmpty()) {
         	// Send the emails and capture the results
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails, false);
            List<SendEmail.OutputResult> outputs = new List<SendEmail.OutputResult>();
            List<Task> taskList = new List<Task>();
            List<Student_Subscription__c> subList = new List<Student_Subscription__c>();
            List<Student_Program__c> studentProgramList = new List<Student_Program__c>();
            
            // For each email sent
            Integer mailIndex = 0;
            for (Messaging.SendEmailResult result: results) {
                SendEmail.OutputResult output = new SendEmail.OutputResult();
                output.relatedToId=mails[mailIndex].WhatId;
                output.isSuccess=result.isSuccess();
                outputs.add(output);
                
                if (result.isSuccess()) {
                    Task tk = new Task();
                    tk.Status = 'Completed';
                    tk.Subject = 'StudentInvoice';
                    tk.ActivityDate = Date.today();
                    tk.Description = mails[mailIndex].plainTextBody;
                    tk.WhatId = mails[mailIndex].WhatId;
                    taskList.add(tk);
                    
                    Student_Subscription__c sub = new Student_Subscription__c(Id=mails[mailIndex].WhatId, Invoice_Sent__c=true, Last_Invoice_Sent_Date__c=System.now());
                    subList.add(sub);
                    Student_Program__c sp = new Student_Program__c(Id=mapContextStuSubIdToStuProgramId.get(mails[mailIndex].WhatId), Last_Invoice_Sent_Date__c=System.now());
                    studentProgramList.add(sp);
                }
                mailIndex++;
            }
            if (!taskList.isEmpty()) {
                insert taskList;
            }
            if (!subList.isEmpty()) {
                update subList;
            }
            if (!studentProgramList.isEmpty()) {
                update studentProgramList;
            }
        }
    }
    
    public class MyCustomException extends Exception {
        
    }
    
    
}