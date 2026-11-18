import { createElement } from 'lwc';
import DonationForm from 'c/donationForm';

const flushPromises = () => Promise.resolve();

describe('c-donation-form', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('clears public recognition when made anonymous while keeping invoice independent', async () => {
        const element = createElement('c-donation-form', { is: DonationForm });
        element.campaign = { id: 'a001', name: 'Education fund' };
        document.body.appendChild(element);

        const findInput = (name) =>
            [...element.shadowRoot.querySelectorAll('lightning-input')].find(
                (input) => input.name === name
            );

        const wantsRecognitionInput = findInput('wantsRecognition');
        const needsInvoiceInput = findInput('needsInvoice');
        const isAnonymousInput = findInput('isAnonymous');

        wantsRecognitionInput.checked = true;
        wantsRecognitionInput.dispatchEvent(new CustomEvent('change'));
        needsInvoiceInput.checked = true;
        needsInvoiceInput.dispatchEvent(new CustomEvent('change'));
        await Promise.resolve();

        expect(element.shadowRoot.querySelector('.recognition-fields')).not.toBeNull();
        expect(element.shadowRoot.querySelector('.invoice-fields')).not.toBeNull();

        isAnonymousInput.checked = true;
        isAnonymousInput.dispatchEvent(new CustomEvent('change'));
        await Promise.resolve();

        expect(wantsRecognitionInput.checked).toBe(false);
        expect(wantsRecognitionInput.disabled).toBe(true);
        expect(needsInvoiceInput.checked).toBe(true);
        expect(element.shadowRoot.querySelector('.recognition-fields')).toBeNull();
        expect(element.shadowRoot.querySelector('.invoice-fields')).not.toBeNull();
    });

    it('enforces the Stripe minimum amount of 10 MXN on the amount input', async () => {
        const element = createElement('c-donation-form', { is: DonationForm });
        element.campaign = { id: 'a001', name: 'Education fund' };
        document.body.appendChild(element);
        await flushPromises();
        const amountInput = [...element.shadowRoot.querySelectorAll('lightning-input')].find(
            (input) => input.name === 'amount'
        );
        expect(amountInput).not.toBeUndefined();
        expect(String(amountInput.min)).toBe('10');
    });
});
