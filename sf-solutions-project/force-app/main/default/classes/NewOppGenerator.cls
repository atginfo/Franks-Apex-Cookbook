//Checkpoint 3 Class 1. Batchable and Schedulable
public with sharing class NewOppGenerator implements Database.Batchable<sObject>, Schedulable {
    
    //Class variables used in methods
    final String CLOSED_WON = 'Closed Won';
    final String CLOSED_LOST = 'Closed Lost';
    final Boolean isTeamLead = true;
    String query;

    public NewOppGenerator() {
        System.debug('In NewOppGenerator Constructor');

        //Pull Accounts where Active Buyer is marked True and pull related Opportunities and Team Members
        //Accounts who have Open Opportunities (Not Closed Won or Lost)
        //And have Team Members who's Team Leader is marked as True
        query = 'SELECT Id, ' +
            '(SELECT Id, StageName FROM Opportunities ' +
            'WHERE StageName != :CLOSED_WON AND StageName != :CLOSED_LOST), ' +
            '(SELECT Name, Preferred_Table_Tennis_Grasp__c, Team_Leader__c, ' +
            'Team_Member__c, Team_Member__r.Id ' +
            'FROM Team_Members__r WHERE Team_Leader__c = :isTeamLead) ' +
        'FROM Account ' +
        'WHERE Active_Buyer__c = TRUE ';
        
    }

    //Feeding our query into the Database.QueryLocator
    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        System.debug('In NewOppGenerator start()');
        Database.QueryLocator queryLocator = Database.getQueryLocator(query);
        return queryLocator;
    
    }

    public void execute(Database.BatchableContext batchContext, List<Account> accountList) {
        
        System.debug('In NewOppGenerator execute()');
        
        //Getting details from within the execute method
        AsyncApexJob asyncJob = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed
            FROM AsyncApexJob 
            WHERE Id = :batchContext.getJobId()
            LIMIT 1
        ];

        System.debug('AsyncJob: ' + asyncJob);

        List<Opportunity> newOpps = new List<Opportunity>();

        //Looping through the Accountlist from the Query
        //*Remember when referencing fields from subqueries use index to reference them*
        for (Account acc : accountList) {
            
                //New Opportunity related to Account
                Opportunity opp = new Opportunity();
                opp.AccountId = acc.Id;
                //Using the Team Leaders Name combined with Opportunity
                opp.Name      = acc.Team_Members__r[0].Name + ' - Opportunity';  
                //StageName is based on Table Tennis Preferred Grasp
                opp.StageName = graspStageName(acc.Team_Members__r[0].Preferred_Table_Tennis_Grasp__c);
                opp.CloseDate = Date.today().addDays(30);
                //Owner of Opportunity is based on the User Id of the Team Leader *change Team_Member__c 
                opp.OwnerId   = acc.Team_Members__r[0].Team_Member__r.Id;
                newOpps.add(opp);
            
        }

        //Inserting the list of new opportunities if not empty
        if (!newOpps.isEmpty()) {
            insert newOpps;
        }

    }

    public void finish(Database.BatchableContext batchContext) {     
        System.debug('In NewOppGenerator finish()');

    }

    /******************** Schedulable *********************/

    public void execute(SchedulableContext SC) {
        NewOppGenerator batchJob = new NewOppGenerator();
        Id jobId = Database.executeBatch(batchJob);  
    }

    //Helper Method, Assigns StageName based on Preferred Table Tennis Grasp
    public static String graspStageName(String grasp) {

        String stageName;

        switch on grasp {
            when 'Penholder' {
                stageName = 'Prospecting';
            }
            when 'Shakehand' {
                stageName = 'Qualification';
            }
            when 'Chinese Penhold' { 
                stageName = 'Needs Analysis';
            } 
            when 'Reverse Backhand' {
                stageName = 'Id. Decision Makers';
            }
            when 'Korean Grip' {
                stageName = 'Perception Analysis';
            }
        }

        return stageName;
    }

    /*
        //In Execute Anonymous
        //Scheduling for every Monday Morning at 5 am
        NewOppGenerator myJob = new NewOppGenerator();
        String cronExpression = '0 0 5 ? * MON *';
        String jobID = System.schedule('NewOppGenerator Schedulabled', cronExpression, myJob);
    */
}