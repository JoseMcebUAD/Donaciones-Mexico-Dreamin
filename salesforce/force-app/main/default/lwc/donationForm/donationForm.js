import { LightningElement, api } from 'lwc';
import startDonation from '@salesforce/apex/PublicDonationController.startDonation';

const TAX_REGIME_OPTIONS = [
    { label: '601 - General de Ley Personas Morales', value: '601' },
    { label: '603 - Personas Morales con Fines no Lucrativos', value: '603' },
    { label: '605 - Sueldos y Salarios e Ingresos Asimilados', value: '605' },
    { label: '606 - Arrendamiento', value: '606' },
    { label: '608 - Demás Ingresos', value: '608' },
    { label: '612 - Personas Físicas con Actividades Empresariales y Profesionales', value: '612' },
    { label: '616 - Sin obligaciones fiscales', value: '616' },
    { label: '621 - Incorporación Fiscal', value: '621' },
    { label: '625 - Plataformas Tecnológicas', value: '625' },
    { label: '626 - Régimen Simplificado de Confianza (RESICO)', value: '626' }
];

const CFDI_USE_OPTIONS = [
    { label: 'D04 - Donativos', value: 'D04' },
    { label: 'G01 - Adquisición de mercancias', value: 'G01' },
    { label: 'G03 - Gastos en general', value: 'G03' },
    { label: 'D01 - Honorarios médicos, dentales y gastos hospitalarios', value: 'D01' },
    { label: 'D10 - Pagos por servicios educativos (colegiaturas)', value: 'D10' },
    { label: 'CN01 - Nómina', value: 'CN01' },
    { label: 'CP01 - Pagos', value: 'CP01' },
    { label: 'S01 - Sin efectos fiscales', value: 'S01' }
];

const MAX_IMAGE_SIZE_BYTES = 2 * 1024 * 1024;

export default class DonationForm extends LightningElement {
    @api campaign;
    amount = 500;
    isAnonymous = false;
    wantsRecognition = false;
    needsInvoice = false;
    postalCode = '';
    taxRegime = '';
    cfdiUse = 'D04';
    recognitionImageBase64 = null;
    recognitionImageFileName = null;
    isLoading = false;
    error;
    privacyAccepted = false;
    showPrivacyText = false;

    get nameRequired() {
        return !this.isAnonymous;
    }

    get taxRegimeOptions() {
        return TAX_REGIME_OPTIONS;
    }

    get cfdiUseOptions() {
        return CFDI_USE_OPTIONS;
    }

    get recognitionTypeOptions() {
        return RECOGNITION_TYPE_OPTIONS;
    }

    get recognitionNameLabel() {
        return this.recognitionType === 'Organization'
            ? 'Nombre de la empresa u organización'
            : 'Nombre para mostrar';
    }

    get privacyLinkLabel() {
        return this.showPrivacyText ? 'Ocultar aviso' : 'Ver aviso de privacidad';
    }

    togglePrivacyText() {
        this.showPrivacyText = !this.showPrivacyText;
    }

    handleChange(event) {
        const name = event.target.name;
        this[name] = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
        if (name === 'isAnonymous' && event.target.checked) {
            this.wantsRecognition = false;
        }
    }

    handleComboChange(event) {
        this[event.target.name] = event.detail.value;
    }

    handleImageChange(event) {
        const file = event.target.files[0];
        if (!file) {
            this.recognitionImageBase64 = null;
            this.recognitionImageFileName = null;
            return;
        }
        if (file.size > MAX_IMAGE_SIZE_BYTES) {
            this.error = 'La imagen no debe superar 2 MB.';
            event.target.value = '';
            return;
        }
        this.recognitionImageFileName = file.name;
        const reader = new FileReader();
        reader.onload = () => {
            this.recognitionImageBase64 = reader.result;
        };
        reader.readAsDataURL(file);
    }

    selectAmount(event) {
        this.amount = Number(event.target.dataset.amount);
    }

    async submit() {
        const fields = [...this.template.querySelectorAll('lightning-input')];
        const combos = [...this.template.querySelectorAll('lightning-combobox')];
        if (!fields.every((f) => f.checkValidity()) || !combos.every((c) => c.checkValidity())) {
            fields.forEach((f) => f.reportValidity());
            combos.forEach((c) => c.reportValidity());
            return;
        }
        if (!this.privacyAccepted) {
            this.error = 'Debes aceptar el aviso de privacidad para continuar.';
            return;
        }
        this.error = undefined;
        this.isLoading = true;
        try {
            const response = await startDonation({
                campaignId: this.campaign.id,
                amount: Number(this.amount),
                isAnonymous: this.isAnonymous,
                wantsRecognition: this.wantsRecognition,
                recognitionName: this.template.querySelector('[name="recognitionName"]')?.value,
                recognitionImageBase64: this.recognitionImageBase64,
                recognitionImageFileName: this.recognitionImageFileName,
                needsInvoice: this.needsInvoice,
                donorName: this.template.querySelector('[name="donorName"]').value,
                donorEmail: this.template.querySelector('[name="donorEmail"]').value,
                legalName: this.template.querySelector('[name="legalName"]')?.value,
                rfc: this.template.querySelector('[name="rfc"]')?.value,
                postalCode: this.template.querySelector('[name="postalCode"]')?.value,
                taxRegime: this.taxRegime,
                cfdiUse: this.cfdiUse
            });
            window.location.assign(response.checkoutUrl);
        } catch (error) {
            this.error = error.body?.message || 'Unable to start checkout.';
        } finally {
            this.isLoading = false;
        }
    }
}
