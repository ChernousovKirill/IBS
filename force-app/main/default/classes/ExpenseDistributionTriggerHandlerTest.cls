@isTest
private class ExpenseDistributionTriggerHandlerTest {
   
    @IsTest
    static void onAfterUpdateTest() {
        ExpenseDistributionTriggerHandler triggerHandler = new ExpenseDistributionTriggerHandler();

        Expense__c newExpense = new Expense__c(Status__c = 'New', Cost__c = 10000);
        insert newExpense;

        List<Expense_Distribution__c> listOfnewExpenseDistributions = new List<Expense_Distribution__c>();
        Expense_Distribution__c newExpenseDistributions = new Expense_Distribution__c(Expense__c = newExpense.Id, Paid_Amount__c = 100);
        listOfnewExpenseDistributions.add(newExpenseDistributions);
        insert listOfnewExpenseDistributions;

        Test.startTest();
        triggerHandler.onAfterInsert(listOfnewExpenseDistributions);
        Test.stopTest();
    }
}