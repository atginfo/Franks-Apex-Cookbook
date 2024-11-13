//Checkpoint 3 Class 5. Batchable and Schedulable
public class OrdersForApprovedQuotes implements Database.Batchable<sObject>, Schedulable {
    
    //Class variables used in methods
    final String APPROVED = 'Approved';
    final Boolean notOrdered = false;
    String query;

    public OrdersForApprovedQuotes() {
        
        System.debug('In OrdersForApprovedQuotes Constructor');

        //Grabbing Quotes that are Approved and have related Opportunities
        query = 'SELECT Id, SBQQ__Ordered__c, SBQQ__Opportunity2__c ' +
        'FROM SBQQ__Quote__c ' +
        'WHERE SBQQ__Status__c = :APPROVED ' +
        'AND SBQQ__Opportunity2__c != NULL ' +
        'AND SBQQ__Ordered__c = :notOrdered';
        
    }

    //Feeding our query into the Database.QueryLocator
    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        System.debug('In OrdersForApprovedQuotes start()');
        Database.QueryLocator queryLocator = Database.getQueryLocator(query);
        return queryLocator;
    
    }

    public void execute(Database.BatchableContext batchContext, List<SBQQ__Quote__c> quoteList) {
        
        System.debug('In OrdersForApprovedQuotes execute()');
        
        //Getting details from within the execute method
        AsyncApexJob asyncJob = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed
            FROM AsyncApexJob 
            WHERE Id = :batchContext.getJobId()
            LIMIT 1
        ];

        System.debug('AsyncJob: ' + asyncJob);

        Set<Id> oppIds = new Set<Id>();
        

        //Adding the related Opportunity Ids from Quotes to a Set
        for (SBQQ__Quote__c quote : quoteList) {
            oppIds.add(quote.SBQQ__Opportunity2__c);
    
        }

        List<SBQQ__Quote__c> quotesWithLines = new List<SBQQ__Quote__c>();

        if (!oppIds.isEmpty()) {

            //Grabbing the quotes above with their Quote lines and related Opportunities
            quotesWithLines = [
                SELECT Id, SBQQ__Opportunity2__c, SBQQ__Ordered__c,
                (
                    SELECT Id FROM SBQQ__LineItems__r
                )
                FROM SBQQ__Quote__c
                WHERE SBQQ__Opportunity2__c IN :oppIds
            ];
        }
        
        if ( !quotesWithLines.isEmpty() ) {

            List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
            List<Opportunity> oppsToUpdate = new List<Opportunity>();

            //Looping through the quoteList from the Query, updating quote and its related Opportunity
            for (SBQQ__Quote__c quote : quotesWithLines ) {

                //Making sure the Quotes have Lines associated with them before continuing
                if(quote.SBQQ__LineItems__r.size() != 0) {

                    //Updating the Quote Ordered to True so it generates a Order
                    quote.SBQQ__Ordered__c = true;
                    quotesToUpdate.add(quote);

                    //Updating the StageName to Closed Won
                    Opportunity opp = new Opportunity();
                    opp.Id = quote.SBQQ__Opportunity2__c;
                    opp.StageName = 'Closed Won';
                    oppsToUpdate.add(opp);
                }  
            }

            //Updating both Lists of Opportunities and Quotes if quote list isn't empty
            if (!quotesToUpdate.isEmpty()) {
                update quotesToUpdate;
                update oppsToUpdate;
            }
        }
    }

    public void finish(Database.BatchableContext batchContext) {     
        System.debug('In OrdersForApprovedQuotes finish()');

    }

    /******************** Schedulable *********************/

    public void execute(SchedulableContext SC) {
        OrdersForApprovedQuotes batchJob = new OrdersForApprovedQuotes();
        Id jobId = Database.executeBatch(batchJob);  
    }

    /*
        //In Execute Anonymous
        //Scheduling for every night at 9 pm
        OrdersForApprovedQuotes myJob = new OrdersForApprovedQuotes();
        String cronExpression = '0 0 21 ? * MON,TUE,WED,THU,FRI,SAT,SUN *';
        String jobID = System.schedule('OrdersForApprovedQuotes Schedulabled', cronExpression, myJob);
    */
}