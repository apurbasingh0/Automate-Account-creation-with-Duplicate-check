import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import findAccounts from '@salesforce/apex/automateAccountCreationContoller.findAccounts';
import createAccountApproval from '@salesforce/apex/automateAccountCreationContoller.createAccountApproval';
import Inactive from '@salesforce/resourceUrl/Inactive';
import Active from '@salesforce/resourceUrl/Active';

export default class AutomateAccountCreation extends NavigationMixin(LightningElement) {
    @track isModalOpen = false;
    @track accountName = '';
    @track accounts = [];
    @track disabledButton = false;
   // @track disabledNextButton = true;
    @track showPage1 = true; 
    @track showPage2 = false; 
    @track Inactive = Inactive;
    @track Active = Active;


    handleInputChange(event) {
        this.accountName = event.target.value;
        this.searchForAccounts();
    }

    handleNext(){
        
        console.log('this.Accountname',this.accountName);
        if(this.accountName != null && this.accountName != '' ){
            this.showPage1 = false;
            this.showPage2 = true;
        }
        else{
            this.showToastMessage('Error', 'Please enter account name', 'error');
            //this.showToastMessage('Error', 'error', 'error');
            //this.showPage2 = false;
        }
            
    }

    handlePrevious(){
        this.showPage1 = true;
        this.showPage2 = false;
    }

    searchForAccounts() {
        if (this.accountName.length > 0) {
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

                    //restrict user to create duplicate account by diabled the button
                    if (this.accounts.length > 0) {
                        //this.disabledNextButton = true;
                        //this.disabledButton = true;
                        this.showToastMessage('Warning', 'Similar account(s) already exist.', 'warning');
                    } else {
                        //this.disabledNextButton = false;
                        //this.disabledButton = false;
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    this.accounts = [];
                });
        } else {
            this.accounts = [];
        }
    }

    handleSave() {
        this.disabledButton = false;
        const approvalDetails = {
            AccountName: this.accountName,
            AccountType: this.template.querySelector('[data-id="AccountType"]').value,
            AccountClassification: this.template.querySelector('[data-id="AccountClassification"]').value,
            Industry: this.template.querySelector('[data-id="Industry"]').value,
            AccountSite: this.template.querySelector('[data-id="AccountSite"]').value,
            AccountPotential: this.template.querySelector('[data-id="AccountPotential"]').value,
            BusinessPlanWCT: this.template.querySelector('[data-id="BusinessPlanWCT"]').value,
            BusinessPlanSWG: this.template.querySelector('[data-id="BusinessPlanSWG"]').value,
            BusinessPlanIAQ: this.template.querySelector('[data-id="BusinessPlanIAQ"]').value,
            BusinessPlanWD: this.template.querySelector('[data-id="BusinessPlanWD"]').value,
            BusinessPlanWaterHeater: this.template.querySelector('[data-id="BusinessPlanWaterHeater"]').value,
            BusinessPlanLighting: this.template.querySelector('[data-id="BusinessPlanLighting"]').value,
            BusinessPlanCMS: this.template.querySelector('[data-id="BusinessPlanCMS"]').value,
            AccountPotentialWCT: this.template.querySelector('[data-id="AccountPotentialWCT"]').value,
            AccountPotentialSWG: this.template.querySelector('[data-id="AccountPotentialSWG"]').value,
            AccountPotentialIAQ: this.template.querySelector('[data-id="AccountPotentialIAQ"]').value,
            AccountPotentialWD: this.template.querySelector('[data-id="AccountPotentialWD"]').value,
            AccountPotentialWaterHeater: this.template.querySelector('[data-id="AccountPotentialWaterHeater"]').value,
            AccountPotentialLighting: this.template.querySelector('[data-id="AccountPotentialLighting"]').value,
            AccountPotentialCMS: this.template.querySelector('[data-id="AccountPotentialCMS"]').value,
            CustomerFirstName: this.template.querySelector('[data-id="CustomerFirstName"]').value,
            CustomerLastName: this.template.querySelector('[data-id="CustomerLastName"]').value,
            EmailId: this.template.querySelector('[data-id="EmailId"]').value,
            MobileNo: this.template.querySelector('[data-id="MobileNo"]').value
        };

        createAccountApproval({ approvalDetails })
            .then(result => {
                console.log('result'+JSON.stringify(result));
                console.log('result Id'+result.Id);
                if(result != null){
                this.showToastMessage('Success', 'Sucessfully Account Approval Created', 'success');

                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                    recordId: result.Id,
                    objectApiName: 'Account_Approval__c',
                    actionName: 'view'
                    }
                });
                this.resetTheData();
                
            }
            })
            .catch(error => {
                this.showToastMessage('Error', error.body.message, 'error', 'sticky');
            });
    }

    // handleAccountNameChange(event) {
    //     //this.accountName = event.target.value;
    // }

    handleCancel(){
        this.navigateToOrderListView();
        this.resetTheData();
    }

    showToastMessage(type, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: type,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    navigateToOrderListView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'list'
            }
        });
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
    

    resetTheData(){
        this.accountName = '';
        this.accounts = [];
        this.showPage1 = true; // Reset to show the first page
        this.showPage2 = false; // Hide the second page
        
        // Reset all input fields
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }
}