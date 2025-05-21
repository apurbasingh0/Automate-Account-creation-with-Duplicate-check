global class DeleteRequestedAccountApprovalBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Query to select records where Talend_Flag__c is true and CreatedDate is within the last 20 days
        String query = 'SELECT Id FROM Account_Approval__c WHERE (Approval_Status__c = \'Approved\' OR No_of_times_rejected__c >= 3) AND LastModifiedDate <= LAST_N_DAYS:20';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Account_Approval__c> scope) {
        try {
            // Deleting the records in the scope
            delete scope;
        } catch (DmlException e) {
            System.debug('Error occurred while deleting records: '  + e.getMessage() + ' at line ' + e.getLineNumber());
        }
    }

    global void finish(Database.BatchableContext bc) {
        // You can implement any post-processing logic here if needed
        System.debug('Batch process completed.');
    }

}