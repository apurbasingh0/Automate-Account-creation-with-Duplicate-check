# Automate Account Creation

Automate the process of Salesforce Account creation with approval workflows, duplicate detection, and business plan tracking using Apex and Lightning Web Components (LWC).

---

## Table of Contents

- [Overview](#overview)  
- [Features](#features)  
- [Components](#components)  
- [Account Approval Automation](#account-approval-automation)  
- [Setup Instructions](#setup-instructions)  
- [Usage](#usage)  
- [Error Handling](#error-handling)   

---

## Overview

This repository contains Apex and Lightning Web Components code that streamlines account creation by:

- Searching existing accounts to prevent duplicates  
- Creating `Account_Approval__c` records with detailed business plan and customer info  
- Providing a multi-step UI for input  
- Showing active/inactive status indicators for accounts  
- Navigating users to relevant records seamlessly  

---

## Features

- Account search by partial name and owner team  
- Duplicate account detection with visual cues  
- Multi-step Lightning Web Component interface  
- Toast notifications for success, warnings, and errors  
- Automatic navigation to created or existing records  
- Multi-level approval routing for account creation  
- Auto-creation of Account and Contact upon approval  
- Scheduled cleanup of obsolete approval records  

---

## Components

### Apex

- **automateAccountCreationContoller.cls**  
  - `findAccounts(String accountName)`: Search accounts with filters  
  - `createAccountApproval(Map<String, String> approvalDetails)`: Creates account approval record  

- **TriggerAccountApprovalHandler.cls**  
  -  Assignment of ASM/RSM approvers
  - Duplicate Account name validation
  - Contact deduplication logic
  - Account & Contact creation logic
  - Sends email notification to the account owner upon successful account creation  

- **DeleteRequestedAccountApprovalBatch.cls**  
  - Batch job to delete approved/rejected requests after 20 days  

- **DeleteRequestedAccountApprovalScheduler.cls**  
  - Schedules the above batch job to run periodically  

### Lightning Web Components (LWC)

- **automateAccountCreation**  
  - Multi-step form, account search, and approval submission  

- **duplicateViewOfAccounts**  
  - View duplicate accounts with active/inactive status  

---

## Account Approval Automation

### Workflow Summary

1. **User Submits Account Approval**  
   - A `Account_Approval__c` record is created via LWC or Apex.

2. **Approver Assignment**  
   - ASM and RSM approvers are auto-assigned based on the record owner.

3. **Validation**  
   - Duplicates are checked by Account name and Contact details (email or mobile).

4. **Approval Conversion**  
   - On status = `Approved`, a new `Account` and related `Contact` are created.
   - The approval record is updated with the new Account ID.

5. **Record Cleanup**  
   - After 20 days, approved or rejected approvals are deleted using a scheduled batch.

---

## Setup Instructions

1. Deploy Apex classes and LWC components to your Salesforce org.  
2. Upload `Active` and `Inactive` icons as Static Resources.  
3. Assign object permissions and Apex class access to appropriate profiles.  
4. Schedule the `DeleteRequestedAccountApprovalScheduler` via UI or `System.schedule()`.  
5. Ensure custom fields exist on `Account_Approval__c`:
   - `Customer_First_Name__c`, `Email_Id__c`, `Mobile_No__c`, `Account__c`

---

## Usage

1. **Account Search:**  
   - Use LWC to search for accounts by partial name and check duplicates.

2. **Submit Approval:**  
   - Fill out required fields and submit an `Account_Approval__c` request.

3. **Approval Routing:**  
   - ASM and RSM users are auto-assigned as approvers.

4. **Account Creation:**  
   - On approval, a new Account and Contact are created automatically.

5. **Notifications & Navigation:**  
   - Toast messages notify the user and navigate to the appropriate record.

---

## Error Handling

- Prevents creation of duplicate Account/Contact  
- Validates all required fields before submission  
- Displays meaningful error messages via toast  
- Catches and logs Apex exceptions when needed

---


