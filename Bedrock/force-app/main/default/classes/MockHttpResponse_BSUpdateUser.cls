/************************************************************************
Name  : MockHttpResponse_BSUpdateUser
Developer: Sarah Khalid, November 2017
Description: After this point, if an HTTP callout is invoked in test context, 
			 the callout is not made and you receive the mock response you 
			 specified in the respond method implementation. This class
			 is specific to the BrightSpace Update User API call
*************************************************************************/

@isTest
global class MockHttpResponse_BSUpdateUser implements HttpCalloutMock {

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
    	String url =  'callout:BS/d2l/api/lp/(version)/users/103';
 		String lpVersion =  String.valueOf(D2L__c.getValues('D2L').LP_Version__c);
		url = url.replace('(version)', lpVersion); 
		        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String response = '{"OrgId":6606,"UserId":306,"FirstName":"Test","MiddleName":"","LastName":"Test","UserName":"test1@test.com","ExternalEmail":"test1@test.com","OrgDefinedId":"","UniqueIdentifier":"test1@test.com","Activation":{"IsActive":true},"DisplayName":"Test test"}';
        res.setBody(response);
        res.setStatusCode(200);
        return res;
       
    }  
    
}