/*******************************************************************
Name  : BrandProfilesTriggerHandler
Author: Vinod (Appirio)
Date  : September 17, 2014
Description: Handler class for the Trigger BrandProfilesTrigger
*************************************************************************/
public with sharing class TempoProfileHelper {

    public void associateBrandProfileWithContact(list<Brand_Profile__c>selectedBrands){

        // find and map any matching Contacts
    ContactHelper helper = new ContactHelper();
    list<Lead> newLeads = new list<Lead>();
    for(Brand_Profile__c bProfile:selectedBrands){
        Lead mockLead = createLead(bProfile);
        mockLead.Description = bProfile.Id;
        newLeads.add(mockLead); 
    }
    
    map<Lead,Contact> mapNewLead_ExistingContact = new map<Lead,Contact>();
    mapNewLead_ExistingContact = helper.getExistingContactMap(newLeads);    
    
    map<Id,Contact> mapBrandProfileID_ExistingContact = new map<Id,Contact>();

    if(!mapNewLead_ExistingContact.isEmpty()){
        for(Lead keyLead:mapNewLead_ExistingContact.keySet()){
            mapBrandProfileID_ExistingContact.put(keyLead.Description,mapNewLead_ExistingContact.get(keyLead));
        }
    }
    
        list<Brand_Profile__c> lstBrandProfileForUpdate = new list<Brand_Profile__c>(); 
        list<Lead> lstLeads = new list<Lead>();     
        set<Id> existingContactIds = new set<Id>();

        for(Brand_Profile__c bProfile:selectedBrands){
            bProfile.Coach_Marks_On_Off__c = true;
            bProfile.ChatterFreeUsername__c = bProfile.Email__c + '.tempowalden'; 
            bProfile.Brand_Username__c = bProfile.Email__c;

            Lead newLead = createLead(bProfile);
            if(mapBrandProfileID_ExistingContact.containsKey(bProfile.Id)){
                bProfile.Contact__c = mapBrandProfileID_ExistingContact.get(bProfile.Id).Id;
                existingContactIds.add(mapBrandProfileID_ExistingContact.get(bProfile.Id).Id);
          } else {
                // create lead
                lstBrandProfileForUpdate.add(bProfile);
                lstLeads.add(newLead); 
            }
        }
        // If existing Contact, check for any existing Brand Profiles 
        if(!existingContactIds.isEmpty()) {
            validateTempoBrandProfileExistForTheSelectedContact(selectedBrands,existingContactIds);
        }

        // Insert/convert Lead and associate the new Contact to the new Brand Profile
        //   the Opp will be created in the afterInsert code. Sibling method: associateContactOpportunityWithBrandProfile
        if(!lstLeads.isEmpty()){
            
            // Prevent LeadHelper.convertLead from firing by setting this static var
            LeadTriggerHandler.isLeadCreatedFromBrandProfileTrigger = true;
            insert lstLeads;

            // Lead conversion
            list<Database.LeadConvert> leadConverts = new list<Database.LeadConvert>();
            for(Lead newLead : lstLeads){
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(newLead.Id);
                lc.convertedStatus = 'Qualified';
                lc.setDoNotCreateOpportunity(true);
                lc.setOverWriteLeadSource(true);
                leadConverts.add(lc);
            }
            // Finally, associate the new Contact to the new Brand Profile, once Lead is converted
            system.debug('leadConverts:::::::::::::;'+leadConverts);
            list<Database.LeadConvertResult> results = Database.convertLead(leadConverts);
            for (integer j = 0; j < results.size(); j++) {              
        if (results[j].isSuccess()) {
          system.debug('Lead converted successfully!');
          lstBrandProfileForUpdate[j].Contact__c = results[j].getContactId();                   
        } else {
          system.debug('Error converting new Lead: '+ results[j].getErrors()[0].getMessage());
        }
        }
        }

    }
    
    public void syncBrandProfileEmailAndChatterInformation(list<Brand_Profile__c> lstBrands) {
        System.debug('syncBrandProfileEmailAndChatterInformation');
        list<Brand_Profile__c> lstBPsToUpdate = new list<Brand_Profile__c>();
        map<String, String> mapBPChatterUser = new map<String, String>();

        list<Brand_Profile__c> selectedBrands = [SELECT ChatterFreeUserName__c, ChatterFreeUserId__c, 
                                                        First_Name__c, Last_Name__c, Email__c, Walden_Email__c,
                                                        Contact__c, Tempo_Id__c, Id, Lead_Source__c, L1_EA_Name__c  
                                                     FROM Brand_Profile__c 
                                                    WHERE Id IN: lstBrands];
        String chatterFreeUserName = '';
        for(Brand_Profile__c bp : selectedBrands) {
            chatterFreeUserName = bp.Email__c + '.tempowalden';
            bp.ChatterFreeUsername__c = chatterFreeUserName; 
            if(bp.ChatterFreeUserId__c != null) {
                if(!mapBPChatterUser.containsKey(bp.ChatterFreeUserId__c)) {
                    mapBPChatterUser.put(bp.ChatterFreeUserId__c, chatterFreeUserName);
                } 
            }
            lstBPsToUpdate.add(bp);
        }

        if(lstBPsToUpdate.size()>0) {
            update lstBPsToUpdate;
        }   
        if(!mapBPChatterUser.isEmpty()) {
            updateChatterFreeUser(mapBPChatterUser);
        }
    }
    
    @future
    private static void updateChatterFreeUser(map<String, String> mapBPChatterUser) {
        if(!mapBPChatterUser.isEmpty()) {
            list<User> usersToUpdate = new list<User>();
            for(String key : mapBPChatterUser.keySet()) {
                String newChatterFreeUsername = mapBPChatterUser.get(key);
                User chatterFreeUser = new User(Id = key, Username = newChatterFreeUsername);
                usersToUpdate.add(chatterFreeUser);
            }
            if(!usersToUpdate.isEmpty()) {
                update usersToUpdate;
            }
        }       
    }
     
    //This method creates the Student's record in BrightSpace LMS
    public void createStudentInBS(list<Brand_Profile__c> lstBrands) {
        System.debug('Create User in BS'); 
        JsonWrapper jsonGenerator = new JsonWrapper();
        try {
            Decimal parentId = D2L__c.getValues('D2L').Org_Unit_ID__c;
            Decimal studentRoleId = D2L__c.getValues('D2L').Student_Role_ID__c;

            for(Brand_Profile__c bf: lstBrands) {
                System.debug('CBL Student ID: ' + bf.CBL_Student_ID__c + 'First Name: '  + bf.First_Name__c + ' Last Name: ' + bf.Last_Name__c + ' Email: ' + bf.Email__c + ' Student Role: ' + studentRoleId);
                String json = jsonGenerator.createUser(bf.CBL_Student_ID__c, bf.First_Name__c, bf.Last_Name__c, bf.Email__c, studentRoleId, false);
                BrightSpaceCalls.createUser(json, bf.Id);
            }    
        }
        catch(Exception exp) {
            System.debug(exp);
        }
    }

    
    public void associateContactOpportunityWithBrandProfile(list<Brand_Profile__c>lstBrands, set<ID>setContactID){
        // get brand with Primary_Program_of_Interest__c name to make opportunity name
        list<Brand_Profile__c> selectedBrands = [SELECT Primary_Program_of_Interest__r.Name, COP_Related_Opportunity__c, Primary_Program_of_Interest__c, Change_of_Program__c, 
                                                                                              First_Name__c, Last_Name__c, Email__c, Walden_Email__c,
                                                                                              Contact__c, Tempo_Id__c, Id, Lead_Source__c, L1_EA_Name__c  
                                                     FROM Brand_Profile__c 
                                                    WHERE Id IN: lstBrands];
        // map to store contact
        map<ID,Contact> mapContacts = new map<ID,Contact>();
        for(Contact con:[Select Id, Email,AccountId,FirstName,LastName,
                        (Select Id, Brand_Profile__c, Primary_Program__c,StageName From Opportunities__r where IsClosed = false)
                        From Contact where id in: setContactID]){
            mapContacts.put(con.ID,con);
        }
        System.debug('mapContacts::::::' + mapContacts);

        list<Opportunity> lstOpportunities = new list<Opportunity>([SELECT Id, Primary_Program__c, Student_Program__c 
                                                                    FROM Opportunity WHERE Contact__c IN : setContactID]);



        list<Opportunity> lstOpportunity = new list<Opportunity>();
        
        // set to hold Brand_Profile__c.Primary_Program_of_Interest__c
        map<ID,Brand_Profile__c> mapPrimaryProgramOfInterestWithBrandProfile = new map<ID,Brand_Profile__c>();
        list<Brand_Profile__c> bpListForTBYB = new list<Brand_Profile__c>();

    //map<ID,list<Brand_Profile__c>> mapPrimaryProgram_BrandProfileList = new map<ID,list<Brand_Profile__c>>();

        // list
        list<Lead> lstLeads = new list<Lead>(); 
        //
        for(Brand_Profile__c bProfile: selectedBrands){

            // This will be everything incoming 
            if(mapContacts.containsKey(bProfile.Contact__c)){
                
                Contact selectedContact = mapContacts.get(bProfile.Contact__c);
                system.debug('selectedContact:::: ' + selectedContact);
                system.debug('selectedContact.Opportunities__r:::::::::'+selectedContact.Opportunities);
                
                // Check to see if a “non-closed” Opportunity exists where the Brand_Profile.Email__c equals the Opp's Contact’s Email
                
                //if(selectedContact.Opportunities__r != null && selectedContact.Opportunities__r.size() > 0){
                    //  “non-closed” Opportunity exists
                    for(Opportunity opty: lstOpportunities){
                        //If yes, check to see if the Brand_Profile.Primary_Program_of_Interest__c equals the found Opp’s Primary_Program__c                        
                       // if(bProfile.Primary_Program_of_Interest__c == opty.Primary_Program__c){
                            // associate the new Brand Profile with the found Contact and the found Opp with the new Brand Profile’s Id
                            opty.Brand_Profile__c = bProfile.ID;
                            lstOpportunity.add(opty);
                        /*
                        }else{
                            // create opportunity
                            Opportunity newOpty = createOpportunity(bProfile,selectedContact.ID,selectedContact.AccountId);
                            system.debug('newOpty11111::::::::'+newOpty);
                            lstOpportunity.add(newOpty);
                            if(bProfile.Primary_Program_of_Interest__c != null){
                              mapPrimaryProgramOfInterestWithBrandProfile.put(bProfile.Primary_Program_of_Interest__c,bProfile);                              
                            }
                        }
                        */
                        
                        if(bProfile.Primary_Program_of_Interest__c != null){
                          mapPrimaryProgramOfInterestWithBrandProfile.put(bProfile.Primary_Program_of_Interest__c,bProfile);      
                          bpListForTBYB.add(bProfile);                      
                        }
                        
                    /*        
                    }

                } else {
                    // associate the new Brand Profile with the found Contact and the found Opp with the new Brand Profile’s Id
                    // create opportunity
                    Opportunity opty = createOpportunity(bProfile,selectedContact.ID,selectedContact.AccountId);
                    lstOpportunity.add(opty);
                    system.debug('newOpty22222::::::'+opty);
                    if(bProfile.Primary_Program_of_Interest__c != null){
                        mapPrimaryProgramOfInterestWithBrandProfile.put(bProfile.Primary_Program_of_Interest__c,bProfile);    
                        bpListForTBYB.add(bProfile);
                    }
                     */
                }

            } 
        }
        // Insert or Update Opportunities
        if(!lstOpportunity.isEmpty()){
            system.debug('lstOpportunity:::::::::::;'+lstOpportunity);
            upsert lstOpportunity;
        }
        if(!bpListForTBYB.isEmpty()){
        //if(!mapPrimaryProgramOfInterestWithBrandProfile.isEmpty()){
            // create TBYB Student_Competency__c and Student_Expertise__c 
            StudentSuiteFactory objSFactory = new StudentSuiteFactory(); 
            objSFactory.createTBYBStudentCompetencyAndStudentExpertiseForBrandProfile(bpListForTBYB);
            //objSFactory.createTrialStudentCompetencyAndStudentExpertise(mapPrimaryProgramOfInterestWithBrandProfile);
        }
        // create Create a Chatter Free User
        // Related :Task:T-320117
        if(!mapContacts.isEmpty()){
            //createChatterFreeAccount(mapContacts.values(),selectedBrands);
        }

    }

   /* 
    public void associatedBrandProfileWithOpportunity(List<Brand_Profile__c selectedBrands) {
        set<Id> lstStudentIds = new set<Id>();
        lst<Opportunity> lstOppsToUpdate = new list<Opportunity>();
        for(Brand_Profile__c bp : selectedBrands) {
            lstStudentIds.add(bp.Contact__c);
        }

        list<Opportunity> lstOpportunities = new list<Opportunity>([SELECT Id, Primary_Program__c, Student_Program__c 
                                                                    FROM Opportunity WHERE Contact__c IN : lstStudentIds]);

        for(Opportunity opp : lstOpportunities) {
            for(Brand_Profile__c currentBp : selectedBrands) {
                if(currentBp.Contact__c == opp.Contact__c) {
                    opp.Brand_Profile__c = currentBp;
                    lstOppsToUpdate.add(opp);
                }
            }
        }
        if(lstOppsToUpdate.size()>0) {
            update lstOppsToUpdate;
        }
    }
    */
    
    /*******************************************************************
    Method to create Create opportunity if Primary Program Of Interest Changed 
    IF Open opportunity not found
    Related task: T-320845
    ********************************************************************/
    public void createOpportunityOnPrimaryProgramOfInterestChanged(list<Brand_Profile__c>selectedBrands1){
        // list to store selected brand profile with open opportunity
        set<ID>brandProfileHasOpenOpportunity = new set<ID>();
        // get open opportunity where the Opp.Primary_Progam__c matches the new Prim Prog of Interest
        for(Opportunity opp:[Select Id,Brand_Profile__c,Primary_Program__c, 
                            Brand_Profile__r.Primary_Program_of_Interest__c, IsClosed,Brand_Profile__r.Primary_Program_of_Interest__r.Name
                            From Opportunity where IsClosed = false and  Primary_Program__c != null and Brand_Profile__c in:selectedBrands1]){
            if(opp.Brand_Profile__r.Primary_Program_of_Interest__c == opp.Primary_Program__c){
                brandProfileHasOpenOpportunity.add(opp.Brand_Profile__c);
            }
        }
        set<ID> contactIds = new set<ID>();
        list<Brand_Profile__c>selectedBrands = new list<Brand_Profile__c>();
        for(Brand_Profile__c bp:[Select ID, COP_Related_Opportunity__c, L1_EA_Name__c, Lead_Source__c, Primary_Program_of_Interest__c,Primary_Program_of_Interest__r.Name, Change_of_Program__c, 
                                Phone__c,First_Name__c,Last_Name__c,Email__c,Contact__c,Tempo_Id__c, Walden_Email__c from Brand_Profile__c where id in: selectedBrands1]){
            if(bp.Contact__c != null){
                contactIds.add(bp.Contact__c);
            }
            selectedBrands.add(bp);
        }
        // get all contact with account id to populate account id in opportunity
        map<id,Contact> mapContact = new map<ID,Contact>();
        for(Contact con: [select id,AccountID from Contact where id in: contactIds]){
            mapContact.put(con.ID,con);
        }
        
        // store newly created opportunity
        list<Opportunity> lstOpportunity = new list<Opportunity>();
        //set       
        set<ID> primaryProgramOfInterestIds = new set<ID>();
        for(Brand_Profile__c bProfile: selectedBrands){
            // check  non-closed Opportunity is exist
            // if not then create new opportunity
            if(!brandProfileHasOpenOpportunity.contains(bProfile.ID)){
                Id accId;
                if(mapContact.containsKey(bProfile.Contact__c)){
                    accId = mapContact.get(bProfile.Contact__c).AccountID;
                }
                // not any open opportunity exist
                lstOpportunity.add(createOpportunity(bProfile,bProfile.Contact__c,accId));  
            }
            // strore contact and Primary_Program_of_Interest__c to create StudentCompetency And StudentExpertise
            //contactIds.add(bProfile.Contact__c);
            primaryProgramOfInterestIds.add(bProfile.Primary_Program_of_Interest__c);
        }
        // create/ update opportunity
        if(!lstOpportunity.isEmpty()){
            system.debug('lstOpportunity:::::::::update::;'+lstOpportunity);
            upsert lstOpportunity;
        }
        System.debug('Selected Brands :: ' + selectedBrands + ' Contact IDs :: ' + contactIds + ' Primary Program :: ' + primaryProgramOfInterestIds);
        StudentSuiteFactory objSFactory = new StudentSuiteFactory(); 
        objSFactory.createStudentCompetencyAndStudentExpertise(selectedBrands,contactIds,primaryProgramOfInterestIds);      
    }
    
    /*******************************************************************
    Method to create Lead records
    ********************************************************************/
    private Lead createLead(Brand_Profile__c bProfile){
        Lead newLead = new Lead();
        newLead.FirstName = bProfile.First_Name__c;
        newLead.LastName = bProfile.Last_Name__c;
        newLead.Company = bProfile.First_Name__c + ' ' + bProfile.Last_Name__c;
        newLead.Email = bProfile.Email__c;
        newLead.Phone = bProfile.Phone__c;
        newLead.LeadSource = 'Tempo';
        newLead.Program_of_Interest__c = bProfile.Primary_Program_of_Interest__c;
        return newLead;
    }

    /*******************************************************************
    Method to create Opportunity records
    ********************************************************************/
    private Opportunity createOpportunity(Brand_Profile__c bProfile, id ContactID, id accountID){
        Opportunity newOpty = new Opportunity();
        string opportunityName = '';
        if(bProfile.First_Name__c != null){
            opportunityName = bProfile.First_Name__c.subString(0,1);
            opportunityName+='.';
        }
        if(bProfile.Last_Name__c != null){
            opportunityName+= bProfile.Last_Name__c;
        }
        if(bProfile.Primary_Program_of_Interest__c != null ){
            opportunityName+= ':'+bProfile.Primary_Program_of_Interest__r.Name;
        }
        if(bProfile.Change_of_Program__c == true) {
            newOpty.Change_of_Program__c = true;
        }
        if(bProfile.COP_Related_Opportunity__c!=null) {
            newOpty.COP_Related_Opportunity__c = bProfile.COP_Related_Opportunity__c;
        }  
        if(bProfile.Lead_Source__c!=null) {  
            newOpty.LeadSource = bProfile.Lead_Source__c;
        }
        if(bProfile.L1_EA_Name__c!=null) {
            newOpty.L1_EA_Name__c = bProfile.L1_EA_Name__c;
        }
        else {
            newOpty.LeadSource = 'Tempo';           
        }
        system.debug('opportunityName:::::::::::::::'+opportunityName);
        newOpty.Name = opportunityName;
        newOpty.Contact__c = ContactID;
        newOpty.StageName = 'New';
        newOpty.Probability = 5;
        newOpty.CloseDate = date.today().addDays(365);
        newOpty.Brand_Profile__c = bProfile.id;
        newOpty.Primary_Program__c = bProfile.Primary_Program_of_Interest__c;
        newOpty.AccountID= accountID;
        newOpty.Student_Institution_Email__c = bProfile.Email__c;
        newOpty.Student_Primary_Email__c = bProfile.Walden_Email__c;
        
        return newOpty;
    }

    /*******************************************************************
    Method to create Chter Free User for the Selected Contact
    Related Task: T-320117
    ********************************************************************/
    public void createChatterFreeAccount(list<Contact> selectedContact,list<Brand_Profile__c> selectedBrands){
        // get chatter free profile id
        ID chatterFreeProfileId = null;
        for(Profile pf:[Select Id From Profile where Name like 'Tempo Chatter Free']){
            chatterFreeProfileId = pf.Id;
        }
        // check chater frre user is alreay exist with same contact
    set<string> userAlreadyCreatedForContact = new set<string>();
    for(Contact con: selectedContact){
        userAlreadyCreatedForContact.add(con.Email + '.tempowalden');
    }
        for(User usr:[Select ID,Email,Username from user where Username in: userAlreadyCreatedForContact]){
            userAlreadyCreatedForContact.add(usr.Email);
            userAlreadyCreatedForContact.add(usr.Username);
        }
        map<String,Brand_Profile__c> mapEmail_BrandProfile = new map<String,Brand_Profile__c>();
        for(Brand_Profile__c bp : selectedBrands){
      mapEmail_BrandProfile.put(bp.Email__c,bp);
        }

        list<User> lstUsers = new list<User>();
        for(Contact con: selectedContact){
            if(!userAlreadyCreatedForContact.contains(con.Email)){
                User chatterFreeuser = new User();
                chatterFreeuser.FirstName = con.FirstName;
                chatterFreeuser.LastName = con.LastName;
                chatterFreeuser.Email = 'nochatteremail@laureate.com';
                chatterFreeuser.Username  = con.Email + '.tempowalden'; 
                chatterFreeuser.Alias = (con.LastName.length() > 8) ? con.LastName.substring(0,7) : con.LastName;
                chatterFreeuser.CommunityNickname = con.FirstName.substring(0,1) + con.LastName + String.valueOf(Datetime.now()).remove('-').remove(':').deleteWhitespace();
                chatterFreeuser.ProfileId = chatterFreeProfileId;
                chatterFreeuser.LanguageLocaleKey = 'en_US';
            chatterFreeuser.LocaleSidKey = 'en_US';
            chatterFreeuser.EmailEncodingKey = 'ISO-8859-1';
            chatterFreeuser.TimeZoneSidKey = 'America/New_York';
            chatterFreeuser.IsActive = true;
            lstUsers.add(chatterFreeuser);
            }
        }
        if(!lstUsers.isEmpty()){
            try {
        insert lstUsers;
        // next update the Brand Profile with new ChatterFreeUserId__c
        // and update the new User with Tempo Id
        map<String,Contact> mapEmail_Contact = new map<String,Contact>();
        list<User> newUserList = new list<User>([SELECT Id, Username, ContactId, Tempo_Id__c FROM User WHERE Id IN :lstUsers ]);
        system.debug( '***** created chatterfree user: '+ newUserList[0].Username );
        for(User u : newUserList) {
                System.setPassword(u.Id,'zyxwv98765lmn');
                if( mapEmail_BrandProfile.containsKey( u.Username.removeEnd('.tempowalden')) ) {
                    mapEmail_BrandProfile.get( u.Username.removeEnd('.tempowalden')).ChatterFreeUserId__c = u.Id;
                    system.debug( '***** Heres the ChatterFreeUserId__c: ' +mapEmail_BrandProfile.get( u.Username.removeEnd('.tempowalden')).ChatterFreeUserId__c );
                    u.Tempo_Id__c = mapEmail_BrandProfile.get( u.Username.removeEnd('.tempowalden')).Tempo_Id__c;
                }
            }
            update mapEmail_BrandProfile.values();
            update newUserList;

            } catch (Exception ex) {
        ApexLogHandler.apexLog log;
        log = new apexLogHandler.apexLog('TempoProfileHelper','createChatterFreeAccount','issue creating ChatterFree user for '); 
        log.logException(ex); 
            if(log != null){
                log.saveLogs();
            }
            }
        }

    }

    /*******************************************************************
    Method to check if a brandprofile is already exist for the selected contact
    Related Task: T-324205
    ********************************************************************/
    public void validateTempoBrandProfileExistForTheSelectedContact(list<Brand_Profile__c> bProfileList, set<Id> contactIdSet){
        set<ID> setContactWithExistingTempoBPs = new set<ID>();
        for(Brand_Profile__c bp:[Select Id, Contact__c from Brand_Profile__c 
                                                            where RecordTypeId = :BrandProfilesTriggerHandler.tempoRecordType
                                                              and Contact__c IN :contactIdSet
                                                                and Id NOT IN :bProfileList ]) {
            setContactWithExistingTempoBPs.add(bp.Contact__c);
        }
        for(Brand_Profile__c bp:bProfileList){
            if(setContactWithExistingTempoBPs.contains(bp.Contact__c)){
                // a brand profile is already exist for the selected contact
                bp.addError('A Tempo Brand Profile already exists for this Contact.');
            }
        }
    }

}