@isTest
private class MyFirstApexBatchTest {

    //When testing for scheduable context
    @isTest
    static void myFirstApexBatchScheduleableTest(){

        createAccounts(5, 'Entertainment');
        
        Test.startTest();

        MyFirstApexBatch myJob = new MyFirstApexBatch('Entertainment');
        String cronExpression = '0 30 14 * * ?';
        String jobId = System.schedule('MyFirstApexBatch in a Schedulable!', cronExpression, myJob);

        Test.stopTest();

        //Querying the CronTrigger Class and grabbing the NextFireTime matching our jobId from above
        CronTrigger cron = [SELECT Id, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        //Making sure that the NextFireTime is not null
        System.assert(cron.NextFireTime != null, 'CronTrigger has been scheduled');

    }

    //When testing for Batch Context 
    @isTest
    static void myFirstApexBatchTest(){

        createAccounts(20, 'Technology');

        System.debug('MyFirstApexBatchTest: before startTest()');

        Test.startTest();

        MyFirstApexBatch batchJob = new MyFirstApexBatch('Technology');
        Id jobId = Database.executeBatch(batchJob, 50); // Set to 20 to ensure it only runs once
        System.debug('MyFirstApexBatchTest: after executeBatch()');

        Test.stopTest();

        System.debug('MyFirstApexBatchTest: after stopTest()');

        AsyncApexJob jobInfo = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob WHERE Id =:jobId LIMIT 1];
        System.assert(jobInfo.Status != null, 'Apex Batch not kicked off as expected');

    }

    // Helper Method to create Account records
    private static List<Account> createAccounts(Integer numAccounts, String industry){

        List<Account> accountsToInsert = new List<Account>();

        // Create 20 Accounts
        for (Integer i = 0; i < numAccounts; i++) {

            Account newAccount = new Account();
            newAccount.Name = 'New Account ' + i;
            newAccount.Industry = industry;

            accountsToInsert.add(newAccount);
        }

        insert accountsToInsert;
        return accountsToInsert;

    }

}