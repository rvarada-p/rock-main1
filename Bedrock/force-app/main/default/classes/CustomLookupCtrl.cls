public with sharing class CustomLookupCtrl {
	public String fieldName {get;set;}   
    public String objName {get;set;}
    public String selectedId {get;set;}
    public SObject currentRecord{get;set;}
    public String selectedRecordName {get;set;}
    public String fieldPopulatingId {get;set;}
    public String fieldSetNameAPI {get;set;}
                  
    public CustomLookupCtrl(){
    	fieldName = '';
    	objName = '';
    	currentRecord = null;
    }
     
    public PageReference getSelectedRecord(){
    	system.debug('selectedId::::::::::::'+selectedId);	
    	if(selectedId != null && selectedId != ''){    
    		string[] allSelectedIds = this.selectedId.split(',');                 
    		string currentRecordId = allSelectedIds[0];    
    		 system.debug('currentRecordId::::::::::::'+currentRecordId);	
    		if(currentRecordId <> null){
		    	List<Sobject> sobjectList = Database.query('SELECT Id, ' + this.fieldName + ' FROM ' + this.objName + ' WHERE ID = : currentRecordId');
		    	system.debug('sobjectList::::::::::::'+sobjectList);
		    	if(!sobjectList.isEmpty()){
		    		this.currentRecord = sobjectList[0];
		    		selectedRecordName = (String) sobjectList[0].get('Name');
		    	}
    		}
    	}
    	system.debug('selectedRecordName::::::::::::'+selectedRecordName);
    	return null;
    }   
}