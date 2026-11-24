public without sharing class StripeWebhookService {
    public class WebhookSecurityException extends Exception {}
    public class WebhookReferenceException extends Exception {}

    private static final Integer TIMESTAMP_TOLERANCE_SECONDS = 300;

    public static void verifySignature(String rawBody, String sigHeader, String secret) {
        if (String.isBlank(sigHeader) || String.isBlank(secret)) {
            throw new WebhookSecurityException('Missing signature or secret.');
        }
        String timestamp = null;
        String receivedSig = null;
        for (String part : sigHeader.split(',')) {
            if (part.startsWith('t=')) {
                timestamp = part.substringAfter('t=');
            } else if (part.startsWith('v1=')) {
                receivedSig = part.substringAfter('v1=');
            }
        }
        if (String.isBlank(timestamp) || String.isBlank(receivedSig)) {
            throw new WebhookSecurityException('Malformed Stripe-Signature header.');
        }
        Long eventTime = Long.valueOf(timestamp);
        Long nowSeconds = DateTime.now().getTime() / 1000;
        if (Math.abs(nowSeconds - eventTime) > TIMESTAMP_TOLERANCE_SECONDS) {
            throw new WebhookSecurityException('Webhook timestamp outside tolerance window.');
        }
        Blob computedMac = Crypto.generateMac(
            'hmacSHA256',
            Blob.valueOf(timestamp + '.' + rawBody),
            Blob.valueOf(secret)
        );
        String computedSig = EncodingUtil.convertToHex(computedMac);
        if (computedSig != receivedSig) {
            throw new WebhookSecurityException('Signature mismatch.');
        }
    }

    public static void processEvent(String rawBody) {
        if (String.isBlank(rawBody)) {
            throw new IllegalArgumentException('Empty webhook body.');
        }
        Map<String, Object> event = (Map<String, Object>) JSON.deserializeUntyped(rawBody);
        String eventType = (String) event.get('type');
        Map<String, Object> data = (Map<String, Object>) event.get('data');
        Map<String, Object> obj = data != null ? (Map<String, Object>) data.get('object') : null;
        String checkoutReference = obj != null ? (String) obj.get('client_reference_id') : null;

        if (eventType == 'checkout.session.completed') {
            markDonation(checkoutReference, 'Paid');
        } else if (eventType == 'checkout.session.expired') {
            markDonation(checkoutReference, 'Cancelled');
        }
    }

    private static void markDonation(String checkoutReference, String newStatus) {
        Donation__c donation = PublicDonationCommandService.findDonationByCheckoutReference(checkoutReference);
        if (donation == null) {
            // Distinguish duplicate (already processed) from unknown reference
            List<Donation__c> existing = [
                SELECT Id FROM Donation__c
                WHERE Checkout_Reference__c = :checkoutReference
                WITH SYSTEM_MODE LIMIT 1
            ];
            if (!existing.isEmpty()) {
                return; // already processed — idempotent, no further action
            }
            throw new WebhookReferenceException('Checkout reference not found: ' + checkoutReference);
        }
        Database.update(
            new Donation__c(Id = donation.Id, Payment_Status__c = newStatus),
            AccessLevel.SYSTEM_MODE
        );
        if (newStatus == 'Paid') {
            try {
                DonationManagementService.sendReceiptEmail(donation.Id);
            } catch (Exception emailEx) {
                System.debug(LoggingLevel.ERROR, 'Receipt email failed for donation ' + donation.Id + ': ' + emailEx.getMessage());
            }
        }
    }
}
