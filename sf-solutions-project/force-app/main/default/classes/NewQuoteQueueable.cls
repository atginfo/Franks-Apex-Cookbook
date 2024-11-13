//Checkpoint 3 Class 3. Queueable called from Trigger, chains another queueable
public class NewQuoteQueueable implements Queueable {
    
    //Class variable that is used in execute method
    private List<Opportunity> parentOppList;
    
    //Our constructor which grabs the list of Opportunities from our Trigger
    public NewQuoteQueueable(List<Opportunity> parentOppList) {
        this.parentOppList = parentOppList;
        
    }

    public void execute(QueueableContext qc) {
        
        System.debug('Executing Queueable Context');
        List<SBQQ__Quote__c> quotesToInsert = new List<SBQQ__Quote__c>();

        //Looping through the opportunities and creating a new Quote for each
        for (Opportunity opp : parentOppList) {

            //Relating a quote to an opportunity automatically fills in the related Account as well
            //as long as the Opportunity has a related Account
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Opportunity2__c = opp.Id;
            quote.SBQQ__Primary__c      = true;
            quote.SBQQ__StartDate__c    = Date.today();
            quotesToInsert.add(quote);
             
        }

        //Making sure the list is not empty to insert Child Accounts
        if (!quotesToInsert.isEmpty()) {
            insert quotesToInsert;
            
            System.debug('lauching Second Queueable');
            //Setting up next chained queueable for emailing Team Members who own the Opportunity
            if (!Test.isRunningTest()) { // Check to ensure we are not running in a Test Context - Can't chain Queueables in Tests?
                EmailTMQueueable queueableJob = new EmailTMQueueable(parentOppList);
                Id jobId = System.enqueueJob(queueableJob);
            }   

        }
    }
}