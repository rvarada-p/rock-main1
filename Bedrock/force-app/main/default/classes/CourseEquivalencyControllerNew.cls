/*******************************************************************
Name  : CourseEquivalencyControllerNew 
Author: Sushant (Laureate)
Date  : August 2, 2017
Description: Controller extension class for CourseEquivalency Page
*************************************************************************/

public with sharing class CourseEquivalencyControllerNew {

    //public List<Course_Competency__c> tOppLst{get;set;}
    public String transferInstitution{get;set;}
    public boolean pShowList{get;set;}
    public boolean sShowList{get;set;}
    public Student_Program__c studentProgram{get;set;}
    public Id studentProgramId;
    //private set<Student_Competency__c> studentCompetencies;
    public String SelectedCreditType{get;set;}
    public List<ProgramCourseDetails> programCourses { get; set;}
    public List<Program_Courses__c> programCourse{ get; set;}
    public List<Id> selectedCompIds{get;set;}
    public List<Course_Competency__c> courseComps{get;set;}
    public List<Student_Competency__c> studComps{get;set;}
    public List<studentCompDetails> studentCompCredit { get; set;}
    public Boolean FlagH { get; set;}
    public Boolean FlagT { get; set;}
    public Boolean FlagN { get; set;}
    public Boolean FlagF { get; set;}
    public Boolean DisplayInstitution { get; set;} 
    public Boolean CreditTypeSelected { get; set;}
    public Boolean undoFlag { get; set;}
    public List<Student_Competency__c> preTransToTrans{get;set;}
    public String objType{get;set;}
    public Student_Competency__c compToUpdate;
    public Student_Competency__c compBeforeUpdate;
    public list<Student_Competency__c> PriorCompetencyList;
    public Map<ID, String> compCourses;
   
    
    public CourseEquivalencyControllerNew(ApexPages.StandardController controller){
        
        try {
            
            studentProgramId = ApexPages.currentPage().getParameters().get('id');
            if(studentProgramId!=null) {
                system.debug('ID: ' + studentProgramId);
                objType = studentProgramId.getSobjectType().getDescribe().getName();
                System.debug('>>> Object Type is ' + objType);
                //studentCompetencies = new set<Student_Competency__c>();
        
                programCourses = new list<ProgramCourseDetails>();
                studentCompCredit = new list<studentCompDetails>();
                
                if (objType == 'Student_Program__c'){  // called from Student_Program__c screen
                    list<Student_Program__c> lstCurrentSP = new list<Student_Program__c>([Select id,name,Student__r.Name,Student__c, Program__r.Name, Program__c From Student_Program__c where id=:studentProgramId LIMIT 1]);
                    if(!lstCurrentSP.isEmpty()) {
                        studentProgram = lstCurrentSP.get(0);
                        pShowList = false;
                        sShowList = false;
                        studentProgramId = studentProgram.Id;
                        system.debug('>>>studentProgram.Program__c:' + studentProgram.Program__c);
                    }
                    
                }else{  // called from opportunity
                    Opportunity myOpp = new Opportunity();
                    list<Opportunity> lstCurrentOpp = new list<Opportunity>([Select Student_Program__c,Primary_Program__c, Contact__c from Opportunity where id=:studentProgramId LIMIT 1]);
                    if(!lstCurrentOpp.isEmpty()) {
                        myOpp = lstCurrentOpp.get(0);
                        system.debug('myOpp.Student_Program__c:' + myOpp.Student_Program__c);
                        studentProgram = new Student_Program__c();
                        studentProgram.Program__c = myOpp.Primary_Program__c;
                        studentProgram.Student__c = myOpp.Contact__c; 
                        system.debug('before studentProgramId:' + studentProgramId ); 
                        system.debug('myOpp.Student_Program__c:' + myOpp.Student_Program__c); 
                        studentProgramId = myOpp.Student_Program__c;         
                        system.debug('after studentProgramId:' + studentProgramId );
                    }
                } 
        
               // application  = (Opportunity)controller.getRecord();   
                SelectedCreditType = '';
                FlagH = false;
                FlagT = false;
                FlagN = false;
                FlagF = false;
                DisplayInstitution = false;
                CreditTypeSelected = false;
                undoFlag = false;
                system.debug('studentProgramId:' + studentProgramId );
                List<Course_Competency__c> courseName = new List<Course_Competency__c>([SELECT Competency__c,CourseName__c FROM Course_Competency__c ]);
                if(!courseName.isEmpty()) {
                    //Create a map of competency_id to course
                    compCourses = new Map<ID, String>();
                    for(Course_Competency__c itr: courseName){
                        compCourses.put(itr.Competency__c,itr.CourseName__c) ;
                    }
                }
                else {
                  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No Courses setup for this Program'));  
                }
            }
        }
        catch(Exception exp) {
            System.debug('Exception: ' + exp);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,exp.getMessage()));
        }
    }
    
   
    
    //Create the dropdown list
     public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('NONE','None'));
        options.add(new SelectOption('FULFILLED','Fulfilled'));
        options.add(new SelectOption('Transferred','Transfer'));
        options.add(new SelectOption('PRELIMINARY TRANSFER','Preliminary Transfer'));
        options.add(new SelectOption('FLIP TO OFFICIAL TRANSFER','Flip to Official Transfer'));

        return options;
    }
    
    //Set flags after credit type selected
    public PageReference setCreditTypeFlag(){
    try{
        CreditTypeSelected = true;
        undoFlag = false;
         if(SelectedCreditType == 'FLIP TO OFFICIAL TRANSFER'){
            DisplayInstitution = false;
        }
        else if(SelectedCreditType == 'NONE'){
            DisplayInstitution = false;
            CreditTypeSelected = false;
        }
        else{
            DisplayInstitution = true;
        }
        FlagH = false;
        FlagT = false;
        FlagN = false;
        FlagF = false;
        }
        catch(Exception exp) {
            system.debug(exp);
            }
        
        return null;
    }
    
    //Method to get the details to be displayed in the Program course section
    public PageReference getDetails(){
    try{
            system.debug(transferInstitution);
            if(String.isBlank(transferInstitution) && SelectedCreditType != 'FLIP TO OFFICIAL TRANSFER'){
                system.debug('Institution is null');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'You must specify an Institution'));
            }
            else{
             if(SelectedCreditType == 'FLIP TO OFFICIAL TRANSFER'){
                FlagH = false;
                FlagT = true;
                FlagN = true;
                FlagF = false;
                }
              else if(SelectedCreditType == 'NONE'){
                FlagH = false;
                FlagN = false;
                FlagT = false;
                FlagF = false;
                }
              else{
                FlagH = true;
                FlagN = false;
                FlagT = false;
                FlagF = false;
                }
              if(SelectedCreditType == 'FULFILLED'){
                FlagF = true;
                }

        programCourses = new list<ProgramCourseDetails>();
        studentCompCredit = new list<studentCompDetails>();
       
        system.debug('Flag is set to :' + FlagH);
        system.debug('Student Id is:' + studentProgramId );
        //tOppLst=new List<Course_Competency__c>();
        //string s = '';
        List<Id> programCourseIds = new List<Id>();
        
        system.debug('The value is' +  studentProgram.Program__c);
        programCourse = new List<Program_Courses__c>([SELECT Id, Course__c, Course__r.Id FROM Program_Courses__c WHERE Program__c = : studentProgram.Program__c ]);
        for(Program_Courses__c pc: programCourse) {
            programCourseIds.add(pc.Course__r.Id);
        }
        system.debug('>>>programCourseIds:' + programCourseIds);
        courseComps = new List<Course_Competency__c>([SELECT CourseName__c, Course__r.Total_Credits__c, Credit_Equiv__c, competencyName__c, Competency__c  FROM Course_Competency__c WHERE Course__c IN :programCourseIds ORDER BY CourseName__c ASC]);
        system.debug('>>>courseComps:' + courseComps);
        Set<String> S1 = new Set<String>();
        for(Course_Competency__c cc : courseComps) {
            //s1.add(cc.CourseName__c);
            if(s1.contains(cc.CourseName__c)){
                system.debug('Course name already exists in set');
            }
            else{
                s1.add(cc.CourseName__c);
                ProgramCourseDetails programCourseCompDetail = new ProgramCourseDetails();
                //programCourseCompDetail.competencyName = cc.competencyName__c;
                programCourseCompDetail.courseName = cc.CourseName__c;
                programCourseCompDetail.creditType = SelectedCreditType;
                programCourseCompDetail.creditEquivilant = cc.Course__r.Total_Credits__c;  
                programCourseCompDetail.compId = cc.Competency__c;
                programCourses.add(programCourseCompDetail);    
                //s += '\n' + cc;
                //system.debug(s);    
            }
        }
        system.debug('>>>programCourses:' + programCourses);
        
        
        if(FlagT == true){
            List<Course_Competency__c> courseName = new List<Course_Competency__c>([SELECT Competency__c,CourseName__c FROM Course_Competency__c ]);
        //Create a map of competency_id to course
        compCourses = new Map<ID, String>();
        for(Course_Competency__c itr: courseName){
            compCourses.put(itr.Competency__c,itr.CourseName__c) ;
            
        }
        
        //string p = '';
        preTransToTrans = new List<Student_Competency__c>([SELECT competency_code__c,Competency_Credit_Equivalency__c,competency_title__c,Name,status__c,Id, competency__c, student_ID__c,Transferring_Institution__c, Student_Expertise__r.Pseudo_Course__c  FROM Student_Competency__c where Student_Program__c  = : studentProgramId AND status__c = 'Preliminary Transfer']);
        for(Student_Competency__c cc : preTransToTrans) {
            studentCompDetails studCompDetail = new studentCompDetails();
            studCompDetail.StudCompName = cc.Name;
            studCompDetail.CompetencyName = cc.competency_title__c;
            studCompDetail.status = cc.status__c;
            system.debug('Id passed:' + cc.competency__c);
            system.debug('Course Name is' + compCourses.get(cc.competency__c));
            studCompDetail.courseName = compCourses.get(cc.competency__c);
            studCompDetail.compCode = cc.competency_code__c;
            studCompDetail.creditEquivilant = cc.Competency_Credit_Equivalency__c;
            studCompDetail.compId = cc.competency__c;
            studCompDetail.TransferringInstitution = cc.Transferring_Institution__c;
            studCompDetail.studentExpertisePseudoCE = cc.Student_Expertise__r.Pseudo_Course__c;
            //p += '\n' + cc;
            //system.debug(p);
            studentCompCredit.add(studCompDetail);
        }
            if(studentCompCredit.isEmpty()){
                FlagT = false;
            }
        }       
        }
        }
        catch(Exception exp) {
            system.debug(exp);
        }
        return null;
    }
    

    public PageReference saveRecords() {
        try {
            List<Student_Competency__c> lstUpdatePseudoCE = new list<Student_Competency__c>();
            System.debug('Count of records: ' + studentCompCredit.size());
            for(studentCompDetails sc : studentCompCredit) {
                System.debug('SC Credits: ' + sc.pseudoCE);
                System.debug('SC ID: ' + sc.scId);
                if(sc.scId!=null && sc.pseudoCE!=0) {
                    lstUpdatePseudoCE.add(new Student_Competency__c(Id = sc.scId, Pseudo_CE__c = sc.pseudoCE));
                }
                //if (sc.status == 'Transferred' || sc.status == 'Fulfilled') {
                //    sc.isCompleted = true;
                //}
            }
            if(!lstUpdatePseudoCE.isEmpty())  {
                update lstUpdatePseudoCE;
            }
            System.debug('List of SCs: ' + lstUpdatePseudoCE);
        }
        catch(Exception exp) {

        }
        return null;
    }

    //method called after clicking save
    public PageReference updateRecords(){
        try{
        FlagN = true;
        string s = '';
        selectedCompIds = new List<Id>();
        List<String> selectedCourses = new List<String>();
        //new list of records if they are selected
        List<ProgramCourseDetails> selectedRecords = new List<ProgramCourseDetails>();
        system.debug('List of selected competency Ids is:' + programCourses);
        //Create a map of coursename with grade
        Map<String, String> gradeCourseName = new Map<String, String>();
        for(ProgramCourseDetails pcd: programCourses){
            if(pcd.selected == true){
                selectedRecords.add(pcd);
                //selectedCompIds.add(pcd.compId);
                selectedCourses.add(pcd.courseName);
                gradeCourseName.put(pcd.courseName,pcd.grade);
                s += '\n' + pcd;
                system.debug(s);
            }
        }
        
                //List<Course_Competency__c> selectedCompIds = new List<Course_Competency__c>([SELECT Competency__c,CourseName__c FROM Course_Competency__c WHERE CourseName__c IN :selectedCourses]);
        List<Course_Competency__c> selectedComp = new List<Course_Competency__c>([SELECT Competency__c,CourseName__c FROM Course_Competency__c WHERE CourseName__c IN :selectedCourses ORDER BY CourseName__c ASC]);
        system.debug('>>>selectedComp:' + selectedComp);
        for(Course_Competency__c itr: selectedComp){
            selectedCompIds.add(itr.Competency__c) ;    
        }   
        
        
        //List<Course_Competency__c> courseName = new List<Course_Competency__c>([SELECT Competency__c,CourseName__c FROM Course_Competency__c WHERE Competency__c IN :selectedCompIds]);
        
        list<Student_Competency__c> updateCompetencyList = new list<Student_Competency__c>();
        
        PriorCompetencyList = new list<Student_Competency__c>();
        //Update student competencies with status
        String grade_value;
        string course_value;
        system.debug('selectedCompIds:' + selectedCompIds);
        //create backup for undo changes
        for(Id itr: selectedCompIds){
            compToUpdate = [SELECT status__c,Transferring_Institution__c,IsCompleted__c ,Fulfilled_Grade__c  FROM Student_Competency__c where competency__c = :itr AND Student_Program__c  = : studentProgramId ];
            if(String.isBlank(compToUpdate.Transferring_Institution__c)){
                compToUpdate.Transferring_Institution__c = null;
            }
            PriorCompetencyList.add(compToUpdate);
        }
            

        for(Id itr: selectedCompIds){
            //Student_Competency__c compToUpdate;
            system.debug('>>>line251 itr:' + itr);
            system.debug('>>>line252 studentProgramId:' + studentProgramId);
            compToUpdate = [SELECT status__c,Transferring_Institution__c,Fulfilled_Grade__c, isCompleted__c  FROM Student_Competency__c where competency__c = :itr AND Student_Program__c  = : studentProgramId ];
            compBeforeUpdate = compToUpdate;
            //Update the status to selectedcredit type
            course_value = compCourses.get(itr);
            grade_value = gradeCourseName.get(course_value);
            compToUpdate.status__c = SelectedCreditType;
            compToUpdate.Transferring_Institution__c = transferInstitution;
            compToUpdate.Fulfilled_Grade__c  = grade_value;
            if (compToUpdate.status__c == 'Transferred' || compToUpdate.status__c == 'Fulfilled') {
                compToUpdate.isCompleted__c = true;
            } else {
                compToUpdate.isCompleted__c = false;
            }
            system.debug('compToUpdate:' + compToUpdate);
            updateCompetencyList.add(compToUpdate);
            //update compToUpdate;
        }
         if(!updateCompetencyList.isEmpty()){
        update updateCompetencyList;
            }
    
        //Get details to be displayed in the student competency credit section
        system.debug('Student Id is:');
        system.debug(studentProgram.Id );
        system.debug('Student competency records are:');
        //string p = '';
        studentCompCredit = new list<studentCompDetails>();
        studComps = new List<Student_Competency__c>([SELECT competency_code__c,Competency_Credit_Equivalency__c,competency_title__c,Name,status__c,Id, competency__c, student_ID__c,Transferring_Institution__c, Student_Expertise__r.Pseudo_Course__c FROM Student_Competency__c where competency__c IN :selectedCompIds AND Student_Program__c  = : studentProgramId]);
        for(Student_Competency__c cc : studComps) {
            studentCompDetails studCompDetail = new studentCompDetails();
            studCompDetail.StudCompName = cc.Name;
            studCompDetail.CompetencyName = cc.competency_title__c;
            studCompDetail.status = cc.status__c;
            system.debug('Id passed:' + cc.competency__c);
            system.debug('Course Name is' + compCourses.get(cc.competency__c));
            studCompDetail.courseName = compCourses.get(cc.competency__c);
            studCompDetail.compCode = cc.competency_code__c;
            studCompDetail.creditEquivilant = cc.Competency_Credit_Equivalency__c;
            studCompDetail.compId = cc.competency__c;
            studCompDetail.TransferringInstitution = cc.Transferring_Institution__c;
            studCompDetail.scId = cc.Id;
            studCompDetail.studentExpertisePseudoCE = cc.Student_Expertise__r.Pseudo_Course__c;
            //p += '\n' + cc;
            //system.debug(p);
            studentCompCredit.add(studCompDetail);
        }
        FlagT = false;
     undoFlag = true; 
     } 
     catch(Exception exp) {
            system.debug(exp);
        }   
     return null; 
    }
    
    
     
     //transfer student competencies from FLIP TO OFFICIAL TRANSFER based on the selected checkboxes
     public PageReference TransferStudent() {
        try {
            string s = '';
            selectedCompIds = new List<Id>();
            //new list of records if they are selected
            List<studentCompDetails> selectedRecords = new List<studentCompDetails>();
            system.debug('>>>301 studentCompCredit:' + studentCompCredit);
            
            for (studentCompDetails pcd: studentCompCredit) {
                if (pcd.checked == true){
                    selectedRecords.add(pcd);
                    selectedCompIds.add(pcd.compId);
                    s += '\n' + pcd;
                    system.debug('Selected compd Id:' + s);
                }
            }
            PriorCompetencyList = new list<Student_Competency__c>();
            //create backup for undo changes
        
            for (Id itr: selectedCompIds) {
                compToUpdate = [SELECT status__c,Transferring_Institution__c,Fulfilled_Grade__c  FROM Student_Competency__c where competency__c = :itr AND Student_Program__c  = : studentProgramId ];
                if (String.isBlank(compToUpdate.Transferring_Institution__c)) {
                    compToUpdate.Transferring_Institution__c = null;
                }
                PriorCompetencyList.add(compToUpdate);
            }
            System.debug('Transfere  Method - PriorCompetencyList'+PriorCompetencyList);
        
            //Update student competencies with status
            list<Student_Competency__c> updateCompetencyList2 = new list<Student_Competency__c>();

            for (Id itr: selectedCompIds) {
                //Student_Competency__c compToUpdate;
                compToUpdate = [SELECT status__c FROM Student_Competency__c where competency__c = :itr AND Student_Program__c  = : studentProgramId ];
                compBeforeUpdate = compToUpdate;
                //Update the status to selectedcredit type
                compToUpdate.status__c = 'Transferred';
                compToUpdate.isCompleted__c = true;
                updateCompetencyList2.add(compToUpdate);
                //update compToUpdate;
            }
            if (!updateCompetencyList2.isEmpty()) {
                update updateCompetencyList2;
            }
    
            FlagT = false;
        
            //Refersh the list to be displayed
            studentCompCredit = new list<studentCompDetails>();
            //List<Course_Competency__c> courseName = new List<Course_Competency__c>([SELECT Competency__c,CourseName__c FROM Course_Competency__c WHERE Competency__c IN :selectedCompIds]);
        
            string p = '';
            studComps = new List<Student_Competency__c>([SELECT Pseudo_CE__c, competency_code__c,Competency_Credit_Equivalency__c,competency_title__c,Name,status__c,Id, competency__c, student_ID__c,Transferring_Institution__c, Student_Expertise__r.Pseudo_Course__c FROM Student_Competency__c where competency__c IN :selectedCompIds AND Student_Program__c  = : studentProgramId ]);
            for (Student_Competency__c cc : studComps) {
                studentCompDetails studCompDetail = new studentCompDetails();
                studCompDetail.StudCompName = cc.Name;
                studCompDetail.CompetencyName = cc.competency_title__c;
                studCompDetail.status = cc.status__c;
                studCompDetail.courseName = compCourses.get(cc.competency__c);
                studCompDetail.compCode = cc.competency_code__c;
                studCompDetail.creditEquivilant = cc.Competency_Credit_Equivalency__c;
                studCompDetail.compId = cc.competency__c;
                studCompDetail.scId = cc.Id;
                studCompDetail.TransferringInstitution = cc.Transferring_Institution__c;
                studCompDetail.pseudoCE = cc.Pseudo_CE__c;
                studCompDetail.studentExpertisePseudoCE = cc.Student_Expertise__r.Pseudo_Course__c;
                p += '\n' + cc;
                system.debug(p);
                studentCompCredit.add(studCompDetail);
            }
            undoFlag = true;
        }
        catch(Exception exp) {
            system.debug(exp);
        }
        return null;
        
     }
     
     //method to undo the changes made called after clicking the undo button 
     public PageReference undoChanges(){
     try{
         system.debug('values in the list');
         system.debug('PriorCompetencyList:' + PriorCompetencyList);
        
         if(!PriorCompetencyList.isEmpty()){
             update PriorCompetencyList;
         } 
         system.debug('undolist');
         system.debug(PriorCompetencyList);
         //Database.rollback( sp );
         
        string p = '';
        system.debug('Before deleting the list');
        system.debug(studentCompCredit);
        studentCompCredit = new list<studentCompDetails>();
        system.debug('after deleting the list');
        system.debug(studentCompCredit);
        studComps = new List<Student_Competency__c>([SELECT Pseudo_CE__c, competency_code__c,Competency_Credit_Equivalency__c,competency_title__c,Name,status__c,Id, competency__c, student_ID__c,Transferring_Institution__c, Student_Expertise__r.Pseudo_Course__c FROM Student_Competency__c where competency__c IN :selectedCompIds AND Student_Program__c  = : studentProgramId]);
        for(Student_Competency__c cc : studComps) {
            studentCompDetails studCompDetail = new studentCompDetails();
            studCompDetail.StudCompName = cc.Name;
            studCompDetail.CompetencyName = cc.competency_title__c;
            studCompDetail.status = cc.status__c;
            system.debug('Id passed:' + cc.competency__c);
            //system.debug('Course Name is' + compCourses.get(cc.competency__c));
            studCompDetail.courseName = compCourses.get(cc.competency__c);
            studCompDetail.compCode = cc.competency_code__c;
            studCompDetail.creditEquivilant = cc.Competency_Credit_Equivalency__c;
            studCompDetail.compId = cc.competency__c;
            studCompDetail.TransferringInstitution = cc.Transferring_Institution__c;
            studCompDetail.pseudoCE = cc.Pseudo_CE__c;
            
            studCompDetail.studentExpertisePseudoCE = cc.Student_Expertise__r.Pseudo_Course__c;
            p += '\n' + cc;
            system.debug(p);
            studentCompCredit.add(studCompDetail);
        }
        system.debug('after adding elements to the list');
        system.debug(studentCompCredit);
        
         undoFlag = false;  
         }
         catch(Exception exp) {
            system.debug(exp);
        }  
         return null;
     }
    
    //Inner class to display Program Course details in the first page table section
    public class ProgramCourseDetails {
        public String competencyName{ get; set; }
        public String courseName { get; set; }
        public Id courseId { get; set; }
        public String creditType { get; set; }
        public String grade { get; set; }
        public Double creditEquivilant { get; set; }
        public Id compId{get; set;}
        public Boolean selected {get; set;}
        
        
        public ProgramCourseDetails() {
        
        }
        
        public ProgramCourseDetails(String competencyName, String courseName, String courseId, String creditType, String grade, Double credits, String compId)   {
            this.competencyName = competencyName;
            this.courseName = courseName;
            this.courseId = courseId;
            this.creditType = creditType;
            this.grade = grade;
            this.creditEquivilant = credits;
            this.compId = compId;
            this.selected = false;  
        }   
    }
    
    //Inner class to display Student competency details in the second page table section
    public class studentCompDetails{
        public String TransferringInstitution{ get; set; } 
        public String StudCompName{ get; set; }
        public String CompetencyName{ get; set; }
        public String Status { get; set; }
        public String courseName { get; set; }
        public String compCode { get; set; }
        public Double creditEquivilant { get; set; }
        public Boolean checked {get; set;}
        public Id compId{get; set;}
        public Id scId { get; set; }
        public Double pseudoCE { get; set; }
        public Boolean studentExpertisePseudoCE {get; set;}
        public Boolean isCompleted {get; set;}
        
        public studentCompDetails() {
            
        }
        
        public studentCompDetails(String TransferringInstitution, String StudCompName,String CompetencyName,String Status,String courseName,String compCode,Double creditEquivilant,  String compId) {
            this.TransferringInstitution = TransferringInstitution;
            this.StudCompName = StudCompName;
            this.CompetencyName = CompetencyName;
            this.Status = Status;
            this.courseName = courseName;
            this.compCode = compCode;
            this.creditEquivilant = creditEquivilant;
            this.compId = compId;
            this.checked = false;
        }
    }
    
}