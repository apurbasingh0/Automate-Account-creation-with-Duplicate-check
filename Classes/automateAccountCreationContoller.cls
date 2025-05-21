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
public with sharing class automateAccountCreationContoller {

        @AuraEnabled(cacheable=true)
        public static List<Account> findAccounts(String accountName) {
            try {
                System.debug('Account Name: ' + accountName);
                
                if (String.isBlank(accountName)) {
                    System.debug('Account name is blank');
                    return new List<Account>();
                }
    
                String searchKey = '%' + accountName + '%';
                
                List<Account> accounts = [
                    SELECT Id, Name, Industry, Account_Region__c, Owner.Name, Account_Classification__c, Owner.PLSI_Team__c, Is_Active__c
                    FROM Account
                    WHERE Name LIKE :searchKey and Owner.PLSI_Team__c In ('Lighting','Power','Residential','Commercial','Distribution','B2G','Specifier','IAQ')
                    ORDER BY Name asc LIMIT 10
                ];
    
                System.debug('Accounts found: ' + accounts.size());
                return accounts;
    
            } catch (Exception e) {
                System.debug('Error in findAccounts: ' + e.getMessage());
                throw new AuraHandledException('An error occurred while searching for accounts.');
            }
        }
    
        @AuraEnabled
        public static Account_Approval__c createAccountApproval(Map<String, String> approvalDetails) {
            try {
                // Check if any similar accounts exist
                List<Account> existingAccounts = findAccounts(approvalDetails.get('AccountName'));
                System.debug('existingAccounts'+existingAccounts);
    
                // if (!existingAccounts.isEmpty()) {
                //     throw new AuraHandledException('Similar account(s) already exist. Record creation not allowed.');
                // }
    
                // Create Account Approval record
                Account_Approval__c accountApproval = new Account_Approval__c();
                accountApproval.Account_Name__c = approvalDetails.get('AccountName');
                accountApproval.Account_Type__c = approvalDetails.get('AccountType');
                accountApproval.Account_Classification__c = approvalDetails.get('AccountClassification');
                accountApproval.Industry__c = approvalDetails.get('Industry');
                accountApproval.Account_Site__c = approvalDetails.get('AccountSite');
                // Check and set business plan fields
                if (approvalDetails.containsKey('BusinessPlanWCT') && !String.isEmpty(approvalDetails.get('BusinessPlanWCT'))) {
                    accountApproval.Business_Plan_WCT__c = Decimal.valueOf(approvalDetails.get('BusinessPlanWCT'));
                }
                if (approvalDetails.containsKey('BusinessPlanIAQ') && !String.isEmpty(approvalDetails.get('BusinessPlanIAQ'))) {
                    accountApproval.Business_Plan_IAQ__c = Decimal.valueOf(approvalDetails.get('BusinessPlanIAQ'));
                }
                if (approvalDetails.containsKey('BusinessPlanWaterHeater') && !String.isEmpty(approvalDetails.get('BusinessPlanWaterHeater'))) {
                    accountApproval.Business_Plan_Water_Heater__c = Decimal.valueOf(approvalDetails.get('BusinessPlanWaterHeater'));
                }
                if (approvalDetails.containsKey('BusinessPlanWD') && !String.isEmpty(approvalDetails.get('BusinessPlanWD'))) {
                    accountApproval.Business_Plan_WD__c = Decimal.valueOf(approvalDetails.get('BusinessPlanWD'));
                }
                if (approvalDetails.containsKey('BusinessPlanLighting') && !String.isEmpty(approvalDetails.get('BusinessPlanLighting'))) {
                    accountApproval.Business_Plan_Lighting__c = Decimal.valueOf(approvalDetails.get('BusinessPlanLighting'));
                }
                if (approvalDetails.containsKey('BusinessPlanCMS') && !String.isEmpty(approvalDetails.get('BusinessPlanCMS'))) {
                    accountApproval.Business_Plan_CMS__c = Decimal.valueOf(approvalDetails.get('BusinessPlanCMS'));
                }
                if (approvalDetails.containsKey('BusinessPlanSWG') && !String.isEmpty(approvalDetails.get('BusinessPlanSWG'))) {
                    accountApproval.Business_Plan_SWG__c = Decimal.valueOf(approvalDetails.get('BusinessPlanSWG'));
                }
                if (approvalDetails.containsKey('AccountPotentialWCT') && !String.isEmpty(approvalDetails.get('AccountPotentialWCT'))) {
                    accountApproval.Account_Potential_WCT__c = Decimal.valueOf(approvalDetails.get('AccountPotentialWCT'));
                }
                if (approvalDetails.containsKey('AccountPotentialIAQ') && !String.isEmpty(approvalDetails.get('AccountPotentialIAQ'))) {
                    accountApproval.Account_Potential_IAQ__c = Decimal.valueOf(approvalDetails.get('AccountPotentialIAQ'));
                }
                if (approvalDetails.containsKey('AccountPotentialWaterHeater') && !String.isEmpty(approvalDetails.get('AccountPotentialWaterHeater'))) {
                    accountApproval.Account_Potential_Water_Heater__c = Decimal.valueOf(approvalDetails.get('AccountPotentialWaterHeater'));
                }
                if (approvalDetails.containsKey('AccountPotentialWD') && !String.isEmpty(approvalDetails.get('AccountPotentialWD'))) {
                    accountApproval.Account_Potential_WD__c = Decimal.valueOf(approvalDetails.get('AccountPotentialWD'));
                }
                if (approvalDetails.containsKey('AccountPotentialLighting') && !String.isEmpty(approvalDetails.get('AccountPotentialLighting'))) {
                    accountApproval.Account_Potential_Lighting__c = Decimal.valueOf(approvalDetails.get('AccountPotentialLighting'));
                }
                if (approvalDetails.containsKey('AccountPotentialCMS') && !String.isEmpty(approvalDetails.get('AccountPotentialCMS'))) {
                    accountApproval.Account_Potential_CMS__c = Decimal.valueOf(approvalDetails.get('AccountPotentialCMS'));
                }
                if (approvalDetails.containsKey('AccountPotentialSWG') && !String.isEmpty(approvalDetails.get('AccountPotentialSWG'))) {
                    accountApproval.Account_Potential_SWG__c = Decimal.valueOf(approvalDetails.get('AccountPotentialSWG'));
                }
                accountApproval.Customer_First_Name__c = approvalDetails.get('CustomerFirstName');
                accountApproval.Customer_Last_Name__c = approvalDetails.get('CustomerLastName');
                accountApproval.Email_Id__c = approvalDetails.get('EmailId');
                accountApproval.Mobile_No__c = approvalDetails.get('MobileNo');

                // Check if required fields are populated
                if (String.isEmpty(accountApproval.Account_Name__c) || 
                    String.isEmpty(accountApproval.Account_Type__c) || 
                    String.isEmpty(accountApproval.Account_Classification__c) || 
                    String.isEmpty(accountApproval.Industry__c) || 
                    String.isEmpty(accountApproval.Account_Site__c) || 
                    String.isEmpty(accountApproval.Customer_First_Name__c) || 
                    String.isEmpty(accountApproval.Customer_Last_Name__c) || 
                    String.isEmpty(accountApproval.Email_Id__c) || 
                    String.isEmpty(accountApproval.Mobile_No__c)) 
                    {
                    // Throw a simple exception if any required field is empty
                    throw new AuraHandledException('Required fields must be populated.');
                }

                insert accountApproval;
    
                return accountApproval;
    
            } catch (Exception e) {
                System.debug('Error in createAccountApproval: ' + e.getMessage());
                throw new AuraHandledException('An error occurred while creating account approval record. Please fill all required fields: ' + e.getMessage());
            }
        }


        // @AuraEnabled
        // public static List<Id> createNewAccounts(List<Id> approvalIds) {
        //     // Query the Account_Approval__c records based on the given Ids
        //     List<Account_Approval__c> approvals = [SELECT Id, Account_Name__c, Account_Region__c, Account_Classification__c, Account_Potential__c,
        //                                         Account_Site__c, Account_Type__c, Business_Plan_CMS__c, Business_Plan_IAQ__c, Business_Plan_Lighting__c,
        //                                         Business_Plan_WCT__c, Business_Plan_WD__c, Business_Plan_SWG__c, Industry__c, OwnerId,
        //                                         Approval_Status__c, Customer_First_Name__c, Customer_Last_Name__c, Email_Id__c, Mobile_No__c
        //                                         FROM Account_Approval__c
        //                                         WHERE Id IN :approvalIds];
            
        //     // Call the method from AccountApprovalHandler
        //     return TriggerAccountApprovalHandler.createNewAccount(approvals);
        // }

    
    
}