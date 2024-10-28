/*******************************************************************
Name  : Utility
Author: Tom (Appirio)
Date  : October 05, 2014
Description: Utility methods
* Sufia             - June 28, 2021 - User Story S-685520
*************************************************************************/
public class Utility {

  public static Date getSundayEndDateForStudentSubscription(Integer numbOfMonths, Date startDate) {
    Date endDate;
    Date firstDateOfNewSubMonth = startDate.addMonths(numbOfMonths).toStartOfMonth();
    Date sundayDateOfFirstWeek = firstDateOfNewSubMonth.toStartOfWeek();
    if(firstDateOfNewSubMonth.month() == sundayDateOfFirstWeek.month()){
      endDate = sundayDateOfFirstWeek; 
    } else {
      endDate = sundayDateOfFirstWeek+7; 
    }
    if(endDate.day()==7){
      endDate = endDate - 7;
    }
    return endDate;
  }
  public static Boolean isFirstMondayOfMonth(Date startDate) {
    Date dtMonthtStartdate = startDate.toStartOfMonth();
  	Date dtWeekStartDate = dtMonthtStartdate.toStartOfWeek();
  	Date dtFirstMondayDate = dtWeekStartDate.addDays(1);
  	if(dtFirstMondayDate < dtMonthtStartdate){
  		// week start before the month start and the monday also before the begning of the month
  		// so we will move to next monday 		
  		dtFirstMondayDate = dtFirstMondayDate.addDays(7);
  	}
  	if(startDate == dtFirstMondayDate){
      return true;
    } else {
      return false;    
    }
  }

  /*******************************************************************
  Method to get all the recordtyeid for a particular sObj
  ********************************************************************/
  public static set<ID> getRecordTypeFromCBLCustomSetting(Schema.DescribeSobjectResult dSObj){    
    Map<String, RecordTypes_For_CBL_Processes__c> recordTypesForCBLProcesses = RecordTypes_For_CBL_Processes__c.getAll();

    Map<String,Schema.RecordTypeInfo> rtMapName_Id = dSObj.getRecordTypeInfosByName();
    set<ID> allRecordTypeIds = new set<ID>();
    for(String rType :recordTypesForCBLProcesses.keySet()){
      RecordTypes_For_CBL_Processes__c cblRecordType = recordTypesForCBLProcesses.get(rType);
      if(cblRecordType.Object_API_Name__c == dSObj.getName() && rtMapName_Id.containsKey(cblRecordType.RecordType_Name__c)){
        allRecordTypeIds.add(rtMapName_Id.get(cblRecordType.RecordType_Name__c).getRecordTypeId());
      }
    }
    return allRecordTypeIds;
  }

  /*******************************************************************
  Method to get items of an array without a particular item 
  ********************************************************************/
  public static List<sObject> without(List<sObject> sobjs, String field, String value){    
    List<sObject> left = new List<sObject>();
    for(sObject sobj : sobjs){
      if(sobj.get(field) <> value){
        left.add(sobj);
      }
    }
    return left;

  }  
  /*******************************************************************
  Method to get if all values of one list are unique within themselves and their parent's children
  ********************************************************************/
  public static sObject unique(List<sObject> search, Map<Id, sObject> targets, String field, String parent, String children){    
     //verify uniqueness in new
     //need to use indexes to make sure we're not comparing
     //the same object
     for(Integer i = 0; i < search.size(); i++){
        sObject item = search.get(i);
        if(item.get(field) <> null){
            for(Integer j = 0; j < search.size(); j++){
                sObject itemSub = search.get(j);
                if(i <> j){
                    if(item.get(parent) == itemSub.get(parent) &&
                        item.get(field) == itemSub.get(field)){
                        return item;
                    }
                }
            }
        }
    }

   
    //verify uniqueness in existing
    for(sObject item : search ){
        if(item.get(field) <> null){
            sObject itemParent = targets.get((id)item.get(parent));
            for(sObject parentChild : itemParent.getSObjects(children)){
                if(parentChild.get(field) == item.get(field)){
                    return item;
                }
            }
        }
        
    }
    return null;

  }  
  /*******************************************************************
  Method to get if a list of sobjects contains all values in another list
  ********************************************************************/
  public static Boolean all(List<sObject> sobjs, String field, List<String> values){
    for(String value : values){
      if(!contains(sobjs, field, value))
        return false;
    }    
    return true;
  }
  /*******************************************************************
  Method to get if a list of sobjects contain a value in a certain field
  ********************************************************************/
  public static Boolean contains(List<sObject> sobjs, String field, String value){
    for(sObject sobj : sobjs){
      if(sobj.get(field) == value){
        return true;
      }
    }
    return false;
  }

