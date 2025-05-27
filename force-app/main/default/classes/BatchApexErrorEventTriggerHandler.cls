public with sharing class BatchApexErrorEventTriggerHandler {
    public BatchApexErrorEventTriggerHandler() {

    }

    public void handleBatchApexErrorEvent(List<BatchApexErrorEvent> events) {
        // Handle the Batch Apex Error Event
        System.debug('Batch Apex Error Event: ' + events);

        for(BatchApexErrorEvent event : events) {
            // You can add your custom logic here to handle the error
            // For example, you might want to log the error or send a notification

            Error_Log__c errorLog = new Error_Log__c();
            errorLog.Name = 'Batch Apex Error';
            errorLog.Async_Apex_Job_Id__c = event.AsyncApexJobId;
            errorLog.Message__c = event.Message;
            errorLog.Stacktrace__c = event.StackTrace;
            errorLog.Job_Scope__c = event.JobScope;
            insert errorLog;
        }
        
    }

}