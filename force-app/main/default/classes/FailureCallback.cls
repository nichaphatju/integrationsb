public class FailureCallback implements EventBus.EventPublishFailureCallback {
      
   public void onFailure(EventBus.FailureResult result) {
       // Your implementation
       // Get event UUIDs from the result
       List<String> eventUuids = result.getEventUuids();
       // ...
   }
       
}