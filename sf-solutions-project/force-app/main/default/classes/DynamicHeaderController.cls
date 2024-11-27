/* 
    Author: Frank Berni
    Purpose: 
    Output specific Quote and Template fields to be displayed in quote document
    Sets specific booleans for visibility on document
*/ 
public with sharing class DynamicHeaderController {

    public string quoteId {get; set;}
    public string templateId {get; set;}
    public SBQQ__Quote__c quote {get;set;}
    public SBQQ__QuoteTemplate__c template {get;set;}

    // Controlling fields for visibility
    public boolean showOpportunity {get; set;}
    public boolean showShipping {get; set;}

    public DynamicHeaderController() {
        quoteId = ApexPages.currentPage().getParameters().get('qid');
        templateId = ApexPages.currentPage().getParameters().get('tid');

        showOpportunity = false;
        showShipping = false;

        // Call queries for Quote Template and Quote
        this.populateTemplate();
        this.populateQuoteData();

    }

    // queries Template fields
    public void populateTemplate() {
        template = [
          SELECT Id, SBQQ__FontFamily__c, SBQQ__FontSize__c, SBQQ__ShadingColor__c, 
                 SBQQ__CompanyName__c, SBQQ__CompanyPhone__c 
          FROM SBQQ__QuoteTemplate__c 
          WHERE Id = :templateId
        ];
      }

      // queries Quote fields and sets visibility booleans
    public void populateQuoteData() {
        quote = [
            SELECT Id, Name, SBQQ__BillingName__c, SBQQ__BillingStreet__c, SBQQ__BillingCity__c, SBQQ__BillingState__c,
                   SBQQ__BillingPostalCode__c, SBQQ__BillingCountry__c, SBQQ__ShippingStreet__c, SBQQ__ShippingCity__c, SBQQ__ShippingState__c,
                   SBQQ__ShippingPostalCode__c, SBQQ__ShippingCountry__c, SBQQ__PrimaryContact__r.Name, SBQQ__PrimaryContact__r.Email,
                   SBQQ__PrimaryContact__r.Phone, Primary_Sales_Contact__r.Name, Primary_Sales_Contact__r.Email, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.Name
            FROM SBQQ__Quote__c 
            WHERE Id = :quoteId 
            LIMIT 1
        ];

        // Check that Quote has an Opportunity for showOpportunity
        showOpportunity = quote.SBQQ__Opportunity2__c != null ? true : false;
        // Check Shipping Street is not null for showShipping
        showShipping = quote.SBQQ__ShippingStreet__c != null ? true : false;
        
    }
}