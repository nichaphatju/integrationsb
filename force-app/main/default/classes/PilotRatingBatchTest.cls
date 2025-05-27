@isTest
private class PilotRatingBatchTest {


@IsTest
    static void testPilotRatingBatch() {
        // Create test data
        Contact pilot = new Contact(FirstName = 'Test', LastName = 'Pilot', Pilot_Rating__c = 0);
        insert pilot;
        Mission__c mission = new Mission__c(
            Subject__c= 'Test Mission',
            Completion_Rating__c = 5,
            Safety_Incidents__c = 0,
            Pilot__c = pilot.Id,
            Status__c = 'Complete'
        );
        insert mission;

        
        // Execute the batch
        try{
            Test.startTest();
            Database.executeBatch(new PilotRatingBatch());
            Test.stopTest();
            
        }catch(System.Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
        
        Test.getEventBus().deliver();
        

    }
}