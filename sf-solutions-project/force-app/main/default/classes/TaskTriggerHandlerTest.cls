//Section 3.2. Assignment 
@isTest
private class TaskTriggerHandlerTest {

    @TestSetup
    static void setUp(){

        //Creating tasks to be updated later
        List<Task> taskList = new List<Task>();

        Task task1 = new Task();
        task1.Status = 'Not Started';
        task1.Description = 'Test 1';
        task1.Subject = 'Test 1';
        taskList.add(task1);

        Task task2 = new Task();
        task2.Status = 'Not Started';
        task2.Description = 'Test 2';
        task2.Subject = 'Test 2';
        taskList.add(task2);

        insert taskList;
        
    }

    @isTest
    static void testFutureMethod(){

        // Reset the Current User's Number of Completed Tasks to 0
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        currentUser.Number_of_Completed_Tasks__c = 0;
        update currentUser;

        //Query back our Tasks
        List<Task> taskList = [SELECT Id FROM Task];

        for (Task task : taskList) {
            task.Status = 'Completed';
        }

        Test.startTest();

        //Updating the status of Tasks to Completed
        update taskList;

        Test.stopTest();

        //Re-query our user and their Number of Completed Tasks
        currentUser = [
            SELECT Id, Number_of_Completed_Tasks__c 
            FROM User 
            WHERE Id = :currentUser.Id
            LIMIT 1
        ];

        //Testing to see if the NOCTs has updated to 2
        System.assertEquals (
            2,
            currentUser.Number_of_Completed_Tasks__c,
            '# of Completed Tasks not updated to 2 as expected'
        );
    }
}