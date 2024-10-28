/************************************************************************
Name  : SubscriptionAutoCreator
Author: Originally "BatchAutoSubscriptionCreationHelper" by Vinod (Appirio)
Date  : October 14, 2014
Author: Refactored by Tom (Appirio)
Date  : May 11, 2014
Author: Sarah Khalid - Laureate
Date: April 6, 2016
Modification: Added in logic for handling discounts/exemptions
Description: worker class for batch class BatchAutoSubscriptionCreation
Test class: SubscriptionAutoCreator_Test
Date: Jun 14, 2016
Author: Sarah Khalid - Laureate
Modification: Added in logic for handing parent/child relationsip for Programs


Revision History 
Ravitej Varada - 02/04/2022 - S-78405  L2: Pricebook: Update Auto Batch 
Ravitej Varada - 02/22/2022 - I-426248   L2: Pricebook: Update Auto Batch Defect 
*************************************************************************/
public with sharing class SubscriptionAutoCreator {
    
    public  integer totalNumberOfSuccess;
    public  integer totalNumberOfFailure;
    
    public  SubscriptionAutoCreator(){  
    }
    
    public  void createSubscription(list<Student_Program__c> lstStudentProgram){
        totalNumberOfSuccess = 0;
        totalNumberOfFailure = 0;
        list<Student_Program__c> lstStudentProgramForApexLoger = new list<Student_Program__c>();
        list<Student_Subscription__c> lstStudentSubscription = new list<Student_Subscription__c>();   
        apexLogHandler.apexLog log;
        try{
        // get next  Student Subscription for the selected student program
        //(meaning where Student Subscription.Start_Date__c equals TODAY())
        Date toDay = Date.today();
        set<ID> setProgramId = new set<ID>(); 
        set<ID> setCurrentSubScriptionId = new set<ID>();
        set<ID> setCurrentSubScriptionTermPriceBookId = new set<ID>();
        //Set of student program id's
        set<ID> setStudentProgramId = new set<ID>(); 
        
        //Custom Settings to retrive Sub_Price_Book_Rule__c     
        List<Sub_Price_Book_Rule__c> priceBookRules = Sub_Price_Book_Rule__c.getall().values();
        
        for(Student_Program__c sProg:lstStudentProgram){ 
            setStudentProgramId.add(sProg.Id);
            if(sProg.Program__c != null){  
                if(sProg.Parent_Program__c!=null) {
                    setProgramId.add(sProg.Parent_Program__c);
                }
                else {
                    setProgramId.add(sProg.Program__c);
                }
            }
            if(sProg.Current_Student_Subscription__c != null){
                setCurrentSubScriptionId.add(sProg.Current_Student_Subscription__c);
            }
            if(sProg.Current_Student_Subscription__r.Term_Price_Book__c != null){
                setCurrentSubScriptionTermPriceBookId.add(sProg.Current_Student_Subscription__r.Term_Price_Book__c);
            }
            
        }
        
        //list<PricebookEntry> latestPricebookEntryList = new list<PricebookEntry>();
        
        //latestPricebookEntryList= [Select Product2Id, Pricebook2Id,name, Id,UnitPrice, Available_for_Existing_Students__c,IsActive From PricebookEntry  where Product2.id In: setProgramId and IsActive= true order by CreatedDate desc];
        
        
        
        
        
        
        
        System.debug('Program IDs: ' + setProgramId);
        System.debug('Current Subscription IDs: ' + setCurrentSubScriptionId);
        System.debug('Current Subscription Pricebook IDs: ' + setCurrentSubScriptionTermPriceBookId);
        
        map<ID,list<Student_Subscription__c>> mapStudentProgramWithStudentSubscription = new map<ID,list<Student_Subscription__c>>();
        for(Student_Subscription__c stuSub:[Select ID,Start_Date__c,Student_Program__c
                                            from Student_Subscription__c 
                                            where Student_Program__c in: lstStudentProgram
                                            and id not in: setCurrentSubScriptionId]){
                                                if(!mapStudentProgramWithStudentSubscription.containsKey(stuSub.Student_Program__c)){
                                                    mapStudentProgramWithStudentSubscription.put(stuSub.Student_Program__c,new list<Student_Subscription__c>());
                                                }
                                                mapStudentProgramWithStudentSubscription.get(stuSub.Student_Program__c).add(stuSub);
                                            }
        
        map<ID,Student_Subscription__c> mapStudentProgramWithRelatedStudentSubscription = new map<ID,Student_Subscription__c>();
        for(Student_Program__c sProg:lstStudentProgram){
            if(mapStudentProgramWithStudentSubscription.containsKey(sProg.ID)){
                for(Student_Subscription__c stuSub: mapStudentProgramWithStudentSubscription.get(sProg.ID)){
                    if(stuSub.Start_Date__c > sProg.Current_Student_Subscription__r.End_Date__c){
                        mapStudentProgramWithRelatedStudentSubscription.put(sProg.ID,stuSub);
                        break;
                    }
                }
            }
        }
        System.debug('mapStudentProgramWithRelatedStudentSubscription :::: ' + mapStudentProgramWithRelatedStudentSubscription); 
        
        System.debug('Map SP with related Sub:: '  + mapStudentProgramWithRelatedStudentSubscription);
        
        // get most recent price book entery for the Student_Program__c.Program__c
        // get the price book entery
        
        
        
        
        
        map<ID,PricebookEntry> mapProgramWithMostRecentPricebookEntry = new map<ID,PricebookEntry>();
        for(PricebookEntry pEntery :[Select Product2Id, Pricebook2Id,name, Id,UnitPrice, Available_for_Existing_Students__c,IsActive 
                                     From PricebookEntry  
                                     where Product2.id In: setProgramId 
                                     and IsActive= true 
                                     order by CreatedDate desc]){
                                         if(!mapProgramWithMostRecentPricebookEntry.containsKey(pEntery.Product2Id)){
                                             // add only most recent pricebook entery
                                             mapProgramWithMostRecentPricebookEntry.put(pEntery.Product2Id,pEntery);
                                         }
                                     } 
        System.debug('Map Program with most recent price book entry: ' + mapProgramWithMostRecentPricebookEntry);
        
        // get the price book entery for Current SubScription 's TermPriceBook
        map<ID,list<PricebookEntry>> mapCurrentSubScriptionTermPriceBookWithPricebookEntry = new map<ID,list<PricebookEntry>>();
        for(PricebookEntry pEntery :[Select Product2Id, Pricebook2Id, Id, Available_for_Existing_Students__c 
                                     From PricebookEntry
                                     where Available_for_Existing_Students__c = true
                                     and Product2Id in: setProgramId
                                     and Pricebook2Id in:setCurrentSubScriptionTermPriceBookId]){
                                         
                                         if(!mapCurrentSubScriptionTermPriceBookWithPricebookEntry.containsKey(pEntery.Pricebook2Id)){
                                             mapCurrentSubScriptionTermPriceBookWithPricebookEntry.put(pEntery.Pricebook2Id,new list<PricebookEntry>());
                                         }
                                         mapCurrentSubScriptionTermPriceBookWithPricebookEntry.get(pEntery.Pricebook2Id).add(pEntery);        
                                         /*
if(!mapCurrentSubScriptionTermPriceBookWithPricebookEntry.containsKey(pEntery.Product2Id)){
mapCurrentSubScriptionTermPriceBookWithPricebookEntry.put(pEntery.Product2Id,new list<PricebookEntry>());
}
mapCurrentSubScriptionTermPriceBookWithPricebookEntry.get(pEntery.Product2Id).add(pEntery);
*/
                                     } 
        System.debug('Current Subscription Term price book with Price book entry : ' + mapCurrentSubScriptionTermPriceBookWithPricebookEntry);
        
        // check and store  If current Student_Subscription__r.Term_Price_Book__c's PricebookEntry for the "Program" is marked "Available_for_Existing_Students__c",
        map<ID,ID> mapProgramIDWithCurrentStudentSubscriptionTermPriceBookID = new map<ID,ID>();
        
        for(Student_Program__c sProg:lstStudentProgram){
            system.debug('sProg'+sProg.id);
            system.debug('sProg'+sProg.Program_Start_Date__r.Start_Date__c);
            system.debug('sProg'+sProg.id);
            system.debug('sProg'+sProg.id);
            if(!mapStudentProgramWithRelatedStudentSubscription.containsKey(sProg.ID)) {	
                //S-78405
                if(!priceBookRules.isEmpty()){
                    
                    
                    
                    for(Sub_Price_Book_Rule__c rule: priceBookRules){
                         if(sProg.Program_Start_Date__r.Start_Date__c  >= rule.From_Date__c && sProg.Program_Start_Date__r.Start_Date__c  <= rule.To_Date__c && rule.Get_Price_Book__c == 'Old'){
                             if(sProg.Current_Student_Subscription__r.Term_Price_Book__c != null && mapCurrentSubScriptionTermPriceBookWithPricebookEntry.containsKey(sProg.Current_Student_Subscription__r.Term_Price_Book__c)){
                                  for(PricebookEntry pEntery: mapCurrentSubScriptionTermPriceBookWithPricebookEntry.get(sProg.Current_Student_Subscription__r.Term_Price_Book__c)){
                                    //Old
                                     System.debug('Price book entry ' + pEntery + ' Program ' + pEntery.Product2Id + ' SP: ' + sProg);
                                    if(!(sProg.Leave_of_Absence_LOA_To__c!=null && sProg.Leave_of_Absence_LOA_To__c > sProg.Current_Student_Subscription__r.End_Date__c.addDays(1))) {            
                                        Date dtStartDaydate = sProg.Current_Student_Subscription__r.End_Date__c;
                                        dtStartDaydate = dtStartDaydate.addDays(1);
                                        Student_Subscription__c newStuSub = new Student_Subscription__c();
                                        newStuSub.Start_Date__c = dtStartDaydate;
                                        newStuSub.Student_Program__c = sProg.ID;
                                        newStuSub.Term_Price_Book__c = pEntery.Pricebook2Id;
                                         
                                        lstStudentSubscription.add(newStuSub);
                                        break;
                                    }  
                                } 
                            }
                        //I-426248    
                        }else if(sProg.Program_Start_Date__r.Start_Date__c  >= rule.From_Date__c && sProg.Program_Start_Date__r.Start_Date__c  <= rule.To_Date__c && rule.Get_Price_Book__c == 'New'){
                            //S-78405
                            //New
                            System.debug('Price book entry ' + mapProgramWithMostRecentPricebookEntry + ' Program ' + sProg.Parent_Program__c + ' SP: ' + sProg);
                             if(!(sProg.Leave_of_Absence_LOA_To__c!=null && sProg.Leave_of_Absence_LOA_To__c > sProg.Current_Student_Subscription__r.End_Date__c.addDays(1))) {            
                                Date dtStartDaydate = sProg.Current_Student_Subscription__r.End_Date__c;
                                dtStartDaydate = dtStartDaydate.addDays(1);
                                Student_Subscription__c newStuSub = new Student_Subscription__c();
                                newStuSub.Start_Date__c = dtStartDaydate;
                                newStuSub.Student_Program__c = sProg.ID;
                                newStuSub.Term_Price_Book__c = mapProgramWithMostRecentPricebookEntry.get(sProg.Parent_Program__c).Pricebook2Id;
                                 
                                lstStudentSubscription.add(newStuSub);
                                break;
                            }  
                        } 
                    }
                    
                    
                }else{
                    if(sProg.Current_Student_Subscription__r.Term_Price_Book__c != null && mapCurrentSubScriptionTermPriceBookWithPricebookEntry.containsKey(sProg.Current_Student_Subscription__r.Term_Price_Book__c)){
                        for(PricebookEntry pEntery: mapCurrentSubScriptionTermPriceBookWithPricebookEntry.get(sProg.Current_Student_Subscription__r.Term_Price_Book__c)){
                            //Old
                            System.debug('Price book entry ' + pEntery + ' Program ' + pEntery.Product2Id + ' SP: ' + sProg);
                            if(!(sProg.Leave_of_Absence_LOA_To__c!=null && sProg.Leave_of_Absence_LOA_To__c > sProg.Current_Student_Subscription__r.End_Date__c.addDays(1))) {            
                                Date dtStartDaydate = sProg.Current_Student_Subscription__r.End_Date__c;
                                dtStartDaydate = dtStartDaydate.addDays(1);
                                Student_Subscription__c newStuSub = new Student_Subscription__c();
                                newStuSub.Start_Date__c = dtStartDaydate;
                                newStuSub.Student_Program__c = sProg.ID;
                                newStuSub.Term_Price_Book__c = pEntery.Pricebook2Id;
                                lstStudentSubscription.add(newStuSub);   
                            }  
                        } 
                    }
                }  
                
            }
            
        }  
        
        
        
        
                /*
        System.debug('mapProgramIDWithCurrentStudentSubscriptionTermPriceBookID:: ' + mapProgramIDWithCurrentStudentSubscriptionTermPriceBookID);
        
        for(Student_Program__c sProgram: lstStudentProgram){
            //
            if(!mapStudentProgramWithRelatedStudentSubscription.containsKey(sProgram.ID)) {
                if(!(sProgram.Leave_of_Absence_LOA_To__c!=null && sProgram.Leave_of_Absence_LOA_To__c > sProgram.Current_Student_Subscription__r.End_Date__c.addDays(1))) {
                    
                    // related student subscription is not there
                    // create a new Student_Subscription__c record  
                    Date dtStartDaydate = sProgram.Current_Student_Subscription__r.End_Date__c;
                    dtStartDaydate = dtStartDaydate.addDays(1);
                    Student_Subscription__c newStuSub = new Student_Subscription__c();
                    newStuSub.Start_Date__c = dtStartDaydate;
                    newStuSub.Student_Program__c = sProgram.ID;
                    
                    if(mapProgramIDWithCurrentStudentSubscriptionTermPriceBookID.containsKey(sProgram.Parent_Program__c)){
                        System.debug('Using mapProgramIDWithCurrentStudentSubscriptionTermPriceBookID');
                        // create new student subscription          
                        newStuSub.Term_Price_Book__c = mapProgramIDWithCurrentStudentSubscriptionTermPriceBookID.get(sProgram.Parent_Program__c);
                        System.debug('Term Price books::: ' + mapProgramIDWithCurrentStudentSubscriptionTermPriceBookID.get(sProgram.Parent_Program__c) + ' Parent Program : ' + sProgram.Parent_Program__c);
                        
                        lstStudentSubscription.add(newStuSub);            
                    }else if(mapProgramWithMostRecentPricebookEntry.containsKey(sProgram.Parent_Program__c)){
                        System.debug('Using mapProgramWithMostRecentPricebookEntry');
                        newStuSub.Term_Price_Book__c = mapProgramWithMostRecentPricebookEntry.get(sProgram.Parent_Program__c).Pricebook2Id;
                        lstStudentSubscription.add(newStuSub);    
                        
                    }else{ 
                        // write apex logger          
                        lstStudentProgramForApexLoger.add(sProgram);
                    }
                }
            }
        }*/ 
         					
        System.debug('Student Subscriptions about to be inserted : ' + lstStudentSubscription);
        Set<Student_Subscription__c> setStudentSubscriptions = new Set<Student_Subscription__c>();
        setStudentSubscriptions.addall(lstStudentSubscription);
        list<Student_Subscription__c> lstStudentSubsToInsert = new list<Student_Subscription__c> ();
        lstStudentSubsToInsert.addAll(setStudentSubscriptions);
        
        // insert all the records
        map<ID,ID> mapStudentProgramNewStudentSubscriptionID = new map<ID,ID>();
        if(!lstStudentSubsToInsert.isEmpty()){
            Database.Saveresult[] saveResult = Database.insert(lstStudentSubsToInsert,false); 
            
            // Iterate through each returned result
            integer index = 0;
            for (Database.SaveResult sr : saveResult) {
                if (sr.isSuccess()) {
                    // Operation was successful
                    // get newly create student sub to polulate studentprogram
                    Student_Subscription__c stuSub = lstStudentSubscription[index];
                    mapStudentProgramNewStudentSubscriptionID.put(stuSub.Student_Program__c,stuSub.id);
                    totalNumberOfSuccess++;
                } 
                else {
                    // Operation failed, so get all errors  
                    string strMessage = '';
                    for(Database.Error err : sr.getErrors()) {
                        strMessage+=  err.getMessage(); 
                    }
                    system.debug('strMessage::::::::::::::::::::::::::;'+strMessage);              
                    totalNumberOfFailure++;
                }
                index++;
            }
            system.debug('totalNumberOfSuccess:::::::::::::'+totalNumberOfSuccess);
            system.debug('totalNumberOfFailure:::::::::::::'+totalNumberOfFailure);       
            // create apex loger for the misssed student program        
            for(Student_Program__c sProg: lstStudentProgramForApexLoger){
                string strMessage = 'The Auto-Renewal was missed for Student Program: ' + sProg.Name;
                strMessage +='. However it was determined that a new Subscription record should still be generated and it has. Please review the Student Program and take any corrective steps if necessary.';
                log = new apexLogHandler.apexLog('BatchAutoSubscriptionCreationHelper','createSubscription', strMessage); 
            }
        }      
    }
    catch(exception ex){
        log = new apexLogHandler.apexLog('BatchAutoSubscriptionCreationHelper','createSubscription', ex.getMessage());
    } 
    finally{
        if(log != null){
            log.saveLogs();
        }
    }
}


}