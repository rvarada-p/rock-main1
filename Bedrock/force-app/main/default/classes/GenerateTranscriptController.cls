/************************************************************************
Name  : GenerateTranscriptController
Developer: Dirk Koechner, May 2015
Description: Controller  class VF Build 'Generate Transcript' VF screen + CBL Transcript functionality

* Revision History
* Horacio Sanchez   11/18/2020     S-28164: WAS Accelerated Scan: Cross-Site Request Forgery
* Horacio Sanchez   01/29/2021     S-40982: Tempo: Update on Generate Transcript Button
* Horacio Sanchez   11/16/2021     S-73899: L2: Transcript update and Task page Layout update
* Swapna Maram      06/09/2022     S-86959: L2 SF: Generate transcript/competency buttons in lightning are adding (+) symbol to name and address
*************************************************************************/
public with sharing class GenerateTranscriptController {

    public Student_Program__c studentProgram{get;set;}
    public list<Student_Competency__c> studentCompetencies{get;set;}
    private Id studentProgramId;
    public boolean showList{get;set;}
    public boolean crsShowList{get;set;}
    public String programGrade {get;set;}
    public  map<id,CourseBasedCompetency> courseBasedCompetencies{get;set;}
    public  map<id,CourseBasedCompetency> degreeAuditCoursesCompetencies{get;set;}      // for Degree Audit
    public String logoImageURL{get;set;}
    public Decimal grandCreditValue{get;set;}
    public Datetime dateConferred{get;set;}
    public String issuedTo{get;set;}
    public String defaultIssuedTo{get;set;}
    public Decimal totalCreditEquivilants { get; set; }
    public String isOfficial { get;set; }
    public decimal gpa { get;set; }
    public String creditType{get;set;}
    public List<Student_Expertise__c> stdntExprtsList {get;set;}
    public Map<Id,List<Date>> subscptDateMap {get;set;}
    public Map<Id, Boolean> dateBoolMap {get;set;}
    public Boolean showMessage {get;set;}
    public String openHoldMessage {get;set;}
    private String issuedToParam;

    public void hasOpenHold() {
        try {
            showMessage = false;
            openHoldMessage = 'This Student has an open hold.';
            studentProgramId = ApexPages.currentPage().getParameters().get('id');
            Student_Program__c sp = [SELECT Active_Hold_Codes__c FROM Student_program__c WHERE Id =:studentProgramId];
            if (sp != null) {
                if (sp.Active_Hold_Codes__c > 0) {
                    showMessage = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'This Student has an open hold.'));
                }
            }
        } catch(Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        
    }

    /*
    *  Image Logo Url
    */
    public void getLogoImageURL(){
        //logoImageURL='/servlet/servlet.FileDownload?file=015170000004saR';
        logoImageURL='/servlet/servlet.FileDownload?file=';
        List<document> documentList=[select name from document where
                Name='LaureateLogo'];

        if(documentList.size()>0){
            logoImageURL=logoImageURL+documentList[0].id;
        }
    }
    /*
    *  Initialize values for student program and other variables used on Page
    */
    public GenerateTranscriptController(ApexPages.StandardController controller){
        hasOpenHold();
        studentProgramId = ApexPages.currentPage().getParameters().get('id');
        issuedTo = ApexPages.currentPage().getParameters().get('issuedto');
        isOfficial = ApexPages.currentPage().getParameters().get('official');

        if (issuedTo != null) {
            system.debug('>> INCOMING URL PARAM  >'+issuedTo+'<');
            //issuedTo = issuedTo.replaceAll('<br/>','<br/>');
             issuedTo=issuedTo.replaceAll('\\+', ' ');//S-86959
            system.debug('>> INCOMING URL PARAM after fix >'+issuedTo+'<');//S-86959
        }
        gpa = 0;
        programGrade = '';
        totalCreditEquivilants = 0;
        studentProgramId = controller.getId();
        studentCompetencies = new list<Student_Competency__c>();
        courseBasedCompetencies = new map<id,CourseBasedCompetency>();
        degreeAuditCoursesCompetencies = new map<id,CourseBasedCompetency>();
        getLogoImageURL();
        showList = false;
        crsShowList = false;
        studentProgram = [Select id,name, Degree_Conferral_Date__c , Program__r.Name, Program__c, Number_of_Competencies__c, Number_of_Competencies_Transferred__c,
                Number_of_Competencies_Completed__c, Program__r.Program_Major__c, Program__r.Degree_Level__c, Degree_Status__c,
                Student__r.Name,Student__r.Birthdate,Student__r.SSN__c, Student__c,Student__r.CBL_Student_ID__c,
                Student__r.Maiden_Name__c,Student__r.MailingCountry,All_Credits_Completed__c, Student__r.MailingPostalCode, Student__r.MailingState, Student__r.MailingCity,
                Student__r.MailingStreet,GPA__c, Program__r.Parent_Program_Name__c, Program__r.Specialization__c, Program__r.Credit_type__c,
                student__r.middle_name__c, Student_First_Name__c, Student_Last_Name__c, student__r.mailingStateCode, Honors__c
        From Student_Program__c where id=:studentProgramId];

        If(studentProgram.GPA__c != null){
            gpa = studentProgram.GPA__c.setScale(2, RoundingMode.HALF_UP);
        }
        totalCreditEquivilants = studentProgram.All_Credits_Completed__c;
        dateConferred = studentProgram.Degree_Conferral_Date__c;
        studentCompetencies = getAllStudentCompetencies();

        String issuedToName;
        if (studentProgram.student__r.middle_name__c != null) {
            issuedToName = studentProgram.Student_First_Name__c + ' ' + studentProgram.student__r.middle_name__c + ' ' + studentProgram.student_last_name__c;
        } else {
            issuedToName = studentProgram.Student_First_Name__c + ' ' + studentProgram.student_last_name__c;
        }
        
        /*defaultIssuedTo = issuedToName +
                '\n'+studentProgram.Student__r.MailingStreet+
                '\n'+studentProgram.Student__r.MailingCity+', '+studentProgram.Student__r.MailingStateCode +
                '\n'+studentProgram.Student__r.MailingPostalCode+
                '\n'+studentProgram.Student__r.MailingCountry;*/
        defaultIssuedTo = issuedToName +
                '\n'+studentProgram.Student__r.MailingStreet+
                '\n'+studentProgram.Student__r.MailingCity+', ' + studentProgram.Student__r.MailingStateCode +
                ' ' + studentProgram.Student__r.MailingPostalCode +
                ' ' + studentProgram.Student__r.MailingCountry;
        system.debug('before'+defaultIssuedTo);
        defaultIssuedTo = defaultIssuedTo.replaceAll('\\+','');
          system.debug('after '+defaultIssuedTo);
        issuedToParam = issuedToName + '<br />' + studentProgram.Student__r.MailingStreet + '<br />' + studentProgram.Student__r.MailingCity+', ' + studentProgram.Student__r.MailingStateCode +
                ' ' + studentProgram.Student__r.MailingPostalCode +
                ' ' + studentProgram.Student__r.MailingCountry;

        getAllCourseBasedCompetencies();
        getCreditType();
        
        if (issuedTo != null) {
            List<String> defaultIssuedToSplit = issuedTo.split('\n');
            issuedTo = String.join(defaultIssuedToSplit, '<br />');
        } else {
            issuedTo = issuedToParam;
        }

        stdntExprtsList = [Select id, Total_CE__c, Pseudo_CE__c, Pseudo_Course__c, Grade__c,
                Area_of_Expertise__r.Course_Code__c, Area_of_Expertise__r.Name,IsAchieved__c,
        (Select id, Competency_Code__c, Competency_Credit_Equivalency__c,
                Status__c, Competency__r.Display_Name__c, Completed_Date__c,
                Pseudo_CE__c, Student_Subscription_Achieved_In__c,
                Student_Subscription_Achieved_In__r.Start_Date__c,
                Student_Subscription_Achieved_In__r.End_Date__c
        from Student_Competencies__r WHERE Competency_Code__c != 'TL000')
        from Student_Expertise__c
        where Student_Program__c = :studentProgramId
        ];
        //and IsAchieved__c = true];
        subscptDateMap = new Map<Id,List<Date>>();
        dateBoolMap = new Map<Id,Boolean>();
        if(!stdntExprtsList.isEmpty()){
            for(Student_Expertise__c stdntExprObj : stdntExprtsList){
                //subscptDateMap.put(stdntExprObj.Id , new List<Date>{});
                dateBoolMap.put(stdntExprObj.Id , true);
                Date maxStartDate = null;
                if(!stdntExprObj.Student_Competencies__r.isEmpty()){
                    for(Student_Competency__c stdntCompObj : stdntExprObj.Student_Competencies__r){
                        if(maxStartDate == null && stdntCompObj.Student_Subscription_Achieved_In__c != null){
                            maxStartDate = stdntCompObj.Student_Subscription_Achieved_In__r.Start_Date__c;
                            dateBoolMap.put(stdntExprObj.Id , false);
                            subscptDateMap.put(stdntExprObj.Id , new List<Date>{stdntCompObj.Student_Subscription_Achieved_In__r.Start_Date__c, stdntCompObj.Student_Subscription_Achieved_In__r.End_Date__c});
                        }else if(stdntCompObj.Student_Subscription_Achieved_In__c != null && maxStartDate < stdntCompObj.Student_Subscription_Achieved_In__r.Start_Date__c){
                            maxStartDate = stdntCompObj.Student_Subscription_Achieved_In__r.Start_Date__c;
                            dateBoolMap.put(stdntExprObj.Id , false);
                            subscptDateMap.put(stdntExprObj.Id , new List<Date>{stdntCompObj.Student_Subscription_Achieved_In__r.Start_Date__c, stdntCompObj.Student_Subscription_Achieved_In__r.End_Date__c});
                        }
                        System.debug('maxStartDate::'+maxStartDate);
                        System.debug('StartDate::'+stdntCompObj.Student_Subscription_Achieved_In__r.Start_Date__c);
                        System.debug('endDate::'+stdntCompObj.Student_Subscription_Achieved_In__r.End_Date__c);
                    }
                }
            }
            System.debug('dateBoolMap::'+dateBoolMap);
            System.debug('subscptDateMap::'+subscptDateMap);
        }
    }

    //this method returns the credit type for the student program
    public void getCreditType(){
        try{
            if((studentProgram.Program__r.Credit_type__c)!=null){
                creditType = studentProgram.Program__r.Credit_type__c;
            }
        }
        catch(Exception exp) {
            System.debug(exp);
        }

        system.debug('creditType :' + creditType );
    }

    private list<Student_Competency__c> getAllStudentCompetencies(){
        for(Student_Competency__c studentCompetency:[Select Transferring_Institution__c, Student_Program__c, Status__c,
                Number_of_Assessment_Attempts__c,Competency_Credit_Equivalency__c, Name, Completed_Date__c, Competency__c, Competency__r.name, Competency__r.Description__c,
                Competency_Code__c, Average_Difficulty_Level__c,Student_Expertise__r.Area_of_Expertise__c,
                Student_Expertise__r.Area_of_Expertise_Name__c, Pseudo_CE__c From Student_Competency__c
        where Student_Program__c =:studentProgramId and  IsCompleted__c = true
        and Competency_Code__c!='CRO01' AND Competency_Code__c != 'TL000' order by Completed_Date__c]){
            studentCompetencies.add(studentCompetency);
            showList = true;
        }
        return studentCompetencies;
    }

    private void getAllCourseBasedCompetencies(){
        Map<Id,list<Student_Competency__c>> crsStudentCompetencies = new Map<Id,list<Student_Competency__c>>();
        Map<Id,Student_Competency__c> mapCompId_StuComp = new Map<Id,Student_Competency__c>();

        map<String,decimal> gradeEque = new map<String,decimal>();
        gradeEque.put('Transferred',0);
        gradeEque.put('Fulfilled',0);
        gradeEque.put('Achieved',2);
        gradeEque.put('Mastered',3);

        Set<Id> studentProgramNotCompleted = new Set<Id>();

        for(Student_Competency__c studentCompetency:[Select IsCompleted__c ,Transferring_Institution__c, Student_Program__c, Status__c,
                Number_of_Assessment_Attempts__c, Name, Completed_Date__c, Competency__c, Competency__r.name,
                Competency_Code__c, Average_Difficulty_Level__c,Student_Expertise__r.Area_of_Expertise__c,
                Student_Expertise__r.Area_of_Expertise_Name__c, Pseudo_CE__c
        From Student_Competency__c
        where
        Is_Enrolled__c = true  AND Competency_Code__c != 'TL000'
        and Student_Program__c =:studentProgramId aND status__C <> 'Not Achieved'   order by Completed_Date__c]){

            mapCompId_StuComp.put(studentCompetency.Competency__c, studentCompetency);


            if(!crsStudentCompetencies.containsKey(studentCompetency.Competency__c)){
                crsStudentCompetencies.put(studentCompetency.Competency__c,new list<Student_Competency__c>());
            }

            crsStudentCompetencies.get(studentCompetency.Competency__c).add(studentCompetency);
            /*
            * that NONE of the competencies appear for courses that are not 'complete'. In other words: ALL competencies need
            * to be completed in order for the course to appear on the transcript with a grade.
            */
            if(!gradeEque.containsKey(studentCompetency.Status__c) || !studentCompetency.IsCompleted__c){
                if(!studentProgramNotCompleted.contains(studentCompetency.Competency__c)){
                    studentProgramNotCompleted.add(studentCompetency.Competency__c);
                    
                    //system.debug('Student Comp NOT completed:'+studentCompetency.Competency__r.Name+'('+studentCompetency.Competency__c+')');
                }
            }

        }

        Map<Id,list<courseCreditStudentCompetency>> courseCreditStudentCompetencies = new Map<Id,list<courseCreditStudentCompetency>>();


        for(Id comp:crsStudentCompetencies.keySet()){
            list<courseCreditStudentCompetency> crsstdComps = new list<courseCreditStudentCompetency>();
            for(Student_Competency__c stdComp:crsStudentCompetencies.get(comp)){
                courseCreditStudentCompetency crsCStdComp = new courseCreditStudentCompetency();
                crsCStdComp.studentComp = stdComp;
                crsCStdComp.creditEquivalency =0.0;
                crsstdComps.add(crsCStdComp);
            }
            if(!courseCreditStudentCompetencies.containsKey(comp)){
                courseCreditStudentCompetencies.put(comp,new list<courseCreditStudentCompetency>());
            }
            courseCreditStudentCompetencies.get(comp).addAll(crsstdComps);

        }
        
        Decimal grandTotalCredit = 0.0;
        Decimal grandTotalCreditEqual = 0.0;
        set<Id> courseWithIncompleteCompetencies = new set<Id>();

        if(!courseCreditStudentCompetencies.isEmpty()){
            map<Id, List<Course_Competency__c>> map_completedCourseId_Comps = new map<Id, List<Course_Competency__c>>();

            for(Course_Competency__c courseComp:[Select SystemModstamp, Name, Competency__r.Credit_Equivalency__c, CreatedDate,
                    Course__r.Name, Course__c, Course__r.Total_Credits__c, Competency__r.Name, Competency__r.Code__c, Competency__c
            From Course_Competency__c where  Competency__c in:courseCreditStudentCompetencies.keySet()
            order by Course__r.Name, Competency__r.Code__c]){

                /*
ALL competencies need to be completed in order for the course to appear on the transcript with a grade.
*/

                if(studentProgramNotCompleted.contains(courseComp.Competency__c)){
                    courseWithIncompleteCompetencies.add(courseComp.Course__c);
                }

                // create course-competency map
                if(!map_completedCourseId_Comps.containsKey(courseComp.Course__c)) {
                    map_completedCourseId_Comps.put(courseComp.Course__c,new List<Course_Competency__c>());
                }
                List<Course_Competency__c> cusComp = new List<Course_Competency__c>();
                cusComp = map_completedCourseId_Comps.get(courseComp.Course__c);
                cusComp.add(courseComp);
                map_completedCourseId_Comps.put(courseComp.Course__c, cusComp);
            }

            list<Student_Subscription__c> studentSubscriptionForStdProgram = getAllStudentSubscription(studentProgramId);

            //
            // Iterate through all completed Courses
            //
            System.debug(' map_completedCourseId_Comps.keySet() ::'+ map_completedCourseId_Comps.keySet() );
            System.debug(' map_completedCourseId_Comps.keySet() ::'+ map_completedCourseId_Comps.keySet().size() );
            for(Id myCourse: map_completedCourseId_Comps.keySet() ) {
                System.debug('----->myCourse'+myCourse);
                // only process Courses that are complete
                if(!courseWithIncompleteCompetencies.contains(myCourse)){

                    Decimal totalCredit = 0.0;
                    Decimal totalCreditEqual = 0.0;
                    DateTime maxCompletedDate = null;
                    Decimal totalCreditsPerCourse = 0.0;
                    for(Course_Competency__c courseComp: map_completedCourseId_Comps.get(myCourse)) {

                        Student_Competency__c crsStudComp = mapCompId_StuComp.get(courseComp.Competency__c);
                        if(courseComp.Competency__r.Credit_Equivalency__c != null
                                && crsStudComp.Status__c !=null && gradeEque.get(crsStudComp.Status__c) != null ){

                            totalCredit += courseComp.Competency__r.Credit_Equivalency__c*gradeEque.get(crsStudComp.Status__c);
                            totalCreditEqual+= courseComp.Competency__r.Credit_Equivalency__c;
                        }
                        /*
                        1) For each course, get the MAX(Completed_Date__c) for all competencies in that course
                                [ in our example, for course 6160 = 10/09/2014]
                        2) Find the student subscription in which that date falls BETWEEN:
                                Student_Subscription__c.Start_Date__c <= MAX(Completed_Date__c) <= Student_Subscription__c.End_Date__c
                                [for our example above this would be student subscription: SUB-1033, which as start date 10/7/2014 and end date 2/1/2015]
                        Term Dates = "10/7/2014 to 2/1/2015"
                        */

                        if(maxCompletedDate == null){
                            maxCompletedDate = crsStudComp.Completed_Date__c;
                        }else if(maxCompletedDate <= crsStudComp.Completed_Date__c){
                            maxCompletedDate = crsStudComp.Completed_Date__c;
                        }


                        // Iteratively populate UI object
                        if(!courseBasedCompetencies.containsKey(myCourse)){
                            CourseBasedCompetency crsBasedCompetency = new CourseBasedCompetency();
                            crsBasedCompetency.courseName = courseComp.Course__r.Name;
                            crsBasedCompetency.courseId = courseComp.Course__c;
                            //crsBasedCompetency.totalCredits = courseComp.Course__r.Total_Credits__c;
                            //totalCreditEquivilants += courseComp.Course__r.Total_Credits__c;
                            courseBasedCompetencies.put(courseComp.Course__c,crsBasedCompetency);
                            degreeAuditCoursesCompetencies.put(courseComp.Course__c,crsBasedCompetency);
                        }
                        courseCreditStudentCompetency cCSC = new courseCreditStudentCompetency();

                        // Looking for Pseudo Competencies at the Student Competency Level
                        for (Student_Competency__c checkIfPseudoSC : studentCompetencies) {
                            if (courseComp.Competency__c == checkIfPseudoSC.Competency__c) {
                                if (checkIfPseudoSC.Status__c == 'Transferred' && checkIfPseudoSC.Pseudo_CE__c != null) {
                                    cCSC.creditEquivalency = checkIfPseudoSC.Pseudo_CE__c;
                                    totalCreditsPerCourse += checkIfPseudoSC.Pseudo_CE__c;
                                    //totalCreditEquivilants += checkIfPseudoSC.Pseudo_CE__c;
                                } else {
                                    cCSC.creditEquivalency = courseComp.Competency__r.Credit_Equivalency__c;
                                    totalCreditsPerCourse += courseComp.Competency__r.Credit_Equivalency__c;
                                    //totalCreditEquivilants += courseComp.Competency__r.Credit_Equivalency__c;
                                }
                            }
                        }

                        cCSC.studentComp = crsStudComp;
                        courseBasedCompetencies.get(myCourse).courseCreditStudentCompetencies.add(cCSC);
                        //degreeAuditCoursesCompetencies.get(myCourse).courseCreditStudentCompetencies.add(cCSC);


                    } // for(Course_Competency__c courseComp: map_completedCourseId_Comps.get(myCourse))


                    Date termStartDate = null;
                    Date termEndDate = null;

                    system.debug('.  Max Completed Date:'+maxCompletedDate);
                    for(Student_Subscription__c stdSubscr:studentSubscriptionForStdProgram){
                        if(maxCompletedDate >= stdSubscr.Start_Date__c && maxCompletedDate <= stdSubscr.End_Date__c){
                            termStartDate = stdSubscr.Start_Date__c ;
                            termEndDate = stdSubscr.End_Date__c;
                        }
                    }

                    Decimal creditValue = 0.0;

                    if(totalCreditEqual != 0){
                        creditValue = totalCredit/totalCreditEqual;
                    }
                    system.debug('creditValue:' + creditValue );
                    String courseGrade = '';
                    if(creditValue >=2.5 && creditValue<=3){
                        courseGrade = 'A';
                    }else if(creditValue >=2 && creditValue<=2.49){
                        courseGrade = 'B';
                    }else if(creditValue == 0){
                        courseGrade = 'TR';
                    }else{
                        courseGrade = '--';
                    }

                    system.debug('***  TOTAL Grade Credits:'+totalCredit+
                            ' ---  Total Credit Equiv:'+totalCreditEqual+
                            ' ---  FINAL course GPA:'+creditValue+' ---  Course Grade:'+courseGrade);


                    // Iteratively populate UI object
                    if(courseBasedCompetencies.containsKey(myCourse)){
                        courseBasedCompetencies.get(myCourse).courseGrade = courseGrade;
                        courseBasedCompetencies.get(myCourse).termStartDate = termStartDate;
                        courseBasedCompetencies.get(myCourse).termEndDate = termEndDate;
                        courseBasedCompetencies.get(myCourse).totalCredits = totalCreditsPerCourse;

                        degreeAuditCoursesCompetencies.get(myCourse).courseGrade = courseGrade;
                        degreeAuditCoursesCompetencies.get(myCourse).termStartDate = termStartDate;
                        degreeAuditCoursesCompetencies.get(myCourse).termEndDate = termEndDate;
                        degreeAuditCoursesCompetencies.get(myCourse).totalCredits = totalCreditsPerCourse;
                    }


                    if(creditValue != 0){
                        grandTotalCredit += totalCredit;
                        grandTotalCreditEqual += totalCreditEqual;
                    }
                } // if(!courseWithIncompleteCompetencies.contains(courseComp.Course__c))
                else
                {
                    // put 'incomplete' courses in degree audit map

                    ///
                    ///
                    ///
                    system.debug('map_completedCourseId_Comps:' + map_completedCourseId_Comps);
                    for(Course_Competency__c courseComp: map_completedCourseId_Comps.get(myCourse)) {

                        system.debug('>>>>>>>>>>>>>>>> Processing:  Course:'+courseComp.Course__r.Name+
                                '  Competency:'+courseComp.Competency__r.Name);


                        Student_Competency__c crsStudComp = mapCompId_StuComp.get(courseComp.Competency__c);

                        // Iteratively populate UI object
                        if(!degreeAuditCoursesCompetencies.containsKey(myCourse)){
                            CourseBasedCompetency crsBasedCompetency = new CourseBasedCompetency();
                            crsBasedCompetency.courseName = courseComp.Course__r.Name;
                            crsBasedCompetency.courseId = courseComp.Course__c;
                            crsBasedCompetency.courseGrade = 'Not Met';
                            crsBasedCompetency.termStartDate = null;
                            crsBasedCompetency.termEndDate = null;

                            degreeAuditCoursesCompetencies.put(courseComp.Course__c,crsBasedCompetency);
                        }

                        courseCreditStudentCompetency cCSC = new courseCreditStudentCompetency();
                        cCSC.creditEquivalency = courseComp.Competency__r.Credit_Equivalency__c;
                        cCSC.studentComp = crsStudComp;
                        degreeAuditCoursesCompetencies.get(myCourse).courseCreditStudentCompetencies.add(cCSC);


                    } // for(Course_Competency__c courseComp: map_completedCourseId_Comps.get(myCourse))

                    ///
                    ///
                    ///

                }

            } // for(Id myCourse: map_completedCourseId_Comps.keySet() )




        }

        if(!courseBasedCompetencies.isEmpty()){
            crsShowList= true;
            grandCreditValue = 0.0;

            if(grandTotalCreditEqual != 0){
                system.debug('::grandTotalCredit:::'+grandTotalCredit);
                system.debug('::grandTotalCreditEqual:::'+grandTotalCreditEqual);
                grandCreditValue = grandTotalCredit/grandTotalCreditEqual;
                system.debug('::grandCreditValue:::'+grandCreditValue);
                grandCreditValue = grandCreditValue.setScale(2, RoundingMode.HALF_UP);
                system.debug('::grandCreditValue:::'+grandCreditValue);
            }

            system.debug('::grandCreditValue:::'+grandCreditValue);
            if(grandCreditValue >=2.5 && grandCreditValue<=3){
                programGrade = 'A';
            }else if(grandCreditValue >=2 && grandCreditValue<=2.49){
                programGrade = 'B';
            }else if(grandCreditValue == 0){
                programGrade = 'TR';
            }else{
                programGrade = '--';
            }

            system.debug('*****  GRAND TOTAL Credits:'+grandTotalCredit+
                    ' ---  GRAND Total Credit Equiv:'+grandTotalCreditEqual+
                    ' ---  FINAL PROGRAM GPA:'+grandCreditValue+' ---  PROGRAM Grade:'+programGrade);
        } 
    }
    
    public PageReference redirectToCBLTranscript() {
        String encodedString = EncodingUtil.urlEncode(defaultIssuedTo,'UTF-8');
        PageReference page = new PageReference('/apex/CBL_transcript?id='+studentProgramId+'&issuedto='+encodedString);
        page.setRedirect(true);
        return page;  
    }
    
    public PageReference redirectToCourseTranscript() {
        String encodedString = EncodingUtil.urlEncode(defaultIssuedTo,'UTF-8');
        PageReference page = new PageReference('/apex/Course_Based_transcript?id='+studentProgramId+'&official=true&issuedto='+encodedString);
        page.setRedirect(true);
        return page;  
    }
    
    public PageReference redirectToUnofficialCourseTranscript() {
        String encodedString = EncodingUtil.urlEncode(defaultIssuedTo,'UTF-8');
        PageReference page = new PageReference('/apex/Course_Based_transcript?id='+studentProgramId+'&official=false&issuedto='+encodedString);
        page.setRedirect(true);
        return page;
    }
    
    public PageReference redirectToCourseOnlyTranscript() {
        String encodedString = EncodingUtil.urlEncode(defaultIssuedTo,'UTF-8');
        PageReference page = new PageReference('/apex/Course_only_transcript?id='+studentProgramId+'&official=false&issuedto='+encodedString);
        page.setRedirect(true);
        return page;  
    }

    private list<Student_Subscription__c> getAllStudentSubscription(Id studentProgramId){
        list<Student_Subscription__c> studentSubscriptions = new list<Student_Subscription__c>();
        for(Student_Subscription__c stdSub:[Select Student_Program__c, Start_Date__c, End_Date__c
        From Student_Subscription__c where Student_Program__c =:studentProgramId]){
            studentSubscriptions.add(stdSub);
        }
        return studentSubscriptions;
    }

    public class CourseBasedCompetency{
        public String courseName{get;set;}
        public Id courseId{get;set;}
        public String courseGrade{get;set;}
        public Date termStartDate{get;set;}
        public Date termEndDate{get;set;}
        public double totalCredits { get;set; }
        public list<courseCreditStudentCompetency> courseCreditStudentCompetencies{get;set;}
        public CourseBasedCompetency(){
            courseCreditStudentCompetencies = new list<courseCreditStudentCompetency>();
            totalCredits = 0;
        }
    }

    public class courseCreditStudentCompetency{
        public Student_Competency__c studentComp{get;set;}
        public Decimal creditEquivalency{get;set;}
    }



}