  /**
     * The MIT License (MIT)
     * 
     * Copyright (c) 2014 bigass.force.com
     * 
     * Permission is hereby granted, free of charge, to any person obtaining a copy
     * of this software and associated documentation files (the "Software"), to deal
     * in the Software without restriction, including without limitation the rights
     * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
     * copies of the Software, and to permit persons to whom the Software is
     * furnished to do so, subject to the following conditions:
     * 
     * The above copyright notice and this permission notice shall be included in
     * all copies or substantial portions of the Software.
     * 
     * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
     * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
     * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
     * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
     * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
     * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
     * THE SOFTWARE.
     */
    static public String protocolAndHost {
        get {
            if (protocolAndHost == null) {
                //memoize
                String orgId = UserInfo.getOrganizationId();
                String userId = UserInfo.getUserId();
                String sessionId = UserInfo.getSessionId();

                //we can trust getSalesforceBaseUrl within batches and schedules (but not in VF)
                if (sessionId == null) return Url.getSalesforceBaseUrl().toExternalForm().replace('http:', 'https:');

                PageReference pr = new PageReference('/id/' + orgId + '/' + userId);
                pr.getParameters().put('oauth_token', sessionId);
                pr.getParameters().put('format', 'json');

                //within test context use url class, else derive from identity api
                String data = Test.isRunningTest() ? '{"urls": {"rest": "' + Url.getSalesforceBaseUrl().toExternalForm() + '"}}' : pr.getContent().toString();
                Map<String,Object> result = (Map<String,Object>)Json.deserializeUntyped(data);
                Map<String,Object> urls = (Map<String,Object>)result.get('urls');
                Url rest = new Url((String)urls.get('rest'));
                protocolAndHost = rest.getProtocol() + '://' + rest.getHost();
            }

            return protocolAndHost;
        }


    }
    /*******************************************************************
  Method to sort sobject lists to reduce chunk issues
  ********************************************************************/
    public static List<sObject> getsObjectListChunkSafe(List<sObject> listToUpdate) {
     Integer SFDC_CHUNK_LIMIT = 10;
     Map<String, List<Sobject>> sortedMapPerObjectType = new Map<String, List<Sobject>>();
     Map<String, Integer> numberOf200ChunkPerObject = new Map<String, Integer>();
     for (Sobject obj : listToUpdate) {
     	String objTypeREAL = String.valueOf(obj.getSObjectType());
     	if (! numberOf200ChunkPerObject.containsKey(objTypeREAL)){
     		numberOf200ChunkPerObject.put(objTypeREAL, 1);
     	}
     	// Number of 200 chunk for a given Object
     	Integer numberOf200Record = numberOf200ChunkPerObject.get(objTypeREAL);
     	// Object type + number of 200 records chunk
     	String objTypeCURRENT = String.valueOf(obj.getSObjectType()) + String.valueOf(numberOf200Record);
     	// CurrentList
     	List<sObject> currentList = sortedMapPerObjectType.get(objTypeCURRENT);
     
     	if (currentList == null || currentList.size() > 199) {
     		if(currentList != null && currentList.size() > 199){
     			numberOf200ChunkPerObject.put(objTypeREAL, numberOf200Record + 1);
     			objTypeCURRENT = String.valueOf(obj.getSObjectType()) + String.valueOf(numberOf200Record); 
     		}
     		sortedMapPerObjectType.put(objTypeCURRENT, new List<Sobject>());
     	}
     	sortedMapPerObjectType.get(objTypeCURRENT).add(obj);
     }
     // Create a new list, which can contain a max of chunking limit, and sorted, so we don't get any errors 
     List<Sobject> safeListForChunking = new List<Sobject>();
     while(sortedMapPerObjectType.size() > 0) {
         List<String> keyListSobjectType = new List<String>(sortedMapPerObjectType.keySet());
         for (Integer i = 0;i<SFDC_CHUNK_LIMIT && !sortedMapPerObjectType.isEmpty();i++) {
         	List<Sobject> listSobjectOfOneType = sortedMapPerObjectType.remove(keyListSobjectType.remove(0)); 
         	safeListForChunking.addAll(listSobjectOfOneType);
         }
     }
     return safeListForChunking;
 	}
}