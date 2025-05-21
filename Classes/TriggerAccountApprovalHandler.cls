/**
* @Description       : 
* @Name              : Apurba Singh
* @Created By        : Apurba Singh
* @last modified on  : 04-09-2024
* @last modified by  : Apurba Singh
* Modifications Log
* Ver   Date         Author                        Modification
* 1.0   04-09-2024  Apurba Singh Initial Version
**/
public class TriggerAccountApprovalHandler {
    public class DuplicateContactWarningException extends Exception {}
    public static void assignApprover(List<Account_Approval__c> newApprovals){
        Set<Id> ownerIds = new Set<Id>();
        
        for (Account_Approval__c approval : newApprovals) {
            if (approval.OwnerId != null) {
                ownerIds.add(approval.OwnerId);
            }
        }
        System.debug('ownerIds::'+ownerIds);
        Map<Id, User> ownerUserMap = new Map<Id, User>([SELECT Id, ASM__c, RSM__c FROM User WHERE Id IN :ownerIds]);
        System.debug('ownerUserMap::'+ownerUserMap);
        for (Account_Approval__c approval : newApprovals) {
            if (approval.OwnerId != null) {
                User ownerUser = ownerUserMap.get(approval.OwnerId);
                System.debug('ownerUser::'+ownerUser);
                if (ownerUser != null) {
                    System.debug('ownerUser.ASM__c;::'+ownerUser.ASM__c);
                    approval.ASM_User__c = ownerUser.ASM__c;
                    approval.RSM_User__c = ownerUser.RSM__c;
                }
            }
        }
        
        
    }
    
    public static void validateAccountApprovalNames(List<Account_Approval__c> approvals) {
        // Create a set to store unique Account Approval names
        Set<String> approvalNames = new Set<String>();
        
        // Loop through each Account_Approval__c record in the trigger context
        for (Account_Approval__c approval : approvals) {
            if (approval.Account_Name__c != null) {
                approvalNames.add(approval.Account_Name__c);
            }
        }
        System.debug('approvalNames'+approvalNames);
        // Query Accounts that match the Account Approval names
        List<Account> existingAccounts = [SELECT Id, Name, Industry, Account_Region__c, Owner.Name, Account_Classification__c, Owner.PLSI_Team__c, Is_Active__c
                                          FROM Account
                                          WHERE Owner.PLSI_Team__c In ('Lighting','Power','Residential','Commercial','Distribution','B2G','Specifier','IAQ') and Name IN :approvalNames];
        System.debug('existingAccounts'+existingAccounts);
        // Create a map to store account names for easy comparison
        Map<String, String> accountMap = new Map<String, String>();
        for (Account acc : existingAccounts) {
            accountMap.put(acc.Name, acc.Id);
        }
        System.debug('accountMap'+accountMap);
        // Loop through each record again to check for a matching account name
        for (Account_Approval__c approval : approvals) {
            if (accountMap.containsKey(approval.Account_Name__c) && approval.Approval_Status__c != 'Approved') {
                approval.addError('The Account Approval Name matches an existing Account Name: ' + approval.Account_Name__c + '. Please use a different name.');
            }
        }
    }
    
   /* public static void validateDuplicateContactsForAccounts(List<Account_Approval__c> approvals) {
        // Create a set to store unique Contact identifying details
        Set<String> contactIdentifiers = new Set<String>();
        
        // Collect the relevant contact details from the Account_Approval__c records
        for (Account_Approval__c approval : approvals) {
            if (approval.Customer_First_Name__c != null && approval.Customer_Last_Name__c != null) {
                String contactIdentifier = approval.Customer_First_Name__c + ' ' + approval.Customer_Last_Name__c;
                contactIdentifiers.add(contactIdentifier);
            }
        }
        System.debug('contactIdentifiers' + contactIdentifiers);
        
        // Query Contacts that match the provided first name, last name, email, or phone, and check the account A360 and Owner_Team__c
        List<Contact> contacts = [SELECT Id, FirstName, LastName, MobilePhone, Email, Account.A360__c, Account.Owner_Team__c
                                  FROM Contact 
                                  WHERE (FirstName != '' AND LastName != '')
                                  AND (MobilePhone != '' OR Email != '')
                                  AND Account.Owner_Team__c IN ('B2G', 'Commercial', 'Residential', 'Power', 'Lighting', 'Distribution', 'Specifier', 'Inside Sales', 'Contractor Management')];
        
        System.debug('contacts' + contacts);
        
        // Loop through each Account_Approval__c record again to check for duplicate contacts
        for (Account_Approval__c approval : approvals) {
            for (Contact contact : contacts) {
                // Match contacts by first name, last name, and either mobile phone or email
               
                if ((contact.FirstName == approval.Customer_First_Name__c && contact.LastName == approval.Customer_Last_Name__c)
                    && (contact.MobilePhone == approval.Mobile_No__c || contact.Email == approval.Email_Id__c) && approval.Approval_Status__c != 'Approved') {
                        System.debug('contact::' + contact);
                        approval.addError('Duplicate contact detected: ' + contact.FirstName + ' ' + contact.LastName + 
                                          ' in account owned by team ' + contact.Account.Owner_Team__c + '. Please modify the details or use a different contact.');
                    }
            }
        }
    }*/
    
    
    
