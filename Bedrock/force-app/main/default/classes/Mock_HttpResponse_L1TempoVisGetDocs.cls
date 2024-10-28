/************************************************************************
Name  : HttpResponse_L1TempoVisibilityGetDocs
Developer: Ravitej Varada - Laureate
Date: April 5th, 2018
Description: This class is to create Fake HTTP Response for HttpResponse_L1TempoVisibilityGetDocs
			code = 202
*************************************************************************/

@isTest
global class Mock_HttpResponse_L1TempoVisGetDocs implements HttpCalloutMock {

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"totalSize":2,"done":true,"records":[{"attributes":{"type":"My_Documents__c","url":"/services/data/v45.0/sobjects/My_Documents__c/a1t1N000006fTXFQA2"},"Name":"MD-1928944","Id":"a1t1N000006fTXFQA2","Document_Type__c":"Unofficial Transcript","Date_Received__c":"2018-04-03","Institution_Name_Text__c":"Punjab University Law College Lahore","Official_Indicator__c":false,"Document_Source__c":"Imported","Institution_Type__c":null,"Document_Detail__c":"5.jpg","Attachments":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Attachment","url":"/services/data/v45.0/sobjects/Attachment/00P1N00000cLIMSUA4"},"Id":"00P1N00000cLIMSUA4","Name":"5.jpg"}]}},{"attributes":{"type":"My_Documents__c","url":"/services/data/v45.0/sobjects/My_Documents__c/a1t1N000006fTXUQA2"},"Name":"MD-1928947","Id":"a1t1N000006fTXUQA2","Document_Type__c":"Resume","Date_Received__c":"2018-04-03","Institution_Name_Text__c":null,"Official_Indicator__c":false,"Document_Source__c":"Imported","Institution_Type__c":null,"Document_Detail__c":"Abuzar CV Updated_2.pdf","Attachments":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Attachment","url":"/services/data/v45.0/sobjects/Attachment/00P1N00000cLIOEUA4"},"Id":"00P1N00000cLIOEUA4","Name":"Abuzar CV Updated_2.pdf"}]}}]}');
        res.setStatusCode(200);
        return res;
       
    }    
    
}