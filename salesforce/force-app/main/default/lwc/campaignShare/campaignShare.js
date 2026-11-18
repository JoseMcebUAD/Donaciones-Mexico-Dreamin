import { LightningElement, api, track } from 'lwc';

export default class CampaignShare extends LightningElement {
    @api campaign;

    @track isOpen = false;
    @track copied = false;

    _copyTimer;

    get shareUrl() {
        if (!this.campaign) return '';
        return (
            window.location.origin +
            window.location.pathname +
            '?campaign=' + encodeURIComponent(this.campaign.id)
        );
    }

    get facebookUrl() {
        return 'https://www.facebook.com/sharer/sharer.php?u=' +
            encodeURIComponent(this.shareUrl);
    }

    get whatsappUrl() {
        const text = encodeURIComponent(this.campaign.name + ' — ' + this.shareUrl);
        return 'https://wa.me/?text=' + text;
    }

    get xUrl() {
        const message = encodeURIComponent('Apoya esta causa: ' + this.campaign.name);
        return (
            'https://twitter.com/intent/tweet?url=' +
            encodeURIComponent(this.shareUrl) +
            '&text=' + message
        );
    }

    get linkedinUrl() {
        return 'https://www.linkedin.com/sharing/share-offsite/?url=' +
            encodeURIComponent(this.shareUrl);
    }

    get emailUrl() {
        const subject = encodeURIComponent('Apoya: ' + (this.campaign ? this.campaign.name : ''));
        const body = encodeURIComponent('Te comparto esta campaña de donación:\n' + this.shareUrl);
        return 'mailto:?subject=' + subject + '&body=' + body;
    }

    openPopup() {
        this.isOpen = true;
        this.copied = false;
        Promise.resolve().then(() => {
            const popup = this.template.querySelector('.share-popup');
            if (popup && typeof popup.focus === 'function') {
                popup.focus();
            }
        });
    }

    closePopup() {
        this.isOpen = false;
        this.copied = false;
        if (this._copyTimer) {
            clearTimeout(this._copyTimer);
            this._copyTimer = null;
        }
    }

    handleBackdropClick(event) {
        if (event.target === event.currentTarget) {
            this.closePopup();
        }
    }

    handleKeyDown(event) {
        if (event.key === 'Escape') {
            this.closePopup();
        }
    }

    stopPropagation(event) {
        event.stopPropagation();
    }

    copyLink() {
        const url = this.shareUrl;
        if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(url)
                .then(() => { this._showCopied(); })
                .catch(() => { this._fallbackCopy(url); });
        } else {
            this._fallbackCopy(url);
        }
    }

    _showCopied() {
        this.copied = true;
        if (this._copyTimer) clearTimeout(this._copyTimer);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this._copyTimer = setTimeout(() => {
            this.copied = false;
            this._copyTimer = null;
        }, 2500);
    }

    _fallbackCopy(url) {
        const el = document.createElement('textarea');
        el.value = url;
        el.style.position = 'fixed';
        el.style.top = '-999px';
        el.style.left = '-999px';
        document.body.appendChild(el);
        el.focus();
        el.select();
        try {
            document.execCommand('copy');
            this._showCopied();
        } catch {
            // silent fail — URL visible en pantalla para copia manual
        }
        document.body.removeChild(el);
    }

    disconnectedCallback() {
        if (this._copyTimer) {
            clearTimeout(this._copyTimer);
        }
    }
}