    public static void callcreateNewAccount(List<Account_Approval__c> aplist, Map<Id,Account_Approval__c> oldmap){
        list<Account_Approval__c> passList = new list<Account_Approval__c>();
        System.debug('Inside callcreateNewAccount');
        for(Account_Approval__c ap:aplist){
            if(ap.Approval_Status__c != oldMap.get(ap.Id).Approval_Status__c && ap.Approval_Status__c == 'Approved'){
                System.debug('Inside callcreateNewAccount after if');
                passList.add(ap);
            }
        }
        
        if(passList.size()>0)
            createNewAccountAndContacts(passList);
    }/*
    public static List<String> createNewAccount(List<Account_Approval__c> newApprovals) {
        System.debug('Inside createNewAccount');
        List<Account> newAccounts = new List<Account>();
        List<Contact> newContacts = new List<Contact>();
        List<String> newAccountIds = new List<String>();
        List<Account_Approval__c> approvalsToUpdate = new List<Account_Approval__c>();
        
        // Create a map to keep track of the Account_Approval__c records by index
        Map<Integer, Account_Approval__c> indexToApprovalMap = new Map<Integer, Account_Approval__c>();
        Set<String> emailSet = new Set<String>();
        
        for (Integer i = 0; i < newApprovals.size(); i++) {
            Account_Approval__c approval = newApprovals[i];
            if (approval.Approval_Status__c == 'Approved') {
                Account acc = new Account();
                acc.Name = approval.Account_Name__c;
                acc.Account_Region__c = approval.Account_Region__c;
                acc.Account_Classification__c = approval.Account_Classification__c;
                acc.Account_Potential__c = approval.Account_Potential__c;
                acc.Site = approval.Account_Site__c;
                acc.PLSI_Account_Type__c = approval.Account_Type__c;
                acc.Business_Plan_CMS__c = approval.Business_Plan_CMS__c;
                acc.Business_Plan_IAQ__c = approval.Business_Plan_IAQ__c;
                acc.Business_Plan_Lighting__c = approval.Business_Plan_Lighting__c;
                acc.Business_Plan_WCT__c = approval.Business_Plan_WCT__c;
                acc.Business_Plan_WD__c = approval.Business_Plan_WD__c;
                acc.Business_Plan__c = approval.Business_Plan_SWG__c;
                acc.Industry = approval.Industry__c;
                acc.Business_Plan_Water_Heater__c = approval.Business_Plan_Water_Heater__c;
                acc.OwnerId = approval.OwnerId;
                
                newAccounts.add(acc);
                indexToApprovalMap.put(newAccounts.size() - 1, approval);
                
                // Collect the email for duplicate checking
                if (approval.Email_Id__c != null) {
                    emailSet.add(approval.Email_Id__c);
                }
            }
        }
        
        System.debug('Accounts before insert: ' + newAccounts);
        
        // Query once for all existing contacts with these emails
        Map<String, Contact> existingContactMap = new Map<String, Contact>();
        if (!emailSet.isEmpty()) {
            List<Contact> existingContacts = [SELECT Id, Email FROM Contact WHERE Email IN :emailSet];
            for (Contact con : existingContacts) {
                existingContactMap.put(con.Email, con);
            }
        }
        
        
        if (!newAccounts.isEmpty()) {
            try {
                insert newAccounts;
                System.debug('Accounts after insert: ' + newAccounts);
                
                // Create a map of Account IDs to Account objects for quick lookup
                Map<Id, Account> accountMap = new Map<Id, Account>();
                for (Account acc : newAccounts) {
                    accountMap.put(acc.Id, acc);
                    // Send an email to the Account Owner
                    sendAccountCreationEmail(acc.Id, acc.OwnerId);
                }
                
                // Update the Account_Approval__c records with the new Account IDs
                for (Integer i = 0; i < newAccounts.size(); i++) {
                    Account acc = newAccounts[i];
                    Account_Approval__c approval = indexToApprovalMap.get(i);
                    
                    if (approval != null) {
                        // Create the related Contact for this Account
                        //if (!existingContactMap.containsKey(approval.Email_Id__c)) {
                        // Create new contact if no duplicate found
                        Contact con = new Contact();
                        con.FirstName = approval.Customer_First_Name__c;
                        con.LastName = approval.Customer_Last_Name__c;
                        con.Email = approval.Email_Id__c;
                        con.MobilePhone = approval.Mobile_No__c;
                        con.AccountId = acc.Id;
                        con.OwnerId=approval.OwnerId;
                        con.Is_Account_Approval__c = true;
                        
                        newContacts.add(con);
                        //}else{
//System.debug('Duplicate contact found: ' + approval.Email_Id__c);
//approval.addError('The Duplicate contact found:'+ approval.Email_Id__c);
//}
                        
                        // Create a copy of the approval record to modify
                        Account_Approval__c updateapproval = new Account_Approval__c(Id = approval.Id);
                        System.debug('updateapproval ' + updateapproval);
                        System.debug('acc.Id ' + acc.Id);
                        updateapproval.Account__c = acc.Id;
                        System.debug('updateapproval.Account__c ' + updateapproval.Account__c);
                        approvalsToUpdate.add(updateapproval);
                        System.debug('approvalsToUpdate ' + approvalsToUpdate);
                        
                    }
                }
                
                if (!newContacts.isEmpty()) {
                    insert newContacts;
                }
                
                if (!approvalsToUpdate.isEmpty()) {
                    // Update the Account Approval records with the new Account ID
                    update approvalsToUpdate;
                }
                
            } catch (DmlException e) {
                System.debug('Error occurred during Account or Contact creation: ' + e.getMessage());
                System.debug('Debug line:: ' + e.getLineNumber());
                throw new AuraHandledException('Error occurred during Account or Contact creation:'+e.getMessage());
                
            }
        }
        
        System.debug('New Account IDs: ' + newAccountIds);
        return newAccountIds;
    }*/
    
    
   

    
//sss
//sss
//sss
//sss
//
//
//
//

