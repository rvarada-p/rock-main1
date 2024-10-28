/************************************************************************
Name  : SMEAssignmentToolController
Developer: Ravitej Varada - Laureate
Date: Jan 15th, 2020
Description: This class is controller class for SMEAssignmentApp 
*************************************************************************/

public class SMEAssignmentToolController {

    @AuraEnabled
    Public static List<studentTransactionWrapper> getAllSection() {

        List<studentTransactionWrapper> wrapList = new List<studentTransactionWrapper>();
        List<Sections__c> secList = [
                SELECT Id,Name,SME_Name__C, SME__c,LMS_Section_ID__c,Competency_Code__c,
                        Competency__c, Current_Section__c, Competency_Shell_ID__c,SME__r.Name,Competency__r.Name
                FROM Sections__c
                WHERE Competency_Shell_ID__c <> null
                AND LMS_Section_ID__c = null
        ];
        system.debug('secList' + secList);
        for (Sections__c sec : secList) {
            studentTransactionWrapper wrap = new studentTransactionWrapper();
            wrap.Name = sec.Name;
            wrap.compCode = sec.Competency_Code__c ;
            wrap.smeName = sec.SME_Name__c;
            wrap.compName = sec.Competency__r.Name;
            wrap.lmsSectionId = sec.LMS_Section_ID__c ;
            wrap.compShellId = sec.Competency_Shell_ID__c ;
            wrap.currentSection = sec.Current_Section__c ;
            wrap.Id = sec.id;
            wrap.responseMessage = '';
            wrap.responseCode = null;
            wrap.responseSuccess = false;

            wrapList.add(wrap);
        }
        return wrapList;
    }


