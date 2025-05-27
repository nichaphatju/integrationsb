trigger BatchApexErrorEventTrigger on BatchApexErrorEvent (after insert) {

    BatchApexErrorEventTriggerHandler handlr = new BatchApexErrorEventTriggerHandler();
    if (Trigger.isAfter && Trigger.isInsert) {
        handlr.handleBatchApexErrorEvent(Trigger.new);
    }
}