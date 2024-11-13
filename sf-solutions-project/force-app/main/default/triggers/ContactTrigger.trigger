trigger ContactTrigger on Contact (before insert, after insert, before update, after update) {

    if (Trigger.isBefore && Trigger.isInsert) {

        //Had to create instance of this class due to not being able to set up static methods
        GovernorLimitsHelper glh = new GovernorLimitsHelper();
        glh.printAllLimits('AccountTrigger Before Insert');
        ContactTriggerHandler.beforeInsertMethod(Trigger.new);

    } else if (Trigger.isAfter && Trigger.isInsert) {
        
        GovernorLimitsHelper glh = new GovernorLimitsHelper();
        glh.printAllLimits('ContactTrigger After Insert');
        ContactTriggerHandler.afterInsertMethod(Trigger.new);
    
    } else if (Trigger.isBefore && Trigger.isUpdate) {
    
        GovernorLimitsHelper glh = new GovernorLimitsHelper();
        glh.printAllLimits('ContactTrigger Before Update');
        ContactTriggerHandler.beforeUpdateMethod(Trigger.new, Trigger.oldMap);
    
    } else if (Trigger.isAfter && Trigger.isUpdate) {
    
        GovernorLimitsHelper glh = new GovernorLimitsHelper();
        glh.printAllLimits('ContactTrigger After Update');
        ContactTriggerHandler.afterUpdateMethod(Trigger.new, Trigger.oldMap);
    
    }

}