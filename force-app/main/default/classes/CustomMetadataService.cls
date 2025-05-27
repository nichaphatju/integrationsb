public class CustomMetadataService {
    public CustomMetadataService() {}
    /**
     * This method instantiates a custom metadata record of type Support_Tier__mdt
     * and sets the DeveloperName to the input String.
     * The record is not inserted into the database,
     * and would not be found by a SOQL query.
     */
    public static Product_Geo_Mapping__mdt getProductGeoMappingRecord(String myName, String countryCode, String permissibleFlyZone, String productFamily) {
        Product_Geo_Mapping__mdt pgm = new Product_Geo_Mapping__mdt();
        pgm.DeveloperName = myName;
        pgm.Country_Code__c = countryCode;
        pgm.Permissible_Fly_Zone__c = permissibleFlyZone;
        pgm.Product_Family__c = productFamily;
        return pgm;
    }
    /**
     * This method retrieves a custom metadata record, changes a field, and returns it
     * to the caller, but does not update the database.
     */
    public static Product_Geo_Mapping__mdt getChangedProductGeoMappingRecord(String myNewName) {
        Product_Geo_Mapping__mdt pgm = [SELECT Id, DeveloperName from Product_Geo_Mapping__mdt LIMIT 1];
        pgm.DeveloperName = myNewName;
        return pgm;
    }
}