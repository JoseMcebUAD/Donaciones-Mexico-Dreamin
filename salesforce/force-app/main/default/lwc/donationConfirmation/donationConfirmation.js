import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import confirmPayment from '@salesforce/apex/DonationManagementService.confirmPayment';

export default class DonationConfirmation extends LightningElement {
    @api recordId;
    isWorking = false;

    async handleConfirm() {
        this.isWorking = true;
        try {
            await confirmPayment({ donationId: this.recordId });
            this.dispatchEvent(new ShowToastEvent({ title: 'Donation confirmed', message: 'The donation is now paid and a receipt was requested.', variant: 'success' }));
            this.dispatchEvent(new CloseActionScreenEvent());
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({ title: 'Unable to confirm donation', message: error.body?.message || 'Try again or contact an administrator.', variant: 'error' }));
        } finally {
            this.isWorking = false;
        }
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}
