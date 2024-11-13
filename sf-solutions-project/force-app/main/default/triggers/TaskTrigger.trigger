//Section 3.2. Assignment 
trigger TaskTrigger on Task (before update) {

    if (Trigger.isBefore && Trigger.isUpdate) {
        TaskTriggerHandler.beforeUpdateMethod(Trigger.new, Trigger.oldMap);
    } 

}