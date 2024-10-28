/************************************************************************
Name  : MockHttpResponse_BsOrgUnit
Developer: Ravitej Varada, Feb 2020
Description: After this point, if an HTTP callout is invoked in test context, 
			 the callout is not made and you receive the mock response you 
			 specified in the respond method implementation. This class
			 is specific to the BrightSpace Create Org Unit API call
*************************************************************************/

@isTest
global class MockHttpResponse_BsOrgUnit implements HttpCalloutMock {

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
   
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String response = '{"Identifier":"17934","Name":"M.S. in Testology 6","Code":"C_TEST6","Type":{"Id":102,"Code":"Program","Name":"Program"}}';
        res.setBody(response);
        res.setStatusCode(200);
        return res;
       
    }  
    
}