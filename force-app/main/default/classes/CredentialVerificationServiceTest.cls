@isTest
private class CredentialVerificationServiceTest {

    @TestSetup
    static void makeData(){
        Contact con = new Contact(LastName = 'DoeCredentialVerificationServiceTest',
                                  FirstName = 'John',
                                  Email = 'DoeCredentialVerificationServiceTest@mail.com');
        insert con;

        Certification__c cert = new Certification__c(Name = 'Test Certification', isActive__c = true);
        insert cert;

        Contact_Certification__c cc = new Contact_Certification__c(Contact__c = con.Id, Certification__c = cert.Id, isActive__c = true, Issue_Date__c = Date.today().addYears(-1));
        insert cc;
    }

    @IsTest
    static void testVerifyCredential() {

        Contact_Certification__c cc = [SELECT Id,Name FROM Contact_Certification__c WHERE Contact__r.LastName = 'DoeCredentialVerificationServiceTest' LIMIT 1];

        Test.startTest();
        String result = CredentialVerificationService.verifyCredential('DoeCredentialVerificationServiceTest', cc.Name);
        Test.stopTest();

        System.assertEquals('Valid', result);
    }

    @IsTest
    static void testVerifyCredentialContactNotFound() {

        Test.startTest();
        String result = CredentialVerificationService.verifyCredential('JessicaCredentialVerificationServiceTest', 'Test Certification');
        Test.stopTest();

        System.assertEquals('No record found', result);
    }

    @IsTest
    static void testVerifyCredentialRenewal() {

        Contact_Certification__c cc = [SELECT Id,Name FROM Contact_Certification__c WHERE Contact__r.LastName = 'DoeCredentialVerificationServiceTest' LIMIT 1];
        cc.isActive__c = false;
        update cc;

        Test.startTest();
        String result = CredentialVerificationService.verifyCredential('DoeCredentialVerificationServiceTest', cc.Name);
        Test.stopTest();

        System.assertEquals('Needs Renewal', result);
    }
}