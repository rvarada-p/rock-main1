/*******************************************************************
Name  : StudentPaymentPlanTriggerHandler
Author: Ravitej Varada
Date  : August 11th, 2020
Description: trigger handler class for  StudentPaymentPlanTrigger

* Revision History
* Horacio Sanchez 	- 	Jul 15, 2021 	- 	User Story 58473: L2: Create Payment Plan identifier on SP
* Horacio Sanchez   -   Nov 18, 2021    -   Task 74055: Create new field on SP re: automatic payment
*************************************************************************/
public class StudentPaymentPlanTriggerHandler {
    private set<ID> setCBLRecordTypes;
    private boolean isExecuting = false;
    private integer batchSize = 0;


    public StudentPaymentPlanTriggerHandler(boolean isExecuting, integer size) {
        isExecuting = isExecuting;
        batchSize = size;
    }

    //On After Insert Event
    public void onAfterInsert(List<Student_Payment_Plan__c > newStudentPayPlan) {
        List<Student_Program__c> spLst = new List<Student_Program__c>();
        for (Student_Payment_Plan__c plan: newStudentPayPlan) {
            if (plan.Type_of_Plan__c == 'Enrollment in Automatic Payment' && plan.Action__c == 'Create') {
                spLst.add(new Student_Program__c(id= plan.Student_Program__c , Enrolled_in_Automatic_Payment__c = TRUE, Enrollment_AutoPayment_Activity_Date__c = Date.today() ));
            } else if(plan.Type_of_Plan__c == 'Enrollment in Automatic Payment' && plan.Action__c == 'Cancel') {
                spLst.add(new Student_Program__c(id= plan.Student_Program__c , Enrolled_in_Automatic_Payment__c = FALSE, Enrollment_AutoPayment_Activity_Date__c = Date.today() ));
            }
        }
        
        if (!spLst.isEmpty()) {
            update spLst;
        }
        
        StudentPaymentPlanTriggerHelper.updatePaymentPlanIdentifierOnSP(newStudentPayPlan);

    }

    //On Before Insert  Event
    public void onBeforeInsert(list<Student_Payment_Plan__c > newStudentPayPlan) {
    }

    //On Before Update Event
    public void onBeforeUpdate(list<Student_Payment_Plan__c > newStudentPayPlan, map<ID, Student_Payment_Plan__c>oldMap) {
    }

    //On After Update Event
    public void onAfterUpdate(list<Student_Payment_Plan__c > newStudentPayPlan, map<ID, Student_Payment_Plan__c>oldMap) {

    }


}