/*******************************************************************
Name  : StudentSubscriptionExemptionHandler
Author: Sarah Khalid - Laureate
Date  : April 6, 2016
Description: Handler class for the Trigger StudentSubscriptionExemptionHandler
*************************************************************************/
public with sharing class StudentSubscriptionExemptionHandler {
  private boolean isExecuting = false;
  private integer batchSize = 0;
  
  public StudentSubscriptionExemptionHandler( boolean isExecuting, integer size ) {
    isExecuting = isExecuting;
    batchSize = size;
  } 

  public void onAfterInsert( list<Student_Subscription_Exemptions__c > newStudentSubscriptionExemptions ) {
       
    system.debug('onAfterInsert size of newStudentSubscriptionExemptions ' + newStudentSubscriptionExemptions.size());
    
    List<Student_Subscription_Exemptions__c>  subscriptionExemptions = new List<Student_Subscription_Exemptions__c>();
    
  for(Student_Subscription_Exemptions__c e : [SELECT  Student_Discount__r.Exemption__r.Fee_Type__c,Student_Discount__r.Student_Program__c,Student_Discount__r.Student_Program__r.Program__c, Student_Discount__r.Student_Program__r.Program__r.Parent_Program__c,  Student_Discount__r.Exemption_Approved__c, Student_Discount__r.Term_Start_Date__c, Student_Discount__r.Term_End_Date__c, Student_Subscription__c,  Student_Subscription__r.Term_Price_Book__c, Student_Subscription__r.Subscription_Duration_in_Months__c, Student_Discount__r.Exemption_Description__c, Student_Subscription__r.List_Price__c, Student_Subscription__r.Start_Date__c, Student_Subscription__r.End_Date__c, Student_Discount__r.no_of_Terms_Exemption_Applied__c, Student_Discount__r.Active__c, Student_Discount__r.Life_of_Program__c, Student_Discount__r.Exemption__c, Student_Discount__r.no_of_Terms__c, Student_Discount__r.Exemption_Category__c, Student_Discount__r.Exemption_Sub_type__c, Student_Discount__r.Flat_Rate_Amount__c, Student_Discount__r.Percent_Discount__c, Student_Discount__r.Program__c, Student_Subscription__r.ProgramID__c FROM Student_Subscription_Exemptions__c Where Id IN: newStudentSubscriptionExemptions AND Student_Discount__r.Exemption_Approved__c = true]) 
   {   	
       
       //system.debug('Student_Discount__r.Student_Program__r.Program__r.Parent_Program__c '+e.Student_Discount__r.Student_Program__r.Program__r.Parent_Program__c );
      	subscriptionExemptions.add(e);
    	
    }   
   StudentSubscriptionExemptionHelper helper = new StudentSubscriptionExemptionHelper();
   helper.processExemptionRules(subscriptionExemptions);    
  } 
     
}