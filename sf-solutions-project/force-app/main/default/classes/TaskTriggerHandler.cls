//Section 3.2. Assignment 
public with sharing class TaskTriggerHandler {

    public static void beforeUpdateMethod(List<Task> newList, Map<Id, Task> oldMap){
        checkStatus(newList, oldMap);
    }

    /****************** Helper Methods *****************/

    //Grabs the updated Completed Tasks and calls our Future Method
    private static void checkStatus(List<Task> newList, Map<Id, Task> oldMap){

        Set<Id> completedTaskIds = new Set<Id>();

        for (Task task : newList) {

            if (task.Status == 'Completed' && task.Status != oldMap.get(task.Id).Status) {
                completedTaskIds.add(task.Id);
            }

        }

        //Checking to make sure the Set of Ids is not empty and 
        //then using it as the parameter for our Future method
        if (!completedTaskIds.isEmpty()) {
            completeTasks(completedTaskIds);
        }

    }

    //Calls all of the Helper methods in Asynchronous Context
    @Future
    private static void completeTasks(Set<Id> completedTaskIds) {

        Map<Id, User> userMap = new Map<Id, User>();

        // Requery task records and get the Last Modified User's details
        List<Task> completedTasks = [
            SELECT Id, Subject, LastModifiedById, LastModifiedBy.Name, LastModifiedBy.ManagerId, 
            LastModifiedBy.Manager.Email, LastModifiedBy.Number_of_Completed_Tasks__c 
            FROM Task 
            WHERE Id IN :completedTaskIds
        ];

        for (Task task : completedTasks) {

            //Sending an email to the User who last modified the record's Manager
            sendEmailToManager(task);

            // Update the Number of Completed Task on the related User record
            User user = updateUsersCompletedTaskCount(task, userMap);

            // Populate Map where Id is the key and the value is the User
            userMap.put(user.Id, user);

        }

        // Update User records
        if (!userMap.isEmpty()) {
            update userMap.values();
        }

    }

    /*********************** Additional Helper Method ***********************/

    //Checks to make sure User has a Manager with valid Email and called sendEmail Method
    private static void sendEmailToManager(Task task){

        if (task.LastModifiedBy.ManagerId != null && task.LastModifiedBy.Manager.Email != null) {
            sendEmail(task);
        }

    }

    //Sending Email to Manager of User who completed the Task
    private static void sendEmail(Task task) {

        //Instantiate new instance of email message
        Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
        
        //String for the subject of email
        String subject = task.LastModifiedBy.Name + ' has completed a Task!';

        //Calling various methods of emailMessage class and adding specific details
        emailMessage.setTargetObjectId(task.LastModifiedBy.ManagerId);
        emailMessage.setToAddresses(new List<String>{task.LastModifiedBy.Manager.Email});
        emailMessage.setSenderDisplayName('Task Helper Buddy'); 
        emailMessage.setUseSignature(false);
        emailMessage.setSaveAsActivity(false); 
        emailMessage.setSubject(subject);
        emailMessage.setPlainTextBody('Yay!');

        //Creating a list to house results of email being sent
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {emailMessage});
 
        //Checking for whether email was sent successfully or not
        if (results[0].success) {
            System.debug(logginglevel.DEBUG,'The email was sent successfully.');
        } else {
            System.debug(logginglevel.DEBUG,'The email failed to send: ' +  results[0].errors[0].message);
        }

    }

    //Updating the User's Number of Completed Tasks
    private static User updateUsersCompletedTaskCount(Task task, Map<Id, User> userMap){

        // Create new instance of User record to update
        User user = new User();

        // If the Map doesn't already have this User record, update instance of User record with existing values
        if (!userMap.containsKey(task.LastModifiedById)) {
            user.Id = task.LastModifiedById;
            user.Number_of_Completed_Tasks__c = task.LastModifiedBy.Number_of_Completed_Tasks__c;
            
        // Otherwise, if the Map has this User record (Another task was completed), the get the User in the Map
        } else {
            user = userMap.get(task.LastModifiedById);
        }

        // If the Number of Completed Tasks is greater than 0, increment by 1
        if (user.Number_of_Completed_Tasks__c > 0) {
            user.Number_of_Completed_Tasks__c++;
        // Otherwise, default Number of Completed Tasks to 1
        } else {
            user.Number_of_Completed_Tasks__c = 1;
        }

        return user;
    }

}