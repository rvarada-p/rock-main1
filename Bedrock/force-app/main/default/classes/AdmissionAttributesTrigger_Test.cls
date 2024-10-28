/************************************************************************
Name  : AdmissionAttributeTrigger
Author: Horacio Sanchez
Date  : May 11, 2021
Description: Trigger for the Admission_Attributes__c object
			 S-52090: L2: Update Credits on SP based on Admission Attributes at Opp

* Revision History
* Horacio Sanchez	- May 14, 2021 - User Story 48046: L2: Insert Selected Attributes from L1 as courses in L2 (MSN1, MSN7 and MSNA)
* Horacio Sanchez   - May 20, 2021 - User Story 52470: L2: Create Student Program Category Requirements
*************************************************************************/
@isTest
public class AdmissionAttributesTrigger_Test {
    
   	/****************************************************************
    Test method for updateTotalCreditsInProgramRNtoMSN method in StudentProgramHelper
	This method tests for RN MSN programs
    Related Story : S-48045 L2: Create new fields to add requirements. Logic for RN to MSN programs
    Created By: Horacio Sanchez
    Event : After Insert
    ********************************************************************/
    static testMethod void testUpdateAttributesOnSP_RNMSNProgram() {
        Account acc = new Account(name='Test Account');
        insert acc;
     
        Contact con = new Contact(FirstName='fname',LastName = 'lname',Email = 'email@gmail.com',Phone = '9743800309'); 
        insert con;
        
        Institution__c instn = new Institution__c(Name='Walden');
        insert instn;
        Id RecordTypeProduct =  Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        Product2 prod = new Product2(Name = 'M.S in Nursing', ProductCode='P_MSN', Family='CBL', Degree_Level__c='Graduate', Institution__c=instn.id,recordtypeid=RecordTypeProduct);
        insert prod;
        
        Product2 prod1 = new Product2(Name = 'M.S in Nursing Informatics - RN to MSN', ProductCode='C_MSN_Info_RNMSN', Parent_Program__c=prod.id, Institution__c=instn.id, 
                                      recordtypeid=RecordTypeProduct, Degree_Level__c='Graduate', Total_Credits_in_Program__c=133.00);
        insert prod1;
        
        Program_Version__c programVersion = new Program_Version__c(Active__c=true, Program_Lookup__c=prod1.id, Total_Credits_in_Program__c=133.00, Credit_Progression_Rate__c=6.6250);
        insert programVersion;
        
        Student_Program__c studentProgram = new student_program__c(Student__c=con.id);
        studentProgram.Program__c = prod1.id;
        studentProgram.Program_Version__c = programVersion.Id;
        insert studentProgram;
        
        Opportunity opp = new Opportunity(Account=acc,StageName='New', Name='Opp name', CloseDate=system.today(), Student_Program__c=studentProgram.id, primary_program__c=prod1.id);
        insert opp;
        
        Student_Program__c sp = [SELECT Id, Program__c, Total_Credits_in_Program__c, Total_Credits_in_Program_MSN__c FROM Student_Program__c WHERE Id =: studentProgram.Id LIMIT 1];
        
        System.assertEquals(133.00, sp.Total_Credits_in_Program__c);
        
        List<Attribute_Rules__c> attributeRulesList = new List<Attribute_Rules__c>();
        attributeRulesList.add(new Attribute_Rules__c(Name='TMSN3',
                                                      Subject_Area_Name__c='Humanities',
                                                      Category__c='General Education; General Elective;',
                                                      Course_Name__c='Humanities Gen Ed I',
                                                      Create_Course__c=false,
                                                      Required_Credits__c=5.0,
                                                      Subject_Matter_Expertise__c='Arts and Humanities',
                                                      Course_Codes_Pool__c='HMNT 3001;PHIL 1001S; PHIL 2001; RELG 2001')
                              );
        
        insert attributeRulesList;
        
        List<Admission_Attributes__c> aaList = new List<Admission_Attributes__c>();
        Admission_Attributes__c aa1 = new Admission_Attributes__c();
        aa1.Name = 'TMSN3';
        aa1.Opportunity__c = opp.Id;
        aaList.add(aa1);
        
        insert aa1;
        
        sp = [SELECT Id, Program__c, Total_Credits_in_Program__c, Total_Credits_in_Program_MSN__c FROM Student_Program__c WHERE Id =: studentProgram.Id LIMIT 1];
        
        System.assertEquals(138, sp.Total_Credits_in_Program_MSN__c);
        
    }
    
