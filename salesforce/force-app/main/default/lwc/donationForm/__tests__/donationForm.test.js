import { createElement } from 'lwc';
import DonationForm from 'c/donationForm';

const flushPromises = () => Promise.resolve();

describe('c-donation-form', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('clears public recognition when an anonymous donation is selected', async () => {
        const element = createElement('c-donation-form', { is: DonationForm });
        element.campaign = { id: 'a001', name: 'Education fund' };
        document.body.appendChild(element);
        await flushPromises();

        const inputs = element.shadowRoot.querySelectorAll('lightning-input');
        const recognition = inputs[4];
        recognition.name = 'wantsRecognition';
        recognition.type = 'checkbox';
        recognition.checked = true;
        recognition.dispatchEvent(new CustomEvent('change'));
        await flushPromises();

        const anonymous = inputs[3];
        anonymous.name = 'isAnonymous';
        anonymous.type = 'checkbox';
        anonymous.checked = true;
        anonymous.dispatchEvent(new CustomEvent('change'));
        await flushPromises();

        expect(inputs[4].checked).toBe(false);
        expect(element.shadowRoot.querySelector('.recognition-fields')).toBeNull();
    });
});
