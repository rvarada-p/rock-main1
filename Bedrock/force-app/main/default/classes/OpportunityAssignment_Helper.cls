public class OpportunityAssignment_Helper {
//Method is passed a set of opportunity ids
    public static map<id,string> OpportunitytoGroupMatch(Set<id> oppids){
       system.debug('Enterted');
        map<id,string> oppidtoassignmentgroupid = new map<id,string>();
        //DATETIME, BOOLEAN, REFERENCE, DATETIME, PICKLIST, STRING, INTEGER, PERCENT, DOUBLE, CURRENCY, TEXTAREA, MULTIPICKLIST, ID, PHONE, EMAIL, URL, ADDRESS, ENCRYPTEDSTRING, 
        //1. get all active rule entries and rule criteria
        List<Assignment_Rule_Entry__c> activerulelist = new List<Assignment_Rule_Entry__c>();
        activerulelist = [Select id, Name, Assign_to_Assignment_Group__c, Order_Number__c, Opportunity_Assignment_Rule__c from Assignment_Rule_Entry__c where Opportunity_Assignment_Rule__r.is_active__c = true ORDER BY Order_Number__c];
        
        System.debug('*activerulelist: '+activerulelist);
        List<Assignment_Rule_Entry_Condition__c> conditionlist = new List<Assignment_Rule_Entry_Condition__c>();
        conditionlist = [Select id, Assignment_Rule_Entry__c, Assignment_Rule_Entry__r.Order_Number__c,  Assignment_Rule_Entry__r.Rule_Description__c,
                                Assignment_Rule_Entry__r.Assign_to_Assignment_Group__c, Field_API_Name__c, Field_Type__c, 
                                Operator__c, Value__c, Value_SOAP_Type__c from Assignment_Rule_Entry_Condition__c 
                                where Assignment_Rule_Entry__c in:activerulelist ORDER BY Assignment_Rule_Entry__r.Order_Number__c ASC];
        
        System.debug('*conditionlist: '+conditionlist);
        //2.loop though all crietia building a list of filed that will be needed
        Set<string> Fieldsneeded  = new Set<string>();
        List<string> FieldsneededList  = new List<string>();
        For(Assignment_Rule_Entry_Condition__c Cond: conditionlist){
          Fieldsneeded.add(Cond.Field_API_Name__c);
        }
        FieldsneededList.addAll(Fieldsneeded);
        system.debug('*:::Fieldsneeded:::'+FieldsneededList);
        //3. build a dynampic query string using the list of fields
        
        String query = 'Select Id, '+ String.join(FieldsneededList, ',')+ ' FROM Opportunity WHERE Id =:oppids ';
        
        //if there are no active rules then we know there will be no matches.
        if(FieldsneededList.isEmpty() == true){
            For(id oppid: oppids){
                oppidtoassignmentgroupid.put(oppid,null);
            }
            return oppidtoassignmentgroupid;

        }

        system.debug('*:::query:::'+query);
        List<Opportunity> opportunityList = new List<Opportunity>();
        opportunityList = Database.query(query);
        //Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>({});
        system.debug('*:::opportunityList:::'+opportunityList);
        
        //4. For each opportunity process it through the list of rule entries and return the id  from the field Assign_to_Assignment_Group__c
        //on the first rule that retruns all true criteria.  add opptunity id, and assignment group id to oppidtoassignmentgroupid map, if no match is found add the opportunityis
        //and null to the map
        system.debug('JSON: ' +JSON.serialize(opportunityList));
            Map<Decimal, Boolean> orderSuccessmap = new Map<Decimal, Boolean>();
            Map<Decimal, String> orderGroupIdMap = new Map<Decimal, String>();    
        for(Opportunity opp : opportunityList){
            
            orderSuccessmap = new Map<Decimal, Boolean>();
            orderGroupIdMap = new Map<Decimal, String>();
            Decimal previousOrderNumber;
            Integer loopCount = 0;
            
            if(!oppidtoassignmentgroupid.containsKey(opp.Id)) {
                oppidtoassignmentgroupid.put(opp.Id, null);
            }
            
            for(Assignment_Rule_Entry_Condition__c Cond: conditionlist){
                orderGroupIdMap.put(Cond.Assignment_Rule_Entry__r.Order_Number__c, Cond.Assignment_Rule_Entry__r.Assign_to_Assignment_Group__c+';'+Cond.Assignment_Rule_Entry__r.Rule_Description__c);
                if(orderSuccessmap.containsKey(Cond.Assignment_Rule_Entry__r.Order_Number__c)){
                
                } else {
                    system.debug(previousOrderNumber +':::'+ Cond.Assignment_Rule_Entry__r.Order_Number__c+':::'+orderSuccessmap.get(Cond.Assignment_Rule_Entry__r.Order_Number__c));
                    if(previousOrderNumber != NULL && previousOrderNumber != Cond.Assignment_Rule_Entry__r.Order_Number__c && orderSuccessmap.get(previousOrderNumber) == true){
                        oppidtoassignmentgroupid.put(opp.Id, orderGroupIdMap.get(previousOrderNumber));
                        break;
                    }
                    system.debug('orderSuccessmap :::'+orderSuccessmap.get(Cond.Assignment_Rule_Entry__r.Order_Number__c));
                    if(orderSuccessmap.get(Cond.Assignment_Rule_Entry__r.Order_Number__c) != false)
                        orderSuccessmap.put(Cond.Assignment_Rule_Entry__r.Order_Number__c, true);
                                          system.debug('orderSuccessmap :::'+orderSuccessmap.get(Cond.Assignment_Rule_Entry__r.Order_Number__c));

                }
                if(cond.Field_Type__c != NULL && cond.Field_Type__c != '') {
                
                    if(cond.Field_Type__c.toUpperCase() == 'REFERENCE' ||  cond.Field_Type__c.toUpperCase() == 'PICKLIST' ||
                       cond.Field_Type__c.toUpperCase() == 'STRING' || cond.Field_Type__c.toUpperCase() == 'TEXTAREA' || cond.Field_Type__c.toUpperCase() == 'MULTIPICKLIST' ) {
                    //||
                       //cond.Field_Type__c.toUpperCase() == 'ID' || cond.Field_Type__c.toUpperCase() == 'PHONE' || cond.Field_Type__c.toUpperCase() == 'EMAIL' ||
                       //cond.Field_Type__c.toUpperCase() == 'URL' || cond.Field_Type__c.toUpperCase() == 'ADDRESS' || cond.Field_Type__c.toUpperCase() == 'ENCRYPTEDSTRING'){
                        String fieldValue;
                        /* see modifirce versionbelow
                        if(Cond.Field_API_Name__c != NULL && Cond.Field_API_Name__c.toLowerCase().contains('contact__r')){
                            
                            if(opp.getSObject('Contact__r') != NULL)
                                fieldValue = (String)opp.getSObject('Contact__r').get(Cond.Field_API_Name__c.replace('Contact__r.',''));
                                
                        } */
						system.debug('cond'+cond);
                        system.debug('cond.Field_API_Name__c'+cond.Field_API_Name__c);
                        if(Cond.Field_API_Name__c != NULL && Cond.Field_API_Name__c.toLowerCase().contains('__r')){
                            
                            string fieldroot = cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'));
                            system.debug('fieldroot'+opp.getSObject(fieldroot));
                            if(opp.getSObject(fieldroot) != NULL){
                                fieldValue = (String)opp.getSObject(fieldroot).get(Cond.Field_API_Name__c.replace(cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'))+'.',''));
                              }
                        } else if(Cond.Field_API_Name__c != NULL && Cond.Field_API_Name__c.contains('.')){
                            string fieldroot = cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'));
                            if(opp.getSObject(fieldroot) != NULL){
                                fieldValue = (String)opp.getSObject(fieldroot).get(Cond.Field_API_Name__c.replace(cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'))+'.',''));                       
                              }
                        } else {
                            if(opp.get(Cond.Field_API_Name__c) != NULL) {
                                fieldValue = (String)opp.get(Cond.Field_API_Name__c);
                            }
                        }
                                                system.debug('cond.Field_Type__c'+cond.Field_Type__c);
                           system.debug('cond'+cond);
                        if(cond.Field_Type__c.toUpperCase() == 'ID'){
                            if(String.isNotBlank(Cond.Value__c) && String.valueOf(Cond.Value__c).length() == 15){
                                fieldValue = fieldValue.substring(0, 15);
                            }                        
                        }
                        if(!validate(fieldValue, Cond.Value__c, Cond.Operator__c, Cond.Value_SOAP_Type__c)){
                            orderSuccessmap.put(Cond.Assignment_Rule_Entry__r.Order_Number__c, false);
                        }
                            //Boolean res = validate(fieldValue, Cond.Value__c, Cond.Operator__c);
                            system.debug(':::String:::'+fieldValue+':::'+Cond.Value__c+'::::'+validate(fieldValue, Cond.Value__c, Cond.Operator__c, Cond.Value_SOAP_Type__c));    
                    } 
                    /*else if(cond.Field_Type__c.toUpperCase() == 'BOOLEAN'){
                        Boolean fieldValue;

                        if(Cond.Field_API_Name__c != NULL && Cond.Field_API_Name__c.toLowerCase().contains('__r')){
                        
                            string fieldroot = cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'));
                            if(opp.getSObject(fieldroot) != NULL)
                                fieldValue = (Boolean)opp.getSObject(fieldroot).get(Cond.Field_API_Name__c.replace(cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'))+'.',''));
                        } else if(Cond.Field_API_Name__c != NULL && Cond.Field_API_Name__c.contains('.')){
                        
                            string fieldroot = cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'));
                            if(opp.getSObject(fieldroot) != NULL)
                                fieldValue = (Boolean)opp.getSObject(fieldroot).get(Cond.Field_API_Name__c.replace(cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'))+'.',''));                       
                        } else {
                            if(opp.get(Cond.Field_API_Name__c) != NULL) {
                                fieldValue = (Boolean)opp.get(Cond.Field_API_Name__c);
                            }
                        }
                        if(!validate(String.valueOf(fieldValue), Cond.Value__c, Cond.Operator__c, Cond.Value_SOAP_Type__c)){
                            orderSuccessmap.put(Cond.Assignment_Rule_Entry__r.Order_Number__c, false);
                        }                   
                        system.debug(':::String:::'+validate(String.valueOf(fieldValue), Cond.Value__c, Cond.Operator__c, Cond.Value_SOAP_Type__c));                         
                    } 
                    */
                    /* else if(cond.Field_Type__c.toUpperCase() == 'DOUBLE' || cond.Field_Type__c.toUpperCase() == 'CURRENCY' || cond.Field_Type__c.toUpperCase() == 'PERCENT'){
                        DOUBLE fieldValue;

                        if(Cond.Field_API_Name__c != NULL && Cond.Field_API_Name__c.toLowerCase().contains('__r')){
                        
                            string fieldroot = cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'));
                            if(opp.getSObject(fieldroot) != NULL)
                                fieldValue = (DOUBLE)opp.getSObject(fieldroot).get(Cond.Field_API_Name__c.replace(cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'))+'.',''));
                        } else if(Cond.Field_API_Name__c != NULL && Cond.Field_API_Name__c.contains('.')){
                        
                            string fieldroot = cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'));
                            if(opp.getSObject(fieldroot) != NULL)
                                fieldValue = (DOUBLE)opp.getSObject(fieldroot).get(Cond.Field_API_Name__c.replace(cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'))+'.',''));                       
                        }
                        else {
                            if(opp.get(Cond.Field_API_Name__c) != NULL) {
                                fieldValue = (DOUBLE)opp.get(Cond.Field_API_Name__c);
                            }
                        }
                        if(Cond.Value__c.contains('.')== false){
                            Cond.Value__c = Cond.Value__c+'.0';
                        }      
                        
                        if(!validate(String.valueOf(fieldValue), Cond.Value__c, Cond.Operator__c, Cond.Value_SOAP_Type__c)){
                            orderSuccessmap.put(Cond.Assignment_Rule_Entry__r.Order_Number__c, false);
                        }  

                        system.debug(':::String Val:::'+String.valueOf(fieldValue) +':::'+ Cond.Value__c+':::'+Cond.Operator__c+':::'+Cond.Value_SOAP_Type__c);                      
                        system.debug(':::String:::'+validate(String.valueOf(fieldValue), Cond.Value__c, Cond.Operator__c, Cond.Value_SOAP_Type__c));                          
                    } 
                    
                    else if(cond.Field_Type__c.toUpperCase() == 'INTEGER'){
                        INTEGER fieldValue;
     
                        if(Cond.Field_API_Name__c != NULL && Cond.Field_API_Name__c.toLowerCase().contains('__r')){
                        
                            string fieldroot = cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'));
                            if(opp.getSObject(fieldroot) != NULL)
                                fieldValue = (INTEGER)opp.getSObject(fieldroot).get(Cond.Field_API_Name__c.replace(cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'))+'.',''));
                        } else if(Cond.Field_API_Name__c != NULL && Cond.Field_API_Name__c.contains('.')){
                        
                            string fieldroot = cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'));
                            if(opp.getSObject(fieldroot) != NULL)
                                fieldValue = (INTEGER)opp.getSObject(fieldroot).get(Cond.Field_API_Name__c.replace(cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'))+'.',''));                       
                        }
                        else {
                            if(opp.get(Cond.Field_API_Name__c) != NULL) {
                                fieldValue = (INTEGER)opp.get(Cond.Field_API_Name__c);
                            }
                        }
                        if(!validate(String.valueOf(fieldValue), Cond.Value__c, Cond.Operator__c, Cond.Value_SOAP_Type__c)){
                            orderSuccessmap.put(Cond.Assignment_Rule_Entry__r.Order_Number__c, false);
                        }                                    
                        system.debug(':::String Val:::'+String.valueOf(fieldValue) +':::'+ Cond.Value__c+':::'+Cond.Operator__c+':::'+Cond.Value_SOAP_Type__c);                      
                        system.debug(':::String:::'+validate(String.valueOf(fieldValue), Cond.Value__c, Cond.Operator__c, Cond.Value_SOAP_Type__c));                          
                    } 

                    else if(cond.Field_Type__c.toUpperCase() == 'DATE'){
                            DATE fieldValue;
                            String dateStr = (Cond.Value__c != NULL) ? String.valueOf(Date.Valueof(Datetime.valueof(Cond.Value__c))) : NULL;
 
                            if(Cond.Field_API_Name__c != NULL && Cond.Field_API_Name__c.toLowerCase().contains('__r')){
                        
                            string fieldroot = cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'));
                            if(opp.getSObject(fieldroot) != NULL)
                                fieldValue = (DATE)opp.getSObject(fieldroot).get(Cond.Field_API_Name__c.replace(cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'))+'.',''));
                            } else if(Cond.Field_API_Name__c != NULL && Cond.Field_API_Name__c.contains('.')){
                        
                                string fieldroot = cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'));
                                if(opp.getSObject(fieldroot) != NULL)
                                    fieldValue = (DATE)opp.getSObject(fieldroot).get(Cond.Field_API_Name__c.replace(cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'))+'.',''));                       
                            }  else {
                                if(opp.get(Cond.Field_API_Name__c) != NULL) {
                                    fieldValue = (DATE)opp.get(Cond.Field_API_Name__c);
                                }
                            } 
                            system.debug(':::String Val:::'+String.valueOf(fieldValue) +':::'+ dateStr+':::'+Cond.Operator__c);
                            if(!validate(String.valueOf(fieldValue), dateStr, Cond.Operator__c, Cond.Value_SOAP_Type__c)){
                                orderSuccessmap.put(Cond.Assignment_Rule_Entry__r.Order_Number__c, false);
                            }               
                            system.debug(':::String:::'+validate(String.valueOf(fieldValue), dateStr, Cond.Operator__c, Cond.Value_SOAP_Type__c));                              
                    
                    
                    } else if(cond.Field_Type__c.toUpperCase() == 'DATETIME'){
                        DATETIME fieldValue;
                        String dateTimeStr = (Cond.Value__c != NULL) ? String.valueOf(DateTime.valueOfGMT(Cond.Value__c)) : NULL;
   

                        if(Cond.Field_API_Name__c != NULL && Cond.Field_API_Name__c.toLowerCase().contains('__r')){
                        
                            string fieldroot = cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'));
                            if(opp.getSObject(fieldroot) != NULL)
                                fieldValue = (DATETIME)opp.getSObject(fieldroot).get(Cond.Field_API_Name__c.replace(cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'))+'.',''));
                        }  else if(Cond.Field_API_Name__c != NULL && Cond.Field_API_Name__c.contains('.')){
                        
                                string fieldroot = cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'));
                            if(opp.getSObject(fieldroot) != NULL)
                                fieldValue = (DATETIME)opp.getSObject(fieldroot).get(Cond.Field_API_Name__c.replace(cond.Field_API_Name__c.left(cond.Field_API_Name__c.indexof('.'))+'.',''));                       
                        } else {
                            if(opp.get(Cond.Field_API_Name__c) != NULL) {
                                fieldValue = (DATETIME)opp.get(Cond.Field_API_Name__c);
                            }
                        }  
                        system.debug(':::String Val:::'+String.valueOf(fieldValue) +':::'+ dateTimeStr+':::'+Cond.Operator__c);
                        if(!validate(String.valueOf(fieldValue), dateTimeStr, Cond.Operator__c, Cond.Value_SOAP_Type__c)){
                            orderSuccessmap.put(Cond.Assignment_Rule_Entry__r.Order_Number__c, false);
                        }   
                        system.debug(':::String:::'+validate(String.valueOf(fieldValue), dateTimeStr, Cond.Operator__c, Cond.Value_SOAP_Type__c));                                         
                    }
                    */
                } // end if cond.Field_Type__c not equals to NULL or empty check
                previousOrderNumber = Cond.Assignment_Rule_Entry__r.Order_Number__c;
                loopCount++;
                system.debug('previousOrderNumber: '+previousOrderNumber);
                system.debug('orderSuccessmap: '+orderSuccessmap.get(previousOrderNumber));
                if(loopCount == conditionlist.size()){
                    if(previousOrderNumber != NULL && orderSuccessmap.get(previousOrderNumber) == true){
                        oppidtoassignmentgroupid.put(opp.Id, orderGroupIdMap.get(previousOrderNumber));
                        break;
                    }                
                }
            }    
        }
        system.debug(oppidtoassignmentgroupid);
        return oppidtoassignmentgroupid;
    }
    
    public static Boolean validate(String input, String compareWith, String operator, String soapValue ){
        
        Boolean result;
        input = (String.isNotBlank(input) ? input.toLowerCase() : input);
        compareWith = (String.isNotBlank(compareWith) ? compareWith.toLowerCase() : compareWith);
        operator = (String.isNotBlank(operator) ? operator.toLowerCase() : operator);
        soapValue = (String.isNotBlank(soapValue) ? soapValue.toLowerCase() : soapValue);
       
        if(operator == 'equals'){
            if(String.isNotBlank(soapValue) && soapValue.toLowerCase() == 'string'){
                result = includesExcludes(compareWith,input,'includes');
                return result;
            } else if(input == compareWith){
               return true; 
            }
        } /*else if(operator == 'not equals to'){
            if(input != compareWith){
                return true;
            }
        } else if(operator == 'starts with'){
            if(input != NULL && input != '') {
                if(input.startsWith(compareWith)){
                 return true;
                }
            }
        } else if(operator == 'contains'){
            if(input != NULL && input != '') {
                if(input.contains(compareWith)){
                     System.debug('C4');
                    return true;
                }
            }
        } else if(operator == 'does not contain'){
            if(input != NULL && input != '') {
                if(!input.contains(compareWith)){
                    return true;
                }
            }
        } else if(operator == 'less than'){
            if(input < compareWith){
                return true;
            }
        } else if(operator == 'greater than'){
            if(input > compareWith){
                return true;
            }
        } else if(operator == 'less or equal'){
            if(input <= compareWith){
                return true;
            }
        } else if(operator == 'greater or equal'){
            if(input >= compareWith){
                return true;
            }
        } else if(operator == 'includes'){
            result = includesExcludes(compareWith,input,operator);
            return result;
        } else if(operator == 'excludes'){
            result = includesExcludes(compareWith,input,operator);
            return result;
        }   */         
        return false;    
    }
            
    //Method to check whether all the user entered input string is contained/not contained in corresponding pick list field in opportunity
    
    public static Boolean includesExcludes(String pleValuesInOpportunity, String userEnteredInput, String operator) {
        
        Set<String> oppPLESet = new Set<String>();
        Set<String> usrEnteredStringSet = new Set<String>();
        Boolean result = false;
        
        if(pleValuesInOpportunity != NULL && pleValuesInOpportunity != '') {
            if(pleValuesInOpportunity.contains(';')) {
                oppPLESet.addAll( pleValuesInOpportunity.trim().split(';') );
            }else if(pleValuesInOpportunity.contains(',')) {
                oppPLESet.addAll( pleValuesInOpportunity.trim().split(',') );
            }else {
                oppPLESet.add( pleValuesInOpportunity );
            }
        }
      
        if(userEnteredInput != NULL && userEnteredInput != '') {
            if(userEnteredInput.contains(';')) {
                usrEnteredStringSet.addAll( userEnteredInput.split(';') );
            }else if(userEnteredInput.contains(',')) {
                usrEnteredStringSet.addAll( userEnteredInput.split(',') );
            }else {
                usrEnteredStringSet.add( userEnteredInput );
            }
        }
        
        Integer counter = 0;
        for(String s : usrEnteredStringSet) {
            
            if(operator == 'includes') {                
                if( oppPLESet.contains( s ) ) {
                    counter++;
                }
            }else {             
                if(!oppPLESet.contains( s )) {
                    counter++;
                }
            }
        }
        
        if(usrEnteredStringSet.size() == counter && userEnteredInput!=null && userEnteredInput!='')
            result = true;
            
        return result;
    }  
}