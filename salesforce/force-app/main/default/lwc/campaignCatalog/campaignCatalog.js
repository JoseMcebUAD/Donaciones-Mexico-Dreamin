import { LightningElement, wire } from 'lwc';
import getActiveCampaigns from '@salesforce/apex/PublicCampaignController.getActiveCampaigns';

export default class CampaignCatalog extends LightningElement {
    campaigns = [];
    selectedCampaign;
    error;
    isLoading = true;

    _campaignIdFromUrl = null;

    connectedCallback() {
        try {
            const params = new URLSearchParams(window.location.search);
            const idParam = params.get('campaign');
            if (idParam) {
                this._campaignIdFromUrl = idParam;
            }
        } catch (_) {
            // URL parsing is non-critical
        }
    }

    @wire(getActiveCampaigns)
    wiredCampaigns({ data, error }) {
        this.isLoading = false;
        if (data) {
            this.campaigns = data;
            this.error = undefined;

            if (this._campaignIdFromUrl) {
                const matched = data.find(
                    (c) => c.id === this._campaignIdFromUrl && !c.isDonationBlocked
                );
                if (matched) {
                    this.selectedCampaign = matched;
                    this._scrollToDonationForm();
                    return;
                }
            }

            if (data.length === 1 && !data[0].isDonationBlocked) {
                this.selectedCampaign = data[0];
            }
        } else if (error) {
            this.campaigns = [];
            this.error = 'Campaigns are temporarily unavailable. Please try again later.';
        }
    }

    _scrollToDonationForm() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        Promise.resolve().then(() => {
            const anchor = this.template.querySelector('.donation-anchor');
            if (anchor) {
                anchor.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        });
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
