@isTest
private class Test_Assignment_Rule_Entry_Trigger {
  @isTest
    static void AddNewRule()
    {
      
      Assignment_Group_Name__c AG = new Assignment_Group_Name__c(name='test');
      insert AG;
      
      
      Opportunity_Assignment_Rule__c NewRule = new Opportunity_Assignment_Rule__c(NAme='testrule', Is_Active__c=true);
      insert NewRule;
      
      Map<decimal,id> Startorder = new Map<decimal,id>();
      List<Assignment_Rule_Entry__c> BaseRules = new List<Assignment_Rule_Entry__c>();
      For(Integer ii = 1; ii <=5; ii++){
        BaseRules.add(new Assignment_Rule_Entry__c(Opportunity_Assignment_Rule__c = NewRule.id, Order_Number__c=ii, Assign_to_Assignment_Group__c=AG.id));
      }
      Assignment_Rule_Entry_Trigger.calledOnce = false;
      insert BaseRules;
      For(Assignment_Rule_Entry__c AR: BaseRules){
        Startorder.put(AR.Order_Number__c, AR.id);
      }
      
      Assignment_Rule_Entry__c oldNumOne = [Select id, Order_Number__c from Assignment_Rule_Entry__c where id =:Startorder.get(1) LIMIT 1];
      system.assertEquals(1, oldNumOne.Order_Number__c);
      
      Integer start = System.Now().millisecond();
        while(System.Now().millisecond()< start+35){ 
        }
      //add new #0
      Assignment_Rule_Entry__c newentry = new Assignment_Rule_Entry__c(Opportunity_Assignment_Rule__c = NewRule.id, Order_Number__c=6, Assign_to_Assignment_Group__c=AG.id);
      Assignment_Rule_Entry_Trigger.calledOnce = false;
      insert newentry;
      newentry = [Select id, Order_Number__c from Assignment_Rule_Entry__c where id =:newentry.id LIMIT 1];

      system.assertEquals( 6,newentry.Order_Number__c);
      //check that the old #1 is now #2
      

    }

  @isTest
    static void RemoveRule()
    {
      
      Assignment_Group_Name__c AG = new Assignment_Group_Name__c(name='test');
      insert AG;
      
      
      Opportunity_Assignment_Rule__c NewRule = new Opportunity_Assignment_Rule__c(NAme='testrule', Is_Active__c=true);
      insert NewRule;
      
      Map<decimal,id> Startorder = new Map<decimal,id>();
      List<Assignment_Rule_Entry__c> BaseRules = new List<Assignment_Rule_Entry__c>();
      For(Integer ii = 1; ii <=5; ii++){
        BaseRules.add(new Assignment_Rule_Entry__c(Opportunity_Assignment_Rule__c = NewRule.id, Order_Number__c=ii, Assign_to_Assignment_Group__c=AG.id));
      }
      Assignment_Rule_Entry_Trigger.calledOnce = false;
      insert BaseRules;
      For(Assignment_Rule_Entry__c AR: BaseRules){
        Startorder.put(AR.Order_Number__c, AR.id);
      }
      
      Assignment_Rule_Entry__c oldNumOne = [Select id, Order_Number__c from Assignment_Rule_Entry__c where id =:Startorder.get(1) LIMIT 1];
      system.assertEquals(1, oldNumOne.Order_Number__c);
      
      Integer start = System.Now().millisecond();
        while(System.Now().millisecond()< start+35){ 
        }
     
      Assignment_Rule_Entry__c newentry = new Assignment_Rule_Entry__c(Opportunity_Assignment_Rule__c = NewRule.id, Order_Number__c=6, Assign_to_Assignment_Group__c=AG.id);
      Assignment_Rule_Entry_Trigger.calledOnce = false;
      insert newentry;

      delete newentry;
      

    }   

    
}