import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent }              from 'lightning/platformShowToastEvent';
import { getRecord }                   from 'lightning/uiRecordApi';
import { refreshApex }                 from '@salesforce/apex';

// Apex Methods
import generateQuoteDoc                from '@salesforce/apex/GenerateQuoteDocumentCtrl.save';
import getTemplatesAndQuoteInfo        from '@salesforce/apex/GenerateQuoteDocumentCtrl.getTemplatesAndQuoteInfo';
import getLatestDocumentId             from '@salesforce/apex/GenerateQuoteDocumentCtrl.getLatestDocumentId';
import checkJobStatus                  from '@salesforce/apex/GenerateQuoteDocumentCtrl.checkJobStatus';

// Quote Field API Names 
import NAME_FIELD                      from '@salesforce/schema/SBQQ__Quote__c.Name';
import QUOTE_ACCOUNT_NAME              from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Account__r.Name';
import QUOTE_TEMPLATE_FIELD            from '@salesforce/schema/SBQQ__Quote__c.SBQQ__QuoteTemplateId__c'

const FIELDS = [NAME_FIELD, QUOTE_ACCOUNT_NAME, QUOTE_TEMPLATE_FIELD];

export default class GenerateQuoteDocument extends LightningElement {
    @api recordId;
    isLoading = false;
    templateOptions = [];
    // Assigned template to Template combobox 
    selectedTemplateId;
    jobId;
    pollingInterval;
    retryCount = 0;
    maxRetries = 12;
    documentName = '';
    quoteName = '';
    // stored current templateId - updates if getRecord returns a new template Id
    currentTemplateId;
    // stored currentQuoteName - updates if getRecord returns a new QuoteName
    currentQuoteName;
     // store wired data for refresh
    wiredData;
    wiredTemplatesResult;

