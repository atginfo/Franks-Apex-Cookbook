//Checkpoint 3 Class 4. Queueable chained from another Queuable
public class EmailTMQueueable implements Queueable {
    
    //Class variable that is used in execute method
    private List<Opportunity> parentOppList;
    //Sets prevent duplicates so that should prevent duplicate emails to the same User
    private Set<Id> oppIds = new Set<Id>();
    private Set<Id> userIds = new Set<Id>();
    
    //Our constructor which grabs the list of Opportunities from our Trigger
    public EmailTMQueueable(List<Opportunity> parentOppList) {
        this.parentOppList = parentOppList;

        //Looping through the new Opportunities and add their Ids to a Set and 
        //their OwnerIds to another Set
        for (Opportunity opp : parentOppList) {
            oppIds.add(opp.Id);
            userIds.add(opp.OwnerId);
        }
        
    }

    public void execute(QueueableContext qc) {

        //Creating a Map of Quotes related to the Opportunities in the Set
        List<SBQQ__Quote__c> relatedQuoteList = [
            SELECT Id, Name, SBQQ__Account__c, SBQQ__Account__r.Name, 
            SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.Name
            FROM SBQQ__Quote__c
            WHERE SBQQ__Opportunity2__c IN :oppIds
        ];

        //Creating a Map of Users related to Owners of the Opportunities 
        //to grab their Team Member Nicknames
        Map<Id, User> userMap = new Map<Id, User>([
            SELECT Id, Email,
            (
                SELECT Nickname__c
                FROM Team_Members__r
            )
            FROM User
            WHERE Id IN :userIds
        ]);
        
        //Looping through the new Opportunities
        for (Opportunity opp : parentOppList) {

            //Setting up a User related to the Opportunity
            User owner = userMap.get(opp.OwnerId);

            //Generating a list of Quotes specific to this Opportunity
            List<SBQQ__Quote__c> allRelatedQuotes = new List<SBQQ__Quote__c>();

            //Looping through that list of Quotes and adding to the above list if Ids match 
            for (SBQQ__Quote__c quote : relatedQuoteList) {
                if (quote.SBQQ__Opportunity2__c == opp.Id) {
                    allRelatedQuotes.add(quote);
                }
            }
            
            //Calling our sendEmail method that takes in 3 parameters
            sendEmail(opp, owner, allRelatedQuotes);   
            
        }
 
    }

    private static void sendEmail(Opportunity opp, User owner, List<SBQQ__Quote__c> relatedQuotes) {

        //Instantiate new instance of email message
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        
        //Subject line for email
        String subject = 'New Quotes Opened';
        
        //Starting our body with a friendly greeting to the uSer using their Nickname from Team Members
        //At the end we use HTML tags to create a line break and start our unordered list
        String body = 'Hello there, ' + owner.Team_Members__r[0].Nickname__c +
         '! You have new Sales Assignments assigned to you! <br><ul> ';

        //Looping through each Quote to build the Body of our message
        for (SBQQ__Quote__c quote : relatedQuotes) {

            // Url.getSalesforceBaseUrl().toExternalForm() allows us to grab the link of our Salesforce
            //Saving each link to the involved records into strings by concatenating with backslash and recordId
            String accountLink = Url.getSalesforceBaseUrl().toExternalForm() + '/' + quote.SBQQ__Account__c;
            String oppLink = Url.getSalesforceBaseUrl().toExternalForm() + '/' + quote.SBQQ__Opportunity2__c;
            String quoteLink = Url.getSalesforceBaseUrl().toExternalForm() + '/' + quote.Id;
            
            //Using HTML tags to create a bulleted list for each quote assigned to the Owner
            //
            body += '<li> Quote: <a href="' + quoteLink + '">' + quote.Name + 
                '</a> Opportunity: <a href="' + oppLink  + '">' + quote.SBQQ__Opportunity2__r.Name +
                '</a> Account: <a href="' + accountLink + '">' + quote.SBQQ__Account__r.Name +
                '</a> </ul> ';
        }

        //Closing the unordered list once the loop finishes generating the list
        body += '</ul>';

        //Calling various methods of emailMessage class and adding specific details
        emailMessage.setTargetObjectId(opp.LastModifiedBy.ManagerId);
        emailMessage.setToAddresses(new List<String>{owner.Email});
        emailMessage.setSenderDisplayName('New Quote Helper Buddy'); 
        emailMessage.setUseSignature(false);
        emailMessage.setSaveAsActivity(false); 
        emailMessage.setSubject(subject);             
        emailMessage.setHtmlBody(body);
        
        //Creating a list to house results of email being sent
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {emailMessage});
 
        //Checking for whether email was sent successfully or not
        if (results[0].success) {
            System.debug(logginglevel.DEBUG,'The email was sent successfully.');
        } else {
            System.debug(logginglevel.DEBUG,'The email failed to send: ' +  results[0].errors[0].message);
        }

    }
}