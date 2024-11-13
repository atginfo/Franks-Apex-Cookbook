@isTest
private class LeadStagingTriggerHandlerTest {

    @TestSetup
    static void setup(){

        List<Lead_Staging__c> leadStagingList = new List<Lead_Staging__c>();
        
        // Create valid Lead Staging with "High" Interest Level
        Lead_Staging__c highInterestLeadStaging = new Lead_Staging__c();
        highInterestLeadStaging.Name__c = 'Lisbeth Salander';
        highInterestLeadStaging.Email__c = 'wasp@HackerRepublic.com';
        highInterestLeadStaging.Phone__c = '071-334-8475';
        highInterestLeadStaging.Street__c = 'Fiskargatan 9';
        highInterestLeadStaging.City__c = 'Stockholm';
        highInterestLeadStaging.Zip__c = '113 51';
        highInterestLeadStaging.Country__c = 'Sweden';
        highInterestLeadStaging.Interest_Level__c = 'High';
        highInterestLeadStaging.Company__c = 'Milton Security';
        leadStagingList.add(highInterestLeadStaging);

        // Create valid Lead Staging with "Medium" Interest Level
        Lead_Staging__c medInterestLeadStaging = new Lead_Staging__c();
        medInterestLeadStaging.Name__c = 'Wade Watts';
        medInterestLeadStaging.Email__c = 'parzival@oasis.com';
        medInterestLeadStaging.Street__c = 'Portland Avenue Stacks 539AZL-4';
        medInterestLeadStaging.City__c = 'Oklahoma City';
        medInterestLeadStaging.Street__c = 'Oklahoma';
        medInterestLeadStaging.Country__c = 'United States';
        medInterestLeadStaging.Interest_Level__c = 'Medium';
        medInterestLeadStaging.Company__c = 'Self-Employed';
        leadStagingList.add(medInterestLeadStaging);

        // Create valid Lead Staging with "Low" Interest Level
        Lead_Staging__c lowInterestLeadStaging = new Lead_Staging__c();
        lowInterestLeadStaging.Name__c = 'Angela Abar';
        lowInterestLeadStaging.Email__c = 'sister.night@tpd.com';
        lowInterestLeadStaging.Phone__c = '918-447-8639';
        lowInterestLeadStaging.Street__c = '544 Philli Lane';
        lowInterestLeadStaging.City__c = 'Tulsa';
        lowInterestLeadStaging.Street__c = 'Oklahoma';
        lowInterestLeadStaging.Zip__c = '74107';
        lowInterestLeadStaging.Country__c = 'United States';
        lowInterestLeadStaging.Interest_Level__c = 'Low';
        lowInterestLeadStaging.Company__c = 'Tulsa Police Department';
        leadStagingList.add(lowInterestLeadStaging);

        // Create invalid Lead Staging with missing Company
        Lead_Staging__c missingInfoLeadStaging = new Lead_Staging__c();
        missingInfoLeadStaging.Name__c = 'Dolores Abernathy';
        missingInfoLeadStaging.Email__c = 'd.abernathy@ww.com';
        missingInfoLeadStaging.Country__c = 'United States';
        missingInfoLeadStaging.Interest_Level__c = 'High';
        leadStagingList.add(missingInfoLeadStaging);

        Test.startTest();
        insert leadStagingList;
        Test.stopTest();
    }

    /****************************** Test Methods ******************************/

    /**
     * @description: Confirm that a Queueable is kicked off after a new Lead Staging records are created
     */
    @isTest
    static void convertToLeadsTest(){

        List<AsyncApexJob> jobInfo = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob];
        System.assertEquals(1, jobInfo.size());

    }

    /**
    * @description: Test LeadStagingToLeadsQueueable. Confirm that a Lead Record is created 
    * when a new Lead Staging record is inserted
    */
    @isTest
    static void leadStagingToLeadsQueueableTest(){

        List<Lead> leadList = [SELECT Id, Name FROM Lead];
        System.assertEquals(3, leadList.size(), '3 Leads were not created as expected');

    }

    /**
    * @description: Test CreateTasksForLeadsQueueable. Test to ensure that only 2 Tasks were created
    * for the Lead records that had a "Hot" or "Warm" Rating.
    */
    @isTest
    static void createTasksForLeadsQueueableTest(){

        List<Lead> leadList = [SELECT Id, Name, Rating, OwnerId FROM Lead];

        Test.startTest();

        CreateTasksForLeadsQueueable queueableJob = new CreateTasksForLeadsQueueable(leadList);
        System.enqueueJob(new CreateTasksForLeadsQueueable(leadList));
        
        Test.stopTest();

        List<Task> taskList = [SELECT Id FROM Task];
        System.assertEquals(2, taskList.size(), '2 Tasks were not created as expected');

    }

}