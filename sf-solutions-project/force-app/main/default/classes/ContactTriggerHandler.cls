//1
public class ContactTriggerHandler {

    public static void beforeInsertMethod(List<Contact> newList){
        updateContactFields(newList, null);
    }

    public static void afterInsertMethod(List<Contact> newList){
        updateDescription(newList);
        updateRelatedAccount(newList, null);
    }

    public static void beforeUpdateMethod(List<Contact> newList, Map<Id, Contact> oldMap){
        updateContactFields(newList, oldMap);
    }

    public static void afterUpdateMethod(List<Contact> newList, Map<Id, Contact> oldMap){
        updateRelatedAccount(newList, oldMap);
    }

   /************** Helper Methods *****************/
   //6.
   private static void updateContactFields(List<Contact> newList, Map<Id, Contact> oldMap){
        
        Set<Id> accountIds = new Set<Id>();

        // Loop through triggered Contacts and populate Set of related Account Ids
        for (Contact contact : newList) {

            if (contact.AccountId != null) {
                accountIds.add(contact.AccountId);
            }

        }

        // Query out related Account records
        Map<Id, Account> relatedAccountMap = new Map<Id, Account>([
            SELECT Id, Industry
            FROM Account
            WHERE Id IN :accountIds
        ]);

        // Loop through triggered Contacts
        for (Contact contact : newList) {
            
            // If OldMap is null or if the MailingCity has Changed, continue
            if (oldMap == null || contact.MailingCity != oldMap.get(contact.Id).MailingCity) {

                // Update OtherCity with MailingCity value
                contact.OtherCity = contact.MailingCity;

            }

            // If oldMap is null or if the AccountId field has changed, perform logic
            if (oldMap == null || contact.AccountId != oldMap.get(contact.Id).AccountId) {

                // If the AccountId is populated, update the Account Industry field
                if (contact.AccountId != null && relatedAccountMap.containsKey(contact.AccountId)) {
                    
                    Account relatedAccount = relatedAccountMap.get(contact.AccountId);
                    contact.Account_Industry__c = relatedAccount.Industry;

                // Otherwise if the AccountId is blank, remove any value in the Account Industry field
                } else {

                    contact.Account_Industry__c = null;

                }
            }
        }
   }
   

   private static void updateDescription(List<Contact> newList){

        List<Contact> consToUpdate = new List<Contact>();

        for (Contact con : newList) {
            Contact conRecord = new Contact();
            conRecord.Id = con.Id;
            conRecord.Description = con.Id;
            consToUpdate.add(conRecord); 
        }

        if (!consToUpdate.isEmpty()){
            //updating everything that gets add to contact list in After Insert Context
            update consToUpdate;
        }
   }

   private static void updateRelatedAccount(List<Contact> newList, Map<Id, Contact> oldMap){
        
        List<Account> accountsToUpdate = new List<Account>();
        Set<Id> relatedAccountIds = new Set<Id>();

        //4.1.
        for (Contact con : newList) {

            //Get newly populated Account Id
            if (con.AccountId != null) {
                relatedAccountIds.add(con.AccountId);

            }

            //Get previously linked account Id
            if (oldMap != null && oldMap.get(con.Id).AccountId != null) {
                relatedAccountIds.add(oldMap.get(con.Id).AccountId);

            }

        }
        //4.1 Finding related accounts and their Primary Contact's title
        Map<Id, Account> accountMap = new Map<Id, Account>([
            SELECT Id, Primary_Contact__c, Primary_Contact__r.Title
            FROM Account
            WHERE Id IN :relatedAccountIds
        ]);

        for (Contact con : newList) {

            //4.1. If oldMap is not null AND Account LookupId has changed
            if (oldMap != null && con.AccountId !=  oldMap.get(con.Id).AccountId) {
                Id prevAccountId = oldMap.get(con.Id).AccountId;

                //4.1.ii. If previous accountID was not blank
                //AND previous account primary contact matched the triggered Contact, remove it
                if (prevAccountId != null && accountMap.get(prevAccountId).Primary_Contact__c == con.Id) {
                    //Creating new Account and assigning previous account Id to it
                    Account prevAccount = new Account();
                    prevAccount.Id = oldMap.get(con.Id).AccountId;
                    //Clearing the Primary Contact and Email as well
                    prevAccount.Primary_Contact__c = null;
                    prevAccount.Primary_Contact_Email__c = null;

                    accountsToUpdate.add(prevAccount);
                    
                }    
            }


            // If the oldMap is null, OR 
            //if the Account lookup has changed, OR
            //if Email has been changed, proceed
            if (oldMap == null || 
            con.AccountId != oldMap.get(con.Id).AccountId || con.Email != oldMap.get(con.Id).Email
            ) {

                //Checking to see if lookup is not blank then update the related account
                if (con.AccountId != null) {
                    
                    Account relatedAcc = accountMap.get(con.AccountId);

                    //4.1.i. If related Account Primary Contact matches, doesn't already have a Primary Contact
                    //OR if the Primary Contact is not an Owner
                    if (relatedAcc.Primary_Contact__c == con.Id ||
                        relatedAcc.Primary_Contact__c == null ||
                        relatedAcc.Primary_Contact__r.Title != 'Owner') 
                    {

                        // Create a new instance of an Account record
                        Account relatedAccount = new Account();
                        // Assign the Account Id in the lookup field to the new instance
                        relatedAccount.Id = con.AccountId;
                        // Assign the triggered Contact's Id to the Primary Contact field
                        relatedAccount.Primary_Contact__c = con.Id;
                        // #2.1 Keeping things Synced
                        relatedAccount.Primary_Contact_Email__c = con.Email;
                        // Add Account to List
                        accountsToUpdate.add(relatedAccount);

                    }
                } 
            }
        }

        if (!accountsToUpdate.isEmpty()) {

            // Update list of related Accounts
            update accountsToUpdate;
        }
    }
}