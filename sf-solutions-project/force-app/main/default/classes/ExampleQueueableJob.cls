//Make sure to implement the Queueable interface when creating Queueable classes
public class ExampleQueueableJob implements Queueable {

    //We declare this String as a class variable when we want to pass it from Constructor to execute() method
    public String myName;

    //This Method is overloading the original ExampleQueueableJob(), Takes no parameters
    public ExampleQueueableJob(){
        this('Peeta Mellark');
        System.debug('ExampleQueueableJob Constructor: No Parameters');
        //The this keyword differentiates a local variable and a Class level variable, 
        //its the current instance of the Apex Class
    }

    //Passing values to the Constructor, then when we instantiate it we can pass in the String parameter 
    //to ExampleQueueableJob()
    public ExampleQueueableJob(String myName){
        System.debug('ExampleQueueableJob Constructor: String Parameter: ' + myName);
        //this is used to chain constructors as well
        this.myName = myName;
    }

    //the execute method is also essential in running the asynchronous context, parameter should be QueueableContext data type
    public void execute(QueueableContext context) {
        System.debug('Hello world from the execute() method - myName: ' + myName);

        // Get Job Id and log out details by using AsyncApexJob record Id to track the progress of the Queueable
        Id jobId = context.getJobId();
        AsyncApexJob jobInfo = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob WHERE Id =:jobId LIMIT 1];
        System.debug('ExampleQueueableJob JobInfo: ' + jobInfo);
    }

    /*
    When you need to run Queueable make sure to use System.enqueueJob();
        In Anonymous Apex Window 
        System.debug('In Anonymous Apex Window - Kicking off Queueable');
        ExampleQueueableJob queueableJob = new ExampleQueueableJob();
        System.enqueueJob(queueableJob);
        System.enqueueJob(new ExampleQueueableJob()); Also works too

    Instantiating with String parameter    
        System.debug('In Anonymous Apex Window - Kicking off Queueable');
        ExampleQueueableJob queueableJob = new ExampleQueueableJob('Katniss Everdeen');
        System.enqueueJob(queueableJob);
    */
    
}