public class MyFirstScheduleable implements Schedulable {

    String industry;
    
    public MyFirstScheduleable(String industry) {
        this.industry = industry;
    }

   public void execute(SchedulableContext SC) {
        MyFirstApexBatch batchJob = new MyFirstApexBatch(industry);
        Id jobId = Database.executeBatch(batchJob);  
   }

   /**
    * 
    Using Execute Anonymous to schedule our Schedulable Apex Batch
    We instantiate the Schedulable class with its parameter then create a cronExpression
    Once we execute the job pops up in our Apex Scheduled Jobs in Setup

        MyFirstScheduleable mySchedulable = new MyFirstScheduleable('Entertainment');
        String cronExpression = '0 30 14 * * ?';
        String jobID = System.schedule('MyFirstSchedulable!', cronExpression, mySchedulable);

    Remember if we want to modify this code further, we have to delete any scheduled jobs in Setup

    */

}