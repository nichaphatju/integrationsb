trigger OrderEventTrigger on Order_Event__e (after insert) {
    private Integer processedEventsCounter = 0;
    
    for (Order_Event__e event : Trigger.New) {
        try {
            // Enable testing exceptions. Runs only in test context.
            PlatformEventsTestUtil.forceExceptionForTesting();
            
            // Process event message.
            // ...
            
            // Set Replay ID after which to resume event processing
            // in a new trigger execution.
            EventBus.TriggerContext.currentContext().setResumeCheckpoint(
                event.ReplayId);
            System.debug('Processed event with Replay ID: ' + event.ReplayId);
            processedEventsCounter++;
           
        } catch(Exception e) {
            // This catch block works only for non-limit exceptions
            // because limit exceptions cannot be caught.
            //
            // If no events have been processed, throw new EventBus.RetryableException
            if (processedEventsCounter == 0) {
                // Only throw RetryableException when the first event
                // is processed but before setResumeCheckpoint is called.
                if (EventBus.TriggerContext.currentContext().retries <
                        PlatformEventsConstants.MAX_RETRIES) {
                    throw new EventBus.RetryableException();
                }
            }
            // This block is reached when catchable exception is received and
            // one of these statements is true:
            // - At least one event was processed.
            // - No event was processed but the number of retries
            //   for RetryableException is exhausted.
            //
            // Log the exception in the debug log. The trigger will
            // resume from the checkpoint if a checkpoint was set.
            System.debug('An exception occurred in OrderEventTrigger: ' + e.getTypeName());
            
            // Rethrow exception: Trigger exits and resumes with this event
            // as the first event in the batch of the new invocation.
            throw e;
        }
    }
}