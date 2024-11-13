//Checkpoint 1 class 2
public class DealGenerator {

    //Creating opportunities for Accounts w/o ones and Updating those that do
    public static List<Opportunity> createOpportunities() {
        
        //Setting up current Month variable used later on
        String currentMonthStr = Datetime.now().format('MMMM');        
        List<Opportunity> oppsToInsert = new List<Opportunity>();

        //Map of Accounts and their Opportunities
        Map<Id, Account> notColdAccsMap = new Map<Id, Account>([
            SELECT Id, Name, Rating, NumberOfEmployees,
            (
                SELECT Id, Name
                FROM Opportunities
            )
            FROM Account 
            WHERE Rating = 'Warm' OR Rating = 'Hot'
        ]);

        //Looping through list of Warm and Hot accounts 
        for (Account acc : notColdAccsMap.values()) {

            //If the Account does not have a related opportunity, create one for them 
            if (!notColdAccsMap.get(acc.Id).Opportunities.isEmpty()) {

                //Warm Accounts receive Qualification Opportunities
                if (acc.Rating == 'Warm') {
                   oppsToInsert.add(new Opportunity(
                    Name = acc.Name + '-' + currentMonthStr,
                    AccountId = acc.Id,
                    StageName = 'Prospecting',
                    CloseDate = date.today().addDays(30)   
                )); 

                }
                //Hot Accounts receive Qualifcation Opportunities
                if (acc.Rating == 'Hot') {
                   oppsToInsert.add(new Opportunity(
                    Name = acc.Name + '-' + currentMonthStr,
                    AccountId = acc.Id,
                    StageName = 'Qualification',
                    CloseDate = date.today().addDays(30)  
                )); 
                }                
            } 
        }

        if (!oppsToInsert.IsEmpty()) {
            insert oppsToInsert;
        }
        
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        //Queueing for all the new opportunities with Hot and Warm Accounts
        List<Opportunity> oppsWithAccs = [
            SELECT Id, Name, StageName, 
            CloseDate, Account.Rating, Account.NumberOfEmployees 
            FROM Opportunity
            WHERE Account.Rating = 'Warm' OR Account.Rating = 'Hot'
        ];
        
        //Looping through the exisitng related Opportunities and checking for Warm or Hot rating
        for (Opportunity opp : oppsWithAccs) {
            
            //If the StageName is not Closed Won or Closed Lost AND 
            //CloseDate is in the future, change to 30 days from today
            if ((opp.StageName != 'Closed Won' || opp.StageName != 'Closed Lost') 
                && (opp.CloseDate > date.today())) {

                opp.CloseDate = date.today().addDays(30);
            }

            //Warm Account Rating = Prospecting Opportunity StageName
            if (opp.Account.Rating == 'Warm') {

                opp.StageName = 'Prospecting';
            
            //Hot Account Rating = Qualifciation Opportunity StageName    
            } else if (opp.Account.Rating == 'Hot') {

                opp.StageName = 'Qualification';
            }

            oppsToUpdate.add(opp);
            
        }

        if(!oppsToUpdate.IsEmpty()) {
            update oppsToUpdate;

        }
        
        //New List to consolidate both lists created above into one
        List<Opportunity> opps = new List<Opportunity>();

        //Looping through both lists and adding those opportunities to a combined opportunity list
        for (Opportunity opp : oppsToInsert) {
            opps.add(opp);
        }
        for (Opportunity opp2 : oppsToUpdate) {
            opps.add(opp2);
        }
        
        return opps;
    }

    //Method that generates Tasks based off Opportunities made above
    public static List<Task> createTasks(List<Opportunity> oppList) {

        List<Task> relatedTasks = new List<Task>();

        for (Opportunity opp : oppList) {

            //Checking for Opportunities with Qualification stage
            if (opp.StageName == 'Qualification') {
                
                //Above 750 Employees receive High Priority Tasks
                if (opp.Account.NumberOfEmployees > 750) {
                    relatedTasks.add(new Task(
                        WhatId = opp.AccountID,
                        Status = 'Not Started',
                        Subject = opp.Name,
                        Priority = 'High',
                        OwnerId = UserInfo.getUserId()
                    ));
                // Sub 750 Employees receive Normal Priority Tasks    
                } else {
                    relatedTasks.add(new Task(
                        WhatId = opp.AccountID,
                        Status = 'Not Started',
                        Subject = opp.Name,
                        Priority = 'Normal',
                        OwnerId = UserInfo.getUserId()
                    ));

                }
            }
        }

        if(!relatedTasks.IsEmpty()){
            insert relatedTasks;
        }
        
        return relatedTasks;
    }

    //Method that uses both above methods
    public static List<Task> createDeals() {

        //This list stores the returned list of opportunities created and updated
        List<Opportunity> oppList = createOpportunities();
        
        //This list stores all of those created tasks for those opportunities
        List<Task> taskList = createTasks(oppList);
        
        return taskList;
    }
}