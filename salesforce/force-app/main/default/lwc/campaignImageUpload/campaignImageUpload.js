import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import publishCoverImage from '@salesforce/apex/CampaignImageService.publishCoverImage';
import getCoverImages from '@salesforce/apex/CampaignImageService.getCoverImages';
import COVER_IMAGE_URL_FIELD from '@salesforce/schema/Campaign__c.Cover_Image_URL__c';

export default class CampaignImageUpload extends LightningElement {
    @api recordId;

    @track isUploading = false;
    @track uploadError = null;

    _wiredImagesResult;
    @track allImages = [];

    @wire(getRecord, { recordId: '$recordId', fields: [COVER_IMAGE_URL_FIELD] })
    wiredRecord;

    get currentCoverUrl() {
        return getFieldValue(this.wiredRecord.data, COVER_IMAGE_URL_FIELD);
    }

    @wire(getCoverImages, { campaignId: '$recordId' })
    wiredImages(result) {
        this._wiredImagesResult = result;
        if (result.data) {
            this.allImages = result.data;
        }
    }

    async handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        if (!uploadedFiles || uploadedFiles.length === 0) return;

        this.isUploading = true;
        this.uploadError = null;

        try {
            await publishCoverImage({
                campaignId: this.recordId,
                contentDocumentId: uploadedFiles[0].documentId
            });
            await refreshApex(this._wiredImagesResult);
            await refreshApex(this.wiredRecord);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Imagen publicada',
                message: 'La imagen de portada se actualizó correctamente.',
                variant: 'success'
            }));
        } catch (error) {
            this.uploadError = error?.body?.message ?? 'Error al publicar la imagen.';
        } finally {
            this.isUploading = false;
        }
    }

    async handleSetCover(event) {
        const contentDocumentId = event.currentTarget.dataset.id;
        this.isUploading = true;
        this.uploadError = null;

        try {
            await publishCoverImage({ campaignId: this.recordId, contentDocumentId });
            await refreshApex(this.wiredRecord);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Portada actualizada',
                message: 'La imagen de portada se cambió correctamente.',
                variant: 'success'
            }));
        } catch (error) {
            this.uploadError = error?.body?.message ?? 'Error al cambiar la portada.';
        } finally {
            this.isUploading = false;
        }
    }
}
