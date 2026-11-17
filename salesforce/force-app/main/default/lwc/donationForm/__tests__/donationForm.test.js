import { createElement } from 'lwc';
import DonationForm from 'c/donationForm';

describe('c-donation-form', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('clears public recognition and invoice selections when made anonymous', () => {
        const element = createElement('c-donation-form', { is: DonationForm });
        element.campaign = { id: 'a001', name: 'Education fund' };
        document.body.appendChild(element);
        element.wantsRecognition = true;
        element.needsInvoice = true;
        element.handleChange({ target: { name: 'isAnonymous', type: 'checkbox', checked: true } });
        expect(element.isAnonymous).toBe(true);
        expect(element.wantsRecognition).toBe(false);
        expect(element.needsInvoice).toBe(false);
    });

    it('enforces the Stripe minimum amount of 10 MXN on the amount input', () => {
        const element = createElement('c-donation-form', { is: DonationForm });
        element.campaign = { id: 'a001', name: 'Education fund' };
        document.body.appendChild(element);
        const amountInput = element.shadowRoot.querySelector('lightning-input[name="amount"]');
        expect(amountInput).not.toBeNull();
        expect(amountInput.min).toBe('10');
    });
});
