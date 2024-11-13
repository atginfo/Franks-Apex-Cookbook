//Assignment 3.
@isTest
public class ContactTriggerHandlerTest {
    
    //Creating two with Two different Industries to be used in test methods
    @TestSetup
    static void setup(){
        
        List<Account> accsToInsert = new List<Account>();

        Account testAccount1 = new Account();
        testAccount1.Name = 'Consulting Account';
        testAccount1.Industry = 'Consulting';
        accsToInsert.add(testAccount1);

        Account testAccount2 = new Account();
        testAccount2.Name = 'Energy Account';
        testAccount2.Industry = 'Energy';
        accsToInsert.add(testAccount2);

        insert accsToInsert;

    }

    @isTest
    static void updateContactFields(){

        //Querying for those test accounts
        List<Account> accs = [SELECT Id, Industry FROM Account];

        //Instantiating Account variables based on each Industry
        Account consultingAccount;
        Account energyAccount;

        //Looping through the list from the query and assigning each respective account to their industry variable
        for (Account acc : accs) {
            if (acc.Industry == 'Consulting') {
                consultingAccount = acc;

            } else if (acc.Industry == 'Energy') {
                energyAccount = acc;

            }
        }

        /** 
        Test 1: Making sure other city field is stamped with MailingCity and that if the AccountId is populated, 
        the Account industry is brought over from the Account
        */

        //Making sure our new Contact has required fields filled in as well as MailingCity and AccountId populated
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Email = 'tester@company.com';
        testContact.MailingCity = 'Tampa';
        testContact.AccountId = consultingAccount.Id;
        insert testContact;

        testContact = [SELECT Id, OtherCity, Account_Industry__c FROM Contact LIMIT 1];

        //Checking if OtherCity matches MailingCity
        System.assertEquals('Tampa', testContact.OtherCity, 'Other city not updated upon insert');
        //Checking if Account Industry was populated from the related Account
        System.assertEquals('Consulting', testContact.Account_Industry__c, 'Account Industry not udpated upon insert');

        /** 
        Test 2: Ensuring that when Mailing City is changed, the Other City is changed.
        Also testing if when the AccountId is changed, the Account Industry is updated as well
        */

        //Minor update to MailingCity and to the related Account
        testContact.MailingCity = 'Fort Myers';
        testContact.AccountId = energyAccount.Id;
        update testContact;

        testContact = [SELECT Id, OtherCity, Account_Industry__c FROM Contact LIMIT 1];

        //Checking if the changes happened to the OtherCity and related Account fields
        System.assertEquals('Fort Myers', testContact.OtherCity, 'Other city not updated upon update');
        System.assertEquals(
            'Energy', 
            testContact.Account_Industry__c, 
            'Account Industry not udpated with new Account information'
        );

        /**
        Test 3: Ensure that when the Account Lookup is removed, the Account Industry is also removed 
         */

        //Updating to remove the related Account
        testContact.AccountId = null;
        update testContact;

        testContact = [SELECT Id, Account_Industry__c FROM Contact LIMIT 1];

        //Checking to make sure the Account Industry was also removed
        System.assert(
            testContact.Account_Industry__c == null,
            'Account Industry was not removed when Account lookup is removed'
        );

    }

    @isTest
    static void updateDescription(){

        /**
        Test 1: Ensure that when a Contact is inserted, the Description is udpated to the Contact's Id
         */

        // Query out Account record created in the TestSetup
        Account testAccount = [
            SELECT Id 
            FROM Account
            WHERE Industry = 'Consulting' 
            LIMIT 1
        ];

        //Making sure that this new contact has an Account associated with it to avoid error upon insert
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.AccountId = testAccount.Id;
        insert testContact;

        testContact = [SELECT Id, Description FROM Contact LIMIT 1];

        //Checking if the Description contains the Contact record ID
        System.assertEquals(testContact.Id, testContact.Description, 'Description was not updated to Contact record Id.');

    }

    @isTest
    static void updateRelatedAccount(){

        //Querying for those test accounts
        List<Account> accs = [SELECT Id, Industry FROM Account];

        //Instantiating Account variables based on each Industry
        Account consultingAccount;
        Account energyAccount;

        //Looping through the list from the query and assigning each respective account to their industry variable
        for (Account acc : accs) {
            if (acc.Industry == 'Consulting') {
                consultingAccount = acc;

            } else if (acc.Industry == 'Energy') {
                energyAccount = acc;

            }
        }

        /**
         * Test 1: Ensuring that upon insert, related Account has the Primary Contact lookup field populated
         */

         //Making sure our new Contact has required fields filled in as well as Title is Owner
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Email = 'tester@company.com';
        testContact.MailingCity = 'Tampa';
        testContact.Title = 'Owner';
        testContact.AccountId = consultingAccount.Id;
        insert testContact;

        //Querying for the Account with new updated fields
        consultingAccount = [
            SELECT Id, Primary_Contact__c, Primary_Contact_Email__c
            FROM Account
            WHERE Id = :consultingAccount.Id
            LIMIT 1
        ];

        //Checking if the Primary Contact is associated with the related Contact
        System.assertEquals(
            testContact.Id,
            consultingAccount.Primary_Contact__c,
            'Primary Contact was not updated on related Account insert'
        );

        /**
         * Test 2: ensuring that when the AccountId is changed on a Contact,
         * the previous Account has the Primary Contact lookup field removed.
         */

         //Switching related Accounts on the Contact
        testContact.AccountId = energyAccount.Id;
        update testContact;

        //Grabbing the Account after the update
        consultingAccount = [
            SELECT Id, Primary_Contact__c, Primary_Contact_Email__c
            FROM Account
            WHERE Id = :consultingAccount.Id
            LIMIT 1
        ];

        //Checking that when a Contact's related Account changes, 
        //the previous Account's Primary Contact is removed
        System.assert(
            consultingAccount.Primary_Contact__c == null,
            'Primary Contact was not removed from related Account update.'
        );

        /**
         * Test 3: Ensuring that when the Email on a Contact is changed, the related
         * Account's Primary Contact Email is changed
         */

         //Updating the Contact's email
        testContact.Email = 'newtest@company.com';
        update testContact;

         //Grabbing the Account after the update
        energyAccount = [
            SELECT Id, Primary_Contact__c, Primary_Contact_Email__c
            FROM Account
            WHERE Id = :energyAccount.Id
            LIMIT 1
        ];

        //Checking if Related Account Primary Contact Email is changed as well
        System.assertEquals(
            testContact.Email,
            energyAccount.Primary_Contact_Email__c,
            'Related Account Primary Contact Email was not updated along with Contact update'
        );

        /**
         * Test 4: Ensuring that when a new Contact is created and associated to the same Account,
         * if the existing Contact has a title of "Owner", do not overwrite the Primary Contact.
         */

         //This contact will not be the title of Owner
        Contact testContact2 = new Contact();
        testContact2.FirstName = 'Dummy';
        testContact2.LastName = 'Data';
        testContact2.AccountId = energyAccount.Id;
        insert testContact2;

        energyAccount = [
            SELECT Id, Primary_Contact__c, Primary_Contact_Email__c
            FROM Account
            WHERE Id = :energyAccount.Id
            LIMIT 1
        ];

        //Checking that this new Contact who is not Owner doesn't change the Primary Contact on the related Account
        System.assertNotEquals(
            testContact2.Id,
            energyAccount.Primary_Contact__c,
            'The Contact with a title of Owner was removed from the related Contact.'
        );
    }
}