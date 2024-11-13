//Section 2 checkpoint class 6
@isTest
private class AccountTriggerHandlerTest {

    @TestSetup
    static void setup(){

        //Creating a Test Account that will be shared amongst each quote
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;

        List<Opportunity> oppsToInsert = new List<Opportunity>();

        //Opportunity with no Purchase Override
        Opportunity oppNoPCO = new Opportunity();
        oppNoPCO.Name = 'No Purchase Override';
        oppNoPCO.StageName = 'Qualification';
        oppNoPCO.CloseDate = Date.today();
        oppNoPCO.AccountId = testAccount.Id;
        oppsToInsert.add(oppNoPCO);

        //Inserting Opportunity with Purchase Cadence Override, Quarterly
        Opportunity oppWithPCO = new Opportunity();
        oppWithPCO.Name = 'Has Quarterly Cadence Override';
        oppWithPCO.CloseDate = Date.today().addDays(3);
        oppWithPCO.StageName = 'Qualification';
        oppWithPCO.Purchase_Cadence_Override__c = 'Quarterly';
        oppWithPCO.AccountId = testAccount.Id;
        oppsToInsert.add(oppWithPCO);
        
        //Inserting Opportunity with Purchase Cadence Override, Quarterly
        Opportunity oppWithPCO2 = new Opportunity();
        oppWithPCO2.Name = 'Has Semi-Annually Override';
        oppWithPCO2.CloseDate = Date.today().addDays(3);
        oppWithPCO2.StageName = 'Qualification';
        oppWithPCO2.Purchase_Cadence_Override__c = 'Semi-Annually';
        oppWithPCO2.AccountId = testAccount.Id;
        oppsToInsert.add(oppWithPCO2);

        //Inserting Opportunity with Purchase Cadence Override, Quarterly
        Opportunity oppWithPCO3 = new Opportunity();
        oppWithPCO3.Name = 'Has Annually Override';
        oppWithPCO3.CloseDate = Date.today().addDays(3);
        oppWithPCO3.StageName = 'Qualification';
        oppWithPCO3.Purchase_Cadence_Override__c = 'Annually';
        oppWithPCO3.AccountId = testAccount.Id;
        oppsToInsert.add(oppWithPCO3);

        //Inserting Opportunity with Purchase Cadence Override, Quarterly
        Opportunity oppWithPCO4 = new Opportunity();
        oppWithPCO4.Name = 'Has Monthly Override';
        oppWithPCO4.CloseDate = Date.today().addDays(3);
        oppWithPCO4.StageName = 'Qualification';
        oppWithPCO4.Purchase_Cadence_Override__c = 'Monthly';
        oppWithPCO4.AccountId = testAccount.Id;
        oppsToInsert.add(oppWithPCO4);

        insert oppsToInsert;

        List<SBQQ__Quote__c> quotesToInsert = new List<SBQQ__Quote__c>();
        
        //Inserting Draft Quote with a related Account, no PCO
        SBQQ__Quote__c accQuoteNoPCO = new SBQQ__Quote__c();
        accQuoteNoPCO.SBQQ__Account__c = testAccount.Id;
        accQuoteNoPCO.SBQQ__Opportunity2__c = oppNoPCO.Id;
        accQuoteNoPCO.SBQQ__Status__c = 'Draft';
        insert accQuoteNoPCO;

        //Each Draft Quote below has a related Account and related Opportunity 
        //With Purchase Cadence Override varying per Quote
        
        //Quarterly Override
        SBQQ__Quote__c accOppQuote = new SBQQ__Quote__c();
        accOppQuote.SBQQ__Account__c = testAccount.Id;
        accOppQuote.SBQQ__Opportunity2__c = oppWithPCO.Id;
        accOppQuote.SBQQ__Status__c = 'Draft';
        quotesToInsert.add(accOppQuote);

        //Semi Annually Override
        SBQQ__Quote__c accOppQuote2 = new SBQQ__Quote__c();
        accOppQuote2.SBQQ__Account__c = testAccount.Id;
        accOppQuote2.SBQQ__Opportunity2__c = oppWithPCO2.Id;
        accOppQuote2.SBQQ__Status__c = 'Draft';
        quotesToInsert.add(accOppQuote2);

        //Annually Override
        SBQQ__Quote__c accOppQuote3 = new SBQQ__Quote__c();
        accOppQuote3.SBQQ__Account__c = testAccount.Id;
        accOppQuote3.SBQQ__Opportunity2__c = oppWithPCO3.Id;
        accOppQuote3.SBQQ__Status__c = 'Draft';
        quotesToInsert.add(accOppQuote3);

        //Monthly Override
        SBQQ__Quote__c accOppQuote4 = new SBQQ__Quote__c();
        accOppQuote4.SBQQ__Account__c = testAccount.Id;
        accOppQuote4.SBQQ__Opportunity2__c = oppWithPCO4.Id;
        accOppQuote4.SBQQ__Status__c = 'Draft';
        quotesToInsert.add(accOppQuote4);

        insert quotesToInsert;
    }

