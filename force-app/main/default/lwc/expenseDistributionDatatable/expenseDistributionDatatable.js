import { LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getExpenseDistributions from '@salesforce/apex/CustomDatatableService.getExpenseDistributions';
import saveExpenseDistributionValues from '@salesforce/apex/CustomDatatableService.saveExpenseDistributionValues';
import deleteExpenseDistributionRecord from '@salesforce/apex/CustomDatatableService.deleteExpenseDistributionRecord';
import sendEmailWithExpenses from '@salesforce/apex/CustomDatatableService.sendEmailWithExpenses'
import { NavigationMixin } from 'lightning/navigation';
import LOGOTYPE from "@salesforce/resourceUrl/Logo";

const actions = [
    { label: 'Delete', name: 'delete' },
  ];

const newExpense = {
    Employee__c: '',
    Expense__c: '',
    Amount__c: 0
};
const COLUMNS = [
    
    {
        label: 'Number',
        fieldName: 'linkName',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_self'
        }
    },
    {
        label: 'Employee',
        fieldName: 'Employee__c',
        type: 'lookup',
        typeAttributes: {
            object: 'Expense_Distribution__c',
            fieldName: 'Employee__c',
            label: 'Employee__c',
            value: { fieldName: 'Employee__c' },
            context: { fieldName: 'Id' },
            variant: 'label-hidden',
            name: 'Employee__c',
            fields: ['Employee__c.Name'],
            target: '_self',
            editable: 'true'
        },
        cellAttributes: {
            class: { fieldName: 'employeeNameClass' }
        }
    },
    {
        label: 'Expense',
        fieldName: 'Expense__c',
        type: 'lookup',
        typeAttributes: {
            object: 'Expense_Distribution__c',
            fieldName: 'Expense__c',
            label: 'Expense__c',
            value: { fieldName: 'Expense__c' },
            context: { fieldName: 'Id' },
            variant: 'label-hidden',
            name: 'Expense__c',
            fields: ['Expense__c.Name'],
            target: '_self',
            editable: 'true'
        },
        cellAttributes: {
            class: { fieldName: 'expenseNameClass' }
        }
    },
    { label: 'Amount', fieldName: 'Amount__c', type: 'currency' },
    { label: 'Paid Amount', fieldName: 'Paid_Amount__c', type: 'currency', editable:true},
    {
        type: 'action',
        typeAttributes:
        {
            rowActions: actions,
        },
        fixedWidth: 50,
    },
];

const COLUMNS_MODAL = [
    { label: 'Number', fieldName: 'Name', type: 'text' },
    { label: 'Employee', fieldName: 'Employee__c', type: 'text' },
    { label: 'Expense', fieldName: 'Employee__c', type: 'text'},
    { label: 'Amount', fieldName: 'Amount__c', type: 'currency' },
    { label: 'Paid Amount', fieldName: 'Paid_Amount__c', type: 'currency'},
];

export default class CustomDatatableDemo extends NavigationMixin(LightningElement) {
    columns = COLUMNS;
    columnsModal = COLUMNS_MODAL;
    records;
    error;
    wiredRecords;
    expenseDestributionId;
    lastSavedData;
    numberOfExpenseDistributionToDelete;
    emailFieldValue;
    idOfExpenseDistributionToDelete = [];
    dataModal = [];
    
    draftValues = [];
    privateChildren = {}; 

    logoImage = LOGOTYPE;

    @track isShowDeleteModal = false;
    @track isShowSaveModal = false;
    @track isShowEmailModal = false;


    @wire(getExpenseDistributions)
    wiredRelatedRecords(result) {
        this.wiredRecords = result;
        const { data, error } = result;
        if (data) {
            this.records = JSON.parse(JSON.stringify(data));
            this.records.forEach(record => {
                record.linkName = '/' + record.Id;
                record.employeeNameClass = 'slds-cell-edit';
                record.expenseNameClass = 'slds-cell-edit';
            });
            this.error = undefined;
        } else if (error) {
            this.records = undefined;
            this.error = error;
        }
    }

