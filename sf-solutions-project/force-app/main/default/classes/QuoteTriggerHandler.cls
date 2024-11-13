//Section 2 checkpoint class 3
public with sharing class QuoteTriggerHandler {
   
    public static void beforeInsertMethod(List<SBQQ__Quote__c> newList){
        setAddresses(newList);
        setSubscription(newList);
    }

    public static void beforeUpdateMethod(List<SBQQ__Quote__c> newList, Map<Id, SBQQ__Quote__c> oldMap){
        syncSubscription(newList, oldMap);
    }

    public static void afterUpdateMethod(List<SBQQ__Quote__c> newList, Map<Id, SBQQ__Quote__c> oldMap){
        updateRelatedOpp(newList, oldMap);
        
    }

    //** Helper Methods **

    //Defaulting Quote addresses to the related Opportunity Addresses 
    private static void setAddresses(List<SBQQ__Quote__c> newList) {

        Set<Id> relatedOppIds = new Set<Id>();
        
        //Grabbing related Opportunity Ids and adding to our Set
        for (SBQQ__Quote__c quote : newList) {
            if (quote.SBQQ__Opportunity2__c != null) {
                relatedOppIds.add(quote.SBQQ__Opportunity2__c);
            }
        }

        //Creating a Map of Ids and Opportunities based on those related Opportunities
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
            SELECT Id, BillingCity__c, BillingCountry__c, BillingState__c,
            BillingStreet__c, BillingPostalCode__c, ShippingCity__c, ShippingCountry__c,
            ShippingState__c, ShippingStreet__c, ShippingPostalCode__c
            FROM Opportunity
            WHERE Id IN :relatedOppIds
        ]);
        
        //Loop through the new quotes and assign each address from the Opportunity
        for (SBQQ__Quote__c quote : newList) {

            //Assigning related Opportunity as variable to be referenced in assignment
            Opportunity relatedOpp = oppMap.get(quote.SBQQ__Opportunity2__c);

            //Broke up each address field into separate conditionals to avoid null pointer error
            if (relatedOpp.BillingCity__c != null) {
                quote.SBQQ__BillingCity__c = relatedOpp.BillingCity__c;
            }

            if (relatedOpp.BillingCountry__c != null) {
                quote.SBQQ__BillingCountry__c = relatedOpp.BillingCountry__c;
            }

            if (relatedOpp.BillingPostalCode__c != null) {
                quote.SBQQ__BillingPostalCode__c = relatedOpp.BillingPostalCode__c;
            }

            if (relatedOpp.BillingState__c != null) {
                quote.SBQQ__BillingState__c = relatedOpp.BillingState__c;
            }

            if (relatedOpp.BillingStreet__c != null) {
                quote.SBQQ__BillingStreet__c = relatedOpp.BillingStreet__c;
            }

            if (relatedOpp.ShippingCity__c != null) {
                quote.SBQQ__ShippingCity__c = relatedOpp.ShippingCity__c;
            }

            if (relatedOpp.ShippingCountry__c != null) {
                quote.SBQQ__ShippingCountry__c = relatedOpp.ShippingCountry__c;
            }

            if (relatedOpp.ShippingPostalCode__c != null) {
                quote.SBQQ__ShippingPostalCode__c = relatedOpp.ShippingPostalCode__c;
            }

            if (relatedOpp.ShippingState__c != null) {
                quote.SBQQ__ShippingState__c = relatedOpp.ShippingState__c;
            }

            if (relatedOpp.ShippingStreet__c != null) {
                quote.SBQQ__ShippingStreet__c = relatedOpp.ShippingStreet__c;
            }
            
        }
    }

    //Updating the Opportunity Billing and Shipping Addresses if Primary Quote Addresses are changed
    private static void updateRelatedOpp(List<SBQQ__Quote__c> newList, Map<Id, SBQQ__Quote__c> oldMap){

        Set<Id> relatedOppIds = new Set<Id>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        //Grabbing related Opportunity Ids and adding to our Set
        /*for (SBQQ__Quote__c quote : newList) {
            
            //IF the quote has a related Opportunity AND
            //The Quote is marked Primary, add the Opportunity Id to the Set Placing conditional for Shipping and billing changes here
            if ((quote.SBQQ__Opportunity2__c != null) && (quote.SBQQ__Primary__c == true)) {
                relatedOppIds.add(quote.SBQQ__Opportunity2__c);
            }
        }*/

        //*If statement if relatedOpps is not empty , only query related opportunities if they exist
        //Creating a Map of Ids and Opportunities based on those related Opportunities
        /*Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
            SELECT Id, BillingCity__c, BillingCountry__c, BillingState__c,
            BillingStreet__c, BillingPostalCode__c, ShippingCity__c, ShippingCountry__c,
            ShippingState__c, ShippingStreet__c, ShippingPostalCode__c
            FROM Opportunity
            WHERE Id IN :relatedOppIds
        ]);*/
        
        //Looping through triggered Quotes
        for (SBQQ__Quote__c quote : newList) {

            //The Quote is marked Primary
            if (quote.SBQQ__Primary__c == true) {   
                    
                    //Storing the Id of the related Opportunity for later
                    //Opportunity relatedOppId = oppMap.get(quote.SBQQ__Opportunity2__c);

                    //Creating a new Opportunity with the Same Id *Redundant area
                    Opportunity relatedOpp = new Opportunity();
                    relatedOpp.Id = quote.SBQQ__Opportunity2__c;

                    //If there is a change in the quote address fields, the related Opportunity will match them
                    if (quote.SBQQ__BillingCity__c != oldMap.get(quote.Id).SBQQ__BillingCity__c) {
                        relatedOpp.BillingCity__c = quote.SBQQ__BillingCity__c;
                    }
                    if (quote.SBQQ__BillingCountry__c != oldMap.get(quote.Id).SBQQ__BillingCountry__c) {
                        relatedOpp.BillingCountry__c = quote.SBQQ__BillingCountry__c;
                    }
                    if (quote.SBQQ__BillingPostalCode__c != oldMap.get(quote.Id).SBQQ__BillingPostalCode__c) {
                        relatedOpp.BillingPostalCode__c = quote.SBQQ__BillingPostalCode__c;
                    }
                    if (quote.SBQQ__BillingState__c != oldMap.get(quote.Id).SBQQ__BillingState__c) {
                        relatedOpp.BillingState__c = quote.SBQQ__BillingState__c;
                    }
                    if (quote.SBQQ__BillingStreet__c != oldMap.get(quote.Id).SBQQ__BillingStreet__c) {
                        relatedOpp.BillingStreet__c = quote.SBQQ__BillingStreet__c;
                    }
                    if (quote.SBQQ__ShippingCity__c != oldMap.get(quote.Id).SBQQ__ShippingCity__c) {
                        relatedOpp.ShippingCity__c = quote.SBQQ__ShippingCity__c;
                    }
                    if (quote.SBQQ__ShippingCountry__c != oldMap.get(quote.Id).SBQQ__ShippingCountry__c) {
                        relatedOpp.ShippingCountry__c = quote.SBQQ__ShippingCountry__c;
                    }
                    if (quote.SBQQ__ShippingPostalCode__c != oldMap.get(quote.Id).SBQQ__ShippingPostalCode__c) {
                        relatedOpp.ShippingPostalCode__c = quote.SBQQ__ShippingPostalCode__c;
                    }
                    if (quote.SBQQ__ShippingState__c != oldMap.get(quote.Id).SBQQ__ShippingState__c) {
                        relatedOpp.ShippingState__c = quote.SBQQ__ShippingState__c;
                    }
                    if (quote.SBQQ__ShippingStreet__c != oldMap.get(quote.Id).SBQQ__ShippingStreet__c) {
                        relatedOpp.ShippingStreet__c = quote.SBQQ__ShippingStreet__c;
                    }
                    
                    oppsToUpdate.add(relatedOpp);    
            }    
        }

        //Updating the related Opportunities if its not empty
        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }

    // Setting the Subscription terms of the Quotes by the Purchase Cadence of related Accounts
    private static void setSubscription(List<SBQQ__Quote__c> newList) {
        
        Set<Id> relatedAccIds = new Set<Id>();

        //Grabbing related Accounts and adding them to a set
        for (SBQQ__Quote__c quote : newList) {
            if (quote.SBQQ__Account__c != null) {
                relatedAccIds.add(quote.SBQQ__Account__c);
            }
        }
        
        //Using those Ids to create a Map of related Accounts
        Map<Id, Account> accMap = new Map<Id, Account>([
            SELECT Id, Purchase_Cadence__c
            FROM Account
            WHERE Id IN :relatedAccIds
        ]);

        for (SBQQ__Quote__c quote : newList) {
            
            //TODO : Add in Purchase Cadence Override as well
            if (quote.SBQQ__Account__c != null) {
            //Assigning the related Account to a variable to be referenced in Conditional statements
            Account relatedAccount = accMap.get(quote.SBQQ__Account__c); 

                switch on relatedAccount.Purchase_Cadence__c {
                    when 'Monthly' {
                        quote.SBQQ__SubscriptionTerm__c = 1;
                    }
                    when 'Quarterly' {
                        quote.SBQQ__SubscriptionTerm__c = 3;
                    }
                    //weird bug where half the string isn't being caught, switch statement still works in debug console
                    when 'Semi-Annually'{
                        quote.SBQQ__SubscriptionTerm__c = 6;
                    } 
                    when 'Annually' {
                        quote.SBQQ__SubscriptionTerm__c = 12;
                    }
                } //End of Switch block
            } // End of Conditonal 
        } //End of Loop
    } // End of Method

    //This updates the Quote's Subscription term when changed back to Draft to sync up with related
    //Account and Opportunity purchase cadences
    private static void syncSubscription(List<SBQQ__Quote__c> newList, Map<Id, SBQQ__Quote__c> oldMap) {

        Set<Id> relatedAccounts = new Set<Id>();
        Set<Id> relatedOpps = new Set<Id>();

        //Grabbing the Ids of Related Accounts and Opportunities
        for (SBQQ__Quote__c quote : newList) {
            if (quote.SBQQ__Account__c != null) {
                relatedAccounts.add(quote.SBQQ__Account__c);
            }

            if (quote.SBQQ__Opportunity2__c != null) {
                relatedOpps.add(quote.SBQQ__Opportunity2__c);
            }
        }

        //Creating two Maps one for related Accounts and another for related Opportunities
        Map<Id, Account> accMap = new Map<Id, Account>([
            SELECT Id, Purchase_Cadence__c
            FROM Account
            WHERE Id IN :relatedAccounts
        ]);
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
            SELECT Id, Purchase_Cadence_Override__c
            FROM Opportunity
            WHERE Id IN :relatedOpps
        ]);
        
        //Looping through triggered quotes
        for (SBQQ__Quote__c quote : newList) {

            //Assigning our related Account and Opportunity to variables to reference 
            Account relatedAccount = accMap.get(quote.SBQQ__Account__c);
            Opportunity relatedOpp = oppMap.get(quote.SBQQ__Opportunity2__c);

            //If the Quote status changes to Draft from another status
            if (quote.SBQQ__Status__c == 'Draft' && oldMap.get(quote.Id).SBQQ__Status__c != 'Draft') {

                //If Quote has a related Account And
                //There is no related Opportunity or related Opportunity PCO is not filled
                if (quote.SBQQ__Account__c != null && 
                (quote.SBQQ__Opportunity2__c == null || relatedOpp.Purchase_Cadence_Override__c == null) ) {

                    //Update the Subscription Term based on the Acc Purchase Cadence value
                    switch on relatedAccount.Purchase_Cadence__c {
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
                
                //If there is a related Opportunity and their PCO is filled in   
                } else if ( (quote.SBQQ__Opportunity2__c != null) && 
                (relatedOpp.Purchase_Cadence_Override__c != null) ) {
                    
                    //Update the Subscription Term based on the Opp Purchase Cadence Overide value
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
                } //End of second conditional
            }//End of first conditional
        }//End of Loop
    }//End of Method
}