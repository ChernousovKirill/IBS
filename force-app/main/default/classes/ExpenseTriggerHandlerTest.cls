@isTest
private class ExpenseTriggerHandlerTest {
    
    @isTest
    static void onAfterInsertTest() {

        ExpenseTriggerHandler triggerHandler = new ExpenseTriggerHandler();

        Trip__c newTrip = new Trip__c(Name =  'Test Name', Designation__c = 'Test Designation', Description__c = 'Test Description', Total_Cost__c = 0);
        insert newTrip;

		Expense__c newExpense = new Expense__c(Trip__c = newTrip.Id, Status__c = 'New', Cost__c = 10000);
        List<Expense__c> listOfNewExpenses =new List<Expense__c>();
        listOfNewExpenses.add(newExpense);
        insert listOfNewExpenses;

        Test.startTest();
        triggerHandler.onAfterInsert(listOfNewExpenses);
        Test.stopTest();
    }

    @IsTest
    static void onBeforeDeleteTest() {
        ExpenseTriggerHandler triggerHandler = new ExpenseTriggerHandler();

        Set<Id> setOfIds = new Set<Id>();

        Trip__c newTrip = new Trip__c(Name =  'Test Name', Designation__c = 'Test Designation', Description__c = 'Test Description', Total_Cost__c = 0);
        insert newTrip;

		Expense__c newExpense = new Expense__c(Trip__c = newTrip.Id, Status__c = 'New', Cost__c = 10000);
        List<Expense__c> listOfNewExpenses =new List<Expense__c>();
        listOfNewExpenses.add(newExpense);
        insert listOfNewExpenses;

        for(Expense__c item : listOfNewExpenses) {
            setOfIds.add(item.Id);
        }
        List<Expense__c> listOfOldExpense = [SELECT Id FROM Expense__c WHERE Id IN : setOfIds];
        Test.startTest();
        triggerHandler.onBeforeDelete(listOfOldExpense);
        delete listOfOldExpense;
        Test.stopTest();

    }

    @IsTest
    static void onAfterUpdateTest() {
        ExpenseTriggerHandler triggerHandler = new ExpenseTriggerHandler();
        

        Trip__c newTrip = new Trip__c(Name =  'Test Name', Designation__c = 'Test Designation', Description__c = 'Test Description', Total_Cost__c = 0);
        insert newTrip;

		Expense__c newExpense = new Expense__c(Trip__c = newTrip.Id, Status__c = 'New', Cost__c = 10000);
        List<Expense__c> listOfNewExpenses =new List<Expense__c>();
        List<Expense__c> listOfUpdateExpenses =new List<Expense__c>();

        Map<Id,Expense__c> oldMap = new Map<Id, Expense__c>();
         Map<Id,Expense__c> newMap = new Map<Id, Expense__c>();
        listOfNewExpenses.add(newExpense);
        insert listOfNewExpenses;

        for(Expense__c item : listOfNewExpenses) {
            oldMap.put(item.Id, item);
            item.Cost__c = 100;
            listOfUpdateExpenses.add(item);
        }
        update listOfUpdateExpenses;

        for(Expense__c item : listOfUpdateExpenses) {
            newMap.put(item.Id, item);
        }
        Test.startTest();
        triggerHandler.onAfterUpdate(oldMap, newMap);
        Test.stopTest();
    }
}