    public static Map<String, Contact> checkDuplicateContacts(List<Account_Approval__c> approvals) {
    // Map to store the duplicate contacts identified
    Map<String, Contact> duplicateContactMap = new Map<String, Contact>();

    // Sets to store dynamically calculated keys for email and mobile
    Set<String> emailKeySet = new Set<String>();
    Set<String> mobileKeySet = new Set<String>();

    // Generate unique keys for comparison based on Account_Approval__c data
    for (Account_Approval__c approval : approvals) {
        if (String.isNotBlank(approval.Customer_First_Name__c) && String.isNotBlank(approval.Customer_Last_Name__c) && String.isNotBlank(approval.Email_Id__c)) {
            String emailKey = approval.Customer_First_Name__c + ':' + approval.Customer_Last_Name__c + ':' + approval.Email_Id__c;
            emailKeySet.add(emailKey);
            System.debug('sss::: emailKeySet '+ emailKeySet);
            System.debug('sss::: emailKey '+ emailKey);

        }
        if (String.isNotBlank(approval.Customer_First_Name__c) && String.isNotBlank(approval.Customer_Last_Name__c) && String.isNotBlank(approval.Mobile_No__c)) {
            String mobileKey = approval.Customer_First_Name__c + ':' + approval.Customer_Last_Name__c + ':' + approval.Mobile_No__c;
            mobileKeySet.add(mobileKey);
            System.debug('sss::: mobileKey '+ mobileKey);
            System.debug('sss::: mobileKeySet '+ mobileKeySet);
        }
    }

    // Query contacts in bulk based on email keys
    if (!emailKeySet.isEmpty()) {
        for (Contact con : [SELECT Id, FirstName, LastName, Email, MobilePhone, 
                            (SELECT AccountId FROM AccountContactRelations WHERE IsDirect = true) 
                            FROM Contact WHERE Contact_Key_Email__c IN :emailKeySet]) {
            String emailKey = con.FirstName + ':' + con.LastName + ':' + con.Email;
            if (!duplicateContactMap.containsKey(emailKey)) {
                System.debug('sss::: inside if ');
            	duplicateContactMap.put(emailKey, con);
            }
            System.debug('sss::: emailKey2 '+ emailKey);
            System.debug('sss::: duplicateContactMap '+ duplicateContactMap);
        }
    }

    // Query contacts in bulk based on mobile keys
    if (!mobileKeySet.isEmpty()) {
        for (Contact con : [SELECT Id, FirstName, LastName, Email, MobilePhone, 
                            (SELECT AccountId FROM AccountContactRelations WHERE IsDirect = true) 
                            FROM Contact WHERE Contact_Key_MobilePhone__c IN :mobileKeySet]) {
            String mobileKey = con.FirstName + ':' + con.LastName + ':' + con.MobilePhone;
            System.debug('sss::: mobileKey2 '+ mobileKey);
            System.debug('sss::: duplicateContactMap '+ duplicateContactMap);
            if (!duplicateContactMap.containsKey(mobileKey)) {
                System.debug('sss::: inside if2 ');
                duplicateContactMap.put(mobileKey, con);
            }
        }
    }

    return duplicateContactMap;
}

