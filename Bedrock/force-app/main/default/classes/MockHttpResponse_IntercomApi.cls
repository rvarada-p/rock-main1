/************************************************************************
Name  : MockHttpResponse_IntercomApi
Developer: Ravitej Varada - Laureate
Date: April 5th, 2018
Description: This class is to create Fake HTTP Response for intercom- status
			code = 200
*************************************************************************/

@isTest
global class MockHttpResponse_IntercomApi implements HttpCalloutMock {

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
    	/*String url =  'callout:BS/d2l/api/lp/(version)/enrollments/';
 		String lpVersion =  ;
		url = url.replace('(version)', lpVersion);

        System.assertEquals(url, req.getEndpoint());
        System.assertEquals('POST', req.getMethod());*/
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"OrgUnitId":7501,"UserId":264,"RoleId":114}');
        res.setStatusCode(200);
        return res;
       
    }    
    
}