import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import findAccounts from '@salesforce/apex/automateAccountCreationContoller.findAccounts';
import findAccounts2 from '@salesforce/apex/automateAccountCreationContoller.findAccounts';
import { getRecord } from 'lightning/uiRecordApi';
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Account_Approval__c.Account_Name__c';
import Inactive from '@salesforce/resourceUrl/Inactive';
import Active from '@salesforce/resourceUrl/Active';
// import createNewAccounts from '@salesforce/apex/automateAccountCreationContoller.createNewAccounts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DuplicateViewOfAccounts extends NavigationMixin(LightningElement) {
    @api recordId;
    @track accounts = [];
    accountName;
    @track disabledButton = false;
    @track accountName2 = '';
    @track accounts2 = [];
    @track Inactive = Inactive;
    @track Active = Active;

    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_NAME_FIELD] })
    wiredAccount({ error, data }) {
        if (data) {
            this.accountName = data.fields.Account_Name__c.value;
            this.searchForAccounts();
        } else if (error) {
            console.error('Error fetching account record', error);
        }
    }

    searchForAccounts() {
        if (this.accountName && this.accountName.length > 0) {
            findAccounts({ accountName: this.accountName })
                .then(result => {
                    this.accounts = result.map(acc => {
                        const isActiveImage = acc.Is_Active__c && acc.Is_Active__c.includes('/resource/') && acc.Is_Active__c.includes('Active');
                        console.log('isActiveImage',isActiveImage);
                        return {
                            ...acc,
                            OwnerName: acc.Owner.Name,
                            AccountClassification: acc.Account_Classification__c,
                            IsActives: isActiveImage ? 
                            { 
                                url: this.Active, 
                                alt: 'Active'
                            } : 
                            { 
                                url: this.Inactive, 
                                alt: 'Inactive'
                            }
                        };
                    });

                    this.disabledButton = this.accounts.length > 0;
                })
                .catch(error => {
                    console.error('Error:', error);
                    this.accounts = [];
                });
        } else {
            this.accounts = [];
        }
    }

    handleRowAction(event) {
        event.preventDefault(); // Prevent the default anchor tag behavior

        const accountId = event.target.dataset.id;
        console.log('Navigating to Account ID:', accountId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: accountId,
                objectApiName: 'Account',
                actionName: 'view',
            },
        });
    }

    

    handleInputChange(event) {
        this.accountName2 = event.target.value;
        console.log('this.accountName2',this.accountName2);
        this.searchForAccounts__2();
    }

    searchForAccounts__2() {
        console.log('this.accountName233',this.accountName2);
        if (this.accountName2.length > 0) {
            findAccounts2({ accountName: this.accountName2 })
                .then(result => {
                    console.log('this.accountName2455 result::',this.accountName2);
                    this.accounts2 = result.map(acc => {
                        const isActiveImage = acc.Is_Active__c && acc.Is_Active__c.includes('/resource/') && acc.Is_Active__c.includes('Active');
                        console.log('isActiveImage',isActiveImage);
                        console.log('accounts2t::',this.accounts2);
                        return {
                            ...acc,
                            OwnerName: acc.Owner.Name,
                            AccountClassification: acc.Account_Classification__c,
                            IsActives: isActiveImage ? 
                            { 
                                url: this.Active, 
                                alt: 'Active'
                            } : 
                            { 
                                url: this.Inactive, 
                                alt: 'Inactive'
                            }
                        };
                        
                    });
                    console.log('Mapped accounts2:', this.accounts2);
                })
                .catch(error => {
                    console.error('Error:', error);
                    this.accounts2 = [];
                });
        } else {
            this.accounts2 = [];
        }
    }
    //navigate to created account
    // handleCreateAccount() {
    //     createNewAccounts({ approvalIds: [this.recordId] })
    //         .then(result => {
    //             if (result && result.length > 0) {
    //                 // Navigate to the newly created Account record
    //                 this[NavigationMixin.Navigate]({
    //                     type: 'standard__recordPage',
    //                     attributes: {
    //                         recordId: result[0], // Assuming one account is created
    //                         objectApiName: 'Account',
    //                         actionName: 'view'
    //                     }
    //                 });

    //                 // Show success message
    //                 this.dispatchEvent(
    //                     new ShowToastEvent({
    //                         title: 'Success',
    //                         message: 'Account created successfully!',
    //                         variant: 'success'
    //                     })
    //                 );
    //             }
    //         })
    //         .catch(error => {
    //             // Handle error
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Error creating account',
    //                     message: error.body.message,
    //                     variant: 'error'
    //                 })
    //             );
    //         });
    // }

}