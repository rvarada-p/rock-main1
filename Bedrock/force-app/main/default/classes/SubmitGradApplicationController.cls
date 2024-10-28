public class SubmitGradApplicationController  {

   
   
    public Graduation_Application__c ga {get;set;}
    
    public String cblId { get; set; }
    
   // public String Wemail { get; set; }
     
     
    //public Student_Program__c sp {get;set;}

    /*   
    public SubmitGradApplicationController() {
    
     //ga = new Graduation_Application__c();
     
    }
    */

    public SubmitGradApplicationController(ApexPages.StandardController controller) {
      System.debug('In Constructor');
      ga = (Graduation_Application__c)controller.getRecord();
      System.debug('Grad Application : ' + ga);       
       
    }

    
    public PageReference cancel() {
        PageReference newocp1 = new PageReference('/apex/Thank_you_Page');
       return newocp1;
    }
    
   
    
      
    public PageReference submitForm() {
     Student_Program__c sp = new Student_Program__c();
     PageReference pageRef;
    
     try{
           List<Student_Program__c> StuProg = [Select Id from Student_Program__c 
                 WHERE  
                 Student_Status__c = 'Active' AND
                 Graduation_Application_Submitted__c = FALSE AND
                 Cbl_Id__c = :cblId];
            // If List is not Empty then assign First SP id to Student_Program Field of Grad App     
            if(!StuProg.isEmpty()) {
               ga.Student_Program_Name__C = StuProg.get(0).Id;  
               //ga.Walden_Email_Address__c = Wemail+'waldenu.edu';  
               ga.Student_Id_Number__c = cblId; 
               INSERT ga;    
               pageRef = new PageReference('/apex/Thank_you_Page');
               pageRef.setRedirect(true);           
           }
           else {
             
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Student Data'));
               pageRef =  null;
           
            }   
                /*
                if(Smsg){
                PageReference pageRef = new PageReference('/apex/Thank_you_Page');
                pageRef.setRedirect(true);
                return pageRef;
                 }   
                 */
               //save();
              // System.debug('Successfully Inserted'+ ga.Id);
        }catch(exception exp) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, exp.getMessage()));
            pageRef = null;
        }
        
     
     return pageRef;
     
     }
   
    
    
 }