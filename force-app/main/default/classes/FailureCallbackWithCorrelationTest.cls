@isTest
public class FailureCallbackWithCorrelationTest {
   
    @isTest
    static void testFailedEventsWithFail() {
        // Create test event
        Order_Event__e event = (Order_Event__e)Order_Event__e.sObjectType.newSObject(
            null, true);
        event.Order_Id__c='dummyOrderId';
        
        // Populate map
        Map<String,String> uuidMap = new Map<String,String>();
        uuidMap.put(event.EventUuid, 'dummyOrderId');
        
        // Create callback
        FailureCallbackWithCorrelation cb = new FailureCallbackWithCorrelation(uuidMap);
        
        // Make sure retry counter is 0
        Assert.areEqual(0, cb.getRetryCounter(),
            'Newly created callback should have retry counter at 0');
        
        // Publish an event with callback
        EventBus.publish(event, cb);
		
        // If we fail all publish attempts, callback should run MAX_RETRIES times.
        // For each attempt, the callback should republish the event,
        //    increase the counter, and update the map
        String prevUuid = event.EventUuid;
        for (Integer i = 1; i <= FailureCallbackWithCorrelation.MAX_RETRIES; i++) {
            Test.getEventBus().fail();
            Assert.areEqual(i, cb.getRetryCounter(), 'Retry counter should be ' + i);
            Assert.areEqual(1, cb.getUuidMap().size(), 'Map size should be 1');
            String currUuid = (new List<String>(cb.getUuidMap().keySet())).get(0);
            Assert.areNotEqual(prevUuid, currUuid,
                'Map should be updated with newly created event Uuid');
            Assert.areEqual('dummyOrderId', cb.getUuidMap().get(currUuid),
                'Map value should be the original Order Id');
            prevUuid = currUuid;
        }
        
        // If we publish another failed event, callback should not retry.
        Order_Event__e event2 = (Order_Event__e)Order_Event__e.sObjectType.newSObject(
            null, true);
        event2.Order_Id__c='dummyOrderId';
        EventBus.publish(event, cb);
        Test.getEventBus().fail();
        Assert.areEqual(FailureCallbackWithCorrelation.MAX_RETRIES, cb.getRetryCounter(),
                        'Retry counter should still be ' +
                         FailureCallbackWithCorrelation.MAX_RETRIES);
    }
}