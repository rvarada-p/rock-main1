@istest
public class HmacSHA256Encryption_Test {

    static testMethod void testlanding() {
        
       string saltValue = 'testhmacHash';
        Community_Site_Settings__c defaultCustomSetngs = new Community_Site_Settings__c();
        defaultCustomSetngs.Name = 'Default Settings';
        defaultCustomSetngs.Intercom_Secret_Key__c = 'U8BjsjJnasonsauho32873ashj783HHBS';
        insert defaultCustomSetngs;
       string hashValue =  HmacSHA256Encryption.generateHmacSHA256Signature(saltValue);
        
    }
}