import { LightningElement, wire } from 'lwc';
import getExpenses from '@salesforce/apex/CustomDatatableService.getExpenses';
import LOGOTYPE from "@salesforce/resourceUrl/Logo";

const COLUMNS = [
    
    {
        label: 'Expense',
        fieldName: 'linkName',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_self'
        }
    },
    { label: 'Status', fieldName: 'Status__c', type: 'text' },
    {
        label: 'Responsible',
        fieldName: 'Responsible__с',
        type: 'lookup',
        typeAttributes: {
            object: 'Expense__c',
            fieldName: 'Responsible__c',
            label: 'Responsible__c',
            value: { fieldName: 'Responsible__c' },
            context: { fieldName: 'Id' },
            variant: 'label-hidden',
            name: 'Responsible__c',
            fields: ['Employee__c.Name'],
            target: '_self'
        },
    },
    {
        label: 'Trip',
        fieldName: 'Trip__c',
        type: 'lookup',
        typeAttributes: {
            object: 'Expense__c',
            fieldName: 'Trip__c',
            label: 'Trip__c',
            value: { fieldName: 'Trip__c' },
            context: { fieldName: 'Id' },
            variant: 'label-hidden',
            name: 'Trip__c',
            fields: ['Trip__c.Name'],
            target: '_self'
        },
    },
    { label: 'Cost', fieldName: 'Cost__c', type: 'currency' },
    { label: 'Total Paid Amount', fieldName: 'Total_Paid_Amount__c', type: 'currency' },
    { label: 'Total Unpaid Employees', fieldName: 'Total_Unpaid_Employees__c', type: 'number' },
];

export default class CustomDatatableDemo extends LightningElement {
    columns = COLUMNS;
    records;
    error;
    wiredRecords;

    logoImage = LOGOTYPE;

    @wire(getExpenses)
    wiredRelatedRecords(result) {
        this.wiredRecords = result;
        const { data, error } = result;
        if (data) {
            this.records = JSON.parse(JSON.stringify(data));
            this.records.forEach(record => {
                record.linkName = '/' + record.Name;
            });
            this.error = undefined;
        } else if (error) {
            this.records = undefined;
            this.error = error;
        }
    }

    connectedCallback(){
        console.log('test');
    }
}