    renderedCallback() {
        if (!this.isComponentLoaded) {
            /* Add Click event listener to listen to window click to reset the lookup selection 
            to text view if context is out of sync*/
            window.addEventListener('click', (evt) => {
                this.handleWindowOnclick(evt);
            });
            this.isComponentLoaded = true;
        }
    }

    disconnectedCallback() {
        window.removeEventListener('click', () => { });
    }

    handleWindowOnclick(context) {
        this.resetPopups('c-datatable-lookup', context);
    }

    //create object value of datatable lookup markup to allow to call callback function with window click event listener
    resetPopups(markup, context) {
        let elementMarkup = this.privateChildren[markup];
        if (elementMarkup) {
            Object.values(elementMarkup).forEach((element) => {
                element.callbacks.reset(context);
            });
        }
    }

    // Event to register the datatable lookup mark up.
    handleItemRegister(event) {
        event.stopPropagation(); //stops the window click to propagate to allow to register of markup.
        const item = event.detail;
        if (!this.privateChildren.hasOwnProperty(item.name))
            this.privateChildren[item.name] = {};
        this.privateChildren[item.name][item.guid] = item;
    }

    handleChange(event) {
        event.preventDefault();
        this.expenseDestributionId = event.target.value;
    }

    handleCancel(event) {
        event.preventDefault();
        this.records = JSON.parse(JSON.stringify(this.lastSavedData));
        this.handleWindowOnclick('reset');
        this.draftValues = [];
    }

    handleCellChange(event) {
        event.preventDefault();
        console.log('update ' , JSON.stringify(event.detail.id));
        this.updateDraftValues(event.detail.draftValues[0]);
    }

    //Captures the changed lookup value and updates the records list variable.
    handleValueChange(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let updatedItem;
        switch (dataRecieved.label) {
            case 'Employee__c':
                updatedItem = {
                    Id: dataRecieved.context,
                    Employee__c: dataRecieved.value
                };
                // Set the cell edit class to edited to mark it as value changed.
                this.setClassesOnData(
                    dataRecieved.context,
                    'employeeNameClass',
                    'slds-cell-edit slds-is-edited'
                );
                break;
            case 'Expense__c':
                updatedItem = {
                    Id: dataRecieved.context,
                    Expense__c: dataRecieved.value
                };
                this.setClassesOnData(
                    dataRecieved.context,
                    'expenseNameClass',
                    'slds-cell-edit slds-is-edited'
                );
                break;
            default:
                this.setClassesOnData(dataRecieved.context, '', '');
                break;
        }
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

    updateDataValues(updateItem) {
        let copyData = JSON.parse(JSON.stringify(this.records));
        copyData.forEach((item) => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });
        this.records = [...copyData];
    }

    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = JSON.parse(JSON.stringify(this.draftValues));
        copyDraftValues.forEach((item) => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
        console.log('>>> ' , JSON.parse(JSON.stringify(this.draftValues)));

    }

    handleEdit(event) {
        event.preventDefault();
        let dataRecieved = event.detail.data;
        console.log('dataRecieved ' + JSON.stringify(dataRecieved));
        this.handleWindowOnclick(dataRecieved.context);
        switch (dataRecieved.label) {
            case 'Employee__c':
                this.setClassesOnData(
                    dataRecieved.context,
                    'employeeNameClass',
                    'slds-cell-edit'
                );
                break;
                case 'Expense__c':
                    this.setClassesOnData(
                        dataRecieved.context,
                        'expenseNameClass',
                        'slds-cell-edit'
                    );
                    break;
            default:
                this.setClassesOnData(dataRecieved.context, '', '');
                break;
        };
    }

    setClassesOnData(id, fieldName, fieldValue) {
        this.records = JSON.parse(JSON.stringify(this.records));
        this.records.forEach((detail) => {
            if (detail.Id === id) {
                detail[fieldName] = fieldValue;
            }
        });
    }

