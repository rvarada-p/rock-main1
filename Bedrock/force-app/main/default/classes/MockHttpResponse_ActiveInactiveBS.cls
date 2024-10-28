/************************************************************************
Name  : MockHttpResponse_IntercomApi
Developer: Ravitej Varada - Laureate
Date: April 5th, 2018
Description: This class is to create Fake HTTP Response for intercom- status
            code = 200
*************************************************************************/

@isTest
global class MockHttpResponse_ActiveInactiveBS implements HttpCalloutMock {

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"OrgUnitId":7501,"UserId":264,"RoleId":114}');
        res.setStatusCode(200);
        return res;
       
    }    
    
}