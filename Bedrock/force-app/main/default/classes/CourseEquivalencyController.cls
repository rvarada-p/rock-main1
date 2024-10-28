/************************************************************************
Name  : CourseEquivalencyController
Author: Virendra (Appirio)
Date  : September 29, 2014 
Description: Controller  class VF interface to give Student Course Competency credit for Courses

* Modified by DK 11/5 - now a standard controller that is called from Opportunity screen 
  in addition to Student Program screen
*************************************************************************/
public with sharing class CourseEquivalencyController {
    
    public list<ProgramCreditableCompetency> programCreditableCompetencies{get;set;}
    public list<StudentCreditableCompetency> studentCreditableCompetencies{get;set;}
        
    public String courseCode{get;set;}
    public String transferInstitution{get;set;}
    public boolean pShowList{get;set;}
    public boolean sShowList{get;set;}
    public Student_Program__c studentProgram{get;set;}
    private Id studentProgramId;
    public boolean showPrimaryTransferButton{get;set;}
    private set<Student_Competency__c> studentCompetencies;
    
    /*
    *  Initialize values for student program and other variables used on Page
        DK: removed: public CourseEquivalencyController(ApexPages.StandardController controller){
    */  
    public CourseEquivalencyController(){

        studentProgramId = ApexPages.currentPage().getParameters().get('id');
        String objType = studentProgramId.getSobjectType().getDescribe().getName();
        System.debug('>>> Object Type is ' + objType);
        studentCompetencies = new set<Student_Competency__c>();
        programCreditableCompetencies = new list<ProgramCreditableCompetency>();
        studentCreditableCompetencies = new list<StudentCreditableCompetency>();
        if (objType == 'Student_Program__c'){  // called from Student_Program__c screen
            studentProgram = [Select id,name,Student__r.Name,Student__c, Program__r.Name, Program__c From Student_Program__c where id=:studentProgramId];
            pShowList = false;
            sShowList = false;
            studentProgramId = studentProgram.Id;
            
        }else{  // called from opportunity
            Opportunity myOpp = new Opportunity();
            myOpp = [Select Student_Program__c,Primary_Program__c, Contact__c from Opportunity where id=:studentProgramId];
            studentProgram = new Student_Program__c();
            studentProgram.Program__c = myOpp.Primary_Program__c;
            studentProgram.Student__c = myOpp.Contact__c;   
            studentProgramId = myOpp.Student_Program__c;         
        }
        ShowPreliminaryTransfer();
    }
    
    /*
    *  On Button click "View Program Competencies" what competencies mapped to this course(s)
    *  intersect with the competencies assigned to the program
    */
    
    public void getProgramCourseCompetencies(){
        if(studentProgram.Program__c != null){
            programCreditableCompetencies = getAllProgramCourseCompetencies(studentProgram.Program__c);
        }
        if(!programCreditableCompetencies.isEmpty()){
            pShowList = true;
        }else{
            pShowList = false;
        }
        
        getStudentCourseCompetencies();
    }
    
    
     /*
    *  On Button click "View Student Competencies" what competencies mapped to this course(s)
    *  intersect with the competencies assigned to the Student Competencies
    */
    public void getStudentCourseCompetencies(){
        if(studentProgramId != null){
            studentCreditableCompetencies = getAllStudentCourseCompetencies(studentProgramId);
        }
        if(!studentCreditableCompetencies.isEmpty()){
            sShowList = true;
        }else{
            /*
             * Make Existing Student Competency List Blank if no Student Course Competency Found
            */
            studentCompetencies = new set<Student_Competency__c>();
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'No student competency records found for the course code entered. Note: You must enter a space between the Course Name and Number (e.g. EDUC 6160)');
            ApexPages.addMessage(myMsg);
            sShowList = false;
        }
    }
    
    /*
     *The screen presents a list of all Course Competency records for the Institution that are
     * shared on the Program (eg. the primary program of interest on the Opportunity).  In other words, we want 
     *to see all Competencies assigned to a Program via the Program_Competencies object that overlap with the Competencies 
     *that are mapped to the Course (Course_Competency object).
    */
    private list<ProgramCreditableCompetency> getAllProgramCourseCompetencies(Id programId){
        programCreditableCompetencies = new list<ProgramCreditableCompetency>();
        if(courseCode != null){
            Set<String> competencyCodes = courseCodes();
            Map<String,List<Course_Competency__c>> courseCompetencies = getCourseCompetencies(competencyCodes);
            map<String,Program_Competency__c> pCompetencies = new map<String,Program_Competency__c>();
            for(Program_Competency__c programCompetency:[Select Product__c,Name,Id, Competency__c, Competency_Name__c,
                                                         Competency_Code__c From Program_Competency__c  where Product__c=:programId
                                                         and Competency_Code__c in:courseCompetencies.keySet()]){
                pCompetencies.put(programCompetency.Competency_Code__c,programCompetency);
            }
            
            /*
            *  Now populate the Wrapper data get from Intersesions 
            */
            for(String cCode:pCompetencies.keySet()){
                for(Course_Competency__c cComp:courseCompetencies.get(cCode)){
                    ProgramCreditableCompetency proCreditComp = new ProgramCreditableCompetency();
                    proCreditComp.programComp = pCompetencies.get(cCode); 
                    proCreditComp.courseComp = cComp;
                    programCreditableCompetencies.add(proCreditComp);
                }
            }
               
       }
        return programCreditableCompetencies;
    }
    
    
     /*
     *The screen presents a list of all Course Competency records for the Institution that are shared on the Student Program. 
     * In other words, we want to see all Competencies assigned to a Student via the Student_Competencies object that overlap 
     * with the Competencies that are mapped to the Course (Course_Competency object).
    */
     private list<StudentCreditableCompetency> getAllStudentCourseCompetencies(Id studentProgramId){
        list<Course_Competency__c> creditStdCourseCompetencies = new list<Course_Competency__c>();
        studentCreditableCompetencies = new list<StudentCreditableCompetency>();
        studentCompetencies = new set<Student_Competency__c>();
        system.debug('::studentProgramId:::'+studentProgramId);
        
        if(courseCode != null){
            Set<String> competencyCodes = courseCodes();
            Map<String,List<Course_Competency__c>> courseCompetencies = getCourseCompetencies(competencyCodes);
            Map<String,Student_Competency__c> sCompetencies = new Map<String,Student_Competency__c>();
            for(Student_Competency__c studentCompetency:[Select id, Competency__c,Name,Competency__r.Name,
                                                         Competency_Code__c, Status__c From Student_Competency__c  where Student_Program__c =:studentProgramId
                                                         and Competency_Code__c in:courseCompetencies.keySet()]){
                sCompetencies.put(studentCompetency.Competency_Code__c,studentCompetency);                                          
            }
            system.debug(':111111:studentCompetencies Size ::'+studentCompetencies.size());
            system.debug('::sCompetencies Size ::'+sCompetencies.size());
            system.debug('::courseCompetencies Size ::'+courseCompetencies.size());
            
            /*
            *  Now populate the Wrapper data get from Intersesions 
            */
            for(String stComp:sCompetencies.keySet()){
                 for(Course_Competency__c cComp:courseCompetencies.get(stComp)){
                    StudentCreditableCompetency stdCreditComp = new StudentCreditableCompetency();
                    stdCreditComp.studentComp = sCompetencies.get(stComp);
                    stdCreditComp.courseComp = cComp;
                    studentCreditableCompetencies.add(stdCreditComp);
                    // Used For Transer Institution Process
                    studentCompetencies.add(stdCreditComp.studentComp);
                 }
             }
        
        }
        system.debug(':222:studentCompetencies Size ::'+studentCompetencies.size());
        system.debug('::studentCreditableCompetencies ::'+studentCreditableCompetencies);
        return studentCreditableCompetencies;
    }
    
    
    
    private Map<String,List<Course_Competency__c>> getCourseCompetencies(set<String> courseCodes){
        //list of all Course Competency records for the Institution that are
        //shared on the Program
        system.debug('courseCodes::::::::::::::::::::::::;11111::::'+courseCodes);
        Map<String,List<Course_Competency__c>> cCompetencies = new Map<String,List<Course_Competency__c>>();
        for(Course_Competency__c courseComp:[Select id,Name, Course__c, Course__r.Name, Competency__c, Competency__r.Name,
                                             Competency__r.Code__c, Competency__r.Credit_Equivalency__c
                                             From Course_Competency__c
                                             where Course__r.Name in:courseCodes]){
            
            if(!cCompetencies.containsKey(courseComp.Competency__r.Code__c)){
                cCompetencies.put(courseComp.Competency__r.Code__c,new List<Course_Competency__c>());
            }                                               
            cCompetencies.get(courseComp.Competency__r.Code__c).add(courseComp);
        }
        system.debug('cCompetencies::::::::::::::::::::::::;11111::::'+cCompetencies);
        return cCompetencies;
    }
    
    /*
    *  Parse of Couse Codes saperated by Comma
    */
    private set<String> courseCodes(){
        set<String> competencyCodes = new set<String>();
        if(courseCode.contains(',')){
            competencyCodes = new set<string>(courseCode.split(','));
        }else{
            competencyCodes.add(courseCode);
        }
        set<String> newCompetencyCodes = new set<String>();
        for(String cCode:competencyCodes){
            cCode = cCode.trim();
            newCompetencyCodes.add(cCode);
        }
        return newCompetencyCodes;
    }

  /*
     *updates all the Student Competency records returned by the 'View Student Competencies button'
     On each of the Student Competency records (that are part of the UNION):
     Set Student_Competency__c.Status = 'Transferred'
     Set Completed? = TRUE
     Set Transferring_Institution__c = transferring institution (from text field) 
    */
    
    public void updateStudentCompetenciesFulfilled(){  // String newStatus, Boolean isCompleted
        getProgramCourseCompetencies();
        list<Student_Competency__c> listSCToUpdate = new list<Student_Competency__c>();
        if(!studentCompetencies.isEmpty()){
            for(Student_Competency__c stdComps:studentCompetencies){
                listSCToUpdate.add(new Student_Competency__c(id=stdComps.Id,Status__c = 'Fulfilled', IsCompleted__c = true, Transferring_Institution__c =transferInstitution));
            }
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Course codes entered do not correspond to any student competencies that can be transferred or fulfilled.');
            ApexPages.addMessage(myMsg);
        }   
        
        /*
        * Update and Make Blank to Student Competency Set 
        */
        if(!listSCToUpdate.isEmpty()){
            update listSCToUpdate;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info,'Student competencies have been marked as Fulfilled.');
            ApexPages.addMessage(myMsg);
            
            studentCompetencies = new set<Student_Competency__c>();
        } 
        getProgramCourseCompetencies(); 
    }

    /*
     *updates all the Student Competency records returned by the 'View Student Competencies button'
     On each of the Student Competency records (that are part of the UNION):
     Set Student_Competency__c.Status = 'Transferred'
     Set Completed? = TRUE
     Set Transferring_Institution__c = transferring institution (from text field) 
    */
    
    public void updateStudentCompetenciesTransferForCredit(){
        getProgramCourseCompetencies();
        list<Student_Competency__c> tranferForCredit = new list<Student_Competency__c>();
        if(!studentCompetencies.isEmpty()){
            for(Student_Competency__c stdComps:studentCompetencies){
                tranferForCredit.add(new Student_Competency__c(id=stdComps.Id,Status__c = 'Transferred',IsCompleted__c = true,Transferring_Institution__c =transferInstitution));
            }
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Course codes entered do not correspond to any student competencies that can be transferred. Please enter all course codes to be transferred.');
            ApexPages.addMessage(myMsg);
        }   
        
        /*
        * Update and Make Blank to Student Competency Set 
        */
        if(!tranferForCredit.isEmpty()){
            update tranferForCredit;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info,'Student competencies have been marked as Transferred Completed');
            ApexPages.addMessage(myMsg);
            
            studentCompetencies = new set<Student_Competency__c>();
        } 
        getProgramCourseCompetencies(); 
    }   
    /*
    Function to get current user profile to visibale Preliminary Transfer Button
    Related task: T-336301
    These button Visible only to CBL Admissions Specialist, CBL Administrator, and System Admin profiles
    */
    private void ShowPreliminaryTransfer(){
        showPrimaryTransferButton = false;
        for(Profile p: [Select Name from Profile where id =: userinfo.getProfileId()]){
            if(p.Name == 'CBL Admissions Specialist' || p.Name == 'CBL Administrator' || p.Name == 'System Administrator'  || p.Name == 'CBL Registrar'){
                showPrimaryTransferButton = true;
            }
        }
    }
     /*
     *updates all the Student Competency records returned by the 'View Student Competencies button'
     On each of the Student Competency records (that are part of the UNION):
     Set Student_Competency__c.Status = 'Preliminary Transfer'
     Set Transferring_Institution__c = transferring institution (from text field) 
     Related Task: T-336301
    */
    
    public void updateStudentCompetenciesPreliminaryTransferOfCredit(){
        getProgramCourseCompetencies();
        list<Student_Competency__c> tranferForCredit = new list<Student_Competency__c>();
        if(!studentCompetencies.isEmpty()){
            for(Student_Competency__c stdComps:studentCompetencies){
                tranferForCredit.add(new Student_Competency__c(id=stdComps.Id,Status__c = 'Preliminary Transfer',Transferring_Institution__c =transferInstitution));
            }
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Course codes entered do not correspond to any student competencies that can be preliminary transferred. Please enter all course codes to be preliminary transferred.');
            ApexPages.addMessage(myMsg);
        }   
        
        /*
        * Update and Make Blank to Student Competency Set 
        */
        if(!tranferForCredit.isEmpty()){
            update tranferForCredit;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info,'Student competencies have been marked as Preliminary Transfer');
            ApexPages.addMessage(myMsg);
            
            studentCompetencies = new set<Student_Competency__c>();
        }   
        getProgramCourseCompetencies();
    }
    /*
     Functionality: converts all 'Preliminary Transfer' to 'Transferred' statuses on all Student Competencies for this student,
     sets the Completed flag = TRUE.
     Assumption: this conversion happens for all student competencies for this student, regardless of what is in the Course Code text box 
     Related Task: T-336301
    */
    
    public void updateStudentCompetenciesConvertPreliminaryTransfers(){
        getProgramCourseCompetencies();
        list<Student_Competency__c> tranferForCredit = new list<Student_Competency__c>();
        // get all the student competency 
        for(Student_Competency__c studentCompetency: studentCompetencies){
                  // 
              if(studentCompetency.Status__c == 'Preliminary Transfer'){
                  studentCompetency.Status__c = 'Transferred';
                  studentCompetency.IsCompleted__c = true;
                  studentCompetency.Transferring_Institution__c = transferInstitution;   
                  tranferForCredit.add(studentCompetency);  
              }                                     
        }      
        
        /*
        * Update and Make Blank to Student Competency Set 
        */
        if(!tranferForCredit.isEmpty()){
            update tranferForCredit;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info,'Student\'s Preliminary Transferred competencies have been marked as Transferred');
            ApexPages.addMessage(myMsg);            
            studentCompetencies = new set<Student_Competency__c>();
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Course codes entered do not correspond to any preliminary transferred student competencies. Please enter all course codes to be transferred.');
            ApexPages.addMessage(myMsg);
        } 
        getProgramCourseCompetencies(); 
    }

    public class ProgramCreditableCompetency{
        public Program_Competency__c programComp {get;set;}
        public Course_Competency__c  courseComp {get;set;} 
    }
    
    public class StudentCreditableCompetency{
        public Student_Competency__c studentComp {get;set;}
        public Course_Competency__c  courseComp {get;set;} 
    }

    public PageReference cancel() {

        String myretURL = Utility.protocolAndHost + '/' + ApexPages.currentPage().getParameters().get('id');

        system.debug('>>> >>> myretURL ' + myretURL);

        PageReference returnPage = new PageReference(myretURL);  
        //return returnPage;
        return returnPage;
    }

}