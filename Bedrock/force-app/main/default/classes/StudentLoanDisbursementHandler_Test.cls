/*******************************************************************
Name  : StudentLoanDisbursementHandler_Test
Author: Vinay (Appirio)
Date  : May 15, 2015
Description: Test Class for StudentLoanDisbursementHandler
*************************************************************************/
@isTest
private class StudentLoanDisbursementHandler_Test {

  /*static testMethod void testStudentLoanDisbursement() {
    
    String recTypeName = 'Walden';
    Integer numberOfSubscriptions = 5;
    Decimal totalListPrice = 0;  
    List<Student_Subscription__c> studentSubs = new List<Student_Subscription__c>();
    List<Id> studentSubscriptionIds = new List<Id>();  
    Account acc = TestDataGenerator.createAccount(True);
    Contact con = TestDataGenerator.createContact(acc, true);
    Opportunity oppty = TestDataGenerator.createOpportunity(acc.id, con.id, recTypeName, True); 
    PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, recTypeName, True);
    Student_Program__c sp = TestDataGenerator.createStudentProgram(oppty, con.id, recTypeName, false);
    sp.IsStudentProgramActive__c = true;
    insert sp;  
    
    Date loanStartDate = system.today() - 100;
    Date asOfDate = system.today();
    Date loanEndDate = system.today() + 25;
    Decimal actualRemainingLoanAmount = 0;
    Decimal actualTotalLoanPaymentAmount = 0;
      
    for(Integer i = 0; i < numberOfSubscriptions + 2; i++) {
      Student_Subscription__c subs = new Student_Subscription__c();
      subs = TestDataGenerator.createStudentSubscription(sp, pb, recTypeName, False);
      subs.List_Price__c = 2000 + 100 * i;
      if(i < numberOfSubscriptions) {
        totalListPrice += subs.List_Price__c;  
        subs.start_date__c = system.today() - 10;
        subs.End_Date__c = system.today() + 10;  
      } else if(i == numberOfSubscriptions) {
        subs.start_date__c = loanStartDate - 10;  
        subs.start_date__c = loanEndDate - 10;
      } else {
        subs.start_date__c = loanStartDate +10;  
        subs.start_date__c = loanEndDate + 10;      
      }
      studentSubs.add(subs);  
        
    }
    
    insert studentSubs;
    
      for(Student_Subscription__c stuSubs : studentSubs) {
        studentSubscriptionIds.add(stuSubs.id);
      }  
      
    test.startTest();
      //loanAmount1, loanAmount2 and loanAmount3 should be positive
      Decimal loanAmount1 = 1000;
      Decimal loanAmount2 = 2000;
      Decimal loanAmount3 = totalListPrice - loanAmount1 - loanAmount2 ;
      
      Student_Loan_Disbursement__c loanDisbursement = TestDataGenerator.createStudentLoanDisbursement(sp.id, loanAmount1, loanStartDate, asOfDate, loanEndDate, True);
      Student_Loan_Disbursement__c loanDisbursement1 = TestDataGenerator.createStudentLoanDisbursement(sp.id, loanAmount2, loanStartDate, asOfDate, loanEndDate, True );
      
      actualRemainingLoanAmount = fetchRemainingLoanBalance(sp.id);
      actualTotalLoanPaymentAmount = fetchTotalLoanPaymentAmount(studentSubscriptionIds);
      
      Decimal expectedRemainingLoanAmount = (loanAmount1 + loanAmount2) > totalListPrice ? ((loanAmount1 + loanAmount2) - totalListPrice) : 0;
      system.assertEquals(expectedRemainingLoanAmount, actualRemainingLoanAmount);
      
      Decimal expectedLoanPaymentAmount = (loanAmount1 + loanAmount2) > totalListPrice ? totalListPrice: (loanAmount1 + loanAmount2);
      system.assertEquals(expectedLoanPaymentAmount, actualTotalLoanPaymentAmount);
      
      Student_Loan_Disbursement__c loanDisbursement2 = TestDataGenerator.createStudentLoanDisbursement(sp.id, loanAmount3, loanStartDate, asOfDate, loanEndDate, True );
      
      actualRemainingLoanAmount = fetchRemainingLoanBalance(sp.id);
      actualTotalLoanPaymentAmount = fetchTotalLoanPaymentAmount(studentSubscriptionIds);
      
      expectedRemainingLoanAmount = (loanAmount1 + loanAmount2 + loanAmount3) > totalListPrice? ((loanAmount1 + loanAmount2 + loanAmount3) - totalListPrice) : 0;
      system.assertEquals(expectedRemainingLoanAmount, actualRemainingLoanAmount);
      
      expectedLoanPaymentAmount = (loanAmount1 + loanAmount2 + loanAmount3) > totalListPrice ? totalListPrice: (loanAmount1 + loanAmount2 + loanAmount3);
      system.assertEquals(expectedLoanPaymentAmount, actualTotalLoanPaymentAmount);
    test.stopTest();
  }
    
    static testmethod void testNegativeDisbursment() {
    
	    String recTypeName = 'Walden';
	    Integer numberOfSubscriptions = 2;
	    Decimal totalListPrice = 0;  
	    List<Student_Subscription__c> studentSubs = new List<Student_Subscription__c>();
	    List<Id> studentSubscriptionIds = new List<Id>();  
	    Account acc = TestDataGenerator.createAccount(True);
	    Contact con = TestDataGenerator.createContact(acc, true);
	    Opportunity oppty = TestDataGenerator.createOpportunity(acc.id, con.id, recTypeName, True); 
	    PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, recTypeName, True);
	    Student_Program__c sp = TestDataGenerator.createStudentProgram(oppty, con.id, recTypeName, false);
	    sp.IsStudentProgramActive__c = false;
	    insert sp;  
	    
	    Date loanStartDate = system.today() - 100;
	    Date asOfDate = system.today();
	    Date loanEndDate = system.today() + 25;
	    Decimal actualRemainingLoanAmount = 0;
	    Decimal actualTotalLoanPaymentAmount = 0;
	      
	    for(Integer i = 0; i < numberOfSubscriptions + 2; i++) {
	      Student_Subscription__c subs = new Student_Subscription__c();
	      subs = TestDataGenerator.createStudentSubscription(sp, pb, recTypeName, False);
	      subs.List_Price__c = 2000 + 100 * i;
	      if(i < numberOfSubscriptions) {
	        totalListPrice += subs.List_Price__c;  
	        subs.start_date__c = system.today() - 10;
	        subs.End_Date__c = system.today() + 10;  
	      } else if(i == numberOfSubscriptions) {
	        subs.start_date__c = loanStartDate - 10;  
	        subs.start_date__c = loanEndDate - 10;
	      } else {
	        subs.start_date__c = loanStartDate +10;  
	        subs.start_date__c = loanEndDate + 10;      
	      }
	      studentSubs.add(subs);  
	        
	    }
	    
	    insert studentSubs;
	    
	      for(Student_Subscription__c stuSubs : studentSubs) {
	        studentSubscriptionIds.add(stuSubs.id);
	      }  
	      
	    test.startTest();
	      //loanAmount1, loanAmount2 and loanAmount3 should be positive
	      Decimal loanAmount1 = -1000;
	      Decimal loanAmount2 = -600;
	      Decimal loanAmount3 = totalListPrice - loanAmount1 - loanAmount2 ;
	      
	      Student_Loan_Disbursement__c loanDisbursement = TestDataGenerator.createStudentLoanDisbursement(sp.id, loanAmount1, loanStartDate, asOfDate, loanEndDate, True );
	      Student_Loan_Disbursement__c loanDisbursement1 = TestDataGenerator.createStudentLoanDisbursement(sp.id, loanAmount2, loanStartDate, asOfDate, loanEndDate, True );
	      
	     test.stopTest();
	    	
    }
    
    static Decimal fetchRemainingLoanBalance(Id studentProgramId) {
      Decimal remainingAmount = 0;
      for(Student_Loan_Disbursement__c stuLoanDis : [SELECT Id, Remaining_Balance__c FROM Student_Loan_Disbursement__c where Student_Program__c = : studentProgramId]) {
        remainingAmount += stuLoanDis.Remaining_Balance__c;
      }
      return remainingAmount;   
    } 
    
    static Decimal fetchTotalLoanPaymentAmount(List<Id> studentSubscriptionIds) {
      Decimal totalLoanPaymentAmount = 0;
      for(Student_Transaction__c stuTrans : [SELECT id, Payment_Amount__c, Refund_Amount__c, Student_Loan_Disbursement__c FROM Student_Transaction__c WHERE Student_Subscription__c IN : studentSubscriptionIds]) {
        if (stuTrans.Payment_Amount__c != null)
          totalLoanPaymentAmount += stuTrans.Payment_Amount__c;   
        if (stuTrans.Refund_Amount__c != null)
          totalLoanPaymentAmount += stuTrans.Refund_Amount__c;   
      } 
      return totalLoanPaymentAmount;  
    }*/

