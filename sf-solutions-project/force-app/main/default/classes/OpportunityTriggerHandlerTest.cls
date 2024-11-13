//Section 2 checkpoint class 2
@isTest
public with sharing class OpportunityTriggerHandlerTest {
    
    //Making sure we have Accounts with Billing and Shipping Addresses filled
    @TestSetup
    static void setup() {

        //Creating a Prospect Account (used in SetDefaults)
        List<Account> accsToInsert = new List<Account>();

        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.Type = 'Prospect';
        testAccount.BillingStreet = '123 Street';
        testAccount.BillingCity = 'Tampa';
        testAccount.BillingCountry = 'USA';
        testAccount.BillingState = 'FL';
        testAccount.BillingPostalCode = '33333';
        testAccount.ShippingStreet = '123 Street';
        testAccount.ShippingCity = 'Tampa';
        testAccount.ShippingCountry = 'USA';
        testAccount.ShippingState = 'FL';
        testAccount.ShippingPostalCode = '33333';
        accsToInsert.add(testAccount);

        //Creating a Non-Prospect Account (used in SetDefaults)
        Account testAccount2 = new Account();
        testAccount2.Name = 'Test Account 2';
        testAccount2.Type = 'Customer - Direct';
        testAccount2.BillingStreet = '345 Street';
        testAccount2.BillingCity = 'Ft. Myers';
        testAccount2.BillingCountry = 'USA';
        testAccount2.BillingState = 'FL';
        testAccount2.BillingPostalCode = '66666';
        testAccount2.ShippingStreet = '345 Street';
        testAccount2.ShippingCity = 'Ft. Myers';
        testAccount2.ShippingCountry = 'USA';
        testAccount2.ShippingState = 'FL';
        testAccount2.ShippingPostalCode = '66666';
        accsToInsert.add(testAccount2);

        //Monthly Cadence to be paired with Opportunity (used in CadenceOverride)
        Account accForOpp = new Account();
        accForOpp.Name = 'Paired with Opportunity';
        accForOpp.Purchase_Cadence__c = 'Monthly';
        accsToInsert.add(accForOpp);

        //Each Account has a specific cadence value (used in CadenceOverride)
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

        insert accsToInsert;
       
        List<Opportunity> oppsToInsert = new List<Opportunity>();

        //Test Opportunity, No Related Account (used in Sync Addresses)
        Opportunity testOpp = new Opportunity();
        testOpp.Name = 'Test Opportunity';
        testOpp.CloseDate = Date.today().addDays(30);
        testOpp.StageName = 'Qualification';
        testOpp.Purchase_Cadence_Override__c = 'Monthly';
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
        oppsToInsert.add(testOpp);
        

        //Next 4 Opportunities have no PCO and are related to each Account with PCs (used in CadenceOverride)
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
        
        insert oppsToInsert;

        List<SBQQ__Quote__c> quotesToInsert = new List<SBQQ__Quote__c>();
        
        //Each Draft Quote will have an Account Associated with them with a specific Purchcase Cadence, 
        //No Opportunity PCO (used in CadenceOverride)
        //Monthly PC
        SBQQ__Quote__c monthAccQuote = new SBQQ__Quote__c();
        monthAccQuote.SBQQ__Account__c = monthAccount.Id;
        monthAccQuote.SBQQ__Opportunity2__c = monthAccOpp.Id;
        monthAccQuote.SBQQ__Status__c = 'Draft';
        quotesToInsert.add(monthAccQuote);
        
        //Quarterly PC
        SBQQ__Quote__c quarterAccQuote = new SBQQ__Quote__c();
        quarterAccQuote.SBQQ__Account__c = quarterAccount.Id;
        quarterAccQuote.SBQQ__Opportunity2__c = quarterAccOpp.Id;
        quarterAccQuote.SBQQ__Status__c = 'Draft';
        quotesToInsert.add(quarterAccQuote);
        
        //Semi Annually PC
        SBQQ__Quote__c semiAccQuote = new SBQQ__Quote__c();
        semiAccQuote.SBQQ__Account__c = semiAccount.Id;
        semiAccQuote.SBQQ__Opportunity2__c = semiAccOpp.Id;
        semiAccQuote.SBQQ__Status__c = 'Draft';
        quotesToInsert.add(semiAccQuote);

        //Annually PC
        SBQQ__Quote__c annualAccQuote = new SBQQ__Quote__c();
        annualAccQuote.SBQQ__Account__c = annualAccount.Id;
        annualAccQuote.SBQQ__Opportunity2__c = annualAccOpp.Id;
        annualAccQuote.SBQQ__Status__c = 'Draft';
        quotesToInsert.add(annualAccQuote);

        insert quotesToInsert;

    }

    //BEFORE INSERT: Testing that Opportunities have their StageName, CloseDate, Billing and Shipping Addresses 
    //Filled in when created
    @isTest
    static void setDefaultsTest() {
        System.debug('Start Test Method SetDefaults');

        //Querying our Accounts from Setup
        Account prospectAccount = [      
            SELECT Id, Type, BillingCity, BillingCountry, BillingState,
            BillingStreet, BillingPostalCode, ShippingCity, ShippingCountry,
            ShippingState, ShippingStreet, ShippingPostalCode
            FROM Account 
            WHERE Name = 'Test Account'
            LIMIT 1
        ];
        Account cusDirAccount = [      
            SELECT Id, Type, BillingCity, BillingCountry, BillingState,
            BillingStreet, BillingPostalCode, ShippingCity, ShippingCountry,
            ShippingState, ShippingStreet, ShippingPostalCode
            FROM Account 
            WHERE Name = 'Test Account 2'
            LIMIT 1
        ];

        List<Opportunity> oppsToInsert = new List<Opportunity>();

        //Opportunity with no related Account
        Opportunity soloOpp = new Opportunity();
        soloOpp.Name = 'No Related Account';
        soloOpp.CloseDate = Date.today().addDays(3);
        soloOpp.StageName = 'Qualification';
        oppsToInsert.add(soloOpp);

        //Opportunity with related Prospect Account
        Opportunity prospectAccOpp = new Opportunity();
        prospectAccOpp.Name = 'Has Prospect Account';
        prospectAccOpp.CloseDate = Date.today().addDays(3);
        prospectAccOpp.StageName = 'Value Proposition';
        prospectAccOpp.AccountId = prospectAccount.Id;
        oppsToInsert.add(prospectAccOpp);

        //Opportunity with related Non-Prospect Account
        Opportunity cusDirAccOpp = new Opportunity();
        cusDirAccOpp.Name = 'Has Customer Direct Account';
        cusDirAccOpp.CloseDate = Date.today().addDays(3);
        cusDirAccOpp.StageName = 'Value Proposition';
        cusDirAccOpp.AccountId = cusDirAccount.Id;
        oppsToInsert.add(cusDirAccOpp);
		        
        insert oppsToInsert;

        //Querying back the new Opportunities we created
        soloOpp = [
            SELECT Id, BillingCity__c, BillingCountry__c,
            BillingPostalCode__c, BillingState__c, BillingStreet__c, CloseDate,
            ShippingCity__c, ShippingCountry__c, ShippingPostalCode__c,
            ShippingState__c, ShippingStreet__c, StageName, Account.Type
            FROM Opportunity
            WHERE AccountId = null
            LIMIT 1
        ];
        
        prospectAccOpp = [
            SELECT Id, BillingCity__c, BillingCountry__c,
            BillingPostalCode__c, BillingState__c, BillingStreet__c, CloseDate,
            ShippingCity__c, ShippingCountry__c, ShippingPostalCode__c,
            ShippingState__c, ShippingStreet__c, StageName, Account.Type
            FROM Opportunity
            WHERE Name = 'Has Prospect Account'
            LIMIT 1
        ];

        cusDirAccOpp = [
            SELECT Id, BillingCity__c, BillingCountry__c,
            BillingPostalCode__c, BillingState__c, BillingStreet__c, CloseDate,
            ShippingCity__c, ShippingCountry__c, ShippingPostalCode__c,
            ShippingState__c, ShippingStreet__c, StageName, Account.Type
            FROM Opportunity
            WHERE Name = 'Has Customer Direct Account'
            LIMIT 1
        ];

        //Test 1: Testing that when Close Date is Less than 30 days from today 
        System.assertEquals(
            Date.today().addDays(30), 
            soloOpp.CloseDate, 
            'Close Date not updating to 30 days from today'
        );

        System.debug('Test 1 Passed');
        
        //Test 2: Testing that the StageName for each Opportunity is updated accordingly
        System.assertEquals(
            'Needs Analysis', 
            soloOpp.StageName, 
            'Stage Name for Opportunity with no Account not updating to Needs Analysis'
        );
        System.assertEquals(
            'Prospecting', 
            prospectAccOpp.StageName, 
            'Stage Name for Opportunity with related Prospect Account not updating to Prospecting'
        );
        System.assertEquals(
            'Qualification', 
            cusDirAccOpp.StageName, 
            'Stage Name for Opportunity with related Non-Prospect Account not updating to Qualification'
        );

        System.debug('Test 2 Passed');

        //Test 3: Testing that each Billing and Shipping Address is being updated
        System.assertEquals(
            prospectAccount.BillingStreet, 
            prospectAccOpp.BillingStreet__c, 
            'Billing Street for Opportunity not updating to Account\'s Billing Street'
        );
        System.assertEquals(
            prospectAccount.BillingCountry, 
            prospectAccOpp.BillingCountry__c, 
            'Billing Country for Opportunity not updating to Account\'s Billing Country'
        );
        System.assertEquals(
            prospectAccount.BillingPostalCode, 
            prospectAccOpp.BillingPostalCode__c, 
            'Billing PostalCode for Opportunity not updating to Account\'s Billing PostalCode'
        );
        System.assertEquals(
            prospectAccount.BillingState, 
            prospectAccOpp.BillingState__c, 
            'Billing State for Opportunity not updating to Account\'s Billing State'
        );
        System.assertEquals(
            prospectAccount.BillingCity, 
            prospectAccOpp.BillingCity__c, 
            'Billing City for Opportunity not updating to Account\'s Billing City'
        );
        System.assertEquals(
            prospectAccount.ShippingStreet, 
            prospectAccOpp.ShippingStreet__c, 
            'Shipping Street for Opportunity not updating to Account\'s Shipping Street'
        );
        System.assertEquals(
            prospectAccount.ShippingCountry, 
            prospectAccOpp.ShippingCountry__c, 
            'Shipping Country for Opportunity not updating to Account\'s Shipping Country'
        );
        System.assertEquals(
            prospectAccount.ShippingPostalCode, 
            prospectAccOpp.ShippingPostalCode__c, 
            'Shipping PostalCode for Opportunity not updating to Account\'s Shipping PostalCode'
        );
        System.assertEquals(
            prospectAccount.ShippingState, 
            prospectAccOpp.ShippingState__c, 
            'Shipping State for Opportunity not updating to Account\'s Shipping State'
        );
        System.assertEquals(
            prospectAccount.ShippingCity, 
            prospectAccOpp.ShippingCity__c, 
            'Shipping City for Opportunity not updating to Account\'s Shipping City'
        );

        System.debug('Test 3 Passed');
        System.debug('End of Test Method SetDefaults');
       
    }

    //AFTER UPDATE: Testing that when the Opportunity addresses change the related Quote also changes
    @isTest
    static void syncAddresses() {
        System.debug('Start Test Method SyncAddresses');
        
        //Querying for Test Opportunity from Setup
        Opportunity testOpp = [
            SELECT Id, BillingCity__c, BillingCountry__c,
            BillingPostalCode__c, BillingState__c, BillingStreet__c,
            ShippingCity__c, ShippingCountry__c, ShippingPostalCode__c,
            ShippingState__c, ShippingStreet__c
            FROM Opportunity
            WHERE Name = 'Test Opportunity'
            LIMIT 1
        ];
        System.debug('Test Opp Before Update: ' + testOpp);

        //Creating a related Quote to the Opportunity and assuming it has the same addresses
        SBQQ__Quote__c relatedQuote = new SBQQ__Quote__c();
        relatedQuote.SBQQ__Status__c = 'Draft';
        relatedQuote.SBQQ__Opportunity2__c = testOpp.Id;
        relatedQuote.SBQQ__BillingCity__c = 'Ft. Myers'; 
        relatedQuote.SBQQ__BillingCountry__c = 'USA';
        relatedQuote.SBQQ__BillingPostalCode__c = '66666'; 
        relatedQuote.SBQQ__BillingState__c = 'FL'; 
        relatedQuote.SBQQ__BillingStreet__c = '345 Street';
        relatedQuote.SBQQ__ShippingCity__c = 'Ft. Myers'; 
        relatedQuote.SBQQ__ShippingCountry__c = 'USA'; 
        relatedQuote.SBQQ__ShippingPostalCode__c = '66666';
        relatedQuote.SBQQ__ShippingState__c = 'FL'; 
        relatedQuote.SBQQ__ShippingStreet__c = '345 Street';
        insert relatedQuote;
        System.debug('Test Opp After Insert: ' + relatedQuote);

        //Updating each address field in the Opportunity
        testOpp.BillingCity__c = 'Baton Rouge'; 
        testOpp.BillingCountry__c = 'CA';
        testOpp.BillingPostalCode__c = '22222'; 
        testOpp.BillingState__c = 'LA'; 
        testOpp.BillingStreet__c = '345 Blvd';
        testOpp.ShippingCity__c = 'Baton Rouge'; 
        testOpp.ShippingCountry__c = 'CA'; 
        testOpp.ShippingPostalCode__c = '22222';
        testOpp.ShippingState__c = 'LA'; 
        testOpp.ShippingStreet__c = '345 Blvd';
        update testOpp;
        System.debug('Test Opp After Update: ' + testOpp);

        //Re-querying the related quote after update
        relatedQuote = [
            SELECT Id, SBQQ__BillingCity__c, SBQQ__BillingCountry__c,
            SBQQ__BillingPostalCode__c, SBQQ__BillingState__c, SBQQ__BillingStreet__c,
            SBQQ__ShippingCity__c, SBQQ__ShippingCountry__c, SBQQ__ShippingPostalCode__c,
            SBQQ__ShippingState__c, SBQQ__ShippingStreet__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__c = :testOpp.Id
            LIMIT 1
        ];

        //Making sure that each Quote Addresses updates to the New Opportunity Addresses
        System.assertEquals(
            testOpp.BillingStreet__c, 
            relatedQuote.SBQQ__BillingStreet__c, 
            'Billing Street for Quote not updating to Opportunity\'s Billing Street'
        );
        System.assertEquals(
            testOpp.BillingCountry__c, 
            relatedQuote.SBQQ__BillingCountry__c, 
            'Billing Country for Quote not updating to Opportunity\'s Billing Country'
        );
        System.assertEquals(
            testOpp.BillingPostalCode__c, 
            relatedQuote.SBQQ__BillingPostalCode__c, 
            'Billing PostalCode for Quote not updating to Opportunity\'s Billing PostalCode'
        );
        System.assertEquals(
            testOpp.BillingState__c, 
            relatedQuote.SBQQ__BillingState__c, 
            'Billing State for Quote not updating to Opportunity\'s Billing State'
        );
        System.assertEquals(
            testOpp.BillingCity__c, 
            relatedQuote.SBQQ__BillingCity__c, 
            'Billing City for Quote not updating to Opportunity\'s Billing City'
        );
        System.assertEquals(
            testOpp.ShippingStreet__c, 
            relatedQuote.SBQQ__ShippingStreet__c, 
            'Shipping Street for Quote not updating to Opportunity\'s Shipping Street'
        );
        System.assertEquals(
            testOpp.ShippingCountry__c, 
            relatedQuote.SBQQ__ShippingCountry__c, 
            'Shipping Country for Quote not updating to Opportunity\'s Shipping Country'
        );
        System.assertEquals(
            testOpp.ShippingPostalCode__c, 
            relatedQuote.SBQQ__ShippingPostalCode__c, 
            'Shipping PostalCode for Quote not updating to Opportunity\'s Shipping PostalCode'
        );
        System.assertEquals(
            testOpp.ShippingState__c, 
            relatedQuote.SBQQ__ShippingState__c, 
            'Shipping State for Quote not updating to Opportunity\'s Shipping State'
        );
        System.assertEquals(
            testOpp.ShippingCity__c, 
            relatedQuote.SBQQ__ShippingCity__c, 
            'Shipping City for Quote not updating to Opportunity\'s Shipping City'
        );
        System.debug('Test Passed');
        System.debug('End of Test Method SyncAddresses');
    }

    //AFTER UPDATE: when Opportunities have their Purchase Cadence Override updated
    //Subscription Term should change based on the Purchase Cadence Override
    @isTest
    private static void cadenceOverrideTest() {
        
        System.debug('Start Test Method CadenceOverride');
        
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
        //Query back Opportunities with No Purchase Cadence Overrides created in Setup
        List<Opportunity> oppsNoPCO = [
            SELECT Id, Name, Purchase_Cadence_Override__c
            FROM Opportunity
            WHERE Purchase_Cadence_Override__c = null
        ];

        for (Opportunity opp : oppsNoPCO) {

            //Filtering through each opp and making sure each one has a different Purchase Cadence Override
            if (opp.Name == 'Has Account Monthly PC') {
                opp.Purchase_Cadence_Override__c = 'Quarterly';

            } else if (opp.Name == 'Has Account Quarterly PC') {
                opp.Purchase_Cadence_Override__c = 'Semi-Annually';

            } else if (opp.Name == 'Has Account Semi-Annually PC') {
                opp.Purchase_Cadence_Override__c = 'Annually';
                
            } else if (opp.Name == 'Has Account Annually PC') {
                opp.Purchase_Cadence_Override__c = 'Monthly';
                
            }

            oppsToUpdate.add(opp);
        }

        //Updating each Opportunity's PCO
        update oppsToUpdate;

        //Querying the quotes created in Setup with updated Subscription Terms
        SBQQ__Quote__c quarterOppQuote = [
            SELECT Id, SBQQ__SubscriptionTerm__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Name = 'Has Account Monthly PC'
            LIMIT 1
        ];
        SBQQ__Quote__c semiOppQuote = [
            SELECT Id, SBQQ__SubscriptionTerm__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Name = 'Has Account Quarterly PC'
            LIMIT 1
        ];
        SBQQ__Quote__c annualOppQuote = [
            SELECT Id, SBQQ__SubscriptionTerm__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Name = 'Has Account Semi-Annually PC'
            LIMIT 1
        ];
        SBQQ__Quote__c monthlyOppQuote = [
            SELECT Id, SBQQ__SubscriptionTerm__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__r.Name = 'Has Account Annually PC'
            LIMIT 1
        ];

        System.assertEquals(
                3, 
                quarterOppQuote.SBQQ__SubscriptionTerm__c, 
                'Quote Subscription term not updated to match Quarterly Opportunity Purchase Cadence Override'
            );
        System.assertEquals(
                6, 
                semiOppQuote.SBQQ__SubscriptionTerm__c, 
                'Quote Subscription term not updated to match Semi-Annually Opportunity Purchase Cadence Override'
            );
        System.assertEquals(
                12, 
                annualOppQuote.SBQQ__SubscriptionTerm__c, 
                'Quote Subscription term not updated to match Annually Opportunity Purchase Cadence Override'
            );
        System.assertEquals(
                1, 
                monthlyOppQuote.SBQQ__SubscriptionTerm__c, 
                'Quote Subscription term not updated to match Monthly Opportunity Purchase Cadence Override'
            );
        
        System.debug('Test Passed');
        System.debug('End of Test Method CadenceOverride');
        System.debug('End of Opportunity Trigger Test');
    }   
}