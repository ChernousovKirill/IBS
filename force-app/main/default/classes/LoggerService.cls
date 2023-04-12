public with sharing class LoggerService {

    public static void saveApexLog (String title, String description){

        Database.insert(getApexLog(title, description), false);

    }

    public static Logger__c getApexLog (String title, String description){

        Logger__c log = new Logger__c(
                Title__c = title,
                Description__c = description
        );

        return log;
    }

}