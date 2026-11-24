@IsTest
private class StripeWebhookControllerTest {
    private static final String TEST_SECRET = 'test_controller_secret';
    private static final String CHECKOUT_REF = 'MD-aabbccdd11223344aabbccdd11223344';
    private static final String SESSION_ID = 'cs_test_webhook_controller';

    private static String buildEventBody(String eventId, String checkoutReference, Integer amount) {
        return '{"id":"' + eventId + '","type":"checkout.session.completed","data":{"object":{' +
            '"id":"' + SESSION_ID + '","object":"checkout.session","client_reference_id":"' + checkoutReference + '",' +
            '"mode":"payment","currency":"mxn","livemode":false,"amount_total":' + amount + ',' +
            '"status":"complete","payment_status":"paid"}}}';
    }

    private static String buildSignatureHeader(String rawBody, Long timestamp) {
        Blob mac = Crypto.generateMac(
            'hmacSHA256',
            Blob.valueOf(String.valueOf(timestamp) + '.' + rawBody),
            Blob.valueOf(TEST_SECRET)
        );
        return 't=' + String.valueOf(timestamp) + ',v1=' + EncodingUtil.convertToHex(mac);
    }

    private static void setupRestContext(String body, String sigHeader) {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/stripe/webhook';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);
        if (sigHeader != null) {
            req.headers.put('Stripe-Signature', sigHeader);
        }
        RestContext.request = req;
        RestContext.response = new RestResponse();
    }

    @IsTest
    static void doPost_validRequest_returns200() {
        StripeWebhookController.webhookSecretOverride = TEST_SECRET;
        Campaign__c campaign = new Campaign__c(Name = 'Ctrl Test', Goal_Amount__c = 1000, Is_Active__c = true);
        insert campaign;
        insert new Donation__c(
            Campaign__c = campaign.Id,
            Amount__c = 200,
            Payment_Status__c = 'Pending',
            Donor_Email__c = 'ctrl@test.com',
            Checkout_Reference__c = CHECKOUT_REF,
            Stripe_Session_Id__c = SESSION_ID
        );

        String body = buildEventBody('evt_1', CHECKOUT_REF, 20000);
        Long ts = DateTime.now().getTime() / 1000;
        setupRestContext(body, buildSignatureHeader(body, ts));

        Test.startTest();
        StripeWebhookController.doPost();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode, 'Valid request should return 200.');
        List<Webhook_Audit_Log__c> logs = [SELECT Outcome__c FROM Webhook_Audit_Log__c];
        System.assertEquals(1, logs.size());
        System.assertEquals('Accepted', logs[0].Outcome__c, 'Debe registrar log Accepted.');
    }

    @IsTest
    static void doPost_invalidSignature_returns400() {
        String body = buildEventBody('evt_2', CHECKOUT_REF, 20000);
        Long ts = DateTime.now().getTime() / 1000;
        setupRestContext(body, 't=' + ts + ',v1=badbadbadbadbadbadbadbadbadbadbadbadbadbadbadbadbadbadbadbadbadb');

        Test.startTest();
        StripeWebhookController.doPost();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode, 'Invalid signature should return 400.');
        List<Webhook_Audit_Log__c> logs = [SELECT Outcome__c FROM Webhook_Audit_Log__c];
        System.assertEquals(1, logs.size());
        System.assertEquals('Rejected_Signature', logs[0].Outcome__c, 'Debe registrar log Rejected_Signature.');
    }

    @IsTest
    static void doPost_emptyBody_returns400() {
        setupRestContext('', null);

        Test.startTest();
        StripeWebhookController.doPost();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode, 'Empty body should return 400.');
    }

    @IsTest
    static void doPost_invalidSignature_createsAuditLog() {
        String body = buildEventBody('evt_3', CHECKOUT_REF, 20000);
        Long ts = DateTime.now().getTime() / 1000;
        setupRestContext(body, 't=' + ts + ',v1=0000000000000000000000000000000000000000000000000000000000000000');

        Test.startTest();
        StripeWebhookController.doPost();
        Test.stopTest();

        Webhook_Audit_Log__c entry = [SELECT Outcome__c, Rejection_Reason__c FROM Webhook_Audit_Log__c LIMIT 1];
        System.assertEquals('Rejected_Signature', entry.Outcome__c);
        System.assert(String.isNotBlank(entry.Rejection_Reason__c), 'El motivo de rechazo debe estar registrado.');
    }

    @IsTest
    static void doPost_unknownCheckoutRef_createsRejectedReferenceLog() {
        StripeWebhookController.webhookSecretOverride = TEST_SECRET;
        String unknownRef = 'MD-nonexistent00000000000000000000';
        String body = buildEventBody('evt_4', unknownRef, 20000);
        Long ts = DateTime.now().getTime() / 1000;
        setupRestContext(body, buildSignatureHeader(body, ts));

        Test.startTest();
        StripeWebhookController.doPost();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode);
        Webhook_Audit_Log__c entry = [SELECT Outcome__c, Checkout_Reference__c FROM Webhook_Audit_Log__c LIMIT 1];
        System.assertEquals('Rejected_Reference', entry.Outcome__c);
        System.assertEquals(unknownRef, entry.Checkout_Reference__c);
    }

    @IsTest
    static void doPost_validRequest_createsAcceptedAuditLog() {
        StripeWebhookController.webhookSecretOverride = TEST_SECRET;
        Campaign__c campaign = new Campaign__c(Name = 'Audit Test', Goal_Amount__c = 500, Is_Active__c = true);
        insert campaign;
        insert new Donation__c(
            Campaign__c = campaign.Id,
            Amount__c = 100,
            Payment_Status__c = 'Pending',
            Checkout_Reference__c = CHECKOUT_REF,
            Stripe_Session_Id__c = SESSION_ID
        );

        String body = buildEventBody('evt_5', CHECKOUT_REF, 10000);
        Long ts = DateTime.now().getTime() / 1000;
        setupRestContext(body, buildSignatureHeader(body, ts));

        Test.startTest();
        StripeWebhookController.doPost();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        Webhook_Audit_Log__c entry = [SELECT Outcome__c FROM Webhook_Audit_Log__c LIMIT 1];
        System.assertEquals('Accepted', entry.Outcome__c);
    }
}
