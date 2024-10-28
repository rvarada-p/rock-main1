/************************************************************************
Name  : Mock_HttpResponse_SMEAssignment
Developer: Ravitej Varada - Laureate
Date: April 5th, 2018
Description: This class is to create Fake HTTP Response for Mock_HttpResponse_SMEAssignment
			code = 202
*************************************************************************/

@isTest
global class Mock_HttpResponse_SMEAssignment implements HttpCalloutMock {

    // Implement this interface method 
    global HTTPResponse respond(HTTPRequest req) {

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{}');
        res.setStatusCode(200);
        return res;
       
    }    
    
}