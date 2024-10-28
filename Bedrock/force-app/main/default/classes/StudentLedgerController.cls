/*******************************************************************
Name  : StudentLedgerController 
Author: Ravitej Varada (Laureate)
Date  : Oct 21, 2019
Description: Controller class for StudentLedger App

* Revision History
* Horacio Sanchez    -    09/14/2021    -    User Story 66781: L2: New Transaction Type for Alternate Payment
*************************************************************************/
public without sharing class StudentLedgerController {
    
    @AuraEnabled
    public Static contactWrapper getContactDetails(id oppId){
        contactWrapper conWrapper = new contactWrapper();
        string currentUserId = UserInfo.getUserId();
        contact con =  [select id,name,MailingStreet,MailingCity,Walden_Email__c,MailingState,MailingCountry,MailingPostalCode,CBL_Student_ID__c,SSN__c 
                        FROM contact where id=:oppId 
                        LIMIT 1 ];
        user usr= [select id,name, Profile.Name  from user where id= :currentUserId];
        system.debug('con'+con);
        If(con != null){
            conWrapper.con = con;
            if(con.SSN__c != null ){    
                if( usr.Profile.Name.Contains('Bursar')){
                    conWrapper.ssn = con.SSN__c;
                }else{
                    string ssn =con.SSN__c;
                    string mask   = 'XXX-XX-' + ssn.right(4);
                    conWrapper.ssn = mask;
                }
            }}
        
        
        return   conWrapper;  
    }
    
    @AuraEnabled
    public Static studentTransactionWrapper getStudentTrans(id oppId, date startdate, date enddate, string subterm, string program, string transType){
        system.debug('startdate----------------'+startdate+'----enddate---------'+enddate+'----subterm----'+subterm+'----program----'+program+'----transType----'+transType);
        Boolean isTransTypeFilterSelected = false;
        
        List<Student_Subscription__c> stuTransFiltersCond = new List<Student_Subscription__c> ();
        List<Student_Subscription__c> stuTrans = new List<Student_Subscription__c> ();
        
        
        string query =  'Select id,name ,CBL_Id__c,Student_program__r.Total_Outstanding_Balance__c,'+
            ' Current_Subscription_Balance__c,'+
            ' Student_program__r.Student_Full_Name__c,'+
            ' End_Date__c,Start_Date__c,Program_Name__c,'+
            ' Student_program__r.Student__r.Name,'+
            ' Student_Program__r.Name,'+
            ' Subscription_Price__c,createdDate,'+
            ' Student_Program__r.Program__r.ProductCode,Total_Payments_Received__c,Tuition__c,Tech_Fee__c,List_Price__c,'+
            ' (select id,name,Transaction_Note__c, Refund_Amount__c, Payment_Amount__c,Transaction_Type__c,'+
            ' Miscellaneous_Adjustment__c,Grant_Scholarship_Amount__c, Discount_Amount__c,transaction_date__c'+
            ' from Student_Payments__r WHERE Student_Subscription__r.student_program__r.Student__c  =:oppId ';
        
        stuTransFiltersCond  = database.query(query+') from Student_Subscription__c WHERE student_program__r.Student__c = :oppId');
        
        if (startdate != null){
            query += ' and transaction_date__c >=: startdate';
        }
        if (enddate != null){
            query += ' and transaction_date__c <=: enddate';
        }  
        
        if (transType != null && transType != ''){
            isTransTypeFilterSelected = true;
            query += ' and Transaction_Type__c =: transType';
        }
        
        query +=  ' ORDER BY Transaction_Date__c DESC) from Student_Subscription__c WHERE student_program__r.Student__c = :oppId';
        
        if (subterm != null){
            query += ' and name =: subterm';
        }        
        if (program != null){
            query += ' and Program_Name__c =: program';
        }
        /*if (startdate != null){
        query += ' and Start_date__c >=: startdate';
        } 
        if (enddate != null){
        query += ' and Start_date__c <=: enddate';
        }
        
        */
        
        query += ' Order BY CreatedDate DESC';
        
        system.debug('stuTransFiltersCond-----'+stuTransFiltersCond);
        system.debug('stuTransFiltersCond-----'+stuTransFiltersCond.size());
        
        system.debug('query'+query);
        
        //Query to fetch the Tran records based on filter conditions
        stuTrans = database.query(query); // 2subs // no trans 
        
        system.debug('stuTrans-----'+stuTrans.size());
        
        //Declaration of Filter values 
        set<string> subListNameSet =new  set<string>();
        set<string> programSet =new  set<string>();
        set<string> tranTypeSet =new  set<string>();
        
        decimal payments = 0;
        decimal subPrice = 0;
        decimal totalCharges = 0;
        integer Count = 0;
        decimal totalOutstanding = 0;
        
        
        studentTransactionWrapper stuTranWrapper = new studentTransactionWrapper();
        
        for(Student_Subscription__c sub: stuTransFiltersCond ){ 
            programSet.add(sub.Program_Name__c);
            
            //Populate subterm  related  Based on start Date and Program
            If(program != null){
                If(startdate == null  && enddate == null   && sub.Program_Name__c == program
                   || startdate != null  && enddate == null   && sub.Start_Date__c >= startdate && sub.Program_Name__c == program
                   || startdate == null  && enddate != null   && sub.Start_Date__c <= endDate && sub.Program_Name__c == program
                   || startdate != null  && enddate != null   && sub.Start_Date__c >= startdate &&  sub.Start_Date__c <= endDate && sub.Program_Name__c == program){
                       subListNameSet.add(sub.name );
                   }
                
            }else{
                
                If(startdate == null  && enddate == null 
                   || startdate != null  && enddate == null   && sub.Start_Date__c >= startdate 
                   || startdate == null  && enddate != null   && sub.Start_Date__c <= endDate 
                   || startdate != null  && enddate != null   && sub.Start_Date__c >= startdate &&  sub.Start_Date__c <= endDate )
                {
                    subListNameSet.add(sub.name );
                }
                
            }
            
            
            for(Student_transaction__c tran: sub.Student_Payments__r){ 
                
                //Populate Transaction type  related SUB Term or  program
                If(program != null){
                    If(startdate == null  && enddate == null  && subTerm == null && sub.Program_Name__c == program 
                       ||startdate != null  && enddate == null && subTerm == null  && tran.Transaction_date__C >= startdate && sub.Program_Name__c == program 
                       || startdate == null  && enddate != null  && subTerm == null  && tran.Transaction_date__C <= endDate && sub.Program_Name__c == program 
                       ||startdate != null  && enddate != null  && subTerm == null  && tran.Transaction_date__C >= startdate &&  tran.Transaction_date__C <= endDate && sub.Program_Name__c == program
                       || startdate == null  && enddate == null  && subTerm != null && sub.Program_Name__c == program && sub.Name == subTerm
                       || startdate != null  && enddate == null && subTerm != null  && tran.Transaction_date__C >= startdate && sub.Program_Name__c == program  && sub.Name == subTerm
                       || startdate == null  && enddate != null  && subTerm != null  && tran.Transaction_date__C <= endDate && sub.Program_Name__c == program  && sub.Name == subTerm
                       || startdate != null  && enddate != null  && subTerm != null  && tran.Transaction_date__C >= startdate &&  tran.Transaction_date__C <= endDate && sub.Program_Name__c == program && sub.Name == subTerm
                      ){
                          tranTypeSet.add(tran.Transaction_Type__c);   
                      }
                    
                }else{
                    
                    If(startdate == null  && enddate == null  && subTerm == null  
                       ||startdate != null  && enddate == null && subTerm == null  && tran.Transaction_date__C >= startdate  
                       || startdate == null  && enddate != null  && subTerm == null  && tran.Transaction_date__C <= endDate 
                       ||startdate != null  && enddate != null  && subTerm == null  && tran.Transaction_date__C >= startdate &&  tran.Transaction_date__C <= endDate 
                       || startdate == null  && enddate == null  && subTerm != null && sub.Name == subTerm
                       || startdate != null  && enddate == null && subTerm != null  && tran.Transaction_date__C >= startdate   && sub.Name == subTerm
                       || startdate == null  && enddate != null  && subTerm != null  && tran.Transaction_date__C <= endDate   && sub.Name == subTerm
                       || startdate != null  && enddate != null  && subTerm != null  && tran.Transaction_date__C >= startdate &&  tran.Transaction_date__C <= endDate   && sub.Name == subTerm
                      ){
                          tranTypeSet.add(tran.Transaction_Type__c);   
                      }
                }
                
                //Populate Transaction related related SUB Term Based on start Date
                If(program != null){
                    If( startdate != null  && enddate == null   && tran.Transaction_date__c >= startdate && sub.Program_Name__c == program
                       || startdate == null  && enddate != null   && tran.Transaction_date__C <= endDate && sub.Program_Name__c == program
                       || startdate != null  && enddate != null   && tran.Transaction_date__C >= startdate &&  tran.Transaction_date__C <= endDate && sub.Program_Name__c == program){
                           subListNameSet.add(sub.name );
                       }
                    
                }else{
                    
                    If( startdate != null  && enddate == null   && tran.Transaction_date__c >= startdate 
                       || startdate == null  && enddate != null   && tran.Transaction_date__C <= endDate 
                       || startdate != null  && enddate != null   && tran.Transaction_date__C >= startdate &&  tran.Transaction_date__C <= endDate )
                    {
                        subListNameSet.add(sub.name );
                    }
                    
                }
                
                
            }
        }
        
        Map<string,decimal> subMap = new   Map<string,decimal>();
        Map<string,decimal> stuProMap = new   Map<string,decimal>();
        List<studentTransactionList> stuTranWrapLst = new   List<studentTransactionList>();
        
        for(Student_Subscription__c sub: stuTrans ){//2. subs 
            
            for(Student_transaction__c tran: sub.Student_Payments__r){//trans
                
                decimal paymentAmount = 0.00;
                decimal chargesAmount = 0.00;
                studentTransactionList stuTranWrap = new studentTransactionList();
                stuTranWrap.studentName = sub.Student_Program__r.Student_Full_Name__c;
                stuTranWrap.cblId = sub.CBL_Id__c;
                stuTranWrap.programCode = sub.Student_Program__r.Program__r.ProductCode;
                stuTranWrap.subName = sub.Name;
                stuTranWrap.tranName = tran.Name;
                stuTranWrap.subStartDate = sub.Start_Date__c;
                stuTranWrap.tranDate = tran.Transaction_Date__c;
                stuTranWrap.tranType  = tran.Transaction_Type__c;
                stuTranWrap.tranNotes = tran.Transaction_Note__c;
                stuTranWrap.tranId = tran.id;
                
                
                if(tran.Transaction_Type__c == 'Payment - Payment Plan' ||
                   tran.Transaction_Type__c == 'Payment - CC' ||
                   tran.Transaction_Type__c == 'Payment - ACH/Check' ||
                   tran.Transaction_Type__c == 'FinAid Payment' ||
                   tran.Transaction_Type__c == 'FinAid Student Credit' ||
                   tran.Transaction_Type__c == 'Sponsor Payment' ||
                   tran.Transaction_Type__c == 'Alt Loan Student Credit' ||
                   tran.Transaction_Type__c == 'Write Off Small Balance' ||
                   tran.Transaction_Type__c == 'Post 9-11 Payment' ||
                   tran.Transaction_Type__c == 'Payment - Ability' ||
                   tran.Transaction_Type__c == 'Payment - Cedar' ||
                   tran.Transaction_Type__c == 'APM-TEMPO' ||
                   tran.Transaction_Type__c == 'FinAid Payment - Adjustment')
                {
                    
                    payments += tran.Payment_Amount__c;
                    paymentAmount = tran.Payment_Amount__c;
                    
                }
                else if(tran.Transaction_Type__c == 'Subscription Reduction'){
                    
                    payments =  tran.Discount_Amount__c ;
                    paymentAmount += tran.Discount_Amount__c;
                    
                }
                else if(tran.Transaction_Type__c == 'Refund to Student' ||
                        tran.Transaction_Type__c == 'FinAid Refund to Student' ||
                        tran.Transaction_Type__c == 'Refund to Third Party')
                {
                    
                    chargesAmount = tran.Refund_Amount__c ;
                    totalCharges += tran.Refund_Amount__c;
                }
                else if(tran.Transaction_Type__c == 'Tuition Adjustment')
                {
                    
                    chargesAmount=  tran.Miscellaneous_Adjustment__c ;
                    totalCharges += tran.Miscellaneous_Adjustment__c;
                    
                }
                else if(tran.Transaction_Type__c == 'Adjustment – Waiver')
                {
                    
                    payments += tran.Miscellaneous_Adjustment__c;
                    paymentAmount = tran.Miscellaneous_Adjustment__c;
                    
                }
                else if(tran.Transaction_Type__c == 'Scholarship' ||
                        tran.Transaction_Type__c == 'Grant')
                {
                    
                    paymentAmount = tran.Grant_Scholarship_Amount__c;
                    payments += tran.Grant_Scholarship_Amount__c;              
                    
                }
                
                stuTranWrap.charge = chargesAmount;            
                stuTranWrap.paymentAmount = paymentAmount;
                stuTranWrapLst.add(stuTranWrap);
                
                
                if(!subMap.containsKey(sub.Name)){
                    if(sub.Subscription_Price__c != null){
                        subPrice += sub.Subscription_Price__c;
                    }
                    subMap.put(sub.Name, 0 );
                }
                
                
                if(!stuProMap.containsKey(sub.Student_Program__r.Name)){
                    if(sub.Student_Program__r.Total_Outstanding_Balance__c != null){
                        totalOutstanding += sub.Student_Program__r.Total_Outstanding_Balance__c;
                    }
                    stuProMap.put(sub.Student_Program__r.Name, 0 );
                }
                
                Count ++;
                
            }
            
            date createdDate = date.newinstance(sub.CreatedDate.year(), sub.CreatedDate.month(), sub.CreatedDate.day());
             
             
            //Tech Fee and Tuition Fee
            If(startdate != null  && enddate != null && createdDate >= startdate  && createdDate <= endDate ||
               startdate != null  && enddate == null && createdDate >= startdate ||
               startdate == null  && enddate != null && createdDate <= enddate ||
               startdate == null  && enddate == null ){//&& transType == null){
                   if((sub.Tech_Fee__c != null && sub.Tech_Fee__c >0 && isTransTypeFilterSelected == false)){ 
                       studentTransactionList stuTranWrp = new studentTransactionList();
                       stuTranWrp.studentName = sub.Student_Program__r.Student_Full_Name__c;
                       stuTranWrp.cblId = sub.CBL_Id__c;
                       stuTranWrp.programCode = sub.Student_Program__r.Program__r.ProductCode;
                       stuTranWrp.subName = sub.Name;
                       stuTranWrp.tranName =  ''; 
                       stuTranWrp.subStartDate = date.valueOf(sub.Start_Date__c);
                       stuTranWrp.tranDate = date.valueOf(sub.createdDate);
                       stuTranWrp.tranType  = 'Tech Fee';
                       stuTranWrp.tranNotes = 'Tech Fee';
                       stuTranWrp.charge = sub.Tech_Fee__c;            
                       stuTranWrp.paymentAmount = 0;      
                       stuTranWrp.tranId = '';
                       
                       totalCharges += sub.Tech_Fee__c;
                       
                       stuTranWrapLst.add(stuTranWrp);
                       Count ++;
                   }
                   if((sub.Tuition__c  != null &&  sub.Tuition__c  >0 &&  isTransTypeFilterSelected == false ) ){
                       studentTransactionList stuTranWrp1 = new studentTransactionList();
                       stuTranWrp1.studentName = sub.Student_Program__r.Student_Full_Name__c;
                       stuTranWrp1.cblId = sub.CBL_Id__c;
                       stuTranWrp1.programCode = sub.Student_Program__r.Program__r.ProductCode;
                       stuTranWrp1.subName = sub.Name;
                       stuTranWrp1.tranName =   ''; 
                       stuTranWrp1.subStartDate =  date.valueOf(sub.Start_Date__c);
                       stuTranWrp1.tranDate = date.valueOf(sub.createdDate);
                       stuTranWrp1.tranType  = 'Tution';
                       stuTranWrp1.tranNotes = 'Tution';   
                       stuTranWrp1.charge = sub.Tuition__c;  
                       stuTranWrp1.paymentAmount = 0 ;  
                       stuTranWrp1.tranId = '';
                       totalCharges += sub.Tuition__c;
                       stuTranWrapLst.add(stuTranWrp1);
                       Count ++;
                   }
               }
        }
        
        
        stuTranWrapper.transactionListWrapper = stuTranWrapLst;
        stuTranWrapper.payments = payments;
        stuTranWrapper.subPrice = subPrice;
        stuTranWrapper.subList = subListNameSet;
        stuTranWrapper.programList = programSet;
        stuTranWrapper.totalOutstanding = totalOutstanding;
        stuTranWrapper.recordCount = Count;
        stuTranWrapper.tranType = tranTypeSet;
        stuTranWrapper.totalCharges = totalCharges;
        
        
        
        system.debug('stuTranWrapper'+stuTranWrapper);
        system.debug('tranTypeSet'+tranTypeSet);
        system.debug('stuTranWrapper'+stuTranWrapper.programList);
        system.debug('stuTranWrapper'+stuTranWrapper.transactionListWrapper);
        
        
        
        return stuTranWrapper;
        
        
        
    }
    
    //Wrapper class to populate Summary/count/filter cond values.
    public class studentTransactionWrapper {
        @AuraEnabled public studentTransactionList[] transactionListWrapper {get;set;}
        @AuraEnabled public decimal payments{get;set;}
        @AuraEnabled public decimal totalCharges{get;set;}
        @AuraEnabled public decimal subPrice{get;set;}
        @AuraEnabled public integer recordCount{get;set;}
        @AuraEnabled public decimal totalOutstanding{get;set;}
        @AuraEnabled public set<string> programList{get;set;}
        @AuraEnabled public set<string> subList{get;set;}
        @AuraEnabled public set<string> tranType{get;set;}
    }
    
    //Student Transaction records wrapper class
    public class contactWrapper {
        @AuraEnabled public string ssn{get;set;}
        @AuraEnabled public contact con{get;set;}
    }
    
    //Student Transaction records wrapper class
    public class studentTransactionList {
        @AuraEnabled public string studentName{get;set;}
        @AuraEnabled public string tranId{get;set;}
        @AuraEnabled public string cblId{get;set;}
        @AuraEnabled public string programCode{get;set;}
        @AuraEnabled public string subName{get;set;}
        @AuraEnabled public string tranName{get;set;}
        @AuraEnabled public date subStartDate{get;set;}   
        @AuraEnabled public date tranDate{get;set;}
        @AuraEnabled public string tranType{get;set;}
        @AuraEnabled public decimal charge{get;set;}
        @AuraEnabled public decimal paymentAmount{get;set;}
        @AuraEnabled public string tranNotes{get;set;}
        
    }
}