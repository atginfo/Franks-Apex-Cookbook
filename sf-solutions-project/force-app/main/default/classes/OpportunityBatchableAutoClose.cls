public class OpportunityBatchableAutoClose implements Database.Batchable<sObject>, Schedulable {

    //Setting up class variables to be used in the Batchable methods
    public static final String CLOSED_WON = 'Closed Won';
    public static final String CLOSED_LOST = 'Closed Lost';
    public String query;
    public Set<Id> oppIds = new Set<Id>();
    
    //Assignment 2, overloading the method to take in a Set of Opportunity Ids
    public OpportunityBatchableAutoClose(Set<Id> oppIds) {   
        System.debug('In OpportunityBatchableAutoClose Constructor');
        
        this.oppIds = oppIds;

        query = 'SELECT Id, Name ' 
        + 'FROM Opportunity '
        + 'WHERE Id IN :oppIds';
        
    }

    //Setting up our query to Grab older Opportunities 
    //whose StageName doesn't equal Closed Won or Closed Lost
    public OpportunityBatchableAutoClose() {   
        System.debug('In OpportunityBatchableAutoClose Constructor');

        query = 'SELECT Id, Name ' 
        + 'FROM Opportunity '
        + 'WHERE CloseDate < TODAY '
        + 'AND StageName != :CLOSED_WON '
        + 'AND StageName != :CLOSED_LOST';
        
    }

    //Processing our query we created
    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        System.debug('In CloseOpportunitiesBatch start() method');
        Database.QueryLocator queryLocator = Database.getQueryLocator(query);
        return queryLocator;

    }

    //Main logic, updating those Opportunities and 
    //marking Auto Close as true and StageName to Closed Lost
    public void execute(Database.BatchableContext batchContext, List<Opportunity> oppList) {
        
        System.debug('In CloseOpportunitiesBatch execute() method');

        for (Opportunity opp : oppList) {
            opp.Auto_Closed__c = true;
            opp.StageName = CLOSED_LOST;
            
        }
        
        update oppList;

        System.debug('oppList.size(): ' + oppList.size());
        
    }

    //Letting us know we are down
    public void finish(Database.BatchableContext batchContext) { 

        System.debug('In OpportunityBatchableAutoClose finish()');

    }


    // ***** Shcedulable Context *****

    //Schedules the non-parameterized OpportunityBatchableAutoClose method
    public void execute(SchedulableContext SC) {
        OpportunityBatchableAutoClose batchJob = new OpportunityBatchableAutoClose();
        Id jobId = Database.executeBatch(batchJob);  
    }

}