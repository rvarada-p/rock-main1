//Modified the complete function by Stephen Paulsam for I-194105 12/22
 
 public with sharing class Assignment_Rule_Entry_Trigger {
  public static set<id> Reordered;
  public static boolean calledOnce = false;
  

  
 
  public static void reOrderRules(List<Assignment_Rule_Entry__c> Rules, string triggertype){
      List<ID> parentRules = new List<id>();
      List<Assignment_Rule_Entry__c> toupdate = new List<Assignment_Rule_Entry__c>();
    //Loop through all records in the Trigger.new collection
       for(Assignment_Rule_Entry__c a: Rules){
          parentRules.add(a.Opportunity_Assignment_Rule__c);
       }
       
       if(parentRules.isEmpty()== false){
           for ( ID aID : parentRules ){
                integer i=1;
                For(Assignment_Rule_Entry__c rule:[Select id, Order_Number__c, Opportunity_Assignment_Rule__c from Assignment_Rule_Entry__c where Opportunity_Assignment_Rule__c =:aID  Order By Order_Number__c,LastModifiedDate Desc]){
                    if(i != rule.Order_Number__c){
                        rule.Order_Number__c = i;
                        toupdate.add(rule);
                    }
                    i++;
                }
           }
       }
       if(toupdate.isempty()==false){
          update toupdate;
        }
  }
}