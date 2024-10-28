/***************************************************************************
 Name 		: MapperExt 
 Created By : Kartik Viswanadha
 Description  : Extension class for Mapper Visualforce Page
 Visualforce Page:  Mapper  
 	   This Class will user to create mapping between to objects to Sync. This is very important to make sure that there are no issues during sync.
	  
	   Operations:

	   1. Displays the Source Object, and based on Source will show the target Records, (Relationship names)
	   2. Auto Match features, will check the field labels to do the Auto Match
	   3. Provides ability to do Two Way Sync, Sync on Inserts.
	   4. Record Types can be mapped by Selections. 
	   5. Displays warnings, if Source and Target Mapping is already present. 
	   6. Displays warnings, if Data Type of Source and Target Fields doesnt match.  

****************************************************************************/

public with sharing class MapperExt {
	

    // Private variable
	private ApexPages.StandardController con;
    private Map<String,String> fieldLabelNames1;
    private Map<String,String> fieldLabelNames2;
    private Map<String,String> fieldTypeMap1;
    private Map<String,String> fieldTypeMap2;
    private Map<String,String> objectMaps;
    private Map<String,String> childrenObjectMap;
    private Map<String,String> parentObjectFieldMap;
    
    // public variables
    public List<SelectOption> targetObjects {get;set;}
    public String selectedObject1	        {get;set;}
    public String selectedObject2	        {get;set;}
    public String selectedSourceRTs         {get;set;}
    public String selectedTargetRTs         {get;set;}
    public String filterValue		        {get;set;}
    public List<wrapFields> wfields	        {get;set;}
    public boolean isCustomValue	        {get;set;}
    public boolean isObjectMap		        {get;set;} 
    public String selectedMapType	        {get;set;}
    public boolean isObjectSelected         {get;set;}
    public boolean isAutomatchSelected      {get;set;}
    public boolean twoWaySync               {get;set;}
    public boolean includeInserts           {get;set;}
    public List<Object_Map__c> existingMaps {get;set;}
    
    // Constructor
	public MapperExt(ApexPages.StandardController con) {

		init();

	}

	// This method gets all the Objects using GlobalDescribe.
	
	private void init(){
  
        wfields = new List<wrapFields>();
        isObjectSelected    = false;
        isAutomatchSelected = false;    
        isObjectMap      = false;
        includeInserts   = false;
        twoWaySync       = true;
        targetObjects    = new List<SelectOption>();
        existingMaps     = new List<Object_Map__c>();
        selectedObject1  = '';
        selectedObject2  = '';
        
        targetObjects.add(new SelectOption('','-- Select Source Object --'));
        

		 objectMaps = new Map<String,String>();  	
         
         Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
         Set<String> objectKeys = gd.keySet();
         for(String objectKey: objectKeys) {              
             Schema.SobjectType sobjecttype = gd.get(objectKey);
             Schema.DescribeSObjectResult r = sobjecttype.getDescribe();
             if(r.isAccessible() && r.isCreateable()){                                                 
                 objectMaps.put(r.getName(),r.getLabel());                                  
             }            
       }

	}

    // Getter for the SourceObject Selection
    public List<SelectOption> getObjects(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--Select Source Object--'));
        List<String> sorted = new List<String>();
        sorted.addAll(objectMaps.keyset());
        sorted.sort();
        for(String s :sorted){
            options.add(new SelectOption(s,objectMaps.get(s)));
        }
        return options;
    }

    // Get the Target Objects, based on the selected source object.
    public void listTargetObjects(){
        
        targetObjects = new List<SelectOption>();
        childrenObjectMap    = new Map<String,String>();
        parentObjectFieldMap = new Map<String,String>();

        if(selectedObject1 == null || selectedObject1 == ''){
            targetObjects.add(new SelectOption('','-- Select Source Object First --'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Select Source Object First '));
            return;
        }

        // Use the ChildRelationship to get the Children for the Source Objects.
        for(Schema.ChildRelationship cr : Schema.getGlobalDescribe().get(selectedObject1).getDescribe().getChildRelationships()){

            Schema.DescribeSObjectResult cder = cr.getChildSObject().getDescribe();

            if(cder.isAccessible() && cder.isCreateable()){
                targetObjects.add(new SelectOption(cder.getLocalName(),cder.getLabel() + '( Child )'));    
                childrenObjectMap.put(cder.getLocalName(),cr.getField().getDescribe().getLocalName());
            }

        }

        // Use the Describe methods to be the Parents 
        for(Schema.SobjectField sf : Schema.getGlobalDescribe().get(selectedObject1).getDescribe().fields.getMap().values()){
            
            Schema.DescribeFieldResult fr = sf.getDescribe();

            // pull only custom right now. I dont want to confuse by adding all standard objects as well. (Addln Features functionality)
            if(fr.getRelationshipOrder() == 0 || (fr.getReferenceTo() != null && fr.getReferenceTo().size()>0 && fr.getReferenceTo()[0].getDescribe().getLocalName().contains('__c')) ){ 
                Schema.DescribeSObjectResult cder = fr.getReferenceTo()[0].getDescribe();
                targetObjects.add(new SelectOption(cder.getLocalName(),cder.getLabel()+'(Parent)'));
                parentObjectFieldMap.put(cder.getLocalName(),fr.getName());
            }
        }

    }

    // Get the Data types to compare. 

    public void getDataTypes(){

    	for(wrapFields wf : wfields){
            
                if(wf.sourceField != null && wf.targetField != null ){
                    
                    if(fieldTypeMap1.get(wf.sourceField) != fieldTypeMap2.get(wf.targetField)){
                    	wf.message = 'Data Types do not match ' + fieldTypeMap1.get(wf.sourceField) + ' --> ' + fieldTypeMap2.get(wf.targetField); 
                    }
                }
            }
    }

    // This method builds the Mapper fields from the Selected Objects. Based on the Fields returned.
    public Pagereference buildMappers(){
        
        if(selectedObject1 != null && selectedObject2 != null){


            existingMaps = [Select Id, Name from Object_Map__c where Source_Object__c = :selectedObject1 AND Target_Object__c = :selectedObject2];

            isObjectSelected = true;                
            getObjectFields(); //
            
            wfields = new List<wrapFields>();       
            wrapFields w;
        
            if(fieldLabelNames1.size() > 0){            
                for(String f : fieldLabelNames1.values()){
                    w = new wrapFields();
                    wfields.add(w); // Empty Wrapper Class is created with size equal to number of fields in the Source Object 
                }
            }
            
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Select both the Objects '));
        }

        return null;
    }
    

    // This method gets the all the fields for the selected Objects.
    public void getObjectFields(){
        
       fieldLabelNames1 = new Map<String,String>();
       fieldLabelNames2 = new Map<String,String>();
       fieldTypeMap1    = new Map<String,String>();
       fieldTypeMap2    = new Map<String,String>();
       
       if (selectedObject1 != null && selectedObject2 != null) {            
                
            for(Schema.SobjectField so: Schema.getGlobalDescribe().get(selectedObject1).getDescribe().fields.getMap().values()){
                
                 DescribeFieldResult f = so.getDescribe();                                                                   
                 
                 if(f.isAccessible()&& f.isUpdateable() && f.getName() != 'RecordTypeId'){  // Checks to see if the field is accessible and updateable. Can be expanded to add more validations.                                                  
                    fieldLabelNames1.put(f.getName(),f.getlabel());                                               
                    fieldTypeMap1.put(f.getName(),f.getType().name());
                 }                                                                           
            }

            for(Schema.SobjectField so: Schema.getGlobalDescribe().get(selectedObject2).getDescribe().fields.getMap().values()){
                 
                DescribeFieldResult f = so.getDescribe();                                                                   

                 if(f.isAccessible() && f.isUpdateable() && f.getName() != 'RecordTypeId'){                                                       
                     fieldLabelNames2.put(f.getName(),f.getlabel());
                     fieldTypeMap2.put(f.getName(),f.getType().name());
                 }

            }
          
        }    
    }

    // Method Resets to the Original State.
    public void reset(){
       
        init();
        
    }   

    // This method inserts the Map into Object Mapper and Field Mapper Custom Objects
    public Pagereference createMaps(){
            
            Object_Map__c newMap = new Object_Map__c(); // Object Map
            List<Field_Mapping__c> fieldMaps = new List<Field_Mapping__c>(); // Field Maps.
            SavePoint s1;
            newMap.Source_Object__c = selectedObject1;
            newMap.Target_Object__c = selectedObject2;
            newMap.Two_way_Sync__c  = twoWaySync;
            if(selectedSourceRTs != null)
            	newMap.Source_Record_Types__c = selectedSourceRTs.substringBetween('[',']').replace(',',';');
            if(selectedTargetRTs != null)
            	newMap.Target_Record_Types__c = selectedTargetRTs.substringBetween('[',']').replace(',',';');
            newMap.Include_Inserts__c     = includeInserts;
            
            if(childrenObjectMap.containsKey(selectedObject2)){
                newMap.Related_to_Source__c = childrenObjectMap.get(selectedObject2);
            } else if(parentObjectFieldMap.containsKey(selectedObject2)){
                newMap.Related_to_Source__c = parentObjectFieldMap.get(selectedObject2); 
                newMap.Parent_Sync__c = true;
            }

            try {
                insert newMap;

            }catch(DMLException e){             
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Map failed to create - ' + e.getMessage()));
                return null;
            }
            
            Field_Mapping__c fm;
            
            for(wrapFields wf : wfields){
            
                if(wf.sourceField != null && wf.targetField != null ){
                    fm = new Field_Mapping__c();
                    
                    fm.Object_Mapping__c = newMap.Id;
                    fm.Source_Field__c   = wf.sourceField;
                    fm.Target_Field__c   = wf.targetField;  

                    fieldMaps.add(fm);
                }
            }
            
            try {
                insert fieldMaps;
            }catch(DMLException e){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Map failed to create - ' + e.getMessage()));
                 Database.rollback(s1); // Rollback to the SavePoint
                 return null;
            }

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Map Created Succesfully'));
            
            return null;
    }

    // This methods performs Auto matching of fields between the two objects based on the field labels.
    public Pagereference autoMatch(){
        
        isAutomatchSelected = true;
        wfields = new List<wrapFields>();       
        wrapFields w;
        
        if(fieldLabelNames1.size() > 0 && fieldLabelNames2.size() > 0){
            
            for(String s : fieldLabelNames1.keyset()){
                for(String t :fieldLabelNames2.keyset()){
                    if(fieldLabelNames1.get(s) == fieldLabelNames2.get(t)){
                        w = new wrapFields();
                        w.sourceField = s;
                        w.targetField = t;
                        if(fieldTypeMap1.get(s) != fieldTypeMap2.get(t)){
                            w.message = 'Data Types do not match ' + fieldTypeMap1.get(s) + ' --> ' + fieldTypeMap2.get(t); 
                        }
                        wfields.add(w);                     
                    }                       
                }               
            }
        
            if(wfields.size() == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'Unable to do Auto Matching - Try doing manual Mapping '));                
                isAutomatchSelected = false;
                
                if(fieldLabelNames1.size() > 0){            
                    for(String f : fieldLabelNames1.values()){
                        w = new wrapFields();
                        wfields.add(w); // Empty Wrapper Class is created with size equal to number of fields in the Source Object 
                    }
                }
            }

        }else{
            isAutomatchSelected = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No Fields in either of objects - Reset and try'));
        }       
        return null;        
    }

    // Getter for the Source Record Types
    public List<SelectOption> getSourceRTs(){
        

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--Select Source Record Types--'));
        
        for(Schema.RecordTypeInfo s: Schema.getGlobalDescribe().get(selectedObject1).getDescribe().getRecordTypeInfos()){
            options.add(new SelectOption(s.getRecordTypeId(),s.getName()));
        }
        
        return options;
    }


    // Getter for the Target Record Types
    public List<SelectOption> getTargetRTs(){
        

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--Select Target Record Types--'));
        
        for(Schema.RecordTypeInfo s: Schema.getGlobalDescribe().get(selectedObject2).getDescribe().getRecordTypeInfos()){
            options.add(new SelectOption(s.getRecordTypeId(),s.getName()));
        }
        
        return options;
    }

	 // Getter for the Shadow Object Fields
    public List<SelectOption> gettargetFields(){
    	

    	List<SelectOption> options = new List<SelectOption>();
    	options.add(new SelectOption('','--Select Target Field--'));
    	
    	for(String s: fieldLabelNames2.keySet()){
    		options.add(new SelectOption(s,fieldLabelNames2.get(s)));
    	}
    	
    	return options;
    }

     // Getter for the Source Object Fields.
    public List<SelectOption> getFields(){
    	
    	List<SelectOption> options = new List<SelectOption>();
    	options.add(new SelectOption('','--Select Source Field--'));
    	
    	for(String s: fieldLabelNames1.keySet()){
    		options.add(new SelectOption(s,fieldLabelNames1.get(s)));
    	}
    	
    	return options;
    }


	// Wrapper Class to Wrap the fields together. This is used to display the fields as tables. Can be expanded to add any boolean flags, Data Types.
	public class wrapFields{
    
    	public String sourceField{get;set;}
    	public String targetField{get;set;}
    	public String message    {get;set;}


	}
}