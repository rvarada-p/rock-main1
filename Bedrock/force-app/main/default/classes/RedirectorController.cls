/**************************************************************************************
Apex Class Name     : RedirectorController
Created Date        : 16th October 2019
Function            : Controller class for Redirector Page
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ravitej Varada            10/16/2019                Original Version
*
* Revision History
* Horacio Sanchez   11/18/2020     S-28164: WAS Accelerated Scan: Cross-Site Request Forgery
*************************************************************************************/
public with sharing class RedirectorController {
    public RedirectorController(ApexPages.StandardController controller) {
    }
    
    private boolean redirectToUndergradView(String programCode) {
        Set<String> gradProgramsForGenEdSet = new Set<string>();
        for(Grad_Programs_for_GenEd_and_GenElective__c gradPrograms : Grad_Programs_for_GenEd_and_GenElective__c.getAll().values()){
            gradProgramsForGenEdSet.add(gradPrograms.Name);
        }
        
        if (gradProgramsForGenEdSet.contains(programCode)) {
            return true;
        }
        return false;
    }
    public pagereference redirect(){
        String studentProgramId = ApexPages.currentPage().getParameters().get('id');
        
        student_program__c sp = [select id,program__r.degree_level__c, Program__r.ProductCode from student_program__C where id =:studentProgramId limit 1];
        if(sp.program__r.Degree_Level__c == 'Undergrad'){
            pagereference page = new pagereference('/apex/DegreeAudit?id='+studentProgramId);
            page.setRedirect(true);
            return page;            
        }else {
            if (redirectToUndergradView(sp.Program__r.ProductCode)) {
                pagereference page = new pagereference('/apex/DegreeAudit?id='+studentProgramId);
                page.setRedirect(true);
                return page; 
            }
            pagereference page = new pagereference('/apex/DegreeAuditGR?id='+studentProgramId);
            page.setRedirect(true);
            return page;            
        }        
        
    }
    
    
}