import { LightningElement, wire } from 'lwc';
import getProducts from '@salesforce/apex/CpqProductSelectionController.getProducts';
import addSelectedProducts from '@salesforce/apex/CpqProductSelectionController.addSelectedProducts';

export default class CpqProductSelection extends LightningElement {
    products = [];
    quoteId;

    @wire(getProducts)
    wiredProducts({ error, data }) {
        if (data) {
            this.products = data.map(product => ({ ...product, selected: false }));
        } else if (error) {
            // Handle error
        }
    }

    handleProductSelection(event) {
        const productId = event.currentTarget.dataset.id;
        const selectedProduct = this.products.find(product => product.Id === productId);
        selectedProduct.selected = event.target.checked;
    }

    addSelectedProducts() {
        const selectedProductIds = this.products.filter(product => product.selected).map(product => product.Id);
        if (selectedProductIds.length === 0) {
            // Handle case when no products are selected
            return;
        }

        // Call Apex method to add selected products to the quote
        addSelectedProducts({ selectedProductIds: selectedProductIds, quoteId: this.quoteId })
            .then(() => {
                // Handle success
                // Refresh the component
                return refreshApex(this.products);
            })
            .catch(error => {
                // Handle error
            });
    }
}