    // Method to handle Account and Contact creation
    public static List<Account> createNewAccountAndContacts(List<Account_Approval__c> newApprovals) {
    try {
        List<Account> newAccounts = new List<Account>();
        List<Contact> newContacts = new List<Contact>();
        List<AccountContactRelation> newAccountContactRelations = new List<AccountContactRelation>();
        List<Account_Approval__c> approvalsToUpdate = new List<Account_Approval__c>();
        Map<String, Contact> duplicateContactMap = checkDuplicateContacts(newApprovals); 
        
        // Map to track Account_Approval__c and their corresponding Accounts
        Map<Integer, Account_Approval__c> indexToApprovalMap = new Map<Integer, Account_Approval__c>();

        // Create Accounts
        for (Account_Approval__c approval : newApprovals) {
            System.debug('sss::: inside forr ');
            if (approval.Approval_Status__c == 'Approved') {
                System.debug('sss::: inside if3 ');
                Account acc = new Account();
                acc.Name = approval.Account_Name__c;
                acc.Account_Region__c = approval.Account_Region__c;
                acc.Account_Classification__c = approval.Account_Classification__c;
                acc.Account_Potential__c = approval.Account_Potential__c;
                acc.Site = approval.Account_Site__c;
                acc.PLSI_Account_Type__c = approval.Account_Type__c;
                acc.Business_Plan_CMS__c = approval.Business_Plan_CMS__c;
                acc.Business_Plan_IAQ__c = approval.Business_Plan_IAQ__c;
                acc.Business_Plan_Lighting__c = approval.Business_Plan_Lighting__c;
                acc.Business_Plan_WCT__c = approval.Business_Plan_WCT__c;
                acc.Business_Plan_WD__c = approval.Business_Plan_WD__c;
                acc.Business_Plan__c = approval.Business_Plan_SWG__c;
                acc.Industry = approval.Industry__c;
                acc.Business_Plan_Water_Heater__c = approval.Business_Plan_Water_Heater__c;
                acc.OwnerId = approval.OwnerId;
                newAccounts.add(acc);
                indexToApprovalMap.put(newAccounts.size() - 1, approval);
            }
        }

        if (!newAccounts.isEmpty()) {
            System.debug('sss::: inside if4 ');
            insert newAccounts;
            System.debug('sss::: inserted newAccounts '+newAccounts);

            // Map of Account IDs for easy lookup
            Map<Id, Account> accountMap = new Map<Id, Account>(newAccounts);

            // Process Account Approvals and create Contacts or AccountContactRelations
            for (Integer i = 0; i < newAccounts.size(); i++) {
                Account acc = newAccounts[i];
                Account_Approval__c approval = indexToApprovalMap.get(i);
                //String contactIdentifier = approval.Customer_First_Name__c + ' ' + approval.Customer_Last_Name__c;
				String mobileKey = approval.Customer_First_Name__c + ':' + approval.Customer_Last_Name__c + ':' + approval.Mobile_No__c;
                 String emailKey = approval.Customer_First_Name__c + ':' + approval.Customer_Last_Name__c + ':' + approval.Email_Id__c;
                if (duplicateContactMap.containsKey(mobileKey) || duplicateContactMap.containsKey(emailKey)) {
                    System.debug('sss::: inside duplicateContactMap mobileKey or email key ');
                    // Duplicate Contact exists, create AccountContactRelation
                    AccountContactRelation acr = new AccountContactRelation();
                    acr.AccountId = acc.Id;
                    acr.Roles= 'Business User';
                    
                    if(duplicateContactMap.containsKey(mobileKey) && duplicateContactMap.containsKey(emailKey)){
                        System.debug('sss::: inside duplicateContactMap mobileKey & emailkey');
                        
                        // Check if the Contact IDs for mobileKey and emailKey are the same
    					if (duplicateContactMap.get(mobileKey).Id == duplicateContactMap.get(emailKey).Id) {
        					acr.ContactId = duplicateContactMap.get(emailKey).Id;
    					} 
                        else {
        					acr.ContactId = duplicateContactMap.get(emailKey).Id;
    					}
                    }
                    
                    else if(duplicateContactMap.containsKey(mobileKey)){
                        System.debug('sss::: inside duplicateContactMap mobileKey');
                        acr.ContactId = duplicateContactMap.get(mobileKey).Id;
                    }
                    else if(duplicateContactMap.containsKey(emailKey)){
                        System.debug('sss::: inside duplicateContactMap emailkey');
                        acr.ContactId = duplicateContactMap.get(emailKey).Id;
                    }
                    
                    newAccountContactRelations.add(acr);
                    System.debug('sss::: added ');
                    System.debug('sss::: acr '+acr);
                    System.debug('sss::: newAccountContactRelations '+newAccountContactRelations);
                } else {
                    // Create a new Contact
                    System.debug('sss::: new Contact created ');
                    Contact con = new Contact();
                    con.FirstName = approval.Customer_First_Name__c;
                    con.LastName = approval.Customer_Last_Name__c;
                    con.Email = approval.Email_Id__c;
                    con.MobilePhone = approval.Mobile_No__c;
                    con.AccountId = acc.Id;
                    con.OwnerId = approval.OwnerId;
                    newContacts.add(con);
                }
                System.debug('sss::: newContacts '+newContacts);

                // Update the Account_Approval__c record
                Account_Approval__c updatedApproval = new Account_Approval__c(Id = approval.Id, Account__c = acc.Id);
                approvalsToUpdate.add(updatedApproval);
                System.debug('sss::: approvalsToUpdate '+approvalsToUpdate);

            }

            // Insert new Contacts
            if (!newContacts.isEmpty()) {
                insert newContacts;
                System.debug('Inserted contact');
            }

            // Insert AccountContactRelations
            if (!newAccountContactRelations.isEmpty()) {
                insert newAccountContactRelations;
                System.debug('Inserted AccountContactRelations');
                
            }

            // Update Account_Approval__c records
            if (!approvalsToUpdate.isEmpty()) {
                update approvalsToUpdate;
                System.debug('Update Account_Approval__c records');
            }
        }
        
        System.debug('sss::: newAccounts'+newAccounts);
        return newAccounts;
    } catch (DmlException e) {
        System.debug('Error occurred during Account or Contact creation: ' + e.getMessage());
        throw new AuraHandledException('Error occurred during Account or Contact creation: ' + e.getMessage());
    }
}
 
    
    
    
    
    
    //---sss---
    //---sss---
    //---sss---
    //---sss---

    
    

