@isTest
public with sharing class OpportunityBatchableAutoCloseTest {

    @TestSetup
    static void setup() {

        //Creating Opportunities with one with a close date in the past and another with one in the future
        List<Opportunity> oppsToInsert = new List<Opportunity>();

        Opportunity pastOpp = new Opportunity();
        pastOpp.Name = 'Past Test Opp';
        pastOpp.StageName = 'Needs Analysis';
        pastOpp.CloseDate = Date.today().addDays(-1);
        oppsToInsert.add(pastOpp);

        Opportunity futureOpp = new Opportunity();
        futureOpp.Name = 'Future Test Opp';
        futureOpp.StageName = 'Needs Analysis';
        futureOpp.CloseDate = Date.today().addDays(1);
        oppsToInsert.add(futureOpp);

        insert oppsToInsert;

    }

    //Testing Schedulable context from Assignment in Section 3-5
    @isTest
    static void BatchableAutoCloseScheduleableTest(){

        Test.startTest();

        //This is also used in the Execute Anonymous Window when we want to run this outside of testing
        OpportunityBatchableAutoClose myJob = new OpportunityBatchableAutoClose();
        String cronExpression = '0 0 1 ? * MON,TUE,WED,THU,FRI,SAT,SUN *';
        String jobID = System.schedule('OpportunityBatchableAutoClose in a Schedulable!', cronExpression, myJob);

        Test.stopTest();

        //Querying the CronTrigger Class and grabbing the NextFireTime matching our jobId from above
        CronTrigger cron = [SELECT Id, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        //Making sure that the NextFireTime is not null
        System.assert(cron.NextFireTime != null, 'CronTrigger has been scheduled');

    }
    
    @isTest
    static void OpportunityBatchableAutoCloseTest() {

        Test.startTest();

        OpportunityBatchableAutoClose newBatch = new OpportunityBatchableAutoClose();
        Id newApexBatchId = Database.executeBatch(newBatch);

        Test.stopTest();

        //Making sure the StageName updates to Closed Lost
        Opportunity testOpp = [SELECT Id, StageName FROM Opportunity WHERE Name = 'Past Test Opp' LIMIT 1];
        System.assertEquals('Closed Lost', testOpp.StageName, 'Opportunity not updated to Closed Lost');

    }

    //Assignment 2
    @isTest
    static void OpportunityBatchableAutoCloseWithIdsTest() {

        //Creating a set that takes in all Ids from Opportunities we created
        Set<Id> oppIdSet = new Set<Id>();

        for (Opportunity opp : [SELECT Id FROM Opportunity]) {
            oppIdSet.add(opp.Id);
        }

        Test.startTest();

        //We use that set to feed into our second method for OpportunityBatchableAutoClose
        OpportunityBatchableAutoClose newBatch = new OpportunityBatchableAutoClose(oppIdSet);
        Id newApexBatchId = Database.executeBatch(newBatch);

        Test.stopTest();

        //Same assertion as above but pulling from the oppIdSet instead
        Opportunity closedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id IN :oppIdSet LIMIT 1];
        System.assertEquals('Closed Lost', closedOpp.StageName, 'Opportunity not updated to Closed Lost');

    }

    
}