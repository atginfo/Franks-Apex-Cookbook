//Checkpoint 1 class 3
public with sharing class ReportHelper {

    //Creates Report answering several questions from Checkpoint 1
    public static void generateSummary(List<Task> taskList) {

        //Hot or Warm Accounts
        List<Account> notColdAccounts = [
            SELECT Id, Name, Rating, NumberOfEmployees
            FROM Account 
            WHERE Rating = 'Warm' OR Rating = 'Hot'
        ];
        
        //Setting up Integers to hold a count of either Prospecting or Qualificaition Opportunities
        Integer prospectingCount = 0;
        Integer qualificationCount = 0;

        //Pull Either Prospecting or Qualification opportunities that were modified today
        List<Opportunity> prosOrQualOpps = [
            SELECT Id, Name, StageName, LastModifiedDate
            FROM Opportunity
            //Parenthesis between the OR and AND is necessary for SOQL queries. Prevents confusion
            WHERE (StageName = 'Prospecting' OR StageName = 'Qualification') AND LastModifiedDate = TODAY 
        ];

        //Looping through the list to increment up the corresponding variable to StageName
        for (Opportunity opp : prosOrQualOpps) {
            If (opp.StageName == 'Prospecting') {
                prospectingCount++;

            } else if (opp.StageName == 'Qualification') {
                qualificationCount++;

            }
        }

        //Using Tasklist to query Tasks created today
        List<Task> tasksToday = [
            SELECT Id, CreatedDate
            FROM Task
            WHERE Id IN :taskList AND CreatedDate = TODAY
        ];
        
        //Using Tasklist to query for Customer Direct Accounts    
        List<Task> tasksWithCustDirAccs = [
            SELECT Id, Account.Type
            FROM Task
            WHERE Id IN :taskList AND Account.Type = 'Customer-Direct'
        ]; 
        
        //Using Tasklist to query for High Priority Tasks    
        List<Task> highPriTasks = [
            SELECT Id, Priority, Account.NumberOfEmployees
            FROM Task
            WHERE Id IN :taskList AND Priority = 'High'
        ];
        
        //Variables to store data from loop *changing this into an IF statement
        Integer totalHighPriTasks = highPriTasks.size();
        Integer numEmployeesHighPri = 0;

        //Adding up every number of employees per high priority task
        for (Task t : highPriTasks) {
                numEmployeesHighPri = numEmployeesHighPri + t.Account.NumberOfEmployees;
        }


        //Printing out report
        System.debug('Total amount of Warm and Hot Accounts: ' + notColdAccounts.size());
        System.debug('Total Prospecting Opportunities created today: ' + prospectingCount);
        System.debug('Total Qualification Opportunities created today: ' + qualificationCount);
        System.debug('Total Tasks made today: ' + tasksToday.size());
        System.debug('Total related Accounts to this Tasklist with Customer-Direct: ' + tasksWithCustDirAccs.size());
        
        //Exception handling to make sure we catch a possible divide by zero exception
        try {
            System.debug('Average number of employees of High Priority Accounts related to this Tasklist: ' + numEmployeesHighPri/totalHighPriTasks);
        
        } catch(MathException e) {
            System.debug('The list size came out to zero which caused this exception: ' + e.getMessage());

        }   
    }
}