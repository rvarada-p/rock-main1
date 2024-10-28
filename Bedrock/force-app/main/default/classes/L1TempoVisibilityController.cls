/*******************************************************************
Name  : L1TempoVisibilityController 
Author: Ravitej Varada (Laureate)
Date  : April 10, 2019
Description: Controller class for L1TempoLightning App
*************************************************************************/
public without sharing class L1TempoVisibilityController {
    
    public static JsonParserL1 jsonBody = new JsonParserL1();
    
    @AuraEnabled 
    public static JsonParserL1 getDataFromL1(Id oppId) {
        if(oppId != null ) {
            opportunity Opp = [SELECT Id, Name,L1OppID__c,CBL_Student_Id__c, Contact__r.Name,Student_Program__r.IsStudentProgramActive__c,Preferred_Start_Date__c,Admissions_Status__c  from opportunity where ID = :oppId];
            string l1OppId = Opp.L1OppID__c;
            if(l1OppId != null ) {
                HttpRequest req = new HttpRequest();
                req.setEndpoint(String.format('callout:{0}',new List<String>{System.Label.L1_Visibility_Effective_Named_Credential})+'/services/data/v45.0/query/?q=SELECT+Name,id,CBL_Student_ID__c,brand_profile__c,Contact__r.name,Contact__r.Email,Product_Code__c,+(select+id,subject,description,Type__c,Status__c,Status,CreatedDate,ActivityDate+from+tasks+order+By+createddate+DESC),(select+id,subject,CreatedDate,Status,CaseNumber,Owner.name,Review_Type__c,Final_Decision__c,Comments_Notes__c+from+Cases1__r+where+subject+=+\'Recommended+Admit+-+Degree+or+Certificate\'+order+By+createddate+DESC)+from+opportunity+Where+id=\''+l1OppId+'\'');
                req.setMethod('GET');
                Http http = new Http();
                HTTPResponse res = System.Test.isRunningTest() ? Mock_HttpResponse_L1TempoVisiGetAttach.fakeOppDatafromL1() : http.send(req);
                string jsonS = res.getBody();
                System.debug(jsonS);
                jsonS = jsonS.replaceAll('__c', '_CField');
                jsonS = jsonS.replaceAll('__r', '_CField');
                
                jsonBody = (JsonParserL1)JSON.deserialize(jsonS,JsonParserL1.class);
                
                if(Opp.Student_Program__r.IsStudentProgramActive__c ) jsonBody.isStudentProgramActive = 'Active'; else  jsonBody.isStudentProgramActive = 'Inactive';
                jsonBody.preferredStartDate = opp.Preferred_Start_Date__c;
                jsonBody.admissionsStatus = opp.Admissions_Status__c;
                
                return  jsonBody;
            }  
        }
        return null;
        
    }
    
    @AuraEnabled 
    public static JsonParserL1.SOQLJSONOutputParser getRelatedAttachments(String statusValue, Decimal pageNumber ,Integer recordToDisply, String brandProfileId) {
        JsonParserL1.SOQLJSONOutputParser attachJson = new JsonParserL1.SOQLJSONOutputParser();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(String.format('callout:{0}',new List<String>{System.Label.L1_Visibility_Effective_Named_Credential})+'/services/data/v50.0/query/?q=SELECT+Name,id,Document_Type__c,Date_Received__c,Institution_Name_Text__c,Official_Indicator__c,Document_Source__c,Institution_Type__c,Document_Detail__c,(Select+Id,name+from+Attachments)+from+My_Documents__c+Where+Brand_Profile__c=\''+brandProfileId+'\'');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = System.Test.isRunningTest() ? Mock_HttpResponse_L1TempoVisiGetAttach.fakeAllAttachmentResponseOfABP() : http.send(req);
        If(res.getStatusCode() == 200){
            string jsonS = res.getBody();
            jsonS = jsonS.replaceAll('__c', '_CField');
            jsonS = jsonS.replaceAll('__r', '_CField');
            attachJson = (JsonParserL1.SOQLJSONOutputParser)JSON.deserialize(jsonS,JsonParserL1.SOQLJSONOutputParser.class); 
        }
        req.setEndpoint(String.format('callout:{0}',new List<String>{System.Label.L1_Visibility_Effective_Named_Credential})+'/services/data/v50.0/query/?q=SELECT%20ContentDocumentId,LinkedEntityId%20FROM%20ContentDocumentLink%20where%20LinkedEntityId%20IN%20(select%20Id%20from%20My_Documents__c%20where%20Brand_Profile__c=\''+brandProfileId+'\')');
        req.setMethod('GET');
        http = new Http();
        res = System.Test.isRunningTest() ? Mock_HttpResponse_L1TempoVisiGetAttach.fakeAllCDLOfABP() : http.send(req);
        If(res.getStatusCode() == 200){
            string jsonS = res.getBody();
            JsonParserL1.SOQLJSONOutputParser contentDocumentQueryJSON = (JsonParserL1.SOQLJSONOutputParser)JSON.deserialize(jsonS,JsonParserL1.SOQLJSONOutputParser.class);
            if(contentDocumentQueryJSON.records!=NULL && contentDocumentQueryJSON.records.size()>0){
                List<String> contentDocumentIds = new List<String>();
                Map<Id,Id> mapLinkedEntityIdandContentDocId = new Map<Id,Id>(); 
                for(JsonParserL1.records  rec : contentDocumentQueryJSON.records){
                    contentDocumentIds.add('\''+rec.ContentDocumentId+'\'');
                    mapLinkedEntityIdandContentDocId.put(rec.LinkedEntityId,rec.ContentDocumentId);
                }
                req = new HttpRequest();
                req.setEndpoint(String.format('callout:{0}',new List<String>{System.Label.L1_Visibility_Effective_Named_Credential})+'/services/data/v50.0/query/?q=SELECT+Id,ContentDocumentId+from+ContentVersion+where+ContentDocumentId+IN+('+String.join(contentDocumentIds,',')+')');
                req.setMethod('GET');
                http = new Http();
                res = System.Test.isRunningTest() ? Mock_HttpResponse_L1TempoVisiGetAttach.fakeCVDataOfAllCDL() : http.send(req);
                If(res.getStatusCode() == 200){
                    jsonS = res.getBody();
                    JsonParserL1.SOQLJSONOutputParser contentVersionIdQueryJSON = (JsonParserL1.SOQLJSONOutputParser)JSON.deserialize(jsonS,JsonParserL1.SOQLJSONOutputParser.class);
                    if(contentVersionIdQueryJSON.records!=NULL && contentVersionIdQueryJSON.records.size()>0){
                        List<Id> contentVersionIds = new List<Id>(); 
                        Map<Id,Id> mapContentDocIdToContentVersionId = new Map<Id,Id>();    
                        for(JsonParserL1.records  rec : contentVersionIdQueryJSON.records){
                            contentVersionIds.add(rec.Id);
                            mapContentDocIdToContentVersionId.put(rec.ContentDocumentId,rec.Id);
                        }
                        req = new HttpRequest();
                        req.setEndpoint(String.format('callout:{0}',new List<String>{System.Label.L1_Visibility_Effective_Named_Credential})+'/services/data/v50.0/composite/sobjects/ContentVersion?ids='+String.join(contentVersionIds,',')+'&fields=Id,PathOnClient,FileType');
                        req.setMethod('GET');
                        http = new Http();
                        res = System.Test.isRunningTest() ? Mock_HttpResponse_L1TempoVisiGetAttach.fakeCVData() : http.send(req);
                        If(res.getStatusCode() == 200){
                            jsonS = res.getBody();
                            List<JsonParserL1.fileInfoJson> filesData = (List<JsonParserL1.fileInfoJson>)JSON.deserialize(jsonS,List<JsonParserL1.fileInfoJson>.class); 
                            Map<Id,JsonParserL1.fileInfoJson> mapCVIdAndCV = new Map<Id,JsonParserL1.fileInfoJson>();
                            for(JsonParserL1.fileInfoJson file : filesData){
                                mapCVIdAndCV.put(file.Id,file);
                            }
                            for(JsonParserL1.records record : attachJson.records) {
                                if(mapLinkedEntityIdandContentDocId.containsKey(record.Id) && mapContentDocIdToContentVersionId.containsKey(mapLinkedEntityIdandContentDocId.get(record.Id)) && mapCVIdAndCV.containsKey(mapContentDocIdToContentVersionId.get(mapLinkedEntityIdandContentDocId.get(record.Id)))) {
                                    record.type='File';
                                    List<JsonParserL1.records> records = new List<JsonParserL1.records>();
                                    JsonParserL1.records file= new JsonParserL1.records();
                                    file.Id = mapContentDocIdToContentVersionId.get(mapLinkedEntityIdandContentDocId.get(record.Id));
                                    file.name = mapCVIdAndCV.get(mapContentDocIdToContentVersionId.get(mapLinkedEntityIdandContentDocId.get(record.Id))).PathOnClient;
                                    file.type = mapCVIdAndCV.get(mapContentDocIdToContentVersionId.get(mapLinkedEntityIdandContentDocId.get(record.Id))).FileType;
                                    records.add(file);
                                    record.Attachments=new JsonParserL1.Attachments();
                                    record.Attachments.records = records;
                                }
                                else {
                                    record.type='Attachment';
                                }
                            }
                        }
                    }
                }
            }else{
                    for(JsonParserL1.records record : attachJson.records) {
                         record.type='Attachment';
                    }
                }  
        }
        return attachJson;
    }
    
    
    @AuraEnabled 
    public static attachmentWrapper getAttachment(string attId) {
        attachmentWrapper objAttachment  = new attachmentWrapper(); 
        try{       
            JsonParserL1.attachmentInfoJson attachJson = new JsonParserL1.attachmentInfoJson();
            HttpRequest req1 = new HttpRequest();
            req1.setEndpoint(String.format('callout:{0}',new List<String>{System.Label.L1_Visibility_Effective_Named_Credential})+'/services/data/v45.0/sobjects/Attachment/'+attId); 
            req1.setMethod('GET');
            
            Http http1 = new Http();
            HTTPResponse res1 = System.Test.isRunningTest() ? Mock_HttpResponse_L1TempoVisiGetAttach.fakeSingleAttachment() : http1.send(req1);
            
            attachJson = (JsonParserL1.attachmentInfoJson)JSON.deserialize(res1.getBody(),JsonParserL1.attachmentInfoJson.class);
            HTTPResponse res;
            If(res1.getStatusCode() == 200){
                
                HttpRequest req = new HttpRequest();
                req.setEndpoint(String.format('callout:{0}',new List<String>{System.Label.L1_Visibility_Effective_Named_Credential})+attachJson.Body); 
                req.setMethod('GET');
                Http http = new Http();
                res = http.send(req);
                objAttachment.body = EncodingUtil.base64Encode( res.getBodyAsBlob());
                objAttachment.name = attachJson.Name;
                objAttachment.contentType = attachJson.ContentType;
            }
            objAttachment.calloutResponse = res1.getStatus();
            objAttachment.calloutStatusCode = res1.getStatusCode();
        }catch(Exception e){
                objAttachment.calloutResponse = e.getMessage();
                objAttachment.calloutStatusCode = 500;
        }
        return objAttachment; 
    }

    @AuraEnabled 
    public static attachmentWrapper getFile(string fileId) { 
        attachmentWrapper objAttachment  = new attachmentWrapper(); 
        try{   
            JsonParserL1.fileInfoJson fileJson = new JsonParserL1.fileInfoJson();
            HttpRequest req1 = new HttpRequest();
            req1.setEndpoint(String.format('callout:{0}',new List<String>{System.Label.L1_Visibility_Effective_Named_Credential})+'/services/data/v45.0/sobjects/ContentVersion/'+fileId); 
            req1.setMethod('GET');
            
            Http http1 = new Http();
            HTTPResponse res1 = System.Test.isRunningTest() ? Mock_HttpResponse_L1TempoVisiGetAttach.fakeSingleFile() : http1.send(req1);
            
            fileJson = (JsonParserL1.fileInfoJson)JSON.deserialize(res1.getBody(),JsonParserL1.fileInfoJson.class);
            HTTPResponse res;
            If(res1.getStatusCode() == 200){
                HttpRequest req = new HttpRequest();
                req.setEndpoint(String.format('callout:{0}',new List<String>{System.Label.L1_Visibility_Effective_Named_Credential})+fileJson.VersionData); 
                req.setMethod('GET');
                Http http = new Http();
                res = http.send(req);
                objAttachment.body = EncodingUtil.base64Encode( res.getBodyAsBlob());
                objAttachment.name = fileJson.PathOnClient;
                objAttachment.contentType = fileJson.FileType;
            }
            objAttachment.calloutResponse = res1.getStatus();
            objAttachment.calloutStatusCode = res1.getStatusCode();
        }catch(Exception e){
            objAttachment.calloutResponse = e.getMessage();
            objAttachment.calloutStatusCode = 500;
        }
        return objAttachment; 
    }
    
    public class attachmentWrapper {
        @AuraEnabled public String body {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String contentType {get;set;}
        @AuraEnabled public String calloutResponse {get;set;}
        @AuraEnabled public Integer calloutStatusCode {get;set;}
    }    
}