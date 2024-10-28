public with sharing class ObjectMapTriggerHandler {

/***************************************************************************
 Name 		: ObjectMapTriggerHandler 
 Created By : Kartik Viswanadha
 Description  : Handler class for Object Map and Field Map Trigger

 	  
****ASSUMPTION****

You might notice that there is SOQL inside of for loop (Line 49), that for loop is basically for mapping records. Assume you have multiple mappings for Account object, the for loop is for that 

Assuming you will not have more than 100 Mapping for a given Single Object at any point of time. we will be good.  

I wouldnt consider this as limitation, but an assumption

****************************************************************************/
	
	private boolean m_isExecuting = false;
	private integer batchSize 	  = 0;

	public ObjectMapTriggerHandler(Boolean isExecuting, Integer size){
		m_isExecuting = isExecuting;
		batchSize     = size;
	}

	// This method is called if a Field Map is updated
	public void fieldMapUpdate(List<Field_Mapping__c> fMappings){
		
		Set<Id> objectMapIds = new Set<Id>();

		for(Field_Mapping__c fm : fMappings){
			objectMapIds.add(fm.Object_Mapping__c);
		}

		if(objectMapIds.size()>0)
			ObjectMapTriggerHandler.onAfterUpdate(objectMapIds);

	}

	// This method is called from Object Map trigger if the Rollup count goes up/down or from Field map if any mapping is updated.
	@future
	public static void onAfterUpdate(Set<Id> mappingIds){
		
		for(Object_Map__c om : [Select Id, Source_Object__c, Source_Record_Types__c from Object_Map__c where ID in :mappingIds]){
			List<SObject> sourceRecords = new List<SObject>();
			
			String soql = 'Select ' + SyncRecordManager.returnAllFields(om.Source_Object__c) + ' from ' + om.Source_Object__c;
			String whrClause = '';

			if(soql.contains('RecordTypeId')){ // Identify if record types are enabled{
				if(om.Source_Record_Types__c != null && om.Source_Record_Types__c != ''){
					for(String s : om.Source_Record_Types__c.split(';')){
						whrClause += '\'' + s.trim() + '\',' ;
					}
					whrClause = whrClause.removeEnd(',');
					soql += ' where RecordTypeId IN (' + whrClause + ')';
				}
			}

			sourceRecords = Database.query(soql);
			SyncRecordManager manager = new SyncRecordManager(false,1);
			SyncRecordManager.isInsert = false;
			manager.doSync(sourceRecords); // This will call the sync method.

		}

	}
}