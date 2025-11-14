/* 
    Author: Frank Berni
    Purpose: 
    Account Trigger that calls IntegrationCalloutService on new or updated Accounts with Sync Account checked
    @DEV-EDIT feel free to take code and integrate with existing Account Triggers 
    or duplicate functionality with another Apex Trigger on a different Object
    @README Ensure IntegrationCalloutService and IntegrationCalloutJob is deployed 
    and Sync_Account and Sync_Id fields exist on Account before deploying
*/ 
trigger AccountTriggerForCallouts on Account (after insert, after update) {
    
    // Handle New Accounts
    if (Trigger.isInsert) {
        for (Account acc : Trigger.new) {
            // When Sync Account is checked and Sync Id is empty, call IntegrationCalloutService
            if (acc.Sync_Account__c == true && acc.Sync_Id__c == null) {
                IntegrationCalloutService.sendAccountPayload(acc.Id);
            }
        }
    }
    // Handle Updated Accounts
    if (Trigger.isUpdate) {
        for (Account acc : Trigger.new) {
            Account oldAcc = Trigger.oldMap.get(acc.Id);
            Boolean turnedOn = (acc.Sync_Account__c == true && oldAcc.Sync_Account__c != true);
            // When Sync Account has only been checked and Sync Id is empty, call IntegrationCalloutService
            if (turnedOn && acc.Sync_Id__c == null) {
                IntegrationCalloutService.sendAccountPayload(acc.Id);
            }
        }
    }
}