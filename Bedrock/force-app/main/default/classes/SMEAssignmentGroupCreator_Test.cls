@isTest
public class SMEAssignmentGroupCreator_Test {


    static testMethod void Test_getCSVObject() {
        String simulatedLines =

                'Code,Email,Assignment Group Name,Status,Split Weight,Current Section,SME Cohort Required?\n' +
                        'TEST01,test1@mail.waldenu.edu.invalid,TEST01 SME Group,Active,,1,No\n' +
                        'TEST02,test2@mail.waldenu.edu.invalid,TEST02 SME Group,Active,,1,Yes\n' +
                        'TEST02,test3@mail.waldenu.edu.invalid,TEST02 SME Group,Active,,1,Yes\n' +
                        'TEST02,test1@mail.waldenu.edu.invalid,TEST02 SME Group,Active,,1,Yes\n' +
                        'TEST02,test4@mail.waldenu.edu.invalid,TEST02 SME Group,Active,,1,Yes\n' +
                        'TEST02,test5@mail.waldenu.edu.invalid,TEST02 SME Group,Active,,1,Yes\n' +
                        'TEST02,test6@mail.waldenu.edu.invalid,TEST02 SME Group,Active,,1,Yes\n' +
                        'TEST02,test7@mail.waldenu.edu.invalid,TEST02 SME Group,Active,,1,Yes';
        Test.startTest();

        // Insert the custom settings for D2L
        D2L__c setting = new D2L__c();
        setting.Name = 'D2L';
        setting.Org_Unit_ID__c = 6606;
        setting.Program_Type__c = 102;
        setting.LP_Version__c = 1.50;
        setting.Create_AoE__c = '/d2l/api/lp/1.5/courses/';
        insert setting;


        // Insert Competency
        Competency__c competency = new Competency__c();
        competency.Name = 'Test Competency';
        competency.Code__c = 'TEST01';
        insert competency;

        // Insert Competency
        Competency__c competency1 = new Competency__c();
        competency1.Name = 'Test Competency';
        competency1.Code__c = 'TEST02';
        insert competency1;


        Profile p = [SELECT id FROM Profile WHERE name = 'System Administrator'];
        List<User> uLst = new List<User>();

        Map<string,string> smeMap =  new     Map<string,string> ();
        smeMap.put('test1@mail.waldenu.edu.invalid','Non-Cohort');
        smeMap.put('test2@mail.waldenu.edu.invalid',   'Compact' );
        smeMap.put('test3@mail.waldenu.edu.invalid',  'Minnesota'  );
        smeMap.put('test4@mail.waldenu.edu.invalid', 'Non-Cohort' );
        smeMap.put('test5@mail.waldenu.edu.invalid',  'Alaska' );
        smeMap.put('test6@mail.waldenu.edu.invalid', 'Non-Cohort' );
        smeMap.put('test7@mail.waldenu.edu.invalid', 'Massachusetts' );
        smeMap.put('test8@mail.waldenu.edu.invalid',    'Washington' );
        smeMap.put('test9@mail.waldenu.edu.invalid',  'Compact' );



        /*    smeMap.put('test1@mail.waldenu.edu.invalid', new set<string> {'Non-Cohort'} );
            smeMap.put('test2@mail.waldenu.edu.invalid', new set<string> {'Non-Cohort','Alaska','Compact'} );
            smeMap.put('test3@mail.waldenu.edu.invalid', new set<string> {'Non-Cohort','Minnesota','Compact'} );
            smeMap.put('test4@mail.waldenu.edu.invalid', new set<string> {'Non-Cohort','Alaska'} );
            smeMap.put('test5@mail.waldenu.edu.invalid', new set<string> {'Non-Cohort','Alaska'} );
            smeMap.put('test6@mail.waldenu.edu.invalid', new set<string> {'Non-Cohort'} );
            smeMap.put('test7@mail.waldenu.edu.invalid', new set<string> {'Non-Cohort','Massachusetts'} );
            smeMap.put('test8@mail.waldenu.edu.invalid', new set<string> {'Non-Cohort','Washington'} );
            smeMap.put('test9@mail.waldenu.edu.invalid', new set<string> {'Non-Cohort','Compact'} );
    */

        for(string sme :smeMap.KeySet()){

            // Insert user
            User u = new User();
            u.Email = sme;
            u.username = sme;
            u.LastName = sme.left(sme.length()-25);
            u.Alias = sme.left(sme.length()-25);
            u.TimeZoneSidKey = 'America/New_York';
            u.LocaleSidKey = 'en_US';
            u.EmailEncodingKey = 'ISO-8859-1';
            u.ProfileId = p.id;
            u.LanguageLocaleKey = 'en_US';
            u.SME_Cohort_License_Type__c = smeMap.get(sme);
            u.LMS_Id__c = 213;


            uLst.add(u);
        }

        insert uLst;

        SMEAssignmentGroupCreator.getCSVObject(simulatedLines);





        Test.stopTest();
    }

}