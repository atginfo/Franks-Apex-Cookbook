@isTest
public class GenerateQuoteDocumentCtrlTest {

    @testSetup
    static void setupData() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            // Name = 'Test Quote',
            SBQQ__Account__c = acc.Id
        );
        insert quote;

        SBQQ__QuoteTemplate__c template = new SBQQ__QuoteTemplate__c(
            Name = 'Test Template',
            SBQQ__DeploymentStatus__c = 'Deployed',
            SBQQ__Default__c = true
        );
        insert template;

        // Update the quote to reference the template
        quote.SBQQ__QuoteTemplateId__c = template.Id;
        update quote;

        SBQQ__QuoteDocument__c doc = new SBQQ__QuoteDocument__c(
            SBQQ__Quote__c = quote.Id
        );
        insert doc;
    }

    @isTest
    static void testSaveMethod() {
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        SBQQ__QuoteTemplate__c template = [SELECT Id FROM SBQQ__QuoteTemplate__c LIMIT 1];

        Map<String, Object> contextMap = new Map<String, Object>{
            'name' => 'Test Proposal',
            'quoteId' => quote.Id,
            'templateId' => template.Id,
            'outputFormat' => 'PDF',
            'language' => 'en_US',
            'paperSize' => 'A4'
        };

        Test.startTest();
        String result = GenerateQuoteDocumentCtrl.save(contextMap);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(result.contains('Completed'), 'Expected status to be Completed in mock response');
    }

    @isTest
    static void testGetTemplatesAndQuoteInfo() {
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        Test.startTest();
        Map<String, Object> result = GenerateQuoteDocumentCtrl.getTemplatesAndQuoteInfo(quote.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(result.containsKey('templates'));
        System.assert(result.containsKey('defaultTemplateId'));
        System.assert(result.containsKey('quoteName'));
    }

    // @isTest
    // static void testCheckJobStatus_Completed() {
    //     AsyncApexJob job = new AsyncApexJob(
    //         Status = 'Completed',
    //         NumberOfErrors = 0,
    //         JobType = 'BatchApex'
    //     );
    //     insert job;

    //     Test.startTest();
    //     String status = GenerateQuoteDocumentCtrl.checkJobStatus(job.Id);
    //     Test.stopTest();

    //     System.assertEquals('Completed', status);
    // }

    // @isTest
    // static void testCheckJobStatus_Failed() {
    //     AsyncApexJob job = new AsyncApexJob(
    //         Status = 'Failed',
    //         NumberOfErrors = 1,
    //         JobType = 'BatchApex'
    //     );
    //     insert job;

    //     Test.startTest();
    //     String status = GenerateQuoteDocumentCtrl.checkJobStatus(job.Id);
    //     Test.stopTest();

    //     System.assertEquals('Failed', status);
    // }

    @isTest
    static void testCheckJobStatus_NotFound() {
        Test.startTest();
        String status = GenerateQuoteDocumentCtrl.checkJobStatus('999999999999999'); // invalid ID
        Test.stopTest();

        System.assertEquals('Job not found', status);
    }

    @isTest
    static void testGetLatestDocumentId() {
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        Test.startTest();
        String docId = GenerateQuoteDocumentCtrl.getLatestDocumentId(quote.Id);
        Test.stopTest();

        System.assertNotEquals(null, docId);
    }
}