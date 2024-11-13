//Section 2 checkpoint trigger 1
trigger OpportunityTrigger on Opportunity (before delete, before insert, before update, after delete, after insert, after update) {

    if (Trigger.isBefore && Trigger.isInsert) {
        
        OpportunityTriggerHandler.beforeInsertMethod(Trigger.new);
    
    } else if (Trigger.isAfter && Trigger.isInsert) {

        OpportunityTriggerHandler.afterInsertMethod(Trigger.new, Trigger.newMap, Trigger.oldMap);

    } else if (Trigger.isBefore && Trigger.isUpdate) {

        OpportunityTriggerHandler.beforeUpdateMethod(Trigger.new, Trigger.oldMap);
    
    } else if (Trigger.isAfter && Trigger.isUpdate) {

        OpportunityTriggerHandler.afterUpdateMethod(Trigger.new, Trigger.newMap, Trigger.oldMap);
    
    }

}