    //Consists of 4 tests where the Account Purchase Cadence is updated to each cadence
    @isTest
    static void updateRelatedQuotesTest() {

        //Query for Test Account
        Account testAccount = [
            SELECT Id, Name, Purchase_Cadence__c
            FROM Account
            WHERE Name = 'Test Account'
            LIMIT 1
        ];     
        
        //Test 1: Updating Account Purchase Cadence to Monthly, Opportunity Purchase Cadence Override to Quarterly 
        //Quote with related Account No PCO should update to Subcription Term 1
        //Quote with related Account and related Opportunity PCO should update to Subcription Term 3
        testAccount.Purchase_Cadence__c = 'Monthly';
        update testAccount;

        SBQQ__Quote__c quoteNoPCO = [
            SELECT Id, SBQQ__SubscriptionTerm__c 
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Purchase_Cadence_Override__c = null
            LIMIT 1
        ];
        SBQQ__Quote__c accOppQuote = [
            SELECT Id, SBQQ__SubscriptionTerm__c 
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Purchase_Cadence_Override__c = 'Quarterly'
            LIMIT 1
        ];

        //Each System Assert checks both Quote Subscription Terms to make sure it reflects each Cadence
        System.assertEquals(
            1, 
            quoteNoPCO.SBQQ__SubscriptionTerm__c, 
            'Subscription term not updated to match Monthly Account Purchase Cadence'
        );
        System.assertEquals(
            3, 
            accOppQuote.SBQQ__SubscriptionTerm__c, 
            'Subscription term not updated to match Quarterly Opportunity Purchase Cadence Override'
        );

        System.debug('Passed Test 1');

        //Test 2: Updating Account Purchase Cadence to Quarterly, Opportunity Purchase Cadence Override to Semi-Annually 
        //Quote with related Account and no PCO should update to Subcription Term 3
        //Quote with related Account and related Opportunity PCO should update to Subcription Term 6
        //Query for Test Account
        testAccount.Purchase_Cadence__c = 'Quarterly';
        update testAccount;
        
        quoteNoPCO = [
            SELECT Id, SBQQ__SubscriptionTerm__c 
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Purchase_Cadence_Override__c = null
            LIMIT 1
        ];
        SBQQ__Quote__c accOppQuote2 = [
            SELECT Id, SBQQ__SubscriptionTerm__c 
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Purchase_Cadence_Override__c = 'Semi-Annually'
            LIMIT 1
        ];

        System.assertEquals(
            3, 
            quoteNoPCO.SBQQ__SubscriptionTerm__c, 
            'Subscription term not updated to match Quarterly Account Purchase Cadence'
        );
        System.assertEquals(
            6, 
            accOppQuote2.SBQQ__SubscriptionTerm__c, 
            'Subscription term not updated to match Semi-Annually Opportunity Purchase Cadence Override'
        );

        System.debug('Passed Test 2');

        //Test 3: Updating Account Purchase Cadence to Semi-Annually, Opportunity Purchase Cadence Override to Annually 
        //Quote with related Account and no PCO should update to Subcription Term 6
        //Quote with related Account and related Opportunity PCO should update to Subcription Term 12
        testAccount.Purchase_Cadence__c = 'Semi-Annually';
        update testAccount;

        quoteNoPCO = [
            SELECT Id, SBQQ__SubscriptionTerm__c 
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Purchase_Cadence_Override__c = null
            LIMIT 1
        ];
        SBQQ__Quote__c accOppQuote3 = [
            SELECT Id, SBQQ__SubscriptionTerm__c 
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Purchase_Cadence_Override__c = 'Annually'
            LIMIT 1
        ];

        System.assertEquals(
            6, 
            quoteNoPCO.SBQQ__SubscriptionTerm__c, 
            'Subscription term not updated to match Semi-Annually Account Purchase Cadence'
        );
        System.assertEquals(
            12, 
            accOppQuote3.SBQQ__SubscriptionTerm__c, 
            'Subscription term not updated to match Annually Opportunity Purchase Cadence Override'
        );

        System.debug('Passed Test 3');

        //Test 4: Updating Account Purchase Cadence to Annually, Opportunity Purchase Cadence Override to Monthly 
        //Quote with related Account and no PCO should update to Subcription Term 12
        //Quote with related Account and related Opportunity PCO should update to Subcription Term 1
        testAccount.Purchase_Cadence__c = 'Annually';
        update testAccount;

        quoteNoPCO = [
            SELECT Id, SBQQ__SubscriptionTerm__c 
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Purchase_Cadence_Override__c = null
            LIMIT 1
        ];
        SBQQ__Quote__c accOppQuote4 = [
            SELECT Id, SBQQ__SubscriptionTerm__c 
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Purchase_Cadence_Override__c = 'Monthly'
            LIMIT 1
        ];

        System.assertEquals(
            12, 
            quoteNoPCO.SBQQ__SubscriptionTerm__c, 
            'Subscription term not updated to match Annually Account Purchase Cadence'
        );
        System.assertEquals(
            1, 
            accOppQuote4.SBQQ__SubscriptionTerm__c, 
            'Subscription term not updated to match Monthly Opportunity Purchase Cadence Override'
        );

        System.debug('Passed Test 4');
    }

}