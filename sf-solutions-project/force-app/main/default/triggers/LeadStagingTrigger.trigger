trigger LeadStagingTrigger on Lead_Staging__c (after insert) {
    
    if (Trigger.isAfter && Trigger.isInsert) {
        LeadStagingTriggerHandler.afterInsertMethod(Trigger.new);
    }

}