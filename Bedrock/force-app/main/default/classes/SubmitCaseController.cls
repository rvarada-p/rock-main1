public class SubmitCaseController {

    public SubmitCaseController(ApexPages.StandardController controller) {

    }


    public PageReference cancel() {
        PageReference newocp1 = new PageReference('https://laureate.my.salesforce.com/');
       return newocp1;
    }


    public Contact cont {get;set;}
    
    public Case ca {get; set;}
    
 
    public SubmitCaseController(){
    
    ca = new Case(
     RecordTypeId ='012o00000019vL8AAI');
           }

     public PageReference submitCase() {
               
               
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule = true;
        ca.setOptions(dmlOpts);
        
                INSERT ca;       
                
                      
           

       PageReference newocp = new PageReference('/'+ca.Id);
       return newocp;

                }
               
            }