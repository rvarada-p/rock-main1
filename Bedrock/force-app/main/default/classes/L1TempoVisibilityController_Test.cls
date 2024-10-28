@istest
public class L1TempoVisibilityController_Test {
    public static JsonParserL1 jsonBody = new JsonParserL1();
    
    static testMethod void testMethod1(){
        Account acc = TestDataGenerator.createAccount(true);
        Contact testCon = TestDataGenerator.createContact(acc, true);
        Product2 parentProduct = TestDataGenerator.createProduct('test', 'Walden', true);
        Product2 product2 = TestDataGenerator.createProduct('test', 'Walden', false);
        product2.Parent_Program__c = parentProduct.Id;
        insert product2;
        Product2 prod = TestDataGenerator.createProduct('test', 'Walden', true);
        Opportunity opp = TestDataGenerator.createOpportunity(acc.Id, testCon.Id, 'Walden', false);
        opp.Primary_Program__c = Product2.Id;
        opp.L1OppID__c ='0064F0000039l9U';
        insert opp;
        
        Student_Program__c sProg = TestDataGenerator.createStudentProgram(opp, testCon.Id, 'Walden', false);
        sProg.IsStudentProgramActive__c = true;
        sProg.GPA__c = null;
        insert sProg;
        
        Test.StartTest();
        L1TempoVisibilityController cnt = new L1TempoVisibilityController();
        JsonParserL1 jsonBody =L1TempoVisibilityController.getDataFromL1(opp.id);
        JsonParserL1.SOQLJSONOutputParser jsonBodyAttachments =L1TempoVisibilityController.getRelatedAttachments('', 1 ,10, '0094F0000039l9U');
        L1TempoVisibilityController.attachmentWrapper attachBodyAttac =L1TempoVisibilityController.getAttachment('0094F0000039l9U');
        L1TempoVisibilityController.attachmentWrapper fileBodyAttac =L1TempoVisibilityController.getfile('0687f0000015WhQ');
        Test.StopTest();         
    }
}