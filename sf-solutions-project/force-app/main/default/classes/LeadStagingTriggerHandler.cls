public with sharing class LeadStagingTriggerHandler {

    public static void afterInsertMethod(List<Lead_Staging__c> newList){
        convertToLeads(newList);
    }

    private static void convertToLeads(List<Lead_Staging__c> newList){
        
        LeadStagingToLeadsQueueable queueableJob = new LeadStagingToLeadsQueueable(newList);
        Id jobId = System.enqueueJob(queueableJob);
        
        AsyncApexJob jobInfo = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob WHERE Id = :jobId];
        System.debug('LeadStagingToLeadsQueueable Job Info: ' + jobInfo);

    }

}