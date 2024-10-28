/*******************************************************************
Name  : CompetencySummaryController 
Author: Ravitej Varada (Laureate)
Date  : Oct 21, 2019
Description: Controller class for CompetencySummary App
*************************************************************************/
public without sharing class CompetencySummaryController {

    @AuraEnabled
    public static List<SelectOptionWrapper> getStudentProgramsFromCompetencies(Id contactId){
        List<SelectOptionWrapper> options = new List<SelectOptionWrapper>();
        for(Student_Program__c sp : [select Id,Student__c,IsStudentProgramActive__c,Program__r.Name,Program_Start_Date__r.Name,Program_Start_Date__r.Start_Date__c from Student_Program__c where Student__c = :contactId ORDER BY IsStudentProgramActive__c DESC,Program_Start_Date__r.Start_Date__c DESC]){
            options.add(new SelectOptionWrapper(sp.Program__r.Name+ (String.isNotBlank(sp.Program_Start_Date__r.Name) ? '-'+sp.Program_Start_Date__r.Name : ''),sp.Id,true,false,new Map<String,String>{'IsStudentProgramActive__c' => String.valueOf(sp.IsStudentProgramActive__c)}));
        }
        return options;
    }
    
    
    @AuraEnabled
    public Static studentCompetencyWrapper getStudentCompetencies(Id contactId, Id spId, date startdate, date enddate, string status,string action){
        studentCompetencyWrapper studCompWrp = new studentCompetencyWrapper(); 
        Boolean isStartDateSelected = False;
        Boolean isEndDateSelected = False;
        Boolean isStatusSelected = False;
        
        string query =  'Select id,name, IsStudentProgramActive__c, Status__c ,Student_Program__r.Student_Full_Name__c, IsCompleted__c  ,Assessment_Submitted_Date__c ,Start_Date__c ,'+
            ' Target_Date__c ,CLP_Active__c ,Quiz_Completed__c ,Pseudo_CE__c ,Assessment_Submitted__c ,Self_Assessment_Submitted_Date__c ,'+
            ' Pause_Competency_Date__c ,Resume_Competency_Date__c ,Student_Subscription_Achieved_In__r.id,Student_Program__r.Program__r.ProductCode,Student_Program__r.Student__r.CBL_Student_ID__c,Pause_Competency__c ,Competency_Type__c ,Competency_Credit_Equivalency__c ,'+
            ' Competency_Code__c , Student_Program__r.id,Student_Expertise__r.Pseudo_Course__c,student_program__r.name,student_program__r.Student_Enrollment_Status__c,student_program__r.Last_Date_of_Engagement__c,'+
            ' student_program__r.Enrollment_DP_WD_Effective_Date__c,Completed_Date__c ,Student_Subscription_Achieved_In__r.name,Student_Subscription_Achieved_In__r.Start_Date__c, '+
            ' Student_Subscription_Achieved_In__r.End_Date__c ,Student_Subscription_Achieved_In__r.List_Price__c,Student_Subscription_Achieved_In__r.Subscription_Status__c  ,Student_Subscription_Achieved_In__r.Tuition__c ,Student_Subscription_Achieved_In__r.Tech_Fee__c'+
            ' FROM Student_Competency__c WHERE Contact__c = :contactId AND Status__c IN (\'Achieved\',\'Mastered\') AND Competency_Type__c = \'Academic\' ';
          
        if(String.isNotBlank(spId)){
            query += ' AND Student_Program__c =:spId';
        }

        if (status != null && status != ''){
            isStatusSelected = true;
            query += ' and status__c =: status';
        }
        if (startdate != null){
            isStartDateSelected = True;
            query += ' and Completed_date__c >=: startdate';
        }
        if (enddate != null){
            isEndDateSelected = True;
            query += ' and Completed_date__c <=: enddate';
        }  
        query += '  ORDER BY Completed_date__c DESC';
        
        set<string> compStatus = new set<string>();
        List<Student_Competency__c> studentCompList = new  List<Student_Competency__c>();
        System.debug('query==>');
        System.debug(query);
        studentCompList = database.query(query);
        
        Student_Program__c sProg = new Student_Program__c ();
        if(String.isNotBlank(spId))
            sProg = [Select Id,name,Last_Date_of_Engagement__c,Enrollment_DP_WD_Effective_Date__c from Student_Program__c Where Id =:spId LIMIT 1];
        decimal totalAchievedCE = 0;
        decimal netTotalAchievedCE = 0;
        decimal listPriceSum = 0;
        Integer count = 0;
        
        if(!isStartDateSelected && !isEndDateSelected && !isStatusSelected || isStatusSelected ){
            for(Student_Competency__c comp: studentCompList){
                if(comp.IsStudentProgramActive__c)
                    compStatus.add(comp.Status__c);  
            }
        }
        
        Map<string,decimal> subMap = new   Map<string,decimal>();
        List<studentCompList> compWrpList = new List<studentCompList>();
        for(Student_Competency__c comp: studentCompList){ 
                if((startDate != null && endDate != null && comp.Completed_date__c >= startdate && comp.Completed_date__c <= enddate) ||(startDate == null && endDate != null && comp.Completed_date__c <= enddate  )||
                startDate != null && endDate == null &&  comp.Completed_date__c >= startdate || (startDate != null && endDate != null && status != null )){
                    compStatus.add(comp.Status__c);  
                } 
                
                studentCompList compWrp = new studentCompList();
                if(comp.IsCompleted__c == TRUE && comp.Student_Subscription_Achieved_In__c !=null){ 
                    
                    compWrp.studentName = comp.Student_Program__r.Student_Full_Name__c;
                    compWrp.cblId 		= comp.Student_Program__r.Student__r.CBL_Student_ID__c;
                    compWrp.programCode = comp.Student_Program__r.Program__r.ProductCode;
                    compWrp.compName 	= comp.name;
                    compWrp.scId 		= comp.id;
                    compWrp.status 		= comp.Status__c;
                    compWrp.code 		= comp.Competency_Code__c;
                    compWrp.spId = comp.Student_Program__r.id;
                    compWrp.subId = comp.Student_Subscription_Achieved_In__r.id;
                    compWrp.studentProgram = comp.Student_Program__r.name;
                    compWrp.studentEnrollmentStatus = comp.Student_Program__r.Student_Enrollment_Status__c ;
                    compWrp.lastDateofEngagement = comp.Student_Program__r.Last_Date_of_Engagement__c ;
                    compWrp.enrollment_DP_WD_EffectiveDate = comp.Student_Program__r.Enrollment_DP_WD_Effective_Date__c ;
                    compWrp.completedDate = comp.Completed_Date__c ;
                    compWrp.studentSubscriptionAchievedIn = comp.Student_Subscription_Achieved_In__r.name;
                    compWrp.subscriptionStatus = comp.Student_Subscription_Achieved_In__r.Subscription_Status__c ;
                    compWrp.tuition = comp.Student_Subscription_Achieved_In__r.Tuition__c ;
                    compWrp.techFee = comp.Student_Subscription_Achieved_In__r.Tech_Fee__c ;
                    compWrp.subStartDate = comp.Student_Subscription_Achieved_In__r.Start_Date__c;
                    compWrp.subEndDate = comp.Student_Subscription_Achieved_In__r.end_Date__c;
                    compWrp.ce = comp.Competency_Credit_Equivalency__c;
                    
                    if(!subMap.containsKey(comp.Student_Subscription_Achieved_In__r.Name)){
                        if(comp.Student_Subscription_Achieved_In__r.List_Price__c != null){
                            listPriceSum += comp.Student_Subscription_Achieved_In__r.List_Price__c	;
                        }
                        subMap.put(comp.Student_Subscription_Achieved_In__r.Name, 0 );
                    }
                    totalAchievedCE +=  (comp.Competency_Credit_Equivalency__c==NULL ? 0 : comp.Competency_Credit_Equivalency__c);
                    count++;
                    compWrpList.add(compWrp);
                }
            netTotalAchievedCE+=(comp.Competency_Credit_Equivalency__c==NULL ? 0 : comp.Competency_Credit_Equivalency__c);
        }
        
        studCompWrp.lastDateofEngagement = sProg.Last_Date_of_Engagement__c ;
        studCompWrp.enrollment_DP_WD_EffectiveDate = sProg.Enrollment_DP_WD_Effective_Date__c ;
        
        studCompWrp.totalAchievedCE = totalAchievedCE;
        studCompWrp.totalListPrice = listPriceSum;
        studCompWrp.studentCompWrapperLst = compWrpList;
        studCompWrp.compStatus = compStatus;
        studCompWrp.recordCount = count;
        if(action=='reset'){
            studCompWrp = new studentCompetencyWrapper();
            studCompWrp.totalAchievedCE = netTotalAchievedCE;
        } 

        return studCompWrp; 
    }
    //Wrapper class to populate Summary/count/filter cond values.
    public class studentCompetencyWrapper {
        @AuraEnabled public studentCompList[] studentCompWrapperLst {get;set;}
        @AuraEnabled public decimal totalAchievedCE{get;set;}
        @AuraEnabled public decimal totalListPrice{get;set;}
        @AuraEnabled public integer recordCount{get;set;}
        @AuraEnabled public set<string> compStatus{get;set;}
        @AuraEnabled public date lastDateofEngagement {get;set;}
        @AuraEnabled public date enrollment_DP_WD_EffectiveDate {get;set;}
    }
    //Student Transaction records wrapper class
    public class studentCompList {
        
        
        
        @AuraEnabled public string studentName{get;set;}
        @AuraEnabled public string cblId{get;set;}
        @AuraEnabled public string programCode{get;set;}
        @AuraEnabled public string studentProgram{get;set;}
        @AuraEnabled public string studentEnrollmentStatus {get;set;}
        @AuraEnabled public date lastDateofEngagement {get;set;}
        @AuraEnabled public date enrollment_DP_WD_EffectiveDate {get;set;}
        @AuraEnabled public string code{get;set;}
        @AuraEnabled public string status{get;set;}
        @AuraEnabled public date completedDate{get;set;}
        @AuraEnabled public decimal ce{get;set;}
        @AuraEnabled public string studentSubscriptionAchievedIn{get;set;}
        @AuraEnabled public date subStartDate{get;set;}   
        @AuraEnabled public date subEndDate{get;set;}
        @AuraEnabled public string subscriptionStatus{get;set;}
        @AuraEnabled public decimal tuition{get;set;}
        @AuraEnabled public decimal techFee{get;set;}
        @AuraEnabled public string compName{get;set;}
        @AuraEnabled public string scId{get;set;}
        //@AuraEnabled public boolean isCompleted{get;set;}
        @AuraEnabled public string spId{get;set;}
        @AuraEnabled public string subId{get;set;}
        
        
    }
        
}