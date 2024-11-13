public with sharing class CreateTasksForLeadsQueueable implements Queueable {
    
    List<Lead> leadList;

    public CreateTasksForLeadsQueueable(List<Lead> leadList) {
        this.leadList = leadList;
    }

    public void execute(QueueableContext context) {
        
        List<Task> tasksToInsert = new List<Task>();

        // Loop through Leads and create a new Task for each one
        for (Lead lead : leadList) {

            Task newTask = new Task();

            newTask.Status      = 'Not Started';
            newTask.Subject     = 'Call ' + lead.Name;
            newTask.Description = 'This lead was created based on the CoolHandLeads import. Please follow up.';
            newTask.Priority    = lead.Rating == 'Hot' ? 'High' : 'Normal';
            newTask.OwnerId     = lead.OwnerId;

            tasksToInsert.add(newTask);
        
        }

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }

    }

}