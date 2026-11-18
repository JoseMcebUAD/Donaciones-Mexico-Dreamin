import { createElement } from 'lwc';
import CampaignCatalog from 'c/campaignCatalog';
import getActiveCampaigns from '@salesforce/apex/PublicCampaignController.getActiveCampaigns';
import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

const getActiveCampaignsAdapter = registerApexTestWireAdapter(getActiveCampaigns);

const MOCK_CAMPAIGNS = [
    { id: 'a001', name: 'Education fund', goalAmount: 1000, raisedAmount: 250, progressPercent: 25, isDonationBlocked: false },
    { id: 'a002', name: 'Becas Dreamin', goalAmount: 2000, raisedAmount: 500, progressPercent: 25, isDonationBlocked: false }
];

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
        expect(element.shadowRoot.textContent).toContain('Tu apoyo transforma oportunidades.');
        expect(element.shadowRoot.textContent).toContain('Education fund');
    });

    it('shows empty state when no public campaigns are returned', async () => {
        const element = createElement('c-campaign-catalog', { is: CampaignCatalog });
        document.body.appendChild(element);
        getActiveCampaignsAdapter.emit([]);
        await Promise.resolve();
        expect(element.shadowRoot.textContent).toContain('No hay campañas activas por el momento. Vuelve pronto.');
    });

    it('renders c-campaign-share for each non-blocked campaign', async () => {
        const element = createElement('c-campaign-catalog', { is: CampaignCatalog });
        document.body.appendChild(element);
        getActiveCampaignsAdapter.emit(MOCK_CAMPAIGNS);
        await Promise.resolve();
        const shareComponents = element.shadowRoot.querySelectorAll('c-campaign-share');
        expect(shareComponents.length).toBe(2);
    });

    describe('URL param auto-select', () => {
        const originalLocation = window.location;

        beforeEach(() => {
            delete window.location;
        });

        afterEach(() => {
            window.location = originalLocation;
        });

        it('auto-selects the matching campaign when ?campaign=id is in the URL', async () => {
            window.location = {
                origin: 'https://test.salesforce.com',
                pathname: '/portal',
                search: '?campaign=a002'
            };
            const element = createElement('c-campaign-catalog', { is: CampaignCatalog });
            document.body.appendChild(element);
            getActiveCampaignsAdapter.emit(MOCK_CAMPAIGNS);
            await Promise.resolve();
            const donationForm = element.shadowRoot.querySelector('c-donation-form');
            expect(donationForm).not.toBeNull();
            expect(donationForm.campaign.id).toBe('a002');
        });

        it('does not auto-select a blocked campaign from the URL param', async () => {
            window.location = {
                origin: 'https://test.salesforce.com',
                pathname: '/portal',
                search: '?campaign=a003'
            };
            const element = createElement('c-campaign-catalog', { is: CampaignCatalog });
            document.body.appendChild(element);
            getActiveCampaignsAdapter.emit([
                { id: 'a003', name: 'Campaña Bloqueada', goalAmount: 1000, raisedAmount: 1000, progressPercent: 100, isDonationBlocked: true, blockedReason: 'Meta alcanzada' }
            ]);
            await Promise.resolve();
            const donationForm = element.shadowRoot.querySelector('c-donation-form');
            expect(donationForm).toBeNull();
        });
    });
});