    public static void sendAccountCreationEmail(Id accountId, Id ownerId) {
        // Query to get the Account and Owner details
        System.debug('Inside send account email acc:::');
        Account acc = [SELECT Name FROM Account WHERE Id = :accountId LIMIT 1];
        System.debug('Account Name:::'+ acc.Name);
        User accOwner = [SELECT Email, Name FROM User WHERE Id = :ownerId LIMIT 1];
        System.debug('Owner EMail'+ accOwner.Email);
        User currentUser = [SELECT Id,Name,FirstName, LastName,Email FROM User WHERE Id = :UserInfo.getUserId()];
        OrgWideEmailAddress fromAddress=[select id from OrgWideEmailAddress where DisplayName ='Salesforce Alert (Do-Not Reply)'];
        // Create the email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        System.debug('adresss:::'+ accOwner.Email);
        System.debug('adresss:::'+ fromAddress.Id);
        mail.setOrgWideEmailAddressId(fromAddress.Id);
        mail.setToAddresses(new String[] { accOwner.Email });
        mail.setSubject('Account Created Successfully');
        mail.setPlainTextBody('Dear '+ accOwner.Name +',\n\n' +
                              'Your account approval request has been approved. \n'+
                              'The Account "' + acc.Name + '" has been created successfully.\n' +
                              'You can view the Account details here: \n' +
                              'https://panasoniclifesolutionsindia--panuatsand.sandbox.lightning.force.com/' + accountId + '\n\n' +
                              'Best Regards');
        
        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}