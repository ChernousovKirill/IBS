public with sharing class EmailService {
  
    public static List<EmailTemplate> getClassicEmailTemplates(List<String> listOfDeveloperNames) {
        return [
            SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
            FROM EmailTemplate
            WHERE DeveloperName IN:listOfDeveloperNames
        ];
    }

    public static Messaging.SingleEmailMessage createClassicSingleEmail(Id targetObjectId, Id templateId, Id whatId, String email) {
        System.debug('email ' + email);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(targetObjectId);
        mail.setTemplateId(templateId);
        mail.setWhatId(whatId);
        if(email !=null) {
            mail.setToAddresses(new String[] { email });
        }
        mail.setBccSender(false);
        mail.setSaveAsActivity(false);

        return mail;
    }

    public static void sendListOfEmails(List<Messaging.SingleEmailMessage> listOfSingleEmailMessages) {
        try {
            if(!listOfSingleEmailMessages.isEmpty()){
                Messaging.sendEmail(listOfSingleEmailMessages);
            }
        } catch (Exception e) {
            LoggerService.saveApexLog('Payment email not delivered', e.getMessage());
        }
    }

    public static List<Expense_Distribution__c> getExpenseDistributions() {
        return [SELECT Id, Name, Employee__c, Employee__r.Name, Expense__c, Expense__r.Name, Amount__c, Paid_Amount__c FROM Expense_Distribution__c];
    }
    
}