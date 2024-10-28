/*******************************************************************
Name  : StudentSubscriptionExemptionHelper
Author: Sarah Khalid
Date  : April 6, 2016
Description: Handler class for the Trigger StudentSubscriptionExemptionTrigger
*************************************************************************/

public with sharing class StudentSubscriptionExemptionHelper {
    
    public void processExemptionRules(list<Student_Subscription_Exemptions__c > newStudentSubscriptionExemptions) {  
        
        System.debug('In Processing Excemption Rules');     
        //list for Student Subscription Exemptions against which a Student Transaction will be created
        list<Student_Subscription_Exemptions__c> studentSubscriptionExemptionTransactions = new list<Student_Subscription_Exemptions__c>();
        
        Set<Id> priceBookIdSet = new   Set<Id>();
        Set<Id> productIdSet = new   Set<Id>();
        
        //Apply the automation rules
        for(Student_Subscription_Exemptions__c exemption : newStudentSubscriptionExemptions) {
            
           
                priceBookIdSet.add(exemption.Student_Subscription__r.Term_Price_Book__c);
                productIdSet.add(exemption.Student_Discount__r.Student_Program__r.Program__r.Parent_Program__c);
           
            //If the Exemption is for the life of the program
            if(exemption.Student_Discount__r.Life_of_Program__c == true && (exemption.Student_Discount__r.Percent_Discount__c!=null || exemption.Student_Discount__r.Flat_Rate_Amount__c!=null) ) {
                studentSubscriptionExemptionTransactions.add(exemption);
            }
            //If the Exemption is only for a specified number of terms
            else if(exemption.Student_Discount__r.no_of_Terms__c!=null &&  exemption.Student_Discount__r.no_of_Terms__c!=0 && 
                    (exemption.Student_Discount__r.no_of_Terms__c > exemption.Student_Discount__r.no_of_Terms_Exemption_Applied__c || exemption.Student_Discount__r.no_of_Terms_Exemption_Applied__c == null) && 
                    (exemption.Student_Discount__r.Percent_Discount__c!=null || exemption.Student_Discount__r.Flat_Rate_Amount__c!=null) ) {
                        studentSubscriptionExemptionTransactions.add(exemption);
                    }   
        }
        system.debug('studentSubscriptionExemptionTransactions'+studentSubscriptionExemptionTransactions);
        
        
        
        
        Map<id,PricebookEntry> PriceBookWithPBEntryMap = new  Map<id,PricebookEntry>();
        for(PricebookEntry entry: [Select id,name, ProductCode, Product2Id  , IsActive , Pricebook2Id , UnitPrice , Available_for_Existing_Students__c, Tuition__c, Tech_Fee__c from PricebookEntry where  Pricebook2Id In: priceBookIdSet AND Product2Id in:productIdSet  ]){
            
            PriceBookWithPBEntryMap.put(entry.Pricebook2Id,entry);
        }
        
        if(studentSubscriptionExemptionTransactions.size()>0) {
            processStudentSubscriptionExemptionTransactions(studentSubscriptionExemptionTransactions, PriceBookWithPBEntryMap);
        }
    }
    
    //Iterates over a list of Student Subscription Excemptions and creates a Student Transaction against them
    public void processStudentSubscriptionExemptionTransactions(list<Student_Subscription_Exemptions__c > studentSubscriptionExemptions,   Map<id,PricebookEntry> PriceBookWithPBEntryMap ) {
        
        system.debug('progWithPriceBookEntryMap'+PriceBookWithPBEntryMap);
         
        //List of Student Transactions to be inserted
        list<Student_Transaction__c> stuTrans = new list<Student_Transaction__c>();
        
        //List of Student Discounts that could potentially be updated to reflect new # of terms applied
        list<Student_Discount__c> studentDiscounts = new list<Student_Discount__c>();
        
        for(Student_Subscription_Exemptions__c s : studentSubscriptionExemptions) {
            
            decimal tuitionFee = 0;
            decimal techFee = 0;
            string feeType = s.Student_Discount__r.Exemption__r.Fee_Type__c;
            if(PriceBookWithPBEntryMap.containsKey(s.Student_Subscription__r.Term_Price_Book__c)){
                tuitionFee =  PriceBookWithPBEntryMap.get(s.Student_Subscription__r.Term_Price_Book__c).Tuition__c;
                techFee =  PriceBookWithPBEntryMap.get(s.Student_Subscription__r.Term_Price_Book__c).Tech_Fee__c;
                
                system.debug('tuitionFee'+tuitionFee);
                system.debug('techFee'+techFee);
            }
            
            
            Decimal listPrice = 0;
            if(feeType == 'Tuition'){
                listPrice = tuitionFee;
            }else if(feeType == 'Tech Fee'){
                listPrice = techFee;
            }else{
                listPrice = s.Student_Subscription__r.List_Price__c;
            }
            
            Decimal discountAmount = 0.0;
            
            if (listPrice == null) listPrice = 0;
            if (s.Student_Discount__r.Flat_Rate_Amount__c > 0) {
                discountAmount = s.Student_Discount__r.Flat_Rate_Amount__c;
            }
            else if (s.Student_Discount__r.Percent_Discount__c > 0) {
                discountAmount = s.Student_Discount__r.Percent_Discount__c * listPrice / 100;
            }
            else
                discountAmount = 0.0;
            
            Decimal noOfTermsApplied = 0;
            
            
            
            //Increment Counter for # terms exemption applied on the Student Discount object
            if(s.Student_Discount__r.no_of_Terms__c!=null && s.Student_Discount__r.no_of_Terms__c > 0) {
                
                if(s.Student_Discount__r.no_of_Terms_Exemption_Applied__c == null) {
                    noOfTermsApplied = 1;
                }
                else {
                    noOfTermsApplied = s.Student_Discount__r.no_of_Terms_Exemption_Applied__c + 1;
                }
                Student_Discount__c sd = new Student_Discount__c(Id = s.Student_Discount__c, no_of_Terms_Exemption_Applied__c = noOfTermsApplied);
                studentDiscounts.add(sd);
                
            }
            
            
            
            
            
            string transactionType = '';
            If(s.Student_Discount__r.Exemption_Category__c == 'Grant'){
                transactionType = 'Grant';
            }else If(s.Student_Discount__r.Exemption_Category__c == 'Scholarship'){
                transactionType = 'Scholarship';
            }else{
                transactionType = 'Subscription Reduction';
            }
            
            if(transactionType == 'Scholarship' || transactionType == 'Grant'){
                stuTrans.add(new Student_Transaction__c(Student_Subscription__c = s.Student_Subscription__c, Transaction_Type__c = transactionType ,
                                                        Transaction_Date__c = s.Student_Subscription__r.Start_Date__c, Grant_Scholarship_Amount__c  = discountAmount, Transaction_Note__c = s.Student_Discount__r.Exemption_Description__c));
                
            }else{stuTrans.add(new Student_Transaction__c(Student_Subscription__c = s.Student_Subscription__c, Transaction_Type__c = transactionType ,
                                                          Transaction_Date__c = s.Student_Subscription__r.Start_Date__c, Discount_Amount__c = discountAmount, Transaction_Note__c = s.Student_Discount__r.Exemption_Description__c));
                 }
        } 
        if(stuTrans.size()>0) {
            insert stuTrans;
        }
        if(studentDiscounts.size()>0) {
            update studentDiscounts;
        }
    }
    
    /*
    //Check if the exemption meets the application eligibility requirements    
    public boolean meetsApplicationEligibility(String exemptionCategory, String exemptionProgram, String subscriptionProgram, Date subscriptionStartDate, Date exemptionStartDate, Date exemptionEndDate) {
        System.debug('In meetsApplicationEligibility method ');
        System.debug('subscriptionStartDate: ' + subscriptionStartDate);
        System.debug('exemptionStartDate: ' + exemptionStartDate);
        System.debug('exemptionEndDate: ' + exemptionEndDate);
        System.debug('exemptionProgram: ' + exemptionProgram);
        System.debug('subscriptionProgram: ' + subscriptionProgram);
        
    boolean meetsEligibility = false;
    
    //If standard reduction then we don't need to apply eligibility requirements
    if(exemptionCategory == 'Standard Reduction') {
        meetsEligibility = true;
    }   
    //For Limited-time savings either program OR start/end dates need to be specified
    else if(exemptionCategory == 'Limited-Time Savings') {      
        if(exemptionProgram == null && (exemptionStartDate == null && exemptionEndDate == null)) {
            meetsEligibility = false;
        }
        //If there is no program specified or the subscription program matches the program at the exemption level and the subscription start date is within range of the exemption start and end term dates
        else if (exemptionProgram!=null && subscriptionProgram == exemptionProgram) {
            meetsEligibility = true;
        }
        else if(exemptionProgram==null && subscriptionStartDate >= exemptionStartDate && subscriptionStartDate <=exemptionEndDate) {
            meetsEligibility = true;
        }
    }
    return meetsEligibility;

  } 
    */
}