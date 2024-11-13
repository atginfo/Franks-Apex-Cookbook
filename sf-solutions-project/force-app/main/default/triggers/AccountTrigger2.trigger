trigger AccountTrigger2 on Account (before delete, before insert, before update, after delete, after insert, after update) {

    if (Trigger.isBefore && Trigger.isInsert) {
        
        AccountTriggerHandler2.beforeInsertMethod(Trigger.new);

    } else if (Trigger.isAfter && Trigger.isInsert) {

        AccountTriggerHandler2.afterInsertMethod(Trigger.new);

    } else if (Trigger.isBefore && Trigger.isUpdate) {

        AccountTriggerHandler2.beforeUpdateMethod(Trigger.new, Trigger.oldMap);

    } else if (Trigger.isAfter && Trigger.isUpdate) {

        AccountTriggerHandler2.afterUpdateMethod(Trigger.new, Trigger.oldMap);

    }
}