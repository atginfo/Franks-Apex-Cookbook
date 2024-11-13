//Section 2 checkpoint class 1 
public with sharing class OpportunityTriggerHandler {
    
    public static void beforeInsertMethod(List<Opportunity> newList){
        setDefaults(newList, null);
        
    }

    public static void afterInsertMethod(List<Opportunity> newList, Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap){
        

    }

    public static void beforeUpdateMethod(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        
    }

    public static void afterUpdateMethod(List<Opportunity> newList, Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap){
        syncAddresses(newList, newMap, oldMap);
        cadenceOverride(newList, newMap, oldMap);
        
    }

    //** Helper Methods **/

    //Populates specific fields on new Opportunities based on related Account
    private static void setDefaults(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        
        //Creating a Set of Account Ids related to triggered Opportunities
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : newList) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }
        
        //Using those Ids to create a Map of related Accounts
        Map<Id, Account> relatedAccMap = new Map<Id, Account>([
            SELECT Id, Type, BillingCity, BillingCountry, BillingState,
            BillingStreet, BillingPostalCode, ShippingCity, ShippingCountry,
            ShippingState, ShippingStreet, ShippingPostalCode
            FROM Account
            WHERE Id IN :accountIds
        ]);

        for (Opportunity opp : newList) {
            
            //Assigning the related Account to a variable to be referenced in Conditional statements
            Account relatedAccount = relatedAccMap.get(opp.AccountId); 
             
            //Setting to at least 30 days from present
            opp.CloseDate = Date.today().addDays(30);
    
            //Checking to see if the Opportunity has a related Account
            if (opp.AccountId == null) {
                
                //If no Account is asscociated with it, StageName will be Needs Analysis
                opp.StageName = 'Needs Analysis';
            
            } else {

                //If there is an Account, StageName will be Qualification if the Account Type is not Prospect
                if (relatedAccount.Type != 'Prospect') {
                    opp.StageName = 'Qualification';
                    
                
                //Otherwise StageName will be assigned Prospecting if Account Type is Prospect
                } else {
                    opp.StageName = 'Prospecting';
                    
                }
   
            //Next, we check to make sure all fields under the Billing Address fields are filled in
            //If at least one is left blank, all Opportunity Billing fields populate from Account Billing fields
            if( (opp.BillingCity__c == null) 
                || (opp.BillingCountry__c == null) 
                || (opp.BillingPostalCode__c == null) 
                || (opp.BillingState__c == null) 
                || (opp.BillingStreet__c == null) ) {
                    
                    opp.BillingCity__c = relatedAccount.BillingCity;
                    opp.BillingCountry__c = relatedAccount.BillingCountry;
                    opp.BillingPostalCode__c = relatedAccount.BillingPostalCode;
                    opp.BillingState__c = relatedAccount.BillingState;
                    opp.BillingStreet__c = relatedAccount.BillingStreet;
                } 

            //Same as above except for Shipping Address fields
            if( (opp.ShippingCity__c == null) 
                || (opp.ShippingCountry__c == null) 
                || (opp.ShippingPostalCode__c == null) 
                || (opp.ShippingState__c == null) 
                || (opp.ShippingStreet__c == null) ) {
                    
                    opp.ShippingCity__c = relatedAccount.ShippingCity;
                    opp.ShippingCountry__c = relatedAccount.ShippingCountry;
                    opp.ShippingPostalCode__c = relatedAccount.ShippingPostalCode;
                    opp.ShippingState__c = relatedAccount.ShippingState;
                    opp.ShippingStreet__c = relatedAccount.ShippingStreet;
                    
                }
            }
        }
    }

    //Updating related Quote Addresses when Opportunity Addresses change
    private static void syncAddresses(List<Opportunity> newList, Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {

        //List to store updated addresses on Opportunities
        Set<Id> changedOppIds = new Set<Id>();
        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
       
        for (Opportunity opp : newList) {
            
            //Checking for any updates to Billing and Shipping Addresses
            if ( (opp.BillingCity__c != oldMap.get(opp.Id).BillingCity__c) ||
            (opp.BillingCountry__c != oldMap.get(opp.Id).BillingCountry__c) ||
            (opp.BillingPostalCode__c != oldMap.get(opp.Id).BillingPostalCode__c) ||
            (opp.BillingState__c != oldMap.get(opp.Id).BillingState__c) ||
            (opp.BillingStreet__c != oldMap.get(opp.Id).BillingStreet__c) ||
            (opp.ShippingCity__c != oldMap.get(opp.Id).ShippingCity__c) || 
            (opp.ShippingCountry__c != oldMap.get(opp.Id).ShippingCountry__c) || 
            (opp.ShippingPostalCode__c != oldMap.get(opp.Id).ShippingPostalCode__c) ||
            (opp.ShippingState__c != oldMap.get(opp.Id).ShippingState__c) ||
            (opp.ShippingStreet__c != oldMap.get(opp.Id).ShippingStreet__c) ) {
                
                //Adding the updated address opportunities to a list
                changedOppIds.add(opp.Id);
            }
        }
        //If not empty and wrap rest of method*
        // Grabbing list of related Quotes to our changed Opportunities with Status as Draft
        List<SBQQ__Quote__c> draftQuotes = [
            SELECT Id, SBQQ__BillingCity__c, SBQQ__BillingCountry__c,
            SBQQ__BillingPostalCode__c, SBQQ__BillingState__c, SBQQ__BillingStreet__c,
            SBQQ__ShippingCity__c, SBQQ__ShippingCountry__c, SBQQ__ShippingPostalCode__c,
            SBQQ__ShippingState__c, SBQQ__ShippingStreet__c, SBQQ__Opportunity2__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__c IN :changedOppIds 
            AND SBQQ__Status__c = 'Draft'
        ];

        //Looping through the related Draft Quotes
        for (SBQQ__Quote__c quote : draftQuotes) {

            //Using the newMap of triggered Opportunities related to the quote and assigning to a variable
            Opportunity relatedOpp = newMap.get(quote.SBQQ__Opportunity2__c);

            //Checking if any Quote Billing or Shipping addresses are different from Opportunity Billing/Shipping addresses
            if( (quote.SBQQ__BillingCity__c != relatedOpp.BillingCity__c) 
                || (quote.SBQQ__BillingCountry__c != relatedOpp.BillingCountry__c) 
                || (quote.SBQQ__BillingPostalCode__c != relatedOpp.BillingPostalCode__c) 
                || (quote.SBQQ__BillingState__c != relatedOpp.BillingState__c) 
                || (quote.SBQQ__BillingStreet__c != relatedOpp.BillingStreet__c)
                || (quote.SBQQ__ShippingCity__c != relatedOpp.ShippingCity__c) 
                || (quote.SBQQ__ShippingCountry__c != relatedOpp.ShippingCountry__c) 
                || (quote.SBQQ__ShippingPostalCode__c != relatedOpp.ShippingPostalCode__c) 
                || (quote.SBQQ__ShippingState__c != relatedOpp.ShippingState__c) 
                || (quote.SBQQ__ShippingStreet__c != relatedOpp.ShippingStreet__c) ) {

                //Updating Quote Billing and Shipping Addresses
                SBQQ__Quote__c quoteRecord = new SBQQ__Quote__c();
                quoteRecord.Id = quote.Id;
                //Broke up each address field into separate conditionals to avoid null pointer error
                if (relatedOpp.BillingCity__c != null) {
                    quoteRecord.SBQQ__BillingCity__c = relatedOpp.BillingCity__c;
                }

                if (relatedOpp.BillingCountry__c != null) {
                    quoteRecord.SBQQ__BillingCountry__c = relatedOpp.BillingCountry__c;
                }

                if (relatedOpp.BillingPostalCode__c != null) {
                    quoteRecord.SBQQ__BillingPostalCode__c = relatedOpp.BillingPostalCode__c;
                }

                if (relatedOpp.BillingState__c != null) {
                    quoteRecord.SBQQ__BillingState__c = relatedOpp.BillingState__c;
                }

                if (relatedOpp.BillingStreet__c != null) {
                    quoteRecord.SBQQ__BillingStreet__c = relatedOpp.BillingStreet__c;
                }

                if (relatedOpp.ShippingCity__c != null) {
                    quoteRecord.SBQQ__ShippingCity__c = relatedOpp.ShippingCity__c;
                }

                if (relatedOpp.ShippingCountry__c != null) {
                    quoteRecord.SBQQ__ShippingCountry__c = relatedOpp.ShippingCountry__c;
                }

                if (relatedOpp.ShippingPostalCode__c != null) {
                    quoteRecord.SBQQ__ShippingPostalCode__c = relatedOpp.ShippingPostalCode__c;
                }

                if (relatedOpp.ShippingState__c != null) {
                    quoteRecord.SBQQ__ShippingState__c = relatedOpp.ShippingState__c;
                }

                if (relatedOpp.ShippingStreet__c != null) {
                    quoteRecord.SBQQ__ShippingStreet__c = relatedOpp.ShippingStreet__c;
                }

                quotesToUpdate.add(quoteRecord);
            }   
        }
        
        //Updating reflected changes to Quotes
        if (!quotesToUpdate.isEmpty()) {
            update quotesToUpdate;
        }
        
    }

    //When the Purchase Cadence Override is filled in, Subscription term is updated based on that value
    //If not Account Purchase Cadence updates the Subscription term instead
    private static void cadenceOverride(List<Opportunity> newList, Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {

        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
        Set<Id> changedOppIds = new Set<Id>();

        for (Opportunity opp : newList) {
            
            //Adding related Opportunities who's PCO is filled in to a set /Simplified conditional check
            if ( (oldMap != null) 
            && (opp.Purchase_Cadence_Override__c != oldMap.get(opp.Id).Purchase_Cadence_Override__c) ) {
                changedOppIds.add(opp.Id);
            }    
        }

        //Query for Draft Quotes related to the Updated Opportunities in our list
        List<SBQQ__Quote__c> quotesWithUpdatedOpps = [
            SELECT Id, SBQQ__Opportunity2__c, SBQQ__Status__c, SBQQ__SubscriptionTerm__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__c = :changedOppIds
            AND SBQQ__Status__c = 'Draft'
        ];

        //Looping through Draft Quotes with Updated Opportunities (This covers After Update Context)
        for (SBQQ__Quote__c quote : quotesWithUpdatedOpps) {
            
            Opportunity relatedOpp = newMap.get(quote.SBQQ__Opportunity2__c);
            
            //Update the Subscription Term based on the Purchase Cadence Overide value
            switch on relatedOpp.Purchase_Cadence_Override__c {
                when 'Monthly' {
                    quote.SBQQ__SubscriptionTerm__c = 1;
                }
                when 'Quarterly' {
                    quote.SBQQ__SubscriptionTerm__c = 3;
                }
                //weird bug where half the string isn't being caught, switch statement still works in debug console
                when 'Semi-Annually' { 
                    quote.SBQQ__SubscriptionTerm__c = 6;
                } 
                when 'Annually' {
                    quote.SBQQ__SubscriptionTerm__c = 12;
                }
            } //End of Switch block
            quotesToUpdate.add(quote);
        }

        //Updating quotes
        if (!quotesToUpdate.isEmpty()) {
            update quotesToUpdate;
        }  
    } // End of Method
}