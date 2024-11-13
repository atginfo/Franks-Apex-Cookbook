//Section 2 checkpoint trigger 2
trigger QuoteTrigger on SBQQ__Quote__c (before delete, before insert, before update, after delete, after insert, after update) {
    
    if (Trigger.isBefore && Trigger.isInsert) {
        
        QuoteTriggerHandler.beforeInsertMethod(Trigger.new);

    } else if (Trigger.isBefore && Trigger.isUpdate) {

        QuoteTriggerHandler.beforeUpdateMethod(Trigger.new, Trigger.oldMap);
    
    }
    else if (Trigger.isAfter && Trigger.isUpdate) {

        QuoteTriggerHandler.afterUpdateMethod(Trigger.new, Trigger.oldMap);
    
    }
}