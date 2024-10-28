/************************************************************************
Name  : MockHttpResponse_BSAPI
Developer: Sarah Khalid, September 2017
Description: After this point, if an HTTP callout is invoked in test context, 
			 the callout is not made and you receive the mock response you 
			 specified in the respond method implementation.
*************************************************************************/

@isTest
global class MockHttpResponse_BSAPI implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
    	String url =  'callout:BS/d2l/api/lp/(version)/orgstructure/';
 		String lpVersion =  String.valueOf(D2L__c.getValues('D2L').LP_Version__c);
		url = url.replace('(version)', lpVersion);

        System.assertEquals(url, req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Identifier":"7032","Name":"Developing People and Leading Teams (EDUC 6166)","Code":"EDUC6166","Type":{"Id":101,"Code":"Area of Expertise","Name":"Area of Expertise"}}');
        res.setStatusCode(200);
        return res;
       
    }
}