trigger ExpenseDistributionTrigger on Expense_Distribution__c (after insert, after update) {
    ExpenseDistributionTriggerHandler triggerHandler = new ExpenseDistributionTriggerHandler();
    if(Trigger.isAfter) {
         if (Trigger.isInsert) {
            triggerHandler.onAfterInsert(Trigger.new);
        } else if(Trigger.isUpdate) {
            triggerHandler.onAfterUpdate(Trigger.oldMap,Trigger.newMap);
        }
    }
}