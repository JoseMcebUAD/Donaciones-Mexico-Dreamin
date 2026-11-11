import { LightningElement, wire } from 'lwc';
import getActiveCampaigns from '@salesforce/apex/PublicCampaignController.getActiveCampaigns';

export default class CampaignCatalog extends LightningElement {
    campaigns = [];
    selectedCampaign;
    error;
    isLoading = true;

    @wire(getActiveCampaigns)
    wiredCampaigns({ data, error }) {
        this.isLoading = false;
        if (data) {
            this.campaigns = data;
            this.error = undefined;
            if (data.length === 1 && !data[0].isDonationBlocked) {
                this.selectedCampaign = data[0];
            }
        } else if (error) {
            this.campaigns = [];
            this.error = 'Campaigns are temporarily unavailable. Please try again later.';
        }
    }

    get hasCampaigns() {
        return this.campaigns.length > 0;
    }

    selectCampaign(event) {
        this.selectedCampaign = this.campaigns.find(
            (campaign) => campaign.id === event.currentTarget.dataset.id
        );
    }
}
