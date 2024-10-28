public with sharing class DocumentHoldHelper {
    
    public Integer totalNumberOfSuccess;
    public Integer totalNumberOfFailure;

    public DocumentHoldHelper() {

    }

    public void applyDocumentHolds(List<Student_Program__c> lstStudentProgram) {
        totalNumberOfSuccess = 0;
        totalNumberOfFailure = 0;
        Id documentHoldCodeId;
        List<Student_Hold_Code__c> lstStudentHoldCodes = new List<Student_Hold_Code__c>();
        List<Hold_codes__c> lstHoldCodes = new List<Hold_codes__c>([SELECT Id FROM Hold_codes__c WHERE Name = 'DH']);
        
        if (lstHoldCodes.size() > 0) {
            documentHoldCodeId = lstHoldCodes[0].Id;
        }

        for (Student_Program__c sp : lstStudentProgram) {
            Student_Hold_Code__c studentHoldCode = new Student_Hold_Code__c();
            studentHoldCode.Hold_Code__c = documentHoldCodeId;
            studentHoldCode.Student_Program__c = sp.Id;
            lstStudentHoldCodes.add(studentHoldCode);
        }
        System.debug('Student Hold Codes to be inserted: ' + lstStudentHoldCodes);
        
        if (lstStudentHoldCodes.size() > 0) {
            Set<Id> failureIdsSet;
            Database.SaveResult[] srList = Database.insert(lstStudentHoldCodes, false);
            
            // Iterate through each returned result 
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('*****: ' + 'Fields: ' + err.getFields() + ', Status Code: ' + err.getStatusCode() + ': ' + err.getMessage());                        
                    }
                }
            }
        }
        
    }

    public void removeDocumentHolds(List<Student_Program__c> lstStudentProgram) {
        totalNumberOfSuccess = 0;
        totalNumberOfFailure = 0;
        Id documentHoldCodeId;
        List<Id> lstSPIds = new List<Id>();
        List<Hold_codes__c> lstHoldCodes = new List<Hold_codes__c>([SELECT Id FROM Hold_codes__c WHERE Name = 'DH']);
        
        if(lstHoldCodes.size()>0) {
            documentHoldCodeId = lstHoldCodes[0].Id;
        }

        for (Student_Program__c sp : lstStudentProgram) {
            lstSPIds.add(sp.Id);
        }

        List<Student_Hold_Code__c> lstToUpdate = new List<Student_Hold_Code__c>();
        List<Student_Hold_Code__c> lstStudentHoldCodes = new List<Student_Hold_Code__c>([SELECT Id FROM Student_Hold_Code__c WHERE Student_Program__c IN :lstSPIds AND Hold_Close_Date__c = null AND Hold_Code__c = :documentHoldCodeId]);
        
        for(Student_Hold_Code__c shc : lstStudentHoldCodes) {
            shc.Hold_Close_Date__c = System.today();
            lstToUpdate.add(shc);
        }
        
        update lstToUpdate; 

        System.debug('Bursar Hold codes to be removed : '  + lstStudentHoldCodes);

    }
  
}