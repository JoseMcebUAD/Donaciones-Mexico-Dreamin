import { LightningElement, api, wire } from 'lwc';
import getRecognizedDonors from '@salesforce/apex/PublicCampaignController.getRecognizedDonors';

export default class DonorWall extends LightningElement {
    @api campaignId;
    donors = [];
    error;

    @wire(getRecognizedDonors, { campaignId: '$campaignId' })
    wiredDonors({ data, error }) {
        if (data) {
            this.donors = data;
            this.error = undefined;
        } else if (error) {
            this.donors = [];
            this.error = 'The recognition wall is temporarily unavailable.';
        }
    }

    get hasDonors() {
        return this.donors.length > 0;
    }
}
