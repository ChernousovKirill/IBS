public with sharing class ExpenseDistributionTriggerHandler {
    
    public void onAfterInsert(List<Expense_Distribution__c> listOfNewExpenseDistribution) {
        sendEmailNotificationWhenExpenseDistributionPaid(listOfNewExpenseDistribution);
    }

    public void onAfterUpdate(Map<Id,Expense_Distribution__c> oldMap, Map<Id,Expense_Distribution__c> newMap) {
        List<Expense_Distribution__c> listOfUpdatedExpenseDistributions = new List<Expense_Distribution__c>();

        if(!newMap.isEmpty()) {
            for(Expense_Distribution__c expenseDistributions :newMap.values()){
                if(expenseDistributions.is_Full_Amount_Paid__c != oldMap.get(expenseDistributions.Id).is_Full_Amount_Paid__c){
                    listOfUpdatedExpenseDistributions.add(expenseDistributions);
                }
            }
        }
        if(listOfUpdatedExpenseDistributions != null) {
            sendEmailNotificationWhenExpenseDistributionPaid(listOfUpdatedExpenseDistributions);
        } 
    }

    private void sendEmailNotificationWhenExpenseDistributionPaid(List<Expense_Distribution__c> listOfNewOrUpdatedExpenseDistribution) {
        System.debug('im here');
        Map<Id, List<Expense_Distribution__c>> mapOfExpensesForEmailById = new Map<Id, List<Expense_Distribution__c>>();
        Set<Id> setOfExpenseDistribution = new Set<Id>();

        for(Expense_Distribution__c expenseDistribution : listOfNewOrUpdatedExpenseDistribution) {
            setOfExpenseDistribution.add(expenseDistribution.Id);
        }
        List<Expense_Distribution__c> listOExpenseDistribution = [SELECT Id, is_Full_Amount_Paid__c, Employee__c, Employee__r.Contact__c FROM Expense_Distribution__c WHERE Id IN :setOfExpenseDistribution];
        for(Expense_Distribution__c expenseDistribution : listOExpenseDistribution) {
            if(expenseDistribution.is_Full_Amount_Paid__c == true) {
                mapOfExpensesForEmailById.put(expenseDistribution.Id, new List<Expense_Distribution__c>{expenseDistribution});
            }
        }
        System.debug('mapOfExpensesForEmailById ' + mapOfExpensesForEmailById);

        List<EmailTemplate> listOfEmailTemplates = EmailService.getClassicEmailTemplates(new List<String>{'Expense_Distribution_was_paid'});

        if(!listOfEmailTemplates.isEmpty()) {
            List<Messaging.SingleEmailMessage> listOfSingleEmailMessages = new List<Messaging.SingleEmailMessage>();

            for (Id expenseDistributionId : mapOfExpensesForEmailById.keySet()) {
                for (Expense_Distribution__c expenseDistribution : mapOfExpensesForEmailById.get(expenseDistributionId)) {
                    listOfSingleEmailMessages.add(EmailService.createClassicSingleEmail(
                        expenseDistribution.Employee__r.Contact__c, 
                        listOfEmailTemplates.get(0).Id, 
                        expenseDistributionId,
                        null
                    ));
                }
            }

            EmailService.sendListOfEmails(listOfSingleEmailMessages);
        }

    }
}