import { LightningElement, api } from 'lwc';
import startDonation from '@salesforce/apex/PublicDonationController.startDonation';

export default class DonationForm extends LightningElement {
    @api campaign;
    amount = 500;
    isAnonymous = false;
    wantsRecognition = false;
    needsInvoice = false;
    isLoading = false;
    error;

    get nameRequired() {
        return !this.isAnonymous;
    }

    handleChange(event) {
        this[event.target.name] = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
        if (event.target.name === 'isAnonymous' && event.target.checked) {
            this.wantsRecognition = false;
            this.needsInvoice = false;
        }
    }

    selectAmount(event) {
        this.amount = Number(event.target.dataset.amount);
    }

    getSuccessUrl() {
        const currentUrl = new URL(window.location.href);
        const siteMarker = '/s/';
        const markerIndex = currentUrl.pathname.indexOf(siteMarker);
        const sitePath = markerIndex >= 0
            ? currentUrl.pathname.substring(0, markerIndex + siteMarker.length)
            : '/s/';
        return `${currentUrl.origin}${sitePath}thank-you?session_id={CHECKOUT_SESSION_ID}`;
    }

    async submit() {
        const fields = [...this.template.querySelectorAll('lightning-input')];
        if (!fields.every((field) => field.checkValidity())) {
            fields.forEach((field) => field.reportValidity());
            return;
        }
        this.error = undefined;
        this.isLoading = true;
        try {
            const response = await startDonation({
                campaignId: this.campaign.id,
                amount: Number(this.amount),
                isAnonymous: this.isAnonymous,
                wantsRecognition: this.wantsRecognition,
                needsInvoice: this.needsInvoice,
                donorName: this.template.querySelector('[name="donorName"]').value,
                donorEmail: this.template.querySelector('[name="donorEmail"]').value,
                legalName: this.template.querySelector('[name="legalName"]')?.value,
                rfc: this.template.querySelector('[name="rfc"]')?.value,
                successUrl: this.getSuccessUrl(),
                cancelUrl: window.location.href
            });
            window.location.assign(response.checkoutUrl);
        } catch (error) {
            this.error = error.body?.message || 'Unable to start checkout.';
        } finally {
            this.isLoading = false;
        }
    }
}
