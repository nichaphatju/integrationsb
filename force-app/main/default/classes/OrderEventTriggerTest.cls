@isTest
public class OrderEventTriggerTest {
    // This test causes the trigger to hit a non-catchable limit exception
    // on the third event.
    // Expected: The trigger resumes where it left off and processes the next events.
    @isTest
    static void testResumeAfterLimitException() {
        PlatformEventsTestUtil.throwLimitExceptionAtRun(3);
        try {
            // Publish 5 events.
            // First event batch should have 2 successfully processed events
            // because the exception occurs on the 3rd event.
            // Verify that trigger resumes and processes remaining events.
            publishAndDeliverEvents(5, 2);
        } finally {
            // Clean up test parameters so they don't affect other tests
            PlatformEventsTestUtil.cleanUp();
        }
    }
    
    // This test causes the trigger to hit a catchable exception on the second event.
    // Expected: The trigger resumes where it left off and processes the next events.
    @isTest
    static void testResumeAfterCatchableExceptionOnSecondEvent() {
        PlatformEventsTestUtil.throwCatchableExceptionAtRun(2);
        try {
            // Publish 5 events.
            // First event batch should have 1 successfully processed event
            // and setResumeCheckpoint was called.
            // The exception occurs on the 2nd event.
            // Verify that trigger resumes and processes remaining events.
            publishAndDeliverEvents(5, 1);
        } finally {
            // Clean up test parameters so they don't affect other tests
            PlatformEventsTestUtil.cleanUp();
        }
    }
    
	// This test causes the trigger to hit a catchable exception on the first event.
	// Expected: The trigger is retried with the entire batch of events.
    @isTest
    static void testRetryAfterCatchableExceptionOnFirstEvent() {
        PlatformEventsTestUtil.throwCatchableExceptionAtRun(1);
        try {
            // Publish 5 events.
            // First batch of events delivered is empty because
            // the execution jumps to the catch block.
            // Because setResumeCheckpoint has not been called yet,
            // the trigger will be retried with EventBus.RetryableException
            // with the entire batch of events.
            publishAndDeliverEvents(5, 0);
        } finally {
            // Clean up test parameters so they don't affect other tests
            PlatformEventsTestUtil.cleanUp();
        }
    }
    
    // This test causes the trigger to hit a catchable exception on the first event and
    // exhausts the number of retries.
    // Expected: The trigger is retried with the entire batch of events MAX_RETRIES + 1 times.
    // After the retries are exhausted, the trigger rethrows the exception.
    @isTest
    static void testRetryAfterCatchableExceptionOnFirstEventMaxRetriesReached() {
        PlatformEventsTestUtil.throwCatchableExceptionContinuousAtRun(1);
        try {
            publishEvents(2);
            
            // The trigger should run (max retry + 1) times
            for (Integer i = 1; i <= PlatformEventsConstants.MAX_RETRIES + 1; i++) {
                Test.getEventBus().deliver();
                Assert.areEqual(i, PlatformEventsTestUtil.getRunCounter(),
                                'Trigger should have retried.');
            }
            
            // Calling deliver more times won't cause the trigger to run,
            // since we're not throwing the Retryable exception anymore.
            Test.getEventBus().deliver();
            Assert.areEqual(PlatformEventsConstants.MAX_RETRIES + 1,
                            PlatformEventsTestUtil.getRunCounter(),
                            'Trigger should NOT have retried.');
        } finally {
            // Clean up test parameters so they don't affect other tests
            PlatformEventsTestUtil.cleanUp();
        }
    }
    
    // Helper method to publish events.
    private static void publishEvents(Integer totalEvents) {
        List<Order_Event__e> eventList = new List<Order_Event__e>();
        
        // Create test events. Number of test events to create is totalEvents.
        for(Integer i = 0; i < totalEvents; i++) {
            Order_Event__e event = (Order_Event__e)Order_Event__e.sObjectType.newSObject(
                null, true);
            event.Order_Id__c='dummyOrderId' + i;
            eventList.add(event);
        }
        
        // Publish all events
        EventBus.publish(eventList);
    }
    
    // Helper method to publish events and call deliver twice to verify
    // that the trigger resumes after an exception.
    private static void publishAndDeliverEvents(Integer totalEvents,
                                                Integer expectedFirstDeliveryCount) {
        publishEvents(totalEvents);
        
        // Deliver the batch of events
        Test.getEventBus().deliver();
        
        // Verify that the trigger processed expectedFirstDeliveryNum of events
        // because it processed only that many events before the exception
        // was hit.
        Assert.areEqual(expectedFirstDeliveryCount,
                        getTriggerPosition(), 'Unexpected number of events processed.');
                
        // Call deliver() again to deliver the remaining events in the batch
        // and cause the trigger resume after the exception.
        Test.getEventBus().deliver();
               
        // Verify that the trigger resumes and remaining events are processed
        // for the remaining events, so there are a total of totalEvents processed events.
        Assert.areEqual(totalEvents,
                        getTriggerPosition(),
                        'Unexpected number of events processed.');
                                                    
        getTriggerPosition();
    }
    
    // Helper method to return the ReplayId of the last processed event.
    // In test context, replayIDs start from 1 and are incremented.
    private static Integer getTriggerPosition() {
        Integer position = 0;
        
        EventBusSubscriber[] subscribers =
            [SELECT Name, Type, Position, Retries, LastError
             FROM EventBusSubscriber WHERE Topic='Order_Event__e'];
        
        for (EventBusSubscriber sub : subscribers) {
            if (sub.Name == 'OrderEventTrigger') {
                System.debug('sub.Position='+sub.Position);
                position = sub.Position;
            }
        }
        
        return position;
    }
}