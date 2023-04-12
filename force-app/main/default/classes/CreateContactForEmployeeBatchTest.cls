@isTest
private class CreateContactForEmployeeBatchTest {

    @testSetup
    static void setup() {
        List<Employee__c> employees = new List<Employee__c>();
        for (Integer i = 0; i < 10; i++) {
            employees.add(new Employee__c(
                First_Name__c = 'TestFirstName' + i,
                Last_Name__c = 'TestLastName' + i,
                Email__c = 'testemail' + i + '@example.com'
            ));
        }
        insert employees;
    }

    @isTest
    static void testCreateContactForEmployeeBatch() {
        Test.startTest();
        CreateContactForEmployeeBatch.scheduleJob();
        Database.executeBatch(new CreateContactForEmployeeBatch(),200);
        Test.stopTest();

        // Verify that the Contact records were created and linked to the Employee records
        List<Employee__c> employees = [SELECT Id, Contact__c FROM Employee__c];
        System.assertEquals(10, employees.size());
        for (Employee__c employee : employees) {
            System.assertNotEquals(null, employee.Contact__c);
        }
    }

}