/************************************************************************
Name  : HttpResponse_L1TempoVisibilityGetAttach
Developer: Ravitej Varada - Laureate
Date: April 5th, 2018
Description: This class is to create Fake HTTP Response for HttpResponse_L1TempoVisibilityGetAttach
            code = 202
*************************************************************************/

@isTest
public class Mock_HttpResponse_L1TempoVisiGetAttach{
  public static HTTPResponse fakeOppDatafromL1(){
      HTTPResponse res= new HTTPResponse();
      res.setStatusCode(200);
      res.setBody('{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Opportunity","url":"/services/data/v45.0/sobjects/Opportunity/0067f000009QNG1AAO"},"Name":"Test Test - COUN 6721 Advanced Psychopathology","Id":"0067f000009QNG1AAO","CBL_Student_ID__c":null,"Brand_Profile__c":"a1V7f000001UggeEAC","Contact__r":{"attributes":{"type":"Contact","url":"/services/data/v45.0/sobjects/Contact/0037f00000Xb4BrAAJ"},"Name":"Test Test","Email":"sfdcdevapps@gmail.com"},"Product_Code__c":"COUN 6721 Advanced Psychopathology","Tasks":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Task","url":"/services/data/v45.0/sobjects/Task/00T7f00000G8po9EAB"},"Id":"00T7f00000G8po9EAB","Subject":"Prospect Re-inquiry","Description":"Re-inquiry: 01to0000003pYN7AAM. Test Test, sfdcdevapps@gmail.com, null, United States","Type__c":null,"Status__c":null,"Status":"Not Started","CreatedDate":"2021-03-19T20:12:06.000+0000","ActivityDate":"2021-03-19"}]},"Cases1__r":null}]}');
      return res;
  }
  public static HTTPResponse fakeAllAttachmentResponseOfABP(){
      HTTPResponse res= new HTTPResponse();
      res.setStatusCode(200);
      res.setBody('{"totalSize":6,"done":true,"records":[{"attributes":{"type":"My_Documents__c","url":"/services/data/v45.0/sobjects/My_Documents__c/a1t1N000007GqU6QAK"},"Name":"MD-2363305","Id":"a1t1N000007GqU6QAK","Document_Type__c":"Unofficial Transcript","Date_Received__c":"2018-10-24","Institution_Name_Text__c":"University of Pittsburgh","Official_Indicator__c":false,"Document_Source__c":"Imported","Institution_Type__c":"College","Document_Detail__c":"unofficial transcript 10.24.18.pdf","Attachments":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Attachment","url":"/services/data/v45.0/sobjects/Attachment/00P1N00000lnGgDUAU"},"Id":"00P1N00000lnGgDUAU","Name":"unofficial transcript 10.24.18.pdf"}]}},{"attributes":{"type":"My_Documents__c","url":"/services/data/v45.0/sobjects/My_Documents__c/a1t1N000007H0BFQA0"},"Name":"MD-2370650","Id":"a1t1N000007H0BFQA0","Document_Type__c":"Application","Date_Received__c":"2018-10-26","Institution_Name_Text__c":null,"Official_Indicator__c":false,"Document_Source__c":"Imported","Institution_Type__c":null,"Document_Detail__c":"OLA Snapshot.pdf","Attachments":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Attachment","url":"/services/data/v45.0/sobjects/Attachment/00P1N00000m9PQ3UAM"},"Id":"00P1N00000m9PQ3UAM","Name":"OLA Snapshot.pdf"}]}},{"attributes":{"type":"My_Documents__c","url":"/services/data/v45.0/sobjects/My_Documents__c/a1t1N000007H0CIQA0"},"Name":"MD-2370663","Id":"a1t1N000007H0CIQA0","Document_Type__c":"Admissions Decision Letter","Date_Received__c":"2018-10-26","Institution_Name_Text__c":null,"Official_Indicator__c":false,"Document_Source__c":"Imported","Institution_Type__c":null,"Document_Detail__c":"Admissions Decision Letter Walden.pdf","Attachments":null},{"attributes":{"type":"My_Documents__c","url":"/services/data/v45.0/sobjects/My_Documents__c/a1t1N000007H0CSQA0"},"Name":"MD-2370665","Id":"a1t1N000007H0CSQA0","Document_Type__c":"Transfer of Credit Evaluation","Date_Received__c":"2018-10-26","Institution_Name_Text__c":null,"Official_Indicator__c":false,"Document_Source__c":"Imported","Institution_Type__c":null,"Document_Detail__c":"MHA GEN Tempo","Attachments":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Attachment","url":"/services/data/v45.0/sobjects/Attachment/00P1N00000m9PUtUAM"},"Id":"00P1N00000m9PUtUAM","Name":"Donna Steigerwalt - MHA General - POS - Tempo.docx"}]}},{"attributes":{"type":"My_Documents__c","url":"/services/data/v45.0/sobjects/My_Documents__c/a1t1N000007HIg7QAG"},"Name":"MD-2384911","Id":"a1t1N000007HIg7QAG","Document_Type__c":"Official Transcript","Date_Received__c":"2018-11-06","Institution_Name_Text__c":"University of Pittsburgh","Official_Indicator__c":true,"Document_Source__c":"Scanned","Institution_Type__c":"College","Document_Detail__c":null,"Attachments":null},{"attributes":{"type":"My_Documents__c","url":"/services/data/v45.0/sobjects/My_Documents__c/a1t1N000007HeJxQAK"},"Name":"MD-2401347","Id":"a1t1N000007HeJxQAK","Document_Type__c":"Employer Document","Date_Received__c":"2018-11-15","Institution_Name_Text__c":null,"Official_Indicator__c":false,"Document_Source__c":"Imported","Institution_Type__c":null,"Document_Detail__c":null,"Attachments":null}]}');
      return res;
  }
  public static HTTPResponse fakeAllCDLOfABP(){
      HTTPResponse res= new HTTPResponse();
      res.setStatusCode(200);
      res.setBody('{"totalSize":3,"done":true,"records":[{"attributes":{"type":"ContentDocumentLink","url":"/services/data/v45.0/sobjects/ContentDocumentLink/06A7f000002i9W5EAI"},"ContentDocumentId":"0697f0000015qHNAAY","LinkedEntityId":"a1t1N000007H0CIQA0"},{"attributes":{"type":"ContentDocumentLink","url":"/services/data/v45.0/sobjects/ContentDocumentLink/06A7f000002hrTsEAI"},"ContentDocumentId":"0697f0000015fI3AAI","LinkedEntityId":"a1t1N000007HIg7QAG"},{"attributes":{"type":"ContentDocumentLink","url":"/services/data/v45.0/sobjects/ContentDocumentLink/06A7f000002dQEjEAM"},"ContentDocumentId":"0697f0000015VzaAAE","LinkedEntityId":"a1t1N000007HeJxQAK"}]}');
      return res;
  }
  public static HTTPResponse fakeCVDataOfAllCDL(){
      HTTPResponse res= new HTTPResponse();
      res.setStatusCode(200);
      res.setBody('{"totalSize":2,"done":true,"records":[{"attributes":{"type":"ContentVersion","url":"/services/data/v45.0/sobjects/ContentVersion/0687f0000015r0qAAA"},"Id":"0687f0000015r0qAAA","ContentDocumentId":"0697f0000015qHNAAY"},{"attributes":{"type":"ContentVersion","url":"/services/data/v45.0/sobjects/ContentVersion/0687f0000015WhQAAU"},"Id":"0687f0000015WhQAAU","ContentDocumentId":"0697f0000015VzaAAE"}]}');
      return res;
  }
  public static HTTPResponse fakeCVData(){
      HTTPResponse res= new HTTPResponse();
      res.setStatusCode(200);
      res.setBody('[{"attributes":{"type":"ContentVersion","url":"/services/data/v50.0/sobjects/ContentVersion/0687f0000015WhQAAU"},"Id":"0687f0000015WhQAAU","PathOnClient":"servlet.txt","FileType":"TEXT"}]');
      return res;
  }
  
