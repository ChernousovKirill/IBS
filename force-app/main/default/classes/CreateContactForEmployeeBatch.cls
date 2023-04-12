global class CreateContactForEmployeeBatch implements Schedulable, Database.Batchable<SObject>  {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Contact__c, First_Name__c, Last_Name__c, Email__c FROM Employee__c WHERE Contact__c = null]);
    }

    global void execute(Database.BatchableContext bc, List<Employee__c> scope) {
        List<Employee__c> employeesToUpdate = new List<Employee__c>();

        for (Employee__c employee : scope) {
            Contact newContact = new Contact();
            newContact.FirstName = employee.First_Name__c;
            newContact.LastName = employee.Last_Name__c;
            newContact.Email = employee.Email__c;
            insert newContact;

            employee.Contact__c = newContact.Id;
            employeesToUpdate.add(employee);
        }

        update employeesToUpdate;
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Batch job finished successfully');
    }

    global void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(new CreateContactForEmployeeBatch());
    }
}