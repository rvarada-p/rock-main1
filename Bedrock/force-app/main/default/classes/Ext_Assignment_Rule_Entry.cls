global with sharing class Ext_Assignment_Rule_Entry {

    public Assignment_Rule_Entry__c rule {get;set;}
    public map<String,String> FieldtoFieldType;
    public map<String,String> FieldtoSOAPValueType;
    public map<string, List<string>> relatedpicklistvalues;
    public string test{get;set;}
    public PaginatedSelectList aggregatedOptionsList{get;set;} 
    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.

    public List<selectOption> fieldnames {get;set;}


    public Ext_Assignment_Rule_Entry(ApexPages.StandardController stdController) {
        this.rule = (Assignment_Rule_Entry__c)stdController.getRecord();
        if(rule.id != null){
            //BeginMod LobR 5/12/2015: Add rule description
            rule = [Select id, Opportunity_Assignment_Rule__r.name, Opportunity_Assignment_Rule__c, Order_Number__c, Assign_to_Assignment_Group__c, Rule_Description__c  from Assignment_Rule_Entry__c where id =: rule.id];
            //EndMod LobR 5/12/2015: Add rule description
        }

        adddefaultrows();
        buildfieldlist();
    }

    public list<Assignment_Rule_Entry_Condition__c> conditions{
        get{
            if(conditions == null){
                conditions = new list<Assignment_Rule_Entry_Condition__c>();
            }
            return conditions;
        }
        set;
    }

    public void addrow(){
        conditions.add(new Assignment_Rule_Entry_Condition__c());
        system.debug(conditions.size());
    }

    public void buildfieldlist(){
        aggregatedOptionsList=new PaginatedSelectList();
        aggregatedOptionsList.add(new SelectOption('','--None--'));
        getPickValues('Opportunity');

        //fieldnames = new List<selectOption>();
        //fieldnames.add(new SelectOption('','--None--'));

        //List<selectOption> OpportunityOptions = getPickValues('Opportunity');
        //fieldnames.addall(getPickValues('Opportunity'));

        //List<selectOption> ContactyOptions = getPickValues('Contact');
        //fieldnames.addall(getPickValues('Contact'));
    }

    public void adddefaultrows(){
        For(Assignment_Rule_Entry_Condition__c REntry: [Select id, Assignment_Rule_Entry__c, Field_API_Name__c, Field_Type__c, Operator__c, Value__c, Value_SOAP_Type__c, LineNumber__c from Assignment_Rule_Entry_Condition__c where Assignment_Rule_Entry__c =: rule.id ORDER BY LineNumber__c]){
            if(REntry.Field_Type__c == 'DATETIME'){
                    if(REntry.Value__c != null){
                        Datetime Currenttime = Datetime.valueOfGMT(REntry.Value__c);
                        string convertedtimeStr = Currenttime.format('MM/dd/yyyy hh:mm a');
                        REntry.Value__c = convertedtimeStr;
                    }
                }else if(REntry.Field_Type__c == 'DATE'){
                    if(REntry.Value__c != null){
                        Datetime Currenttime = Datetime.valueOf(REntry.Value__c);

                        string convertedtimeStr = Currenttime.format('MM/dd/yyyy');
                        REntry.Value__c = convertedtimeStr;
                }
            }
            conditions.add(REntry);
        }

        integer conditionsize =  conditions.size();

        if(conditions.size()>0 && conditions.size()<5){
            system.debug('this is the default size:'+conditions.size());
            for(Integer ii = 0; ii < (5-conditionsize); ii++){
                conditions.add(new Assignment_Rule_Entry_Condition__c());
            } 
        }else if(conditions.size()>=5){
            conditions.add(new Assignment_Rule_Entry_Condition__c());
        }else if(conditions.size() == null || conditions.size() == 0){
            for(Integer ii = 0; ii < 5; ii++){
                conditions.add(new Assignment_Rule_Entry_Condition__c());
            } 
        }


    }

    public List<selectOption> getOpperatorValues(){
            List<selectOption> options = new List<selectOption>();
            
            options.add(new SelectOption('','--None--'));

            options.add(new SelectOption('equals','equals'));
            options.add(new SelectOption('not equals to','not equals to'));
            options.add(new SelectOption('starts with','starts with'));
            options.add(new SelectOption('contains','contains'));
            options.add(new SelectOption('does not contain','does not contain'));
            options.add(new SelectOption('less than','less than'));
            options.add(new SelectOption('greater than','greater than'));
            options.add(new SelectOption('less or equal','less or equal'));
            options.add(new SelectOption('greater or equal','greater or equal'));
            options.add(new SelectOption('includes','includes'));
            options.add(new SelectOption('excludes','excludes'));

            return options;

    } 

    public void getPickValues(string Objectname) {
        //field prefix + related object
        relatedpicklistvalues = new map<string, List<string>>();
        FieldtoFieldType =new map<String,String>();
        FieldtoSOAPValueType =new map<String,String>();

        Map<Schema.SObjectType, string>objectlabelmap = new Map<Schema.SObjectType, string>();
        Map<Schema.SObjectType, List<Schema.DescribeFieldResult>>objectmap = new Map<Schema.SObjectType, List<Schema.DescribeFieldResult>>();
        Map<string, Schema.SObjectType> relatedobjectmap = new Map<string, Schema.SObjectType>();
        Map<string, string> relatedlabelmap = new Map<string, string>();

        //List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(Objectname);
        sObject obj = targetType.newSObject();
        Schema.sObjectType sobject_type = obj.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
            For(Schema.SObjectField Field: field_map.values()){
                Schema.DescribeFieldResult F = Field.getDescribe();


                if(F.getReferenceTo().size()>0){
                    system.debug('Lookup field name = ' + F.getName());
                    string originalname = F.getName();
                    string modifiedfieldname = '';
                    if(originalname.endsWithIgnoreCase('Id') == true){
                        modifiedfieldname = originalname.left(originalname.lastIndexOfIgnoreCase('Id'));
                    }else if(originalname.endsWith('__c')== true){
                        modifiedfieldname = originalname.removeEnd('__c') +'__r';
                    }

                    relatedobjectmap.put(modifiedfieldname,F.getReferenceTo()[0]);
                    relatedlabelmap.put(modifiedfieldname,F.getLabel().removeEnd(' ID'));

                    objectmap.put(F.getReferenceTo()[0], new list<Schema.DescribeFieldResult>());
                }

                //system.debug(F.getName() + ' reference to ' + F.getSObjectField());
                system.debug('Option field name = ' + F.getName());
                //options.add(new SelectOption(F.getName(),Objectname+': '+F.getLabel()));
                aggregatedOptionsList.add(new SelectOption(F.getName(),Objectname+': '+F.getLabel()));
                FieldtoFieldType.put(F.getName(),String.Valueof(F.getType()));
                FieldtoSOAPValueType.put(F.getName(),String.Valueof(F.getSOAPType()));
                    String FieldValType = String.Valueof(F.getType());
                    system.debug('FieldValType: ' +FieldValType);
                    if(FieldValType == 'PICKLIST'||FieldValType == 'MULTIPICKLIST'){
                        List<string> PLvalues = new List<string>();
                        For(Schema.PicklistEntry PL: F.getPicklistValues()){
                            PLvalues.add(PL.getValue());
                        }

                        relatedpicklistvalues.put(F.getName(),PLvalues);
                    }
              /*
                    if(Objectname == 'Contact'){
                        options.add(new SelectOption('contact__r.'+F.getName(),Objectname+': '+F.getLabel()));
                    }else{
                        options.add(new SelectOption(F.getName(),Objectname+': '+F.getLabel()));
                    }*/
            }
            //options.sort();


            if(objectmap.isEmpty()==false){
                for(Schema.SObjectType S:objectmap.keyset()){
                    List<Schema.DescribeFieldResult> fieldlist = objectmap.get(S);

                    Schema.DescribeSObjectResult describe = S.getDescribe(); //describe the sobject
                        objectlabelmap.put(S,describe.getLabel());

                        Map<String, Schema.SObjectField> field_map2 = describe.fields.getMap(); //get a map of fields for the passed sobject
                            For(Schema.SObjectField Field: field_map2.values()){
                                Schema.DescribeFieldResult F = Field.getDescribe();
                                fieldlist.add(F);
                            }
                }
            }

            //List<selectOption> sortedtempoptions = new List<selectOption>(); 

            if(relatedobjectmap.isEmpty()==false){
                for(String FieldPrefix: relatedobjectmap.keyset()){
                    system.debug('FieldPrefix ' + FieldPrefix);
                    //Skip some lookup objects which we don't need their related values in the select list (ignore list should be reviewed and updated)
                    if(FieldPrefix != 'CreatedBy' && FieldPrefix != 'LastModifiedBy' && FieldPrefix != 'Account' && FieldPrefix != 'Referred_By__r' && FieldPrefix != 'Brand_Profile__r'){
                        //List<selectOption> tempoptions = new List<selectOption>(); //new list for holding all of the picklist options prior to sorting

                        for(Schema.DescribeFieldResult FieldVal: objectmap.get(relatedobjectmap.get(FieldPrefix))){
                            //tempoptions.add(new SelectOption(FieldPrefix+'.'+FieldVal.getName(), relatedlabelmap.get(FieldPrefix)+':'+FieldVal.getLabel()+'('+objectlabelmap.get(relatedobjectmap.get(FieldPrefix))+')'));
                            aggregatedOptionsList.add(new SelectOption(FieldPrefix+'.'+FieldVal.getName(), relatedlabelmap.get(FieldPrefix)+':'+FieldVal.getLabel()+'('+objectlabelmap.get(relatedobjectmap.get(FieldPrefix))+')'));
                            //Fieldtodescriberesult.put(FieldPrefix+'.'+FieldVal.getName(),FieldVal);
                            FieldtoFieldType.put(FieldPrefix+'.'+FieldVal.getName(),String.Valueof(FieldVal.getType()));
                            FieldtoSOAPValueType.put(FieldPrefix+'.'+FieldVal.getName(),String.Valueof(FieldVal.getSOAPType()));
                            String FieldValType = String.Valueof(FieldVal.getType());
                            //system.debug('FieldValType: ' +FieldValType);
                            if(FieldValType == 'PICKLIST'||FieldValType == 'MULTIPICKLIST'){
                                List<string> PLvalues = new List<string>();
                                For(Schema.PicklistEntry PL: FieldVal.getPicklistValues()){
                                    PLvalues.add(PL.getValue());
                                }

                                relatedpicklistvalues.put(FieldPrefix+'.'+FieldVal.getName(),PLvalues);
                            }
                        }

                        //tempoptions.sort();
                        //system.debug('tempoptions length ' + tempoptions.size());
                        //sortedtempoptions.addAll(tempoptions);
                    }
                }
            }
            //sortedtempoptions.sort();

            //options.addAll(sortedtempoptions);
            //system.debug('options length ' + options.size());
            //system.debug('all related fields ' + FieldtoFieldType);

            system.debug('test list --> ' + aggregatedOptionsList.getSize());
        //return options; //return the List
    }

    public PageReference save(){
        upsert rule;

        List<Assignment_Rule_Entry_Condition__c> toupsert = new List<Assignment_Rule_Entry_Condition__c>();
        List<Assignment_Rule_Entry_Condition__c> todelete = new List<Assignment_Rule_Entry_Condition__c>();


        for(Assignment_Rule_Entry_Condition__c cond:conditions){
            if(cond.id != null && (cond.Field_API_Name__c == null||cond.Field_API_Name__c == '')){
                todelete.add(cond);
            }else if(cond.Field_API_Name__c != null && cond.Field_API_Name__c != ''){
                
                system.debug( FieldtoFieldType.keyset());

                system.debug( cond.Field_API_Name__c);

                cond.Field_Type__c = FieldtoFieldType.get(cond.Field_API_Name__c);
                cond.Value_SOAP_Type__c = FieldtoSOAPValueType.get(cond.Field_API_Name__c);

                if(cond.Assignment_Rule_Entry__c == null){
                     cond.Assignment_Rule_Entry__c = Rule.id;               
                }

                if(cond.Field_Type__c == 'DATETIME'){
                    if(cond.Value__c != null && cond.Value__c != ''){
                        Datetime Currenttime = Datetime.parse(cond.Value__c);
                        string convertedtimeStr = Currenttime.formatGMT('yyyy-MM-dd HH:mm:ss');
                        cond.Value__c = convertedtimeStr;
                    }
                }else if(cond.Field_Type__c == 'DATE'){
                    if(cond.Value__c != null&& cond.Value__c != ''){

                        Date Currentdate = Date.parse(cond.Value__c);
                        Datetime dt = datetime.newInstance(Currentdate.year(), Currentdate.month(),Currentdate.day());
                        string convertedtimeStr = dt.format('yyyy-MM-dd HH:mm:ss');
                        system.debug(convertedtimeStr);
                        cond.Value__c = convertedtimeStr;
                    }
                }

                
                toupsert.add(cond);
            }
        }

        for(Integer ii = 0; ii < toupsert.size(); ii++){
            toupsert[ii].name = string.valueof(ii+1);
            toupsert[ii].LineNumber__c = ii+1;
        }

        if(toupsert.isEmpty() == false){
            system.debug(toupsert);
            upsert toupsert;
        }
        if(todelete.isEmpty() == false){
            delete todelete;
        }

        PageReference pageRef = new PageReference('/'+Rule.Opportunity_Assignment_Rule__c);
            pageRef.setRedirect(true);
            return pageRef;

    }

   /* public PageReference cancel(){
        PageReference pageRef = new PageReference('/'+rule.id);
            pageRef.setRedirect(true);
            return pageRef;
    }*/

    public void resetpicklistvalue(){
        string fieldname =  ApexPages.currentPage().getParameters().get('selectedfield');
        picklistoptions = new list<string>();

        if(fieldname != null && fieldname != ''){
            if(relatedpicklistvalues.get(fieldname) != null){
                picklistoptions = relatedpicklistvalues.get(fieldname);
            }
        }

    }



    public List<string> picklistoptions{
        get{
            if(picklistoptions == null){
                picklistoptions = new list<string>();
            }
            return picklistoptions;
        }
        set;
    }


    @RemoteAction
    global static string getFieldType(String selectedval) {
        string fieldtype;

        system.debug(selectedval);

            Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Opportunity');
            sObject obj = targetType.newSObject();
            Schema.sObjectType sobject_type = obj.getSObjectType(); //grab the sobject that was passed
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();


        if(selectedval.contains('.')){
            Schema.SObjectField Field;

            system.debug(selectedval.left(selectedval.indexOf('.')));
            string rootfield = selectedval.left(selectedval.indexOf('.')).removeEnd('__r');
            if(field_map.get(rootfield +'__c')!= null){
                Field = field_map.get(rootfield +'__c');
            }else if(field_map.get(rootfield +'Id')!= null){
                Field = field_map.get(rootfield +'Id');
            }
            
            system.debug('Field'+ Field);

            if(Field != null){
                Schema.DescribeFieldResult F = Field.getDescribe();

                Schema.SObjectType relatedobjecttype;
                if(F.getReferenceTo().size()>0){
                    relatedobjecttype = F.getReferenceTo()[0];
                }
                            system.debug('relatedobjecttype'+ relatedobjecttype);

                if(relatedobjecttype!= null){
                    Schema.DescribeSObjectResult sobject_describerelated = relatedobjecttype.getDescribe(); //describe the sobject
                    Map<String, Schema.SObjectField> field_maprelated = sobject_describerelated.fields.getMap();
                     system.debug(selectedval.substringAfterLast('.'));
                     system.debug(field_maprelated.keyset());

                     for(string s: field_maprelated.keyset()){
                        system.debug(S);

                     }

                    if(field_maprelated.get(selectedval.substringAfterLast('.'))!= null){
                        Schema.SObjectField FinalField =field_maprelated.get(selectedval.substringAfterLast('.'));
                                                    system.debug('FinalField'+ FinalField);

                        Schema.DescribeFieldResult FFinal = FinalField.getDescribe();
                        
                        fieldtype = String.valueof(FFinal.getType());
                    }
                }

                //substringAfterLast(String)


            }

        }else if(field_map.get(selectedval)!= null){
            Schema.SObjectField Field = field_map.get(selectedval);
                if(Field != null){
                    Schema.DescribeFieldResult FFinal = Field.getDescribe();
                    fieldtype = String.valueof(FFinal.getType());
                }
        }

        return fieldtype;
    }

    
}