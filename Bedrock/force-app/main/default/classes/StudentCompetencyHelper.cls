/*******************************************************************
Name  : StudentCompetencyHelper
Author: Vinod (Appirio)
Date  : September 22, 2014
Description: Helper class for the object Student_Competency__c
*************************************************************************/
public without sharing class StudentCompetencyHelper {
    /* Constructor */
    public StudentCompetencyHelper(){   
    }
    
    /************************************************************************
    Method to Achieve the Skill Competency's  if the child comps are completed 
    ***************************************************************************/ 
    public  void assessSkillCompetencyCompletion(set<ID> students){
        //get a list of the students with their competencies
        List<Contact> studentsWithCompetencies = [select id, 
                                                  (
                                                      SELECT ID, IsCompleted__c, status__c, Program_Competency__c, Contact__c
                                                      FROM Student_Competencies__r
                                                  )
                                                  from contact 
                                                  where id in: students];
        
        //create a set of the program competencies these students have
        Set<Id> studentProgramCompetencies = new Set<Id>();
        for(Contact c : studentsWithCompetencies){
            for(student_competency__c studentCompetency : c.Student_Competencies__r){
                studentProgramCompetencies.add(studentCompetency.Program_Competency__c);
            }
        }
        
        //get the program competencies and their parent competencies if it is a 'skill competency'
        Map<Id, program_competency__c> skillProgramCompetenciesWithDependents =  new Map<Id, program_competency__c>(
            [
                select id, Competency_Name__c,
                (select dependent_competency__c, Dependent_Competency_Name__c  
                 from ParentCompetency_joins__r)
                from program_competency__c 
                where competency_type__c = 'Skill'
                and id in 
                (select Parent_Competency__c 
                 from Program_Competency_Join__c 
                 where Dependent_Competency__c in: studentProgramCompetencies
                )
                
            ]);
        //each of these students completed some competency
        List<Student_Competency__c> studentSkillCompetenciesForUpdate = new List<Student_Competency__c>();
        for(Contact c : studentsWithCompetencies){
            //create a list of their achieved competency ids
            Set<String> achievedCompetencyIds = new Set<String>();
            for(Student_Competency__c sc : c.student_competencies__r){
                if(sc.IsCompleted__c){
                    achievedCompetencyIds.add(sc.Program_Competency__c);
                }
            }
            //for each of the student's program competencies (student competencies)
            for(Student_Competency__c sc : c.student_competencies__r){
                //if it is a skill competency, get it and its dependents from the map
                program_competency__c skillProgramCompetencyWithDependents = skillProgramCompetenciesWithDependents.get(sc.Program_Competency__c);
                if(skillProgramCompetencyWithDependents != null){
                    //if it was in the map, if all of the dependent competencies are in the student's achieved competency sets
                    //update the competency for this student
                    Set<String> competencyIds = new Set<String>();
                    for(Program_Competency_Join__c programCompetency: skillProgramCompetencyWithDependents.ParentCompetency_joins__r){
                        competencyIds.add(programCompetency.Dependent_Competency__c);
                    }
                    //if the students achieved competencies contains all the requirements/
                    //set the student comp to achived
                    if(achievedCompetencyIds.containsAll(competencyIds)){
                        sc.status__c = 'Achieved';
                        sc.IsCompleted__c = true;
                        studentSkillCompetenciesForUpdate.add(sc);
                    }else{
                        if(sc.status__c != 'Registered'){
                            sc.status__c = 'Registered';
                            sc.IsCompleted__c = false;
                            studentSkillCompetenciesForUpdate.add(sc);
                        }
                    }
                }
            }
        }
        System.debug('>>>>>>>>>studentSkillCompetenciesForUpdate'+studentSkillCompetenciesForUpdate);
        
        If(!studentSkillCompetenciesForUpdate.isEmpty() && studentSkillCompetenciesForUpdate.Size() > 0 ){
            update studentSkillCompetenciesForUpdate;
        }
        
    }
    
    /*******************************************************************
    Method to populate StudentExpertise 
    Related task: T-321152
    ********************************************************************/
    public void populateStudentExpertise(list<Student_Competency__c> selectedStudentCompetency,set<ID> setProgramCometency){
        map<ID,ID> mapProgramCompetencyWithProgramExpertise = new map<ID,ID>();
        // get all
        for(Program_Competency__c pComp: [Select Program_Expertise__c, Id From Program_Competency__c where id in:setProgramCometency and Program_Expertise__c != null]){
            mapProgramCompetencyWithProgramExpertise.put(pComp.ID,pComp.Program_Expertise__c);
        }
        
        // NEW
        // build Contact map of their stuComps
        map<ID,list<Student_Competency__c>> mapContactId_stuCompList = new map<ID,list<Student_Competency__c>>(); 
        for(Student_Competency__c sc:selectedStudentCompetency){
            if(mapContactId_stuCompList.containsKey(sc.Contact__c)){
                list<Student_Competency__c> scList = mapContactId_stuCompList.get(sc.Contact__c);
                scList.add(sc);
                mapContactId_stuCompList.put(sc.Contact__c,scList);
            } else {
                mapContactId_stuCompList.put(sc.Contact__c, new list<Student_Competency__c>{ sc } );
            }
            
        }
        // get all program expertise with related Student Expertise
        if(!mapProgramCompetencyWithProgramExpertise.isEmpty() && !mapContactId_stuCompList.isEmpty() ){
            //
            map<ID,list<Student_Expertise__c>> mapContactId_stuExpertiseList = new map<ID,list<Student_Expertise__c>>();
            for(Student_Expertise__c stuExp: [  SELECT Id, Contact__c, Program_Expertise__c 
                                              FROM Student_Expertise__c 
                                              WHERE Contact__c IN :mapContactId_stuCompList.keySet()
                                              AND Program_Expertise__c IN :mapProgramCompetencyWithProgramExpertise.values()]){
                                                  if(mapContactId_stuCompList.containsKey(stuExp.Contact__c)){
                                                      list<Student_Competency__c> scList = mapContactId_stuCompList.get(stuExp.Contact__c);
                                                      for(Student_Competency__c sc:scList){
                                                          if(mapProgramCompetencyWithProgramExpertise.containsKey(sc.Program_Competency__c)){
                                                              if(mapProgramCompetencyWithProgramExpertise.get(sc.Program_Competency__c)==stuExp.Program_Expertise__c){
                                                                  sc.Student_Expertise__c = stuExp.Id;
                                                              }
                                                          }
                                                      }
                                                      mapContactId_stuCompList.put(stuExp.Contact__c,scList);
                                                  }
                                              }
        }
        
        
        
    }
    /*******************************************************************
    Method to Roll up number of completed competencies on the Related StudentExpertise 
    Also poluate IsAchieved__c as true if all the competency is completed
    Related task: T-322650,T-324525
    Created By: Vinod Kumar
    ********************************************************************/
    public void rollUpNumberOfCompletedCompetenciesOnStudentExpertise(set<ID> setStudentExpertiseID){
        // get all the Completed competencies
        map<ID,list<Student_Competency__c>> mapStudentExpertiseWithStudentCompetency = new map<ID,list<Student_Competency__c>>();
        for(Student_Competency__c sComp:[Select ID,Student_Expertise__c,IsCompleted__c,Status__c, Pseudo_CE__c ,Competency_Type__c
                                         from Student_Competency__c 
                                         where Student_Expertise__c in:setStudentExpertiseID]){
                                             if(!mapStudentExpertiseWithStudentCompetency.containsKey(sComp.Student_Expertise__c)){
                                                 mapStudentExpertiseWithStudentCompetency.put(sComp.Student_Expertise__c,new list<Student_Competency__c>());
                                             }            
                                             mapStudentExpertiseWithStudentCompetency.get(sComp.Student_Expertise__c).add(sComp);
                                         }
        list<Student_Expertise__c> updatedStudentExpertise = new list<Student_Expertise__c>();          
        for(ID studentExpertiseID : setStudentExpertiseID){
            decimal numberOfCompetenciesCompleted = 0;
            decimal numberOfCompetenciesTransferred = 0;
            decimal totalCompetencies = 0;
            decimal totalNonAcademicAndSkillCompetencies = 0;
            decimal totalPseudoCE = 0;
            if(mapStudentExpertiseWithStudentCompetency.containsKey(studentExpertiseID)){
                totalCompetencies = (decimal)mapStudentExpertiseWithStudentCompetency.get(studentExpertiseID).Size();
                // count no of completed competency
                for(Student_Competency__c sComp : mapStudentExpertiseWithStudentCompetency.get(studentExpertiseID)){
                    //Roll Up Sum of Pseudo CE values from SC on SE
                    If(sComp.IsCompleted__c  && sComp.Pseudo_CE__c  != Null &&( sComp.Status__c=='Transferred' || sComp.Status__c=='Fulfilled')){
                        totalPseudoCE += sComp.Pseudo_CE__c;
                    }
                    if(sComp.IsCompleted__c){
                        
                        if(sComp.Competency_Type__c == 'Academic'){
                            if(sComp.Status__c=='Transferred' || sComp.Status__c=='Fulfilled'){
                                numberOfCompetenciesTransferred++;
                            }else {
                                numberOfCompetenciesCompleted++;
                            }
                        }else{ // Rollup SUM of Complted Non Academic and Skiilled Competencies
                            totalNonAcademicAndSkillCompetencies++;
                        }
                        
                    }
                }
            }
            boolean isAllCompleted = false;
            if((numberOfCompetenciesCompleted+numberOfCompetenciesTransferred + totalNonAcademicAndSkillCompetencies) == totalCompetencies){ 
                isAllCompleted = true;
            }
            Student_Expertise__c sExper = new Student_Expertise__c(ID = studentExpertiseID);
            sExper.Number_of_Competencies_Completed__c = numberOfCompetenciesCompleted;
            sExper.Number_of_Competencies_Transferred__c = numberOfCompetenciesTransferred;
            sExper.IsAchieved__c = isAllCompleted;
            sExper.Pseudo_CE__c = totalPseudoCE;
            
            updatedStudentExpertise.add(sExper);
        }
        update updatedStudentExpertise;
    }
    /*******************************************************************
    Method to Roll up number of completed competencies and number of All the competencies on the Related StudentProgram 
    IF the child competencies is Achieved
    Related task: T-324637
    Created By: Vinod Kumar
	*
	* S-38826: Tempo: Add Preliminary Transfer Credits on Grad and UG degree audit
    ********************************************************************/
    public void rollUpNumberOfCompetenciesOnStudentProgram(set<ID> setStudentProgramID) {
        // get all the Completed competencies 
        map<ID, list<Student_Competency__c>> mapStudentProgramWithStudentCompetency = new map<ID, list<Student_Competency__c>>();
        map<ID, Decimal> mapStudentProgramWithSpTrailCredits = new map<ID, Decimal>();
        for (Student_Competency__c sComp : [
                Select ID, Status__c, Area_Of_Expertise_Name__c, Student_Program__c,Student_Program__r.Number_of_Credits_Completed_in_Trial__c, Student_Subscription_Achieved_In__c,Pseudo_CE__c,Student_Expertise__r.Pseudo_Course__c,
                        IsCompleted__c,Competency_Credit_Equivalency__c
                from Student_Competency__c
                where Student_Program__c in:setStudentProgramID
        ]) {
            if (!mapStudentProgramWithStudentCompetency.containsKey(sComp.Student_Program__c)) {
                mapStudentProgramWithStudentCompetency.put(sComp.Student_Program__c, new list<Student_Competency__c>{
                        sComp
                });
                if (sComp.Student_Program__r.Number_of_Credits_Completed_in_Trial__c != null) {
                    mapStudentProgramWithSpTrailCredits.put(sComp.Student_Program__c, sComp.Student_Program__r.Number_of_Credits_Completed_in_Trial__c);
                } else {
                    mapStudentProgramWithSpTrailCredits.put(sComp.Student_Program__c, 0);
                }
            } else {
                mapStudentProgramWithStudentCompetency.get(sComp.Student_Program__c).add(sComp);
            }
        }

        List<Student_Program__c> updatedStudentProgram = new list<Student_Program__c>();
        for (ID studentProgramID : setStudentProgramID) {
            decimal totalCompetencies = 0;
            decimal numberOfTransferredCredits = 0;
            decimal numberOfFulfilledCredits = 0;
            decimal numberOfCompetenciesTransferred = 0;
            decimal numberOfCreditsPreliminaryTransfer = 0;
            decimal numberOfCreditsTransferred = 0;
            decimal numberOfCompetenciesAchievedOrMastered = 0;
            decimal totalCreditsCompletedAchievedOrMastered = 0;
            decimal creditsBroughtIntoProgram = 0;

            if (mapStudentProgramWithStudentCompetency.containsKey(studentProgramID)) {
                totalCompetencies = (decimal) mapStudentProgramWithStudentCompetency.get(studentProgramID).Size();
                // count all the completed competency
                for (Student_Competency__c sComp : mapStudentProgramWithStudentCompetency.get(studentProgramID)) {
                    system.debug('sCompsCompsComp: ' + sComp.Area_Of_Expertise_Name__c + 'Status: ' + sComp.Status__c + ', ' + sComp.Student_Expertise__r.Pseudo_Course__c + ', ' + sComp.Pseudo_CE__c);
                    if (sComp.IsCompleted__c && (sComp.Status__c == 'Transferred' || sComp.Status__c == 'Fulfilled')) {

                        numberOfCompetenciesTransferred++;

                        if (sComp.Student_Expertise__r.Pseudo_Course__c == TRUE && sComp.Pseudo_CE__c != null) {
                            numberOfCreditsTransferred += sComp.Pseudo_CE__c;
                        } else if (sComp.Student_Expertise__r.Pseudo_Course__c == FALSE) {
                            numberOfCreditsTransferred += sComp.Competency_Credit_Equivalency__c;
                        }

                        if (sComp.Status__c == 'Transferred') {
                            if (sComp.Student_Expertise__r.Pseudo_Course__c == TRUE && sComp.Pseudo_CE__c != null) {
                                numberOfTransferredCredits += sComp.Pseudo_CE__c;
                            } else if (sComp.Student_Expertise__r.Pseudo_Course__c == FALSE) {
                                numberOfTransferredCredits += sComp.Competency_Credit_Equivalency__c;
                            }
                        } else if (sComp.Status__c == 'Fulfilled') {
                            if (sComp.Student_Expertise__r.Pseudo_Course__c == TRUE && sComp.Pseudo_CE__c != null) {
                                numberOfFulfilledCredits += sComp.Pseudo_CE__c;
                            } else if (sComp.Student_Expertise__r.Pseudo_Course__c == FALSE) {
                                numberOfFulfilledCredits += sComp.Competency_Credit_Equivalency__c;
                            }
                        }

                    } else if (sComp.IsCompleted__c && (sComp.Status__c == 'Achieved' || sComp.Status__c == 'Mastered') && sComp.Student_Subscription_Achieved_In__c != null) {
                        numberOfCompetenciesAchievedOrMastered++;
                        totalCreditsCompletedAchievedOrMastered += sComp.Competency_Credit_Equivalency__c;

                    } else If (sComp.IsCompleted__c && (sComp.Status__c == 'Achieved' || sComp.Status__c == 'Mastered') && sComp.Student_Subscription_Achieved_In__c == null) {
                        numberOfCompetenciesAchievedOrMastered++;
                        creditsBroughtIntoProgram += sComp.Competency_Credit_Equivalency__c;
                    }
                    
                    
                    if (sComp.Status__c == 'Preliminary Transfer') {
                        if (sComp.Student_Expertise__r.Pseudo_Course__c == TRUE && sComp.Pseudo_CE__c != null) {
                            numberOfCreditsPreliminaryTransfer += sComp.Pseudo_CE__c;
                        } else if (sComp.Student_Expertise__r.Pseudo_Course__c == FALSE) {
                            numberOfCreditsPreliminaryTransfer += sComp.Competency_Credit_Equivalency__c;
                        }
                    }

                }

            }


            Student_Program__c sProgram = new Student_Program__c(ID = studentProgramID,
                    Number_of_Competencies_Transferred__c = numberOfCompetenciesTransferred,
                    Number_of_Credits_TransferredFulfilled__c = numberOfCreditsTransferred,
                    Credits_Brought_into_Program__c = creditsBroughtIntoProgram,
                    Number_of_Competencies__c = totalCompetencies,
                    Number_of_Credits_Transferred__c = numberOfTransferredCredits,
                    Number_of_Credits_Preliminary_Transfer__c = numberOfCreditsPreliminaryTransfer,
                    Fulfilled_Credit__c = numberOfFulfilledCredits,
                    All_Program_Credits_Completed__c = totalCreditsCompletedAchievedOrMastered);
            updatedStudentProgram.add(sProgram);
        }
        system.debug('updatedStudentProgram:::::::::::::' + updatedStudentProgram);
        update updatedStudentProgram;
    }
    
    
        /*******************************************************************
    Method to Roll up number of completed competencies on the Related Student Subscription 
    IF the child competencies is Achieved   
    Related task: T-324627
    Created By: Vinod Kumar
    
    NOTE: replaced by: rollUpCompletedCompetenciesOnCurrentAndPriorSubscription
    ********************************************************************/
        /*           
        public void rollUpNumberOfCompletedCompetenciesOnCurrentStudentSubscription(set<ID> setStudentProgramID){
        //Status__c is changed to the value "Achieved", then increment the current Student_Subscription__r.Number_of_Competencies_Completed__c by 1.
        //- if Status__c is changed from the value "Achieved", then decrement the current 
        Date dtToday = Date.today();
        map<ID,Student_Subscription__c>mapStudentProgramWithStudentSubscription = new map<ID,Student_Subscription__c>();
        
        for(Student_Subscription__c sSub:[Select ID,Student_Program__c, Number_of_Competencies_Completed__c,
        Number_of_Credits_Completed__c, Start_Date__c,End_Date__c
        from Student_Subscription__c 
        where Student_Program__c in: setStudentProgramID
        and Start_Date__c <=: dtToday
        and End_Date__c >=: dtToday]){
        mapStudentProgramWithStudentSubscription.put(sSub.Student_Program__c,sSub);
        }
        if(!mapStudentProgramWithStudentSubscription.isEmpty()){
        // get all completed studenct competency (that are not Transferred, Fulfilled, Non-Academic, or Skills)
        map<ID,list<Student_Competency__c>> mapStudentProgramWithStudentCompetency = new map<ID,list<Student_Competency__c>>();
        for(Student_Competency__c sComp:[SELECT id,Completed_Date__c,Student_Program__c, Competency__r.Credit_Equivalency__c
        FROM Student_Competency__c
        WHERE Student_Program__c in: mapStudentProgramWithStudentSubscription.keySet()
        AND IsCompleted__c = true
        AND Status__c NOT IN( 'Preliminary Transfer','Transferred','Fulfilled') and Competency_Type__c NOT IN ('Non-Academic','Skill')] ){
        
        if(!mapStudentProgramWithStudentCompetency.containsKey(sComp.Student_Program__c)){
        mapStudentProgramWithStudentCompetency.put(sComp.Student_Program__c,new list<Student_Competency__c>());
        }
        mapStudentProgramWithStudentCompetency.get(sComp.Student_Program__c).add(sComp);
        } 
        list<Student_Subscription__c> updatedStudentSubscription = new list<Student_Subscription__c>();
        for(ID sProgramID :mapStudentProgramWithStudentSubscription.keySet()){
        Student_Subscription__c currentSubscription = mapStudentProgramWithStudentSubscription.get(sProgramID);
        decimal totalCompletedCompetency = 0;
        decimal totalCompletedCredits = 0.0;
        if(mapStudentProgramWithStudentCompetency.containsKey(sProgramID)){
        for(Student_Competency__c sComp: mapStudentProgramWithStudentCompetency.get(sProgramID)){
        // check if the copleteion date is in between the subscrption start and end date
        if(sComp.Completed_Date__c >= currentSubscription.Start_Date__c && sComp.Completed_Date__c <= currentSubscription.End_Date__c){
        totalCompletedCompetency++;
        totalCompletedCredits += sComp.Competency__r.Credit_Equivalency__c;
        }               
        }                       
        }
        currentSubscription.Number_of_Competencies_Completed__c = totalCompletedCompetency;
        currentSubscription.Number_of_Credits_Completed__c = totalCompletedCredits;
        updatedStudentSubscription.add(currentSubscription);
        }
        if(!updatedStudentSubscription.isEmpty()){
        update updatedStudentSubscription;
        }
        }
        
        }                                 
*/
    
    /*******************************************************************
    New Method to Roll up number of completed competencies on Current AND Past Student Subscription 
    IF the child competencies is Achieved   
    Created By: Dirk Koechner
    ********************************************************************/
    public void rollUpCompletedCompetenciesOnCurrentAndPriorSubscription(set<ID> setStudentProgramID){
        
        Date dtToday = Date.today();
        // process past subscriptions w/ end dates -90 days from today
        // TBD: adjust how many days into past to recalculate credits
        Date dtCutoff = dtToday.addDays(-500);
        set<Student_Subscription__c> setStudentSubscription = new set<Student_Subscription__c>();
        
        for(Student_Subscription__c sSub:[Select ID,Student_Program__c, Number_of_Competencies_Completed__c, 
                                          Number_of_Credits_Completed__c, Start_Date__c,End_Date__c
                                          from Student_Subscription__c 
                                          where Student_Program__c in: setStudentProgramID
                                          and Subscription_Status__c = 'RE = Registered'
                                          and Start_Date__c <=: dtToday
                                          and End_Date__c >=: dtCutoff]){
                                              system.debug('>>> Loading Subscriptions.  Program:' + sSub.Student_Program__c + '  Sub StartDate:' + sSub.Start_Date__c);
                                              setStudentSubscription.add(sSub);
                                          }
        
        if(!setStudentSubscription.isEmpty()){
            // get all completed studenct competency (that are not Transferred, Fulfilled, Non-Academic, or Skills)
            map<ID,list<Student_Competency__c>> mapStudentProgram_StudentCompetency = new map<ID,list<Student_Competency__c>>();
            for(Student_Competency__c sComp:[SELECT id,Completed_Date__c,Student_Program__c, Competency__r.Credit_Equivalency__c
                                             FROM Student_Competency__c
                                             WHERE Student_Program__c in: setStudentProgramID
                                             AND IsCompleted__c = true
                                             AND Status__c NOT IN( 'Preliminary Transfer','Transferred','Fulfilled') and Competency_Type__c NOT IN ('Non-Academic','Skill')] ){
                                                 
                                                 if(!mapStudentProgram_StudentCompetency.containsKey(sComp.Student_Program__c)){
                                                     mapStudentProgram_StudentCompetency.put(sComp.Student_Program__c,new list<Student_Competency__c>());
                                                 }
                                                 mapStudentProgram_StudentCompetency.get(sComp.Student_Program__c).add(sComp);
                                             }
            list<Student_Subscription__c> updatedStudentSubscription = new list<Student_Subscription__c>();
            
            for(Student_Subscription__c StuSub: setStudentSubscription) {
                integer totalCompletedCompetency = 0;
                decimal totalCompletedCredits = 0.0;
                if(mapStudentProgram_StudentCompetency.containsKey(StuSub.Student_Program__c)) {
                    for(Student_Competency__c sComp: mapStudentProgram_StudentCompetency.get(StuSub.Student_Program__c)){
                        
                        system.debug('>>> Calculating Program:' + StuSub.Student_Program__c + '  sComp CompletedDate:' + sComp.Completed_Date__c);
                        
                        // check if the copleteion date is in between the subscrption start and end date
                        if(sComp.Completed_Date__c >= StuSub.Start_Date__c && sComp.Completed_Date__c <= StuSub.End_Date__c){
                            totalCompletedCompetency++;
                            
                            if (sComp.Competency__r.Credit_Equivalency__c != null)
                                totalCompletedCredits += sComp.Competency__r.Credit_Equivalency__c;
                        }               
                    }
                }
                StuSub.Number_of_Competencies_Completed__c = totalCompletedCompetency;
                StuSub.Number_of_Credits_Completed__c = totalCompletedCredits;
                updatedStudentSubscription.add(StuSub);
            }
            if(!updatedStudentSubscription.isEmpty()) {
                update updatedStudentSubscription;
            }
            
        }
        
    }   
    
    /*******************************************************************
    Method to rollup Student Competencies completed during TBYB (trial period) and capture it 
    at: Opportunity.Competencies_Completed_in_Trial__c.     
    Related task: T-337411
    Created By: Vinod Kumar
    ********************************************************************/
    public void rollUpNumberOfCompletedCompetenciesInTrial(set<ID> setOpportunityID){       
        
        map<ID,decimal> mapOpportunityIdWithNumberOfNonAcademicCompetencies = new map<ID,decimal>();
        map<ID,decimal> mapOpportunityIdWithNumberOfCompletedCompetencies = new map<ID,decimal>();
        map<ID,decimal> mapOpportunityIdWithNumberOfCompletedCredits = new map<ID,decimal>();
        
        system.debug('rollUpNumberOfCompletedCompetenciesInTrial::::::::'+setOpportunityID);
        // get all student competency of the selected opportunity
        for(Student_Competency__c sComp:[select ID,Student_Program__c,Opportunity__c,Status__c,Completed_Date__c,
                                         Student_Program__r.First_Start_Date__c,Competency_Type__c,Competency_Credit_Equivalency__c
                                         from Student_Competency__c
                                         where Opportunity__c in: setOpportunityID
                                         and Completed_Date__c != null 
                                         and ( Status__c = 'Mastered' OR Status__c = 'Achieved')
                                         and Competency_Type__c IN('Non-Academic', 'Academic')
                                         ORDER BY Competency_Type__c]){
                                             //
                                             if(sComp.Student_Program__c == null || sComp.Completed_Date__c < sComp.Student_Program__r.First_Start_Date__c){
                                                 //Seperate out the academic and non-academic competencies
                                                 if(sComp.Competency_Type__c == 'Academic') {
                                                     // roll up the number os student competency on opportunity
                                                     if(!mapOpportunityIdWithNumberOfCompletedCompetencies.containsKey(sComp.Opportunity__c)){
                                                         
                                                         mapOpportunityIdWithNumberOfCompletedCompetencies.put(sComp.Opportunity__c,0);
                                                         mapOpportunityIdWithNumberOfCompletedCredits.put(sComp.Opportunity__c,0);                
                                                     }
                                                     
                                                     decimal totalComp = mapOpportunityIdWithNumberOfCompletedCompetencies.get(sComp.Opportunity__c) +1;
                                                     mapOpportunityIdWithNumberOfCompletedCompetencies.put(sComp.Opportunity__c,totalComp);
                                                     
                                                     system.debug('>> sComp.Status__c:'+sComp.Status__c);
                                                     system.debug('>> sComp.Completed_Date__c:'+sComp.Completed_Date__c);
                                                     system.debug('>> sComp.Competency_Credit_Equivalency__c:'+sComp.Competency_Credit_Equivalency__c);
                                                     
                                                     decimal totalCred = mapOpportunityIdWithNumberOfCompletedCredits.get(sComp.Opportunity__c) + sComp.Competency_Credit_Equivalency__c;
                                                     mapOpportunityIdWithNumberOfCompletedCredits.put(sComp.Opportunity__c,totalCred);
                                                 }
                                                 
                                                 else if(sComp.Competency_Type__c == 'Non-Academic') {
                                                     if(!mapOpportunityIdWithNumberOfNonAcademicCompetencies.containsKey(sComp.Opportunity__c)){
                                                         
                                                         mapOpportunityIdWithNumberOfNonAcademicCompetencies.put(sComp.Opportunity__c,0);
                                                     }
                                                     
                                                     decimal totalComp = mapOpportunityIdWithNumberOfNonAcademicCompetencies.get(sComp.Opportunity__c) +1;
                                                     mapOpportunityIdWithNumberOfNonAcademicCompetencies.put(sComp.Opportunity__c,totalComp);
                                                 }
                                             }
                                         }
        system.debug('mapOpportunityIdWithNumberOfCompletedCompetencies::::::::'+mapOpportunityIdWithNumberOfCompletedCompetencies);
        system.debug('mapOpportunityIdWithNumberOfNonAcademicCompetencies::::::::::'+mapOpportunityIdWithNumberOfNonAcademicCompetencies);
        
        list<Opportunity>lstOpportunity = new list<Opportunity>();
        for(ID optyId: setOpportunityID){
            Opportunity newOpty= new Opportunity(ID=optyId);
            if(mapOpportunityIdWithNumberOfCompletedCompetencies.containsKey(optyId)){
                
                newOpty.Competencies_Completed_in_Trial__c = mapOpportunityIdWithNumberOfCompletedCompetencies.get(optyId);
                newOpty.Credits_Completed_in_Trial__c = mapOpportunityIdWithNumberOfCompletedCredits.get(optyId);
                
            }
            if(mapOpportunityIdWithNumberOfNonAcademicCompetencies.containsKey(optyId)) {
                newOpty.NonAcademic_Competencies_Completed_TBYB__c = mapOpportunityIdWithNumberOfNonAcademicCompetencies.get(optyId);           
            }
            else{
                // already threre is only one and now that one is delete then make the rollup as null
                newOpty.Competencies_Completed_in_Trial__c = null;
                newOpty.Credits_Completed_in_Trial__c = null;
                newOpty.NonAcademic_Competencies_Completed_TBYB__c = null;
            }
            lstOpportunity.add(newOpty);
        }
        system.debug(lstOpportunity);
        update lstOpportunity;
    }
    
    /*******************************************************************
    Method to populate student subscription when student competency's 
    completed date is updated.    
    Related task: T-392581
    Created By: Vinay Joshi
    ********************************************************************/
    public void populateStudentSubscription(list<Student_Competency__c > newStudentCompetency) {
        
        List<Id> sPrograms = new List<Id>();
        Map<Student_Competency__c, List<Student_Subscription__c>> compSubsMap = new Map<Student_Competency__c, List<Student_Subscription__c>>();
        Map<Student_Competency__c, id> compSProgram = new Map<Student_Competency__c, id>();
        Map<Id, List<Student_Subscription__c>> sprogSubsmap = new Map<Id, List<Student_Subscription__c>>();  
        
        for(Student_Competency__c sComp: newStudentCompetency) {
            compSProgram.put(sComp, sComp.Student_Program__c);  
        }
        
        if(newStudentCompetency != null && newStudentCompetency.size() > 0) {
            for(Student_Subscription__c studentSubscriptions : [SELECT id, Student_Program__c, Start_Date__c, End_Date__c, Subscription_Status__c  FROM Student_Subscription__c WHERE Student_Program__c IN : compSProgram.values()]) {
                if(sprogSubsmap.containsKey(studentSubscriptions.Student_Program__c)) {
                    sprogSubsmap.get(studentSubscriptions.Student_Program__c).add(studentSubscriptions);
                } else {
                    sprogSubsmap.put(studentSubscriptions.Student_Program__c, new List<Student_Subscription__c>{studentSubscriptions});
                }
            } 
        }
        system.debug('sProgSubsMap::: ' + sprogSubsmap);
        
        for(Student_Competency__c sComp: newStudentCompetency) {
            
            List<id> tempSubs = new List<id>();  
            if(compSProgram.containsKey(sComp) && sprogSubsmap.containsKey(compSProgram.get(sComp))) {
                for(Student_Subscription__c studentSubsAchievedIn : sprogSubsmap.get(compSProgram.get(sComp))) {
                    if(sComp.Completed_Date__c >= studentSubsAchievedIn.Start_Date__c && sComp.Completed_Date__c <= studentSubsAchievedIn.End_Date__c && studentSubsAchievedIn.Subscription_Status__c =='RE = Registered') {
                        tempSubs.add(studentSubsAchievedIn.id);    
                    }
                }  
            } 
            
            system.debug('tempSubs::: ' + tempSubs);
            
            if(tempSubs != null && tempSubs.size() > 1 ) {
                system.debug(Logginglevel.ERROR,'More than 1 Subscriptions found');
            } else if(tempSubs != null && tempSubs.size() == 1) {
                sComp.Student_Subscription_Achieved_In__c = tempSubs[0]; 
            }
        }
        
        
    } 
    
    /*********************************************************************************
    Method to update number of Non Acedemic completed competencies on Student Program.
    Related task: T-398060
    Created By: Vinay Joshi
    /*********************************************************************************/
    public void updateNonAcedemicCompletedCompOnStuProg(Map<Id, Integer> progCompletedCompMap) {
        
        List<Student_Program__c> stuProgsToBeUpdated = new List<Student_Program__c>();
        for(Student_Program__c stuProg : [SELECT Id, Non_Academic_Competencies_Completed__c FROM Student_Program__c
                                          WHERE Id IN : progCompletedCompMap.keySet()]) {
                                              
                                              if(stuProg.Non_Academic_Competencies_Completed__c == null) {
                                                  stuProg.Non_Academic_Competencies_Completed__c = 0;
                                              }
                                              
                                              stuProg.Non_Academic_Competencies_Completed__c += progCompletedCompMap.get(stuProg.Id);
                                              
                                              if(stuProg.Non_Academic_Competencies_Completed__c < 0) {
                                                  stuProg.Non_Academic_Competencies_Completed__c = 0;
                                              }
                                              stuProgsToBeUpdated.add(stuProg);
                                          }
        //system.debug('stuProgsToBeUpdated"::::::::'+ stuProgsToBeUpdated[0].Non_Academic_Competencies_Completed__c );
        if(!stuProgsToBeUpdated.isEmpty()) {
            database.update(stuProgsToBeUpdated, false);
        } 
    }
     
    
    /*********************************************************************************
    Method to Assign SME with Assignment Group considering the Cohort Logics
    Related task: Devops- 16226
    Modified By: Ravitej Varada
    /*********************************************************************************/
    public void groupAssignment(List<Student_Competency__c> scs, Id groupAssig) {
        system.debug('groupAssig'+groupAssig);
        
        if(groupAssig != null){ 
            list<Student_Sections__c> studentSections = new list<Student_Sections__c>();
            
             string studentState = '';
            string studentProgramCode = '';
            If(scs[0].student_State__c != null &&  scs[0].Program_Name__c != null){
                studentState = scs[0].student_State__c;
                studentProgramCode = scs[0].Program_Name__c; 
            }
            system.debug('studentState'+studentState);
            Set<string> compactStatesSet = new Set<string>();
            for(Compact_License_States__c c :Compact_License_States__c.getAll().values()){
                compactStatesSet.add(c.Name);
            } 
            
            Set<string> cohortProgramSet = new Set<string>();
            for(Cohort_Programs__c   c :Cohort_Programs__c.getAll().values()){
                cohortProgramSet.add(c.Name);
            } 
            system.debug('compactStatesSet'+compactStatesSet.contains(studentState));
            
            
            
            Map<string,SME_Cohort__c> cohortWithType = new map<string,SME_Cohort__c>();
            List<SME_Cohort__c> smeCohortLst = new List<SME_Cohort__c>();
            smeCohortLst = [Select id,name, License_Type__c, State__c,(select id,  Today_s_Score__c , User__c, User__r.Name from Group_Members_CST__r where  Status__c = 'Active' ) from  SME_Cohort__c  WHERE SME_Assignment_Group__c =: groupAssig];
            SME_Cohort__c cohortGroup = new SME_Cohort__c();
            system.debug('smeCohortLst'+smeCohortLst);
            
            
            If(!smeCohortLst.isEmpty()){
                for(SME_Cohort__c cohort:smeCohortLst){ 
                    if(cohort.License_Type__c == 'Compact'){
                        cohortWithType.put(cohort.License_Type__c,cohort);
                    }else if(cohort.License_Type__c == 'Single State'){
                        cohortWithType.put(cohort.State__c,cohort);
                    }else if(cohort.License_Type__c == 'Non-Cohort'){
                        cohortWithType.put(cohort.License_Type__c,cohort);
                    }
                }
  
                If(compactStatesSet.contains(studentState) && cohortProgramSet.contains(studentProgramCode)){
                    cohortGroup =  cohortWithType.get('Compact'); 
                 }else if(cohortWithType.containskey(studentState) && cohortProgramSet.contains(studentProgramCode)){
                     cohortGroup =  cohortWithType.get(studentState); 
                 }else{
                    cohortGroup =  cohortWithType.get('Non-Cohort');
                 }
            }
            
             
            system.debug('cohortGroup'+cohortGroup);
            
            list<Customer_Support_Team__c> listCustomerSupportTeam = [select id,  Today_s_Score__c , User__c, User__r.Name from Customer_Support_Team__c where  Status__c = 'Active' AND SME_Cohort_Group__c =: cohortGroup.Id order by Fair_Check__c ASC];
            system.debug('listCustomerSupportTeam'+listCustomerSupportTeam);
            list<String> userIds = new list<String>();
            list<String> compIds = new list<String>();
            for(Customer_Support_Team__c cst : listCustomerSupportTeam) {
                userIds.add(cst.User__c);
            }
            
            system.debug('userIds'+userIds);
            
            for(Student_Competency__c currentSC : scs) {
                compIds.add(currentSC.Competency__c);
            }
            system.debug('compIds'+compIds);
            
            //List<Competency_Version__c > compVersionList = new List<Competency_Version__c >();
            Map<Id,Competency__c> compMap = new Map<id,Competency__c>([ Select Id,name, (Select Id,name, Active__c , Competency__c, Competency_Shell_ID__c ,Effective_Date__c ,Available_for_Existing_Students__c  from Competency_Version__r Where Active__c = True) from Competency__c where Id IN: compIds]);
            
            list<Sections__c> smeSections = [SELECT Id, SME__c, Competency__c FROM Sections__c WHERE Competency__c IN :compIds and SME__c in :userIds AND Current_Section__c = true];
            system.debug('smeSections++++++++'+smeSections);
            Map<String, Sections__c> mapSections = new Map<String, Sections__c>();
            
            
            
            for(Student_Competency__c sc: scs)
            {
                if(listCustomerSupportTeam.size() > 0) {             
                    sc.SME__c =  listCustomerSupportTeam[0].User__c;
                    for(Sections__c section : smeSections) {
                        if(listCustomerSupportTeam[0].User__c == section.SME__c && sc.Competency__c == section.Competency__c) {
                            mapSections.put(sc.Competency__c, section);
                        }
                    } 
                    listCustomerSupportTeam[0].Today_s_Score__c = listCustomerSupportTeam[0].Today_s_Score__c == null? 0 +1 : listCustomerSupportTeam[0].Today_s_Score__c + 1;  
                    update listCustomerSupportTeam[0]; //trigger size =1
                }              
            }
                    
            for(Student_Competency__c studentComp : scs) {
                if(mapSections.containsKey(studentComp.Competency__c)) {
                    Sections__c currentSCSection = mapSections.get(studentComp.Competency__c);
                    Student_Sections__c studentSection = new Student_Sections__c();
                    studentSection.Section__c = currentSCSection.Id;
                    studentSection.Student_Competency__c = studentComp.Id;
                    studentSection.RecordTypeId =Schema.SObjectType.Student_Sections__c.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
                    studentSections.add(studentSection);
                }
            } 
            if(studentSections.size()>0) {
                insert studentSections;
            }  
        }
         
    } 
	   
    /*********************************************************************************
    Method to the first competency started count on SP associated to the Student Competency
	This substitutes the process in Process Builder
    Related task: Devops- 19654
	Tempo: Convert first competency completed process flow to trigger
    Modified By: Horacio Sanchez
    /*********************************************************************************/
    public void updateFirstCompetencyStartedCount(Set<Id> setUpdateFirstCompetencyStartedCount) {
        List<Student_Program__c> studentProgramToUpgradeList = new List<Student_Program__c>();
        Set<Id> studentProgramsToUpdateIdSet = new Set<Id>();
        
        List<Student_Competency__c> studentCompetencyList = [SELECT Id, Student_Program__c, Competency__r.Assessment_Type__c, Student_Program__r.First_Assessment__c 
                                                        	 FROM Student_Competency__c
                                                        	 WHERE Id IN :setUpdateFirstCompetencyStartedCount];
        for (Student_Competency__c studentCompetency : studentCompetencyList) {
            if (studentCompetency.Student_Program__c == null || studentCompetency.Student_Program__r.First_Assessment__c != 0) {
                continue;
            }
            if (studentCompetency.Competency__r.Assessment_Type__c == 'Work Product' ||
                studentCompetency.Competency__r.Assessment_Type__c == 'Performance Task' ||
                studentCompetency.Competency__r.Assessment_Type__c == 'Short Answer' ||
                studentCompetency.Competency__r.Assessment_Type__c == 'Written Response') {
                    studentProgramsToUpdateIdSet.add(studentCompetency.Student_Program__c);
                }
        }
        
        List<Student_Program__c> studentProgramList = [SELECT Id, First_Assessment__c FROM Student_Program__c WHERE Id IN :studentProgramsToUpdateIdSet];
        for (Student_Program__c sp : studentProgramList) {
            Student_Program__c studentProgram = new Student_Program__c();
            studentProgram.id = sp.id;
            studentProgram.First_Assessment__c = 1;
            studentProgramToUpgradeList.add(studentProgram);
        }
        
        if (!studentProgramToUpgradeList.isEmpty()) {
            update studentProgramToUpgradeList;
        }
    }
    
}