public without sharing class TOCCurrentStateController {
	
    private Id studentProgramId;
    private List<Student_Competency__c> studentCompetencyList;
    private String degreeLevel;
    public List<CategoryGrouping> categoryGroupingList {get;set;}
    public Decimal totalPreliminaryTransferCE {get;set;}
    public Decimal totalTransferredCE {get;set;}
    public Decimal totalFulfilledCE {get;set;}
    public String studentName {get;set;}
    public String program {get;set;}
    public String cblID {get;set;}
    public Boolean isUndergrad {get;set;}
    
    public TOCCurrentStateController(ApexPages.StandardController controller) {
        try {
            if (ApexPages.currentPage().getParameters().get('id') != null) {
                studentProgramId = ApexPages.currentPage().getParameters().get('id');
            } else {
             	studentProgramId = ApexPages.currentPage().getParameters().get('spId');   
            }
            totalPreliminaryTransferCE = 0.0;
            totalTransferredCE = 0.0;
            totalFulfilledCE = 0.0;
            degreeLevel = '';
            
            categoryGroupingList = new List<CategoryGrouping>();

			Student_Program__c sp = [SELECT Student_name__c, program__R.display_name__c, cbl_id__c, program__r.Degree_Level__c
                                     FROM Student_program__c 
                                     WHERE Id = :studentProgramId];
            if (sp != null) {
                studentName = sp.Student_Name__c;
                program = sp.program__R.display_name__c;
                cblID = sp.CBL_Id__c;
                degreeLevel = sp.program__r.Degree_Level__c;
            }
            
            studentCompetencyList = new List<Student_Competency__c>();
            studentCompetencyList = [SELECT student_expertise__r.area_of_expertise_name__c, 
                                            student_expertise__r.area_of_expertise__r.course_code__c,
                                            status__c,
                                            student_expertise__r.audit_category__c,
                                            transferring_institution__c,
                                            student_expertise__r.pseudo_Course__c,
                                            student_expertise__r.pseudo_ce__c,
                                            student_expertise__r.total_ce__c,
                                     		pseudo_ce__c
                                    FROM Student_Competency__c
                                    WHERE student_program__c = :studentProgramId
                                    AND (status__c = 'Fulfilled' OR status__c = 'Transferred' OR status__c = 'Preliminary Transfer')
                                    ORDER BY student_expertise__r.audit_category__c,
                                    		 student_expertise__r.area_of_expertise_name__c];
            if (degreeLevel == 'Undergrad') {
                isUndergrad = true;
            	manageList();
            } else {
                isUndergrad = false;
                manageGradStudent();
            }
        } catch(Exception e) {
            e.getMessage();
            System.debug('TOCCurrentState: ' + e.getMessage());
        }           
    }
    
    private void manageList() {
        Set<String> auditCategorySet = new Set<String>();
        Set<String> studentExpertiseSet = new Set<String>();
        for(Student_Competency__c sc : studentCompetencyList) {
            if (sc.student_expertise__r.audit_category__c != null) {
                String auditCategoryType = sc.student_expertise__r.audit_category__c.split(';')[0];
                if (!auditCategorySet.contains(auditCategoryType)) {
                    auditCategorySet.add(auditCategoryType);
                    CategoryGrouping grouping = new CategoryGrouping();
                    grouping.type = auditCategoryType;
                    grouping.entry = new List<CategoryGroupingItem>();
                    grouping.totalCE = 0.0;
                    grouping.preliminaryTransferCE = 0.0;
                    grouping.transferredCE = 0.0;
                    grouping.fulfilledCE = 0.0;
                    categoryGroupingList.add(grouping);
                }
            
                if (sc.student_expertise__r.area_of_expertise__r.course_code__c != null) {
                    if (!studentExpertiseSet.contains(sc.student_expertise__r.area_of_expertise__r.course_code__c)) {
                        CategoryGroupingItem item = new CategoryGroupingItem();
                        item.seCourseCode = sc.student_expertise__r.area_of_expertise__r.course_code__c;
                        item.seAOEName = sc.student_expertise__r.area_of_expertise_name__c;
                        if (sc.student_expertise__r.pseudo_Course__c) {
                            if (sc.pseudo_ce__c != null) {
                                //item.creditTotal = sc.student_expertise__r.pseudo_ce__c;
                                item.creditTotal = sc.pseudo_ce__c;
                            } else {
                                item.creditTotal = 0;
                            }
                        } else {
                            studentExpertiseSet.add(sc.student_expertise__r.area_of_expertise__r.course_code__c);
                            item.creditTotal = sc.student_expertise__r.total_ce__c;
                        }
                        item.transferringInstitution = sc.transferring_institution__c;
                        item.creditType = sc.status__c;
                        for (CategoryGrouping cat : categoryGroupingList) {
                            if (cat.type == auditCategoryType) {
                                cat.totalCE += item.creditTotal;
                                if (item.creditType == 'Preliminary Transfer') {
                                    totalPreliminaryTransferCE += item.creditTotal;
                                    cat.preliminaryTransferCE += item.creditTotal;
                                } else if (item.creditType == 'Transferred') {
                                    totalTransferredCE += item.creditTotal;
                                    cat.transferredCE += item.creditTotal;
                                } else if (item.creditType == 'Fulfilled') {
                                    totalFulfilledCE += item.creditTotal;
                                    cat.fulfilledCE += item.creditTotal;
                                }
                                cat.entry.add(item);
                            }
                        }
                    }
                }
            }
        }
    }
    
    private void manageGradStudent() {
        Set<String> studentExpertiseSet = new Set<String>();
        CategoryGrouping grouping = new CategoryGrouping();
            grouping.type = 'All';
            grouping.entry = new List<CategoryGroupingItem>();
            grouping.totalCE = 0.0;
            grouping.preliminaryTransferCE = 0.0;
            grouping.transferredCE = 0.0;
            grouping.fulfilledCE = 0.0;
            categoryGroupingList.add(grouping);
        for(Student_Competency__c sc : studentCompetencyList) {
            if (!studentExpertiseSet.contains(sc.student_expertise__r.area_of_expertise__r.course_code__c)) {
                studentExpertiseSet.add(sc.student_expertise__r.area_of_expertise__r.course_code__c);
                CategoryGroupingItem item = new CategoryGroupingItem();
                item.seCourseCode = sc.student_expertise__r.area_of_expertise__r.course_code__c;
                item.seAOEName = sc.student_expertise__r.area_of_expertise_name__c;
                item.creditTotal = sc.student_expertise__r.total_ce__c;
                item.transferringInstitution = sc.transferring_institution__c;
                item.creditType = sc.status__c;
                for (CategoryGrouping cat : categoryGroupingList) {
                    if (cat.type == 'All') {
                        cat.totalCE += item.creditTotal;
                        if (item.creditType == 'Preliminary Transfer') {
                            totalPreliminaryTransferCE += item.creditTotal;
                            cat.preliminaryTransferCE += item.creditTotal;
                        } else if (item.creditType == 'Transferred') {
                            totalTransferredCE += item.creditTotal;
                            cat.transferredCE += item.creditTotal;
                        } else if (item.creditType == 'Fulfilled') {
                            totalFulfilledCE += item.creditTotal;
                            cat.fulfilledCE += item.creditTotal;
                        }
                        cat.entry.add(item);
                   }
                }
            }
        }
    }
    
    public class CategoryGrouping {
        public String type {get;set;}
        public List<CategoryGroupingItem> entry {get; set;}
        public Decimal totalCE {get;set;}
        public Decimal preliminaryTransferCE {get;set;}
        public Decimal transferredCE {get;set;}
        public Decimal fulfilledCE {get;set;}
        
        public CategoryGrouping() {
            
        }
    }
    
    public class CategoryGroupingItem {
        public String seCourseCode {get;set;}
        public String seAOEName {get;set;}
        public Decimal creditTotal {get;set;}
        public String transferringInstitution {get;set;}
        public String creditType {get;set;}
        
        public CategoryGroupingItem() {
            
        }
    }
}