trigger EmployeeTrigger on Employee__c (before insert, before update) {

    EmployeeTriggerHandler triggerHandler = new EmployeeTriggerHandler();

    if(Trigger.isBefore) {
        if (Trigger.isUpdate) {
            triggerHandler.onBeforeUpdate(Trigger.oldMap,Trigger.newMap);
        } else if (Trigger.isInsert) {
            triggerHandler.onBeforeInsert(Trigger.new);
        }
    }

}