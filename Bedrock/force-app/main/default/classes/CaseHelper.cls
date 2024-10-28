/*******************************************************************
Name  : CaseHelper
Author: Appirio
Date  : May 06, 2015
Description: Helper class for Case    
*************************************************************************/  

public with sharing class CaseHelper {

  public static void fetchRecordType(List<Case> newCaseList) {

    Map<Case, Id> caseOppty = new Map<Case, Id>();
    Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>();
    List<Id> spId = new List<Id>();
    List<Id> opptyId = new List<Id>();
    Map<Id, Id> spOppty = new Map<Id, Id>();
    Map<Id, Id> opptySP = new Map<Id, Id>();
    
    for(Case ca: newCaseList) {
    
      if(ca.Student_Program__c != null && ca.Opportunity__c == null) {
        spId.add(ca.Student_Program__c);
      } else if(ca.Student_Program__c == null && ca.Opportunity__c != null) {
        opptyId.add(ca.Opportunity__c);
      }    
      
      if(ca.Opportunity__c != null) {
        caseOppty.put(ca, ca.Opportunity__c);
      }
    }
    
    if(spId != null && spId.size() > 0) {
      spOppty = CaseHelper.populateSPOpptyMap(spId);
    }
    
    if(opptyId!= null && opptyId.size() > 0) {
      opptySP = CaseHelper.populateOpptySPMap(opptyId);
    }
    
    CaseHelper.populateSPOppty(newCaseList, spOppty, opptySP);
    
    caseOppty.clear();
    
    for(Case ca: newCaseList) {
      if(ca.Opportunity__c != null) {
        caseOppty.put(ca, ca.Opportunity__c);
      }
    }

    if(caseOppty != null && caseOppty.size() > 0) {
      opptyMap = CaseHelper.populateOpptyMap(caseOppty.values());
    }

    CaseHelper.populateRecordType(newCaseList, caseOppty, opptyMap);
  }

  public static Map<Id, Id> populateSPOpptyMap(List<Id> spId) {
    Map<Id, Id> spOppty = new Map<Id, Id>();
    for(Student_Program__c sp: [SELECT id, Application__c FROM Student_Program__c WHERE id IN: spId]) {
      if(sp.Application__c != null) {
        spOppty.put(sp.id, sp.Application__c);  
      }
    } 
    return spOppty;
  }
  
  public static Map<Id, Id> populateOpptySPMap(List<Id> opptyId) {
    Map<Id, Id> opptySP = new Map<Id, Id>();
    for(Opportunity opp: [SELECT id, Student_Program__c FROM Opportunity WHERE id IN: opptyId]) {
      if(opp.Student_Program__c != null) {
        opptySP.put(opp.id, opp.Student_Program__c);  
      }
    }
    return opptySP;
  } 
  
  public static Map<Id, Opportunity> populateOpptyMap(List<Id> opptyId) {
    Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>();
    for(Opportunity oppty : [SELECT id, Primary_Program__c, Institution__c FROM Opportunity WHERE id IN :opptyId]) {
      opptyMap.put(oppty.id, oppty);  
    }
    return opptyMap;
  }
  
  public static void populateSPOppty(List<Case> newCaseList, Map<Id, Id> spOppty, Map<Id, Id> opptySP) {
    
    for(Case ca: newCaseList) {  
      if(ca.Student_Program__c != null && ca.Opportunity__c == null) {
        if(spOppty.containsKey(ca.Student_Program__c)) {
          ca.Opportunity__c = spOppty.get(ca.Student_Program__c);
        }
      } else if(ca.Student_Program__c == null && ca.Opportunity__c != null) {
        if(opptySP.containsKey(ca.Opportunity__c)) {
          ca.Student_Program__c = opptySP.get(ca.Opportunity__c);
        }
      }
    }     
  }  
  
  public static void populateRecordType(List<Case> newCaseList, Map<Case, Id> caseOppty, Map<Id, Opportunity> opptyMap) {
    Schema.DescribeSObjectResult R = Case.SObjectType.getDescribe();
    List<Schema.RecordTypeInfo> caseRecordTypes = R.getRecordTypeInfos();
    Map<String, Id> caseRecordTypeMap = new Map<String, Id>();
    
    for(Schema.RecordTypeInfo rt : caseRecordTypes) {
       caseRecordTypeMap.put(rt.Name, rt.RecordTypeId); 
    }
    
    for(Case ca: newCaseList) {
      if(caseOppty.containsKey(ca) && opptyMap.containsKey(caseOppty.get(ca))) {
        if(opptyMap.get(caseOppty.get(ca)).Primary_Program__c != null) {
          ca.RecordTypeId = caseRecordTypeMap.get(opptyMap.get(caseOppty.get(ca)).Institution__c);
        }
      }
    }  
  
  }  

}