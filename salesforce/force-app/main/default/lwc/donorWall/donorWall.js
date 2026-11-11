import { LightningElement, api, wire } from 'lwc';
import getRecognizedDonors from '@salesforce/apex/PublicCampaignController.getRecognizedDonors';
import getAnonymousDonorCount from '@salesforce/apex/PublicCampaignController.getAnonymousDonorCount';

export default class DonorWall extends LightningElement {
    @api campaignId;
    donors = [];
    anonymousCount = 0;
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

    @wire(getAnonymousDonorCount, { campaignId: '$campaignId' })
    wiredAnonCount({ data, error }) {
        if (data !== undefined) {
            this.anonymousCount = data;
        } else if (error) {
            this.anonymousCount = 0;
        }
    }

    get hasDonors() {
        return this.donors.length > 0;
    }

    get hasAnonymousDonors() {
        return this.anonymousCount > 0;
    }

    get hasAnyDonors() {
        return this.hasDonors || this.hasAnonymousDonors;
    }

    get anonymousLabel() {
        return this.anonymousCount === 1
            ? '+ 1 Donante Anónimo'
            : `+ ${this.anonymousCount} Donantes Anónimos`;
    }
}
