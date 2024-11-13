import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import generateQuoteLineCsv from '@salesforce/apex/QuoteLineExportController.generateQuoteLineCsv';

export default class QuoteLineExportv2 extends LightningElement {
    @api recordId; // This will hold the Quote ID

    connectedCallback() {
        console.log('LWC Quick Action launched with recordId: ' + this.recordId);
        // this.handleExport();
    }

    handleExport() {
        generateQuoteLineCsv({ quoteId: this.recordId })
            .then(result => {
                this.downloadCsv(result, `Export Quote Lines - ${this.recordId}.csv`);
                this.showExportMessage();
                this.closeQuickAction();
            })
            .catch(error => {
                console.error('Error generating CSV:', error);
                this.closeQuickAction();
            });
    }

    // This works!
    // downloadCsv(csvContent, filename) {
    //     // Convert CSV content to Base64
    //     const base64CsvContent = btoa(unescape(encodeURIComponent(csvContent)));
    
    //     // Create a data URL with the Base64 content
    //     const dataUrl = `data:text/csv;charset=utf-8;base64,${base64CsvContent}`;
    
    //     // Create a temporary anchor element to trigger the download
    //     const link = document.createElement('a');
    //     link.href = dataUrl;
    //     link.download = filename;
        
    //     // Append the link to the body and trigger the click
    //     document.body.appendChild(link);
    //     link.click();
    
    //     // Clean up by removing the link
    //     document.body.removeChild(link);
    // }

    downloadCsv(dataUrl, filename) {
        // Create a temporary anchor element to trigger the download
        const link = document.createElement('a');
        link.href = dataUrl;
        link.download = filename;
        
        // Append the link to the body and trigger the click
        document.body.appendChild(link);
        link.click();

        // Clean up by removing the link
        document.body.removeChild(link);
    }

    showExportMessage() {
        const message = this.template.querySelector('.export-message');
        if (message) {
            message.style.display = 'block';
        }
    }

    closeQuickAction() {
        // Close the modal after the download has started
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}