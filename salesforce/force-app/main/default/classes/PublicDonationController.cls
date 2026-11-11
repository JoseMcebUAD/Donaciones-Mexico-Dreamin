public without sharing class PublicDonationController {
    public class DonationRequest {
        @AuraEnabled public Id campaignId;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public Boolean isAnonymous;
        @AuraEnabled public Boolean wantsRecognition;
        @AuraEnabled public String recognitionType;
        @AuraEnabled public String recognitionName;
        @AuraEnabled public String recognitionImageUrl;
        @AuraEnabled public Boolean needsInvoice;
        @AuraEnabled public String donorName;
        @AuraEnabled public String donorEmail;
        @AuraEnabled public String legalName;
        @AuraEnabled public String rfc;
        @AuraEnabled public String postalCode;
        @AuraEnabled public String taxRegime;
        @AuraEnabled public String cfdiUse;
        @AuraEnabled public String successUrl;
        @AuraEnabled public String cancelUrl;
    }

    public class CheckoutResponse {
        @AuraEnabled public Id donationId;
        @AuraEnabled public String checkoutUrl;
    }

    @AuraEnabled
    public static CheckoutResponse startDonation(DonationRequest request) {
        validate(request);
        Campaign__c campaign = [
            SELECT Id, Goal_Amount__c, Raised_Amount__c, Allow_Additional_Donations__c, Expiration_Date__c
            FROM Campaign__c
            WHERE Id = :request.campaignId AND Is_Active__c = true
            LIMIT 1
        ];
        if (campaign.Expiration_Date__c != null && campaign.Expiration_Date__c < Date.today()) {
            throw new AuraHandledException('Esta campaña ha cerrado y no admite nuevas donaciones.');
        }
        if (!campaign.Allow_Additional_Donations__c && campaign.Goal_Amount__c > 0) {
            Decimal raised = campaign.Raised_Amount__c == null ? 0 : campaign.Raised_Amount__c;
            if (raised >= campaign.Goal_Amount__c) {
                throw new AuraHandledException('Esta campaña alcanzó su meta y no admite nuevas donaciones.');
            }
        }
        String checkoutReference = 'MD-' + String.valueOf(Math.abs(Crypto.getRandomLong()));
        StripeCheckoutService.CheckoutResult checkout = StripeCheckoutService.createSession(
            request.amount,
            checkoutReference,
            request.donorEmail,
            request.successUrl,
            request.cancelUrl
        );
        Donation__c donation = new Donation__c(
            Campaign__c = campaign.Id,
            Amount__c = request.amount,
            Payment_Status__c = 'Pending',
            Is_Anonymous__c = request.isAnonymous,
            Wants_Recognition__c = request.isAnonymous ? false : request.wantsRecognition,
            Recognition_Type__c = request.wantsRecognition ? request.recognitionType : null,
            Recognition_Name__c = request.wantsRecognition ? request.recognitionName.trim() : null,
            Recognition_Image_URL__c = request.wantsRecognition && !String.isBlank(request.recognitionImageUrl)
                ? request.recognitionImageUrl.trim()
                : null,
            Needs_Invoice__c = request.needsInvoice,
            Donor_Name__c = request.isAnonymous ? null : request.donorName,
            Donor_Email__c = request.donorEmail,
            Legal_Name__c = request.legalName,
            RFC__c = request.rfc == null ? null : request.rfc.trim().toUpperCase(),
            Postal_Code__c = request.postalCode,
            Tax_Regime__c = request.taxRegime,
            CFDI_Use__c = request.cfdiUse,
            Checkout_Reference__c = checkoutReference,
            Stripe_Session_Id__c = checkout.id
        );
        insert donation;
        CheckoutResponse result = new CheckoutResponse();
        result.donationId = donation.Id;
        result.checkoutUrl = checkout.url;
        return result;
    }

    private static void validate(DonationRequest request) {
        if (request == null || request.campaignId == null || request.amount == null || request.amount <= 0) {
            throw new AuraHandledException('Select an active campaign and a positive amount.');
        }
        if (String.isBlank(request.donorEmail)) {
            throw new AuraHandledException('An email address is required for the receipt.');
        }
        if (!request.isAnonymous && String.isBlank(request.donorName)) {
            throw new AuraHandledException('Provide your name or select anonymous donation.');
        }
        if (request.wantsRecognition) {
            if (request.isAnonymous) {
                throw new AuraHandledException('Anonymous donations cannot be displayed on the recognition wall.');
            }
            if (String.isBlank(request.recognitionName)) {
                throw new AuraHandledException('Provide the name to display on the recognition wall.');
            }
            if (request.recognitionType != 'Individual' && request.recognitionType != 'Organization') {
                throw new AuraHandledException('Select whether the public recognition is for an individual or an organization.');
            }
            if (!String.isBlank(request.recognitionImageUrl) &&
                !Pattern.matches('https://[^\\s]+', request.recognitionImageUrl.trim())) {
                throw new AuraHandledException('The public logo or photo URL must use HTTPS.');
            }
        }
        if (request.needsInvoice && (
            String.isBlank(request.legalName) || String.isBlank(request.rfc) ||
            !Pattern.matches('[A-Z&]{3,4}[0-9]{6}[A-Z0-9]{3}', request.rfc.trim().toUpperCase()) ||
            String.isBlank(request.postalCode) || String.isBlank(request.taxRegime) || String.isBlank(request.cfdiUse)
        )) {
            throw new AuraHandledException('Provide a valid legal name, RFC, postal code, tax regime, and CFDI use.');
        }
        if (String.isBlank(request.successUrl) || String.isBlank(request.cancelUrl)) {
            throw new AuraHandledException('Checkout return URLs are not configured.');
        }
    }
}
