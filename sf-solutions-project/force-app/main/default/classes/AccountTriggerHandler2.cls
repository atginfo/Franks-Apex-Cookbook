public with sharing class AccountTriggerHandler2 {
    
    
    public static void beforeInsertMethod(List<Account> newList){
        
    }

    public static void afterInsertMethod(List<Account> newList){
        callAccountRegionQueueables(newList);
    }

    public static void beforeUpdateMethod(List<Account> newList, Map<Id, Account> oldMap){
        
    }

    public static void afterUpdateMethod(List<Account> newList, Map<Id, Account> oldMap){
        
    }

    // Helper Methods

    //This starts a queueable chain where we create several levels of Accounts to 
    //represent each Region, Subregion and Country
    private static void callAccountRegionQueueables(List<Account> newList) {

        List<Account> masterAccounts = new List<Account>();

        //Grabbing all New Accounts with Master Account checked
        for (Account acc : newList) {
            if(acc.Master_Account__c) {
                masterAccounts.add(acc);
            }
        }

        //Then we run our chain of queueables
        if (!masterAccounts.isEmpty()) {
            AccountRegionQueueable queueableJob = new AccountRegionQueueable(masterAccounts);
            Id jobId = System.enqueueJob(queueableJob);
        }

    }
}