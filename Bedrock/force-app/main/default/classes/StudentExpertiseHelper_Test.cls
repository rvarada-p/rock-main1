/************************************************************************************** 
Apex Class Name     : StudentExpertiseHelper_Test
Created Date        : 10th February 2019
Function            : Test class for StudentExpertiseHelper class
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                  
* Ravitej Varada            2/10/2019                Original Version
*************************************************************************************/
@isTest
public class StudentExpertiseHelper_Test {
    static testMethod void testMethodOne(){
        List<Student_Expertise__c> studExprtiseLst = new List<Student_Expertise__c>();
        List<Student_Expertise__c> studExprtiseLst2 = new List<Student_Expertise__c>();
        Account acc = new Account(name='Test Account');
        insert acc;
        
        Opportunity opp = new Opportunity(Account=acc,StageName='New',Name='ooo',CloseDate=system.today());
        insert opp;
        
        Contact con=new Contact(FirstName='fname',LastName = 'lname',Email = 'email@gmail.com',Phone = '9743800309'); 
        insert con;
        
        Brand_Profile__c brandProf = new Brand_Profile__c(Contact__c=con.id,First_Name__c='AAAA', Last_Name__c='ZZZZ');
        insert brandProf;
        
        Area_of_Expertise__c areaOfExp = new Area_of_Expertise__c(Name='SSS');
        insert areaOfExp;
        
        Institution__c instn = new Institution__c(Name='Walden');
        insert instn;
        
        Id RecordTypeProduct =  Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Product2 prod = new Product2(Name = 'Laptop X200',Family = 'Hardware',Degree_Level__c='Undergrad',Institution__c=instn.id,
                                     recordtypeid=RecordTypeProduct,ProductCode='RNMSN');
        insert prod;
        
        Id RecordTypeProduct1 =  Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Product2 prod1 = new Product2(Name = 'Laptop X20',Parent_Program__c=prod.id,Institution__c=instn.id,recordtypeid=RecordTypeProduct1,
                                      Degree_Level__c='Undergrad',ProductCode='RNMSN');
        insert prod1;
        
        student_program__c stuProg = new student_program__c(program__c=prod1.id,Student__c=con.id);
        insert stuProg;
      
        System.assertNotEquals(studExprtiseLst,Null);    

        Area_of_Expertise__c areaOfExp1 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Core',Level__c ='3000',Subject_Area__c = 'Arts and Humanities');
        insert areaOfExp1;
        Student_Expertise__c studExprtse1 = new  Student_Expertise__c();
        studExprtse1.Opportunity__c = opp.id;
        studExprtse1.IsAchieved__c= True;
        studExprtse1.Is_Audit_History_Created__c = False;
        studExprtse1.Pseudo_CE__c = 66;
        studExprtse1.Area_of_Expertise__c=areaOfExp1.id;
        studExprtse1.Outcome_Category__c = 'Core Upper';
        studExprtse1.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse1);        
        Student_Expertise__c studExprtse51 = new  Student_Expertise__c();
        studExprtse51.Opportunity__c = opp.id;
        studExprtse51.IsAchieved__c= True;
        studExprtse51.Is_Audit_History_Created__c = False;
        studExprtse51.Pseudo_CE__c = 66;
        studExprtse51.Area_of_Expertise__c=areaOfExp1.id;
        studExprtse51.Outcome_Category__c = 'Core Upper';
        studExprtse51.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse51);
        
        Area_of_Expertise__c areaOfExp2 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Core',Level__c ='3000',Subject_Area__c = 'Written and Oral Communication');
        insert areaOfExp2;  
        Student_Expertise__c studExprtse2 = new  Student_Expertise__c();
        studExprtse2.Opportunity__c = opp.id;
        studExprtse2.IsAchieved__c= True;
        studExprtse2.Is_Audit_History_Created__c = False;
        studExprtse2.Pseudo_CE__c = 66;
        studExprtse2.Area_of_Expertise__c=areaOfExp2.id;
        studExprtse2.Outcome_Category__c = 'Core Lower';
        studExprtse2.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse2);       
        Student_Expertise__c studExprtse52 = new  Student_Expertise__c();
        studExprtse52.Opportunity__c = opp.id;
        studExprtse52.IsAchieved__c= True;
        studExprtse52.Is_Audit_History_Created__c = False;
        studExprtse52.Pseudo_CE__c = 66;
        studExprtse52.Area_of_Expertise__c=areaOfExp2.id;
        studExprtse52.Outcome_Category__c = 'Core Lower';
        studExprtse52.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse52);
        
        Area_of_Expertise__c areaOfExp3 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Core',Level__c ='3000',Subject_Area__c ='Mathematics/Natural Sciences');
        insert areaOfExp3;  
        Student_Expertise__c studExprtse3 = new  Student_Expertise__c();
        studExprtse3.Opportunity__c = opp.id;
        studExprtse3.IsAchieved__c= True;
        studExprtse3.Is_Audit_History_Created__c = False;
        studExprtse3.Pseudo_CE__c = 66;
        studExprtse3.Area_of_Expertise__c=areaOfExp3.id;
        studExprtse3.Outcome_Category__c = 'BACK';
        studExprtse3.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse3);        
        Student_Expertise__c studExprtse53 = new  Student_Expertise__c();
        studExprtse53.Opportunity__c = opp.id;
        studExprtse53.IsAchieved__c= True;
        studExprtse53.Is_Audit_History_Created__c = False;
        studExprtse53.Pseudo_CE__c = 66;
        studExprtse53.Area_of_Expertise__c=areaOfExp3.id;
        studExprtse53.Outcome_Category__c = 'BACK';
        studExprtse53.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse53);
        
        Area_of_Expertise__c areaOfExp4 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Concentration',Level__c ='1000',Subject_Area__c ='Social Sciences');
        insert areaOfExp4;  
        Student_Expertise__c studExprtse4 = new  Student_Expertise__c();
        studExprtse4.Opportunity__c = opp.id;
        studExprtse4.IsAchieved__c= True;
        studExprtse4.Is_Audit_History_Created__c = False;
        studExprtse4.Pseudo_CE__c = 66;
        studExprtse4.Area_of_Expertise__c=areaOfExp4.id;
        studExprtse4.Outcome_Category__c = 'Concentration';
        studExprtse4.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse4);
        Student_Expertise__c studExprtse54 = new  Student_Expertise__c();
        studExprtse54.Opportunity__c = opp.id;
        studExprtse54.IsAchieved__c= True;
        studExprtse54.Is_Audit_History_Created__c = False;
        studExprtse54.Pseudo_CE__c = 66;
        studExprtse54.Area_of_Expertise__c=areaOfExp4.id;
        studExprtse54.Outcome_Category__c = 'Concentration';
        studExprtse54.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse54);
        
        Area_of_Expertise__c areaOfExp5 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Core',Level__c ='1000',Subject_Area__c ='Social Sciences');
        insert areaOfExp5;  
        Student_Expertise__c studExprtse5 = new  Student_Expertise__c();
        studExprtse5.Opportunity__c = opp.id;
        studExprtse5.IsAchieved__c= True;
        studExprtse5.Is_Audit_History_Created__c = False;
        studExprtse5.Pseudo_CE__c = 66;
        studExprtse5.Area_of_Expertise__c=areaOfExp5.id;
        studExprtse5.Outcome_Category__c = 'General Elective';
        studExprtse5.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse5);
        Student_Expertise__c studExprtse55 = new  Student_Expertise__c();
        studExprtse55.Opportunity__c = opp.id;
        studExprtse55.IsAchieved__c= True;
        studExprtse55.Is_Audit_History_Created__c = False;
        studExprtse55.Pseudo_CE__c = 66;
        studExprtse55.Area_of_Expertise__c=areaOfExp5.id;
        studExprtse55.Outcome_Category__c = 'General Elective';
        studExprtse55.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse55);
        
        Area_of_Expertise__c areaOfExp6 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Education',Level__c ='3000',Subject_Area__c ='Arts and Humanities');
        insert areaOfExp6;  
        Student_Expertise__c studExprtse6 = new  Student_Expertise__c();
        studExprtse6.Opportunity__c = opp.id;
        studExprtse6.IsAchieved__c= True;
        studExprtse6.Is_Audit_History_Created__c = False;
        studExprtse6.Pseudo_CE__c = 66;
        studExprtse6.Area_of_Expertise__c=areaOfExp6.id;
        studExprtse6.Outcome_Category__c = 'General Education';
        studExprtse6.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse6);
        Student_Expertise__c studExprtse56 = new  Student_Expertise__c();
        studExprtse56.Opportunity__c = opp.id;
        studExprtse56.IsAchieved__c= True;
        studExprtse56.Is_Audit_History_Created__c = False;
        studExprtse56.Pseudo_CE__c = 66;
        studExprtse56.Area_of_Expertise__c=areaOfExp6.id;
        studExprtse56.Outcome_Category__c = 'General Education';
        studExprtse56.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse56);
        
        Area_of_Expertise__c areaOfExp7 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Concentration',Level__c ='3000',Subject_Area__c ='Mathematics/Natural Sciences');
        insert areaOfExp7;  
        Student_Expertise__c studExprtse7 = new  Student_Expertise__c();
        studExprtse7.Opportunity__c = opp.id;
        studExprtse7.IsAchieved__c= True;
        studExprtse7.Is_Audit_History_Created__c = False;
        studExprtse7.Pseudo_CE__c = 66;
        studExprtse7.Area_of_Expertise__c=areaOfExp7.id;
        studExprtse7.Outcome_Category__c = 'General Education';
        studExprtse7.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse7);
        Student_Expertise__c studExprtse57 = new  Student_Expertise__c();
        studExprtse57.Opportunity__c = opp.id;
        studExprtse57.IsAchieved__c= True;
        studExprtse57.Is_Audit_History_Created__c = False;
        studExprtse57.Pseudo_CE__c = 66;
        studExprtse57.Area_of_Expertise__c=areaOfExp7.id;
        studExprtse57.Outcome_Category__c = 'General Education';
        studExprtse57.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse57);
        
        Area_of_Expertise__c areaOfExp8 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Elective',Level__c ='3000',Subject_Area__c ='Social Sciences');
        insert areaOfExp8;  
        Student_Expertise__c studExprtse8 = new  Student_Expertise__c();
        studExprtse8.Opportunity__c = opp.id;
        studExprtse8.IsAchieved__c= True;
        studExprtse8.Is_Audit_History_Created__c = False;
        studExprtse8.Pseudo_CE__c = 66;
        studExprtse8.Area_of_Expertise__c=areaOfExp8.id;
        studExprtse8.Outcome_Category__c = 'General Education';
        studExprtse8.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse8);
        Student_Expertise__c studExprtse58 = new  Student_Expertise__c();
        studExprtse58.Opportunity__c = opp.id;
        studExprtse58.IsAchieved__c= True;
        studExprtse58.Is_Audit_History_Created__c = False;
        studExprtse58.Pseudo_CE__c = 66;
        studExprtse58.Area_of_Expertise__c=areaOfExp8.id;
        studExprtse58.Outcome_Category__c = 'General Education';
        studExprtse58.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse58);
        
        Area_of_Expertise__c areaOfExp9 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Education;General Elective',Level__c ='1000',Subject_Area__c = 'Written and Oral Communication');
        insert areaOfExp9;
        Student_Expertise__c studExprtse9 = new  Student_Expertise__c();
        studExprtse9.Opportunity__c = opp.id;
        studExprtse9.IsAchieved__c= True;
        studExprtse9.Is_Audit_History_Created__c = False;
        studExprtse9.Pseudo_CE__c = 66;
        studExprtse9.Area_of_Expertise__c=areaOfExp9.id;
        studExprtse9.Outcome_Category__c = 'General Education';
        studExprtse9.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse9);
        Student_Expertise__c studExprtse59 = new  Student_Expertise__c();
        studExprtse59.Opportunity__c = opp.id;
        studExprtse59.IsAchieved__c= True;
        studExprtse59.Is_Audit_History_Created__c = False;
        studExprtse59.Pseudo_CE__c = 66;
        studExprtse59.Area_of_Expertise__c=areaOfExp9.id;
        studExprtse59.Outcome_Category__c = 'General Education';
        studExprtse59.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse59);
        
        Area_of_Expertise__c areaOfExp10 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Core',Level__c ='3000',Subject_Area__c ='Social Sciences');
        insert areaOfExp10; 
        Student_Expertise__c studExprtse10 = new  Student_Expertise__c();
        studExprtse10.Opportunity__c = opp.id;
        studExprtse10.IsAchieved__c= True;
        studExprtse10.Is_Audit_History_Created__c = False;
        studExprtse10.Pseudo_CE__c = 66;
        studExprtse10.Area_of_Expertise__c=areaOfExp10.id;
        studExprtse10.Outcome_Category__c = 'General Elective';
        studExprtse10.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse10);
        Student_Expertise__c studExprtse60 = new  Student_Expertise__c();
        studExprtse60.Opportunity__c = opp.id;
        studExprtse60.IsAchieved__c= True;
        studExprtse60.Is_Audit_History_Created__c = False;
        studExprtse60.Pseudo_CE__c = 66;
        studExprtse60.Area_of_Expertise__c=areaOfExp10.id;
        studExprtse60.Outcome_Category__c = 'General Elective';
        studExprtse60.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse60);
        
        Area_of_Expertise__c areaOfExp11 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Elective',Level__c ='3000',Subject_Area__c ='Social Sciences');
        insert areaOfExp11; 
        Student_Expertise__c studExprtse11 = new  Student_Expertise__c();
        studExprtse11.Opportunity__c = opp.id;
        studExprtse11.IsAchieved__c= True;
        studExprtse11.Is_Audit_History_Created__c = False;
        studExprtse11.Pseudo_CE__c = 66;
        studExprtse11.Area_of_Expertise__c=areaOfExp11.id;
        studExprtse11.Outcome_Category__c = 'Back';
        studExprtse11.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse11);
        Student_Expertise__c studExprtse61 = new  Student_Expertise__c();
        studExprtse61.Opportunity__c = opp.id;
        studExprtse61.IsAchieved__c= True;
        studExprtse61.Is_Audit_History_Created__c = False;
        studExprtse61.Pseudo_CE__c = 66;
        studExprtse61.Area_of_Expertise__c=areaOfExp11.id;
        studExprtse61.Outcome_Category__c = 'Back';
        studExprtse61.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse61);
        
        Area_of_Expertise__c areaOfExp12 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Core',Level__c ='1000',Subject_Area__c ='Social Sciences');
        insert areaOfExp12; 
        Student_Expertise__c studExprtse12 = new  Student_Expertise__c();
        studExprtse12.Opportunity__c = opp.id;
        studExprtse12.IsAchieved__c= True;
        studExprtse12.Is_Audit_History_Created__c = False;
        studExprtse12.Pseudo_CE__c = 66;
        studExprtse12.Area_of_Expertise__c=areaOfExp12.id;
        studExprtse12.Outcome_Category__c = 'Back';
        studExprtse12.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse12);
        Student_Expertise__c studExprtse62 = new  Student_Expertise__c();
        studExprtse62.Opportunity__c = opp.id;
        studExprtse62.IsAchieved__c= True;
        studExprtse62.Is_Audit_History_Created__c = False;
        studExprtse62.Pseudo_CE__c = 66;
        studExprtse62.Area_of_Expertise__c=areaOfExp12.id;
        studExprtse62.Outcome_Category__c = 'Back';
        studExprtse62.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse62);

        Area_of_Expertise__c areaOfExp13 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Concentration',Level__c ='1000',Subject_Area__c ='Social Sciences');
        insert areaOfExp13; 
        Student_Expertise__c studExprtse13 = new  Student_Expertise__c();
        studExprtse13.Opportunity__c = opp.id;
        studExprtse13.IsAchieved__c= True;
        studExprtse13.Is_Audit_History_Created__c = False;
        studExprtse13.Pseudo_CE__c = 66;
        studExprtse13.Area_of_Expertise__c=areaOfExp13.id;
        studExprtse13.Outcome_Category__c = 'Back';
        studExprtse13.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse13);
        Student_Expertise__c studExprtse63 = new  Student_Expertise__c();
        studExprtse63.Opportunity__c = opp.id;
        studExprtse63.IsAchieved__c= True;
        studExprtse63.Is_Audit_History_Created__c = False;
        studExprtse63.Pseudo_CE__c = 66;
        studExprtse63.Area_of_Expertise__c=areaOfExp13.id;
        studExprtse63.Outcome_Category__c = 'Back';
        studExprtse63.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse63);
        
        Area_of_Expertise__c areaOfExp14 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='Concentration',Level__c ='1000',Subject_Area__c ='Social Sciences');
        insert areaOfExp14; 
        Student_Expertise__c studExprtse14 = new  Student_Expertise__c();
        studExprtse14.Opportunity__c = opp.id;
        studExprtse14.IsAchieved__c= True;
        studExprtse14.Is_Audit_History_Created__c = False;
        studExprtse14.Pseudo_CE__c = 66;
        studExprtse14.Area_of_Expertise__c=areaOfExp14.id;
        studExprtse14.Outcome_Category__c = 'General Elective';
        studExprtse14.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse14);
        Student_Expertise__c studExprtse64 = new  Student_Expertise__c();
        studExprtse64.Opportunity__c = opp.id;
        studExprtse64.IsAchieved__c= True;
        studExprtse64.Is_Audit_History_Created__c = False;
        studExprtse64.Pseudo_CE__c = 66;
        studExprtse64.Area_of_Expertise__c=areaOfExp14.id;
        studExprtse64.Outcome_Category__c = 'General Elective';
        studExprtse64.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse64);
        
        Area_of_Expertise__c areaOfExp15 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Education',Level__c ='1000',Subject_Area__c ='Arts and Humanities');
        insert areaOfExp15; 
        Student_Expertise__c studExprtse15 = new  Student_Expertise__c();
        studExprtse15.Opportunity__c = opp.id;
        studExprtse15.IsAchieved__c= True;
        studExprtse15.Is_Audit_History_Created__c = False;
        studExprtse15.Pseudo_CE__c = 66;
        studExprtse15.Area_of_Expertise__c=areaOfExp15.id;
        studExprtse15.Outcome_Category__c = 'General Education';
        studExprtse15.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse15);
        Student_Expertise__c studExprtse65 = new  Student_Expertise__c();
        studExprtse65.Opportunity__c = opp.id;
        studExprtse65.IsAchieved__c= True;
        studExprtse65.Is_Audit_History_Created__c = False;
        studExprtse65.Pseudo_CE__c = 66;
        studExprtse65.Area_of_Expertise__c=areaOfExp15.id;
        studExprtse65.Outcome_Category__c = 'General Education';
        studExprtse65.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse65);
        
        Area_of_Expertise__c areaOfExp16 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Education',Level__c ='1000',Subject_Area__c ='Mathematics/Natural Sciences');
        insert areaOfExp16; 
        Student_Expertise__c studExprtse16 = new  Student_Expertise__c();
        studExprtse16.Opportunity__c = opp.id;
        studExprtse16.IsAchieved__c= True;
        studExprtse16.Is_Audit_History_Created__c = False;
        studExprtse16.Pseudo_CE__c = 66;
        studExprtse16.Area_of_Expertise__c=areaOfExp16.id;
        studExprtse16.Outcome_Category__c = 'General Education';
        studExprtse16.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse16);
        Student_Expertise__c studExprtse66 = new  Student_Expertise__c();
        studExprtse66.Opportunity__c = opp.id;
        studExprtse66.IsAchieved__c= True;
        studExprtse66.Is_Audit_History_Created__c = False;
        studExprtse66.Pseudo_CE__c = 66;
        studExprtse66.Area_of_Expertise__c=areaOfExp16.id;
        studExprtse66.Outcome_Category__c = 'General Education';
        studExprtse66.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse66);
        
        Area_of_Expertise__c areaOfExp17 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Education',Level__c ='1000',Subject_Area__c ='Social Sciences');
        insert areaOfExp17; 
        Student_Expertise__c studExprtse17 = new  Student_Expertise__c();
        studExprtse17.Opportunity__c = opp.id;
        studExprtse17.IsAchieved__c= True;
        studExprtse17.Is_Audit_History_Created__c = False;
        studExprtse17.Pseudo_CE__c = 66;
        studExprtse17.Area_of_Expertise__c=areaOfExp17.id;
        studExprtse17.Outcome_Category__c = 'General Education';
        studExprtse17.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse17);
        Student_Expertise__c studExprtse67 = new  Student_Expertise__c();
        studExprtse67.Opportunity__c = opp.id;
        studExprtse67.IsAchieved__c= True;
        studExprtse67.Is_Audit_History_Created__c = False;
        studExprtse67.Pseudo_CE__c = 66;
        studExprtse67.Area_of_Expertise__c=areaOfExp17.id;
        studExprtse67.Outcome_Category__c = 'General Education';
        studExprtse67.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse67);
        
        Area_of_Expertise__c areaOfExp18 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Education',Level__c ='1000',Subject_Area__c ='Written and Oral Communication');
        insert areaOfExp18; 
        Student_Expertise__c studExprtse18 = new  Student_Expertise__c();
        studExprtse18.Opportunity__c = opp.id;
        studExprtse18.IsAchieved__c= True;
        studExprtse18.Is_Audit_History_Created__c = False;
        studExprtse18.Pseudo_CE__c = 66;
        studExprtse18.Area_of_Expertise__c=areaOfExp18.id;
        studExprtse18.Outcome_Category__c = 'General Education';
        studExprtse18.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse18);
        Student_Expertise__c studExprtse68 = new  Student_Expertise__c();
        studExprtse68.Opportunity__c = opp.id;
        studExprtse68.IsAchieved__c= True;
        studExprtse68.Is_Audit_History_Created__c = False;
        studExprtse68.Pseudo_CE__c = 66;
        studExprtse68.Area_of_Expertise__c=areaOfExp18.id;
        studExprtse68.Outcome_Category__c = 'General Education';
        studExprtse68.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse68);
        
        Area_of_Expertise__c areaOfExp19 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Education',Level__c ='1000',Subject_Area__c ='Arts and Humanities');
        insert areaOfExp19; 
        Student_Expertise__c studExprtse19 = new  Student_Expertise__c();
        studExprtse19.Opportunity__c = opp.id;
        studExprtse19.IsAchieved__c= True;
        studExprtse19.Is_Audit_History_Created__c = False;
        studExprtse19.Pseudo_CE__c = 66;
        studExprtse19.Area_of_Expertise__c=areaOfExp19.id;
        studExprtse19.Outcome_Category__c = 'Back';
        studExprtse19.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse19);
        Student_Expertise__c studExprtse69 = new  Student_Expertise__c();
        studExprtse69.Opportunity__c = opp.id;
        studExprtse69.IsAchieved__c= True;
        studExprtse69.Is_Audit_History_Created__c = False;
        studExprtse69.Pseudo_CE__c = 66;
        studExprtse69.Area_of_Expertise__c=areaOfExp19.id;
        studExprtse69.Outcome_Category__c = 'Back';
        studExprtse69.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse69);
        
        Area_of_Expertise__c areaOfExp20 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Elective',Level__c ='1000',Subject_Area__c ='Arts and Humanities');
        insert areaOfExp20; 
        Student_Expertise__c studExprtse20 = new  Student_Expertise__c();
        studExprtse20.Opportunity__c = opp.id;
        studExprtse20.IsAchieved__c= True;
        studExprtse20.Is_Audit_History_Created__c = False;
        studExprtse20.Pseudo_CE__c = 66;
        studExprtse20.Area_of_Expertise__c=areaOfExp20.id;
        studExprtse20.Outcome_Category__c = 'General Education';
        studExprtse20.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse20);
        Student_Expertise__c studExprtse70 = new  Student_Expertise__c();
        studExprtse70.Opportunity__c = opp.id;
        studExprtse70.IsAchieved__c= True;
        studExprtse70.Is_Audit_History_Created__c = False;
        studExprtse70.Pseudo_CE__c = 66;
        studExprtse70.Area_of_Expertise__c=areaOfExp20.id;
        studExprtse70.Outcome_Category__c = 'General Education';
        studExprtse70.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse70);
        
        Area_of_Expertise__c areaOfExp21 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Education',Level__c ='1000',Subject_Area__c ='Arts and Humanities');
        insert areaOfExp21; 
        Student_Expertise__c studExprtse21 = new  Student_Expertise__c();
        studExprtse21.Opportunity__c = opp.id;
        studExprtse21.IsAchieved__c= True;
        studExprtse21.Is_Audit_History_Created__c = False;
        studExprtse21.Pseudo_CE__c = 66;
        studExprtse21.Area_of_Expertise__c=areaOfExp21.id;
        studExprtse21.Outcome_Category__c = 'General Elective';
        studExprtse21.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse21);
        Student_Expertise__c studExprtse71 = new  Student_Expertise__c();
        studExprtse71.Opportunity__c = opp.id;
        studExprtse71.IsAchieved__c= True;
        studExprtse71.Is_Audit_History_Created__c = False;
        studExprtse71.Pseudo_CE__c = 66;
        studExprtse71.Area_of_Expertise__c=areaOfExp21.id;
        studExprtse71.Outcome_Category__c = 'General Elective';
        studExprtse71.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse71);
        
        Area_of_Expertise__c areaOfExp22 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Education',Level__c ='1000',Subject_Area__c ='Arts and Humanities');
        insert areaOfExp22; 
        Student_Expertise__c studExprtse22 = new  Student_Expertise__c();
        studExprtse22.Opportunity__c = opp.id;
        studExprtse22.IsAchieved__c= True;
        studExprtse22.Is_Audit_History_Created__c = False;
        studExprtse22.Pseudo_CE__c = 66;
        studExprtse22.Area_of_Expertise__c=areaOfExp22.id;
        studExprtse22.Outcome_Category__c = 'General Education';
        studExprtse22.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse22);
        Student_Expertise__c studExprtse72 = new  Student_Expertise__c();
        studExprtse72.Opportunity__c = opp.id;
        studExprtse72.IsAchieved__c= True;
        studExprtse72.Is_Audit_History_Created__c = False;
        studExprtse72.Pseudo_CE__c = 66;
        studExprtse72.Area_of_Expertise__c=areaOfExp22.id;
        studExprtse72.Outcome_Category__c = 'General Elective';
        studExprtse72.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse72);
        
        Area_of_Expertise__c areaOfExp23 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Education',Level__c ='3000',Subject_Area__c ='Mathematics/Natural Sciences');
        insert areaOfExp23;  
        Student_Expertise__c studExprtse23 = new  Student_Expertise__c();
        studExprtse23.Opportunity__c = opp.id;
        studExprtse23.IsAchieved__c= True;
        studExprtse23.Is_Audit_History_Created__c = False;
        studExprtse23.Pseudo_CE__c = 66;
        studExprtse23.Area_of_Expertise__c=areaOfExp23.id;
        studExprtse23.Outcome_Category__c = 'General Education';
        studExprtse23.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse23);        
        Student_Expertise__c studExprtse73 = new  Student_Expertise__c();
        studExprtse73.Opportunity__c = opp.id;
        studExprtse73.IsAchieved__c= True;
        studExprtse73.Is_Audit_History_Created__c = False;
        studExprtse73.Pseudo_CE__c = 66;
        studExprtse73.Area_of_Expertise__c=areaOfExp23.id;
        studExprtse73.Outcome_Category__c = 'Back';
        studExprtse73.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse73);
        
        Area_of_Expertise__c areaOfExp24 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Education',Level__c ='3000',Subject_Area__c ='Arts and Humanities');
        insert areaOfExp24;  
        Student_Expertise__c studExprtse24 = new  Student_Expertise__c();
        studExprtse24.Opportunity__c = opp.id;
        studExprtse24.IsAchieved__c= True;
        studExprtse24.Is_Audit_History_Created__c = False;
        studExprtse24.Pseudo_CE__c = 66;
        studExprtse24.Area_of_Expertise__c=areaOfExp24.id;
        studExprtse24.Outcome_Category__c = 'General Education';
        studExprtse24.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse24);     
           
        Student_Expertise__c studExprtse74 = new  Student_Expertise__c();
        studExprtse74.Opportunity__c = opp.id;
        studExprtse74.IsAchieved__c= True;
        studExprtse74.Is_Audit_History_Created__c = False;
        studExprtse74.Pseudo_CE__c = 66;
        studExprtse74.Area_of_Expertise__c=areaOfExp24.id;
        studExprtse74.Outcome_Category__c = 'Back';
        studExprtse74.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse74);
        
        Area_of_Expertise__c areaOfExp25 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Education',Level__c ='3000',Subject_Area__c ='Arts and Humanities');
        insert areaOfExp25;  
        Student_Expertise__c studExprtse25 = new  Student_Expertise__c();
        studExprtse25.Opportunity__c = opp.id;
        studExprtse25.IsAchieved__c= True;
        studExprtse25.Is_Audit_History_Created__c = False;
        studExprtse25.Pseudo_CE__c = 66;
        studExprtse25.Area_of_Expertise__c=areaOfExp25.id;
        studExprtse25.Outcome_Category__c = 'General Education';
        studExprtse25.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse25); 
        
        Student_Expertise__c studExprtse75 = new  Student_Expertise__c();
        studExprtse75.Opportunity__c = opp.id;
        studExprtse75.IsAchieved__c= True;
        studExprtse75.Is_Audit_History_Created__c = False;
        studExprtse75.Pseudo_CE__c = 66;
        studExprtse75.Area_of_Expertise__c=areaOfExp25.id;
        studExprtse75.Outcome_Category__c = 'General Elective';
        studExprtse75.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse75);
        
        Area_of_Expertise__c areaOfExp26 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Education',Level__c ='3000',Subject_Area__c ='Mathematics/Natural Sciences');
        insert areaOfExp26;  
        Student_Expertise__c studExprtse26 = new  Student_Expertise__c();
        studExprtse26.Opportunity__c = opp.id;
        studExprtse26.IsAchieved__c= True;
        studExprtse26.Is_Audit_History_Created__c = False;
        studExprtse26.Pseudo_CE__c = 66;
        studExprtse26.Area_of_Expertise__c=areaOfExp26.id;
        studExprtse26.Outcome_Category__c = 'General Education';
        studExprtse26.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse26); 
        
        Student_Expertise__c studExprtse76 = new  Student_Expertise__c();
        studExprtse76.Opportunity__c = opp.id;
        studExprtse76.IsAchieved__c= True;
        studExprtse76.Is_Audit_History_Created__c = False;
        studExprtse76.Pseudo_CE__c = 66;
        studExprtse76.Area_of_Expertise__c=areaOfExp26.id;
        studExprtse76.Outcome_Category__c = 'General Elective';
        studExprtse76.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse76);
        
        Area_of_Expertise__c areaOfExp27 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Education',Level__c ='3000',Subject_Area__c ='Social Sciences');
        insert areaOfExp27;  
        Student_Expertise__c studExprtse27 = new  Student_Expertise__c();
        studExprtse27.Opportunity__c = opp.id;
        studExprtse27.IsAchieved__c= True;
        studExprtse27.Is_Audit_History_Created__c = False;
        studExprtse27.Pseudo_CE__c = 66;
        studExprtse27.Area_of_Expertise__c=areaOfExp27.id;
        studExprtse27.Outcome_Category__c = 'General Education';
        studExprtse27.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse27); 
        
        Student_Expertise__c studExprtse77 = new  Student_Expertise__c();
        studExprtse77.Opportunity__c = opp.id;
        studExprtse77.IsAchieved__c= True;
        studExprtse77.Is_Audit_History_Created__c = False;
        studExprtse77.Pseudo_CE__c = 66;
        studExprtse77.Area_of_Expertise__c=areaOfExp27.id;
        studExprtse77.Outcome_Category__c = 'Back';
        studExprtse77.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse77);
        
        Area_of_Expertise__c areaOfExp28 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Education',Level__c ='3000',Subject_Area__c ='Social Sciences');
        insert areaOfExp28;  
        Student_Expertise__c studExprtse28 = new  Student_Expertise__c();
        studExprtse28.Opportunity__c = opp.id;
        studExprtse28.IsAchieved__c= True;
        studExprtse28.Is_Audit_History_Created__c = False;
        studExprtse28.Pseudo_CE__c = 66;
        studExprtse28.Area_of_Expertise__c=areaOfExp28.id;
        studExprtse28.Outcome_Category__c = 'General Education';
        studExprtse28.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse28); 
        
        Student_Expertise__c studExprtse78 = new  Student_Expertise__c();
        studExprtse78.Opportunity__c = opp.id;
        studExprtse78.IsAchieved__c= True;
        studExprtse78.Is_Audit_History_Created__c = False;
        studExprtse78.Pseudo_CE__c = 66;
        studExprtse78.Area_of_Expertise__c=areaOfExp28.id;
        studExprtse78.Outcome_Category__c = 'General Elective';
        studExprtse78.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse78);
        
        Area_of_Expertise__c areaOfExp29 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Education',Level__c ='3000',Subject_Area__c ='Written and Oral Communication');
        insert areaOfExp29;  
        Student_Expertise__c studExprtse29 = new  Student_Expertise__c();
        studExprtse29.Opportunity__c = opp.id;
        studExprtse29.IsAchieved__c= True;
        studExprtse29.Is_Audit_History_Created__c = False;
        studExprtse29.Pseudo_CE__c = 66;
        studExprtse29.Area_of_Expertise__c=areaOfExp29.id;
        studExprtse29.Outcome_Category__c = 'General Education';
        studExprtse29.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse29); 
        
        Student_Expertise__c studExprtse79 = new  Student_Expertise__c();
        studExprtse79.Opportunity__c = opp.id;
        studExprtse79.IsAchieved__c= True;
        studExprtse79.Is_Audit_History_Created__c = False;
        studExprtse79.Pseudo_CE__c = 66;
        studExprtse79.Area_of_Expertise__c=areaOfExp29.id;
        studExprtse79.Outcome_Category__c = 'Back';
        studExprtse79.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse79);
        
        Area_of_Expertise__c areaOfExp30 = new Area_of_Expertise__c(Name='SSS',Pseudo_Course__c=true,Category__c='General Education',Level__c ='3000',Subject_Area__c ='Written and Oral Communication');
        insert areaOfExp30;  
        Student_Expertise__c studExprtse30 = new  Student_Expertise__c();
        studExprtse30.Opportunity__c = opp.id;
        studExprtse30.IsAchieved__c= True;
        studExprtse30.Is_Audit_History_Created__c = False;
        studExprtse30.Pseudo_CE__c = 66;
        studExprtse30.Area_of_Expertise__c=areaOfExp30.id;
        studExprtse30.Outcome_Category__c = 'General Education';
        studExprtse30.Student_Program__c = stuProg.id;
        studExprtiseLst.add(studExprtse30); 
        
        Student_Expertise__c studExprtse80 = new  Student_Expertise__c();
        studExprtse80.Opportunity__c = opp.id;
        studExprtse80.IsAchieved__c= True;
        studExprtse80.Is_Audit_History_Created__c = False;
        studExprtse80.Pseudo_CE__c = 66;
        studExprtse80.Area_of_Expertise__c=areaOfExp30.id;
        studExprtse80.Outcome_Category__c = 'General Elective';
        studExprtse80.Student_Program__c = stuProg.id;
        studExprtiseLst2.add(studExprtse80);
        
        insert studExprtiseLst; 
        insert studExprtiseLst2; 
        
        
        Competency__c comp = new Competency__c();
        comp.Code__c = 'code';
        comp.Description__c = 'Test Competency';
        comp.Type__c = 'Academic';
        comp.Credit_Equivalency__c = 0.0;  
        comp.Published__c = true;  
        insert comp;
        
        List<Student_Competency__c> studComList = new List<Student_Competency__c>();
        Student_Competency__c compObj1 = new Student_Competency__c(Student_Expertise__c=studExprtse6.Id,Competency__c=comp.Id,status__c = 'Transferred');
        studComList.add(compObj1);
        Student_Competency__c compObj2 = new Student_Competency__c(Student_Expertise__c=studExprtse6.Id,Competency__c=comp.Id,status__c = 'Fulfilled');
        studComList.add(compObj2);
        insert studComList;
        
        List<Student_Audit_History__c> sahList = new List<Student_Audit_History__c>();
        for(Student_Expertise__c seObj : studExprtiseLst){
            Student_Audit_History__c sahObj = new Student_Audit_History__c(Student_Program__c = stuProg.Id,
                                                                           Earned_CE_Core_Upper__c=500,
                                                                           Student_Expertise__c=seObj.Id,
                                                                           Total_CE_Core_Upper__c=1000,
                                                                           Earned_CE_General_Electives__c = 0,
                                                                           Total_CE_General_Electives__c = 1500,
                                                                           Earned_CE_Core__c = 600,
                                                                           Total_CE_Core__c = 900,
                                                                           Earned_CE_Concentration__c = 200,
                                                                           Total_CE_Concentration__c = 400,
                                                                           Earned_CE_Arts_and_Humanities__c = 200,
                                                                           Total_CE_Arts_and_Humanities__c = 300,
                                                                           Earned_CE_Mathematics_Natural_Science__c = 100,
                                                                           Total_CE_Mathematics_Natural_Science__c = 200,
                                                                           Earned_CE_Social_Science__c = 300,
                                                                           Total_CE_Social_Science__c = 400,
                                                                           Earned_CE_Written_and_Oral_Communication__c = 100,
                                                                           Total_CE_Written_and_Oral_Communication__c = 200);
            sahList.add(sahObj);
        }
        for(Student_Expertise__c seObj : studExprtiseLst2){
            Student_Audit_History__c sahObj = new Student_Audit_History__c(Student_Program__c = stuProg.Id,
                                                                           Earned_CE_Core_Upper__c=500,
                                                                           Student_Expertise__c=seObj.Id,
                                                                           Total_CE_Core_Upper__c=1000,
                                                                           Earned_CE_General_Electives__c = 0,
                                                                           Total_CE_General_Electives__c = 1500,
                                                                           Earned_CE_Core__c = 600,
                                                                           Total_CE_Core__c = 900,
                                                                           Earned_CE_Concentration__c = 200,
                                                                           Total_CE_Concentration__c = 400,
                                                                           Earned_CE_Arts_and_Humanities__c = 200,
                                                                           Total_CE_Arts_and_Humanities__c = 300,
                                                                           Earned_CE_Mathematics_Natural_Science__c = 100,
                                                                           Total_CE_Mathematics_Natural_Science__c = 200,
                                                                           Earned_CE_Social_Science__c = 300,
                                                                           Total_CE_Social_Science__c = 400,
                                                                           Earned_CE_Written_and_Oral_Communication__c = 100,
                                                                           Total_CE_Written_and_Oral_Communication__c = 200);
            sahList.add(sahObj);
        }
        insert sahList;
        
        StudentExpertiseHelper.calculateGradeValue(studExprtiseLst);
        StudentExpertiseHelper.calculateGrandGPAOnStudentProgram(new set<ID>{stuProg.Id});
        StudentExpertiseHelper sehlpr = new StudentExpertiseHelper();
               
        Program_Expertise__c pe1 = new Program_Expertise__c();
        pe1.Program__c = prod.id;
        insert pe1;
        Student_Expertise__c studExprtseTR = new  Student_Expertise__c();
        studExprtseTR.Opportunity__c = opp.id;
        studExprtseTR.IsAchieved__c= True;
        studExprtseTR.Is_Audit_History_Created__c = False;
        studExprtseTR.Pseudo_CE__c = 66;
        studExprtseTR.Area_of_Expertise__c=areaOfExp20.id;
        studExprtseTR.Outcome_Category__c = 'General Education';
        studExprtseTR.Fulfilled_Course_from_a_Conferred_Degree__c = true;
        studExprtseTR.Student_Program__c = stuProg.id;
        studExprtseTR.Total_Applied_Earned_CE_Outcome__c = 10;
        studExprtseTR.Program_Expertise__c = pe1.id;
        insert studExprtseTR;
        update stuProg;
        StudentExpertiseHelper.calculateUGProgramTransferredFulfilledCE(new set<ID>{stuProg.Id});
          
        //sehlpr.rollUpNumberOfStudentExpertiseCompletedOnStudentProgram(new set<ID>{stuProg.Id});
        //Student_Expertise__c studExprtse7 = new Student_Expertise__c(id=studExprtse6.Id,Pseudo_CE__c = 68,IsAchieved__c= false);
        //StudentExpertiseHelper.delAndcreateStudentAuditHistory(new Map<Id, Student_Expertise__c>{studExprtse6.Id=>studExprtse6},new List<Student_Expertise__c>{studExprtse7});
        /*for(Student_Expertise__c seObj : studExprtiseLst)
            seObj.IsAchieved__c = false;
        update studExprtiseLst;*/
    }
}