    @AuraEnabled
    Public static List<studentTransactionWrapper> createSections(String[] lstAccountId) {

        List<studentTransactionWrapper> wrapList = new List<studentTransactionWrapper>();

        String lpVersion = String.valueOf(D2L__c.getValues('D2L').LP_Version__c);
        String initializeSection = D2L__c.getValues('D2L').Section_Initialization__c;
        Decimal enrollmentStyle = D2L__c.getValues('D2L').Enrollment_Style__c;
        Decimal enrollmentQuantity = D2L__c.getValues('D2L').Enrollment_Quantity__c;
        initializeSection = initializeSection.replace('(version)', lpVersion);
        List<Sections__c> sections = new List<Sections__c>([
                SELECT
                        Id,Name,SME_Name__C, SME__c,LMS_Section_ID__c,Competency_Code__c,
                        Competency__c, Current_Section__c, Competency_Shell_ID__c,SME__r.Name,Competency__r.Name
                FROM Sections__c
                WHERE Competency_Shell_ID__c <> null
                AND LMS_Section_ID__c = null
                AND Id IN:lstAccountId
        ]);
        List<Sections__c> toUpdate = new List<Sections__c>();
        Integer sectionId;
        String shellId;
        system.debug('sections' + sections);
        for (Sections__c section : sections) {
            studentTransactionWrapper wrap = new studentTransactionWrapper();

            wrap.Name = section.Name;
            wrap.compCode = section.Competency_Code__c ;
            wrap.smeName = section.SME_Name__c;
            wrap.compName = section.Competency__r.Name;
            wrap.lmsSectionId = section.LMS_Section_ID__c ;
            wrap.compShellId = section.Competency_Shell_ID__c ;
            wrap.currentSection = section.Current_Section__c ;
            wrap.Id = section.id;


            System.debug('SME: ' + section.SME__c);
            shellId = section.Competency_Shell_ID__c;
            System.debug('Shell Id: ' + shellId);
            String sectionEndPoint = initializeSection;
            sectionEndPoint = sectionEndPoint.replace('(orgUnitId)', shellId);
            System.debug('Endpoint: ' + sectionEndPoint);
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:BS' + sectionEndPoint);
            req.setMethod('PUT');

            String reqBody = '{ "EnrollmentStyle":' + enrollmentStyle + ' ,"EnrollmentQuantity":' + enrollmentQuantity + ' ,"AutoEnroll": false,"RandomizeEnrollments":false}';


            System.debug('Request Body: ' + reqBody);
            req.setBody(reqBody);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('Response: ' + res);
            System.debug('Response: ' + res.getStatusCode());
            System.debug('Response Body: ' + string.valueOf(res.getBody()));


            if (res.getStatusCode() == 200) {
                JSONParser parser = JSON.createParser(res.getBody());
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                            (parser.getText() == 'SectionId')) {
                        parser.nextToken();
                        sectionId = parser.getIntegerValue();
                        System.debug('SectionId  ' + sectionId);
                    }
                }
                if (sectionId != null) {
                    Sections__c sec = new Sections__c();
                    sec.Id = section.Id;
                    sec.LMS_Section_ID__c = sectionId;
                    toUpdate.add(sec);
                    System.debug('Updating: ' + sec);

                }
                wrap.responseSuccess = true;
            } else {
                string message = '';
                JSONParser parser1 = JSON.createParser(res.getBody());
                while (parser1.nextToken() != null) {
                    if ((parser1.getCurrentToken() == JSONToken.FIELD_NAME) &&
                            (parser1.getText() == 'Message')) {
                        parser1.nextToken();
                        message = parser1.getText();
                        System.debug('message ----- ' + message);
                    }
                }


                if (message == 'Cannot initalize new sections when sections already exist for a org unit.') {
                    req = new HttpRequest();
                    req.setEndpoint('callout:BS' + sectionEndPoint);
                    req.setMethod('POST');

                    reqBody = '{"Name": "Section 1 '+section.SME__r.Name +'",' +
                            ' "Code": "Sec1",' +
                            ' "Description": {"Content": "", "Type": ""} }';

                    System.debug('Request Body: ' + reqBody);
                    req.setBody(reqBody);
                    http = new Http();
                    res = http.send(req);
                    System.debug('Response: ' + res);
                    System.debug('Response: ' + res.getStatusCode());
                    System.debug('Response Body: ' + string.valueOf(res.getBody()));

                    if (res.getStatusCode() == 200) {
                        JSONParser parser = JSON.createParser(res.getBody());
                        while (parser.nextToken() != null) {
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                                    (parser.getText() == 'SectionId')) {
                                parser.nextToken();
                                sectionId = parser.getIntegerValue();
                                System.debug('SectionId  ' + sectionId);
                            }
                        }
                        if (sectionId != null) {
                            Sections__c sec = new Sections__c();
                            sec.Id = section.Id;
                            sec.LMS_Section_ID__c = sectionId;
                            toUpdate.add(sec);
                            System.debug('Updating: ' + sec);

                        }
                        wrap.responseSuccess = true;
                    }

                }


            }

            wrap.responseMessage = string.valueOf(res.getBody());
            if (res.getStatusCode() == 200) {
                wrap.responseCode = 'Success';
            } else {
                wrap.responseCode = 'Failed';

            }
            system.debug('wrap--->>>' + wrap);
            wrapList.add(wrap);
        }

        if (toUpdate.size() > 0) {
            System.debug('Updating section: ' + toUpdate);
            update toUpdate;
            return wrapList;
        }


        system.debug('result' + wrapList);
        return wrapList;


    }


    @AuraEnabled
    Public static List<studentTransactionWrapper> getAllSections() {

        List<studentTransactionWrapper> wrapList = new List<studentTransactionWrapper>();

        //get all contact list
        List<Sections__c> secList = [
                SELECT Id, Competency_Code__c, SME__c, LMS_Section_ID__c,
                        SME_LMS_User_ID__c, Competency__c, Current_Section__c, SME_Name__C,Name,SME__r.Name,Competency__r.Name,
                        Competency_Shell_ID__c
                FROM Sections__c
                WHERE SME_LMS_User_ID__c <> null AND
                LMS_Section_ID__c <> null AND
                Competency_Shell_ID__c <> null AND
                Enrolled_in_LMS__c = false
        ];

        for (Sections__c sec : secList) {
            studentTransactionWrapper wrap = new studentTransactionWrapper();
            wrap.Name = sec.Name;
            wrap.compCode = sec.Competency_Code__c ;
            wrap.smeName = sec.SME_Name__c;
            wrap.compName = sec.Competency__r.Name;
            wrap.lmsSectionId = sec.LMS_Section_ID__c ;
            wrap.compShellId = sec.Competency_Shell_ID__c ;
            wrap.currentSection = sec.Current_Section__c ;
            wrap.Id = sec.id;
            wrap.responseMessage = '';
            wrap.responseCode = null;
            wrap.responseSuccess = false;
            wrapList.add(wrap);
        }
        return wrapList;
    }


    @AuraEnabled
    Public static List<studentTransactionWrapper> enrollSMEsToSections(String[] lstAccountId) {
        system.debug('lstAccountId' + lstAccountId);
        List<studentTransactionWrapper> wrapList = new List<studentTransactionWrapper>();


        String lpVersion = String.valueOf(D2L__c.getValues('D2L').LP_Version__c);
        Decimal smeRoleId = D2L__c.getValues('D2L').SME_Role_ID__c ;
        String enrollmentEndPoint = D2L__c.getValues('D2L').Create_Enrollment_Endpoint__c ;
        enrollmentEndPoint = enrollmentEndPoint.replace('(version)', lpVersion);

        List<Sections__c> sections = new List<Sections__c>([
                SELECT Id, Competency_Code__c, SME__c, LMS_Section_ID__c,
                        SME_LMS_User_ID__c, Competency__c, Current_Section__c, SME_Name__C,Name,SME__r.Name,Competency__r.Name,
                        Competency_Shell_ID__c
                FROM Sections__c
                WHERE SME_LMS_User_ID__c <> null AND
                LMS_Section_ID__c <> null AND
                Competency_Shell_ID__c <> null AND
                Enrolled_in_LMS__c = false
                AND Id IN:lstAccountId
        ]);
        System.debug('Sections: ' + sections);
        List<Sections__c> toUpdate = new List<Sections__c>();
        Decimal smeSectionId;
        Decimal smeLMSId;
        Decimal competencyShellId;
        List<BrightSpace_API_Exceptions__c> bsExpLst = new List<BrightSpace_API_Exceptions__c>();
        for (Sections__c section : sections) {
            studentTransactionWrapper wrap = new studentTransactionWrapper();

            wrap.Name = section.Name;
            wrap.compCode = section.Competency_Code__c ;
            wrap.smeName = section.SME_Name__c;
            wrap.compName = section.Competency__r.Name;
            wrap.lmsSectionId = section.LMS_Section_ID__c ;
            wrap.compShellId = section.Competency_Shell_ID__c ;
            wrap.currentSection = section.Current_Section__c ;

            wrap.Id = section.id;


            competencyShellId = Decimal.valueOf(section.Competency_Shell_ID__c);
            smeSectionId = section.LMS_Section_ID__c;
            smeLMSId = section.SME_LMS_User_ID__c;
            System.debug('Endpoint: ' + enrollmentEndPoint + ' Competency: ' + section.Competency_Code__c);
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:BS' + enrollmentEndPoint);
            req.setMethod('POST');
            String json = '{ "OrgUnitId":' + smeSectionId + ' ,"UserId":' + smeLMSId + ' ,"RoleId": ' + smeRoleId + '}';
            String json2 = '{ "OrgUnitId":' + competencyShellId + ' ,"UserId":' + smeLMSId + ' ,"RoleId": ' + smeRoleId + '}';

            System.debug('Request Body: ' + json);
            System.debug('Request 2: ' + json2);
            req.setBody(json);
            Http http = new Http();
            HTTPResponse res;
            try {
                res = http.send(req);

                System.debug('Response: ' + res.getBody() + ' Status Code: ' + res.getStatusCode());
                if (res.getStatusCode() == 200) {
                    //Make second enrollment call for enrolling into Competency Shell
                    req.setBody(json2);
                    Http http2 = new Http();
                    HttpResponse response;
                    try {
                        res = http2.send(req);
                        System.debug('Response 2: ' + res.getBody() + ' Status Code: ' + res.getStatusCode());
                        if (res.getStatusCode() == 200) {
                            System.debug('Enrolled into Competency Shell');
                            section.Enrolled_in_LMS__c = true;
                            toUpdate.add(section);
                            wrap.responseSuccess = true;

                        } else {
                            wrap.responseSuccess = false;
                        }
                    } catch (Exception e) {
                        System.debug(e);
                    }
                    wrap.responseSuccess = true;

                } else {
                    wrap.responseSuccess = false;

                    BrightSpace_API_Exceptions__c bsExp = new BrightSpace_API_Exceptions__c();
                    //bsExp.Area_of_Expertise__c = aoeId;
                    if (res != null) {
                        bsExp.Status_Code__c = res.getStatusCode();
                        bsExp.Error_Description__c = res.getStatus();
                    }
                    bsExpLst.add(bsExp);
                }
            } catch (Exception exp) {
                System.debug('Exception: ' + exp);
                BrightSpace_API_Exceptions__c bsExp = new BrightSpace_API_Exceptions__c();
                //bsExp.Area_of_Expertise__c = aoeId;
                if (res != null) {
                    bsExp.Status_Code__c = res.getStatusCode();
                    bsExp.Error_Description__c = res.getStatus();
                }
                bsExpLst.add(bsExp);
            }

            if (res.getStatusCode() == 200) {
                wrap.responseCode = 'Success';
            } else {
                wrap.responseCode = 'Failed';

            }

            wrap.responseMessage = string.valueOf(res.getBody());

            wrapList.add(wrap);
        }
        if (bsExpLst.size() > 0) {
            insert bsExpLst;
        }


        if (toUpdate.size() > 0) {
            update toUpdate;
        }

        return wrapList;
    }


    public class studentTransactionWrapper {
        @AuraEnabled public string Id { get; set; }
        @AuraEnabled public string Name { get; set; }
        @AuraEnabled public string compCode { get; set; }
        @AuraEnabled public string smeName { get; set; }
        @AuraEnabled public string compName { get; set; }
        @AuraEnabled public decimal lmsSectionId { get; set; }
        @AuraEnabled public string compShellId { get; set; }
        @AuraEnabled public boolean currentSection { get; set; }
        @AuraEnabled public string responseMessage { get; set; }
        @AuraEnabled public boolean responseSuccess { get; set; }
        @AuraEnabled public string responseCode { get; set; }

    }


}