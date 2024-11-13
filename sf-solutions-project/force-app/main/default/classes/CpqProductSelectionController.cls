public with sharing class CpqProductSelectionController {
    
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts() {
        // Query products you want to display
        return [SELECT Id, Name, Description FROM Product2];
    }

    @AuraEnabled
    public static void addSelectedProducts(List<String> selectedProductIds, Id recordId) {
        List<SBQQ__QuoteLine__c> qlsToInsert = new List<SBQQ__QuoteLine__c>();
        
        // Retrieve the quote record
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__PriceBook__c FROM SBQQ__Quote__c WHERE Id = :recordId];

        //List<Product2> selectedProducts = [SELECT Id, SBQQ__DefaultQuantity__c FROM Product2];
        Map<Id, Product2> selectedProductsMap = new Map<Id, Product2>([SELECT Id, Name, SBQQ__DefaultQuantity__c FROM Product2 LIMIT 50000]);
        
        List<PricebookEntry> selectedPbes = [
            SELECT Id, Product2Id, UnitPrice, ProductCode 
            FROM PricebookEntry 
            WHERE Id IN :selectedProductIds AND Pricebook2Id = :quote.SBQQ__PriceBook__c LIMIT 50000
            ];
        Map<Id, PricebookEntry> productToPbeMap = new Map<Id, PricebookEntry>();

        // Populate map 
        for (PricebookEntry pbe : selectedPbes) {
            productToPbeMap.put(pbe.Product2Id, pbe);
        }

        // Loop through selected product Ids
        for (String productId : selectedProductIds) {
            Product2 relatedProduct = selectedProductsMap.get(productId);
            PricebookEntry relatedPbe = productToPbeMap.get(productId);
            // Create a new Quote Line Item
            // May need to see what else needs to twin over to the Quote Line but here's a start
            SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
            ql.SBQQ__Quote__c = recordId;
            ql.SBQQ__Product__c = productId;
            // ql.SBQQ__ProductName__c = selectedProductsMap.get(productId).Name;
            ql.SBQQ__Quantity__c = relatedProduct.SBQQ__DefaultQuantity__c;
            ql.SBQQ__ListPrice__c = (relatedPbe != null) ? relatedPbe.UnitPrice : 0;

            qlsToInsert.add(ql);
        }
        
        // Insert the Quote Line Items
        if (!qlsToInsert.isEmpty()) {
            insert qlsToInsert;
        }
    }
}