    handleSave(event) {
        event.preventDefault();
        this.isShowSaveModal = true;
        this.records.forEach(record => {
            let draftRecord = this.draftValues.find(draft => draft.Id === record.Id);
            if(draftRecord) {
                if (draftRecord && draftRecord.Paid_Amount__c && !draftRecord.Employee__c) {
                this.dataModal.push({
                    Id: draftRecord.Id,
                    Employee__c: record.Employee__r.Name,
                    Expense__c: record.Expense__r.Name,
                    Paid_Amount__c: draftRecord.Paid_Amount__c,
                    Amount__c: record.Amount__c,
                    Name: record.Name,
                });
                } else if ((draftRecord && draftRecord.Employee__c && !draftRecord.Paid_Amount__c)){
                    this.dataModal.push({
                        Id: draftRecord.Id,
                        Employee__c: draftRecord.Employee__c,
                        Expense__c: record.Expense__c.Name,
                        Paid_Amount__c: record.Paid_Amount__c,
                        Amount__c: record.Amount__c,
                        Name: record.Name,
                    });
                } else if ((draftRecord && draftRecord.Employee__c && draftRecord.Paid_Amount__c)){
                    this.dataModal.push({
                        Id: draftRecord.Id,
                        Employee__c: draftRecord.Employee__c,
                        Expense__c: record.Expense__r.Name,
                        Paid_Amount__c: draftRecord.Paid_Amount__c,
                        Amount__c: record.Amount__c,
                        Name: record.Name,
                    });
                }
            }
        });
    }

    handleSaveFromModal(event) {
        event.preventDefault();
        // Update the draftvalues
        console.log('this.draftValues  ' + JSON.stringify(this.dataModal));
        saveExpenseDistributionValues({ data: this.draftValues })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Expense Distributions updated successfully',
                        variant: 'success'
                    })
                );
                //Get the updated list with refreshApex.
                refreshApex(this.wiredRecords).then(() => {
                    this.records.forEach(record => {
                        record.employeeNameClass = 'slds-cell-edit';
                        record.expenseNameClass = 'slds-cell-edit';
                    });
                    this.draftValues = [];
                });
                this.isShowSaveModal = false;
                this.isShowEmailModal = true;
            })
            .catch(error => {
                console.log('error : ' + JSON.stringify(error));
            });
    }

    handleRowActions(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                this.numberOfExpenseDistributionToDelete = row.Name;
                this.idOfExpenseDistributionToDelete = row.Id;
                this.isShowDeleteModal = true;
        }
    }

    hideDeleteModalBox() {  
        this.isShowDeleteModal = false;
    }

    hideSaveModalBox() {
        this.isShowSaveModal = false;
    }

    hideEmailModalBox() {
        this.isShowEmailModal = false;
    }

    handleExpenseDistributionDelete(event){
        event.preventDefault();
        // Update the draftvalues
        console.log('this.draftValues  ' + JSON.stringify(this.idOfExpenseDistributionToDelete));
        deleteExpenseDistributionRecord({ listOfExpenseDistributionId: this.idOfExpenseDistributionToDelete })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Expense Distributions updated successfully',
                        variant: 'success'
                    })
                );
                this.isShowDeleteModal = false;
                refreshApex(this.wiredRecords).then(() => {
                    this.records.forEach(record => {
                        record.employeeNameClass = 'slds-cell-edit';
                        record.expenseNameClass = 'slds-cell-edit';
                    });
                    this.draftValues = [];
                });
            })
            .catch(error => {
                console.log('error : ' + JSON.stringify(error));
            });
     }

     navigateToNewExpenseDistributionPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Expense_Distribution__c',
                actionName: 'new'
            },
        });
    }

    handleEmailChange(event){
        this.emailFieldValue = event.target.value;
        console.log('this.emailFieldValue ' + this.emailFieldValue);
    }

    handleSendEmail(event){
        sendEmailWithExpenses({ email: this.emailFieldValue});
        this.isShowEmailModal = false;
    }
}