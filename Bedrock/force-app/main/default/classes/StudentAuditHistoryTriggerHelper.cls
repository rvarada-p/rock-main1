public class StudentAuditHistoryTriggerHelper {
    
    public static void mapUGTotalEarnedCredits(Set<Id> spIdSet) {
             
        List<Student_Program__c> spList = new List<Student_Program__c>();
        
        for (Student_Program__c sp : [SELECT Id, total_earned_core_lower__c, total_earned_core_upper__c, total_earned_concentration__c, total_earned_general_education__c, total_earned_general_elective__c, 
                                          (SELECT Id, Earned_CE_Core__c, Earned_CE_Core_Upper__c, Earned_CE_Concentration__c, Earned_CE_General_Education__c, Earned_CE_General_Electives__c                                                            
                                           FROM Student_Audit_Historys__r
                                           ORDER BY name DESC
                                           LIMIT 1)
                                      FROM Student_Program__c
                                      WHERE id IN :spIdSet]) {
                                         
            if (!sp.student_audit_historys__r.isEmpty()) {
                for (Student_audit_history__c sah : sp.student_audit_historys__r) {
                    sp.Total_Earned_Core_Lower__c = sah.Earned_CE_Core__c;
                    sp.Total_Earned_Core_Upper__c = sah.Earned_CE_Core_Upper__c;
                    sp.Total_Earned_Concentration__c = sah.Earned_CE_Concentration__c;
                    sp.Total_Earned_General_Education__c = sah.Earned_CE_General_Education__c;
                    sp.Total_Earned_General_Elective__c = sah.Earned_CE_General_Electives__c;
                }
            }
            spList.add(sp);
        }
        
        if (!spList.isEmpty()) {
            update spList;
        }
        
    }

}