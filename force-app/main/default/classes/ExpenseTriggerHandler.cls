public with sharing class ExpenseTriggerHandler {
    
    public void onAfterUpdate( Map<Id,Expense__c> oldMap, Map<Id,Expense__c> newMap) {
        List<Expense__c> listOfUpdatedExpenses = new List<Expense__c>();

        if(!newMap.isEmpty()) {
            for(Expense__c employee :newMap.values()){
                listOfUpdatedExpenses.add(employee);
            }
        }
        if(listOfUpdatedExpenses != null) {
            fillTotalParticipantsOfTrip(listOfUpdatedExpenses);
            updateAmountOfExpenseDistrubution(listOfUpdatedExpenses);
        }   
    }

    public void onAfterInsert(List<Expense__c> listOfNewExpenses) {
        fillTotalCostOfTrip(listOfNewExpenses);
    }

    public void onBeforeDelete(List<Expense__c> listOfOldExpenses) {
        deleteTotalCostOfTrip(listOfOldExpenses);
    }

    private void fillTotalCostOfTrip(List<Expense__c> listOfNewExpenses) {
        Map<Id, Decimal> mapOfTripByCost = new Map<Id, Decimal>();	
        for(Expense__c expense : listOfNewExpenses) {
            mapOfTripByCost.put(expense.Trip__c, expense.Cost__c);
        }

        List<Trip__c> listOfTrips = [SELECT Id, Total_Cost__c FROM Trip__c WHERE Id IN :mapOfTripByCost.keySet()];

        for(Trip__c trip : listOfTrips) {
            if(trip.Total_Cost__c == null){
                trip.Total_Cost__c = mapOfTripByCost.get(trip.Id);
            } else {
                trip.Total_Cost__c += mapOfTripByCost.get(trip.Id);
            }
        }

        update listOfTrips;
    }

    private void deleteTotalCostOfTrip(List<Expense__c> listOfOldExpenses) {
        Map<Id, Decimal> mapOfTripByCost = new Map<Id, Decimal>();	
        Set<Id> setOfExpenseId = new Set<Id>();
        for(Expense__c expense : listOfOldExpenses) {
            setOfExpenseId.add(expense.Id);
            //mapOfTripByCost.put(expense.Trip__c, expense.Cost__c);
        }
        List<Expense__c> listOfExpenses = [SELECT Id, Cost__c, Trip__c FROM Expense__c WHERE Id IN :setOfExpenseId];
        for(Expense__c expense : listOfExpenses) {
            mapOfTripByCost.put(expense.Trip__c, expense.Cost__c);
        }


        List<Trip__c> listOfTrips = [SELECT Id, Total_Cost__c FROM Trip__c WHERE Id IN :mapOfTripByCost.keySet()];

        for(Trip__c trip : listOfTrips) {
            trip.Total_Cost__c -= mapOfTripByCost.get(trip.Id);
        }

        update listOfTrips;
    }

    private void fillTotalParticipantsOfTrip(List<Expense__c> listOfExpenses) {

        Map<Id, Decimal> mapOfTripByNumberExpenseDistribution = new Map<Id, Decimal>();	
        for(Expense__c expense : listOfExpenses) {
            mapOfTripByNumberExpenseDistribution.put(expense.Trip__c, expense.Number_of_Expense_Distribution__c);
        }

        List<Trip__c> listOfTrips = [SELECT Id, Total_Participants__c FROM Trip__c WHERE Id IN :mapOfTripByNumberExpenseDistribution.keySet()];

        for(Trip__c trip : listOfTrips) {
            trip.Total_Participants__c = mapOfTripByNumberExpenseDistribution.get(trip.Id);
        }

        update listOfTrips;
    }

    private void updateAmountOfExpenseDistrubution(List<Expense__c> listOfExpenses) {

        Set<Id> setOfExpenseIds = new Set<Id>();
        
        for(Expense__c expense : listOfExpenses) {
            setOfExpenseIds.add(expense.Id);
        }
        List<Expense_Distribution__c> listOfExpenseDistribution = [SELECT Id, Expense__c,Amount__c, Expense__r.Number_of_Expense_Distribution__c, Expense__r.Cost__c FROM Expense_Distribution__c WHERE Expense__c IN : setOfExpenseIds];

        if(!listOfExpenseDistribution.isEmpty()){
            for(Expense_Distribution__c expenseDistribution : listOfExpenseDistribution) {
                expenseDistribution.Amount__c = expenseDistribution.Expense__r.Cost__c / expenseDistribution.Expense__r.Number_of_Expense_Distribution__c;
            }
            update listOfExpenseDistribution;
        }


    }
}