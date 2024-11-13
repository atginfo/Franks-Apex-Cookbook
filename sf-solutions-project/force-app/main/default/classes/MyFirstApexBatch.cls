public class MyFirstApexBatch implements Database.Batchable<sObject>, Schedulable {

    //Added the Account Industry as a class string since the query was not able to access 
    //the variable from the method
    String accountIndustry;
    String query;

    //We use Dyanmic SOQL in the Start Method so we place a query in a string and assign it to 
    //the public instance
    public MyFirstApexBatch(String accountIndustry) {
        this.accountIndustry = accountIndustry;
        System.debug('In MyFirstApexBatch Constructor');
        query = 'SELECT Id FROM Account WHERE Industry = :accountIndustry';
        
    }

    //First of the Batchable methods, runs one time and returns the Database.QueryLocator
    public Database.QueryLocator start(Database.BatchableContext batchContext) {

        System.debug('In MyFirstApexBatch start()');
        //we feed the Database.getQueryLocator the query from our earlier method
        Database.QueryLocator queryLocator = Database.getQueryLocator(query);
        return queryLocator;
    
    }

    //Second of the Batchable Methods, runs as many times as it takes to process all records
    //returned from Database.querylocator. Runs your main logic in the code
    public void execute(Database.BatchableContext batchContext, List<Account> accountList) {
        
        System.debug('In MyFirstApexBatch execute()');
        System.debug('accountList.size() ' + accountList.size());
        
        //Getting details from within the execute method
        AsyncApexJob asyncJob = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed
            FROM AsyncApexJob 
            WHERE Id = :batchContext.getJobId()
            LIMIT 1
        ];

        System.debug('AsyncJob: ' + asyncJob);

        for (Account acc : accountList) {
            // Perform logic
        }

    }

    //Third and Final Batchable Methods, runs after all records have been processed in one or more execute methods
    //Sends confirmation emails or any post processing operations.
    //If you're chaining another batch job, you kick it off here
    public void finish(Database.BatchableContext batchContext) {
        
        System.debug('In MyFirstApexBatch finish()');

    }

    /******************** Schedulable *********************/

    //New edition to this Class which allows it to execute this batch on a scheduled basis
    //Use of method overloading to have a separate execute method
    //System.schedule() method still required in Execute Anonymous windo
    public void execute(SchedulableContext SC) {
        MyFirstApexBatch batchJob = new MyFirstApexBatch('Technology');
        Id jobId = Database.executeBatch(batchJob);  
    }

    /*
     In Anonymous Apex Window 
        MyFirstApexBatch batchJob = new MyFirstApexBatch('Technology');
        Id jobId = Database.executeBatch(batchJob, 5);

    Where we can grab the details of the job when its done
        AsyncApexJob jobInfo = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob WHERE Id =:jobId LIMIT 1];
        System.debug('JobInfo: ' + jobInfo);

    When using callouts use Database.AllowCallouts when instantiating the Class
        public class CalloutApexClass implements Database.Batchable<sObject>, Database.AllowsCallouts {
            ...
        }
    
    When planning to schedule this batch, CRON expression is everyday at 2:30 pm    
        MyFirstApexBatch myJob = new MyFirstApexBatch();
        String cronExpression = '0 30 14 * * ?';
        String jobID = System.schedule('MyFirstApexBatch in a Schedulable!', cronExpression, myJob);
    
    Used when monitoring a Scheduled Apex
        CronTrigger cron = [
            SELECT Id, CronExpression, TimesTriggered, State, NextFireTime,
            PreviousFireTime, StartTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];

    */

}