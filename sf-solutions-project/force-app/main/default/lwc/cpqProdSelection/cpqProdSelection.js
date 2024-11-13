import { LightningElement, api, track, wire } from 'lwc';
import getProducts from '@salesforce/apex/CpqProductSelectionController.getProducts';
import addSelectedProducts from '@salesforce/apex/CpqProductSelectionController.addSelectedProducts';

export default class CpqProdSelection extends LightningElement {
    products = [];
    @api recordId;
    @api xdm
    @api cd

    @wire(getProducts)
    wiredProducts({ error, data }) {
        if (data) {
            this.products = data.map(product => ({ ...product, selected: false }));
            console.log('Returned Products');
            console.log(this.products);
        } else if (error) {
            // Handle error
        }
    }

    handleProductSelection(event) {
        console.log(event);
        const evTarget = event.target;
        console.log(evTarget);
        let productId = evTarget.id;
        console.log(productId);
        productId = productId.replace("-0","");
        const selectedProduct = this.products.find(product => product.Id === productId);
        console.log(selectedProduct);
        if (selectedProduct) {
            selectedProduct.selected = event.target.checked;
        }
    }
    

    addSelectedProducts() {
        const selectedProductIds = this.products.filter(product => product.selected).map(product => product.Id);
        if (selectedProductIds.length === 0) {
            // Handle case when no products are selected
            return;
        }

        // Call Apex method to add selected products to the quote
        addSelectedProducts({ selectedProductIds: selectedProductIds, recordId: this.recordId })
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