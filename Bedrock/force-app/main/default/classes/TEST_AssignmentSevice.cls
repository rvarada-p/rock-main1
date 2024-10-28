@isTest
private class TEST_AssignmentSevice {
    
    static testMethod void myUnitTest() {
        
        //for controller
        list<User> logUser = [select id, Name from User where isActive = true ];
        Test.startTest();  
        
        Assignment_Group_CST__c ag = new Assignment_Group_CST__c();
        ag.Name = 'Tset';
        ag.Start_Assignment_Time__c = '9PM';
        ag.End_Assignment_Time__c = '9PM';
        ag.Status__c = 'Active';
        insert ag;
        
        sme_cohort__c smeCohort = new sme_cohort__c(SME_Assignment_Group__c =ag.id, License_Type__c  ='Non-Cohort');
        insert smeCohort;
        
        sme_cohort__c   smeCohort2 = new sme_cohort__c(SME_Assignment_Group__c =ag.id, License_Type__c  = 'Non-Cohort');
        insert smeCohort2;
        
        Customer_Support_Team__c newobj1 = new Customer_Support_Team__c();
        Customer_Support_Team__c newobj2 = new Customer_Support_Team__c();
        Customer_Support_Team__c newobj3 = new Customer_Support_Team__c();
        
        newobj1.User__c = logUser[0].id;
        newobj1.Status__c = 'Active';
        newobj1.Split_Weight__c = 78;
        newobj1.SME_Cohort_Group__c = smeCohort.id;
        newobj1.Out_Of_Office_Start_Date__c = date.today().addDays(-2);
        newobj1.Out_Of_Office_End_Date__c = date.today().addDays(-1);
        insert newobj1;
        newobj1.Status__c = 'Inactive';
        update newobj1;
        
        newobj2.User__c = logUser[0].id;
        newobj2.Status__c = 'Active';
        newobj2.Split_Weight__c = 70;
        newobj2.SME_Cohort_Group__c = smeCohort2.id;
        newobj2.Out_Of_Office_Start_Date__c = date.today().addDays(-2);
        newobj2.Out_Of_Office_End_Date__c = date.today();
        insert newobj2;
        
        newobj3.User__c = logUser[0].id;
        newobj3.Status__c = 'Active';
        newobj3.Split_Weight__c = 70;
        newobj3.SME_Cohort_Group__c = smeCohort2.id;
        insert newobj3;
        
        Contact con = new Contact();
        con.LastName = 'test';
        insert con;
        
        Competency__c com = new Competency__c();
        com.Name = 'test';
        com.Assignment_Group_CST__c = ag.id;
        insert com;
        
        Student_Competency__c sc = new Student_Competency__c();
        sc.Contact__c = con.id;
        sc.Assessment_Submitted__c = true;
        sc.Competency__c = com.id;
        insert sc;
        
        Student_Competency__c sc2 = new Student_Competency__c();
        sc2.Contact__c = con.id;
        sc2.Assessment_Submitted__c = false;
        sc2.Competency__c = com.id;
        insert sc2;
        sc2.Assessment_Submitted__c = true;
        update sc2;
        
        CustomerSupportTeamReset cst = new CustomerSupportTeamReset();
        cst.OvernightReset();
        
        MyGroupAssignmentController mgac = new MyGroupAssignmentController();
        mgac.UserId = logUser[0].id;
        mgac.GroupId = newobj1.id;
        mgac.deactivate();
        mgac.activate();
        
        MyGroupAssignmentPopUpWindow mgap = new MyGroupAssignmentPopUpWindow();
        mgap.mgaId = newobj1.id;
        mgap.allgr = true;
        mgap.saveobj();
        mgap.allgr = false;
        mgap.saveobj();
        
        
        
        
    }
    
}