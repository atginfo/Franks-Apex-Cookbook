public with sharing class QuoteLineExportController {
    @AuraEnabled
    public static Map<String, String> generateQuoteLineCsv(Id quoteId) {

        // Query the Name from Quote to be used in File Name and Header Row
        SBQQ__Quote__c quote = [SELECT Id, Name FROM SBQQ__Quote__c WHERE Id = :quoteId LIMIT 1];

        // Query all Quote Lines related to Quote
        List<SBQQ__QuoteLine__c> quoteLines = [
            SELECT Name, SBQQ__ProductName__c, SBQQ__Quantity__c, SBQQ__PriceEditable__c, SBQQ__ListPrice__c, SBQQ__NetTotal__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__c = :quoteId
        ];
        
        // This build the first row to have the Quote's Name. Each \n is a new row break
        String csvContent = 'Quote Name: ' + quote.Name + '\n\n';

        // Build the csvContent uses comma separations for the columns
        csvContent += 'Line,Product,Quantity,Price Editable,Unit Price,Total Price\n';
        
        // Loop through the quote lines to build onto the csvContent
        for (SBQQ__QuoteLine__c qli : quoteLines) {
            // checkbox fields will use ternary conditions to assign true or false
            String priceEditable = qli.SBQQ__PriceEditable__c ? 'True' : 'False';
            // currency fields will have dollar signs associated as well as setScale(2) for proper currency format
            String unitPrice = '$' + String.valueOf(qli.SBQQ__ListPrice__c.setScale(2));
            String totalPrice = '$' + String.valueOf(qli.SBQQ__NetTotal__c.setScale(2));
            
            // combine the csvContent with each quote line field separated by commas, also using reformatted strings above
            csvContent += qli.Name + ',' + qli.SBQQ__ProductName__c + ',' + qli.SBQQ__Quantity__c + ',' + priceEditable + ',' + unitPrice + ',' + totalPrice + '\n';
        }
        
        // Create a new map of String String
        Map<String, String> result = new Map<String, String>();
        // The first key/value pair will be the EncodingUtil.base64Encode format of the csvContent
        result.put('csvContent', 'data:text/csv;charset=utf-8;base64,' + EncodingUtil.base64Encode(Blob.valueOf(csvContent)));
        // The second key/value pair will be the quote's name to be referenced in JS and Excel Doc
        result.put('quoteName', quote.Name);
        return result;
    }
}