@RestResource(urlMapping='/lost/*')
global with sharing class AssetService {
    
    @HttpPost
    global static String report() {
        
        RestRequest req = RestContext.request;
        Map<String, Object> body = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
        String assetIdentifier = (String)body.get('assetIdentifier');
        
        return reportLostDevice(assetIdentifier);
    }

    public static String reportLostDevice(String assetIdentifier) {
        // Query asset based on identifier
        List<Asset> assets = [SELECT Id, Status, Product2.Family, ContactId FROM Asset WHERE Asset_Identifier__c = :assetIdentifier LIMIT 1];
        
        if(!assets.isEmpty()) {

            Asset asset = assets[0];
            List<Claim__c> existingClaims = [SELECT Id,Name FROM Claim__c WHERE Asset__c = :asset.Id AND Type__c = 'Loss' LIMIT 1];
            if(!existingClaims.isEmpty()) {
                return existingClaims[0].Name + ' already filed.';
            }

            // Update asset status to 'Lost'
            asset.Status = 'Lost';
            update asset;
            
            // Check for active comprehensive insurance coverage and create a claim
            List<Insurance__c> insurances = [SELECT Id, Coverage__c, Active__c FROM Insurance__c WHERE Coverage__c = 'Comprehensive' AND Asset__c = :asset.Id AND Active__c = true LIMIT 1];
            if(!insurances.isEmpty()) {
                Claim__c claim = new Claim__c();
                claim.Contact__c = asset.ContactId;
                claim.Status__c = 'New';
                claim.Type__c = 'Loss';
                claim.Insurance__c = insurances[0].Id;
                claim.Asset__c = asset.Id;
                insert claim;
                
                return [SELECT Name FROM Claim__c WHERE Id = :claim.Id].Name;
            }else{
                return 'No coverage. Asset status adjusted to Lost.';
            }
        }
        
        return 'No device found.';
    }

}