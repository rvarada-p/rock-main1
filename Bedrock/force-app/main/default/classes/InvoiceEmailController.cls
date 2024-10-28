/************************************************************************
Name  : InvoiceEmailController 
Author: Dirk (Appirio)
Date  : Jan, 2015
Discription: Conroller for the InvoiceEmailComponent,
(used in the Invoice VF Email template and CBL Invoice VF page)

Revision History 
Horacio Sanchez - 11/03/2020 - S-23006: Update Invoice Date on both Generate Invoice and Email Invoice VF pages to refer to Student Subscription Created Date
Sufia  -07/20/2021 : - S-685961 : converting constructor to get/set for reusability
Horacio Sanchez	- 08/16/2021 - S-58882: L2: Trigger Automatic Email invoice when Student Subscription is Manually created
*************************************************************************/

public class InvoiceEmailController {
    public Id studentSubId {get; set;}    
	public decimal futureBalance {get; set;}    
    public date futureTermStartDate {get; set;} 
    public boolean isFuture { get; set; }
    public boolean isCurrentSub { get; set; }
    public PriceBookEntry pbEntry {get;set;}
    public string studentFacultyPortalSso { get; set; }
    public Datetime createdDateEST {get;set;}
	
    public Id stuSubId {
        get{
            if(stuSubId==NULL){
            	stuSubId = ApexPages.currentPage().getParameters().get('id');
                if(String.isBlank(stuSubId))
                    stuSubId=studentSubId;
            }
            return stuSubId;
        }
        private set;
    }
    public Student_Subscription__c stuSub { 
        get{
            if(stuSub==NULL){
                futureBalance = 0;
                String tempObjectType = '' + stuSubId.getsObjectType();
                if (tempObjectType.equals('Student_Program__c')) {
                    stuSubId = [SELECT Id FROM Student_Subscription__c WHERE Student_Program__c = :stuSubId ORDER BY CreatedDate DESC LIMIT 1].Id;
                }
                stuSub = [ select Total_Grant_special_refund_to_student__c,Student_Program__r.Student__r.Name,
                          Student_Program__r.Student__r.CBL_Student_ID__c,
                          Student_Program__r.Sponsor_Billing__c,
                          Student_Program__r.Student__r.MailingStreet,
                          Student_Program__r.Student__r.MailingCity,
                          Student_Program__r.Student__r.MailingState,
                          Student_Program__r.Student__r.MailingPostalCode,
                          Student_Program__r.Student__r.MailingCountry,
                          Student_Program__r.Program__r.Name,
                          Student_Program__r.Program__r.Parent_Program_Name__c,
                          Student_Program__r.Outstanding_Balance_Minus_Future__c,
                          Student_Program__r.Total_Outstanding_Balance__c,
                          Student_Program__r.Learner_Outcome__c,
                          Student_Program__r.BK_Hold_Code__c, 
                          Student_Program__c,
                          Student_Program__r.Current_Student_Subscription__c,
                          Student_Program__r.Current_Student_Subscription__r.Current_Subscription_Balance__c,
                          Name,
                          Start_Date__c,
                          End_Date__c,
                          List_Price__c,
                          Total_Discount_1__c,
                          Subscription_Price__c,
                          Total_Payments_Received__c,
                          Total_Miscellaneous_Adjustment__c,
                          Total_Refund__c,
                          Total_Sponsorship_Amount__c,
                          Current_Subscription_Balance__c,
                          Invoice_Notes__c,
                          Future_Term__c,
                          Days_Past_Due__c,
                          Total_Grant_Scholarship__c,
                          Term_Price_Book__c,
                          CreatedDate
                          FROM Student_Subscription__c WHERE Id = :stuSubId LIMIT 1];
                List<Student_Subscription__c> futureStuSubLst = new List<Student_Subscription__c>(); 
                futureStuSubLst = [Select Student_Program__r.Student__r.Name, Student_Program__r.Outstanding_Balance_Minus_Future__c, Student_Program__r.Total_Outstanding_Balance__c,
                                   Name,
                                   Start_Date__c,
                                   End_Date__c,
                                   Current_Subscription_Balance__c
                                   FROM Student_Subscription__c WHERE  Student_Program__c =: StuSub.Student_Program__c  AND Future_Term__c = True LIMIT 1];
                
                isFuture = StuSub.Future_Term__c;
                
                
                Community_Site_Settings__c defaultCustomSetngs = Community_Site_Settings__c.getValues('Default Settings');
                if( defaultCustomSetngs != null ) {
                    if(defaultCustomSetngs.Student_Financial_Portal_Sso__c != null){
                        studentFacultyPortalSso = defaultCustomSetngs.Student_Financial_Portal_Sso__c;
                    }
                }
                        
                try {
                    pbEntry = [SELECT Name, Product2.id, Product2.Name, Product2.ProductCode, PriceBook2.Name, Tuition__c ,Tech_Fee__c, Pricebook2.id
                               FROM PriceBookEntry
                               WHERE Product2.Name =: StuSub.Student_Program__r.Program__r.Parent_Program_Name__c AND Pricebook2.id =: StuSub.Term_Price_Book__c
                               LIMIT 1];    
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }        
                
                If(futureStuSubLst.size() > 0 && !futureStuSubLst.IsEmpty()){
                    futureBalance = futureStuSubLst[0].Current_Subscription_Balance__c;
                    futureTermStartDate = futureStuSubLst[0].Start_Date__c;
                }
                
                if(stuSubId == StuSub.Student_Program__r.Current_Student_Subscription__c){
                    isCurrentSub = true;
                }
                
                if(StuSub.Student_Program__r.Learner_Outcome__c > 0 && StuSub.Days_Past_Due__c<=0) {
                    ApexPages.addMessage(new ApexPages.Message(
                        ApexPages.Severity.FATAL
                        ,'Student is pending Graduation. Future billing suppressed.'
                    ));     
                }
                
                if(StuSub.Student_Program__r.Sponsor_Billing__c == true && StuSub.Days_Past_Due__c<60)
                {
                    ApexPages.addMessage(new ApexPages.Message(
                        ApexPages.Severity.FATAL
                        ,'Sponsor Billing Student – Do not invoice student directly!'
                    ));
                }  
                
                if(StuSub.Student_Program__r.BK_Hold_Code__c == true) {
                    ApexPages.addMessage(new ApexPages.Message(
                        ApexPages.Severity.FATAL
                        ,'Student has BK hold - Do not invoice!'
                    ));     
                }
                // S-23006 - Converting createdDate to EST Timezone
                String createdDateESTString = stuSub.CreatedDate.format('yyyy-MM-dd HH:mm:ss', 'EST');
                createdDateEST = Date.valueOf(createdDateESTString);
            }
            return stuSub;
        }
        private set;
    }
    
    public List<Student_Transaction__c> stuTrans {
        get{
            if(stuTrans==NULL){
                stuTrans = new List<Student_Transaction__c>();
                stuTrans = [SELECT Transaction_Date__c, Transaction_Type__c, Transaction_Note__c, Payment_Amount__c, Refund_Amount__c,
                           Miscellaneous_Adjustment__c, Discount_Amount__c, Grant_Scholarship_Amount__c
                           FROM Student_Transaction__c WHERE Student_Subscription__c = :stuSubId
                           AND Transaction_Type__c NOT IN ('Refund - Tuition')
                           ORDER BY Transaction_Date__c];
            }
            return stuTrans;
        }
        private set;
    }
}