/* 
    Author: Frank Berni
    Purpose: 
    Async Apex that allows Triggers to make callout to External Systems. 
    Called after IntegrationCalloutService has ran
*/ 
public class IntegrationCalloutJob implements Queueable, Database.AllowsCallouts {
    private String endpoint;
    private Map<String, Object> payload;
    private Id recordId;
    private String objectType;

    // constructor handles SObject and saves data to class variables
    public IntegrationCalloutJob(String endpoint, Map<String, Object> payload, Id recordId, String objectType) {
        this.endpoint = endpoint;
        this.payload = payload;
        this.recordId = recordId;
        this.objectType = objectType;
    }

    public void execute(QueueableContext context) {
        // Http callout to Postman Mock Server
        Http http = new Http();
        HttpRequest req = new HttpRequest();

        // Building path based on endpoint value
        String path = (endpoint == null) ? '' : endpoint;
        System.debug(path);

        // Uses Named Credential Setup for Postman
        req.setEndpoint('callout:Postman_Mock' + endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(payload));

        System.debug('IntegrationCalloutJob request body: ' + req.getBody());

        HTTPResponse res = http.send(req);

        System.debug('Status: ' + res.getStatus());
        System.debug('Body: ' + res.getBody());  
        System.debug(res.getStatusCode());

        // Check status code before writing to Account
        if(res.getStatusCode() >= 200 && res.getStatusCode() < 300) {

            // Postman server is set up to return a generated Id for the Account, this gets set to the syncId
            try {
                // Expected shape:
                // {
                //   "synced": true,
                //   "postmanSyncId": "<guid>",
                //   "receivedAt": "<timestamp>"
                // }
                Map<String, Object> result =
                    (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

                String syncId = (String) result.get('postmanSyncId');
                System.debug('Parsed postmanSyncId: ' + syncId);

                // @DEV-EDIT add more conditionals here to handle different SObjects you wish to sync
                // Check that syncId is populated and write to Account's Sync_Id field
                if (!String.isBlank(syncId) && objectType == 'Account') {
                    Account accToUpdate = new Account(
                        Id        = recordId,
                        Sync_Id__c = syncId
                    );
                    update accToUpdate;
                    System.debug('Account updated with Sync_Id__c: ' + recordId);
                } else {
                    System.debug('No postmanSyncId found or objectType not Account.');
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR,
                    'Error parsing Postman response: ' + e.getMessage() +
                    ' body: ' + res.getBody());
            }

        } else {
            System.debug(LoggingLevel.ERROR, 'Postman call failed: ' + res.getStatusCode() + ' ' + res.getBody());
        }
    }
}