//Section 2 checkpoint trigger 3
trigger AccountTrigger on Account (before delete, before insert, before update, after delete, after insert, after update) {

    if (Trigger.isBefore && Trigger.isInsert) {
        
        AccountTriggerHandler.beforeInsertMethod(Trigger.new);

    } else if (Trigger.isAfter && Trigger.isInsert) {

        AccountTriggerHandler.afterInsertMethod(Trigger.new);

    } else if (Trigger.isBefore && Trigger.isUpdate) {

        AccountTriggerHandler.beforeUpdateMethod(Trigger.new, Trigger.oldMap);

    } else if (Trigger.isAfter && Trigger.isUpdate) {

        AccountTriggerHandler.afterUpdateMethod(Trigger.new, Trigger.newMap, Trigger.oldMap);

    }
}