import { LightningElement, api } from 'lwc';
import generateQuoteLineCsv from '@salesforce/apex/QuoteLineExportController.generateQuoteLineCsv';

export default class QuoteLineExport extends LightningElement {
    @api recordId; // This will hold the Quote ID

    connectedCallback() {
        this.handleExport();
    }

    handleExport() {
        generateQuoteLineCsv({ quoteId: this.recordId })
            .then(result => {
                this.downloadCsv(result, `Export Quote Lines - ${this.recordId}.csv`);
                // this.showExportMessage();
            })
            .catch(error => {
                console.error('Error generating CSV:', error);
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
    
}