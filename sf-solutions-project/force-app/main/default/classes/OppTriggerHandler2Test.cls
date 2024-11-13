@isTest
public class OppTriggerHandler2Test {
    
    @TestSetup
    static void makeData(){
        
        //Creates a test Account, Opportunity and Team Member
        TestDataCreator.createTestData();
    }

    @IsTest
    static void callQueueablesTest() {
        
        //Querying the testAcc from Setup
        Account testAcc = [
            SELECT Id, 
            (
                SELECT Name, Team_Member__r.Id 
                FROM Team_Members__r
            ) 
            FROM Account LIMIT 1
        ];

        Test.startTest();

        //Inserting one opportunity with its Account having Active Buyer set as True
        Opportunity tlOpp = new Opportunity();
        tlOpp.AccountId = testAcc.Id;
        tlOpp.Name = testAcc.Team_Members__r[0].Name + ' - Opportunity';
        tlOpp.StageName = 'Qualification';
        tlOpp.CloseDate = Date.today().addDays(30);
        tlOpp.OwnerId = testAcc.Team_Members__r[0].Team_Member__r.Id;
        insert tlOpp;

        Test.stopTest();

        tlOpp = [
            SELECT Id, Account.Active_Buyer__c
            FROM Opportunity
            WHERE StageName = 'Qualification'
            LIMIT 1
        ];

        //Testing for the handler method before starting our queueables
        System.assertEquals(true, tlOpp.Account.Active_Buyer__c, 'Did not find Opportunity with Active Buyer Account');

    }
    
    //Testing first queueable class from class trigger
    @isTest
    static void callNewQuoteQueueableTest() {
        
        //Querying the testAcc from Setup
        Account testAcc = [
            SELECT Id, 
            (
                SELECT Name, Team_Member__r.Id 
                FROM Team_Members__r
            ) 
            FROM Account LIMIT 1
        ];

        //Inserting one opportunity with its Account having Active Buyer set as True
        Opportunity tlOpp = new Opportunity();
        tlOpp.AccountId = testAcc.Id;
        tlOpp.Name = testAcc.Team_Members__r[0].Name + ' - Opportunity';
        tlOpp.StageName = 'Qualification';
        tlOpp.CloseDate = Date.today().addDays(30);
        tlOpp.OwnerId = testAcc.Team_Members__r[0].Team_Member__r.Id;
        insert tlOpp;

        List<Opportunity> oppList = [
            SELECT Id
            FROM Opportunity
            WHERE StageName = 'Qualification'
        ];

        Test.startTest();

        NewQuoteQueueable queueableJob = new NewQuoteQueueable(oppList);
        Id jobId = System.enqueueJob(queueableJob);

        Test.stopTest();

        //Querying the quotes that should be added upon opportunity insert
        List<SBQQ__Quote__c> newQuoteList = [
            SELECT Id
            FROM SBQQ__Quote__c
        ];

        //Asserting 1 quote was inserted 
        System.assertEquals(1, newQuoteList.size(), 'New Related Quotes not inserted');
    }

    //Testing second queueable chained from first queueable
    @isTest
    static void callEmailTMQueueableTest() {
        
        //Querying the same Test Account
        Account testAcc = [
            SELECT Id, 
            (
                SELECT Name, Team_Member__r.Id 
                FROM Team_Members__r
            ) 
            FROM Account LIMIT 1
        ];

        //Inserting same Opportunity
        Opportunity tlOpp = new Opportunity();
        tlOpp.AccountId = testAcc.Id;
        tlOpp.Name = testAcc.Team_Members__r[0].Name + ' - Opportunity';
        tlOpp.StageName = 'Qualification';
        tlOpp.CloseDate = Date.today().addDays(30);
        tlOpp.OwnerId = testAcc.Team_Members__r[0].Team_Member__r.Id;
        insert tlOpp;

        //Querying back the opportunity into a list which we pass into the queueable constructor
        List<Opportunity> oppList = [
            SELECT Id, OwnerId, LastModifiedBy.ManagerId
            FROM Opportunity
            WHERE Id = :tlOpp.Id
        ];

        Test.startTest();
        
        //Calling the constrcutor for the queueable
        EmailTMQueueable queueableJob = new EmailTMQueueable(oppList);
        Id jobId = System.enqueueJob(queueableJob);

        Test.stopTest();

        //Testing that the Emails were sent successfully
        AsyncApexJob jobInfo = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob WHERE Id =:jobId LIMIT 1];
        System.assert(jobInfo.NumberOfErrors == 0, 'Emails Sent Successfully'); 
    }
}