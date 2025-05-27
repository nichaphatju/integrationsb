@isTest
private class AssetServiceTest {

    @TestSetup
    static void makeData(){

        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i,
                Type = 'Customer'
            ));
        }
        insert accounts;

        List<Contact> contacts = new List<Contact>();
        List<Product2> products = new List<Product2>();

        // Create 1 Contact
        for (Integer i = 0; i < 10; i++) {
            contacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'Contact ' + i,
                Email = 'testcontact' + i + '@example.com',
                AccountId = accounts[0].Id
            ));
        }
        insert contacts;

        // Create 1 Product
        for (Integer i = 0; i < 10; i++) {
            products.add(new Product2(
                Name = 'Test Product ' + i,
                IsActive = true
            ));
        }
        insert products;
        
        List<Asset> assets = new List<Asset>();
        
        for (Integer i = 0; i < 10; i++) {
            assets.add(new Asset(
                Name = 'Test Asset ' + i,
                Asset_Identifier__c = 'Test Identifier ' + i,
                Product2Id = products[0].Id,
                ContactId = contacts[0].Id
            ));
        }
        
        insert assets;

        Asset assetLost = [SELECT Id FROM Asset WHERE Asset_Identifier__c = 'Test Identifier 0' LIMIT 1];
        assetLost.Status = 'Lost';
        update assetLost;

        List<Insurance__c> insurances = new List<Insurance__c>();
        for (Integer i = 0; i < 2; i++) {
            insurances.add(new Insurance__c(
                Coverage__c = 'Comprehensive',
                Asset__c = assets[i].Id,
                Start_Date__c = System.today().addDays(-30),
                Active__c = true
            ));
        }
        insert insurances;

        List<Claim__c> claims = new List<Claim__c>();   
        for (Integer i = 0; i < 1; i++) {
            claims.add(new Claim__c(
                Contact__c = contacts[0].Id,
                Status__c = 'New',
                Type__c = 'Loss',
                Insurance__c = insurances[i].Id,
                Asset__c = assetLost.Id
            ));
        }

        insert claims;
    }

    @IsTest
    static void testReportAssetNotfound() {
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/asset/report';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf('{"assetIdentifier": "Test Identifier 100"}');
            RestContext.request = req;
            RestContext.response = res;
            
            Test.startTest();
            String result = AssetService.report();
            Test.stopTest();

            System.assertEquals('No device found.', result);
    }

    @IsTest
    static void testReportID() {
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/asset/report';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf('{"assetIdentifier": "Test Identifier 1"}');
            RestContext.request = req;
            RestContext.response = res;
            
            Test.startTest();
            String result = AssetService.report();
            Test.stopTest();

            System.assertNotEquals('No device found.', result);
            System.assertNotEquals(null, result);
    }

    @IsTest
    static void testReportNoCoverage() {

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/asset/report';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf('{"assetIdentifier": "Test Identifier 5"}');
            RestContext.request = req;
            RestContext.response = res;
            
            Test.startTest();
            String result = AssetService.report();
            Test.stopTest();

            System.assertEquals('No coverage. Asset status adjusted to Lost.', result);
    }

    @IsTest
    static void testReportAlreadyClaimed() {

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/asset/report';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf('{"assetIdentifier": "Test Identifier 0"}');
            RestContext.request = req;
            RestContext.response = res;
            
            Test.startTest();
            String result = AssetService.report();
            Test.stopTest();

            System.assert(result.contains('already filed.'));
    }
}