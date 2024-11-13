public with sharing class AccountRegionQueueable implements Queueable {
    
    private List<Account> parentAccountList;
    private List<String> regionList;

    //Assigning our parentAccount List and our String list which consists of each Region
    public AccountRegionQueueable(List<Account> parentAccountList) {
        this.parentAccountList = parentAccountList;
        regionList = new List<String>{'APAC', 'EMEA', 'AMER', 'Extraterrestrial'};
    }

    public void execute(QueueableContext qc) {
        
        List<Account> regionAccToInsert = new List<Account>();

        //Double for loop used to save code space and efficiently add Child Accounts for each Region
        for (Account acc : parentAccountList) {

            for (String region : regionList) {

                Account regionAccount = new Account();
                regionAccount.ParentId = acc.Id;
                regionAccount.Name = acc.Name + ' ' + region;
                regionAccount.Region__c = region;
                regionAccToInsert.add(regionAccount);
            }  
        }

        //Making sure the list is not empty to insert Child Accounts
        if (!regionAccToInsert.isEmpty()) {
            
            insert regionAccToInsert;

            //Setting up next chained queueable for creating Child Accounts for Subregions
            if (!Test.isRunningTest()) { // Check to ensure we are not running in a Test Context - Can't chain Queueables in Tests
                AccountSubRegionQueueable queueableJob = new AccountSubRegionQueueable(regionAccToInsert);
                Id jobId = System.enqueueJob(queueableJob);
            }   

        }
    }
}