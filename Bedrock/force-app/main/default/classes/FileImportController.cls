/************************************************************************
Name  : FileImportController
Author: Dirk Koechner (Appirio)
Date  : April, 2015
Description: 	Single click file import tool.   Can be embedded in any VF page or linked to custom button/link.
				File format expected: text with delimiter (tab, comma, etc.)
				Default mapping: File name defines object, column headers define fields.
				Compound " .. " fields supported.

Revision History 
Horacio Sanchez - 03/19/2021 - S-38952: Tempo: Fix Loan Disbursement Apex CPU time Exceed Error
*************************************************************************/

public with sharing class FileImportController {
    
    public String processStatus {get;set;}
    public Boolean isPollingEnabled {get;set;}
    public Id jobId;
    
    public FileImportController() {
        processStatus = '';
        isPollingEnabled = false;
    }

  static final String fileDelimiter = '\t';		// File delimiter set to tab, change this as needed

  public Attachment attachment {				// attachment not required, defined here for demo purposes
  get {
      if (attachment == null)
        attachment = new Attachment();
      return attachment;
    }
  set;
  }

  public PageReference upload() {

	List<List<String>> csvOutput;
	Schema.SObjectType sObjType;
	Map<String, Schema.SObjectField> mapObjFields;
	List<SObject> listsObject;
    String sObjectName = '';

    try {

	  	// Option 1: set object name based on file name
		system.debug('attachment.name:'+attachment.name);
	    List<String> filename = new List<String>();
	    filename = attachment.Name.split('[.]');
	    sObjectName = filename[0].trim();
		system.debug('sObjectName:' + sObjectName);

		// Option 2: hard code object name, define as needed
	    //String sObjectName = 'Student_Loan_Disbursement__c';

		csvOutput = parseCSV( (String) attachment.body.toString() );

		System.debug('Number of Rows in File:' + csvOutput.size());

	    if (csvOutput.size() > 10000) {
	    	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error importing file. Row limit exceeds 10,000 rows. Break into smaller files.'));
      		return null;
	    }
	    else if (csvOutput.size() < 2) {
	    	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error importing file. No rows to insert. First row must be field names.'));
      		return null;
	    }

		sObjType = Schema.getGlobalDescribe().get(sObjectName);
        system.debug('Schema.getGlobalDescribe().size():'+Schema.getGlobalDescribe().size());		
		if(sObjType == null) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error importing file. Can not identify Object: '+sObjectName));
      		return null;
		}
		mapObjFields = sObjType.getDescribe().fields.getMap();

		listsObject = new List<SObject>();

    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error importing file. Incorrect file name or format. ' + e.getMessage()));
      return null;
    }

	integer fieldpos;
	integer rowpos;
    try {

	    rowpos = 0;
	    for( List<String> listRow : csvOutput) {
	    	if (rowpos > 0) {
		    	system.debug('listrow:'+listrow);
				Sobject importObject = sObjType.newSobject();

		    	fieldpos = 0;
		    	for ( String field : listRow) {
		    		// Dynamically populate sObject fieldname, value
		    		String fieldType = String.valueOf(mapObjFields.get(csvOutput[0][fieldpos]).getDescribe().getType());

		    		system.debug('Processing Column:' + csvOutput[0][fieldpos] + '  Type:' + fieldType +'   Value:' + field );

		    		// Note: not all types included, expand as needed
		    		if (fieldType == 'String' || fieldType == 'TextArea' || fieldType == 'Phone' || fieldType == 'Picklist' )
		    			importObject.put(csvOutput[0][fieldpos], (String) field );
		    		else if (fieldType == 'Decimal' || fieldTYpe == 'Double' || fieldType == 'Currency')
		    			importObject.put(csvOutput[0][fieldpos], Decimal.valueOf(field) );
		    		else if (fieldType == 'Integer')
		    			importObject.put(csvOutput[0][fieldpos], Integer.valueOf(field) );		    			
		    		else if (fieldType == 'Boolean')
		    			importObject.put(csvOutput[0][fieldpos], Boolean.valueOf(field) );			    			
		    		else if (fieldType == 'Date')
		    			importObject.put(csvOutput[0][fieldpos], Date.valueOf(field) );	
				    else {
				    	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error importing file. Undefined field data type:'+fieldType));
			      		return null;
				    }

		    		fieldpos++;
		    	}
		    	listsObject.add(importObject);
	    	}
	    	rowpos++;
	    }
        
        if (sObjectName == 'Student_Loan_Disbursement__c') {
            jobId = Database.executeBatch(new BatchManageLoanDisbursementFile(listsObject), 10);
            processStatus = 'Processing file...';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, (csvOutput.size() - 1) +' records uploaded. Processing file...'));
            isPollingEnabled = true;
        } else {
         	insert listsObject;   
        }	    

	    // OPTIONAL FUNCTIONALITY: insert import file as an (archival) attachment
	    //attachment.OwnerId = UserInfo.getUserId();
	    //attachment.ParentId = 'a0M17000000HNEw'; // the record the file should attached to
	    //attachment.IsPrivate = true;
	    //insert attachment;

    } catch (Exception e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error importing file. Incorrect file column header or data field. Column:'+(fieldpos+1)+' Row:'+rowpos+'.  '+ e.getMessage()));
      return null;
    }

      if (sObjectName != 'Student_Loan_Disbursement__c') {
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'File imported successfully. '+ (csvOutput.size() - 1) +' records uploaded.'));
      }
    return null;
}

// parse CSV file, return list of lists of strings
//  - treat all content inside quotes (" , tab , etc ") as a single token

public static List<List<String>> parseCSV(String contents) {
	    List<List<String>> allFields = new List<List<String>>();
	 
	    List<String> lines = new List<String>();
	    try {
	        lines = contents.split('\n');
	    } catch (System.ListException e) {
	        System.debug('Limits exceeded?' + e.getMessage());
	        return allFields;
	    }
	    Integer num = 0;
	    for(String line : lines) {

	        line = line.replaceAll('\r','').replaceAll('\n','').trim();

	        system.debug('Loading row:'+line);

	        // Option: set token blow to file delimiter (comma, tab, etc.)
	        List<String> fields = line.split(fileDelimiter);   
	        List<String> listFieldRow = new List<String>();
	        String compositeField = '';
	        
	        for(String field : fields) {
	        	//system.debug('Processing current field >' + field + '<');
				if (field.endsWith('"')) {
					//listFieldRow.add( 'COl HAD END QUOTE' );
					compositeField += field;
					listFieldRow.add(compositeField);
					compositeField = '';
				}
				else if ( field.startsWith('"') || compositeField != '') {
					//listFieldRow.add( 'COl HAD START QUOTE' );
					compositeField += field;
				}
				else
					listFieldRow.add(field);
	        }

	        allFields.add(listFieldRow);
	    }

	    return allFields;
	}
    
    public void jobWatch() {
        AsyncApexJob batchJob;
        if (jobId != null) {
            batchJob = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: jobId ];
            if (batchJob != null) {
                if (batchJob.TotalJobItems > 0) {
                    System.debug('Update progress: '+(batchJob.JobItemsProcessed/batchJob.TotalJobItems)*100+'% completed');
                }
                if (batchJob.JobItemsProcessed == batchJob.TotalJobItems) {
                    processStatus = 'Processing completed.';
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Processing completed.'));
                    isPollingEnabled = false;                
                } else {
                    String summary = '';
                    if (ApexPages.hasMessages()) {
                        ApexPages.addMessage(ApexPages.getMessages().get(0));
                    } else {
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Processing... '));
                    }
                }
            }
        }
    }
}