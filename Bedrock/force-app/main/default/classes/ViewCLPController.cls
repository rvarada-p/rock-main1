/*******************************************************************
Name  : ViewCLPController
Author: Sarah (Laureate)
Date  : December 3, 2015
Description: Controller extension class for ViewCLP Page
*************************************************************************/

 
public with sharing class ViewCLPController {
     
    public Student_Program__c sProgram {get; set;}
    //public list<Student_Competency__c> studentCompetencies {get;set;}
    public decimal creditsCompleteThisTerm { get; set; }
    public decimal creditsInCurrentTerm { get; set; } 
    public decimal creditsAgreedInTerm { get; set; }
    public integer monthsIntoProgram { get; set; }
    public integer daysLeftInTerm { get; set; }
    public decimal competenciesCompleted { get; set; }
    public decimal totalAttemptedCredits { get; set; }
    public decimal completedComps { get; set; }
    public decimal tbybComps { get; set; }
    public decimal fulfilledTransferredComps { get; set; }
    public decimal completedCredits { get; set; }
    public decimal tbybCredits { get; set; }
    public decimal fulfilledTransferredCredits { get; set; }
    public decimal totalAgreedToCredits { get; set; }
    public decimal percentCompleted { get; set; }
    public decimal creditsNeededForCompliance { get; set; }
    public decimal progressTowardSAPCompliance { get; set; }
    public List<StudentCompetency> studentComps { get; set; }
    public decimal TBYBCredits1;

    
    public ViewCLPController(ApexPages.StandardController controller){
        
        Student_Program__c sp = (Student_Program__c)controller.getRecord();
        this.creditsCompleteThisTerm = 0.0;
        this.creditsInCurrentTerm = 0.0;
        this.creditsAgreedInTerm = 0.0;
        this.daysLeftInTerm = 0;
        
        this.sProgram = [SELECT       Name, Credits_Brought_into_Program__c ,Student_Full_Name__c, Current_Student_Subscription__c, CurrentSubscriptionStartDate__c, CurrentSubscriptionEndDate__c,
                                      Renewal_Denied__c, Renewal_Denied_Comment__c, Number_of_Enrolled_Terms__c,Competencies_Completed_in_Trial__c, 
                                      Number_of_Competencies_Completed__c, IsStudentProgramActive__c, Id, Application__c, Number_of_Competencies_Transferred__c,Program__c,
                                      Number_of_Competencies__c,Progress_Toward_SAP_Compliance__c,Application__r.Admissions_Contingency__c, Total_attempted_credits__c, Number_Credits_Completed_in_all_Terms__c,
                                      Number_of_Credits_Completed_in_Trial__c,Number_of_Credits_TransferredFulfilled__c,SAP_Code__c, Previous_SAP_Code__c,
                                      Current_Student_Subscription__r.Agreed_To_Credits__c,Current_Student_Subscription__r.Number_of_Credits_Completed__c,
                                      Student__r.Name,All_Credits_Completed__c , UG_GR_Transferred_Fulfilled_CE__c , Degree_Level__c,
                                      Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c, First_Start_Date__c, Modality_Switcher_chk__c,LOA_Gap_Months__c  FROM Student_Program__c WHERE Id = :sp.Id];
        
        
        System.debug('Full Student Program :::: ' + sProgram);
        if(sProgram!=null) { 
            if(sProgram.CurrentSubscriptionEndDate__c!=null) {              
                this.daysLeftInTerm = System.today().daysBetween(sProgram.CurrentSubscriptionEndDate__c);           
            }
            creditsAgreedInTerm = sProgram.Current_Student_Subscription__r.Date_Student_Agreed_To_Credits__c!=null ? sProgram.Current_Student_Subscription__r.Agreed_To_Credits__c : null;
            getAllStudentCompetencies();
            
        TBYBCredits1 = sProgram.Number_of_Credits_Completed_in_Trial__c;
        if (TBYBCredits1 == null){
            TBYBCredits1 = 0;
        }
        
            calculateSAP();
        } 
        
    }
        
    private list<StudentCompetency> getAllStudentCompetencies(){
        if(sProgram!=null) { 
            list<Student_Competency__c> studentCompetencies = new List<Student_Competency__c>([Select Status__c,Start_Date__c, Target_Date__c, Competency_Credit_Equivalency__c, 
                                                         Name, Completed_Date__c, Competency__c, Competency__r.name, Competency__r.Description__c,
                                                         Competency_Code__c, Student_Expertise__r.Area_of_Expertise__c,
                                                         Assessment_Submitted__c, Pause_Competency__c, 
                                                         Engagement_Met__c, Quiz_Completed__c, 
                                                         Student_Expertise__r.Area_of_Expertise_Name__c, Submission_Status__c From Student_Competency__c 
                                                         where Student_Program__c =:sProgram.Id AND clp_active__c = true
                                                         and Competency_Code__c!='CRO01' order by Start_Date__c asc NULLS LAST]);

                try {
                    String colorCode;   
                    studentComps = new List<StudentCompetency>();           
                    for(Student_Competency__c sc : studentCompetencies) {
                        StudentCompetency studentComp;
                        System.debug('Submission_Status__c ::::: ' + sc.Submission_Status__c);
                        if(sc.Submission_Status__c == 'Red') {
                            colorCode = '#FE7676';
                        } 
                        if(sc.Submission_Status__c == 'Yellow') {
                            colorCode = '#FDB93E';
                        }
                        if(sc.Submission_Status__c == null || sc.Submission_Status__c == '') {
                            colorCode = '';
                        }
                        studentComp = new StudentCompetency(sc, colorCode);
                        studentComps.add(studentComp);
                        if(sc.Status__c == 'Mastered' || sc.Status__c == 'Achieved')  {
                            creditsCompleteThisTerm = creditsCompleteThisTerm + sc.Competency_Credit_Equivalency__c;
                        }
                         
                        creditsInCurrentTerm = creditsInCurrentTerm  + sc.Competency_Credit_Equivalency__c;
                    }
                    System.debug('Student Competencies:::: ' + studentComps); 
                   }
                   catch(Exception exp) {
                        System.debug(exp);
                   }
            
        }   
        return studentComps;
    }
    
    public void calculateSAP() {
        Date toDay = Date.today();
        String newSAPCode = '';
        String SAPLog = '';
        String renewalLog = '';

        integer numberCompletedTerms = (integer) sProgram.Number_of_Enrolled_Terms__c - 1;
        system.debug('numberCompletedTerms:' + numberCompletedTerms );

		decimal creditsBroughtIntoProgram = sProgram.Credits_Brought_into_Program__c ;
        if (creditsBroughtIntoProgram == null)
        creditsBroughtIntoProgram = 0;

        decimal TransferredCredits = sProgram.UG_GR_Transferred_Fulfilled_CE__c ;
        if (TransferredCredits == null)
        TransferredCredits = 0; 

        decimal CurrSubAttemptCred = sProgram.Current_Student_Subscription__r.Agreed_To_Credits__c;
        if (CurrSubAttemptCred == null)
        CurrSubAttemptCred = 0;

        decimal CurrSubCredComplete = sProgram.Current_Student_Subscription__r.Number_of_Credits_Completed__c;
        if (CurrSubCredComplete == null)
        CurrSubCredComplete = 0; 
        competenciesCompleted = 0;
        
        this.totalAgreedToCredits = sProgram.Total_attempted_credits__c  + creditsBroughtIntoProgram + TransferredCredits;
        if (sProgram.Degree_Level__c == 'Undergrad') {
            this.totalAttemptedCredits = sProgram.Number_Credits_Completed_in_all_Terms__c + sProgram.UG_GR_Transferred_Fulfilled_CE__c + sProgram.Credits_Brought_into_Program__c;
        } else {
        	this.totalAttemptedCredits = sProgram.All_Credits_Completed__c ;    
        }        
        this.completedCredits =  (sProgram.Number_Credits_Completed_in_all_Terms__c!=null?sProgram.Number_Credits_Completed_in_all_Terms__c:0 );
        this.tbybCredits = creditsBroughtIntoProgram;
        this.fulfilledTransferredCredits = (sProgram.UG_GR_Transferred_Fulfilled_CE__c!=null?sProgram.UG_GR_Transferred_Fulfilled_CE__c:0 );
        this.completedComps =  (sProgram.Number_of_Competencies_Completed__c!=null?Integer.valueOf(sProgram.Number_of_Competencies_Completed__c):0 );
        this.tbybComps = (sProgram.Competencies_Completed_in_Trial__c!=null?Integer.valueOf(sProgram.Competencies_Completed_in_Trial__c):0 ); 
        this.fulfilledTransferredComps = (sProgram.Number_of_Competencies_Transferred__c!=null?Integer.valueOf(sProgram.Number_of_Competencies_Transferred__c):0 );
        this.competenciesCompleted = completedComps + tbybComps + fulfilledTransferredComps; 
        this.competenciesCompleted = completedComps + tbybComps + fulfilledTransferredComps; 
        this.progressTowardSAPCompliance = sProgram.Progress_Toward_SAP_Compliance__c;

        Date currentSubscriptionStartDate = sProgram.CurrentSubscriptionStartDate__c;
        Date firstStartDate = sProgram.First_Start_Date__c;
        
        if (currentSubscriptionStartDate == null || firstStartDate == null) {
            system.debug('ERROR: either no currentSubscriptionStartDate OR First Start Date defined');
         }
                    
        this.monthsIntoProgram = firstStartDate.monthsBetween(toDay) - (sProgram.LOA_Gap_Months__c!=null?Integer.valueOf(sProgram.LOA_Gap_Months__c):0);
        System.debug('totalAgreedToCredits:' + totalAgreedToCredits);
        System.debug('totalAttemptedCredits:' + totalAttemptedCredits);
        if(totalAgreedToCredits!=null && totalAgreedToCredits!=0 && totalAttemptedCredits!=null) {
            percentCompleted = progressTowardSAPCompliance;
            decimal halfCredits = 0.0;
            if (sProgram.Degree_Level__c == 'Undergrad') {
                halfCredits = totalAgreedToCredits * 0.67;
            } else {
            	halfCredits = totalAgreedToCredits/2;    
            }
            
            if(percentCompleted < halfCredits*100) {
                creditsNeededForCompliance = halfCredits - totalAttemptedCredits;
            }
        }
   
    } 

   
     // Inner class to hold display details for each Student Competency
    public class StudentCompetency {
        public Student_Competency__c sc { get; set; }
        public String hexCode { get; set; }

        public StudentCompetency(Student_Competency__c sc, String color) {
            this.sc = sc;
            this.hexCode = color;
        }

    }    
    
}