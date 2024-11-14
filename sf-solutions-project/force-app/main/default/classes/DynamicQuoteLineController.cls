/* 
    Author: Frank Berni
    Purpose: 
    Output quote lines grouped by their quote line groups
    Conditionally render certain fields base on quote line values
    Using getters/setters to dynamically set values for Visualforce template
*/ 
public with sharing class DynamicQuoteLineController {

    // Grab and populate our Quote Id and Template
    public string quoteId {get; set;}
    public string templateId {get; set;}
    public SBQQ__QuoteTemplate__c template {get;set;}
    // Main collection to display in template
    public Map<String, GroupedLines> groupToLineItemsMap{get;set;}

    // Visibility Controller - boolean getter setter 
    public boolean showDiscount {get;set;}

    // Width settings for columns
    // public string productCodeWidth {get;set;}
    // public string productNameWidth {get;set;}
    // public string quantityWidth {get;set;}
    // public string listPriceWidth {get;set;}
    public string addtlDiscWidth {get;set;}
    // public string addtlDiscPercentWidth {get;set;}
    // public string netPriceWidth {get;set;}
    // public string netTotalWidth {get;set;}
    

    
    // Inner class to contain totals by group
    public class GroupedLines{
        public List<SBQQ__QuoteLine__c> lines {get; set;}
        public Double netTotalSum {get; set;}
       
        public GroupedLines(List<SBQQ__QuoteLine__c> lineItems, Double netSum ) {
            this.lines = lineItems;
            this.netTotalSum = netSum;
        }  
      }
    
    public DynamicQuoteLineController() {
        quoteId = ApexPages.currentPage().getParameters().get('qid');
        templateId = ApexPages.currentPage().getParameters().get('tid');

        showDiscount = false;

        groupToLineItemsMap = new Map<String, GroupedLines>();

        // Query our template fields for styling
        this.populateTemplate();

        // Query quote lines and populate collections and variables above
        this.populateQuoteLineData();

         // Set widths for columns based on conditional booleans
         this.setColumnWidths();
    }

    // ***** Helper Functions ********

    public void populateTemplate() {
        template = [
          SELECT Id, SBQQ__FontFamily__c, SBQQ__FontSize__c, SBQQ__ShadingColor__c 
          FROM SBQQ__QuoteTemplate__c 
          WHERE Id = :templateId
        ];
    }

    // queries all related quote lines, groups them by group if applicable, set visibility booleans, calculates sum for each group, then populates map for display in table
    public void populateQuoteLineData() {
        // query all pertinent fields for Quote Lines, ensure they are related to the Quote  
        List<SBQQ__QuoteLine__c> quoteLines = [
            SELECT Id, SBQQ__Description__c,
                SBQQ__ProductCode__c,
                SBQQ__CustomerPrice__c, SBQQ__Quantity__c,
                SBQQ__AdditionalDiscount__c, SBQQ__Discount__c,
                SBQQ__AdditionalDiscountAmount__c, SBQQ__AdditionalQuantity__c, SBQQ__ListPrice__c,
                SBQQ__NetPrice__c, SBQQ__ProductName__c, SBQQ__Quote__r.Name,
                SBQQ__RegularPrice__c, SBQQ__Group__c, SBQQ__Group__r.Name, SBQQ__NetTotal__c, SBQQ__Group__r.SBQQ__Number__c    
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__c = :quoteId
            ORDER BY SBQQ__Number__c
        ];

        Map<String, GroupedLines> tempGroupedLinesMap = new Map<String, GroupedLines>();
        Map<String, List<SBQQ__QuoteLine__c>> linesByGroupMap = new Map<String, List<SBQQ__QuoteLine__c>>();
        // Setting up a group id in case Quote does not have quote line groups
        String tempGroupId = quoteLines[0].SBQQ__Quote__r.Name;

        for (SBQQ__QuoteLine__c ql : quoteLines) {

            // set boolean
            if( (ql.SBQQ__AdditionalDiscountAmount__c > 0 || ql.SBQQ__Discount__c > 0)  && showDiscount != true) {
                showDiscount = true;
            }

            // overwrite tempGroupId with the respective ql Group Number + Group Id
            if (ql.SBQQ__Group__c != null) {
                tempGroupId = ql.SBQQ__Group__r.SBQQ__Number__c + ' - ' + ql.SBQQ__Group__r.Name;
            }

            // build map of groups and their associated quote lines
            if(linesByGroupMap.containsKey(tempGroupId)) {
                // Adding ql to list
                linesByGroupMap.get(tempGroupId).add(ql);
            }
            else {
                // create a new List for the newly added group
                linesByGroupMap.put(tempGroupId, new List<SBQQ__QuoteLine__c>());
                // Adding ql to list
                linesByGroupMap.get(tempGroupId).add(ql);
            }

        }

        // Loop through group map keySet
        for (String groupName : linesByGroupMap.keySet()) {
            Double groupNetSum = 0;
            
            // Loop through the groupName's quote lines
            for(SBQQ__QuoteLine__c groupQL : linesByGroupMap.get(groupName)) {
                // sum up each groups quote line SBQQ__NetTotal__c
                groupNetSum += groupQL.SBQQ__NetTotal__c != null ? groupQL.SBQQ__NetTotal__c : 0; 
            }

            // Create a GroupedLines for this program
            GroupedLines gl = new GroupedLines(
                linesByGroupMap.get(groupName),
                groupNetSum
            );

            // Put the program with its associated groupedLines in a map
            tempGroupedLinesMap.put(
                groupName,
                gl 
            );
        }

        groupToLineItemsMap = tempGroupedLinesMap;


    }

    // variables to set for table-column widths
    public void setColumnWidths() { 
        
        // Set as default when all columns are shown
        // productCodeWidth = 'auto';
        // productNameWidth = 'auto';
        // quantityWidth = 'auto';
        // listPriceWidth = 'auto';
        // Ternary to set column-width to 0% if the boolean is false
        addtlDiscWidth = this.showDiscount ? 'auto' : '0%';
        // addtlDiscPercentWidth = this.showDiscount ? 'auto' : '0%';
        // netPriceWidth = 'auto';
        // netTotalWidth = 'auto';
    
      }


}