@isTest
private class EmployeeTriggerHandlerTest {
    @IsTest
    static void onBeforeUpdateTest() {

        EmployeeTriggerHandler triggerHandler = new EmployeeTriggerHandler();
        Map<Id,Employee__c> oldMap = new Map<Id, Employee__c>();
        Map<Id,Employee__c> newMap = new Map<Id, Employee__c>();

        List<Employee__c> listOfNewEmployees = new List<Employee__c>();
        for(Integer i = 0; i<10; i++) {
            Employee__c newEmployee = new Employee__c(Name = 'Name' + i, Last_Name__c = 'LastName' + i, First_Name__c = 'FirstName' + i, ID_Number__c = '555' + i, ID_Type__c = 'Passport');
            listOfNewEmployees.add(newEmployee);
        }
        insert listOfNewEmployees;

        for(Employee__c item : listOfNewEmployees) {
            oldMap.put(item.Id, item);
            item.Last_Name__c = 'Update Name';
        }
        update listOfNewEmployees;
        for(Employee__c item : listOfNewEmployees) {
            newMap.put(item.Id, item);
            item.Last_Name__c = 'Update Name';
        }
        Test.startTest();
        triggerHandler.onBeforeUpdate(oldMap, newMap);
        Test.stopTest();

     }
}