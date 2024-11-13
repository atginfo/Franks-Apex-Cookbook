@isTest
public class TestDataCreator {
    
    //Creating Data for Testing NewOppGenerator
    public static void createTestData() {

        Account testAcc = New Account();
        testAcc.Name = 'Test Account';
        testAcc.Active_Buyer__c = true;
        insert testAcc;

        Opportunity testOpp = New Opportunity();
        testOpp.AccountId = testAcc.Id;
        testOpp.Name = 'Not Closed Won or Lost';
        testOpp.CloseDate = Date.Today().addDays(2);
        testOpp.StageName = 'Needs Analysis';
        insert testOpp;

        Team_Member__c tm = New Team_Member__c();
        tm.Account__c = testAcc.Id;
        tm.Team_Member__c = UserInfo.getUserId();
        tm.Name = 'Frank Berni';
        tm.Nickname__c = 'Frankie';
        tm.Preferred_Table_Tennis_Grasp__c = 'Shakehand';
        tm.Team_Leader__c = true;
        insert tm;

    }

    //Creating data for testing the OrdersForApprovedQuotes Class, 
    //To generate Orders Products, Pricebooks and Quote Lines have to be set up
    public static void createCPQData() {
        
        Product2 testProduct = new Product2();
        testProduct.Name = 'Test Product';
        testProduct.IsActive = true;
        testProduct.Family = 'Software';
        insert testProduct;

        PricebookEntry testPBE = new PricebookEntry();
        testPBE.UnitPrice = 1;
        testPBE.Pricebook2Id = Test.getStandardPricebookId();
        testPBE.Product2Id = testProduct.Id;
        testPBE.isActive = true;
        insert testPBE;

        Account testAcc = new Account();
        testAcc.Name = 'Test Account';
	    testAcc.Active_Buyer__c = true;
        insert testAcc;

        Team_Member__c tm = New Team_Member__c();
        tm.Account__c = testAcc.Id;
        tm.Team_Member__c = UserInfo.getUserId();
        tm.Name = 'Frank Berni';
        tm.Nickname__c = 'Frankie';
        tm.Preferred_Table_Tennis_Grasp__c = 'Shakehand';
        tm.Team_Leader__c = true;
        insert tm;

        Opportunity testOpp = new Opportunity();
        testOpp.Name = 'Test Opportunity';
        testOpp.StageName = 'Qualification';
        testOpp.CloseDate = Date.today();
        testOpp.AccountId = testAcc.Id;
        insert testOpp;

        //Make sure the Quote also has its PricebookId Field when testing
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote.SBQQ__Account__c = testAcc.Id;
        testQuote.SBQQ__Opportunity2__c = testOpp.Id;
        testQuote.SBQQ__Primary__c = true;
        testQuote.SBQQ__Status__c = 'Approved';
        testQuote.SBQQ__PricebookId__c = Test.getStandardPricebookId();
        insert testQuote;

        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c();
        testQuoteLine.SBQQ__Quote__c = testQuote.Id;
        testQuoteLine.SBQQ__Product__c = testProduct.Id;
        testQuoteLine.SBQQ__PricebookEntryId__c = testPBE.Id;
        insert testQuoteLine;

    }
}