public class CustomerSupportTeamReset
{ 
    public list<Customer_Support_Team__c> listCustomerSupportTeam;
    public CustomerSupportTeamReset(){
        listCustomerSupportTeam = new list<Customer_Support_Team__c>();
        listCustomerSupportTeam = [select id,  Today_s_Score__c, Status__c, Out_Of_Office_Start_Date__c, Out_Of_Office_End_Date__c  from Customer_Support_Team__c];
    }
    
    public void OvernightReset()
    {
      
      for(Customer_Support_Team__c a: listCustomerSupportTeam)
      {
          a.Today_s_Score__c = 0;
          if(a.Out_Of_Office_Start_Date__c != null && a.Out_Of_Office_End_Date__c != null){
              if(date.today() >= a.Out_Of_Office_Start_Date__c && date.today() <= a.Out_Of_Office_End_Date__c && a.Status__c == 'Active'){
                  a.Status__c = 'Inactive';
                  
              }
              else if(date.today() > a.Out_Of_Office_End_Date__c && a.Status__c == 'Inactive'){
                  a.Status__c = 'Active';
                  a.Out_Of_Office_End_Date__c = null;
                  a.Out_Of_Office_Start_Date__c = null;
              }
          }
      }
      update listCustomerSupportTeam;
    } 

}