    /****************************************************************
    Related Story: S-48046 Insert Selected Attributes from L1 as courses in L2 (MSN1, MSN7 and MSNA)
    Created By: Horacio Sanchez
    Event : After Insert and Before Delete
    ********************************************************************/
    static testMethod void testSEandSCCreateAndDelete_Test() {
        Account acc1 = new Account(name='Test Account1');
        insert acc1;
        Account acc2 = new Account(name='Test Account2');
        insert acc2;	
     
        Contact con1 = new Contact(FirstName='fname1',LastName = 'lname1',Email = 'email1@gmail.com',Phone = '9743800309');
        insert con1;
        Contact con2 = new Contact(FirstName='fname2',LastName = 'lname2',Email = 'email2@gmail.com',Phone = '9743800302');
        insert con2;
        
        Institution__c instn = new Institution__c(Name='Walden');
        insert instn;
        
        Id RecordTypeProduct =  Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Walden').getRecordTypeId();
        
        Product2 prod = new Product2(Name = 'M.S in Nursing', ProductCode='P_MSN', Family='CBL', Degree_Level__c='Graduate', Institution__c=instn.id,recordtypeid=RecordTypeProduct);
        insert prod;
        
        Product2 prod1 = new Product2(Name = 'M.S in Nursing Informatics - RN to MSN', ProductCode='C_MSN_Info_RNMSN', Parent_Program__c=prod.id, Institution__c=instn.id, 
                                      recordtypeid=RecordTypeProduct, Degree_Level__c='Graduate', Total_Credits_in_Program__c=133.00);
        insert prod1;
        
        Student_Program__c studentProgram1 = new student_program__c(Student__c=con1.id);
        studentProgram1.Program__c = prod1.id;
        insert studentProgram1;
        Student_Program__c studentProgram2 = new student_program__c(Student__c=con2.id);
        studentProgram2.Program__c = prod1.id;
        insert studentProgram2;
        
        Opportunity opp1 = new Opportunity(Account=acc1,StageName='New', Name='Opp name1', CloseDate=system.today(), Student_Program__c=studentProgram1.id, primary_program__c=prod1.id);
        insert opp1;
        Opportunity opp2 = new Opportunity(Account=acc2,StageName='New', Name='Opp name2', CloseDate=system.today(), Student_Program__c=studentProgram2.id, primary_program__c=prod1.id);
        insert opp2;
        
        Program_Version__c programVersion = new Program_Version__c(Active__c=true, Program_Lookup__c=prod1.id, Total_Credits_in_Program__c=133.00, Credit_Progression_Rate__c=6.6250);
        insert programVersion;
        
        studentProgram1.Program__c = prod1.id;
        studentProgram1.Program_Version__c = programVersion.Id;
        update studentProgram1;
        studentProgram2.Program__c = prod1.id;
        studentProgram2.Program_Version__c = programVersion.Id;
        update studentProgram2;
        
        List<Area_of_Expertise__c> aoeList = new List<Area_of_Expertise__c>();
        Area_of_Expertise__c engl = new Area_of_Expertise__c(Name='English Composition(ENGL 1015S)', Display_name__c='English Composition(ENGL 1015S)', LMS_ID__c='11726');
        aoeList.add(engl);        
        Area_of_Expertise__c biol = new Area_of_Expertise__c(Name='Essentials of Human Anatomy and Physiology(BIOL 3020)', Display_Name__c='Essentials of Human Anatomy and Physiology(BIOL 3020)', LMS_ID__c='44654');
        aoeList.add(biol);        
        Area_of_Expertise__c stat = new Area_of_Expertise__c(Name='Statistical Methods and Applications (STAT 3001)', Display_Name__c='Statistical Methods and Applications (STAT 3001)', LMS_ID__c='14329');
        aoeList.add(stat);        
        insert (aoeList);
        
        List<Competency__c> competenciesList = new List<Competency__c>();
        Competency__c englComp1 = new Competency__c(AoE_LMS_ID__c='11726', Name='Reading to Write', Display_Name__c='Reading to Write');
        competenciesList.add(englComp1);
        Competency__c englComp2 = new Competency__c(AoE_LMS_ID__c='11726', Name='Developing Coherent Sentences and Paragraphs', Display_Name__c='Developing Coherent Sentences and Paragraphs');
        competenciesList.add(englComp2);
        Competency__c englComp3 = new Competency__c(AoE_LMS_ID__c='11726', Name='Developing a Thesis and Outline', Display_Name__c='Developing a Thesis and Outline');
        competenciesList.add(englComp3);
        Competency__c englComp4 = new Competency__c(AoE_LMS_ID__c='11726', Name='Developing a Rough Draft', Display_Name__c='Developing a Rough Draft');
        competenciesList.add(englComp4);
        Competency__c englComp5 = new Competency__c(AoE_LMS_ID__c='11726', Name='Revising and Proofreading to Develop a Final Draft', Display_Name__c='Revising and Proofreading to Develop a Final Draft');
        competenciesList.add(englComp5);
        Competency__c biol1 = new Competency__c(AoE_LMS_ID__c='44654', Name='From Atoms to Organ Systems', Display_Name__c='From Atoms to Organ Systems');
        competenciesList.add(biol1);
        Competency__c biol2 = new Competency__c(AoE_LMS_ID__c='44654', Name='Integumentary and Musculoskeletal Systems', Display_Name__c='Integumentary and Musculoskeletal Systems');
        competenciesList.add(biol2);
        Competency__c biol3 = new Competency__c(AoE_LMS_ID__c='44654', Name='The Nervous System, The Senses, and The Endocrine System', Display_Name__c='The Nervous System, The Senses, and The Endocrine System');
        competenciesList.add(biol3);
        Competency__c biol4 = new Competency__c(AoE_LMS_ID__c='44654', Name='Cardiovascular System', Display_Name__c='Cardiovascular System');
        competenciesList.add(biol4);
        Competency__c biol5 = new Competency__c(AoE_LMS_ID__c='44654', Name='Digestive System and Nutrition; Respiratory System; Urinary System', Display_Name__c='Digestive System and Nutrition; Respiratory System; Urinary System');
        competenciesList.add(biol5);
        Competency__c biol6 = new Competency__c(AoE_LMS_ID__c='44654', Name='Reproductive Systems, Pregnancy, Growth, Development, and Genetics', Display_Name__c='Reproductive Systems, Pregnancy, Growth, Development, and Genetics');
        competenciesList.add(biol6);
        Competency__c stat1 = new Competency__c(AoE_LMS_ID__c='14329', Name='Descriptive Statistics', Display_Name__c='Descriptive Statistics');
        competenciesList.add(stat1);
        Competency__c stat2 = new Competency__c(AoE_LMS_ID__c='14329', Name='Correlation and Regression', Display_Name__c='Correlation and Regression');
        competenciesList.add(stat2);
        Competency__c stat3 = new Competency__c(AoE_LMS_ID__c='14329', Name='Normal Distribution', Display_Name__c='Normal Distribution');
        competenciesList.add(stat3);
        Competency__c stat4 = new Competency__c(AoE_LMS_ID__c='14329', Name='Hypothesis Testing', Display_Name__c='Hypothesis Testing');
        competenciesList.add(stat4);
        insert competenciesList;
        
        List<Attribute_Rules__c> attributeRulesList = new List<Attribute_Rules__c>();
        attributeRulesList.add(new Attribute_Rules__c(Name='TMSN1',
                                                      Category__c='General Education; General Elective;',
                                                      Course_Name__c='ENGL 1015S',
                                                      Create_Course__c=true,
                                                      Required_Credits__c=5.0,
                                                      Subject_Matter_Expertise__c='ENGL 1015S'
                                                     )
                              );
        attributeRulesList.add(new Attribute_Rules__c(Name='TMSN2',
                                                      Subject_Area_Name__c='Communication',
                                                      Category__c='General Education; General Elective;',
                                                      Course_Name__c='Written and Oral Communications Gen Ed',
                                                      Create_Course__c=false,
                                                      Required_Credits__c=5.0,
                                                      Subject_Matter_Expertise__c='Written and Oral Communication',
                                                      Course_Codes_Pool__c='COMM 1004C; ENGL 2002; COMM 4001; COMM 1008')
                              );
        attributeRulesList.add(new Attribute_Rules__c(Name='TMSNA',
                                                      Category__c='General Education; General Elective;',
                                                      Course_Name__c='STAT 3001',
                                                      Create_Course__c=true,
                                                      Required_Credits__c=5.0,
                                                      Subject_Matter_Expertise__c='STAT 3001'
                                                     )
                              );
        attributeRulesList.add(new Attribute_Rules__c(Name='TMSN7',
                                                      Category__c='General Education; General Elective;',
                                                      Course_Name__c='BIOL 3020',
                                                      Create_Course__c=true,
                                                      Required_Credits__c=5.0,
                                                      Subject_Matter_Expertise__c='BIOL 3020'
                                                     )
                              );
        
        insert attributeRulesList;
        
        Test.startTest();
        
        List<Student_Expertise__c> seList1 = [SELECT Id, Name FROM Student_Expertise__c WHERE Student_Program__c = :studentProgram1.Id];
        List<Student_Expertise__c> seList2 = [SELECT Id, Name FROM Student_Expertise__c WHERE Student_Program__c = :studentProgram2.Id];
        System.assertEquals(0, seList1.size());
        System.assertEquals(0, seList2.size());
        
        List<Admission_Attributes__c> aaList = new List<Admission_Attributes__c>();
        Admission_Attributes__c aa1 = new Admission_Attributes__c();
        aa1.Name = 'TMSN1';
        aa1.Opportunity__c = opp1.Id;
        //aaList.add(aa1);
        insert aa1;
        
        Admission_Attributes__c aa2 = new Admission_Attributes__c();
        aa2.Name = 'TMSN2';
        aa2.Opportunity__c = opp1.Id;
        //aaList.add(aa2);
        insert aa2;
        
        Admission_Attributes__c aa3 = new Admission_Attributes__c();
        aa3.Name = 'TMSN1';
        aa3.Opportunity__c = opp2.Id;
        //aaList.add(aa3);
        insert aa3;
        
        Admission_Attributes__c aa4 = new Admission_Attributes__c();
        aa4.Name = 'TMSNA';
        aa4.Opportunity__c = opp2.Id;
        //aaList.add(aa4);
        insert aa4;
        
        Admission_Attributes__c aa5 = new Admission_Attributes__c();
        aa5.Name = 'TMSN7';
        aa5.Opportunity__c = opp2.Id;
        //aaList.add(aa5);
        insert aa5;
        
        //insert aaList;
        
        seList1 = [SELECT Id, Name FROM Student_Expertise__c WHERE Student_Program__c = :studentProgram1.Id];
        seList2 = [SELECT Id, Name FROM Student_Expertise__c WHERE Student_Program__c = :studentProgram2.Id];
        List<Student_Competency__c> scList1 = [SELECT Id, Name FROM Student_Competency__c WHERE Student_Program__c = :studentProgram1.Id];
        List<Student_Competency__c> scList2 = [SELECT Id, Name FROM Student_Competency__c WHERE Student_Program__c = :studentProgram2.Id];
        List<Student_Program_Category_Requirement__c> spcrList = [SELECT Id, Name FROM Student_Program_Category_Requirement__c WHERE Student_Program__c = :studentProgram1.Id];
        System.assertEquals(1, seList1.size());
        System.assertEquals(3, seList2.size());
        System.assertEquals(5, scList1.size());
        System.assertEquals(15, scList2.size());
        System.assertEquals(2, spcrList.size());
        
        // Delete 2 Admission Attribute 
        List<Admission_Attributes__c> aaToDelete = new List<Admission_Attributes__c>{aa1, aa4, aa5};
        delete aaToDelete;
        
        seList1 = [SELECT Id, Name FROM Student_Expertise__c WHERE Student_Program__c = :studentProgram1.Id];
        seList2 = [SELECT Id, Name FROM Student_Expertise__c WHERE Student_Program__c = :studentProgram2.Id];
        scList1 = [SELECT Id, Name FROM Student_Competency__c WHERE Student_Program__c = :studentProgram1.Id];
        scList2 = [SELECT Id, Name FROM Student_Competency__c WHERE Student_Program__c = :studentProgram2.Id];
        System.assertEquals(0, seList1.size());
        System.assertEquals(1, seList2.size());
        System.assertEquals(0, scList1.size());
        System.assertEquals(5, scList2.size());
        
        Test.stopTest();
        

    }

}