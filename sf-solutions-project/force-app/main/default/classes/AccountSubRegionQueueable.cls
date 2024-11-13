public with sharing class AccountSubRegionQueueable implements Queueable{
    
    private List<Account> parentAccountList;
    private Map<String, List<String>> subRegionByRegionMap = new Map<String, List<String>>();

    //Assigning our parentAccount List and our Map which consists of each Region to their Subregions
    public AccountSubRegionQueueable(List<Account> parentAccountList) {
        this.parentAccountList = parentAccountList;
        subRegionByRegionMap.put('APAC', new List<String>{'East Asia','South Asia','Southeast Asia', 'Oceania'});
        subRegionByRegionMap.put('EMEA', new List<String>{'Europe','Middle-East','Africa'});
        subRegionByRegionMap.put('AMER', new List<String>{'North America','Central America','South America'});

    }

    public void execute(QueueableContext qc) {
        
        List<Account> subRegionAccToInsert = new List<Account>();

        //Double for loop used to save code space and efficiently add Child Accounts for each SubRegion
        for (Account acc : parentAccountList) {

            if (subRegionByRegionMap.containsKey(acc.Region__c)) {
                for (String subRegion : subRegionByRegionMap.get(acc.Region__c)) {

                    Account subRegionAcc = new Account();
                    subRegionAcc.ParentId = acc.Id;
                    subRegionAcc.Name = acc.Name + ' ' + subRegion;
                    subRegionAcc.Subregion__c = subRegion;
                    subRegionAccToInsert.add(subRegionAcc);
                } 
            }  
        }

        //Making sure the list is not empty to insert Child Accounts
        if (!subRegionAccToInsert.isEmpty()) {
            
            insert subRegionAccToInsert;

            //Setting up next chained queueable for creating Child Accounts for Subregions
            if (!Test.isRunningTest()) { // Check to ensure we are not running in a Test Context - Can't chain Queueables in Tests
                AccountCountryRegionQueueable queueableJob = new AccountCountryRegionQueueable(subRegionAccToInsert);
                Id jobId = System.enqueueJob(queueableJob);
            }   

        }
    }
}