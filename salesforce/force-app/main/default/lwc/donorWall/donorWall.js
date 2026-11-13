import { LightningElement, api } from 'lwc';

export default class DonorWall extends LightningElement {
    _donors = [];
    _anonymousCount = 0;

    @api
    set donors(value) {
        this._donors = (value || []).map((donor) => ({
            ...donor,
            imageAlt: `Logo o foto de ${donor.displayName}`,
            initial: donor.displayName ? donor.displayName.charAt(0).toUpperCase() : 'D',
            recognitionTypeLabel: donor.recognitionType === 'Organization' ? 'ORGANIZACIÓN' : 'DONANTE'
        }));
    }

    get donors() {
        return this._donors;
    }

    @api
    set anonymousCount(value) {
        this._anonymousCount = Number(value) || 0;
    }

    get anonymousCount() {
        return this._anonymousCount;
    }

    get hasDonors() { return this.donors.length > 0; }
    get hasAnonymousDonors() { return this.anonymousCount > 0; }
    get hasAnyDonors() { return this.hasDonors || this.hasAnonymousDonors; }
    get anonymousLabel() {
        return this.anonymousCount === 1 ? '+ 1 Donante Anónimo' : `+ ${this.anonymousCount} Donantes Anónimos`;
    }
}
