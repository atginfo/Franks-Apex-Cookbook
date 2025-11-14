/* 
    Author: Frank Berni
    Purpose: 
    To showcase how we can use Apex Triggers to make callouts to external systems. 
    We'll be using Postman to receive the callouts and stamp Id back to the record
*/ 
public class IntegrationCalloutService {

    // specify the endpoint, payload, recordId and objectType and enqueues the async apex to callout
    private static void sendPayload(String endpoint, Map<String, Object> payload, Id recordId, String objectType) {
        System.enqueueJob(new IntegrationCalloutJob(endpoint, payload, recordId, objectType));
    }

    // builds account payload based on the passed in Account
    // @DEV-EDIT feel free to create more methods or expand on this one based on project need 
    public static void sendAccountPayload(Id accountId) {

        // Querying matching account
        Account acc = [
            SELECT Id, Name, ParentId, Phone, Fax, Website, 
                   BillingStreet, BillingCity, BillingState, BillingPostalCode,
                   BillingCountry, Industry, Owner.Name, Owner.Email, AccountNumber
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];

        // Creating payload Map, Object for all Account Fields to send to external site
        Map<String, Object> payload = new Map<String, Object>{
            'Id' => acc.Id,
            'Name' => acc.Name,
            'ParentId' => acc.ParentId,
            'Phone' => acc.Phone,
            'Fax' => acc.Fax,
            'Website' => acc.Website,
            'BillingStreet' => acc.BillingStreet,
            'BillingCity' => acc.BillingCity,
            'BillingState' => acc.BillingState,
            'BillingPostalCode' => acc.BillingPostalCode,
            'BillingCountry' => acc.BillingCountry,
            'Industry' => acc.Industry,
            'OwnerName' => acc.Owner != null ? acc.Owner.Name : null,
            'OwnerEmail' => acc.Owner != null ? acc.Owner.Email : null,
            'AccountNumber' => acc.AccountNumber
        };

        System.debug('Account Payload: ' + payload);
        // Calling sendPayload with matching root '/accounts/sync', 
        // @DEV-EDIT: if using with multiple SF objects. Set up mock root to handle them. i.e. /products for Products
        sendPayload('/accounts/sync', payload, acc.Id, 'Account');
    }
}