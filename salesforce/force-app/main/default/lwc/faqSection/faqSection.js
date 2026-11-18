import { LightningElement, track } from 'lwc';
import createCase from '@salesforce/apex/ContactController.createCase';

const FAQ_DATA = [
    {
        id: '1',
        question: '¿Cómo funciona el proceso de donación?',
        answer: 'Selecciona la campaña que deseas apoyar y haz clic en "Apoyar esta causa". Elige un monto sugerido o escribe el tuyo (mínimo $10 MXN), llena tus datos y haz clic en "Continuar al pago seguro". Serás redirigido a Stripe para completar el pago con tu tarjeta. Una vez confirmado, recibirás un correo de agradecimiento y, si lo solicitaste, tu nombre aparecerá en el muro de reconocimiento.'
    },
    {
        id: '2',
        question: '¿Cómo aparece mi nombre en el muro de reconocimiento?',
        answer: 'Durante el proceso de donación, activa la opción "Autorizo mostrar mi nombre y monto en el muro". Podrás elegir si apareces como individuo o como empresa, escribir el nombre que deseas mostrar y, opcionalmente, agregar la URL de tu foto o logo. Tu nombre se mostrará en el muro una vez que el pago sea confirmado. Si prefieres permanecer anónimo, simplemente activa la opción "Quiero donar de forma anónima".'
    },
    {
        id: '3',
        question: '¿Es seguro mi pago y mis datos personales?',
        answer: 'Sí. Los pagos son procesados por Stripe, certificado PCI-DSS nivel 1, el estándar más alto de seguridad en pagos en línea. Mexico Dreamin nunca almacena ni tiene acceso a los datos de tu tarjeta. Tus datos personales (nombre y correo) se usan únicamente para gestionar tu donativo y, si lo solicitas, emitir tu CFDI. Consulta nuestro aviso de privacidad para más información.'
    }
];

export default class FaqSection extends LightningElement {
    @track faqItems = FAQ_DATA.map((item) => ({ ...item, isOpen: false, iconName: 'utility:chevronright' }));
    contactName = '';
    contactEmail = '';
    contactMessage = '';
    contactError;
    isSending = false;
    submitted = false;

    toggleItem(event) {
        const id = event.currentTarget.dataset.id;
        this.faqItems = this.faqItems.map((item) => {
            if (item.id === id) {
                const isOpen = !item.isOpen;
                return { ...item, isOpen, iconName: isOpen ? 'utility:chevrondown' : 'utility:chevronright' };
            }
            return item;
        });
    }

    handleContactChange(event) {
        this[event.target.name] = event.target.value;
    }

    async sendMessage() {
        const inputs = [...this.template.querySelectorAll('lightning-input, lightning-textarea')];
        if (!inputs.every((f) => f.checkValidity())) {
            inputs.forEach((f) => f.reportValidity());
            return;
        }
        this.contactError = undefined;
        this.isSending = true;
        try {
            await createCase({
                name: this.contactName,
                email: this.contactEmail,
                message: this.contactMessage
            });
            this.submitted = true;
        } catch (error) {
            this.contactError = error.body?.message || 'No se pudo enviar el mensaje. Intenta de nuevo.';
        } finally {
            this.isSending = false;
        }
    }
}
