public without sharing class PublicDonationController {
    public class DonationRequest {
        @AuraEnabled public Id campaignId;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public Boolean isAnonymous;
        @AuraEnabled public Boolean wantsRecognition;
        @AuraEnabled public Boolean needsInvoice;
        @AuraEnabled public String donorName;
        @AuraEnabled public String donorEmail;
        @AuraEnabled public String legalName;
        @AuraEnabled public String rfc;
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
            SELECT Id FROM Campaign__c
            WHERE Id = :request.campaignId AND Is_Active__c = true
            LIMIT 1
        ];
        String checkoutReference = 'MD-' + String.valueOf(Math.abs(Crypto.getRandomLong()));
        StripeCheckoutService.CheckoutResult checkout = StripeCheckoutService.createSession(
            request.amount,
            checkoutReference,
            request.successUrl,
            request.cancelUrl
        );
        Donation__c donation = new Donation__c(
            Campaign__c = campaign.Id,
            Amount__c = request.amount,
            Payment_Status__c = 'Pending',
            Is_Anonymous__c = request.isAnonymous,
            Wants_Recognition__c = request.isAnonymous ? false : request.wantsRecognition,
            Needs_Invoice__c = request.needsInvoice,
            Donor_Name__c = request.isAnonymous ? null : request.donorName,
            Donor_Email__c = request.donorEmail,
            Legal_Name__c = request.legalName,
            RFC__c = request.rfc == null ? null : request.rfc.trim().toUpperCase(),
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
        if (request.isAnonymous && request.needsInvoice) {
            throw new AuraHandledException('Anonymous donations cannot request an invoice.');
        }
        if (!request.isAnonymous && String.isBlank(request.donorName)) {
            throw new AuraHandledException('Provide your name or select anonymous donation.');
        }
        if (request.needsInvoice && (
            String.isBlank(request.legalName) || String.isBlank(request.rfc) ||
            !Pattern.matches('[A-Z&]{3,4}[0-9]{6}[A-Z0-9]{3}', request.rfc.trim().toUpperCase())
        )) {
            throw new AuraHandledException('Provide a valid legal name and RFC.');
        }
        if (String.isBlank(request.successUrl) || String.isBlank(request.cancelUrl)) {
            throw new AuraHandledException('Checkout return URLs are not configured.');
        }
    }
}
