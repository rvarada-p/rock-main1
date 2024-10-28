/************************************************************************
Name  : HttpResponse_L1TempoVisibilityCaseTask
Developer: Ravitej Varada - Laureate
Date: April 5th, 2018
Description: This class is to create Fake HTTP Response for HttpResponse_L1TempoVisibilityCaseTask
			code = 202
*************************************************************************/

@isTest
global class Mock_HttpResponse_L1TempoVisCaseTask implements HttpCalloutMock {

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Opportunity","url":"/services/data/v45.0/sobjects/Opportunity/0061N00000WIVtbQAH"},"Name":"Abuzar Ghafari - MS in Criminal Justice - Law & Public Policy","Id":"0061N00000WIVtbQAH","CBL_Student_ID__c":null,"Brand_Profile__c":"a1V1N000007yQJWUA2","Contact__r":{"attributes":{"type":"Contact","url":"/services/data/v45.0/sobjects/Contact/0031N00001QbiprQAB"},"Name":"Abuzar Ghafari","Email":"rana.abuzar@hotmail.com"},"Product_Code__c":"MS in Criminal Justice - Law & Public Policy","Tasks":{"totalSize":2,"done":true,"records":[{"attributes":{"type":"Task","url":"/services/data/v45.0/sobjects/Task/00T1N00003DTitrUAD"},"Id":"00T1N00003DTitrUAD","Subject":"Auto-generated debug task by NextStartDate Update Batch","Description":"OPPORTUNITY UPDATE SUCCESS:https://laureateone.my.salesforce.com/0061N00000WIVtbQAH","Type__c":null,"Status__c":null,"Status":"Completed","CreatedDate":"2018-12-20T10:41:19.000+0000","ActivityDate":"2018-12-20"},{"attributes":{"type":"Task","url":"/services/data/v45.0/sobjects/Task/00T1N000032kHJRUA2"},"Id":"00T1N000032kHJRUA2","Subject":"Auto-generated debug task by NextStartDate Update Batch","Description":"OPPORTUNITY UPDATE SUCCESS:https://laureateone.my.salesforce.com/0061N00000WIVtbQAH","Type__c":null,"Status__c":null,"Status":"Completed","CreatedDate":"2018-10-26T00:04:14.000+0000","ActivityDate":"2018-10-25"}]},"Cases1__r":null}]}');
        res.setStatusCode(200);
        return res;
       
    }    
    
}