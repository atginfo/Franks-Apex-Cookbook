@isTest
public class TableTennisBatchableTest {
   
    //Testing when New Opportunities are created based on our Team Leaders
    @IsTest
    static void NewOppGeneratorTest() {

        //Creates a Test Account, Opportunity and Team Member
        TestDataCreator.createTestData();

        Test.startTest();

        NewOppGenerator newBatch = new NewOppGenerator();
        Id newApexBatchId = Database.executeBatch(newBatch);

        Test.stopTest();

        //Querying the new Opportunity that should be inserted
        Opportunity newOpp = [
            SELECT StageName 
            FROM Opportunity
            WHERE StageName = 'Qualification'
            LIMIT 1
        ];

        //Testing that a New Opp was inserted and the StageName is based on TT Grasp
        //Shakehand == Qualification
        System.assertEquals(
            'Qualification', 
            newOpp.StageName, 
            'New Opportunity not inserted with StageName based on Preferred Table Tennis Grasp'
        );
    }

    //Testing the schedulable context for batch
    @IsTest
    static void NewOppGeneratorSchedulableTest() {

        //Creates a Test Account, Opportunity and Team Member
        TestDataCreator.createTestData();

        Test.startTest();

        //Testing that we scheduled our Batch for every Monday Morning at 5 am
        NewOppGenerator myJob = new NewOppGenerator();
        String cronExpression = '0 0 5 ? * MON *';
        String jobID = System.schedule('NewOppGenerator Schedulabled', cronExpression, myJob);

        Test.stopTest();

        //Querying the CronTrigger class
        CronTrigger cron = [SELECT Id, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        
        //Making sure that the NextFireTime is not null
        System.assert(cron.NextFireTime != null, 'CronTrigger has been scheduled');

    }

    //Testing when Orders are generated for Approved Quotes
    @IsTest
    static void OrderForApprovedQuotesTest() {

        //Creating a Test Product, PriceBook, Account, Opportunity, Team Member, Quote and Quote Line
        TestDataCreator.createCPQData();

        Test.startTest();

        //Calling our constructor for Batch
        OrdersForApprovedQuotes newBatch = new OrdersForApprovedQuotes();
        Id newApexBatchId = Database.executeBatch(newBatch);        

        Test.stopTest();

        //Querying the Quote with updated Ordered field and its new Order
        SBQQ__Quote__c updatedQuote = [
            SELECT Id, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.StageName,
            (
                SELECT Id
                FROM SBQQ__Orders__r
            )
            FROM SBQQ__Quote__c
            LIMIT 1
        ];

        //Making sure the Order was created when we checked our Ordered field
        System.assertEquals(
            1, 
            updatedQuote.SBQQ__Orders__r.size(), 
            'Order not generated for Approved Quote'
        );

        //Making sure the related Opportunity StageName updated as well
        System.assertEquals(
            'Closed Won', 
            updatedQuote.SBQQ__Opportunity2__r.StageName, 
            'Stage Name of related Opportunity not updated to Closed Won'
        );
        
    }

    //Testing the schedulable context for our batch class
    @IsTest
    static void OrderForApprovedQuotesSchedulableTest() {

        //Creating a Test Product, PriceBook, Account, Opportunity, Team Member, Quote and Quote Line
        TestDataCreator.createCPQData();

        Test.startTest();

        //Testing that we scheduled our Batch for every night at 9 pm
        OrdersForApprovedQuotes myJob = new OrdersForApprovedQuotes();
        String cronExpression = '0 0 21 ? * MON,TUE,WED,THU,FRI,SAT,SUN *';
        String jobID = System.schedule('OrdersForApprovedQuotes Schedulabled', cronExpression, myJob);      

        Test.stopTest();

        //Querying the CronTrigger class
        CronTrigger cron = [SELECT Id, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        
        //Making sure that the NextFireTime is not null
        System.assert(cron.NextFireTime != null, 'CronTrigger has been scheduled');

    }

    @IsTest
    static void stageNameGraspTest() {
        
        //Testing each scenario in this method to reach 100% code coverage
        String stageName1 = NewOppGenerator.graspStageName('Penholder');
        System.assertEquals('Prospecting', stageName1, 'Returned value as expected');

        String stageName2 = NewOppGenerator.graspStageName('Shakehand');
        System.assertEquals('Qualification', stageName2, 'Returned value as expected');

        String stageName3 = NewOppGenerator.graspStageName('Chinese Penhold');
        System.assertEquals('Needs Analysis', stageName3, 'Returned value as expected');

        String stageName4 = NewOppGenerator.graspStageName('Reverse Backhand');
        System.assertEquals('Id. Decision Makers', stageName4, 'Returned value as expected');

        String stageName5 = NewOppGenerator.graspStageName('Korean Grip');
        System.assertEquals('Perception Analysis', stageName5, 'Returned value as expected');

    }
    
}