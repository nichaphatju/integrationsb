@isTest
private class ProductZoningServiceTest {

    @TestSetup
    static void makeData(){
        List<Product2> productList = new List<Product2>();
        productList.add(new Product2(Name = 'DJI Mavic 2 Pro', Family = 'HALE', ProductCode = 'SL9080'));
        productList.add(new Product2(Name = 'DJI Mavic 2 Enterprise', Family = 'UALE', ProductCode = 'IN7040'));
        productList.add(new Product2(Name = 'DJI Mavic 2 *', Family = 'LALE', ProductCode = 'GC5040'));
        insert productList;
    }

    @IsTest
    static void testFindPermissibleFlyZone() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ProductZoningService';
        req.httpMethod = 'GET';
        req.addParameter('ProductCode', 'SL9080');
        req.addHeader('CountryCode', 'US');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        String result = ProductZoningService.findPermissibleFlyZone();
        Test.stopTest();
        
        System.assertEquals('Restricted', result);
    }

    @IsTest
    static void testFindPermissibleFlyZoneDefaultCountry() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ProductZoningService';
        req.httpMethod = 'GET';
        req.addParameter('ProductCode', 'SL9080');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        String result = ProductZoningService.findPermissibleFlyZone();
        Test.stopTest();
        
        System.assertEquals('Restricted', result);
    }

    @IsTest
    static void testFindPermissibleFlyZoneNoCountry() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ProductZoningService';
        req.httpMethod = 'GET';
        req.addParameter('ProductCode', 'SL9080');
        req.addHeader('CountryCode', 'IN');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        String result = ProductZoningService.findPermissibleFlyZone();
        Test.stopTest();

        System.assertEquals('Confirm with the local authorities', result);
    }

    @IsTest
    static void testFindPermissibleFlyZoneNoProduct() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ProductZoningService';
        req.httpMethod = 'GET';
        req.addParameter('ProductCode', 'GC5041');
        req.addHeader('CountryCode', 'EU');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        String result = ProductZoningService.findPermissibleFlyZone();
        Test.stopTest();

        
        System.assertEquals('ProductCode is missing or doesn\'t exist', result);
        
    }

    @IsTest
    static void testFindPermissibleFlyZoneNoProduct2() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ProductZoningService';
        req.httpMethod = 'GET';
        req.addParameter('ProductCode', 'IN7040');
        req.addHeader('CountryCode', 'IN');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        String result = ProductZoningService.findPermissibleFlyZone();
        Test.stopTest();

        
        System.assertEquals('ProductCode is missing or doesn\'t exist', result);
        
    }
}