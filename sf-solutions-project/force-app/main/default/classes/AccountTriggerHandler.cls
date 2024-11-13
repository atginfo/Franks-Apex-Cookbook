//Section 2 checkpoint class 5
public class AccountTriggerHandler {
    
    public static void beforeInsertMethod(List<Account> newList){
        
    }

    public static void afterInsertMethod(List<Account> newList){
        
    }

    public static void beforeUpdateMethod(List<Account> newList, Map<Id, Account> oldMap){
        
    }

    public static void afterUpdateMethod(List<Account> newList, Map<Id, Account> newMap, Map<Id, Account> oldMap){
        updateRelatedQuotes(newList, newMap, oldMap);
    }

    /************** Helper Methods *****************/
    
    //Update Quote Subscription Terms based on Changed Purchase Cadence
    private static void updateRelatedQuotes(List<Account> newList, Map<Id, Account> newMap, Map<Id, Account> oldMap) {

        //New collections to store data from loops
        Set<Id> relatedAccIds = new Set<Id>();
        Set<Id> relatedOppIds = new Set<Id>();
        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();

        //Grabbing Ids of Accounts whose Purchase Cadences have changed
        for (Account acc : newList) {
            If (acc.Purchase_Cadence__c != oldMap.get(acc.Id).Purchase_Cadence__c) {
                relatedAccIds.add(acc.Id);
            }
        }

        //Query for Draft Quotes with the related Accounts from above 
        List<SBQQ__Quote__c> quotesWithAccs = [
            SELECT Id, SBQQ__Account__c, SBQQ__Opportunity2__c,
                SBQQ__SubscriptionTerm__c, SBQQ__Opportunity2__r.AccountId,
                SBQQ__Opportunity2__r.Purchase_Cadence_Override__c, SBQQ__Account__r.Purchase_Cadence__c,
                SBQQ__Opportunity2__r.Account.Purchase_Cadence__c
            FROM SBQQ__Quote__c
            WHERE SBQQ__Account__c = :relatedAccIds 
            AND SBQQ__Status__c = 'Draft'
        ];

        //Looping through those quotes and grabbing the related Opportunity Ids 
        for (SBQQ__Quote__c quote : quotesWithAccs) {
            if (quote.SBQQ__Opportunity2__c != null) {
                relatedOppIds.add(quote.SBQQ__Opportunity2__c);
            }
        }

        //Creating a Map with those related Opportunity Ids
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
            SELECT Id, Purchase_Cadence_Override__c
            FROM Opportunity
            WHERE Id IN :relatedOppIds
        ]);

        //Looping through those quotes once again
        for (SBQQ__Quote__c quote : quotesWithAccs) {

            //Utilizing the newMap of Accounts and the related oppMap for variable assignment
            Account relatedAcc = newMap.get(quote.SBQQ__Account__c);
            Opportunity relatedOpp = oppMap.get(quote.SBQQ__Opportunity2__c);

            //Seeing if the Purchase cadence is filled and the Purchase Cadence Override is not
            if (relatedAcc.Purchase_Cadence__c != null && relatedOpp.Purchase_Cadence_Override__c == null) {
                
                //Update the Quotes Subscription Terms based on Account Purchase Cadence
                switch on relatedAcc.Purchase_Cadence__c {
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
            
            //If the Purchase Cadence Override is filled
            } else if (relatedOpp.Purchase_Cadence_Override__c != null) {
                
                //Subscription Terms will reflect the Purchase Cadence Override instead
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
        }

        //Updating quotes
        if (!quotesToUpdate.isEmpty()) {
            update quotesToUpdate;
        }
        
    } // End of Method
}