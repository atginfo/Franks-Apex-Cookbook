//Checkpoint 3 Class 2
public class OppTriggerHandler2 {
    
    public static void beforeInsertMethod(List<Opportunity> newList){
           
    }

    public static void afterInsertMethod(List<Opportunity> newList){
        callQueueables(newList);
    }

    public static void beforeUpdateMethod(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        
    }

    public static void afterUpdateMethod(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
          
    }

    //** Helper Methods **/
    private static void callQueueables(List<Opportunity> newList) {
        
        List<Opportunity> oppsWithActiveAccounts = new List<Opportunity>();
        Set<Id> accIds = new Set<Id>();

        for (Opportunity opp : newList) {
            if (opp.AccountId != null) {
                accIds.add(opp.AccountId);
            }
        }

        if (!accIds.isEmpty()) {

            //Grabbing related Accounts who are related to our new Opportunities and have Active Buyer checked
            Map<Id, Account> accMap = new Map<Id, Account>([
                SELECT Id, Active_Buyer__c 
                FROM Account
                WHERE Id IN :accIds 
                AND Active_Buyer__c = true
            ]);

            //Grabbing all New Opportunities
            for (Opportunity opp : newList) {

                //Assigning related Account from AccMap
                Account relatedAcc = accMap.get(opp.AccountId);

                //Making sure opportunity has a related Account
                if (opp.AccountId != null) {
                    //Then checking if the related Account has Active Buyer marked true
                    if(relatedAcc.Active_Buyer__c == true) {
                        oppsWithActiveAccounts.add(opp);        
                    }
                }
            }

            //Then we run our chain of queueables 
            if ( (!oppsWithActiveAccounts.isEmpty()) && (!Test.isRunningTest()) ) {
                System.debug('List is full so now lauching first Queueable');
                NewQuoteQueueable queueableJob = new NewQuoteQueueable(oppsWithActiveAccounts);
                Id jobId = System.enqueueJob(queueableJob);
            }
        }   
    }
}