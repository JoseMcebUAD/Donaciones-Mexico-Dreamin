import { createElement } from 'lwc';
import CampaignShare from 'c/campaignShare';

const MOCK_CAMPAIGN = {
    id: 'a001',
    name: 'Becas para Ingeniería',
    isDonationBlocked: false
};

const originalLocation = window.location;

beforeEach(() => {
    delete window.location;
    window.location = {
        origin: 'https://test.salesforce.com',
        pathname: '/portal',
        search: ''
    };
});

afterEach(() => {
    window.location = originalLocation;
    while (document.body.firstChild) {
        document.body.removeChild(document.body.firstChild);
    }
});

function mountShare(campaign = MOCK_CAMPAIGN) {
    const el = createElement('c-campaign-share', { is: CampaignShare });
    el.campaign = campaign;
    document.body.appendChild(el);
    return el;
}

describe('c-campaign-share', () => {
    it('renders the share button and no popup by default', () => {
        const el = mountShare();
        expect(el.shadowRoot.querySelector('.share-button')).not.toBeNull();
        expect(el.shadowRoot.querySelector('.share-popup')).toBeNull();
    });

    it('opens the popup when the share button is clicked', async () => {
        const el = mountShare();
        el.shadowRoot.querySelector('.share-button').click();
        await Promise.resolve();
        expect(el.shadowRoot.querySelector('.share-popup')).not.toBeNull();
    });

    it('shows the campaign name as the popup title', async () => {
        const el = mountShare();
        el.shadowRoot.querySelector('.share-button').click();
        await Promise.resolve();
        const title = el.shadowRoot.querySelector('.share-popup-title');
        expect(title.textContent).toContain('Becas para Ingeniería');
    });

    it('closes the popup when the close button is clicked', async () => {
        const el = mountShare();
        el.shadowRoot.querySelector('.share-button').click();
        await Promise.resolve();
        el.shadowRoot.querySelector('.share-close').click();
        await Promise.resolve();
        expect(el.shadowRoot.querySelector('.share-popup')).toBeNull();
    });

    it('closes the popup when the backdrop itself is clicked', async () => {
        const el = mountShare();
        el.shadowRoot.querySelector('.share-button').click();
        await Promise.resolve();
        el.shadowRoot.querySelector('.share-backdrop').click();
        await Promise.resolve();
        expect(el.shadowRoot.querySelector('.share-popup')).toBeNull();
    });

    it('closes the popup when Escape is pressed', async () => {
        const el = mountShare();
        el.shadowRoot.querySelector('.share-button').click();
        await Promise.resolve();
        el.shadowRoot
            .querySelector('.share-backdrop')
            .dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }));
        await Promise.resolve();
        expect(el.shadowRoot.querySelector('.share-popup')).toBeNull();
    });

    it('constructs the share URL using window.location + campaign id', async () => {
        const el = mountShare();
        el.shadowRoot.querySelector('.share-button').click();
        await Promise.resolve();
        const urlDisplay = el.shadowRoot.querySelector('.share-url-display');
        expect(urlDisplay.textContent).toContain(
            'https://test.salesforce.com/portal?campaign=a001'
        );
    });

    it('generates a valid Facebook share URL', async () => {
        const el = mountShare();
        el.shadowRoot.querySelector('.share-button').click();
        await Promise.resolve();
        const link = el.shadowRoot.querySelector('.share-fb');
        expect(link.getAttribute('href')).toContain('facebook.com/sharer');
        expect(link.getAttribute('href')).toContain(
            encodeURIComponent('https://test.salesforce.com/portal?campaign=a001')
        );
    });

    it('generates a WhatsApp URL that includes the campaign name', async () => {
        const el = mountShare();
        el.shadowRoot.querySelector('.share-button').click();
        await Promise.resolve();
        const link = el.shadowRoot.querySelector('.share-wa');
        const href = link.getAttribute('href');
        expect(href).toContain('wa.me');
        expect(decodeURIComponent(href)).toContain('Becas para Ingeniería');
    });

    it('all social share links (except email) have target="_blank"', async () => {
        const el = mountShare();
        el.shadowRoot.querySelector('.share-button').click();
        await Promise.resolve();
        const links = el.shadowRoot.querySelectorAll('.share-fb, .share-wa, .share-x, .share-li');
        expect(links.length).toBe(4);
        links.forEach((link) => {
            expect(link.getAttribute('target')).toBe('_blank');
        });
    });

    it('shows "¡Copiado!" confirmation after the copy button is clicked', async () => {
        Object.assign(navigator, {
            clipboard: { writeText: jest.fn().mockResolvedValue(undefined) }
        });
        const el = mountShare();
        el.shadowRoot.querySelector('.share-button').click();
        await Promise.resolve();
        el.shadowRoot.querySelector('.share-copy-button').click();
        // allow clipboard promise + LWC reactive update
        await Promise.resolve();
        await Promise.resolve();
        expect(el.shadowRoot.querySelector('.share-copy-button').textContent.trim()).toBe('¡Copiado!');
    });
});
