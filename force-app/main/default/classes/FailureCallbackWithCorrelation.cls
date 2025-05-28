public class FailureCallbackWithCorrelation implements EventBus.EventPublishFailureCallback {
    public static final Integer MAX_RETRIES = 2;
    private Integer retryCounter = 0;
    private Map<String,String> uuidMap;
    
    // Callback constructor
    public FailureCallbackWithCorrelation(Map<String,String> uuidMap) {
        this.uuidMap = uuidMap;
    }
    
    public void onFailure(EventBus.FailureResult result) {
        List<String> eventUuids = result.getEventUuids();
        Map<String,String> newUuidMap = new Map<String,String>();
        
        if (retryCounter < MAX_RETRIES) {
            // Try to re-publish the failed events
            List<Order_Event__e> events = new List<Order_Event__e>();
            for (String uuid : eventUuids) {
                // Create a new event with the contents of the failed event
                Order_Event__e event = (Order_Event__e)
                    Order_Event__e.sObjectType.newSObject(null, true);
                // Fill event with the right order record Id
                event.Order_Id__c = uuidMap.get(uuid);
                events.add(event);
                
                // Use a new map since the new event will have a different uuid
                newUuidMap.put(event.EventUuid, event.Order_Id__c);
            }
            // Replace old uuid map because we no longer need its contents
            uuidMap = newUuidMap;
            
            // Republish with the same callback passed in again as 'this'
            System.debug('Republish ' + eventUuids.size() + ' failed event(s).');
            EventBus.publish(events, this);
            System.debug('Republish event for Order with Ids: ' +
                         String.join(uuidMap.values(), ', '));
            
            // Increase counter
            retryCounter++;
        } else {
            // Retry exhausted, log an error instead
            System.debug(eventUuids.size() + ' event(s) failed to publish after ' +
                         MAX_RETRIES + ' retries ' +
                         'for Order with Ids: ' + String.join(uuidMap.values(), ', '));
        }
    }
    
    // Getter methods so we can validate this in the unit test
    public Integer getRetryCounter() {
        return retryCounter;
    }
    public Map<String,String> getUuidMap() {
        return uuidMap;
    }
}