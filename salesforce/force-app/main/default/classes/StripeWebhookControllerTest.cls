@IsTest
private class StripeWebhookControllerTest {
    private static final String TEST_SECRET = 'test_controller_secret';
    private static final String CHECKOUT_REF = 'MD-aabbccdd11223344aabbccdd11223344';

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
        Campaign__c campaign = new Campaign__c(Name = 'Ctrl Test', Goal_Amount__c = 1000, Is_Active__c = true);
        insert campaign;
        insert new Donation__c(
            Campaign__c = campaign.Id,
            Amount__c = 200,
            Payment_Status__c = 'Pending',
            Donor_Email__c = 'ctrl@test.com',
            Checkout_Reference__c = CHECKOUT_REF
        );

        String body = '{"id":"evt_1","type":"checkout.session.completed","data":{"object":{"id":"cs_test","client_reference_id":"' + CHECKOUT_REF + '"}}}';
        Long ts = DateTime.now().getTime() / 1000;
        setupRestContext(body, buildSignatureHeader(body, ts));

        Test.startTest();
        StripeWebhookController.doPost();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode, 'Valid request should return 200.');
    }

    @IsTest
    static void doPost_invalidSignature_returns400() {
        String body = '{"id":"evt_2","type":"checkout.session.completed","data":{"object":{"id":"cs_test","client_reference_id":"' + CHECKOUT_REF + '"}}}';
        Long ts = DateTime.now().getTime() / 1000;
        setupRestContext(body, 't=' + ts + ',v1=badbadbadbadbadbadbadbadbadbadbadbadbadbadbadbadbadbadbadbadbadb');

        Test.startTest();
        StripeWebhookController.doPost();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode, 'Invalid signature should return 400.');
    }

    @IsTest
    static void doPost_emptyBody_returns400() {
        setupRestContext('', null);

        Test.startTest();
        StripeWebhookController.doPost();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode, 'Empty body should return 400.');
    }
}
