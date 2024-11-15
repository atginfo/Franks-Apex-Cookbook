@IsTest
public with sharing class DynamicQuoteLineControllerTest {
    
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

        // Create test QuoteTemplate
        SBQQ__QuoteTemplate__c template = new SBQQ__QuoteTemplate__c(
            SBQQ__BottomMargin__c = 1,
            SBQQ__LeftMargin__c = 1,
            SBQQ__RightMargin__c = 1,
            SBQQ__TopMargin__c = 1,
            SBQQ__FontFamily__c = 'Arial',
            SBQQ__FontSize__c = 12,
            SBQQ__ShadingColor__c = 'FFFFFF'
        );
        insert template;
        System.debug('Quote Template Inserted - ' + template);

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        // Create test Quotes - 1 without quote line groups
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
        quote1.SBQQ__PriceBookId__c = testPriceBook.Id;
        quote1.SBQQ__StartDate__c = Date.Today(); 
        quote1.SBQQ__SubscriptionTerm__c = 12;
        quote1.SBQQ__Status__c = 'Draft';
        quoteList.add(quote1);

        // 1 with quote line groups
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c();
        quote2.SBQQ__PriceBookId__c = testPriceBook.Id;
        quote2.SBQQ__StartDate__c = Date.Today(); 
        quote2.SBQQ__SubscriptionTerm__c = 12;
        quote2.SBQQ__LineItemsGrouped__c = true;
        quote2.SBQQ__Status__c = 'In Review';
        quoteList.add(quote2);
        
        insert quoteList;
        System.debug('Quotes Inserted - ' + quoteList);

        List<SBQQ__QuoteLineGroup__c> qlgList = new List<SBQQ__QuoteLineGroup__c>();
        for(integer i = 1; i<3; i++) {
            SBQQ__QuoteLineGroup__c qlg = new SBQQ__QuoteLineGroup__c(
                Name = 'Group ' + i, 
                SBQQ__Number__c = i, 
                SBQQ__Quote__c = quote2.Id
            );
            qlgList.add(qlg);
        }
        insert qlgList;
        System.debug('QuoteLineGroups Inserted - ' + qlgList);

        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        for(PricebookEntry pbe : pbeList) {
            // Creating solo quote lines - No Additional Discounts
            SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c(
                SBQQ__Quote__c = quote1.Id,
                SBQQ__PricebookEntryId__c = pbe.Id,
                SBQQ__PricingMethod__c = 'List',
                SBQQ__StartDate__c = Date.today(),
                SBQQ__Quantity__c = 1,
                SBQQ__PriorQuantity__c = 0,
                SBQQ__RegularPrice__c = 100,
                SBQQ__NetPrice__c = 100,
                SBQQ__CustomerPrice__c = 80,
                SBQQ__Number__c = 1,
                SBQQ__ProrateMultiplier__c = 1,
                SBQQ__SubscriptionPricing__c = 'Fixed Price',
                SBQQ__SubscriptionScope__c = 'Quote',
                SBQQ__DefaultSubscriptionTerm__c = 1,
                SBQQ__Description__c = 'Test Product Description',
                SBQQ__ListPrice__c = 100
            );

            qlList.add(line);
            
            // Creating quote lines with groups - with additional discounts
            for (SBQQ__QuoteLineGroup__c qlg : qlgList) {
                SBQQ__QuoteLine__c groupLine = new SBQQ__QuoteLine__c(
                    SBQQ__Quote__c = quote2.Id,
                    SBQQ__PricebookEntryId__c = pbe.Id,
                    SBQQ__Group__c = qlg.Id,
                    SBQQ__PricingMethod__c = 'List',
                    SBQQ__StartDate__c = Date.today(),
                    SBQQ__Quantity__c = 1,
                    SBQQ__PriorQuantity__c = 0,
                    SBQQ__RegularPrice__c = 100,
                    SBQQ__NetPrice__c = 100,
                    SBQQ__CustomerPrice__c = 80,
                    SBQQ__Number__c = 1,
                    SBQQ__ProrateMultiplier__c = 1,
                    SBQQ__SubscriptionPricing__c = 'Fixed Price',
                    SBQQ__SubscriptionScope__c = 'Quote',
                    SBQQ__DefaultSubscriptionTerm__c = 1,
                    SBQQ__Description__c = 'Test Product Description',
                    SBQQ__AdditionalDiscountAmount__c = 20,
                    SBQQ__ListPrice__c = 100
                );
                qlList.add(groupLine);
            }
        }

        SBQQ.TriggerControl.disable();
        insert qlList;
        System.debug('Quote Lines Inserted - ' + qlList);
        System.debug('Quote Lines Total' + qlList.size());

    }



    @IsTest
    static void testDynamicQuoteLineController() {
        SBQQ__Quote__c quote = [SELECT Id, Name FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' LIMIT 1];
        SBQQ__QuoteTemplate__c template = [SELECT Id FROM SBQQ__QuoteTemplate__c LIMIT 1];

        // Quotes with no Quote Line Groups will use the Quote Number to group everything under it
        String quoteNumber = quote.Name;
        
        // Set test page parameters
        Test.setCurrentPageReference(new PageReference('/apex/DynamicQuoteLines'));
        ApexPages.currentPage().getParameters().put('qid', quote.Id);
        ApexPages.currentPage().getParameters().put('tid', template.Id);

         // Instantiate the controller
         DynamicQuoteLineController controller = new DynamicQuoteLineController();

         // Test that the template is populated correctly
         System.assertNotEquals(null, controller.template);
         System.assertEquals('Arial', controller.template.SBQQ__FontFamily__c);

         // Testing that the Net Total on line items were totaled up for the Quote
        System.assert(
            controller.groupToLineItemsMap.get(quoteNumber).netTotalSum > 0,
            'Free Amount Sum not totaled up correctly'
        );

        // Test that the controlling boolean fields are updated properly
        System.assert(controller.showDiscount == false, 'Additional Discount was detected on Quote, should be false');

    }

    @IsTest
    static void testDynamicQuoteLineCtrWithGroups() {

        SBQQ__Quote__c quote = [SELECT Id, Name FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'In Review' LIMIT 1];
        SBQQ__QuoteTemplate__c template = [SELECT Id FROM SBQQ__QuoteTemplate__c LIMIT 1];
        SBQQ__QuoteLine__c ql = [SELECT Id, SBQQ__Group__r.Name, SBQQ__Group__r.SBQQ__Number__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quote.Id LIMIT 1];

        // Quotes with Quote Line Groups will use a combination of Group Number + Name
        String groupName = ql.SBQQ__Group__r.SBQQ__Number__c + ' - ' + ql.SBQQ__Group__r.Name;
        System.debug(groupName);
        
        // Set test page parameters
        Test.setCurrentPageReference(new PageReference('/apex/DynamicQuoteLines'));
        ApexPages.currentPage().getParameters().put('qid', quote.Id);
        ApexPages.currentPage().getParameters().put('tid', template.Id);

         // Instantiate the controller
         DynamicQuoteLineController controller = new DynamicQuoteLineController();

         // Test that the template is populated correctly
         System.assertNotEquals(null, controller.template);
         System.assertEquals('Arial', controller.template.SBQQ__FontFamily__c);

         // Testing that the Net Total on line items were totaled up for the Quote
        System.assert(
            controller.groupToLineItemsMap.get(groupName).netTotalSum > 0,
            'Free Amount Sum not totaled up correctly'
        );

        // Test that the controlling boolean fields are updated properly
        System.assert(controller.showDiscount == true, 'Additional Discount was not detected on Quote, should be true');

    }
}