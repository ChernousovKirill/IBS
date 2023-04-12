@isTest
private class CustomDatatableServiceTest {
    
 @TestSetup
    static void setUp() {

        /*Employee__c newEmployee = new Employee__c(Name = 'Test Name', First_Name__c = 'Test First', Last_Name__c = 'Test Last', ID_Number__c= '777', ID_Type__c = 'Passport');
        insert newEmployee;

		Trip__c newTrip = new Trip__c(Name = 'Test Trip', Description__c = 'Test Description', Designation__c = 'Test Designation');
        insert newTrip;*/
    }
	@IsTest
    static void getExpensesTest() {

		Employee__c newEmployee = new Employee__c(Name = 'Test Name', First_Name__c = 'Test First', Last_Name__c = 'Test Last', ID_Number__c= '777', ID_Type__c = 'Passport');
        insert newEmployee;

		Expense__c newExpense = new Expense__c(Responsible__c = newEmployee.Id, Status__c = 'New', Cost__c = 10000);
        insert newExpense;

		List<Expense__c> listOfExpenses = CustomDatatableService.getExpenses();
		System.assertEquals(1, listOfExpenses.size());
    }

	@IsTest
    static void getTripsTest() {

		Trip__c newTrip = new Trip__c(Name = 'Test Trip', Description__c = 'Test Description', Designation__c = 'Test Designation');
        insert newTrip;

		List<Trip__c> listOfTrips = CustomDatatableService.getTrips();
		System.assertEquals(1, listOfTrips.size());
    }

	@IsTest
    static void getExpenseDistributionTest() {

		Employee__c newEmployee = new Employee__c(Name = 'Test Name', First_Name__c = 'Test First', Last_Name__c = 'Test Last', ID_Number__c= '777', ID_Type__c = 'Passport');
        insert newEmployee;

		Expense__c newExpense = new Expense__c(Responsible__c = newEmployee.Id, Status__c = 'New', Cost__c = 10000);
        insert newExpense;

		Expense_Distribution__c newExpenseDistributions = new Expense_Distribution__c(Employee__c = newEmployee.Id, Expense__c = newExpense.Id, Paid_Amount__c = 100);
        insert newExpenseDistributions;

		List<Expense_Distribution__c> listOfExpenseDistributions = CustomDatatableService.getExpenseDistributions();
		System.assertEquals(1, listOfExpenseDistributions.size());
    }

    @IsTest
    static void saveExpenseDistributionValuesTest(){
		Employee__c newEmployee = new Employee__c(Name = 'Test Name', First_Name__c = 'Test First', Last_Name__c = 'Test Last', ID_Number__c= '777', ID_Type__c = 'Passport');
        insert newEmployee;

		Expense__c newExpense = new Expense__c(Responsible__c = newEmployee.Id, Status__c = 'New', Cost__c = 10000);
        insert newExpense;

		Expense_Distribution__c newExpenseDistributions = new Expense_Distribution__c(Employee__c = newEmployee.Id, Expense__c = newExpense.Id, Paid_Amount__c = 100);

        List<Expense_Distribution__c> listOfNewExpenseDistributions = new List<Expense_Distribution__c>();
		listOfNewExpenseDistributions.add(newExpenseDistributions);
		insert listOfNewExpenseDistributions;
        for(Expense_Distribution__c item : listOfNewExpenseDistributions) {
			item.Paid_Amount__c = 200;
		}
		CustomDatatableService.saveExpenseDistributionValues(listOfNewExpenseDistributions);
		System.assertEquals(200, listOfNewExpenseDistributions[0].Paid_Amount__c);
	}

	@IsTest
    static void deleteExpenseDistributionRecordTest() {
	
		Expense__c newExpense = new Expense__c(Status__c = 'New', Cost__c = 10000);
        insert newExpense;
		
		Expense_Distribution__c newExpenseDistributions = new Expense_Distribution__c(Expense__c = newExpense.Id, Paid_Amount__c = 100);
		List<Expense_Distribution__c> listOfNewExpenseDistributions = new List<Expense_Distribution__c>();
		listOfNewExpenseDistributions.add(newExpenseDistributions);
		List<Id> listOfExpenseDistributionId = new List<Id>();
		for(Expense_Distribution__c item : listOfNewExpenseDistributions) {
			listOfExpenseDistributionId.add(item.Id);
		}
		CustomDatatableService.deleteExpenseDistributionRecord(listOfExpenseDistributionId);
		List<Expense_Distribution__c> listOfItems = [SELECT Id FROM Expense_Distribution__c WHERE Id IN :listOfExpenseDistributionId];
		System.assertEquals(0, listOfItems.size());

	}

	@IsTest
	static void sendEmailWithExpensesTest(){

	  List<EmailTemplate> listOfEmailTemplates = EmailService.getClassicEmailTemplates(new List<String>{'Final_Email_with_Expenses'});
      Id idOfUser = UserInfo.getUserId();
	  String email = 'test.mail@mail.com';
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