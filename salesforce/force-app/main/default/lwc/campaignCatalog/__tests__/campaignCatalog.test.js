import { createElement } from 'lwc';
import CampaignCatalog from 'c/campaignCatalog';
import getActiveCampaigns from '@salesforce/apex/PublicCampaignController.getActiveCampaigns';
import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

const getActiveCampaignsAdapter = registerApexTestWireAdapter(getActiveCampaigns);

describe('c-campaign-catalog', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('shows an active campaign returned by Apex', async () => {
        const element = createElement('c-campaign-catalog', { is: CampaignCatalog });
        document.body.appendChild(element);
        getActiveCampaignsAdapter.emit([
            { id: 'a001', name: 'Education fund', goalAmount: 1000, raisedAmount: 250, progressPercent: 25 }
        ]);
        await Promise.resolve();
        expect(element.shadowRoot.querySelector('lightning-card').title).toBe('Mexico Dreamin Campaigns');
        expect(element.shadowRoot.textContent).toContain('Education fund');
    });

    it('shows empty state when no public campaigns are returned', async () => {
        const element = createElement('c-campaign-catalog', { is: CampaignCatalog });
        document.body.appendChild(element);
        getActiveCampaignsAdapter.emit([]);
        await Promise.resolve();
        expect(element.shadowRoot.textContent).toContain('There are no active campaigns at this time.');
    });
});
