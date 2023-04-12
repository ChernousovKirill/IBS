import { LightningElement, wire } from 'lwc';
import getTrips from '@salesforce/apex/CustomDatatableService.getTrips';
import LOGOTYPE from "@salesforce/resourceUrl/Logo";

const COLUMNS = [
    
    {
        label: 'Trip',
        fieldName: 'linkName',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_self'
        }
    },
    { label: 'Designation', fieldName: 'Designation__c', type: 'text' },
    { label: 'Total Cost', fieldName: 'Total_Cost__c', type: 'currency' },
    {label: 'Start Date', fieldName: 'Start_Date__c', type: 'date-local',
    typeAttributes: {
        day: 'numeric',
        month: 'numeric',
        year: 'numeric'
    }},
    {label: 'End Date', fieldName: 'End_Date__c', type: 'date-local',
    typeAttributes: {
        day: 'numeric',
        month: 'numeric',
        year: 'numeric'
    }},
    { label: 'Total Participants', fieldName: 'Total_Participants__c', type: 'number' },
    { label: 'Total Days', fieldName: 'Total_Days__c', type: 'number' },
    { label: 'Total Vacation Days Required', fieldName: 'Total_Vacation_Days_Required__c', type: 'number' }
];

export default class CustomDatatableDemo extends LightningElement {
    columns = COLUMNS;
    records;
    error;
    wiredRecords;

    logoImage = LOGOTYPE;


    @wire(getTrips)
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
}