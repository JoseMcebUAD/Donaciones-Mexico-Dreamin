import { LightningElement, wire } from 'lwc';
import getActiveCampaigns from '@salesforce/apex/PublicCampaignController.getActiveCampaigns';

export default class CampaignCatalog extends LightningElement {
    campaigns = [];
    selectedCampaign;
    error;
    isLoading = true;
    currentView = 'home';

    get isHome() {
        return this.currentView === 'home';
    }

    get isFaq() {
        return this.currentView === 'faq';
    }

    get homeNavClass() {
        return this.currentView === 'home' ? 'nav-btn nav-btn--active' : 'nav-btn';
    }

    get faqNavClass() {
        return this.currentView === 'faq' ? 'nav-btn nav-btn--active' : 'nav-btn';
    }

    handleNav(event) {
        this.currentView = event.currentTarget.dataset.view;
    }

    _campaignIdFromUrl = null;

    connectedCallback() {
        try {
            const params = new URLSearchParams(window.location.search);
            const idParam = params.get('campaign');
            if (idParam) {
                this._campaignIdFromUrl = idParam;
            }
        } catch {
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
        Promise.resolve().then(() => {
            const anchor = this.template.querySelector('.donation-anchor');
            if (anchor && typeof anchor.scrollIntoView === 'function') {
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
        this._scrollToDonationForm();
    }
}
