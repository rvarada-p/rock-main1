/************************************************************************
Name  : CreateSubscriptionTermController
Author: Vinod (Appirio)
Date  : October 10, 2014
Description: Controller  class VFpage  Create Subscription Term
Name: Sarah Khalid - Laureate
Date: June 14, 2016
Description: Made changes to handle Program hierarchy

* Revision History
* Horacio Sanchez	-	Aug 12, 2021	-	User Story 58882: L2: Trigger Automatic Email invoice when Student Subscription is Manually created
* Horacio Sanchez   -   Jan 28, 2022    -   User Story 78073: L2: Pricebook: Update manual subscription creation process
*************************************************************************/
public with sharing class CreateSubscriptionTermController {
  	private Id studentProgramId;
  	public Student_Program__c studentProgram                            {get;set;}
  	public Student_Subscription__c newStudentSubscription               {get;set;}
  	public list<SelectOption> optionTermPriceBook                       {get;set;}
  	public string selectedPriceBookID                                   {get;set;}
  	public boolean isMoreThenOnePriceBook                               {get;set;}
  	public boolean isStudentSubscriptionExisting                        {get;set;}
  	public boolean preventSave                                          {get;set;}
  	public list<Student_Subscription__c> lstExistingStudentSubscription {get;set;}
  	public ID programId 											  	{get;set;}
    public String selectedPricebook										{get;set;}
    public List<SelectOption> priceBookSelectOptionList                 {get;set;}
  
  	public CreateSubscriptionTermController(ApexPages.StandardController controller) {
    	studentProgramId = controller.getId();
		studentProgram = [SELECT ID, Application__c, Program__r.Name, Program__c, Parent_Program__c, Open_Bursar_Hold__c, Open_BK_Hold__c, Open_C2_Hold__c, 
                                 Application__r.Primary_Program__c,Application__r.Initial_Price_Book__c,Name, Program_Start_Date__r.Start_Date__c,
                                 Number_of_Enrolled_Terms__c 
                          FROM Student_Program__c 
                          WHERE id=:studentProgramId];
    	if (studentProgram.Parent_Program__c != null)
      		programId = studentProgram.Parent_Program__c;
    	else
      		programId = studentProgram.Program__c;

    	newStudentSubscription = new Student_Subscription__c();
    	newStudentSubscription.Student_Program__c = studentProgram.id;
    	isMoreThenOnePriceBook = false;
    	isStudentSubscriptionExisting = false;
    	preventSave = true;
    	lstExistingStudentSubscription = new list<Student_Subscription__c>();
    	getDetail();
  	}

  	private void getDetail() {
    	optionTermPriceBook = new list<SelectOption>();
        priceBookSelectOptionList = new List<SelectOption>();
    	List<PricebookEntry> selectedPricebookEntry = new List<PricebookEntry>();
        List<PricebookEntry> inactivePricebookEntries = new List<PricebookEntry>();
        
        if (studentProgram.Application__r.Primary_Program__c != null) {            
            for (PricebookEntry pbEnter : [SELECT Product2Id, Name, Id, Pricebook2.Name, Pricebook2Id 
                                           FROM PricebookEntry 
                                           WHERE Product2Id =: programId
                                           AND Available_for_Existing_Students__c = true
                                           AND IsActive = false
                                           ORDER BY Pricebook2.Name DESC]) {
                                               inactivePricebookEntries.add(pbEnter);                                               
            }
	    }
    
    	if (studentProgram.Number_of_Enrolled_Terms__c == 0) {
      		if(studentProgram.Application__c != null) {
        		newStudentSubscription.Start_Date__c = studentProgram.Program_Start_Date__r.Start_Date__c;             
		
	        	if (studentProgram.Application__r.Primary_Program__c != null) {
	        		System.debug('Inital Price Book ::: ' + studentProgram.Application__r.Initial_Price_Book__c );
	        		System.debug('Product ::: ' + programId );
	
	          		for (PricebookEntry pbEnter : [SELECT Product2Id, Name, Id, Pricebook2.Name, Pricebook2Id 
                                                  FROM PricebookEntry 
                                                  WHERE Product2Id =: programId 
                                                  AND IsActive = true]) {
                        selectedPricebookEntry.add(pbEnter);
                        preventSave = false;
                    }
	        	}
      		}
      
            //  if only one is found then default the Term_Price_Book__c with the related Opp's Term_Price_Book__c
      		if (selectedPricebookEntry.size() == 1 ) {
                // Adding the Active priceBook to the beginning of the list
                for (PricebookEntry pbEntery:selectedPricebookEntry) {
                	priceBookSelectOptionList.add(new SelectOption(pbEntery.Pricebook2Id,pbEntery.Pricebook2.Name));
                }
                
                // Adding inactive priceBooks, with Available_for_Existing_Students__c flag equals to true, to the dropdown menu
                for (PricebookEntry pbEntry : inactivePricebookEntries) {
                    priceBookSelectOptionList.add(new SelectOption(pbEntry.Pricebook2Id,pbEntry.Pricebook2.Name));
                }
      		} else if (selectedPricebookEntry.size() > 1 ) {
                isMoreThenOnePriceBook = true;
                //if more than one is found the display each unique Term_Price_Book__c in a "dropdown list" and instruct the user to choose one 
                for (PricebookEntry pbEntery:selectedPricebookEntry) {
                	optionTermPriceBook.add(new SelectOption(pbEntery.Pricebook2Id,pbEntery.Pricebook2.Name));
                }
                for (PricebookEntry pbEntry : inactivePricebookEntries) {
                    optionTermPriceBook.add(new SelectOption(pbEntry.Pricebook2Id,pbEntry.Pricebook2.Name));
                }
      		} else {
                // add an error 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.No_CBL_Pricebooks_Available));
      		}
    
    	} else {

      		if (studentProgram.Application__c != null) {
        		//newStudentSubscription.Start_Date__c =    studentProgram.Program_Start_Date__r.Start_Date__c;        		
                if (studentProgram.Application__r.Primary_Program__c != null) {
                 	for (PricebookEntry pbEnter : [SELECT Product2Id, Name, Id, Pricebook2.Name, Pricebook2Id 
                                                  FROM PricebookEntry 
                                                  WHERE Product2Id =: programId 
                                                  AND IsActive = true]) {
                        selectedPricebookEntry.add(pbEnter);
                        preventSave = false;
                    }   
                }                 
      		}
            
        	if (selectedPricebookEntry.size() == 1 ) {
                // Adding the Active priceBook to the beginning of the list
                for (PricebookEntry pbEntery:selectedPricebookEntry) {
                	priceBookSelectOptionList.add(new SelectOption(pbEntery.Pricebook2Id,pbEntery.Pricebook2.Name));                          
                }
                
                // Adding inactive priceBooks, with Available_for_Existing_Students__c flag equals to true, to the dropdown menu
                for (PricebookEntry pbEntry : inactivePricebookEntries) {
                    priceBookSelectOptionList.add(new SelectOption(pbEntry.Pricebook2Id,pbEntry.Pricebook2.Name));
                }
      		} else if (selectedPricebookEntry.size() > 1 ) {
        		isMoreThenOnePriceBook = true;
        		//if more than one is found the display each unique Term_Price_Book__c in a "dropdown list" and instruct the user to choose one 
        		for (PricebookEntry pbEntery:selectedPricebookEntry) {
            		optionTermPriceBook.add(new SelectOption(pbEntery.Pricebook2Id,pbEntery.Pricebook2.Name));                          
        		}
                for (PricebookEntry pbEntry : inactivePricebookEntries) {
                    optionTermPriceBook.add(new SelectOption(pbEntry.Pricebook2Id,pbEntry.Pricebook2.Name));
                }
      		} else {
        		// add an error
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.No_CBL_Pricebooks_Available));
      		}
			if(studentProgram.Open_Bursar_Hold__c > 0) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.CBL_Open_Bursar_Hold));
				preventSave = true;
			}
        
            if(studentProgram.Open_BK_Hold__c > 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.CBL_Open_BK_Hold));
                preventSave = true;
            }
        
            if(studentProgram.Open_C2_Hold__c > 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.CBL_Open_C2_Hold));
                preventSave = true;
            }
	
    	} 

    	// get already existing 
    	lstExistingStudentSubscription =[SELECT Term_Price_Book__r.Name, Term_Price_Book__c, Subscription_Status__c, Start_Date__c, Name, Id, Subscription_Price__c, End_Date__c 
                                         FROM Student_Subscription__c 
                                         WHERE Student_Program__c =:studentProgramId 
                                         ORDER BY End_Date__c DESC];   
    	if (lstExistingStudentSubscription != null && lstExistingStudentSubscription.size() > 0) {
        	isStudentSubscriptionExisting = true;
    	}
  
	}

  	public pageReference save() {
        if (preventSave) {
            return new pageReference('/'+studentProgramId);
        }
    	pageReference pg = null;
        if (selectedPriceBook == null || selectedPriceBookID == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select Term Price Book'));
        }
        if (selectedPriceBook != null) {
            newStudentSubscription.Term_Price_Book__c = selectedPriceBook;
        }
        if (selectedPriceBookID != null) {
            newStudentSubscription.Term_Price_Book__c = selectedPriceBookID;
        }
        try {
            newStudentSubscription.Is_Created_Manually__c = true;
            insert newStudentSubscription;
            pg = new pageReference('/'+studentProgramId);
        } catch(exception ex) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));            
        }
    	return pg;
  	}

  	public pageReference cancel() {
    	return  new pageReference('/'+studentProgramId);
  	}

}