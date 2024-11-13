// Section 2 checkpoint class 4
@isTest
public with sharing class QuoteTriggerHandlerTest {
    
    @TestSetup
    static void setup() {

        //Creating Test Account with Addresses filled in (Used in SetAddresses)
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.BillingStreet = '345 Street';
        testAccount.BillingCity = 'Ft. Myers';
        testAccount.BillingCountry = 'USA';
        testAccount.BillingState = 'FL';
        testAccount.BillingPostalCode = '66666';
        testAccount.ShippingStreet = '345 Street';
        testAccount.ShippingCity = 'Ft. Myers';
        testAccount.ShippingCountry = 'USA';
        testAccount.ShippingState = 'FL';
        testAccount.ShippingPostalCode = '66666';
        insert testAccount;

        List<Account> accsToInsert = new List<Account>();

        //Each Account has a specific cadence value (used in SetSubscription and SyncSubscription)
        Account monthAccount = new Account();
        monthAccount.Name = 'Has Monthly Cadence';
        monthAccount.Purchase_Cadence__c = 'Monthly';
        accsToInsert.add(monthAccount);
        
        Account quarterAccount = new Account();
        quarterAccount.Name = 'Has Quarterly Cadence';
        quarterAccount.Purchase_Cadence__c = 'Quarterly';
        accsToInsert.add(quarterAccount);

        Account semiAccount = new Account();
        semiAccount.Name = 'Has Semi-Annually Cadence';
        semiAccount.Purchase_Cadence__c = 'Semi-Annually';
        accsToInsert.add(semiAccount);

        Account annualAccount = new Account();
        annualAccount.Name = 'Has Annually Cadence';
        annualAccount.Purchase_Cadence__c = 'Annually';
        accsToInsert.add(annualAccount);

        if (!accsToInsert.isEmpty()){
            insert accsToInsert;
        }
        
        //Creating Test Opportunity with Addresses filled in (Used in Set Addresses)
        Opportunity testOpp = new Opportunity();
        testOpp.Name = 'Test Opportunity';
        testOpp.StageName = 'Qualification';
        testOpp.CloseDate = Date.today();
        testOpp.AccountId = testAccount.Id;
        testOpp.BillingCity__c = 'Ft. Myers'; 
        testOpp.BillingCountry__c = 'USA';
        testOpp.BillingPostalCode__c = '66666'; 
        testOpp.BillingState__c = 'FL'; 
        testOpp.BillingStreet__c = '345 Street';
        testOpp.ShippingCity__c = 'Ft. Myers'; 
        testOpp.ShippingCountry__c = 'USA'; 
        testOpp.ShippingPostalCode__c = '66666';
        testOpp.ShippingState__c = 'FL'; 
        testOpp.ShippingStreet__c = '345 Street';
        insert testOpp;

        //(Used in SyncSubscriptions)
        List<Opportunity> oppsToInsert = new List<Opportunity>();

        //First 4 Opportunities have no PCO and are related to each Account with PCs
        Opportunity monthAccOpp = new Opportunity();
        monthAccOpp.Name = 'Has Account Monthly PC';
        monthAccOpp.StageName = 'Qualification';
        monthAccOpp.CloseDate = Date.today();
        monthAccOpp.AccountId = monthAccount.Id;
        oppsToInsert.add(monthAccOpp);

        Opportunity quarterAccOpp = new Opportunity();
        quarterAccOpp.Name = 'Has Account Quarterly PC';
        quarterAccOpp.StageName = 'Qualification';
        quarterAccOpp.CloseDate = Date.today();
        quarterAccOpp.AccountId = quarterAccount.Id;
        oppsToInsert.add(quarterAccOpp);

        Opportunity semiAccOpp = new Opportunity();
        semiAccOpp.Name = 'Has Account Semi-Annually PC';
        semiAccOpp.StageName = 'Qualification';
        semiAccOpp.CloseDate = Date.today();
        semiAccOpp.AccountId = semiAccount.Id;
        oppsToInsert.add(semiAccOpp);

        Opportunity annualAccOpp = new Opportunity();
        annualAccOpp.Name = 'Has Account Annually PC';
        annualAccOpp.StageName = 'Qualification';
        annualAccOpp.CloseDate = Date.today();
        annualAccOpp.AccountId = annualAccount.Id;
        oppsToInsert.add(annualAccOpp);

        //Next 4 Opportunities have PCOs and are related to each Account with PCs, 
        //PCOs are offset to show it overriding the Account's PC
        Opportunity monthAccQuarterOpp = new Opportunity();
        monthAccQuarterOpp.Name = 'Has Opportunity Quarterly PCO';
        monthAccQuarterOpp.StageName = 'Qualification';
        monthAccQuarterOpp.CloseDate = Date.today();
        monthAccQuarterOpp.AccountId = monthAccount.Id;
        monthAccQuarterOpp.Purchase_Cadence_Override__c = 'Quarterly';
        oppsToInsert.add(monthAccQuarterOpp);

        Opportunity quarterAccSemiOpp = new Opportunity();
        quarterAccSemiOpp.Name = 'Has Opportunity Semi-Annually PCO';
        quarterAccSemiOpp.StageName = 'Qualification';
        quarterAccSemiOpp.CloseDate = Date.today();
        quarterAccSemiOpp.AccountId = quarterAccount.Id;
        quarterAccSemiOpp.Purchase_Cadence_Override__c = 'Semi-Annually';
        oppsToInsert.add(quarterAccSemiOpp);

        Opportunity semiAccAnnualOpp = new Opportunity();
        semiAccAnnualOpp.Name = 'Has Opportunity Annually PCO';
        semiAccAnnualOpp.StageName = 'Qualification';
        semiAccAnnualOpp.CloseDate = Date.today();
        semiAccAnnualOpp.AccountId = semiAccount.Id;
        semiAccAnnualOpp.Purchase_Cadence_Override__c = 'Annually';
        oppsToInsert.add(semiAccAnnualOpp);

        Opportunity annualAccMonthlyOpp = new Opportunity();
        annualAccMonthlyOpp.Name = 'Has Opportunity Monthly PCO';
        annualAccMonthlyOpp.StageName = 'Qualification';
        annualAccMonthlyOpp.CloseDate = Date.today();
        annualAccMonthlyOpp.AccountId = annualAccount.Id;
        annualAccMonthlyOpp.Purchase_Cadence_Override__c = 'Monthly';
        oppsToInsert.add(annualAccMonthlyOpp);

        if (!oppsToInsert.isEmpty()){
            insert oppsToInsert;
        }
        
        //Creating a Quote related to both SObjects above (Used in SetAddresses and UpdateRelatedOpp)
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote.SBQQ__Account__c = testAccount.Id;
        testQuote.SBQQ__Opportunity2__c = testOpp.Id;
        testQuote.SBQQ__Primary__c = true;
        insert testQuote;

        //Creating 8 Quotes to be paired with each Opportunity above
        //Giving each a set Subscription Term and Non Draft Status
        List<SBQQ__Quote__c> quotesToInsert = new List<SBQQ__Quote__c>();

        //Monthly Account PC 
        SBQQ__Quote__c monthAccQuote = new SBQQ__Quote__c();
        monthAccQuote.SBQQ__Account__c = monthAccount.Id;
        monthAccQuote.SBQQ__Opportunity2__c = monthAccOpp.Id;
        monthAccQuote.SBQQ__SubscriptionTerm__c = 10;
        monthAccQuote.SBQQ__Status__c = 'In Review';
        quotesToInsert.add(monthAccQuote);
        
        //Quarterly Account PC 
        SBQQ__Quote__c quarterAccQuote = new SBQQ__Quote__c();
        quarterAccQuote.SBQQ__Account__c = quarterAccount.Id;
        quarterAccQuote.SBQQ__Opportunity2__c = quarterAccOpp.Id;
        quarterAccQuote.SBQQ__SubscriptionTerm__c = 10;
        quarterAccQuote.SBQQ__Status__c = 'In Review';
        quotesToInsert.add(quarterAccQuote);
        
        //Semi Annually Account PC 
        SBQQ__Quote__c semiAccQuote = new SBQQ__Quote__c();
        semiAccQuote.SBQQ__Account__c = semiAccount.Id;
        semiAccQuote.SBQQ__Opportunity2__c = semiAccOpp.Id;
        semiAccQuote.SBQQ__SubscriptionTerm__c = 10;
        semiAccQuote.SBQQ__Status__c = 'In Review';
        quotesToInsert.add(semiAccQuote);

        //Annually Account PC
        SBQQ__Quote__c annualAccQuote = new SBQQ__Quote__c();
        annualAccQuote.SBQQ__Account__c = annualAccount.Id;
        annualAccQuote.SBQQ__Opportunity2__c = annualAccOpp.Id;
        annualAccQuote.SBQQ__SubscriptionTerm__c = 10;
        annualAccQuote.SBQQ__Status__c = 'In Review';
        quotesToInsert.add(annualAccQuote);

        //Monthly Account PC and Quarterly Opportunity PCO 
        SBQQ__Quote__c quarterOppQuote = new SBQQ__Quote__c();
        quarterOppQuote.SBQQ__Account__c = monthAccount.Id;
        quarterOppQuote.SBQQ__Opportunity2__c = monthAccQuarterOpp.Id;
        quarterOppQuote.SBQQ__SubscriptionTerm__c = 10;
        quarterOppQuote.SBQQ__Status__c = 'In Review';
        quotesToInsert.add(quarterOppQuote);
        
        //Quarterly Account PC and Semi-Annually Opportunity PCO 
        SBQQ__Quote__c semiOppQuote = new SBQQ__Quote__c();
        semiOppQuote.SBQQ__Account__c = quarterAccount.Id;
        semiOppQuote.SBQQ__Opportunity2__c = quarterAccSemiOpp.Id;
        semiOppQuote.SBQQ__SubscriptionTerm__c = 10;
        semiOppQuote.SBQQ__Status__c = 'In Review';
        quotesToInsert.add(semiOppQuote);
        
        //Semi Annually Account PC and Annually Opportunity PCO 
        SBQQ__Quote__c annualOppQuote = new SBQQ__Quote__c();
        annualOppQuote.SBQQ__Account__c = semiAccount.Id;
        annualOppQuote.SBQQ__Opportunity2__c = semiAccAnnualOpp.Id;
        annualOppQuote.SBQQ__SubscriptionTerm__c = 10;
        annualOppQuote.SBQQ__Status__c = 'In Review';
        quotesToInsert.add(annualOppQuote);

        //Annually Account PC and Monthly Opportunity PCO
        SBQQ__Quote__c monthlyOppQuote = new SBQQ__Quote__c();
        monthlyOppQuote.SBQQ__Account__c = annualAccount.Id;
        monthlyOppQuote.SBQQ__Opportunity2__c = annualAccMonthlyOpp.Id;
        monthlyOppQuote.SBQQ__SubscriptionTerm__c = 10;
        monthlyOppQuote.SBQQ__Status__c = 'In Review';
        quotesToInsert.add(monthlyOppQuote);

        if (!quotesToInsert.isEmpty()) {
            insert quotesToInsert;
        } 
    }

    //BEFORE INSERT: When a Quote is created the addresses should match related Opportunity Addresses
    @isTest
    static void setAddressesTest() {
        
        System.debug('Start of Test Method SetAddresses');

        //Querying back the related Opportunity and Quote
        Opportunity testOpp = [
            SELECT Id, BillingCity__c, BillingCountry__c,
            BillingPostalCode__c, BillingState__c, BillingStreet__c, CloseDate,
            ShippingCity__c, ShippingCountry__c, ShippingPostalCode__c,
            ShippingState__c, ShippingStreet__c, StageName, Account.Type
            FROM Opportunity
            WHERE Name = 'Test Opportunity'
            LIMIT 1
        ];
        SBQQ__Quote__c newQuote = [
            SELECT Id, SBQQ__BillingCity__c, SBQQ__BillingCountry__c,
            SBQQ__BillingPostalCode__c, SBQQ__BillingState__c, SBQQ__BillingStreet__c,
            SBQQ__ShippingCity__c, SBQQ__ShippingCountry__c, SBQQ__ShippingPostalCode__c,
            SBQQ__ShippingState__c, SBQQ__ShippingStreet__c
            FROM SBQQ__Quote__c
            LIMIT 1
        ];

        //Asserting that each Quote address field is matching the related Opportunity's
        System.assertEquals(
            testOpp.BillingStreet__c, 
            newQuote.SBQQ__BillingStreet__c, 
            'Billing Street for Quote not updating to Opportunity\'s Billing Street'
        );
        System.assertEquals(
            testOpp.BillingCountry__c, 
            newQuote.SBQQ__BillingCountry__c, 
            'Billing Country for Quote not updating to Opportunity\'s Billing Country'
        );
        System.assertEquals(
            testOpp.BillingPostalCode__c, 
            newQuote.SBQQ__BillingPostalCode__c, 
            'Billing PostalCode for Quote not updating to Opportunity\'s Billing PostalCode'
        );
        System.assertEquals(
            testOpp.BillingState__c, 
            newQuote.SBQQ__BillingState__c, 
            'Billing State for Quote not updating to Opportunity\'s Billing State'
        );
        System.assertEquals(
            testOpp.BillingCity__c, 
            newQuote.SBQQ__BillingCity__c, 
            'Billing City for Quote not updating to Opportunity\'s Billing City'
        );
        System.assertEquals(
            testOpp.ShippingStreet__c, 
            newQuote.SBQQ__ShippingStreet__c, 
            'Shipping Street for Quote not updating to Opportunity\'s Shipping Street'
        );
        System.assertEquals(
            testOpp.ShippingCountry__c, 
            newQuote.SBQQ__ShippingCountry__c, 
            'Shipping Country for Quote not updating to Opportunity\'s Shipping Country'
        );
        System.assertEquals(
            testOpp.ShippingPostalCode__c, 
            newQuote.SBQQ__ShippingPostalCode__c, 
            'Shipping PostalCode for Quote not updating to Opportunity\'s Shipping PostalCode'
        );
        System.assertEquals(
            testOpp.ShippingState__c, 
            newQuote.SBQQ__ShippingState__c, 
            'Shipping State for Quote not updating to Opportunity\'s Shipping State'
        );
        System.assertEquals(
            testOpp.ShippingCity__c, 
            newQuote.SBQQ__ShippingCity__c, 
            'Shipping City for Quote not updating to Opportunity\'s Shipping City'
        );
       
        System.debug('Test Passed');
        System.debug('End of Test Method SetAddresses');
    }

    //AFTER UPDATE: When a a Primary Quote has their addresses updated, update the related Opportunity's address as well
    @isTest
    static void updateRelatedOppTest() {

        System.debug('Start of Test Method UpdateRelatedOpp');

        //Query back Quote from Setup
        SBQQ__Quote__c primaryQuote = [
            SELECT Id, SBQQ__BillingCity__c, SBQQ__BillingCountry__c,
            SBQQ__BillingPostalCode__c, SBQQ__BillingState__c, SBQQ__BillingStreet__c,
            SBQQ__ShippingCity__c, SBQQ__ShippingCountry__c, SBQQ__ShippingPostalCode__c,
            SBQQ__ShippingState__c, SBQQ__ShippingStreet__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Primary__c = true
            LIMIT 1
        ];

        //Updating the primary quote's address fields
        primaryQuote.SBQQ__BillingCity__c = 'Samhla'; 
        primaryQuote.SBQQ__BillingCountry__c = 'UK';
        primaryQuote.SBQQ__BillingPostalCode__c = 'HS6 4ZN'; 
        primaryQuote.SBQQ__BillingState__c = null; 
        primaryQuote.SBQQ__BillingStreet__c = '28 Wade Lane';
        primaryQuote.SBQQ__ShippingCity__c = 'Samhla'; 
        primaryQuote.SBQQ__ShippingCountry__c = 'UK'; 
        primaryQuote.SBQQ__ShippingPostalCode__c = 'HS6 4ZN';
        primaryQuote.SBQQ__ShippingState__c = null; 
        primaryQuote.SBQQ__ShippingStreet__c = '28 Wade Lane';
        update primaryQuote;

        //Querying back the related Opportunity and Quote
        Opportunity relatedOpp = [
            SELECT Id, BillingCity__c, BillingCountry__c,
            BillingPostalCode__c, BillingState__c, BillingStreet__c, CloseDate,
            ShippingCity__c, ShippingCountry__c, ShippingPostalCode__c,
            ShippingState__c, ShippingStreet__c, StageName, Account.Type
            FROM Opportunity
            WHERE Name = 'Test Opportunity'
            LIMIT 1
        ];
        
        //Asserting that each related Opportunity address field is matching the primary Quote's
        //Don't have to test for every type of scenario
        System.assertEquals(
            primaryQuote.SBQQ__BillingStreet__c,
            relatedOpp.BillingStreet__c, 
            'Billing Street for Opportunity not updating to Primary Quote\'s Billing Street'
        );
        System.assertEquals(
            primaryQuote.SBQQ__BillingCountry__c,
            relatedOpp.BillingCountry__c, 
            'Billing Country for Opportunity not updating to Primary Quote\'s Billing Country'
        );
        System.assertEquals(
            primaryQuote.SBQQ__BillingPostalCode__c,
            relatedOpp.BillingPostalCode__c, 
            'Billing PostalCode for Opportunity not updating to Primary Quote\'s Billing PostalCode'
        );
        System.assertEquals(
            primaryQuote.SBQQ__BillingState__c,
            relatedOpp.BillingState__c, 
            'Billing State for Opportunity not updating to Primary Quote\'s Billing State'
        );
        System.assertEquals(
            primaryQuote.SBQQ__BillingCity__c,
            relatedOpp.BillingCity__c, 
            'Billing City for Opportunity not updating to Primary Quote\'s Billing City'
        );
        System.assertEquals(
            primaryQuote.SBQQ__ShippingStreet__c,
            relatedOpp.ShippingStreet__c, 
            'Shipping Street for Opportunity not updating to Primary Quote\'s Shipping Street'
        );
        System.assertEquals(
            primaryQuote.SBQQ__ShippingCountry__c, 
            relatedOpp.ShippingCountry__c,
            'Shipping Country for Opportunity not updating to Primary Quote\'s Shipping Country'
        );
        System.assertEquals(             
            primaryQuote.SBQQ__ShippingPostalCode__c,
            relatedOpp.ShippingPostalCode__c, 
            'Shipping PostalCode for Opportunity not updating to Primary Quote\'s Shipping PostalCode'
        );
        System.assertEquals( 
            primaryQuote.SBQQ__ShippingState__c,
            relatedOpp.ShippingState__c, 
            'Shipping State for Opportunity not updating to Primary Quote\'s Shipping State'
        );
        System.assertEquals(
            primaryQuote.SBQQ__ShippingCity__c,
            relatedOpp.ShippingCity__c, 
            'Shipping City for Opportunity not updating to Primary Quote\'s Shipping City'
        );
       
        System.debug('Test Passed');
        System.debug('End of Test Method UpdateRelatedOpp');

    }
    
    //BEFORE INSERT: When Quotes are created, their Subscription terms should reflect their Account Purchase Cadence
    //Monthly = 1, Quarterly = 3, Semi-Annually = 6, Annually = 12
    @isTest
    static void setSubscriptionTest() {

        System.debug('Start of Test Method SetSubscription');

        //Querying back each Quote's created in Setup, Account's have Purchase Cadences 
        //Opportunities have no Purchase Cadence Override
        SBQQ__Quote__c monthAccQuote = [
            SELECT Id, SBQQ__SubscriptionTerm__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Name = 'Has Account Monthly PC'
            LIMIT 1
        ];
        SBQQ__Quote__c quarterAccQuote = [
            SELECT Id, SBQQ__SubscriptionTerm__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Name = 'Has Account Quarterly PC'
            LIMIT 1
        ];
        SBQQ__Quote__c semiAccQuote = [
            SELECT Id, SBQQ__SubscriptionTerm__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Name = 'Has Account Semi-Annually PC'
            LIMIT 1
        ];
        SBQQ__Quote__c annualAccQuote = [
            SELECT Id, SBQQ__SubscriptionTerm__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Name = 'Has Account Annually PC'
            LIMIT 1
        ];

        //Making sure Quote Subscription terms update to reflect Account Purchase Cadence
        System.assertEquals(
                1, 
                monthAccQuote.SBQQ__SubscriptionTerm__c, 
                'Subscription term not updated to match Quarterly Account Purchase Cadence'
            );
        System.assertEquals(
                3, 
                quarterAccQuote.SBQQ__SubscriptionTerm__c, 
                'Subscription term not updated to match Semi-Annually Account Purchase Cadence'
            );
        System.assertEquals(
                6, 
                semiAccQuote.SBQQ__SubscriptionTerm__c, 
                'Subscription term not updated to match Annually Account Purchase Cadence'
            );
        System.assertEquals(
                12, 
                annualAccQuote.SBQQ__SubscriptionTerm__c, 
                'Subscription term not updated to match Monthly Account Purchase Cadence'
            );

        System.debug('Test Passed');
        System.debug('End of Test Method SetSubscription');
    }

    //BEFORE UPDATE: When Quotes have their status changed to Draft, make sure the Subscription Terms reflect 
    //the Purchase Cadence or Purchase Cadence Override if there is one
    @isTest
    static void syncSubscriptionTest() {
        
        System.debug('Start of Test Method SyncSubscription');

        //Creating a list of Quotes we need to update to Draft Status
        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> quotesInReview = [
            SELECT Id, SBQQ__SubscriptionTerm__c, SBQQ__Status__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Status__c = 'In Review'
        ];
       
        for (SBQQ__Quote__c quote : quotesInReview) {
            quote.SBQQ__Status__c = 'Draft';
            quotesToUpdate.add(quote);
        }

        update quotesToUpdate;

        //Querying back each Quote's updated Subscription Terms (instead of SOQL query, can use a for loop to assign quotes)
        SBQQ__Quote__c monthAccQuote = [
            SELECT Id, SBQQ__SubscriptionTerm__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Name = 'Has Account Monthly PC'
            LIMIT 1
        ];
        SBQQ__Quote__c quarterAccQuote = [
            SELECT Id, SBQQ__SubscriptionTerm__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Name = 'Has Account Quarterly PC'
            LIMIT 1
        ];
        SBQQ__Quote__c semiAccQuote = [
            SELECT Id, SBQQ__SubscriptionTerm__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Name = 'Has Account Semi-Annually PC'
            LIMIT 1
        ];
        SBQQ__Quote__c annualAccQuote = [
            SELECT Id, SBQQ__SubscriptionTerm__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Name = 'Has Account Annually PC'
            LIMIT 1
        ];
        SBQQ__Quote__c quarterOppQuote = [
            SELECT Id, SBQQ__SubscriptionTerm__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Name = 'Has Opportunity Quarterly PCO'
            LIMIT 1
        ];
        SBQQ__Quote__c semiOppQuote = [
            SELECT Id, SBQQ__SubscriptionTerm__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Name = 'Has Opportunity Semi-Annually PCO'
            LIMIT 1
        ];
        SBQQ__Quote__c annualOppQuote = [
            SELECT Id, SBQQ__SubscriptionTerm__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Name = 'Has Opportunity Annually PCO'
            LIMIT 1
        ];
        SBQQ__Quote__c monthlyOppQuote = [
            SELECT Id, SBQQ__SubscriptionTerm__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Name = 'Has Opportunity Monthly PCO'
            LIMIT 1
        ];

        //Making sure Quotes updated to Draft have their Subscription terms update 
        //to reflect Account Purchase Cadence
        //Or Opportunity Purchase Cadence Override if there is one
        System.assertEquals(
                1, 
                monthAccQuote.SBQQ__SubscriptionTerm__c, 
                'Subscription term not updated to match Monthly Account Purchase Cadence'
            );
        System.assertEquals(
                3, 
                quarterAccQuote.SBQQ__SubscriptionTerm__c, 
                'Subscription term not updated to match Quarterly Account Purchase Cadence'
            );
        System.assertEquals(
                6, 
                semiAccQuote.SBQQ__SubscriptionTerm__c, 
                'Subscription term not updated to match Semi-Annually Account Purchase Cadence'
            );
        System.assertEquals(
                12, 
                annualAccQuote.SBQQ__SubscriptionTerm__c, 
                'Subscription term not updated to match Annually Account Purchase Cadence'
            );
        System.assertEquals(
                3, 
                quarterOppQuote.SBQQ__SubscriptionTerm__c, 
                'Subscription term not updated to match Quarterly Opportunity Purchase Cadence Override'
            );
        System.assertEquals(
                6, 
                semiOppQuote.SBQQ__SubscriptionTerm__c, 
                'Subscription term not updated to match Semi-Annually Opportunity Purchase Cadence Override'
            );
        System.assertEquals(
                12, 
                annualOppQuote.SBQQ__SubscriptionTerm__c, 
                'Subscription term not updated to match Annually Opportunity Purchase Cadence Override'
            );
        System.assertEquals(
                1, 
                monthlyOppQuote.SBQQ__SubscriptionTerm__c, 
                'Subscription term not updated to match Monthly Opportunity Purchase Cadence Override'
            );    
        System.debug('Test Passed');
        System.debug('End of Test Method SyncSubscription');
    }
}