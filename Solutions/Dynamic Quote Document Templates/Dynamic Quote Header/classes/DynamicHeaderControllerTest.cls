@IsTest
public with sharing class DynamicHeaderControllerTest {
    @TestSetup
    static void makeData() {

        // Insert Products
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.Name = 'Test Prod 1';
        prod1.IsActive = true;
        prod1.SBQQ__DefaultQuantity__c = 1;
        prod1.ProductCode = '1234567891234'; 
        prod1.Description = 'Testing Products';
        prodList.add(prod1);

        Product2 prod2 = new Product2();
        prod2.Name = 'Test Prod 2';
        prod2.IsActive = true;
        prod2.SBQQ__DefaultQuantity__c = 1;
        prod2.ProductCode = '1234567574896'; 
        prod2.Description = 'Testing Products';
        prodList.add(prod2);

        insert prodList;
        System.debug('Products Inserted - ' + prodList);

        // Setting up a test PriceBook 
        Pricebook2 testPriceBook = new Pricebook2();
        testPriceBook.Id = Test.getStandardPricebookId();
        testPriceBook.IsActive = true;
        update testPriceBook;
        System.debug('Pricebook setup - ' + testPricebook);

        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        for (Product2 prod : prodList) {
            // Standard pricebook
            PricebookEntry pbe = new PricebookEntry();
            pbe.Product2Id = prod.Id;
            pbe.Pricebook2Id = testPriceBook.Id;
            pbe.UnitPrice = 17.50;
            pbe.IsActive = true;
            pbeList.add(pbe);
        }

        insert pbeList;
        System.debug('Pricebook Entries Inserted - ' + pbeList);

        // Create Test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            CloseDate = Date.Today(),
            StageName = 'Needs Analysis'
        );
        insert opp;
        System.debug('Opportunity Inserted - ' + opp);

        // Create test QuoteTemplate
        SBQQ__QuoteTemplate__c template = new SBQQ__QuoteTemplate__c(
            SBQQ__BottomMargin__c = 1,
            SBQQ__LeftMargin__c = 1,
            SBQQ__RightMargin__c = 1,
            SBQQ__TopMargin__c = 1,
            SBQQ__FontFamily__c = 'Arial',
            SBQQ__FontSize__c = 12,
            SBQQ__ShadingColor__c = 'FFFFFF',
            SBQQ__CompanyName__c = 'Test Company', 
            SBQQ__CompanyPhone__c = '8880001234'
        );
        insert template;
        System.debug('Quote Template Inserted - ' + template);

        // Create test Quotes 
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__PriceBookId__c = testPriceBook.Id;
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.SBQQ__StartDate__c = Date.Today(); 
        quote.SBQQ__SubscriptionTerm__c = 12;
        quote.SBQQ__Status__c = 'Draft';
        quote.SBQQ__ShippingStreet__c = '123 Test St.';
        
        insert quote;
        System.debug('Quote Inserted - ' + quote);

    }

    @isTest
    static void testDynamicHeaderController() { 
        
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        SBQQ__QuoteTemplate__c template = [SELECT Id FROM SBQQ__QuoteTemplate__c LIMIT 1];

        // Set test page parameters
        Test.setCurrentPageReference(new PageReference('/apex/DynamicHeaderPage'));
        ApexPages.currentPage().getParameters().put('qid', quote.Id);
        ApexPages.currentPage().getParameters().put('tid', template.Id);

        // Instantiate the controller
        DynamicHeaderController controller = new DynamicHeaderController();

        // Test that the template is populated correctly
        System.assertNotEquals(null, controller.template);
        System.assertEquals('Arial', controller.template.SBQQ__FontFamily__c);

        // Test that the boolean fields are updated properly
        System.assert(controller.showOpportunity == true);
        System.assert(controller.showShipping == true);
        
    }

}