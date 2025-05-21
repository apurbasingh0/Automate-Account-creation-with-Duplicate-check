"# Automate-Account-creation-with-Duplicate-check" 
# Automate Account Creation

Automate the process of Salesforce Account creation with approval workflows, duplicate detection, and business plan tracking using Apex and Lightning Web Components (LWC).

---

## Table of Contents

- [Overview](#overview)  
- [Features](#features)  
- [Components](#components)  
- [Setup Instructions](#setup-instructions)  
- [Usage](#usage)  
- [Error Handling](#error-handling)  
- [Contributing](#contributing)  
- [License](#license)  

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

---

## Components

### Apex

- **automateAccountCreationContoller.cls**  
  - `findAccounts(String accountName)`: Search accounts with filters  
  - `createAccountApproval(Map<String, String> approvalDetails)`: Creates account approval record  

### Lightning Web Components (LWC)

- **automateAccountCreation**  
  - Multi-step form, account search, and approval submission  

- **duplicateViewOfAccounts**  
  - View duplicate accounts with active/inactive status  

---

## Setup Instructions

1. Deploy `automateAccountCreationContoller.cls` Apex class to your Salesforce org.  
2. Deploy the `automateAccountCreation` and `duplicateViewOfAccounts` LWCs.  
3. Upload `Active` and `Inactive` icons as Static Resources.  
4. Assign necessary permissions to users for Apex and custom objects.  
5. Add LWCs to desired Lightning pages or app layouts.

---

## Usage

1. **Account Search:**  
   Enter partial account name to find existing accounts. Duplicate accounts are displayed with active/inactive icons.  

2. **Account Approval:**  
   If no duplicates, proceed to fill detailed fields and submit approval request.  

3. **Navigation:**  
   On success, navigate to the newly created approval record or existing account.  

4. **Notifications:**  
   Toast messages provide real-time feedback on actions and errors.

---

## Error Handling

- Handles empty search inputs gracefully  
- Validates required fields before approval creation  
- Warns and prevents duplicate account creation  
- Catches and displays exceptions as user-friendly messages  

---


