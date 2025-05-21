/**********************************************************************************
* ClassName: PLSI_Account_Approval_Trigger
* Created By: Apurba Singh
* Created on: 27-03-2024
* Description:It will call the helper class.
* Modified on :
* Modified by :
***********************************************************************************/
trigger PLSI_Account_Approval_Trigger on Account_Approval__c (before insert, before update, after update) {
	
    if(Trigger.isInsert && Trigger.isBefore || Trigger.isUpdate && Trigger.isBefore){
        TriggerAccountApprovalHandler.assignApprover(Trigger.new);
        TriggerAccountApprovalHandler.validateAccountApprovalNames(Trigger.new);
        //TriggerAccountApprovalHandler.checkDuplicateContacts(Trigger.new);
        
    }
    
    if(Trigger.isUpdate && Trigger.isAfter){
        TriggerAccountApprovalHandler.callcreateNewAccount(Trigger.new, Trigger.oldmap);
    }
    
    
}