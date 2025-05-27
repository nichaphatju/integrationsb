@isTest
public class BatchApexErrorEventTriggerTest {
    
    @IsTest
    static void testHandleBatchApexErrorEvent() {
        // Create a test BatchApexErrorEvent
        BatchApexErrorEvent event = new BatchApexErrorEvent();
        event.AsyncApexJobId = '*';
        event.Message = 'Test error message';
        event.StackTrace = 'Test stack trace';
        event.JobScope = 'Test job scope';
        Database.insertImmediate(event);

        // Create a list of BatchApexErrorEvent
        List<BatchApexErrorEvent> events = new List<BatchApexErrorEvent>{event};

        // Call the handler method
        BatchApexErrorEventTriggerHandler handler = new BatchApexErrorEventTriggerHandler();
        handler.handleBatchApexErrorEvent(events);

        // Verify that an Error_Log__c record was created
        List<Error_Log__c> errorLogs = [SELECT Name, Async_Apex_Job_Id__c, Message__c, Stacktrace__c, Job_Scope__c FROM Error_Log__c];
        System.assertEquals(1, errorLogs.size());
        Error_Log__c errorLog = errorLogs[0];
        System.assertEquals('Batch Apex Error', errorLog.Name);
        System.assertEquals(event.AsyncApexJobId, errorLog.Async_Apex_Job_Id__c);
        System.assertEquals(event.Message, errorLog.Message__c);
        System.assertEquals(event.StackTrace, errorLog.Stacktrace__c);
        System.assertEquals(event.JobScope, errorLog.Job_Scope__c);
    }

}