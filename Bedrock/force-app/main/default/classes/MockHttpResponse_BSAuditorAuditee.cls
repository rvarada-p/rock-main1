/************************************************************************
Name  : MockHttpResponse_BSAuditorAuditee
Developer: Sarah Khalid, November 2017
Description: After this point, if an HTTP callout is invoked in test context, 
			 the callout is not made and you receive the mock response you 
			 specified in the respond method implementation. This class
			 is specific to the BrightSpace Auditor Auditee Template API call
*************************************************************************/

@isTest
global class MockHttpResponse_BSAuditorAuditee implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
    	String url =  'callout:BS/d2l/api/le/(version)/auditing/auditors/500/auditees/';
 		String leVersion =  String.valueOf(D2L__c.getValues('D2L').LE_Version__c);
		url = url.replace('(version)', leVersion);

        //System.assertEquals(url, req.getEndpoint());
       // System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{}');
        res.setStatusCode(200);
        return res;
       
    }    
}