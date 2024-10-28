/************************************************************************
Name  : MockHttpResponse_BSCourseTemplate
Developer: Sarah Khalid, September 2017
Description: After this point, if an HTTP callout is invoked in test context, 
			 the callout is not made and you receive the mock response you 
			 specified in the respond method implementation. This class
			 is specific to the BrightSpace Create Course Template API call
*************************************************************************/

@isTest
global class MockHttpResponse_BSCourseTemplate implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
    	String url =  'callout:BS/d2l/api/lp/(version)/coursetemplates/';
 		String lpVersion =  String.valueOf(D2L__c.getValues('D2L').LP_Version__c);
		url = url.replace('(version)', lpVersion);

        //System.assertEquals(url, req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Identifier":"7034","Code":"IG001","Name":"Creativity and Innovation in Business","Path":"/content/enforced/7034-IG001/"}');
        res.setStatusCode(200);
        return res;
       
    }    
}