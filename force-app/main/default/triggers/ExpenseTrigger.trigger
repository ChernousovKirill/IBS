trigger ExpenseTrigger on Expense__c (after update, after insert, before delete) {
    ExpenseTriggerHandler triggerHandler = new ExpenseTriggerHandler();
    if(Trigger.isAfter) {
        if (Trigger.isUpdate) {
            triggerHandler.onAfterUpdate(Trigger.oldMap,Trigger.newMap);
        } else if (Trigger.isInsert) {
            triggerHandler.onAfterInsert(Trigger.new);
        }
    }
    if(Trigger.isBefore) {
        if(Trigger.isDelete) {
            triggerHandler.onBeforeDelete(Trigger.old);
        }
    }
}