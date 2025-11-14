# Salesforce ↔ Postman Mock Integration

A lightweight example demonstrating how to connect Salesforce Apex to a Postman Mock Server using Named Credentials and External Credentials.  
This guide is written for developers experienced in Apex but newer to Postman's mock server features.

---

# Overview

This project shows how to:

- Create a Postman Mock Server  
- Build a `POST /accounts/sync` endpoint with dynamic responses  
- Configure Salesforce Named Credentials + External Credentials  
- Add custom Account fields to support syncing  
- Write Apex code for outbound callouts using Queueables  
- Trigger an automatic sync when a checkbox is selected  

---

# 1. Postman Setup

## 1.1 Create the Mock Server

1. In Postman, go to **Mock Servers → Create Mock Server**
2. Configure:
   - Name: `Account Sync FCB`
   - Collection: your chosen collection (or create a new one)
   - Environment: none
   - Simulated Delay: none
   - Make mock server private: checked
3. Click **Create Mock Server**
4. Copy the generated mock server URL  
   Example:
   ```
   https://77a4ff81-a5d6-46a5-8e8d-c6b722bd7248.mock.pstmn.io
   ```

---

## 1.2 Create the POST Request

Create a request inside your collection:

```
POST /accounts/sync
```

Set the request body to:

```
raw → JSON
```

Example payload:

```json
{
  "Id": "001XX0000001234",
  "Name": "Test Account",
  "Phone": "555-555-1212"
}
```

Save your request.

---

## 1.3 Create the Example Response

1. Send the request once  
2. In the returned response → click **Save Response → Save as example**  
3. Replace the example response body with:

```json
{
  "synced": true,
  "postmanSyncId": "{{$guid}}",
  "receivedAt": "{{$isoTimestamp}}",
  "example": "yes"
}
```

4. Ensure your example response headers include:

```
Content-Type: application/json
```

Save the example.

---

## 1.4 Get the Postman API Key

To authorize the private mock server:

1. Open the mock server's **View Logs** page  
2. Copy the **Mock Server API Key**  
3. You will use this as a custom header in Salesforce

---

# 2. Salesforce Setup

## 2.1 Create Custom Fields on Account

| Field Label   | API Name          | Type     | Purpose                                 |
|---------------|-------------------|----------|-----------------------------------------|
| Sync Account  | Sync_Account__c   | Checkbox | User selects this to initiate syncing   |
| Sync Id       | Sync_Id__c        | Text     | Stores the GUID returned from Postman   |

---

## 2.2 Create the External Credential

1. Go to **Setup → External Credentials → New**
2. Enter:
   ```
   Name: Postman_Custom_Auth
   Type: Custom
   ```
3. Create a **Named Principal**
4. Create a Permission Set granting access to this Named Principal  
5. Assign the permission set to the appropriate user(s)
6. Leave Custom Headers blank (we add the API key on the Named Credential)

---

## 2.3 Create the Named Credential

Go to **Setup → Named Credentials → New**

```
Label: Postman Mock
Name: Postman_Mock
URL: https://<your-mock-id>.mock.pstmn.io
Identity Type: Named Principal
Authentication Protocol: Custom
External Credential: Postman_Custom_Auth
Generate Authorization Header: (unchecked)
```

### Add the API Key Header

Under the Named Credential → **Custom Headers → New**

```
Name: x-api-key
Value: <your-postman-api-key>
```

---

# 3. Apex Implementation

This integration includes:

- `IntegrationCalloutService` — prepares payloads and enqueues jobs  
- `IntegrationCalloutJob` — Queueable that performs the actual HTTP call  
- `AccountTriggerForCallouts` — fires the integration when the user checks Sync Account  

---

## 3.1 IntegrationCalloutService.cls

