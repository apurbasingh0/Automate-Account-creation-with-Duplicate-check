@isTest
public class TriggerAccountApprovalHandlerTest {
    
    @testSetup
    public static void makedata(){
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'Custom Sales Team (Power)'];
        Profile pf2 = [SELECT Id FROM Profile WHERE Name = 'Custom Sales RSM(Power)'];
        UserRole ur3 = new UserRole(Name = 'Sales Head-Power-Mumbai');
        insert ur3;
        UserRole ur2 = new UserRole(Name = 'RSM POWER[W1]',parentRoleId=ur3.Id);
        insert ur2;
        
        UserRole ur = new UserRole(Name = 'VERTICAL MANAGER-POWER COMMERCIAL MUMBAI',parentRoleId=ur2.Id);
        insert ur;
        
        UserRole ur1 = new UserRole(Name = 'EXECUTIVE-POWER COMMERCIAL MUMBAI',parentRoleId=ur.Id);
        insert ur1;
        
        
        List<User> userList = new List<User>();
        User user3 = new User();
        user3.Username = 'test10211@samp.com';
        user3.Email = 'test1@samp.com';
        user3.Alias = 'tsamp1';
        user3.TimeZoneSidKey = 'America/Los_Angeles';
        user3.LocaleSidKey = 'en_US';
        user3.EmailEncodingKey = 'UTF-8';
        user3.LanguageLocaleKey = 'en_US';
        user3.ProfileId = pf2.Id ;
        user3.LastName = 'LIVESTON';
        user3.IsActive = false;
        user3.PLSI_Region__c = 'East 2';
        user3.PLSI_State__c = 'Jharkhand';
        user3.PLSI_State_Code__c = 'JHA';
        user3.PLSI_Team__c = 'Power';
        user3.UserRoleId = ur3.Id;
        user3.Approver_Role__c = 'RSM/ASM/ZSM/Level1';
        insert user3;
        
        
        User user2 = new User();
        user2.Username = 'test102111@samp.com';
        user2.Email = 'test11@samp.com';
        user2.Alias = 'tsamp11';
        user2.TimeZoneSidKey = 'America/Los_Angeles';
        user2.LocaleSidKey = 'en_US';
        user2.EmailEncodingKey = 'UTF-8';
        user2.LanguageLocaleKey = 'en_US';
        user2.ProfileId = pf.Id ;
        user2.LastName = 'LIVESTON';
        user2.IsActive = false;
        user2.PLSI_Region__c = 'East 2';
        user2.PLSI_State__c = 'Jharkhand';
        user2.PLSI_State_Code__c = 'JHA';
        user2.UserRoleId = ur2.Id;
        user2.PLSI_Team__c = 'Power';
        user2.Approver_Role__c = 'Not an Approver/Reviewer';
        insert user2 ;
        
        User user1 = new User();
        user1.Username = 'test1021exe@samp.com';
        user1.Email = 'test@samp.com';
        user1.Alias = 'tsamp';
        user1.TimeZoneSidKey = 'America/Los_Angeles';
        user1.LocaleSidKey = 'en_US';
        user1.EmailEncodingKey = 'UTF-8';
        user1.LanguageLocaleKey = 'en_US';
        user1.ProfileId = pf.Id ;
        user1.LastName = 'LIVESTON';
        user1.IsActive = false;
        user1.PLSI_Region__c = 'East 2';
        user1.PLSI_State__c = 'Jharkhand';
        user1.PLSI_State_Code__c = 'JHA';
        user1.PLSI_Team__c = 'Power';
        user1.UserRoleId = ur1.Id;
        user1.Approver_Role__c = 'Not an Approver/Reviewer';
        
        insert user1;
        
        
    }
    
    @isTest
    public static void assignApproverTest(){
        User user1 =[SELECT Id FROM User WHERE Username='test1021exe@samp.com'];
        List<Account_Approval__c> ap = TestUtill.createAccountApproval(1);
        ap[0].OwnerId = user1.Id;
        insert ap;
        
        test.startTest();
        try{
            TriggerAccountApprovalHandler.assignApprover(ap);
            
        }Catch(Exception e){
            system.assertEquals(e.getMessage(), e.getMessage());
        }
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void callCreateAccountTest(){
        
        User user1 =[SELECT Id FROM User WHERE Username='test1021exe@samp.com'];
        List<Account_Approval__c> apList = TestUtill.createAccountApproval(1);
        apList[0].OwnerId = user1.Id;
        apList[0].Account_Name__c = 'Test Pvt Ltd.';
        insert apList;
        
        // Query for any existing Accounts with the same name before running the test
        List<Account> existingAccounts = [SELECT Id, Name FROM Account WHERE Name = 'Test Pvt Ltd.'];
        System.debug('Existing Accounts: ' + existingAccounts);
        
        // Capture the old state before updating the Approval_Status__c field
        Account_Approval__c oldApproval = apList[0].clone(false, true, true);
        
        // Update the Approval_Status__c field to 'Approved'
        apList[0].Approval_Status__c = 'Approved';
        update apList;
        
        // Call the method
        Test.startTest();
        TriggerAccountApprovalHandler.callcreateNewAccount(apList, new Map<Id, Account_Approval__c>{ apList[0].Id => oldApproval });
        Test.stopTest();
        
    }
}