    /*********************************** IMPORTED LIGHTNING METHODS ***********************************/
    // Queries quote fields to ensure most up to date record values
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS }) 
    record({ data, error}) {
        if(data) {
            // Updates template Id if there is a stale Id assigned
            const newTemplateId = data.fields.SBQQ__QuoteTemplateId__c.value;
            // newQuoteName to store latest value of Quote Name Override
            const newQuoteName = data.fields.Name.value;
            const newQuoteAccName = data.fields.Acccount__r.Name.value;
            var newDocumentName = newQuoteAccName + ' ' + newQuoteName;
            let refresh = false;

            if(this.currentTemplateId !== newTemplateId) {
                this.currentTemplateId = newTemplateId;
                refresh = true;
            }

            // add currentQuoteName check to automatically update if different
            if(this.currentQuoteName !== newDocumentName) {
                this.currentQuoteName = newDocumentName;
                // this.documentName = this.currentQuoteName;
                refresh = true;
            }

            // refresh check to run refreshTemplates if either Template Id or Quote Name is different
            if(refresh) {
                this.refreshTemplates();
            }

        } else if (error) {
            console.error('Error fetching record data:', error);
            this.showToast('Error', 'Failed to fetch quote data', 'error');
        }
    }

    // Refreshes the component's data - Default Template will change based on SBQQ__QuoteTemplateId__c change
    refreshTemplates() {
        console.log('Refreshing document name and template data due to recent changes...');

        // utilizing refeshApex to re-query the quote and template 
        refreshApex(this.wiredData)
        .then(() => {
            console.log('Document Name and Template data refreshed successfully');
        })
        .catch((error) => {
            console.log('Error refreshing document name and template data:', error);
            this.showToast('Error', 'Error refreshing document name and template data', 'error');
        });
    }
    
    /*********************************** IMPORTED APEX METHODS ***********************************/
    // Uses getTemplatesAndQuoteInfo to query for Template Id and Quote Document Name
    @wire(getTemplatesAndQuoteInfo, { quoteId: '$recordId' })
    wiredTemplatesAndQuoteInfo(result) {
        this.wiredData = result;

        if (result.data) {
            this.templateOptions = result.data.templates.map(template => ({
                label: template.Name,
                value: template.Id
            }));
            // Sets default selection to first option if no defaultTemplateId is provided
            this.selectedTemplateId = result.data.defaultTemplateId || (this.templateOptions.length > 0 ? this.templateOptions[0].value : null);
            this.quoteName = result.data.quoteName;
            this.documentName = `${this.quoteName}`;
            
        } else if (result.error) {
            console.error('Error fetching templates and quote info:', result.error);
            this.showToast('Error', 'Failed to load quote templates and info', 'error');
        }
    }

    // Tied to Generate Document button
    handleGenerateDocument() {
        console.log('Generate Document clicked. RecordId:', this.recordId, 'TemplateId:', this.selectedTemplateId);

        // Validate recordId and TemplateId are available
        if (!this.recordId) {
            console.error('Quote ID is not available');
            this.showToast('Error', 'Quote ID is not available', 'error');
            return;
        }

        if (!this.selectedTemplateId) {
            console.error('Template ID is not selected');
            this.showToast('Error', 'Please select a template', 'error');
            return;
        }

        // Checks that character count on documentName is not greater than 80
        if (this.documentName.length > 80) {
            console.error('Document name is too long. Please keep within 80 characters');
            this.showToast('Error', 'Document name is too long. Please keep within 80 characters', 'error');
            return;
        }

        this.isLoading = true;

        const context = {
            name: this.documentName,
            quoteId: this.recordId,
            templateId: this.selectedTemplateId,
            outputFormat: 'PDF',
            language: 'en_US',
            paperSize: 'Default'
        };

        console.log('Sending context to Apex:', JSON.stringify(context));

        generateQuoteDoc({ contextMap: context })
            .then(result => {
                console.log('Document generation job started. Job ID:', result);
                this.jobId = result.replace(/"/g, ''); // Remove quotes
                this.showToast('Success', 'Quote document generation job started. Job ID: ' + this.jobId, 'success');

                setTimeout(() => {
                    this.startPolling();
                }, 2000); // Wait 2 seconds before starting to poll
            })
            .catch(error => {
                console.error('Error generating quote document:', error);
                this.showToast('Error', 'Error generating quote document: ' + error.body.message, 'error');
                this.isLoading = false;
            });
    }

    // Automatically Open Proposal Document after complete
    openLatestDocument() {
        getLatestDocumentId({ quoteId: this.recordId })
            .then((documentId) => {
                console.log('Document ID fetched:', documentId);

                if (documentId) {
                    // Get current origin (e.g., https://acme-dev-ed.lightning.force.com)
                    const lightningDomain = window.location.origin;

                    // Replace .lightning.force.com with --sbqq.vf.force.com
                    const vfDomain = lightningDomain.replace(
                        '.lightning.force.com',
                        '--sbqq.vf.force.com'
                    );

                    // Construct the final URL to the ViewDocument page
                    const url = `${vfDomain}/apex/ViewDocument?id=${documentId}`;
                
                    // Open in new tab
                    window.open(url, '_blank');

                } else {
                    console.log('No document found for this quote');
                    this.showToast('Error', 'No document found for this quote', 'error');
                }
            })
            .catch((error) => {
                console.error('Error fetching document:', error);
                this.showToast('Error', 'An error occurred while fetching the document', 'error');
            });
    }

    // Checks status of async apex job, runs polling to check again after certain period of time
    checkJobStatus() {
        console.log('Checking job status for Job ID:', this.jobId);
        // Passing jobId to apex method
        checkJobStatus({ jobId: this.jobId })
            .then(status => {
                console.log('Job status received:', status);

                // On complete, show success toast, open latest doc in new tab, call stopPolling
                if (status === 'Completed') {
                    let successMessage = 'Quote document generation completed';
                    this.showToast('Success', successMessage, 'success');
                    this.openLatestDocument();
                    this.stopPolling();

                // On failure, show error toast, call stopPolling
                } else if (status === 'Failed') {
                    this.showToast('Error', 'Quote document generation failed', 'error');
                    this.stopPolling();

                // If job isn't found, then retryCount increments until it succeeds maxRetries
                } else if (status === 'Job not found') {
                    console.log('Job not found, will retry. Job ID:', this.jobId);
                    this.retryCount++;
                    if (this.retryCount >= this.maxRetries) {
                        console.log('Max retries reached. Stopping polling.');
                        this.showToast('Error', 'Unable to find job status after multiple attempts', 'error');
                        this.stopPolling();
                    }
                    
                // Jobs in progress will set retryCount to 0
                } else {
                    console.log('Job in progress. Status:', status);
                    this.retryCount = 0; // Reset retry count if we get a valid status
                }
            })
            .catch(error => {
                console.error('Error checking job status:', error);
                this.showToast('Error', 'Error checking job status: ' + error.body.message, 'error');
                this.stopPolling();
            });
    }


    /*********************************** FUNCTIONS and HANDLERS ***********************************/
    // Overrides selectedTemplateId based Template selected
    handleTemplateChange(event) {
        this.selectedTemplateId = event.detail.value;
    }

    // Overrides documentName based on entered value
    handleDocumentNameChange(event) {
        this.documentName = event.target.value;
    }

    // Takes user to the SBQQ__PreviewDocument page to further see how document looks like before saving
    handlePreviewDocument() {
        console.log('Preview Document clicked. RecordId:', this.recordId);
        
        // Error handling if recordId is not available
        if(!this.recordId) {
            console.error('Quote Id is not available for preview');
            this.showToast('Error', 'Quote Id is not available', 'error');
            return;
        }

        const url = `/apex/SBQQ__PreviewDocument?id=${this.recordId}`;
        window.open(url, '_blank'); // Opens the VF page in a new tab
    }

    // Checks jobStatus, sets interval to checck every 5 seconds until job is done
    startPolling() {
        // First check immediately
        this.checkJobStatus();
        // Then poll every 5 seconds
        this.pollingInterval = setInterval(() => {
            this.checkJobStatus();
        }, 5000);
    }

    // Clears interval from poll and resets certain variables
    stopPolling() {
        clearInterval(this.pollingInterval);
        this.isLoading = false;
        this.retryCount = 0;

        // refresh Quote Data 
        refreshApex(this.wiredData);
    }

    // Imported toast function for feedback
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }),
        );
    }    

    
}