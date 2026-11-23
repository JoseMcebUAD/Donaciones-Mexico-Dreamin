@IsTest
private class StripeWebhookServiceTest {
    private static final String TEST_SECRET = 'test_webhook_secret';
    private static final String CHECKOUT_REF = 'MD-aabbccdd11223344aabbccdd11223344';

    private static String buildSignatureHeader(String rawBody, String secret, Long timestamp) {
        Blob mac = Crypto.generateMac(
            'hmacSHA256',
            Blob.valueOf(String.valueOf(timestamp) + '.' + rawBody),
            Blob.valueOf(secret)
        );
        return 't=' + String.valueOf(timestamp) + ',v1=' + EncodingUtil.convertToHex(mac);
    }

    private static String buildEventBody(String eventType, String clientReference) {
        return '{"id":"evt_test","type":"' + eventType + '","data":{"object":{"id":"cs_test","client_reference_id":"' + clientReference + '"}}}';
    }

    private static Campaign__c makeActiveCampaign() {
        Campaign__c c = new Campaign__c(Name = 'Webhook Test Campaign', Goal_Amount__c = 5000, Is_Active__c = true);
        insert c;
        return c;
    }

    private static Donation__c makePendingDonation(Id campaignId) {
        Donation__c d = new Donation__c(
            Campaign__c = campaignId,
            Amount__c = 500,
            Payment_Status__c = 'Pending',
            Donor_Email__c = 'donor@test.com',
            Checkout_Reference__c = CHECKOUT_REF
        );
        insert d;
        return d;
    }

    @IsTest
    static void verifySignature_valid() {
        Long ts = DateTime.now().getTime() / 1000;
        String body = buildEventBody('checkout.session.completed', CHECKOUT_REF);
        String header = buildSignatureHeader(body, TEST_SECRET, ts);

        Test.startTest();
        try {
            StripeWebhookService.verifySignature(body, header, TEST_SECRET);
            System.assert(true, 'No exception should be thrown for valid signature.');
        } catch (StripeWebhookService.WebhookSecurityException e) {
            System.assert(false, 'Valid signature should not throw: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void verifySignature_wrongSignature() {
        Long ts = DateTime.now().getTime() / 1000;
        String body = buildEventBody('checkout.session.completed', CHECKOUT_REF);
        String header = 't=' + ts + ',v1=0000000000000000000000000000000000000000000000000000000000000000';

        Test.startTest();
        try {
            StripeWebhookService.verifySignature(body, header, TEST_SECRET);
            System.assert(false, 'Should have thrown WebhookSecurityException.');
        } catch (StripeWebhookService.WebhookSecurityException e) {
            System.assert(true, 'Expected exception thrown.');
        }
        Test.stopTest();
    }

    @IsTest
    static void verifySignature_expiredTimestamp() {
        Long expiredTs = (DateTime.now().getTime() / 1000) - 400;
        String body = buildEventBody('checkout.session.completed', CHECKOUT_REF);
        String header = buildSignatureHeader(body, TEST_SECRET, expiredTs);

        Test.startTest();
        try {
            StripeWebhookService.verifySignature(body, header, TEST_SECRET);
            System.assert(false, 'Should have thrown WebhookSecurityException for expired timestamp.');
        } catch (StripeWebhookService.WebhookSecurityException e) {
            System.assert(true, 'Expected exception thrown for expired timestamp.');
        }
        Test.stopTest();
    }

    @IsTest
    static void handle_completedEvent_marksPaid() {
        Campaign__c campaign = makeActiveCampaign();
        Donation__c donation = makePendingDonation(campaign.Id);
        String body = buildEventBody('checkout.session.completed', CHECKOUT_REF);

        Test.startTest();
        StripeWebhookService.processEvent(body);
        Test.stopTest();

        Donation__c updated = [SELECT Payment_Status__c FROM Donation__c WHERE Id = :donation.Id];
        System.assertEquals('Paid', updated.Payment_Status__c, 'Donation should be marked Paid.');
    }

    @IsTest
    static void handle_expiredEvent_marksCancelled() {
        Campaign__c campaign = makeActiveCampaign();
        Donation__c donation = makePendingDonation(campaign.Id);
        String body = buildEventBody('checkout.session.expired', CHECKOUT_REF);

        Test.startTest();
        StripeWebhookService.processEvent(body);
        Test.stopTest();

        Donation__c updated = [SELECT Payment_Status__c FROM Donation__c WHERE Id = :donation.Id];
        System.assertEquals('Cancelled', updated.Payment_Status__c, 'Donation should be marked Cancelled.');
    }

    @IsTest
    static void handle_unknownEvent_noChange() {
        Campaign__c campaign = makeActiveCampaign();
        Donation__c donation = makePendingDonation(campaign.Id);
        String body = buildEventBody('customer.created', CHECKOUT_REF);

        Test.startTest();
        StripeWebhookService.processEvent(body);
        Test.stopTest();

        Donation__c unchanged = [SELECT Payment_Status__c FROM Donation__c WHERE Id = :donation.Id];
        System.assertEquals('Pending', unchanged.Payment_Status__c, 'Unknown event should not change status.');
    }

    @IsTest
    static void handle_duplicateEvent_idempotent() {
        Campaign__c campaign = makeActiveCampaign();
        Donation__c donation = makePendingDonation(campaign.Id);
        String body = buildEventBody('checkout.session.completed', CHECKOUT_REF);

        Test.startTest();
        StripeWebhookService.processEvent(body);
        StripeWebhookService.processEvent(body);
        Test.stopTest();

        Donation__c updated = [SELECT Payment_Status__c FROM Donation__c WHERE Id = :donation.Id];
        System.assertEquals('Paid', updated.Payment_Status__c, 'Duplicate event should be idempotent.');
    }
}
