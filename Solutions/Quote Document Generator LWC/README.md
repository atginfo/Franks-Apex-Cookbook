# Quote Document Generator LWC

## Introduction

Within Salesforce CPQ, users can generate quote documents using predefined templates. While Salesforce CPQ provides a native interface for this, you may want to offer users a more direct, streamlined way to generate documents without leaving the Quote record page. This solution accomplishes that using a custom Lightning Web Component and Apex controller.

This setup enables users to select a deployed template, enter a document name, and generate a quote document via the SBQQ.QuoteDocumentAPI.Save API. It also includes the ability to preview the quote before generation, poll for the document job's completion, and automatically open the finished PDF once ready.

This README is intended as a supplemental guide for developers looking to customize the quote document generation flow, whether to integrate it into a guided experience or improve document UX for sales teams.

![Screenshot](https://github.com/atginfo/Franks-Apex-Cookbook/blob/main/Solutions/Quote%20Document%20Generator%20LWC/images/quote-doc-generator-screenshot.png)

## Features

This solution provides the following capabilities:
- Fetches a list of deployed templates associated with a Quote.
- Prefills and allows editing of the document name.
- Allows users to preview the quote document before saving.
- Invokes SBQQ.QuoteDocumentAPI.Save with fully customized input.
- Tracks the async job until completion and automatically opens the final document.
- Displays real-time loading states and toast messages for success/failure.

## How It Works

The solution consists of the following components:

### Apex Class: GenerateQuoteDocumentCtrl
This controller handles all backend logic for document generation and template lookup.

Key Methods:
- save(Map<String, Object> contextMap) : Serializes the input data and calls the CPQ Save API.
- getTemplatesAndQuoteInfo(Id quoteId) : Queries the quote and deployed templates. Returns a list of templates and a default template ID.
- checkJobStatus(String jobId) :Checks the status of the AsyncApexJob tied to the document generation.
- getLatestDocumentId(Id quoteId) : Queries for the most recently created SBQQ__QuoteDocument__c to help preview the final document.

### Lightning Web Component: generateQuoteDocument

This LWC provides the front-end interface and user interactions.

Main Features:
- Combobox to select a quote template.
- Input field for custom document name (defaulted to Quote Name).
- "Preview" button to view document layout before generation.
- "Generate" button to trigger document creation.
- Spinner and toast notifications to provide user feedback.
- Polling mechanism checks the async job status every 5 seconds.
- Auto-open the document once generated.

Validation:
- Document name must be present and ≤ 80 characters.
- Template must be selected.
- Quote ID must be valid.

## Document Generation Flow

1. User lands on Quote Record Page with the LWC placed on layout
2. LWC fetches deployed templates and quote name using getTemplatesAndQuoteInfo.
3. User previews or generates document using UI controls.
4. On generate:
    - save method is called with serialized context (name, quoteId, templateId, etc.).
    - Apex class calls SBQQ.QuoteDocumentAPI.Save.
    - Async Apex job is created.
5. Polling begins to check job status.
    - If Completed with no errors, the latest document is fetched and opened.
    - If Failed or job not found after 12 attempts, user is notified.

## Visualforce Page Compatibility

The final document preview uses the standard SBQQ__PreviewDocument Visualforce page and the output document is opened using the ViewDocument page. The component dynamically builds the correct VF domain based on the current Lightning domain.

## General Troubleshooting

- Error generating quote document: Bad Request : Likely due to missing or malformed input to the Save API. Ensure the Quote ID and Template ID are not null and the name is under the character limit.

- Async job stuck on In Progress : Document generation may take longer than expected. Polling retries up to 12 times before displaying an error.

- Template not appearing in dropdown :Make sure the template’s SBQQ__DeploymentStatus__c is set to Deployed and it's assigned to the Quote.
