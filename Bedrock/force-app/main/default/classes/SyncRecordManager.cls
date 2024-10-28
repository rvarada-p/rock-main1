public with sharing class SyncRecordManager {

/***************************************************************************
 Name 		: SyncRecordManager 
 Created By : Kartik Viswanadha
 Description  : The main class to perform the Sync between two objects based on Mapping Configuration
 Operations:  : 
 	   This Class mainly depends on the two Custom Objects - Object Map and Field Map.
	   
	   The fields can / shall be set by methods but make sure before calling any methods from this class  
	   1. objectName - The name of object on which the Trigger / operation is written	
	   2. hasAlreadyRanSync  - this boolean flag puts breaks in the recursion that might happen
	   3. isInsert - This is the variable that can be used in case of Trigger Insert Syncs. This will work if you are trying to insert both Parent & Child at Same time, or Child with a Parent that has sync rule.

	   The Methods are 

	   1. doSync(List<SObject> sourceRecords) - The core logic resides in this method. call this from anywhere by sending list of Sobject records you want to sync and it will take care of the rest. 
	   2. getMappings() 					  - The sync mappings are returned. 
	   3. buildRecordTypeMap(String sourceRecordTypeString, String targetRecordTypeString) - Build the Record Type map for Source and Targets. Generally because of the nature of how Record Type maps are stored, its many to many. 
	   4. returnSOQLforTargetRecords(String targetObj,List<SObject> sourceRecords, String whrIds, String whrFld) - Returns the SOQL query to gather the target records based on Source Record's Id. 

****ASSUMPTION****

You might notice that there is SOQL inside of for loop (Line 112), that for loop is basically for mapping records. Assume you have multiple mappings for Account object, the for loop is for that 

Assuming you will not have more than 100 Mapping for a given Single Object at any point of time. we will be good.  

I wouldnt consider this as limitation, but an assumption

****************************************************************************/
	
	// Public static variable set from Trigger Contexts	
	public static boolean hasAlreadyRanSync = false;
	public static String objectName;
	public static boolean isInsert = false;

	// Private variables
	private List<Object_Map__c> omappers;
	private boolean m_isExecuting = false;
	private integer batchSize 	  = 0;

	public SyncRecordManager(Boolean isExecuting, Integer size){
		m_isExecuting = isExecuting;
		batchSize     = size;
	}

	// This method will generate the mappings for an object.
	
	public void getMappings(){
		
			String whrClause;		
			omappers 			= new List<Object_Map__c>(); 			
			
			// Generate SOQL and get all object maps.		
			String soql = 'SELECT Include_Inserts__c, Parent_Sync__c, Source_Record_Types__c, Target_Record_Types__c, Source_Object__c, Target_Object__c, Related_to_Source__c, Child_Relationship_Name__c, Two_way_Sync__c, (SELECT Source_Field__c, Target_Field__c, isReferenceField__c from Field_Mappings__r) from Object_Map__c ';
			
			whrClause = 'WHERE Source_Object__c = ' + '\'' +String.escapeSingleQuotes(objectName) + '\'';
			
			whrClause += ' OR Target_Object__c = ' + '\'' +String.escapeSingleQuotes(objectName) + '\'';
			
			omappers = Database.query(soql + whrClause); // Get the Object Map
			
	}


	// This is the main method that is called from any context for updating mapping records. 

	public void doSync(List<SObject> sourceRecords) {
		
		// Set the hasAlreadyRanSync to true

		hasAlreadyRanSync = true; // Avoids the recursion.

		if(sourceRecords == null || sourceRecords.size() == 0){
			throw new SyncException('No Source Records Provided');
		}

		objectName = sourceRecords[0].Id.getSObjectType().getDescribe().getLocalName(); // Get the object name

		List<SObject> targetRecords 			  				 = new List<SObject>();
		Map<Id,List<SObject>> objectMapTargets    				 = new Map<Id,List<SObject>>();
		Map<Id,SObject> updatedMap				  				 = new Map<Id,SObject>();
		Map<String,Map<String,Set<String>>> objrecordTypeMap     = new Map<String,Map<String,Set<String>>>();

		// Get the Sync Mappings.
		getMappings();	
		
		// Iterate over each mappings found, ideally only one mapping as per requirement, but you can always have more than one mapping for every object Type and we will iterate over each mapping record and process it. 
		for(Object_Map__c om : omappers){

			if(!isInsert || (isInsert && om.Include_Inserts__c)){

				Map<String,Set<String>> recordTypeMap = new Map<String,Set<String>>();

				String soql = '';
				
				// This in case of Object is a Source Object as listed in Mapping Record.
				if(objectName == om.Source_Object__c){
					
					soql = returnSOQLforTargetRecords(om.Target_Object__c,sourceRecords,'Id',om.Related_to_Source__c); // Get the SOQL

					if(om.Source_Record_Types__c != null){
						
						recordTypeMap = buildRecordTypeMap(om.Source_Record_Types__c,om.Target_Record_Types__c); // Build Record Type Map
						
					}

					objrecordTypeMap.put(om.Id,recordTypeMap);

					
				}else if(objectName == om.Target_Object__c && om.Two_way_Sync__c){ // Do the reverse for Target Object, if 2 way sync is turned on.

					
					soql = returnSOQLforTargetRecords(om.Source_Object__c,sourceRecords,om.Related_to_Source__c,'Id');

					if(om.Target_Record_Types__c != null){
						
						recordTypeMap = buildRecordTypeMap(om.Target_Record_Types__c,om.Source_Record_Types__c);
					}

					objrecordTypeMap.put(om.Id,recordTypeMap);


				}

				List<SObject> temp = new List<SObject>();

				soql = soql.remove('ConnectionReceivedId,');
				soql = soql.remove('ConnectionSentId,');
				soql = soql.remove('ConnectionSentDate,');
				soql = soql.remove('ConnectionReceivedDate,');
				soql = soql.remove('Comments,');
				soql = soql.remove('ConnectionReceivedId');
				soql = soql.remove('ConnectionSentId');
				soql = soql.remove('ConnectionSentDate');
				soql = soql.remove('ConnectionReceivedDate');
				soql = soql.remove('Comments');

				soql = soql.replace(', from',' from');

				system.debug('theSOQL:'+ soql);
				
				temp = Database.query(soql);	

				objectMapTargets.put(om.Id,temp); // Get the target Records that need to be updated. It can be one or many, one SOQL per 1 Mapping. So be careful with number of mapping you have. 

			}
		}

			// Iterate over the Object Mappers again. This time to perform the update.

		for(Object_Map__c om : omappers){
			if(!isInsert || (isInsert && om.Include_Inserts__c)){

				Map<String,Set<String>> recordTypeMap = new Map<String,Set<String>>();
				recordTypeMap = objrecordTypeMap.get(om.Id);

				for(Sobject src : sourceRecords){ // This is required as there can be many records
					for(SObject target : objectMapTargets.get(om.Id)){
						
						Boolean isRelated = false;
						Boolean skipFor = checkRecordTypes(src,target,recordTypeMap); // This will map the record types correctly.
						
						// This will get the records that are related to the Source Record, either Using Id or Related To Ids (Both ways will work)
						if(objectName == om.Source_Object__c){
							if(String.valueOf(src.get('Id')) == String.valueOf(target.get(om.Related_to_Source__c)))
								isRelated = true;
						}else{
							if(String.valueof(src.get(om.Related_to_Source__c)) == String.valueOf(target.get('Id')))
								isRelated = true;
						}
						if(!skipFor && isRelated){
							for(Field_Mapping__c fm : om.Field_Mappings__r){
								if(objectName == om.Source_Object__c)
									target.put(fm.Target_Field__c,src.get(fm.Source_Field__c)); // Update the target Object records
								else
									target.put(fm.Source_Field__c,src.get(fm.Target_Field__c)); // Update the target Object records
							}
							updatedMap.put(target.Id,target); // Build the map with updated values. 
						}
					}
				}
			}
		}

		update updatedMap.values();

	}

	// Build the Record Type Map based on the Source Record Types and Target Record Types. 
	/*
		Since both are string separated by ; I am doing a many to many. 
	*/
	private Map<String,Set<String>> buildRecordTypeMap(String sourceRecordTypeString, String targetRecordTypeString){

		Map<String,Set<String>> recordTypeMap = new Map<String,Set<String>>();

		for(String s : sourceRecordTypeString.split(';')){
			s = s.trim();			
			Set<String> targetRecordTypes;
			
			if(recordTypeMap.get(s) != null)	{
				targetRecordTypes = recordTypeMap.get(s);
			}else{
				targetRecordTypes = new Set<String>();
			}

			if(targetRecordTypeString != null)
				targetRecordTypes.addAll(targetRecordTypeString.split(';'));
				
			recordTypeMap.put(s,targetRecordTypes);
		}

		return recordTypeMap;

	}

	// Build the SOQL dynamically to pull the target records for the Source Records. 

	private String returnSOQLforTargetRecords(String targetObj,List<SObject> sourceRecords, String whrIds, String whrFld){
		
		String soql = '';

		soql = 'Select ' + SyncRecordManager.returnAllfields(targetObj) + ' from ' + targetObj;
				
		String whrClause = '';
		
		for(SObject s : sourceRecords){
			whrClause += '\'' + String.escapeSingleQuotes(String.valueOf(s.get(whrIds))) + '\'' + ','; 
		}
		
		whrClause = '(' + whrClause.removeEnd(',') + ')';

		soql += ' Where ' + whrFld + ' IN ' + whrClause;

		return soql;
	}

	// Check to see if the Record Types are mapped correctly .

	private  boolean checkRecordTypes(SObject src, SObject target, Map<String,Set<String>> recordTypeMap){
		if(recordTypeMap.values().size() == 0) // Check if mapping exist)
			return false;
		
		try {	
			if(src.get('RecordTypeId') == null) // Mapping exists and record is not having a Record Type,
				return true;
			if(recordTypeMap.containsKey(String.valueof(src.get('RecordTypeId')))){
				Set<String> targetRTs = recordTypeMap.get(String.valueof(src.get('RecordTypeId')));
				if(targetRTs.size() == 0)
					return false; // If source record type is mapped to nothing
				if(target.get('RecordTypeId') == null)
					return false;
				else if(targetRTs.contains(String.valueof(target.get('RecordTypeId'))))
					return false;
				else
					return true;			
			}
		
		}catch(SObjectException e){ // In case Record Type doesnt exist, skip should never happen if using mapping process
			return false;
		}

		return false;	
				

	}

	// Simple utility method to return all fields in an object as CSV String

	public static String returnAllFields(String objName){
	   
		String fieldsCSV = '';
		
		for(Schema.SObjectField f: Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().values()){
		        	
		        	DescribeFieldResult fr = f.getDescribe();
		        	
		        	if(fr.isAccessible())
		        	  fieldsCSV += fr.getLocalName() + ',';
		        }
		
	
		fieldsCSV = fieldscsv.removeEnd(',');
	
		return fieldsCSV;
	
	}

	public class SyncException extends Exception {}

}