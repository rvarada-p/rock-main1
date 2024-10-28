/************************************************************************
Name  : Mock_HttpResponse_SMEAssignment
Developer: Ravitej Varada - Laureate
Date: April 5th, 2018
Description: This class is to create Fake HTTP Response for Mock_HttpResponse_SMEAssignment
			code = 202
*************************************************************************/

@isTest
global class Mock_HttpResponse_SMEAssignment_400 implements HttpCalloutMock {

    // Implement this interface method 
    global HTTPResponse respond(HTTPRequest req) {

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"SectionId":18392,"Name":"Section 1","Description":{"Text":"","Html":""},"Enrollments":[]}');
        res.setStatusCode(400);
        return res;
       
    }    
    
}