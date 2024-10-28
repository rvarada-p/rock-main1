public class MyGroupAssignmentController 
{    
    public String GroupId {get;set;}
    public String MyButton {get;set;}
    public List<Customer_Support_Team__c> MyGroups {get;set;}
    public Id UserId;
    public MyGroupAssignmentController()
    {
        GroupId = '';
        UserId = UserInfo.getUserId();
        MyGroups = [SELECT SME_Cohort_Group__r.SME_Assignment_Group__c,SME_Cohort_Group__r.SME_Assignment_Group__r.Name, Split_Weight__c, Split_formula__c,
                           Today_s_Score__c,Out_Of_Office_End_Date__c,Out_Of_Office_Start_Date__c,
                           of_today__c, Fair_Check__c,Lunch_Break__c, Status__c FROM Customer_Support_Team__c
                             WHERE User__c =: UserId];                  
    }
    
    public void activate()
    {
        Customer_Support_Team__c CST = [SELECT Status__c,Out_Of_Office_Start_Date__c,Out_Of_Office_End_Date__c FROM Customer_Support_Team__c WHERE Id =: GroupId];
        
        if(CST.Out_Of_Office_Start_Date__c != null && CST.Out_Of_Office_End_Date__c != null && date.today() >= CST.Out_Of_Office_Start_Date__c && date.today() <= CST.Out_Of_Office_End_Date__c){
            Apexpages.addMessage(new Apexpages.message(ApexPages.Severity.Error,'You can\'t Activate User who is Out Of Office'));
        }
        else{
            CST.Status__c = 'Active';
            update CST;
            
            MyGroups = [SELECT SME_Cohort_Group__r.SME_Assignment_Group__c,SME_Cohort_Group__r.SME_Assignment_Group__r.Name, Split_Weight__c, Split_formula__c,
                                                              Today_s_Score__c,Out_Of_Office_End_Date__c,Out_Of_Office_Start_Date__c,
                                                              of_today__c, Fair_Check__c,Lunch_Break__c,
                                                              Status__c FROM Customer_Support_Team__c
                                                              WHERE User__c =: UserId];
        }
    }
    
    public void deactivate()
    {
        Customer_Support_Team__c CST = [SELECT Status__c,Out_Of_Office_Start_Date__c,Out_Of_Office_End_Date__c FROM Customer_Support_Team__c WHERE Id =: GroupId];

        CST.Status__c = 'Inactive';
        update CST;
        
        MyGroups = [SELECT SME_Cohort_Group__r.SME_Assignment_Group__c,SME_Cohort_Group__r.SME_Assignment_Group__r.Name, Split_Weight__c, Split_formula__c,
                                                          Today_s_Score__c,Out_Of_Office_End_Date__c,Out_Of_Office_Start_Date__c,
                                                          of_today__c, Fair_Check__c,Lunch_Break__c,
                                                          Status__c FROM Customer_Support_Team__c
                                                          WHERE User__c =: UserId];
    }

    

}