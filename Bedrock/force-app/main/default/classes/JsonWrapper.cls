/*******************************************************************
Name  : JsonWrapper
Author: Sarah Khalid - Laureate
Date  : September 21, 2017
Description: Helper  class for creating and returning various JSON 
			 blocks for integration with BrightSpace LMS
*************************************************************************/

public with sharing class JsonWrapper {
	
	//This method returns a JSON block for creating an Area of Expertise in BrightSpace  
	public String createOrgUnitCreateData(decimal orgUnitType, String name, String code, list<decimal> parentIds) {
		JSONGenerator g = JSON.createGenerator(false);
        g.writeStartObject();
        g.writeNumberField('Type', orgUnitType);      
        g.writeStringField('Name', name);
        g.writeStringField('Code', code);
        g.writeObjectField('Parents', parentIds);   
        g.writeEndObject();
       return g.getAsString();		
	}
   
   //This method returns the "Identifier" created in BrightSpace for a number of API calls  
    public String returnOrgUnitCreateData(String jsonResponse) {
    	String identifier = '';
  		JSONParser parser = JSON.createParser(jsonResponse);
        while (parser.nextToken() != null && identifier == '') {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'Identifier')) {
	             parser.nextToken();
                 identifier = parser.getText();
                 System.debug('Identifier: ' + identifier);
            }
        }
        return identifier;  	
    }
 
   //This method returns the "UserId" created in BrightSpace for a number of API calls  
    public Integer returnUserData(String jsonResponse) {
    	Integer userId;
  		JSONParser parser = JSON.createParser(jsonResponse);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'UserId')) {
	             parser.nextToken();
                 userId = parser.getIntegerValue();
                 System.debug('UserId: ' + userId);
            }
        }
        return userId;  	
    }
    
    //This method returns a JSON block for creating a Cource Template in BrightSpace  
	public String createCreateCourseTemplate(String name, String code, list<decimal> parentIds) {
		JSONGenerator g = JSON.createGenerator(false);
        g.writeStartObject();  
        g.writeStringField('Name', name);
        g.writeStringField('Code', code);
        g.writeStringField('Path', '');
        g.writeObjectField('ParentOrgUnitIds', parentIds);   
        g.writeEndObject();
       return g.getAsString();		
	}   
	
	//This method returns a JSON block for creating a Competency Shell in BrightSpace  
	public String createCreateCompetencyShell(String name, String code, Decimal courseTemplateId) {
		JSONGenerator g = JSON.createGenerator(false);
        g.writeStartObject();  
        g.writeStringField('Name', name);
        g.writeStringField('Code', code);
        g.writeStringField('Path', '');
        g.writeNumberField('CourseTemplateId', courseTemplateId);   
        g.writeNullField('SemesterId');
        g.writeNullField('StartDate');
        g.writeNullField('EndDate');
        g.writeNullField('LocaleId');
        g.writeBooleanField('ForceLocale', false);
        g.writeBooleanField('ShowAddressBook', true);
        g.writeEndObject();
        return g.getAsString();		
	} 
	
	//This method returns a JSON block for creating a User in BrightSpace  
	public String createUser(String orgUnitType, String firstName, String lastName, String emailAddress, Decimal roleId, boolean sendCreationEmail) {
		JSONGenerator g = JSON.createGenerator(false);
        g.writeStartObject();
        g.writeStringField('OrgDefinedId', orgUnitType);      
        g.writeStringField('FirstName', firstName);
        g.writeStringField('MiddleName', '');
        g.writeStringField('LastName', lastName);
        g.writeStringField('ExternalEmail', emailAddress);
        g.writeStringField('UserName', emailAddress);   
        g.writeNumberField('RoleId', roleId); 
        g.writeBooleanField('IsActive', true);
        g.writeBooleanField('SendCreationEmail', sendCreationEmail);
        g.writeEndObject();
       return g.getAsString();		
	}	     

    //This method returns a JSON block for creating a User in BrightSpace  
    public String createUser(Decimal orgUnitType, String firstName, String lastName, String emailAddress, Decimal roleId, boolean sendCreationEmail) {
        JSONGenerator g = JSON.createGenerator(false);
        g.writeStartObject();
        //g.writeStringField('OrgDefinedId', orgUnitType);      
        g.writeStringField('FirstName', firstName);
        g.writeStringField('MiddleName', '');
        g.writeStringField('LastName', lastName);
        g.writeStringField('ExternalEmail', emailAddress);
        g.writeStringField('UserName', emailAddress);   
        g.writeNumberField('RoleId', roleId); 
        g.writeBooleanField('IsActive', true);
        g.writeBooleanField('SendCreationEmail', sendCreationEmail);
        g.writeEndObject();
       return g.getAsString();      
    }
    
  

	//This method returns a JSON block for updating a User in BrightSpace  
	public String updateUser(String studentId, String firstName, String lastName, String email) {
		JSONGenerator g = JSON.createGenerator(false);
        g.writeStartObject();
        g.writeStringField('OrgDefinedId', studentId);    
        g.writeStringField('FirstName', firstName);
        g.writeStringField('MiddleName', '');
        g.writeStringField('LastName', lastName);
        g.writeStringField('ExternalEmail', email);
        g.writeStringField('UserName', email);   
        g.writeFieldName('Activation');
        g.writeStartObject();
        g.writeBooleanField('IsActive', true);
        g.writeEndObject();
        g.writeEndObject();
       return g.getAsString();		
	}
    
    //This method returns a JSON block for updating a User in BrightSpace  
	public String updateUser(String studentId, String firstName, String lastName, String email, boolean isActive) {
		JSONGenerator g = JSON.createGenerator(false);
        g.writeStartObject();
        if( String.isNotBlank(studentId))
        	g.writeStringField('OrgDefinedId', studentId);
        if( String.isNotBlank(firstName))
        	g.writeStringField('FirstName', firstName);
        
        g.writeStringField('MiddleName', '');
        if( String.isNotBlank(lastName))
        	g.writeStringField('LastName', lastName);
        if( String.isNotBlank(email))
        	g.writeStringField('ExternalEmail', email);
        if( String.isNotBlank(email))
			g.writeStringField('UserName', email);   
        g.writeFieldName('Activation');
        g.writeStartObject();
        g.writeBooleanField('IsActive', isActive);
        g.writeEndObject();
        g.writeEndObject();
       return g.getAsString();		
	}
	
	public String createEnrollmentData(Decimal orgUnitId, Decimal userId, Decimal roleId) {
		JSONGenerator g = JSON.createGenerator(false);
        g.writeStartObject();
        g.writeNumberField('OrgUnitId', orgUnitId);      
		g.writeNumberField('UserId', userId);
		g.writeNumberField('RoleId', roleId);
		g.writeEndObject();
		return g.getAsString();
	}
	/*
	//This method returns a JSON block for creating an Area of Expertise in BrightSpace  
	public String createAuditeeIdData(decimal auditeeId) {
		JSONGenerator g = JSON.createGenerator(false);
        g.writeStartObject();
        g.writeNumber(auditeeId);      
        g.writeEndObject();
       return g.getAsString();		
	}
	*/
}