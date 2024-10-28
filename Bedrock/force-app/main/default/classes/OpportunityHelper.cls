/*******************************************************************
Name  : OpportunityHelper
Author: Appirio
Date  : October 14, 2014
Description: Helper  class for Opportunity
* Sufia             - June 28, 2021 - User Story S-685520
*************************************************************************/ 
public with sharing class OpportunityHelper {
    private Opportunity opp;
    public OpportunityHelper() {

    }
    public OpportunityHelper(Opportunity opp) {
        this.opp = opp;
    }

    public Opportunity getOpp() {
        return opp;
    }

    public static void markOppForCOSBeforeAdmitted(List<Opportunity> opportunities) {
        // Mark the CoS checkbox is Opp isn't Admitted or Student.
        // Be careful with boolean logic: !(A||B) == (!A)&&(!B)
        for (Opportunity opp : opportunities) {
            if (opp.StageName != 'Admitted' && opp.StageName != 'Student') {
                opp.Change_of_Specialization__c = true;
            }
        }
    }

    public static void updateProgramOnBrandProfile(List<Opportunity> opportunities) {
        System.debug('In updateProgramOnBrandProfile');
        list<Brand_Profile__c> bpToUpdate = new list<Brand_Profile__c>();
        for (Opportunity opp : opportunities) {
            if (opp.Brand_Profile__c != null) {
                System.debug('Inserting Brand Profile');
                Brand_Profile__c bp = new Brand_Profile__c(Id = opp.Brand_Profile__c, Primary_Program_of_Interest__c = opp.Primary_Program__c);
                bpToUpdate.add(bp);
            }
        }
        if (!bpToUpdate.isEmpty()) {
            update bpToUpdate;
        }
    }

    /*******************************************************************************************
        bleboff T-325653 - given a list of opportunities, query for their
        student discounts, and apply them to the amount if they exists
        DK: add Condition: Exemption_Approved__c = true
    *******************************************************************************************/
    public static void calculateAmountAfterDiscount(List<Opportunity> opportunities) {
        List<Opportunity> aggregateOpps = Utility.without(opportunities, 'Id', null);
        map<Id, AggregateResult> mapOptyToDiscount = new map<Id, AggregateResult>(
        [
                SELECT Opportunity__c Id, SUM(Exemption__r.Flat_Rate_Amount__c) framt, SUM(Exemption__r.Percentage_Discount__c) peramt
                FROM Student_Discount__c
                WHERE Opportunity__c IN :aggregateOpps
                AND Exemption_Approved__c = true
                group by Opportunity__c
        ]);

        Set<Id> priceBookIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();

        for (Opportunity opty : opportunities) {
            priceBookIds.add(opty.Initial_Price_Book__c);
            productIds.add(opty.Primary_Program__c);
        }
        //create a map with key of pricebook & product to the pricebook entry 
        //so we can grab the unitprice easy
        PricebookProductMap priceBookProductMap = new PricebookProductMap();
        System.debug(opportunities);
        System.debug(pricebookids);
        System.debug(productIds);
        for (PricebookEntry pe : [
                select pricebook2id, product2id, unitprice
                from PricebookEntry
                where pricebook2id in:priceBookIds
                and product2id in:productIds
        ]) {
            priceBookProductMap.put(pe);
        }

        for (Opportunity opty : opportunities) {
            PricebookEntry pe = priceBookProductMap.get(opty.Initial_Price_Book__c, opty.Primary_Program__c);
            if (pe != null) {
                Decimal amount = pe.unitprice;
                Decimal finalDiscount = 0;

                if (mapOptyToDiscount.containsKey(opty.id)) {
                    AggregateResult ar = mapOptyToDiscount.get(opty.id);
                    Decimal flatDisc = (Decimal) ar.get('framt');
                    if (flatDisc == null) flatDisc = 0;
                    Decimal percentDisc = (Decimal) ar.get('peramt');
                    if (percentDisc == null) percentDisc = 0;
                    finalDiscount = (percentDisc * amount) / 100 + flatDisc;
                    //system.debug('amount::::::::::::'+amount);
                    //system.debug('flatDisc::::::::::::'+flatDisc);
                    //system.debug('percentDisc::::::::::::'+percentDisc);
                    //system.debug('finalDiscount::::::::::::'+finalDiscount);
                }

                opty.amount = amount - finalDiscount;
            }
        }
    }

    public class PricebookProductMap {
        private Map<String, PricebookEntry> priceBookProductMap;
        PricebookProductMap() {
            priceBookProductMap = new Map<String, PricebookEntry>();
        }

        public void put(PricebookEntry pe) {
            priceBookProductMap.put(pe.pricebook2id + '-' + pe.product2id, pe);
        }

        public PricebookEntry get(Id pricebk, Id prod) {
            return priceBookProductMap.get(pricebk + '-' + prod);
        }
    }

    // On new Opportunity Creation:
    // insert into student application requirements from application requirements based on Opportunity.primary program
    public static void createStudentApplicationRequirements(list<Opportunity> opportunities) {

        list<Program_Application_Requirement__c> appReqList = new list<Program_Application_Requirement__c>
                ([SELECT Name, Program__c FROM Program_Application_Requirement__c]);

        list<Student_Application_Requirement__c> stuAppReqList = new list<Student_Application_Requirement__c>();

        for (Opportunity opty : opportunities) {
            for (Program_Application_Requirement__c appReq : appReqList) {
                if (opty.Primary_Program__c == appReq.Program__c || opty.Parent_Program__c == appReq.Program__c) {
                    Student_Application_Requirement__c stuAppReq = new Student_Application_Requirement__c();
                    stuAppReq.Program_Application_Requirement__c = appReq.Id;
                    stuAppReq.Opportunity__c = opty.Id;
                    stuAppReqList.add(stuAppReq);
                }
            }
        }

        insert stuAppReqList;

    }

    public static void updateOppsWithCBLwithContactFields(list<Opportunity> selectedCBL_Opportunities, map<ID, Opportunity> oldMap) {
        System.debug('In updateOppsWithCBLwithContactFields');
        map<Id, Contact> mapContact = new map<Id, Contact>();
        set<Id> contactIdSet = new set<Id>();
        list<Opportunity> opsToPublish = new list<Opportunity>();
        for (Opportunity opty : selectedCBL_Opportunities) {
            contactIdSet.add(opty.Contact__c);
        }

        if (!contactIdSet.isEmpty()) {
            mapContact = new map<Id, Contact>([
                    SELECT Id, CBL_Student_ID__c, Email, Walden_Email__c
                            , FirstName, LastName
                    FROM Contact
                    WHERE Id IN :contactIdSet
            ]);
            for (Opportunity opty : selectedCBL_Opportunities) {
                System.debug('Opportunity Contact: ' + opty.Contact__c + ' in map: ' + mapContact.containsKey(opty.Contact__c));

                if (opty.Contact__c != null && mapContact.containsKey(opty.Contact__c)) {
                    Opportunity oldOpty = oldMap.get(opty.ID);
                    opty.CBL_Student_Id__c = mapContact.get(opty.Contact__c).CBL_Student_ID__c;
                    opty.Student_Primary_Email__c = mapContact.get(opty.Contact__c).Email;
                    opty.Student_Institution_Email__c = mapContact.get(opty.Contact__c).Walden_Email__c;
                    System.debug('Student Full Name: ' + mapContact.get(opty.Contact__c).FirstName + ' ' + mapContact.get(opty.Contact__c).LastName);
                    opty.Student_Full_Name__c = mapContact.get(opty.Contact__c).FirstName + ' ' + mapContact.get(opty.Contact__c).LastName;
                    if ((oldOpty.CBL_Student_Id__c == null && opty.CBL_Student_Id__c != null) && opty.Student_LMS_ID__c != null) {
                        opsToPublish.add(opty);
                    }
                }
            }
            /* Commenting out - CBL ID will be sent to LMS upon BP creation
            //Update the CBL Student ID to BS User
            if(opsToPublish.size()>0) {
              JsonWrapper jsonGenerator = new JsonWrapper();
              try {
                  for(Opportunity o: opsToPublish) {
                      if(o.Student_Primary_Email__c!=null && o.Student_LMS_ID__c!=null && o.Student_First_Name__c!=null && o.Student_Last_Name__c!=null) {
                          String json = jsonGenerator.updateUser(o.CBL_Student_Id__c, o.Student_First_Name__c, o.Student_Last_Name__c, o.Student_Primary_Email__c);
                          BrightSpaceCalls.updateUser(json, String.valueOf(o.Student_LMS_ID__c), o.Contact__c);
                      }
                  }
              }
              catch(Exception exp) {
                  System.debug(exp);
              }
            }
            */
        }
    }


    public void updateStudentProgramStartDate(list<Opportunity> selectedCBL_Opportunities, map<ID, Opportunity> oldMap) {
        System.debug('In updateStudentProgramStartDate');
        List<Student_Program__c> spsNeedingUpdate = new List<Student_Program__c>();
        for (Opportunity opty : selectedCBL_Opportunities) {
            Opportunity oldOpty = oldMap.get(opty.ID);
            // check if the preferred start date has changed
            System.debug('New Start Date ' + opty.Program_Start_Date__c + ' Old Start Date ' + opty.Student_Program__c + ' Student Program ' + opty.Student_Program__c);
            if ((opty.Program_Start_Date__c != oldOpty.Program_Start_Date__c) && opty.Student_Program__c != null && opty.Primary_Program__c != null) {
                Student_Program__c sp = new Student_Program__c(Id = opty.Student_Program__c, Program_Start_Date__c = opty.Program_Start_Date__c);
                spsNeedingUpdate.add(sp);
            }
            // check if the primary program has changed
            if ((opty.Primary_Program__c != oldOpty.Primary_Program__c) && opty.Student_Program__c != null && opty.Primary_Program__c != null) {
                Student_Program__c sp = new Student_Program__c(Id = opty.Student_Program__c, Program__c = opty.Primary_Program__c);
                system.debug('Student Program ::: ' + sp);
                spsNeedingUpdate.add(sp);
            }

        }
        System.debug('SPs to be updated ' + spsNeedingUpdate);
        if (spsNeedingUpdate.size() > 0) {
            update spsNeedingUpdate;
        }
    }

    public void updatesUponOpportunityAdmitOrWin(list<Opportunity> selectedCBL_Opportunities, map<ID, Opportunity> oldMap) {
        System.debug('In updatesUponOpportunityAdmitOrWin');
        // operations when CBL opps are admitted and/or Student accepts
        list<Opportunity> oppsNeedingStudentProgramList = new list<Opportunity>();
        list<Opportunity> oppsNeedingCOP = new list<Opportunity>();
        set<ID> studentProgramIdsForEligibilitySet = new set<ID>();
        list<Opportunity> oppsNeedingBPs = new list<Opportunity>();
        set<ID> contactIdsNeedStudentIdSet = new set<ID>();
        StudentSuiteFactory objSfactory = new StudentSuiteFactory();

        for (Opportunity opty : selectedCBL_Opportunities) {
            System.debug('CBL ID: ' + opty.CBL_Student_Id__c);
            Opportunity oldOpty = oldMap.get(opty.ID);

            // parse for Student Program upon admittance
            /*
            if(opty.StageName == 'Admitted' && oldOpty.StageName != 'Admitted'
                && opty.Primary_Program__c != null && opty.Student_Program__c == null && opty.Brand_Profile__c == null){
                  */
            if (opty.StageName == 'Admitted' && oldOpty.StageName != 'Admitted'
                    && opty.Primary_Program__c != null && opty.Student_Program__c == null) {
                oppsNeedingStudentProgramList.add(opty);

            }
            /*
            if(opty.CBL_Student_Id__c!=null && oldOpty.CBL_Student_Id__c==null && opty.Brand_Profile__c == null && (opty.StageName == 'Student' && oldOpty.StageName != 'Admitted') ) {
              oppsNeedingBPs.add(opty);
            }
            */
            if (opty.CBL_Student_Id__c != null && opty.Brand_Profile__c == null && (opty.StageName == 'Student' && oldOpty.StageName != 'Student')) {
                oppsNeedingBPs.add(opty);
            }
            // parse for student acceptance
            if (opty.StageName == 'Student' && oldOpty.StageName != 'Student'
                    && opty.Student_Program__c != null) {
                studentProgramIdsForEligibilitySet.add(opty.Student_Program__c);
            }

            // parse for CBL Student Id needed
            if (opty.Contact__c != null && ((opty.StageName == 'Admitted' && oldOpty.StageName != 'Admitted') ||
                    (opty.StageName == 'Student' && oldOpty.StageName != 'Student'))) {
                contactIdsNeedStudentIdSet.add(opty.Contact__c);
            }
        }

        //Create BP only when the CBL Student ID has been generated
        if (!oppsNeedingBPs.isEmpty()) {
            //System.debug('In Createing BP');
            objSfactory.createBrandProfile(oppsNeedingBPs);
        }

        // create Student Program upon admittance
        if (!oppsNeedingStudentProgramList.isEmpty()) {
            System.debug('In create BP');
            //objSfactory.createBrandProfile(oppsNeedingStudentProgramList);
            objSfactory.createFullCBLStudentProgram(oppsNeedingStudentProgramList);
        }

        // make student eligible to register
        if (!studentProgramIdsForEligibilitySet.isEmpty()) {
            list<Student_Program__c> lstStudentProgram = new list<Student_Program__c>();
            for (Student_Program__c sp : [
                    SELECT Id,Student_Enrollment_Status__c,Student_Enrollment_Status_Code__c,Coach__c,Student__c
                    FROM Student_Program__c
                    WHERE Id IN:studentProgramIdsForEligibilitySet
            ]) {
                sp.Student_Enrollment_Status_Code__c = 'EL';
                sp.Student_Enrollment_Status__c = 'Eligible to Register (EL)';
                lstStudentProgram.add(sp);
            }
            StudentProgramHelper.cblCoachAssignment(lstStudentProgram);

            system.debug(lstStudentProgram[0].Coach__c);
            update lstStudentProgram;
        }
        // create CBL Student Ids
        if (!contactIdsNeedStudentIdSet.isEmpty()) {
            ContactHelper objContactHelper = new ContactHelper();
            objContactHelper.populateCBLStudentId(contactIdsNeedStudentIdSet);
        }

    }

    //This method checks if there is an existing BP for this student and updates the Opp with the BP if it exists
    //This method also checks if
    public static void checkAndAssociateExistingBP(list<Opportunity> lstOpportunities) {
        System.debug('In checkAndAssociateExistingBP');
        set<Id> contactIds = new set<Id>();
        list<Opportunity> oppsToUpdate = new list<Opportunity>();
        list<Brand_Profile__c> bpsToUpdate = new list<Brand_Profile__c>();
        for (Opportunity op : lstOpportunities) {
            contactIds.add(op.Contact__c);
        }

        map<Id, Brand_Profile__c> mapContactBrandProfile = new map<Id, Brand_Profile__c>();

        list<Brand_Profile__c> lstBrandProfile = new list<Brand_Profile__c>([SELECT Id, Contact__c, Primary_Program_of_Interest__c FROM Brand_Profile__c WHERE Contact__c IN :contactIds]);
        System.debug('lstBrandProfile :::: ' + lstBrandProfile);

        for (Brand_Profile__c bp : lstBrandProfile) {
            for (Opportunity opp : lstOpportunities) {
                if (opp.Contact__c == bp.Contact__c) {
                    mapContactBrandProfile.put(opp.Id, bp);
                }
                if (opp.Primary_Program__c != bp.Primary_Program_of_Interest__c) {
                    Brand_Profile__c bpToUpdate = new Brand_Profile__c(Id = bp.Id, Primary_Program_of_Interest__c = opp.Primary_Program__c);
                    bpsToUpdate.add(bpToUpdate);
                }
            }
        }
        System.debug('mapContactBrandProfile:::: ' + mapContactBrandProfile);
        for (ID oppId : mapContactBrandProfile.keySet()) {
            Brand_Profile__c currentBrandProfile = mapContactBrandProfile.get(oppId);
            Opportunity oppToUpdate = new Opportunity(Id = oppId, Brand_Profile__c = mapContactBrandProfile.get(oppId).Id);
            oppsToUpdate.add(oppToUpdate);
        }
        if (oppsToUpdate.size() > 0) {
            update oppsToUpdate;
        }
        if (bpsToUpdate.size() > 0) {
            update bpsToUpdate;
        }
    }

    /*
    public static void cblEAAssignment(list<Opportunity> cblOpportunities){
      // For each Opp. populate listRRNames with appropriate Queue name: depending if student is US or not
      List<String> listRRNames = new List<String>();
      String mailingCountry;
      for(Opportunity opty:cblOpportunities){
        // Lead.Lead_Country__c is custom field mapped to Opportunity.Lead_Country__c
        mailingCountry = opty.Lead_Country__c;

        system.debug('>>> mailingCountry:'+ mailingCountry);
        if (mailingCountry == 'United States' || mailingCountry == '' || mailingCountry == null) {
         // listRRNames.add('RR Walden EAs');
        } else {
         // listRRNames.add('RR Walden Non-US EAs');
        }
      }
      // Call the RoundRobinHelper, pass in List of RR Names (RR Walden EAs), returns List of 'next' User IDs
      map<Id,User> mapId_User = new map<Id,User>();
      RoundRobinHelper objRRHelper = new RoundRobinHelper();
      list<Id> listUserIds = new list<Id>();
      if(!Test.isRunningTest()){
        listUserIds = objRRHelper.getNextRRUsers(listRRNames);
      } else {
        listUserIds.add( system.Userinfo.getUserId() );
      }
      integer index = 0;
      if(!listUserIds.isEmpty()){
        mapId_User = new map<Id,User>([SELECT Id, Email FROM User WHERE Id IN :listUserIds]);
        for (Opportunity opty : cblOpportunities) {
          opty.Enrollment_Advisor__c = listUserIds[index];
          opty.Enrollment_Advisor_s_Email__c = mapId_User.get(listUserIds[index]).Email;
          if( index == listUserIds.size()-1 ) {
            index = 0;
          } else {
            index++;
          }
        }
      }

    }
    */

    public static void runroundrobin(List<opportunity> Newopps) {
        Set<id> Opps = new Set<id>();

        For (opportunity Opp : Newopps) {
            if (Opp.RunRoundRobin__c == true) {
                Opps.add(Opp.id);
            }
        }

        if (opps.isempty() == false) {
            manageroundrobin(opps);
        }

    }

    public static void manageroundrobin(set<id> Opps) {

        //pass off to assignment rule engine find out group match
                        Map<id, string> OpptoAssignmentGroup = OpportunityAssignment_Helper.OpportunitytoGroupMatch(Opps);
        system.debug(OpptoAssignmentGroup);
        system.debug('OpptoAssignmentGroup' + OpptoAssignmentGroup);

        Set<id> groupids = new set<id>();
        For (string s : OpptoAssignmentGroup.values()) {
            if (s != null) {
                system.debug('######' + s);
                groupids.add(id.valueof(S.substringBefore(';')));
            }
        }

        //Build Map of groups to users
        Map<id, List<Assignment_Groups__c>> GrouptoGroupMember = new Map<id, List<Assignment_Groups__c>>();
        Map<id, set<id>> GrouptoGroupUsers = new Map<id, set<id>>();


        For (Assignment_Groups__c GMember : [
                SELECT id, Group_Name__c, User__c, Last_Assignment__c, Millisecond__c, User_Active__c
                from Assignment_Groups__c
                where User_Active__c = :'True'
                AND User__c NOT IN (SELECT User__c from Out_Of_Office__c where Absence_start_date__c <= today and Absence_end_date__c >= today) and Group_Name__c in:groupids
                ORDER BY Group_Name__c, Last_Assignment__c, Millisecond__c
        ]) {
            if (GrouptoGroupMember.get(GMember.Group_Name__c) != null) {
                List<Assignment_Groups__c> templist = GrouptoGroupMember.get(GMember.Group_Name__c);
                templist.add(GMember);
                GrouptoGroupMember.put(GMember.Group_Name__c, templist);

                set<id> tempset = GrouptoGroupUsers.get(GMember.Group_Name__c);
                tempset.add(GMember.User__c);
                GrouptoGroupUsers.put(GMember.Group_Name__c, tempset);
            } else {
                List<Assignment_Groups__c> templist = new List<Assignment_Groups__c>();
                templist.add(GMember);
                GrouptoGroupMember.put(GMember.Group_Name__c, templist);
                set<id> tempset = new set<id>();
                tempset.add(GMember.User__c);
                GrouptoGroupUsers.put(GMember.Group_Name__c, tempset);
            }
        }


        //Begin Mapping Process

        List<Opportunity> relatedopps = new List<Opportunity> ();
        relatedopps = [Select id, RunRoundRobin__c from Opportunity where id in:Opps];

        map<id, Assignment_Groups__c> UniqueGMemberstoUpdate = new map<id, Assignment_Groups__c>();

        For (Opportunity Opp : relatedopps) {
            if (Opp.RunRoundRobin__c != true) {
                continue;
            }
            String AssignedGroup = '';
            String RuleDescription = '';
            if (String.isNotBlank(OpptoAssignmentGroup.get(opp.id))) {
                AssignedGroup = OpptoAssignmentGroup.get(opp.id).substringBefore(';');
                RuleDescription = OpptoAssignmentGroup.get(opp.id).substringAfter(';');
            }
            //String AssignedGroup = '';
            //AssignedGroup = OpptoAssignmentGroup.get(opp.id);

            if (AssignedGroup != null && AssignedGroup != '') {
                if (GrouptoGroupMember.get(id.valueof(AssignedGroup)) != null) {

                    //if opp round robin still equal true continue
                    if (Opp.RunRoundRobin__c == true) {
                        List<Assignment_Groups__c> tempgroup = GrouptoGroupMember.get(id.valueof(AssignedGroup));
                        //Opp.ownerid = tempgroup[0].user__c;
                        Opp.Enrollment_Advisor__c = tempgroup[0].user__c;
                        Opp.RunRoundRobin__c = false;
                        //Opp.Assignment_Rule_Description__c = RuleDescription;
                        tempgroup[0].Last_Assignment__c = datetime.now();
                        tempgroup[0].Millisecond__c = datetime.now().millisecondGMT();

                        //remove the record in position 0 and readd to the end
                        Assignment_Groups__c tempmember = tempgroup[0];
                        tempgroup.remove(0);
                        tempgroup.add(tempmember);
                        UniqueGMemberstoUpdate.put(tempmember.id, tempmember);
                        GrouptoGroupMember.put(id.valueof(AssignedGroup), tempgroup);
                    }

                }


            } else {
                //Opp.ownerid = failedassignment.id;
                Opp.RunRoundRobin__c = false;
            }
        }

        //update opps & related members
        if (relatedopps.isEmpty() == false) {
            update relatedopps;
        }

        if (UniqueGMemberstoUpdate.isEmpty() == false) {
            update UniqueGMemberstoUpdate.values();
        }


    }
	/* S-685520 : - Deprecated
    // This method will Make Student COmpetencies related to Business Essentials Student Expertise STatus to FulFilled On Opty.Business_Essential__c = True and Stage = Student.
    public static void updateBEToFulfilled(list<Opportunity> lstOpportunities) {
        List<Student_Competency__c> stuCompList = new List<Student_Competency__c>();
        List<student_expertise__c> stuExpList = new List<student_expertise__c>();
        stuExpList = [Select id,name, (select id,name,Status__c,IsCompleted__c From Student_Competencies__r), Area_of_Expertise__c from Student_Expertise__c Where Area_of_Expertise__r.name = 'Business Essentials (WMBA 4990)' AND Opportunity__c IN :lstOpportunities];
        system.debug('stuExpList' + stuExpList);
        if (!stuExpList.isEmpty()) {
            for (student_expertise__c stuExp : stuExpList) {
                For (Student_Competency__c sc : stuExp.Student_Competencies__r) {
                    sc.Status__c = 'Fulfilled';
                    sc.IsCompleted__c = True;
                    stuCompList.add(sc);
                }
            }
            if (!stuCompList.isEmpty()) {
                Update stuCompList;
            }
        }

    }*/

}