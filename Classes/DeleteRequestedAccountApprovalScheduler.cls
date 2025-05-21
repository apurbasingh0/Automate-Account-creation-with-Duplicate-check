global class DeleteRequestedAccountApprovalScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        // Instantiate the batch class
        DeleteRequestedAccountApprovalBatch batch = new DeleteRequestedAccountApprovalBatch();
        
        // Execute the batch with a batch size of 200
        Database.executeBatch(batch, 200);
    }
}