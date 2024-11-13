@isTest
private class ExampleQueueableJobTest {

    @isTest
    static void exampleQueueableJobTest(){

        System.debug('Before Start Test');

        // Add before calling any asynchronous code we need to test
        Test.startTest();

        ExampleQueueableJob queueableJob = new ExampleQueueableJob('Harry Potter');
        Id jobId = System.enqueueJob(queueableJob);
        System.debug('After kicking of Queueable');

        // When this method is called, all async code is run synchronously
        Test.stopTest();

        System.debug('After Stop Test');

        AsyncApexJob jobInfo = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob WHERE Id =:jobId LIMIT 1];
        System.assert(jobInfo.Status != null, 'Queueable not kicked off as expected');


    }

    /* Using Test.isRunningTest() Method when calling another queueable so it isn't chained
     together in a test class
        public void execute(QueueableContext context) {

            // Perform logic...

            // Only kick off other Queueable if we are NOT in a Test Context
            if (!Test.isRunningTest()) {
                AnotherQueueableJob secondQueueableJob = new AnotherQueueableJob('Fortuna Major');
                System.enqueueJob(secondQueueableJob);
            }

        } 
    */

}