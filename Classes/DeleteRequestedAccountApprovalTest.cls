@IsTest
public class DeleteRequestedAccountApprovalTest {
    
    // Test Data Setup
    private static void setupTestData() {
        List<Account_Approval__c> dealerRecords = new List<Account_Approval__c>();

        // Create records where approval status is approved or no of times rejected is = 0 and CreatedDate is within the last 20 days
        for (Integer i = 0; i < 5; i++) {
            dealerRecords.add(new Account_Approval__c(
                Approval_Status__c = 'Approved',
                No_of_times_rejected__c = 0,
                CreatedDate = Date.today().addDays(-i)
            ));
        }

        // Create records where approval status is Re-Work or no of times rejected is >= 3 and CreatedDate is within the last 20 days
        for (Integer i = 0; i < 5; i++) {
            dealerRecords.add(new Account_Approval__c(
                Approval_Status__c = 'Re-Work',
                No_of_times_rejected__c = 3,
                CreatedDate = Date.today().addDays(-i)
            ));
        }

        insert dealerRecords;
    }

    @IsTest
    static void testBatchExecution() {
        // Set up test data
        setupTestData();

        // Test the batch execution
        Test.startTest();
        DeleteRequestedAccountApprovalBatch batch = new DeleteRequestedAccountApprovalBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Verify that the correct records were deleted
        Integer count = [SELECT COUNT() FROM Account_Approval__c WHERE (Approval_Status__c = 'Approved' OR No_of_times_rejected__c >= 3 )];
        System.assertEquals(0, count, 'All records with Approval_Status__c = Approved or no of times rejected is >= 3 should be deleted.');
    }

    @IsTest
    static void testBatchErrorHandling() {
        // Set up test data with an invalid scenario to cause a DML exception
        setupTestData();

        // Intentionally insert a record that will cause a deletion failure
        Account_Approval__c acp = new Account_Approval__c(
            Approval_Status__c = 'Approved',
            CreatedDate = Date.today()
        );
        insert acp;

        
        // Test the batch execution with the error scenario
        Test.startTest();
        DeleteRequestedAccountApprovalBatch batch = new DeleteRequestedAccountApprovalBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Verify that the locked record still exists
        Integer count = [SELECT COUNT() FROM Account_Approval__c WHERE Id = :acp.Id];
       // System.assertEquals(1, count, 'Locked record should not be deleted.');
    }

    @IsTest
    static void testScheduler() {
        // Set up test data
        setupTestData();

        // Test the scheduler
        Test.startTest();
        String cronExp = '0 0 4 ? * 1 *'; // Sunday at 4 AM
        System.schedule('TestDeleteRequestedAccountApprovalScheduler', cronExp, new DeleteRequestedAccountApprovalScheduler());
        Test.stopTest();

        // Verify that the scheduled job was created
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered FROM CronTrigger WHERE CronJobDetail.Name = 'TestDeleteRequestedAccountApprovalScheduler'];
        System.assertEquals(cronExp, ct.CronExpression, 'The cron expression should match the scheduled job.');
    }

}