    static testMethod void testStudentLoanDisbursement() {
    
        String recTypeName = 'Walden';
        Integer numberOfSubscriptions = 5;
        Decimal totalListPrice = 0;  
        List<Student_Subscription__c> studentSubs = new List<Student_Subscription__c>();
        List<Id> studentSubscriptionIds = new List<Id>();  
        Account acc = TestDataGenerator.createAccount(True);
        Contact con = TestDataGenerator.createContact(acc, true);
        Product2 parentProd = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', false);
        prod.Parent_Program__c = parentProd.Id;
        insert prod;
        Opportunity oppty = TestDataGenerator.createOpportunity(acc.id, con.id, recTypeName, True); 
        PriceBook2 pb = TestDataGenerator.createSubscrptPricebook('Pricebook for Opportunity', 6, recTypeName, True);
        Student_Program__c sp = TestDataGenerator.createStudentProgram(oppty, con.id, recTypeName, false);
        sp.IsStudentProgramActive__c = true;
        sp.Program__c = prod.id;
        insert sp;        
        
        Date loanStartDate = system.today() - 100;
        Date asOfDate = system.today();
        Date loanEndDate = system.today() + 25;
        Decimal actualRemainingLoanAmount = 0;
        Decimal actualTotalLoanPaymentAmount = 0;
          
        for(Integer i = 0; i < numberOfSubscriptions + 2; i++) {
          	Student_Subscription__c subs = new Student_Subscription__c();
          	subs = TestDataGenerator.createStudentSubscription(sp, pb, recTypeName, False);
          	subs.List_Price__c = 2000 + 100 * i;
          	if (i < numberOfSubscriptions) {
            	totalListPrice += subs.List_Price__c;  
            	subs.start_date__c = system.today() - 10;
            	subs.End_Date__c = system.today() + 10;  
          	} else if(i == numberOfSubscriptions) {
            	subs.start_date__c = loanStartDate - 10;  
            	subs.start_date__c = loanEndDate - 10;
          	} else {
            	subs.start_date__c = loanStartDate +10;  
            	subs.start_date__c = loanEndDate + 10;      
          	}
          	studentSubs.add(subs);  
            
        }
        
        insert studentSubs;
        
        for(Student_Subscription__c stuSubs : studentSubs) {
        	studentSubscriptionIds.add(stuSubs.id);
        }
          
        test.startTest();
        
        Student_Program__c currentStudentProgram = [SELECT Id, Total_Outstanding_Balance__c FROM Student_Program__c WHERE Id = :sp.id];
        List<Student_Subscription__c> currentStudentSubscriptionList = [SELECT Id, Start_Date__c, End_Date__c, Current_Subscription_Balance__c FROM Student_Subscription__c WHERE student_program__c = :sp.id];
        Set<Id> currentStudentSubscriptionIdSet = new Set<Id>();
        for (Student_Subscription__c ss : currentStudentSubscriptionList) {
            currentStudentSubscriptionIdSet.add(ss.Id);
        }
        System.debug('*****: ' + currentStudentProgram);
        System.debug('*****: ' + currentStudentSubscriptionList);
        
        //Student_Loan_Disbursement__c loanDisbursement = TestDataGenerator.createStudentLoanDisbursement(sp.id, loanAmount1, loanStartDate, asOfDate, loanEndDate, True);
        
        Student_Loan_Disbursement__c loan1 = new Student_Loan_Disbursement__c(Student_Program__c = sp.id, 
                                                                             Disbursement_Amount__c = 1000, 
                                                                             Loan_Start_Date__c = loanStartDate,
                                                                             As_of_Date__c = asOfDate,
                                                                             Loan_End_Date__c = loanEndDate,
                                                                             Loan_ID__c = '623449081U19G25042001',
                                                                             Disbursement_Number__c = 1,
                                                                             Unique_Key__c = 'Key' + String.valueOf(math.random()),
                                                                             Fund_Name_Long__c = 'Federal Direct Unsubsidized Loan');
        
        insert loan1;
        Student_Loan_Disbursement__c loan2 = new Student_Loan_Disbursement__c(Student_Program__c = sp.id, 
                                                                             Disbursement_Amount__c = 25000, 
                                                                             Loan_Start_Date__c = loanStartDate,
                                                                             As_of_Date__c = asOfDate,
                                                                             Loan_End_Date__c = loanEndDate,
                                                                             Loan_ID__c = '623449081U19G25042002',
                                                                             Disbursement_Number__c = 1,
                                                                             Unique_Key__c = 'Key' + String.valueOf(math.random()),
                                                                             Fund_Name_Long__c = 'Federal Direct Subsidized Loan');
        insert loan2;
        
        List<Student_Transaction__c> studentTransactionList = [SELECT Id, Student_Subscription__r.Name, Transaction_Type__c, Transaction_Note__c, Payment_Amount__c, Refund_Amount__c 
                                                               FROM Student_Transaction__c 
                                                               WHERE Student_Subscription__c IN :currentStudentSubscriptionIdSet];
        System.debug('+++++: ' + studentTransactionList);
        
        Student_Loan_Disbursement__c loan3 = new Student_Loan_Disbursement__c(Student_Program__c = sp.id, 
                                                                             Disbursement_Amount__c = -1000, 
                                                                             Loan_Start_Date__c = loanStartDate,
                                                                             As_of_Date__c = asOfDate,
                                                                             Loan_End_Date__c = loanEndDate,
                                                                             Loan_ID__c = '623449081U19G25042001',
                                                                             Disbursement_Number__c = 1,
                                                                             Unique_Key__c = 'Key' + String.valueOf(math.random()),
                                                                             Fund_Name_Long__c = 'Federal Direct Unsubsidized Loan');
        insert loan3;
        
        Student_Loan_Disbursement__c loan4 = new Student_Loan_Disbursement__c(Student_Program__c = sp.id, 
                                                                             Disbursement_Amount__c = -25000, 
                                                                             Loan_Start_Date__c = Date.newInstance(2020, 11, 19),
                                                                             As_of_Date__c = asOfDate,
                                                                             Loan_End_Date__c = Date.newInstance(2021, 3, 19),
                                                                             Loan_ID__c = '623449081U19G25042002',
                                                                             Disbursement_Number__c = 1,
                                                                             Unique_Key__c = 'Key' + String.valueOf(math.random()),
                                                                             Fund_Name_Long__c = 'Federal Direct Subsidized Loan');
        insert loan4;
        test.stopTest();
        
	}
}