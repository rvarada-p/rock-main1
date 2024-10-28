public without sharing class LeaveOfAbsenceTriggerHelper {
    
    public static void updateGapMonthsInSP(List<Leave_of_Absence__c> loaList) {
        List<Student_Program__c> spToUpdateList = new List<Student_Program__c>();
        
        Set<Id> spIds = new Set<Id>();
        for (Leave_Of_Absence__c loa : loaList) {
            spIds.add(loa.student_program__c);
        }
        
        for (Student_Program__c sp : [SELECT Id, loa_gap_months__c FROM Student_Program__c WHERE Id IN :spIds]) {
            for (Leave_of_Absence__c loa : loaList) {
                if (loa.Student_Program__c == sp.id) {
                    if (sp.LOA_Gap_Months__c == null) {
                        sp.LOA_Gap_Months__c = 0;
                    }
                    sp.LOA_Gap_Months__c += loa.Months_on_LOA__c;
                }
            }
            spToUpdateList.add(sp);
        }
        
        if (!spToUpdateList.isEmpty()) {
            update spToUpdateList;
        }
    }
    
    public static void updateGapMonthsInSP(List<Leave_of_Absence__c> updatedLeavesOfAbsence, map<ID,Leave_of_Absence__c> mapOld) {
        List<Student_Program__c> spToUpdateList = new List<Student_Program__c>();
        
        Set<Id> spIds = new Set<Id>();
        for (Leave_Of_Absence__c loa : updatedLeavesOfAbsence) {
            spIds.add(loa.student_program__c);
        }
        for (Student_Program__c sp : [SELECT Id, loa_gap_months__c FROM Student_Program__c WHERE Id IN :spIds]) {
            for (Leave_of_Absence__c loa : updatedLeavesOfAbsence) {
                Decimal newLoaMonths = loa.months_on_loa__c;
                Decimal oldLoaMonths = mapOld.get(loa.id).months_on_loa__c;
                if (newLoaMonths != oldLoaMonths) {
                    sp.LOA_Gap_Months__c = sp.LOA_Gap_Months__c + (newLoaMonths - oldLoaMonths);
                }
            }
            spToUpdateList.add(sp);
        }
        
        if (!spToUpdateList.isEmpty()) {
            update spToUpdateList;
        }
    }
	
    public static void populateLOAMonthsRemainingWithin12MonthPeriod(List<Leave_of_Absence__c> LOAList, boolean substractFromSP) {
        Set<ID> LOAIds = new Set<Id>();
        Set<ID> spIds = new Set<Id>();
        List<Student_Program__c> spToUpdateList = new List<Student_Program__c>();
        
        for (Leave_Of_Absence__c loa : LOAList) {
            LOAIds.add(loa.id);
            spIds.add(loa.student_program__c);
        }
        
        for (Student_Program__c sp : [SELECT Id, Total_LOA_Months_Available__c FROM Student_Program__c WHERE Id IN :spIds]) {
            Student_Program__c studentProgram = new Student_Program__c();
            studentProgram.id = sp.id;
            studentProgram.Total_LOA_Months_Available__c = sp.Total_LOA_Months_Available__c;
            
            for (Leave_of_Absence__c loa : LOAList) {
                if (loa.Student_Program__c == sp.id) {
                    if (substractFromSP) {
                    	studentProgram.Total_LOA_Months_Available__c = studentProgram.Total_LOA_Months_Available__c - loa.Months_on_LOA__c;
                        loa.LOA_Months_Remaining_within_12_months__c = studentProgram.Total_LOA_Months_Available__c;
                    } else {
                        studentProgram.Total_LOA_Months_Available__c = studentProgram.Total_LOA_Months_Available__c + loa.Months_on_LOA__c;
                    }
                }
            }
            spToUpdateList.add(studentProgram);
        }
        
        if (!spToUpdateList.isEmpty()) {
            update spToUpdateList;
        }
    }
    
    public static void populateToAndFromDatesOnSP(List<Leave_of_Absence__c> loaList) {
        Set<ID> spIds = new Set<Id>();
        List<Student_Program__c> spToUpdateList = new List<Student_Program__c>();
        
        for (Leave_Of_Absence__c loa : LOAList) {
            spIds.add(loa.student_program__c);
        }
        
        Set<ID> loaIds = new Set<Id>();
        for (Leave_Of_Absence__c loa : [SELECT id, student_program__c, from_date__c, to_date__c, createdDate FROM Leave_of_absence__c WHERE student_program__c IN :spIds ORDER BY createdDate DESC]) {
            if (!loaIds.contains(loa.student_program__c)) {
                loaIds.add(loa.student_program__c);
                Student_Program__c sp = new Student_Program__c();
                sp.id = loa.Student_Program__c;
                sp.Leave_of_Absence_LOA_From__c = loa.From_Date__c;
                sp.Leave_of_Absence_LOA_To__c = loa.To_Date__c;
                spToUpdateList.add(sp);
            }
        }
        
        if (!spToUpdateList.isEmpty()) {
            update spToUpdateList;
        }
    }
}