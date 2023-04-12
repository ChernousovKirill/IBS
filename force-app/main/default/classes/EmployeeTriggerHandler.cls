public with sharing class EmployeeTriggerHandler {
    
    public void onBeforeInsert( List<Employee__c> listOfEmployees){
        validationOfIdAndPassportTypeUniqueness(listOfEmployees);
    }

    public void onBeforeUpdate( Map<Id,Employee__c> oldMap, Map<Id,Employee__c> newMap){

        List<Employee__c> listOfUpdatedEmployees = new List<Employee__c>();

        if(!newMap.isEmpty()) {
            for(Employee__c employee :newMap.values()){
                if(employee.ID_Number__c != oldMap.get(employee.Id).ID_Number__c || employee.ID_Type__c != oldMap.get(employee.Id).ID_Type__c){
                    listOfUpdatedEmployees.add(employee);
                }
            }
            if(listOfUpdatedEmployees != null) {
                validationOfIdAndPassportTypeUniqueness(listOfUpdatedEmployees);
            }   
        }
    }

    private void validationOfIdAndPassportTypeUniqueness(List<Employee__c> listOfNewOrUpdatedEmployees) {

        Set<String> setOfPassportIds = new Set<String>();
        Set<String> serOfPassportTypes = new Set<String>();
        Set<String> setOfCombinationOfExistingPairs = new Set<String>();

        for(Employee__c employee : listOfNewOrUpdatedEmployees) {
            setOfPassportIds.add(employee.ID_Number__c);
            serOfPassportTypes.add(employee.ID_Type__c);
        }

        List<Employee__c> listOfExistingEmployees = [SELECT Id, ID_Number__c, ID_Type__c FROM Employee__c WHERE ID_Number__c IN :setOfPassportIds AND ID_Type__c IN : serOfPassportTypes];

        if(!listOfExistingEmployees.isEmpty()) {
            for(Employee__c employee : listOfExistingEmployees) {
                String existingPairOfNumberAndType = employee.ID_Number__c + employee.ID_Type__c;
                setOfCombinationOfExistingPairs.add(existingPairOfNumberAndType);
            }
            for(Employee__c newEmployee : listOfNewOrUpdatedEmployees) {
                String newPairOfNumberAndType = newEmployee.ID_Number__c + newEmployee.ID_Type__c;
                if(setOfCombinationOfExistingPairs.contains(newPairOfNumberAndType)){
                    newEmployee.addError(System.Label.typeAndIdMustBeUnique);
                }
            }

        }
    }

}