  public static HTTPResponse fakeSingleAttachment(){
      HTTPResponse res= new HTTPResponse();
      res.setStatusCode(200);
      res.setBody('{"attributes":{"type":"Attachment","url":"/services/data/v51.0/sobjects/Attachment/00P1N00000m9PUUUA2"},"Id":"00P1N00000m9PUUUA2","IsDeleted":false,"ParentId":"a1t1N000007H0CIQA0","Name":"Donna Steigerwalt - Admissions Decision Letter.pdf","IsPrivate":false,"ContentType":"application/pdf","BodyLength":75331,"Body":"/services/data/v51.0/sobjects/Attachment/00P1N00000m9PUUUA2/Body","OwnerId":"005o0000002QaQrAAK","CreatedDate":"2018-10-26T17:07:52.000+0000","CreatedById":"005o0000002QaQrAAK","LastModifiedDate":"2018-10-26T17:07:52.000+0000","LastModifiedById":"005o0000002QaQrAAK","SystemModstamp":"2018-10-26T17:07:52.000+0000","Description":null}');
      return res;
  }
  public static HTTPResponse fakeSingleFile(){
      HTTPResponse res= new HTTPResponse();
      res.setStatusCode(200);
      res.setBody('{"attributes":{"type":"ContentVersion","url":"/services/data/v51.0/sobjects/ContentVersion/0687f0000015WhQAAU"},"Id":"0687f0000015WhQAAU","ContentDocumentId":"0697f0000015VzaAAE","IsLatest":true,"ContentUrl":null,"ContentBodyId":"05T7f000007fL5qEAE","VersionNumber":"1","Title":"servlet","Description":null,"ReasonForChange":null,"SharingOption":"A","SharingPrivacy":"N","PathOnClient":"servlet.txt","RatingCount":0,"IsDeleted":false,"ContentModifiedDate":"2021-05-08T20:57:03.000+0000","ContentModifiedById":"005o0000003p5R2AAI","PositiveRatingCount":0,"NegativeRatingCount":0,"FeaturedContentBoost":null,"FeaturedContentDate":null,"OwnerId":"005o0000003p5R2AAI","CreatedById":"005o0000003p5R2AAI","CreatedDate":"2021-05-08T20:57:03.000+0000","LastModifiedById":"005o0000003p5R2AAI","LastModifiedDate":"2021-05-08T20:57:04.000+0000","SystemModstamp":"2021-05-09T10:00:29.000+0000","TagCsv":null,"FileType":"TEXT","PublishStatus":"P","VersionData":"/services/data/v51.0/sobjects/ContentVersion/0687f0000015WhQAAU/VersionData","ContentSize":822,"FileExtension":"txt","FirstPublishLocationId":"005o0000003p5R2AAI","Origin":"H","NetworkId":null,"ContentLocation":"S","TextPreview":null,"ExternalDocumentInfo1":null,"ExternalDocumentInfo2":null,"ExternalDataSourceId":null,"Checksum":"e1ecd1a15c4e0290c9a0010bee129af9","IsMajorVersion":true,"IsAssetEnabled":false,"Contact__c":null,"Contract_Files__c":false,"Flag__c":null}');
      return res;
  }
  public static HTTPResponse fakeFileBody(){
      HTTPResponse res= new HTTPResponse();
      res.setStatusCode(200);
      res.setBody('Test Body');
      return res;
  }   
}