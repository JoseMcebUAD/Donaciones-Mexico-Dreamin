public without sharing class PublicDonationController {
    private static final Decimal MIN_DONATION_AMOUNT_MXN = 10.00;

    public class DonationRequest {
        @AuraEnabled public Id campaignId;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public Boolean isAnonymous;
        @AuraEnabled public Boolean wantsRecognition;
        @AuraEnabled public String recognitionName;
        @AuraEnabled public String recognitionImageBase64;
        @AuraEnabled public String recognitionImageFileName;
        @AuraEnabled public Boolean needsInvoice;
        @AuraEnabled public String donorName;
        @AuraEnabled public String donorEmail;
        @AuraEnabled public String legalName;
        @AuraEnabled public String rfc;
        @AuraEnabled public String postalCode;
        @AuraEnabled public String taxRegime;
        @AuraEnabled public String cfdiUse;
        @AuraEnabled public Boolean privacyAccepted;
    }

    public class CheckoutResponse {
        @AuraEnabled public String checkoutReference;
        @AuraEnabled public String checkoutUrl;
    }

    @AuraEnabled
    public static CheckoutResponse prepareDonation(DonationRequest request) {
        validate(request);
        Campaign__c campaign = PublicDonationCommandService.findActiveCampaign(request.campaignId);
        validateCampaignCapacity(campaign);

        String checkoutReference = 'MD-' + EncodingUtil.convertToHex(Crypto.generateAesKey(128));
        PublicDonationCommandService.createPendingDonation(request, campaign.Id, checkoutReference, null);
        CheckoutResponse result = new CheckoutResponse();
        result.checkoutReference = checkoutReference;
        return result;
    }

    @AuraEnabled
    public static CheckoutResponse openCheckout(String checkoutReference) {
        Donation__c donation = PublicDonationCommandService.findPendingDonation(checkoutReference);
        Campaign__c campaign = PublicDonationCommandService.findActiveCampaign(donation.Campaign__c);
        validateCampaignCapacity(campaign);
        StripeCheckoutService.CheckoutResult checkout = StripeCheckoutService.createSession(
            donation.Amount__c,
            checkoutReference,
            donation.Donor_Email__c,
            successUrl(),
            cancelUrl()
        );
        PublicDonationCommandService.attachCheckoutSession(donation.Id, checkout.id);
        CheckoutResponse result = new CheckoutResponse();
        result.checkoutUrl = checkout.url;
        return result;
    }

    private static void validateCampaignCapacity(Campaign__c campaign) {
        if (campaign.Expiration_Date__c != null && campaign.Expiration_Date__c < Date.today()) {
            throw new AuraHandledException('Esta campaña ha cerrado y no admite nuevas donaciones.');
        }
        if (!campaign.Allow_Additional_Donations__c && campaign.Goal_Amount__c > 0) {
            Decimal raised = campaign.Raised_Amount__c == null ? 0 : campaign.Raised_Amount__c;
            if (raised >= campaign.Goal_Amount__c) {
                throw new AuraHandledException('Esta campaña alcanzó su meta y no admite nuevas donaciones.');
            }
        }
    }

    private static void validate(DonationRequest request) {
        if (request == null || request.campaignId == null) {
            throw new AuraHandledException('Selecciona una campaña activa.');
        }
        if (request.amount == null || request.amount < MIN_DONATION_AMOUNT_MXN) {
            throw new AuraHandledException('El monto mínimo de donación es de $10.00 MXN.');
        }
        if (String.isBlank(request.donorEmail)) {
            throw new AuraHandledException('An email address is required for the receipt.');
        }
        if (request.isAnonymous != true && String.isBlank(request.donorName)) {
            throw new AuraHandledException('Provide your name or select anonymous donation.');
        }
        if (request.wantsRecognition == true) {
            if (request.isAnonymous == true) {
                throw new AuraHandledException('Anonymous donations cannot be displayed on the recognition wall.');
            }
            if (String.isBlank(request.recognitionName)) {
                throw new AuraHandledException('Provide the name to display on the recognition wall.');
            }
        }
        if (request.needsInvoice && (
            String.isBlank(request.legalName) || String.isBlank(request.rfc) ||
            !Pattern.matches('[A-Z&]{3,4}[0-9]{6}[A-Z0-9]{3}', request.rfc.trim().toUpperCase()) ||
            String.isBlank(request.postalCode) || String.isBlank(request.taxRegime) || String.isBlank(request.cfdiUse)
        )) {
            throw new AuraHandledException('Provide a valid legal name, RFC, postal code, tax regime, and CFDI use.');
        }
        if (request.privacyAccepted != true) {
            throw new AuraHandledException('Debes aceptar el aviso de privacidad para continuar.');
        }
        if (request.isAnonymous == true && request.needsInvoice == true) {
            throw new AuraHandledException('Una donación anónima no puede solicitar factura.');
        }
    }

    private static String portalBaseUrl() {
        String baseUrl = System.Label.Donation_Portal_Base_URL;
        if (String.isBlank(baseUrl) || !baseUrl.startsWith('https://') || baseUrl.endsWith('/')) {
            throw new AuraHandledException('Checkout is temporarily unavailable. Please try again later.');
        }
        return baseUrl;
    }

    private static String successUrl() {
        return portalBaseUrl() + '/thank-you?session_id={CHECKOUT_SESSION_ID}';
    }

    private static String cancelUrl() {
        return portalBaseUrl() + '/';
    }
}
