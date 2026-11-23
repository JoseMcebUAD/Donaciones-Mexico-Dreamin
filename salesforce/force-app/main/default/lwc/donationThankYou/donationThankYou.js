import { LightningElement } from 'lwc';

const PORTAL_URL = 'https://uady--class2026a.sandbox.my.site.com/donaciones/s';

export default class DonationThankYou extends LightningElement {
    get hasCheckoutReference() {
        return new URLSearchParams(window.location.search).has('session_id');
    }

    goBack() {
        window.location.assign(PORTAL_URL);
    }
}
