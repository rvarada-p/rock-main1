public class MyGroupAssignmentPopUpWindow
{
     public String suc {get; set;}
     public String mgaId {get; set;}
     public Customer_Support_Team__c cst {get; set;}
     public Boolean allgr {get; set;}
     public MyGroupAssignmentPopUpWindow()
     {
         mgaId = ApexPages.currentPage().getParameters().get('id');
         cst = new Customer_Support_Team__c();
         if(mgaId != null && mgaId != '')
         {
            cst = [select id, Out_Of_Office_Start_Date__c, Out_Of_Office_End_Date__c from Customer_Support_Team__c where id=: mgaId limit 1]; 
         }     
         allgr = false;
     }
     public PageReference saveobj()
     {
         try
         {
             if(mgaId != null && mgaId != '')
             {
                 if(allgr == true)
                 {
                     List<Customer_Support_Team__c> MyGroups = [SELECT Out_Of_Office_Start_Date__c, Out_Of_Office_End_Date__c FROM Customer_Support_Team__c
                                                                 WHERE User__c =: UserInfo.getUserId()];  
                     for(Customer_Support_Team__c a: MyGroups)   
                     {
                         a.Out_Of_Office_Start_Date__c = cst.Out_Of_Office_Start_Date__c;
                         a.Out_Of_Office_End_Date__c = cst.Out_Of_Office_End_Date__c;
                     }       
                     update MyGroups;
                     suc = 'Ok!';                               
                 }
                 else
                 {
                     update cst;
                     suc = 'Ok!';
                 }
             }              
         }
         catch(Exception e)
         {
             //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
         }     
         return null;
     }
}