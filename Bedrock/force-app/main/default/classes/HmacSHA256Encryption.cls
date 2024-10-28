/*******************************************************************
Name  : HmacSHA256Encryption 
Author: Ravitej Varada (Laureate)
Date  : March 4th, 2018
Description: This class returns the Hmac SHA-256 Hex Hash encryption for a string
			 * SecretKeyValue is pre coded for Intercom Widget Identity Verification
*************************************************************************/
Public with sharing class HmacSHA256Encryption {

    public static string generateHmacSHA256Signature(String saltValue) {
       Community_Site_Settings__c defaultCustomSetngs = Community_Site_Settings__c.getValues('Default Settings');
       string secretKeyValue = defaultCustomSetngs.Intercom_Secret_Key__c ;
       String algorithmName = 'HmacSHA256';
       Blob hmacData = Crypto.generateMac('hmacSHA256', Blob.valueOf(saltValue), Blob.valueOf(secretKeyValue));
       return EncodingUtil.convertToHex(hmacData);
    }
}