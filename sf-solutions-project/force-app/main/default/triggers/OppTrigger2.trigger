//Checkpoint 3 Trigger 1
trigger OppTrigger2 on Opportunity (before delete, before insert, before update, after delete, after insert, after update) {

    if (Trigger.isBefore && Trigger.isInsert) {
        
        OppTriggerHandler2.beforeInsertMethod(Trigger.new);
    
    } else if (Trigger.isAfter && Trigger.isInsert) {

        OppTriggerHandler2.afterInsertMethod(Trigger.new);

    } else if (Trigger.isBefore && Trigger.isUpdate) {

        OppTriggerHandler2.beforeUpdateMethod(Trigger.new, Trigger.oldMap);
    
    } else if (Trigger.isAfter && Trigger.isUpdate) {

        OppTriggerHandler2.afterUpdateMethod(Trigger.new, Trigger.oldMap);
    
    }

}