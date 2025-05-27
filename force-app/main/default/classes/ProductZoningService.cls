@RestResource(urlMapping='/ProductZoning/*')
global with sharing class ProductZoningService {

    @HttpGet
    global static String findPermissibleFlyZone() {

        String productCode = RestContext.request.params.get('ProductCode');
        String countryCode = RestContext.request.headers.get('CountryCode');

        if(countryCode == null || countryCode == '') {
            countryCode = 'US';
        }

        if(productCode == null || productCode == '') {
            return 'ProductCode is missing or doesn\'t exist';
        }

        List<Product2> products = [
            SELECT Id, Name, ProductCode, Family
            FROM Product2
            WHERE ProductCode = :productCode
        ];

        if(products.isEmpty()) {
            return 'ProductCode is missing or doesn\'t exist';
        }

        Map<String, String> productFamilyMap = new Map<String, String>();
        
        List<Product_Geo_Mapping__mdt> productGeoMappings = [
            SELECT Id, Country_Code__c, Permissible_Fly_Zone__c, Product_Family__c
            FROM Product_Geo_Mapping__mdt WHERE Product_Family__c = :products[0].Family
        ];

        if (productGeoMappings.isEmpty()) {
            return 'ProductCode is missing or doesn\'t exist';
        }

        if(Test.isRunningTest()){
            productGeoMappings.add(CustomMetadataService.getProductGeoMappingRecord('TestMapping', 'US', 'Restricted', 'HALE'));
            productGeoMappings.add(CustomMetadataService.getProductGeoMappingRecord('TestMappingEU', 'EU', 'Permissible', 'MALE'));
            productGeoMappings.add(CustomMetadataService.getProductGeoMappingRecord('TestMappingFR', 'FR', 'Restricted', 'Fixed-Wing'));
        }

        for(Product_Geo_Mapping__mdt pgm: productGeoMappings){
            if(pgm.Country_Code__c == countryCode) {
                productFamilyMap.put(pgm.Product_Family__c, pgm.Permissible_Fly_Zone__c);
            }
        }

        if(productFamilyMap.isEmpty()){
            return 'Confirm with the local authorities';
        }

        
        return productFamilyMap.get(products[0].Family);
    }
}