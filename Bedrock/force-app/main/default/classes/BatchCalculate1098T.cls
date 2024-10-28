/************************************************************************************** 
Apex Class Name     : BatchCalculate1098T
Created Date        : 23th Sep 2019
Function            : Batch Class to caluculate the 1098T Values.
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                  
* Ravitej Varada            09/23/2019                Original Version
* Horacio Sanchez           09/14/2021                User Story 66781: L2: New Transaction Type for Alternate Payment
*************************************************************************************/
global class BatchCalculate1098T implements Database.Batchable<sObject>, Database.AllowsCallouts,Schedulable,Database.Stateful{
    public Exception[] errors = new Exception[0];
    private string processingYear;
    private boolean isTodayCutOffDate;
    private date cutOfDate ;
	private string thisYear; 
    global Database.QueryLocator start(Database.BatchableContext BC){
        isTodayCutOffDate = false;
        date todayDate = system.today();
        thisYear = string.valueOf(todayDate.year());
        processingYear = 'THIS_YEAR';
        
        //Retrieve Cut of date from Custom Setting
        cutOfDate = Script_Settings__c.getValues('Current Settings').X1098T_Cut_Of_Date__c;
        system.debug(cutOfDate);
        
        
        // Check if today is cut of date & to run 1098T script for current year or prior year
        If(todayDate.day() == cutOfDate.day() && todayDate.month()  == cutOfDate.month() ){
            system.debug('Cut Of date');
            thisYear = string.valueOf(todayDate.year()-1);
            processingYear = 'LAST_YEAR';
            isTodayCutOffDate = true;
        }
        
        system.debug('thisYear'+thisYear);
        
        String query = 'Select id, Total_Charges__c,Carry_Over_Amount__c ,Total_Payment__c,Student__c,Calculations_are_Up_to_Date__c , (Select id,Student_Subscription__r.start_date__c, Transaction_Type__c,Refund_Amount__c,Grant_Scholarship_Amount__c, Payment_Amount__c from Student_Transactions__r) from X1098T__c where Year__c =:thisYear';
        
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(SchedulableContext SC) { 
        BatchCalculate1098T objBatch = new BatchCalculate1098T(); 
        ID batchprocessid = Database.executeBatch(objBatch, 200);
    } 
    
    
    global void execute(Database.BatchableContext BC, List<X1098T__c> x1098List){
        
        try{
            Set<Id> conIdSet = new Set<Id>();  
            List<X1098T__c> x1098TToUpdate = new List<X1098T__c>();        
            List<contact> conListtoUpdate = new List<contact>();        
            Map<id,id> conmap = new map<id,id>();
            for(X1098T__c x1098Obj : x1098List){
                conIdSet.add(x1098Obj.Student__c); 
            }
            
            Map<Id,List<Student_Subscription__c>> consubMap = new Map<Id,List<Student_Subscription__c>>();
            Map<Id,decimal> conCarryOverAmountMap = new Map<Id,decimal>();
            List<Student_Subscription__c> stusubList = new List<Student_Subscription__c>(); 
            
            //Get all the SUB records for the processing year.
            string stusubQueryStr = 'Select id,Start_Date__c,Student_Program__r.Student__r.Carry_Over_Amount__c,Total_Miscellaneous_Adjustment__c,(Select id,Name, Transaction_Type__c,Refund_Amount__c,Grant_Scholarship_Amount__c, Transaction_Date__c ,Payment_Amount__c from Student_Payments__r),Student_Program__r.Student__c,Subscription_Price__c, List_Price__c, Total_Grant_Scholarship__c from Student_Subscription__c' 
                +' where Student_Program__r.Student__c IN :conIdSet' 
                +' AND Start_Date__c ='+ processingYear
                +' AND Subscription_Status__c in (\'RE = Registered\',\'WD = Subscription Withdrawal\',\'WM = Withdrawal- Maryland Student\',\'WN = Withdrawal-North Dakota Student\',\'WT = Withdrawal - Tennessee Student\')';
            
            
            system.debug('stusubQueryStr'+stusubQueryStr);
            stusubList = database.query(stusubQueryStr);
            
            
            system.debug('stusubList'+stusubList);
            //Retreive carryover amount from contact and map it to the contact record.
            for(Student_Subscription__c stusubObj : stusubList){
                if(consubMap.containsKey(stusubObj.Student_Program__r.Student__c)){
                    List<Student_Subscription__c> studentSubList = new List<Student_Subscription__c>();
                    studentSubList = consubMap.get(stusubObj.Student_Program__r.Student__c);
                    studentSubList.add(stusubObj);
                    consubMap.put(stusubObj.Student_Program__r.Student__c, studentSubList);
                }else{
                    consubMap.put(stusubObj.Student_Program__r.Student__c, new List<Student_Subscription__c>{stusubObj});
                }
                if(!conCarryOverAmountMap.containsKey(stusubObj.Student_Program__r.Student__c) && stusubObj.Student_Program__r.Student__r.Carry_Over_Amount__c != null){
                    conCarryOverAmountMap.put(stusubObj.Student_Program__r.Student__c, stusubObj.Student_Program__r.Student__r.Carry_Over_Amount__c);
                } 
            }
            
            system.debug('conCarryOverAmountMap'+conCarryOverAmountMap);
            
            for(X1098T__c x1098Obj : x1098List){
                
                Decimal totalCharges = 0;
                Decimal totalSubPrice = 0;
                Decimal totalMisc = 0;
                Decimal totalScholAndGrants = 0;
                Decimal totalScholAndGrantsPriorYear = 0;
                Decimal totalPriorYearAdj = 0;
                Decimal conCarryOverAmount = 0;
                Decimal totalPayments = 0;
                Decimal priorYearAdjustmentPayments = 0;
                Decimal priorYearAdjustmentRefunds = 0;
                
                //If Calculations_are_Up_to_Date__c = false - To populate all boxs logic 
                If(x1098Obj.Calculations_are_Up_to_Date__c == False){
                    system.debug('#####Calculations are Up to Date == FALSE');
                    if(!consubMap.isEmpty() && consubMap.containsKey(x1098Obj.Student__c) && consubMap.get(x1098Obj.Student__c) != null){
                        
                        for(Student_Subscription__c stusubObj : consubMap.get(x1098Obj.Student__c)){
                            totalSubPrice += stusubObj.Subscription_Price__c;
                            totalMisc += stusubObj.Total_Miscellaneous_Adjustment__c;
                            totalScholAndGrants += stusubObj.Total_Grant_Scholarship__c;
                        }
                        system.debug('>>>>>>totalSubPrice>>>>>'+totalSubPrice+'>>>>>>totalMisc>>>>>'+totalMisc+'>>>>>>totalScholAndGrants>>>>>'+totalScholAndGrants);
                        if(totalMisc < 0){    
                            totalMisc =    totalMisc * -1;
                        }
                        if(!conCarryOverAmountMap.isEmpty() && conCarryOverAmountMap.containsKey(x1098Obj.Student__c) && conCarryOverAmountMap.get(x1098Obj.Student__c)  != null){
                            conCarryOverAmount = conCarryOverAmountMap.get(x1098Obj.Student__c);
                        }
                        system.debug('>>>>>>totalMisc'+totalMisc+'>>>>>>>conCarryOverAmount'+conCarryOverAmount);
                    }
                    
                    
                    if(!x1098Obj.Student_Transactions__r.isEmpty() ){
                        Decimal payments = 0;
                        Decimal refunds = 0;
                        for(Student_Transaction__c stuTranObj : x1098Obj.Student_Transactions__r){
                            
                            if(stuTranObj.Transaction_Type__c != null && stuTranObj.Transaction_Type__c != ''){
                                if(stuTranObj.Transaction_Type__c == 'Refund to Student' || 
                                   stuTranObj.Transaction_Type__c == 'Refund to Third Party' ||
                                   stuTranObj.Transaction_Type__c == 'FinAid Refund to Student' && 
                                   stuTranObj.Refund_Amount__c != null)
                                {
                                    if((stuTranObj.Student_Subscription__r.start_date__c.year() == integer.valueOf(thisYear)) || 
                                       (stuTranObj.Student_Subscription__r.start_date__c.year() == integer.valueOf(thisYear)-1 && 
                                        stuTranObj.Refund_Amount__c > 0 )){
                                            refunds += stuTranObj.Refund_Amount__c;
                                        }else if(stuTranObj.Student_Subscription__r.start_date__c.year() == integer.valueOf(thisYear)-1 && 
                                                 stuTranObj.Refund_Amount__c < 0)
                                        {
                                            priorYearAdjustmentRefunds += stuTranObj.Refund_Amount__c;                                 
                                        }
                                    
                                }else if(stuTranObj.Transaction_Type__c == 'Payment - Payment Plan' ||
                                         stuTranObj.Transaction_Type__c == 'Post 9-11 Payment' ||
                                         stuTranObj.Transaction_Type__c == 'Alt Loan Student Credit' ||
                                         stuTranObj.Transaction_Type__c == 'Sponsor Payment' ||
                                         stuTranObj.Transaction_Type__c == 'FinAid Student Credit' ||
                                         stuTranObj.Transaction_Type__c == 'FinAid Payment' ||
                                         stuTranObj.Transaction_Type__c == 'FinAid Payment - Adjustment' ||
                                         stuTranObj.Transaction_Type__c == 'Payment - ACH/Check' ||
                                         stuTranObj.Transaction_Type__c == 'APM-TEMPO' ||
                                         stuTranObj.Transaction_Type__c == 'Payment - CC' &&  stuTranObj.Payment_Amount__c != null )
                                {
                                    if((stuTranObj.Student_Subscription__r.start_date__c.year() == integer.valueOf(thisYear)) ||  
                                       (stuTranObj.Student_Subscription__r.start_date__c.year() == integer.valueOf(thisYear)-1 && 
                                        stuTranObj.Payment_Amount__c > 0 )){ 
                                            payments += stuTranObj.Payment_Amount__c;                                 
                                        }else if(stuTranObj.Student_Subscription__r.start_date__c.year() == integer.valueOf(thisYear)-1 &&  
                                                 stuTranObj.Payment_Amount__c < 0) 
                                        {
                                            priorYearAdjustmentPayments += stuTranObj.Payment_Amount__c;                                 
                                        }
                                    
                                }else if(stuTranObj.Transaction_Type__c == 'Grant' || 
                                         stuTranObj.Transaction_Type__c == 'Scholarship' &&
                                         stuTranObj.Grant_Scholarship_Amount__c != null)
                                {
                                    if((stuTranObj.Student_Subscription__r.start_date__c.year() == integer.valueOf(thisYear)) || 
                                       (stuTranObj.Student_Subscription__r.start_date__c.year() == integer.valueOf(thisYear)-1 && 
                                        stuTranObj.Grant_Scholarship_Amount__c > 0 )){
                                            payments += stuTranObj.Grant_Scholarship_Amount__c;
                                        }else if(stuTranObj.Student_Subscription__r.start_date__c.year() == integer.valueOf(thisYear)-1 && 
                                                 stuTranObj.Grant_Scholarship_Amount__c < 0)
                                        {
                                            priorYearAdjustmentPayments += stuTranObj.Grant_Scholarship_Amount__c; 
                                            totalScholAndGrantsPriorYear += stuTranObj.Grant_Scholarship_Amount__c;
                                        }
                                }
                            }
                        }
                        system.debug('****** -----priorYearAdjustmentPayments'+priorYearAdjustmentPayments +
                                     '--------priorYearAdjustmentRefunds'+priorYearAdjustmentRefunds+
                                     '****** -----Payment_Amount__c'+payments +
                                     '--------Refund_Amount__c'+ refunds+
                                     '******1Subscription_Price__c'+totalSubPrice +
                                     '--------Total_Miscellaneous_Adjustment__c'+ totalMisc); 
                        
                        if((priorYearAdjustmentPayments  -   priorYearAdjustmentRefunds)< 0){
                            totalPriorYearAdj =  (priorYearAdjustmentPayments  -   priorYearAdjustmentRefunds) * -1;
                        }else{
                            totalPriorYearAdj =  priorYearAdjustmentPayments  -   priorYearAdjustmentRefunds;      
                        }  
                        
                        
                        totalCharges = (totalSubPrice  -  totalMisc) + conCarryOverAmount + totalPriorYearAdj;
                        
                        /*If((payments - refunds) > (totalSubPrice- totalMisc) ){
totalPayments = totalSubPrice- totalMisc;
}else{
totalPayments = payments - refunds;
}*/
                        
                        totalPayments = payments - refunds;
                        
                        system.debug('totalPriorYearAdj'+totalPriorYearAdj);  
                        system.debug('totalPayments'+totalPayments +'totalCharges'+totalCharges+'totalPriorYearAdj'+totalPriorYearAdj);  
                        
                        x1098Obj.Scholarships_grants_Prior_Year_Adjusts__c = totalScholAndGrantsPriorYear * -1;
                        x1098Obj.Total_Payment__c = totalPayments;
                        x1098Obj.Total_Charges__c = totalCharges;
                        x1098Obj.Total_Grants__c = totalScholAndGrants;
                        x1098Obj.Prior_Year_Adjustment__c = totalPriorYearAdj;                
                        x1098Obj.Calculations_are_Up_to_Date__c =true;
                        
                        If(isTodayCutOffDate && ( x1098Obj.Carry_Over_Amount__c == Null || x1098Obj.Carry_Over_Amount__c == 0)){
                            system.debug('##### isTodayCutOffDate--'+isTodayCutOffDate);
                            system.debug('##### Calculate the Carry over amount on 1098t--'); 
                            
                            If((totalCharges  - totalPayments) < 0) {
                                x1098Obj.Carry_Over_Amount__c  =  0;
                            } else{
                                x1098Obj.Carry_Over_Amount__c  = totalCharges  - totalPayments;
                            }
                            
                            conListtoUpdate.add(new contact(id=x1098Obj.Student__c, Carry_Over_Amount__c= x1098Obj.Carry_Over_Amount__c));
                        }
                        
                        x1098TToUpdate.add(x1098Obj);
                    }
                }
                //To populate carry over amount on 1098T and contact  on cut of day  
                else If(x1098Obj.Calculations_are_Up_to_Date__c && isTodayCutOffDate && ( x1098Obj.Carry_Over_Amount__c == Null || x1098Obj.Carry_Over_Amount__c == 0)&&
                        x1098Obj.Total_Charges__c != Null &&  x1098Obj.Total_Payment__c != Null ){
                            system.debug('x1098Obj'+x1098Obj+'##### Calculations_are_Up_to_Date__c'+x1098Obj.Calculations_are_Up_to_Date__c+'---'+x1098Obj.Total_Charges__c+'===='+x1098Obj.Total_Payment__c); 
                            system.debug('##### Cut of date If Condiiton'); 
                            
                            If((x1098Obj.Total_Charges__c  - x1098Obj.Total_Payment__c) <0) {
                                x1098Obj.Carry_Over_Amount__c  =  0;
                            } else{
                                x1098Obj.Carry_Over_Amount__c  = x1098Obj.Total_Charges__c  - x1098Obj.Total_Payment__c;
                            }
                            
                            conListtoUpdate.add(new contact(id=x1098Obj.Student__c,Carry_Over_Amount__c= x1098Obj.Carry_Over_Amount__c));
                            x1098TToUpdate.add(x1098Obj);      
                        }
            }
            
            If(!x1098TToUpdate.isEmpty()){ 
                database.Update(x1098TToUpdate);
            }
            
            If(!conListtoUpdate.isEmpty()){ 
                database.Update(conListtoUpdate);
            }
            
        }
        catch(exception e){
            System.debug('An exception occurred: ' + e.getMessage());
            errors.add(e);
            System.debug('errors'+errors);
            System.debug('errors'+errors.size());
        }
    }
    
    global void finish(Database.BatchableContext BC){
        //Schedule Batch to run on next cut of date and twice a year
        if(isTodayCutOffDate && !test.isRunningTest()){
            string processingYear = string.valueOf(Date.Today().year());
            string nextYear = string.valueOf(Date.Today().addYears(+1).year());
            System.schedule('Calculate_1098T_On_Cut_Off_Date_'+nextYear, '0 30 23 '+cutOfDate.day()+' '+cutOfDate.month()+' '+'?'+' '+nextYear, new BatchCalculate1098T());
            System.schedule('Calculate_1098T_On_half_Year_'+processingYear, '0 30 23 30 6 ? '+processingYear, new BatchCalculate1098T());
            System.schedule('Calculate_1098T_On_Anual_'+processingYear, '0 30 23 31 12 ? '+processingYear, new BatchCalculate1098T());
        }
        
    }
}