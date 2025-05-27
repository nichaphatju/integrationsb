import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';


export default class DisconnectionNotice extends LightningElement {
    subscription = {};
    status;
    identifier;
    channelName = '/event/Asset_Disconnection__e';

    connectedCallback() {
        this.handleSubscribe();

        onError(error => {
            console.error('Emp API error: ', error);
        });
        
    }

    renderedCallback(){
        
    }

    handleSubscribe() {

        const messageCallback = function (response) {
            console.log('New message received: ', JSON.stringify(response));
            // Response contains the payload of the new message received

            this.status = response.data.payload.Disconnected__c;
            this.identifier = response.data.payload.Asset_Identifier__c;

            if (this.status) {
                this.showSuccessToast(this.identifier);
            } else {
                this.showErrorToast();
            }
        };

        subscribe(this.channelName, -1, messageCallback).then(response => {
            console.log('Subscribed to channel: ', JSON.stringify(response));
            this.subscription = response;
        });
    }

    disconnectedCallback() {
        //Implement your unsubscribing solution here
        if (this.subscription) {
            unsubscribe(this.subscription, response => {
                console.log('Unsubscribed', response);
            });
        }
    }

    showSuccessToast(assetId) {
        const event = new ShowToastEvent({
            title: 'Success',
            message: 'Asset Id '+assetId+' is now disconnected',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showErrorToast() {
        const event = new ShowToastEvent({
            title: 'Error',
            message: 'Asset was not disconnected. Try Again.',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

}