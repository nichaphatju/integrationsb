global class CredentialVerificationService {

    webservice static String verifyCredential(String lastName, String certName) {

        Map<String, Contact_Certification__c> certMap = new Map<String, Contact_Certification__c>();
        for(Contact_Certification__c cert : [
            SELECT Id, Name, Contact__c, Certification__c, isActive__c, Certification__r.Name, Issue_Date__c
            FROM Contact_Certification__c
            WHERE Contact__r.LastName = :lastName
        ]) {
            certMap.put(cert.Name.toLowerCase(), cert);
        }

        if( certMap.isEmpty()) {
            return 'No record found';
        }

        if( certMap.containsKey(certName.toLowerCase()) && certMap.get(certName.toLowerCase()).isActive__c ) {
            return 'Valid';
        }

        return 'Needs Renewal';
    }
}