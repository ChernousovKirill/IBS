@isTest
private class EmailServiceTest {
    @isTest
    static void testGetClassicEmailTemplates() {
        // Create test data
        List<EmailTemplate> templates = new List<EmailTemplate>{
            new EmailTemplate(DeveloperName='template1', Subject='Test 1', Body='Body 1'),
            new EmailTemplate(DeveloperName='template2', Subject='Test 2', Body='Body 2')
        };
        insert templates;
        
        // Call the method being tested
        List<String> developerNames = new List<String>{'template1', 'template2'};
        List<EmailTemplate> result = EmailService.getClassicEmailTemplates(developerNames);
        
        // Verify the results
        System.assertEquals(2, result.size());
        System.assertEquals('Test 1', result[0].Subject);
        System.assertEquals('Body 2', result[1].Body);
    }
    
    @isTest
    static void testCreateClassicSingleEmail() {
        // Create test data
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        EmailTemplate testTemplate = new EmailTemplate(DeveloperName='testTemplate', Subject='Test Subject', Body='Test Body');
        insert testTemplate;
        
        // Call the method being tested
        Messaging.SingleEmailMessage result = EmailService.createClassicSingleEmail(testAccount.Id, testTemplate.Id, null, 'test@example.com');
        
        // Verify the results
        System.assertEquals(testAccount.Id, result.getTargetObjectId());
        System.assertEquals(testTemplate.Id, result.getTemplateId());
        System.assertEquals(null, result.getWhatId());
        System.assertEquals('test@example.com', result.getToAddresses()[0]);
    }
    
    @isTest
    static void testSendListOfEmails() {
        // Create test data
        Messaging.SingleEmailMessage testEmail = new Messaging.SingleEmailMessage();
        testEmail.setToAddresses(new String[]{'test@example.com'});
        List<Messaging.SingleEmailMessage> testList = new List<Messaging.SingleEmailMessage>{testEmail};
        
        // Call the method being tested
        Test.startTest();
        EmailService.sendListOfEmails(testList);
        Test.stopTest();
        
        // Verify the results
        List<EmailMessage> messages = [SELECT Id FROM EmailMessage];
        System.assertEquals(1, messages.size());
        System.assertEquals('test@example.com', messages[0].ToAddress);
    }
    
    @isTest
    static void testGetExpenseDistributions() {
        // Create test data
        Expense__c testExpense = new Expense__c(Cost__c=100.0);
        insert testExpense;
        Employee__c testEmployee = new Employee__c(Name='Test Employee');
        insert testEmployee;
        Expense_Distribution__c testDistribution = new Expense_Distribution__c(
            Expense__c=testExpense.Id,
            Employee__c=testEmployee.Id,
            Paid_Amount__c=25.0
        );
        insert testDistribution;
        
        // Call the method being tested
        List<Expense_Distribution__c> result = EmailService.getExpenseDistributions();
        
        // Verify the results
        System.assertEquals(1, result.size());
        System.assertEquals('Test Employee', result[0].Employee__r.Name);
        System.assertEquals('Test Expense', result[0].Expense__r.Name);
        System.assertEquals(25.0, result[0].Paid_Amount__c);
    }
}