@isTest
public with sharing class AccountTriggerHandlerTest2 {
    
    //Testing to make sure that each Master Account receives a Child Account for each Region
    @isTest
    static void callAccountRegionQueueablesTest() {

        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.Master_Account__c = true;

        Test.startTest();

        insert testAccount;

        Test.stopTest();

        //Querying Accounts where Region is filled
        List<Account> regionAccounts = [
            SELECT Id, Name
            FROM Account
            WHERE Region__c != null
        ];

        //4 child accounts should be inserted 
        System.assertEquals(
            4,
            regionAccounts.size(),
            'Did not insert child accounts per each Region'
        );

    }

    //Testing that each Region Account receives a Subregion related to Master Account
    @isTest
    static void callAccountSubRegionQueueablesTest(){

        Account regionAccount = new Account();
        regionAccount.Name = 'Test AMER Account';
        regionAccount.Region__c = 'AMER';
        insert regionAccount;

        Test.startTest();
        
        //Since we can't test queuable chains, we call the method here instead
        AccountSubRegionQueueable queueableJob = new AccountSubRegionQueueable(new List<Account>{regionAccount});
        Id jobId = System.enqueueJob(queueableJob);
        
        Test.stopTest();

        //Query for Accounts with Subregion filled
        List<Account> subRegionAccounts = [
            SELECT Id, Name
            FROM Account
            WHERE Subregion__c != null
        ];

        //There should be 3 child accounts inserted for AMER region
        System.assertEquals(
            3,
            subRegionAccounts.size(),
            'Did not insert child accounts per each SubRegion'
        );

    }

    //Testing to make sure each Subregion account has a Country Account related to Master
    @isTest
    static void callAccountCountryRegionQueueablesTest(){

        Account countryAccount = new Account();
        countryAccount.Name = 'Test Southeast Asia Account';
        countryAccount.Subregion__c = 'Southeast Asia';
        insert countryAccount;

        Test.startTest();
        
        //Can't test queuable chains so we call it here instead
        AccountCountryRegionQueueable queueableJob = new AccountCountryRegionQueueable(new List<Account>{countryAccount});
        Id jobId = System.enqueueJob(queueableJob);
        
        Test.stopTest();

        //Accounts where their Region Country is filled in
        List<Account> countryAccounts = [
            SELECT Id, Name
            FROM Account
            WHERE Region_Country__c != null
        ];

        //There should be 1 child account inserted for Southeast Asia
        System.assertEquals(
            1,
            countryAccounts.size(),
            'Did not insert child accounts per each Country'
        );   
    }
}