```apex
public class IntegrationCalloutService {

    private static void sendPayload(String endpoint, Map<String, Object> payload, Id recordId, String objectType) {
        System.enqueueJob(new IntegrationCalloutJob(endpoint, payload, recordId, objectType));
    }

    public static void sendAccountPayload(Id accountId) {
        Account acc = [
            SELECT Id, Name, ParentId, Phone, Fax, Website,
                   BillingStreet, BillingCity, BillingState,
                   BillingPostalCode, BillingCountry, Industry,
                   Owner.Name, Owner.Email, AccountNumber
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];

        Map<String, Object> payload = new Map<String, Object>{
            'Id'                => acc.Id,
            'Name'              => acc.Name,
            'ParentId'          => acc.ParentId,
            'Phone'             => acc.Phone,
            'Fax'               => acc.Fax,
            'Website'           => acc.Website,
            'BillingStreet'     => acc.BillingStreet,
            'BillingCity'       => acc.BillingCity,
            'BillingState'      => acc.BillingState,
            'BillingPostalCode' => acc.BillingPostalCode,
            'BillingCountry'    => acc.BillingCountry,
            'Industry'          => acc.Industry,
            'OwnerName'         => acc.Owner != null ? acc.Owner.Name : null,
            'OwnerEmail'        => acc.Owner != null ? acc.Owner.Email : null,
            'AccountNumber'     => acc.AccountNumber
        };

        sendPayload('/accounts/sync', payload, acc.Id, 'Account');
    }
}
```

---

## 3.2 IntegrationCalloutJob.cls

```apex
public class IntegrationCalloutJob implements Queueable, Database.AllowsCallouts {

    private String endpoint;
    private Map<String, Object> payload;
    private Id recordId;
    private String objectType;

    public IntegrationCalloutJob(String endpoint, Map<String, Object> payload, Id recordId, String objectType) {
        this.endpoint = endpoint;
        this.payload = payload;
        this.recordId = recordId;
        this.objectType = objectType;
    }

    public void execute(QueueableContext context) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Postman_Mock' + endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(payload));

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            try {
                Map<String, Object> result =
                    (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

                String syncId = (String) result.get('postmanSyncId');

                if (!String.isBlank(syncId) && objectType == 'Account') {
                    update new Account(Id = recordId, Sync_Id__c = syncId);
                }

            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR,
                    'Error parsing Postman response: ' + e.getMessage() +
                    ' body: ' + res.getBody());
            }
        } else {
            System.debug(LoggingLevel.ERROR,
                'Postman call failed: ' + res.getStatusCode() + ' ' +
                res.getBody());
        }
    }
}
```

---

## 3.3 AccountTriggerForCallouts.trigger

```apex
trigger AccountTriggerForCallouts on Account (after insert, after update) {

    if (Trigger.isInsert) {
        for (Account acc : Trigger.new) {
            if (acc.Sync_Account__c == true && acc.Sync_Id__c == null) {
                IntegrationCalloutService.sendAccountPayload(acc.Id);
            }
        }
    }

    if (Trigger.isUpdate) {
        for (Account acc : Trigger.new) {
            Account oldAcc = Trigger.oldMap.get(acc.Id);
            Boolean turnedOn = (acc.Sync_Account__c == true && oldAcc.Sync_Account__c != true);

            if (turnedOn && acc.Sync_Id__c == null) {
                IntegrationCalloutService.sendAccountPayload(acc.Id);
            }
        }
    }
}
```

---

# 4. End-to-End Workflow

1. User checks the **Sync Account** checkbox on an Account  
2. Trigger detects the change and calls the service  
3. Apex builds a JSON payload  
4. Payload is sent by a Queueable to the Named Credential:  
   ```
   callout:Postman_Mock/accounts/sync
   ```
5. Named Credential injects the Postman API Key automatically  
6. Postman Mock Server responds with something like:

```json
{
  "synced": true,
  "postmanSyncId": "05e6d77e-57dc-4551-89c1-897716c66f03",
  "receivedAt": "2025-11-07T19:47:34.360Z",
  "example": "yes"
}
```

7. Apex parses the JSON  
8. Returned `postmanSyncId` is written to `Sync_Id__c`  
9. The Account record is now “synced”

---

# 5. Summary

This project demonstrates a full integration pattern using:

- Postman Mock Server  
- Salesforce Named Credentials  
- Apex callout architecture using Queueables  
- A clean Account-level trigger for initiating outbound syncs  

This pattern provides a strong foundation for future real integrations.
