/*******************************************************************
Name  : StudentPaymentPlanTriggerHelper
Author: Horacio Sanchez
Date  : July 15th, 2021
Description: Helper class for StudentPaymentPlanTrigger
*************************************************************************/
public class StudentPaymentPlanTriggerHelper {

    public static void updatePaymentPlanIdentifierOnSP(List<Student_Payment_Plan__c > sppList) {
        final String CREATE_ACTION = 'Create';
        final String UPDATE_ACTION = 'Update';
        
        Map<String, String> spActionMap = new Map<String, String>();
        for (Student_Payment_Plan__c spp : sppList) {
            if (spp.Type_of_Plan__c != null && spp.Type_of_Plan__c.equals('PaymentPlan') && spp.Action__c != null) {
                spActionMap.put(spp.Student_Program__c, spp.Action__c);
            }
        }
        
        List<Student_Program__c> spToUpdateList = new List<Student_Program__c>();
        for (String spId : spActionMap.keySet()) {
            Student_Program__c sp = new Student_Program__c();
			sp.Id = spId;
            if (spActionMap.get(spId).equals(CREATE_ACTION) || spActionMap.get(spId).equals(UPDATE_ACTION)) {
                sp.Active_Student_Payment_Plan__c = true;
            } else {
                sp.Active_Student_Payment_Plan__c = false;
            }
            spToUpdateList.add(sp);
        }
        
        if (!spToUpdateList.isEmpty()) {
            update spToUpdateList;
        }
    }
}