public with sharing class CustomDatatableService {

    @AuraEnabled(cacheable=true)
    public static List<Expense__c> getExpenses() {
      return [SELECT Id, Name, Cost__c, Responsible__c, Responsible__r.Name, Status__c,
                     Total_Paid_Amount__c, Total_Unpaid_Employees__c, Trip__c, Trip__r.Name
              FROM Expense__c];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Trip__c> getTrips() {
      return [SELECT Id, Name, Designation__c, Start_Date__c, End_Date__c, Total_Cost__c, Total_Days__c, Total_Participants__c, Total_Vacation_Days_Required__c FROM Trip__c];
    }

    @AuraEnabled(cacheable=true)
    public static List<Expense_Distribution__c> getExpenseDistributions() {
      return [SELECT Id, Name, Employee__c, Employee__r.Name, Expense__c, Expense__r.Name, Amount__c, Paid_Amount__c FROM Expense_Distribution__c];
    }

    @AuraEnabled
    public static void saveExpenseDistributionValues(Object data) {
        List<Expense_Distribution__c> listOfExpenseDistribution = (List<Expense_Distribution__c>) JSON.deserialize(
            JSON.serialize(data),
            List<Expense_Distribution__c>.class
        );
        upsert listOfExpenseDistribution;
    }

    @AuraEnabled
    public static void deleteExpenseDistributionRecord(List<Id> listOfExpenseDistributionId){
        delete [SELECT Id FROM Expense_Distribution__c WHERE Id IN :listOfExpenseDistributionId];
    }

    @AuraEnabled
    public static void sendEmailWithExpenses(String email){

      List<EmailTemplate> listOfEmailTemplates = EmailService.getClassicEmailTemplates(new List<String>{'Final_Email_with_Expenses'});
      Id idOfUser = UserInfo.getUserId();

      if(!listOfEmailTemplates.isEmpty()) {
        List<Messaging.SingleEmailMessage> listOfSingleEmailMessages = new List<Messaging.SingleEmailMessage>();
        listOfSingleEmailMessages.add(EmailService.createClassicSingleEmail(
                        idOfUser, 
                        listOfEmailTemplates.get(0).Id, 
                        idOfUser,
                        email
        ));
        EmailService.sendListOfEmails(listOfSingleEmailMessages);

      }

    }

  }

  