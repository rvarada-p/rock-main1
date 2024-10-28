/************************************************************************
Name  : ExceptionController
Author: Horacio Sanchez
Date  : March 19, 2021
Description: Controller that handles the general Exception Visualforce page.
			 S-45080: Tempo: Redirect students on CSRF enabled pages
*************************************************************************/
public class ExceptionController {

    public String studentProgramId {get;set;}
    public String errorString {get;set;}
    
    public ExceptionController(){
        
    }
    
    public PageReference errorAction() {
        PageReference p;
        errorString = '';
        errorString += Site.getErrorDescription();
        System.debug('Exception: ' + Site.getErrorDescription());
        for(Error_Messages_in_Portal__c errorMessage : Error_Messages_in_Portal__c.getAll().values()){
            if (errorString.containsIgnoreCase(errorMessage.Name)) {
                p = new PageReference('/apex' + Site.getOriginalUrl());
               	return p;
            }
        }
        
        return null;
    }

}