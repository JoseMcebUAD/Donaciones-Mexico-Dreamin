@IsTest
private class StripeWebhookServiceTest {
    private static final String TEST_SECRET = 'test_webhook_secret';
    private static final String CHECKOUT_REF = 'MD-aabbccdd11223344aabbccdd11223344';
    private static final String SESSION_ID = 'cs_test_webhook_service';

    private static String buildSignatureHeader(String rawBody, String secret, Long timestamp) {
        Blob mac = Crypto.generateMac(
            'hmacSHA256',
            Blob.valueOf(String.valueOf(timestamp) + '.' + rawBody),
            Blob.valueOf(secret)
        );
        return 't=' + String.valueOf(timestamp) + ',v1=' + EncodingUtil.convertToHex(mac);
    }

    private static String buildEventBody(String eventType, String clientReference) {
        String status = eventType == 'checkout.session.expired' ? 'expired' : 'complete';
        String paymentStatus = eventType == 'checkout.session.expired' ? 'unpaid' : 'paid';
        return '{"id":"evt_test","type":"' + eventType + '","data":{"object":{' +
            '"id":"' + SESSION_ID + '","object":"checkout.session","client_reference_id":"' + clientReference + '",' +
            '"mode":"payment","currency":"mxn","livemode":false,"amount_total":50000,' +
            '"status":"' + status + '","payment_status":"' + paymentStatus + '"}}}';
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
            Checkout_Reference__c = CHECKOUT_REF,
            Stripe_Session_Id__c = SESSION_ID
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

    @IsTest
    static void handle_completedEvent_sendsReceiptEmail() {
        Campaign__c campaign = makeActiveCampaign();
        Donation__c donation = makePendingDonation(campaign.Id);
        String body = buildEventBody('checkout.session.completed', CHECKOUT_REF);

        Test.startTest();
        StripeWebhookService.processEvent(body);
        System.assert(Limits.getEmailInvocations() > 0, 'Se debio enviar correo de comprobante al confirmar pago.');
        Test.stopTest();

        Donation__c updated = [SELECT Payment_Status__c FROM Donation__c WHERE Id = :donation.Id];
        System.assertEquals('Paid', updated.Payment_Status__c);
    }

    @IsTest
    static void handle_completedEvent_noEmail_doesNotFail() {
        Campaign__c campaign = makeActiveCampaign();
        Donation__c donation = new Donation__c(
            Campaign__c = campaign.Id, Amount__c = 500,
            Payment_Status__c = 'Pending',
            Checkout_Reference__c = CHECKOUT_REF,
            Stripe_Session_Id__c = SESSION_ID
        );
        insert donation;
        String body = buildEventBody('checkout.session.completed', CHECKOUT_REF);

        Test.startTest();
        StripeWebhookService.processEvent(body);
        Test.stopTest();

        Donation__c updated = [SELECT Payment_Status__c FROM Donation__c WHERE Id = :donation.Id];
        System.assertEquals('Paid', updated.Payment_Status__c, 'Debe quedar Paid aunque no haya email.');
        System.assertEquals(0, Limits.getEmailInvocations(), 'Sin email no se debe intentar envio.');
    }

    @IsTest
    static void handle_expiredEvent_doesNotSendEmail() {
        Campaign__c campaign = makeActiveCampaign();
        Donation__c donation = makePendingDonation(campaign.Id);
        String body = buildEventBody('checkout.session.expired', CHECKOUT_REF);

        Test.startTest();
        StripeWebhookService.processEvent(body);
        Test.stopTest();

        Donation__c updated = [SELECT Payment_Status__c FROM Donation__c WHERE Id = :donation.Id];
        System.assertEquals('Cancelled', updated.Payment_Status__c);
        System.assertEquals(0, Limits.getEmailInvocations(), 'Expiracion no debe enviar correo.');
    }

    @IsTest
    static void handle_duplicateCompletedEvent_sendsEmailOnlyOnce() {
        Campaign__c campaign = makeActiveCampaign();
        Donation__c donation = makePendingDonation(campaign.Id);
        String body = buildEventBody('checkout.session.completed', CHECKOUT_REF);

        Test.startTest();
        StripeWebhookService.processEvent(body);
        StripeWebhookService.processEvent(body);
        System.assertEquals(1, Limits.getEmailInvocations(), 'El correo solo se envia en el primer procesamiento.');
        Test.stopTest();
    }

    @IsTest
    static void handle_completedEvent_withoutPaidStatus_doesNotConfirm() {
        Campaign__c campaign = makeActiveCampaign();
        Donation__c donation = makePendingDonation(campaign.Id);
        String body = buildEventBody('checkout.session.completed', CHECKOUT_REF)
            .replace('"payment_status":"paid"', '"payment_status":"unpaid"');

        try {
            StripeWebhookService.processEvent(body);
            System.assert(false, 'Unpaid checkout must be rejected.');
        } catch (StripeWebhookService.WebhookReferenceException expected) {
            System.assert(expected.getMessage().contains('not confirmed'));
        }
        System.assertEquals('Pending', [SELECT Payment_Status__c FROM Donation__c WHERE Id = :donation.Id].Payment_Status__c);
    }

    @IsTest
    static void handle_completedEvent_wrongAmountOrSession_doesNotConfirm() {
        Campaign__c campaign = makeActiveCampaign();
        Donation__c donation = makePendingDonation(campaign.Id);
        List<String> invalidBodies = new List<String>{
            buildEventBody('checkout.session.completed', CHECKOUT_REF).replace('"amount_total":50000', '"amount_total":10000'),
            buildEventBody('checkout.session.completed', CHECKOUT_REF).replace(SESSION_ID, 'cs_test_other')
        };
        for (String body : invalidBodies) {
            try {
                StripeWebhookService.processEvent(body);
                System.assert(false, 'Mismatched checkout must be rejected.');
            } catch (StripeWebhookService.WebhookReferenceException expected) {
                System.assert(expected.getMessage().contains('does not match'));
            }
        }
        System.assertEquals('Pending', [SELECT Payment_Status__c FROM Donation__c WHERE Id = :donation.Id].Payment_Status__c);
    }

    @IsTest
    static void handle_asyncPaymentSucceeded_marksPaid() {
        Campaign__c campaign = makeActiveCampaign();
        Donation__c donation = makePendingDonation(campaign.Id);
        StripeWebhookService.processEvent(buildEventBody('checkout.session.async_payment_succeeded', CHECKOUT_REF));
        System.assertEquals('Paid', [SELECT Payment_Status__c FROM Donation__c WHERE Id = :donation.Id].Payment_Status__c);
    }
}
