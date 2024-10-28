/************************************************************************
Name  : MockHttpResponseChatter
Developer: Sarah Khalid, Jan 2017
Description: After this point, if an HTTP callout is invoked in test context, 
			 the callout is not made and you receive the mock response you 
			 specified in the respond method implementation.
*************************************************************************/

@isTest
global class MockHttpResponseChatter implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
    	String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
    	String url =  salesforceHost + '/services/data/v26.0/chatter/users/me/messages/';

        System.assertEquals(url, req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "body" : "Test Chatter Message","recipients" : ["005D0000001GOYpIAO", "005D0000001GbdHIAS"]}');
        res.setStatusCode(201);
        return res;
    }
}