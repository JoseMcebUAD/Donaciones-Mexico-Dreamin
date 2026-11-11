import { LightningElement } from 'lwc';

export default class DonationThankYou extends LightningElement {
    get hasCheckoutReference() {
        return new URLSearchParams(window.location.search).has('session_id');
    }
}
