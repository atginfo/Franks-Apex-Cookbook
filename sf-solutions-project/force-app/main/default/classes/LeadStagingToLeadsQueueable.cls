public with sharing class LeadStagingToLeadsQueueable implements Queueable {
    
    List<Lead_Staging__c> leadStagingRecords;

    public LeadStagingToLeadsQueueable(List<Lead_Staging__c> leadStagingRecords) {
        System.debug('In LeadStagingToLeadsQueueable Constructor');
        this.leadStagingRecords = leadStagingRecords;
    }

    public void execute(QueueableContext context) {
        
        System.debug('In LeadStagingToLeadsQueueable execute()');

        List<Lead> leadsToInsert = new List<Lead>();

        for (Lead_Staging__c leadStaging : leadStagingRecords) {

            List<String> nameList = parseName(leadStaging.Name__c);
            String firstName = nameList.get(0);
            String lastName = nameList.get(1);
            
            // Only create a Lead if the Last Name and Company is populated
            if (!String.isBlank(lastName) && !String.isBlank(leadStaging.Company__c)) {

                // Create new instance of a Lead
                Lead newLead = new Lead();

                // Assign First and Last Name values from parsed name
                newLead.FirstName       = firstName;
                newLead.LastName        = lastName;
    
                // Map other fields
                newLead.Company         = leadStaging.Company__c;
                newLead.Email           = leadStaging.Email__c;
                newLead.Phone           = leadStaging.Phone__c;
                newLead.Street          = leadStaging.Street__c;
                newLead.City            = leadStaging.City__c;
                newLead.PostalCode      = leadStaging.Zip__c;
                newLead.State           = leadStaging.State__c;
                newLead.Country         = leadStaging.Country__c;
                
                // Set Rating and default fields
                newLead.Rating          = getRating(leadStaging.Interest_Level__c);
                newLead.Status          = 'Open - Not Contacted';
                newLead.LeadSource      = 'CoolHandLeads';
    
                leadsToInsert.add(newLead);

            }

        }

        if (!leadsToInsert.isEmpty()) {
            
            insert leadsToInsert;

            if (!Test.isRunningTest()) { // Check to ensure we are not running in a Test Context - Can't chain Queueables in Tests
                System.enqueueJob(new CreateTasksForLeadsQueueable(leadsToInsert));
            }            

        }

    }

    /************ Helper Methods *************/

    // Helper Method that takes a String and returns a List of Strings
    private static List<String> parseName(String fullName){

        fullName = fullName == null ? '' : fullName; // Update to empty String if value is null;

        String firstName = fullName.substringBeforeLast(' '); // Will return empty String if no value is found
        String lastName  = fullName.substringAfterLast(' '); // Will return empty String if no value is found

        return new List<String>{firstName, lastName};

    }

    // Helper Method that takes an interest level and returns a rating
    private static String getRating(String interestLevel){

        String rating;

        if (interestLevel == 'High') {
            rating = 'Hot';
        } else if (interestLevel == 'Medium') {
            rating = 'Warm';
        } else {
            rating = 'Cold';
        }

        return rating;

    }

}