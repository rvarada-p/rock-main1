/**************************************************************************************
Apex Class Name     : PortalRedirectController
Created Date        : August 31, 2020
Function            : Controller class to redirect to Tempo Portal
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ravitej Varada            08/31/2020                Original Version
*************************************************************************************/
public class PortalRedirectController {
    public PortalRedirectController(ApexPages.StandardController controller) { }
    
    public PageReference redirect(){
        String studentProgramId = ApexPages.currentPage().getParameters().get('id');
        String openedDay = ApexPages.currentPage().getParameters().get('day');
    	PageReference page = new PageReference('https://mytempo.waldenu.edu');
        page.setRedirect(true);
        Task tk = new Task();
        tk.Subject = 'Non-Engagement Email Activity';
        tk.ActivityDate = Date.today();
        tk.Description = 'Opened Login page through Non-Engagement email sent on ' + openedDay + 'th Day';
        tk.Status = 'Completed';
        tk.Priority = 'Normal';
        tk.WhatId = studentProgramId;
        insert tk;
        return page;   
    }
}