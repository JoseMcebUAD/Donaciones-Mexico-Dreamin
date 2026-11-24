public without sharing class StripeWebhookService {
    public class WebhookSecurityException extends Exception {}
    public class WebhookReferenceException extends Exception {}

    private static final Integer TIMESTAMP_TOLERANCE_SECONDS = 300;

    public static void verifySignature(String rawBody, String sigHeader, String secret) {
        if (String.isBlank(sigHeader) || String.isBlank(secret)) {
            throw new WebhookSecurityException('Missing signature or secret.');
        }
        String timestamp = null;
        List<String> receivedSignatures = new List<String>();
        for (String part : sigHeader.split(',')) {
            part = part.trim();
            if (part.startsWith('t=')) {
                timestamp = part.substringAfter('t=');
            } else if (part.startsWith('v1=')) {
                receivedSignatures.add(part.substringAfter('v1='));
            }
        }
        if (String.isBlank(timestamp) || receivedSignatures.isEmpty()) {
            throw new WebhookSecurityException('Malformed Stripe-Signature header.');
        }
        Long eventTime;
        try {
            eventTime = Long.valueOf(timestamp);
        } catch (Exception ex) {
            throw new WebhookSecurityException('Malformed Stripe-Signature timestamp.');
        }
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
        if (!receivedSignatures.contains(computedSig)) {
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
        if (eventType == 'checkout.session.completed' ||
            eventType == 'checkout.session.async_payment_succeeded') {
            markDonation(obj, 'Paid');
        } else if (eventType == 'checkout.session.expired') {
            markDonation(obj, 'Cancelled');
        }
    }

    private static void markDonation(Map<String, Object> session, String newStatus) {
        if (session == null) {
            throw new WebhookReferenceException('Missing Checkout Session.');
        }
        String checkoutReference = (String) session.get('client_reference_id');
        String sessionId = (String) session.get('id');
        if (String.isBlank(checkoutReference) || String.isBlank(sessionId)) {
            throw new WebhookReferenceException('Missing Checkout reference or session ID.');
        }
        Donation__c donation = PublicDonationCommandService.findDonationByCheckoutReference(checkoutReference);
        if (donation == null) {
            List<Donation__c> existing = [
                SELECT Id, Payment_Status__c, Stripe_Session_Id__c, Amount__c FROM Donation__c
                WHERE Checkout_Reference__c = :checkoutReference
                WITH SYSTEM_MODE LIMIT 1 FOR UPDATE
            ];
            if (existing.isEmpty()) {
                throw new WebhookReferenceException('Checkout reference not found.');
            }
            validateSession(session, existing[0], newStatus);
            if (existing[0].Payment_Status__c == newStatus) {
                return;
            }
            throw new WebhookReferenceException('Checkout session has a conflicting donation status.');
        }
        validateSession(session, donation, newStatus);
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

    private static void validateSession(Map<String, Object> session, Donation__c donation, String newStatus) {
        String sessionId = (String) session.get('id');
        if (String.isBlank(donation.Stripe_Session_Id__c) ||
            donation.Stripe_Session_Id__c != sessionId ||
            !sessionId.startsWith('cs_test_') ||
            (String) session.get('object') != 'checkout.session' ||
            (String) session.get('mode') != 'payment' ||
            (String) session.get('currency') != 'mxn' ||
            session.get('livemode') != false ||
            session.get('amount_total') == null ||
            Decimal.valueOf(String.valueOf(session.get('amount_total'))) != donation.Amount__c * 100) {
            throw new WebhookReferenceException('Checkout session does not match the donation.');
        }
        if (newStatus == 'Paid' &&
            ((String) session.get('status') != 'complete' ||
             (String) session.get('payment_status') != 'paid')) {
            throw new WebhookReferenceException('Checkout payment is not confirmed.');
        }
        if (newStatus == 'Cancelled' && (String) session.get('status') != 'expired') {
            throw new WebhookReferenceException('Checkout session is not expired.');
        }
    }
}
