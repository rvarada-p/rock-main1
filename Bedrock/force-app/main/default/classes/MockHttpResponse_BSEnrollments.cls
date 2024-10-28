/************************************************************************
Name  : MockHttpResponse_BSEnrollments
Developer: Sarah Khalid - Laureate
Date: October 16, 2017
Description: After this point, if an HTTP callout is invoked in test context, 
			 the callout is not made and you receive the mock response you 
			 specified in the respond method implementation. This class
			 is specific to the BrightSpace Enrollment  API call
*************************************************************************/

@isTest
global class MockHttpResponse_BSEnrollments implements HttpCalloutMock {

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
    	String url =  'callout:BS/d2l/api/lp/(version)/enrollments/';
 		String lpVersion =  String.valueOf(D2L__c.getValues('D2L').LP_Version__c);
		url = url.replace('(version)', lpVersion);

        System.assertEquals(url, req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"OrgUnitId":7501,"UserId":264,"RoleId":114}');
        res.setStatusCode(200);
        return res;
       
    }    
    
}