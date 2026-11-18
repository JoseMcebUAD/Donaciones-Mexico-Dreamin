@IsTest
private class PublicDonationControllerTest {
    private class StripeMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            System.assertEquals('POST', request.getMethod());
            System.assert(request.getBody().contains('client_reference_id='));
            String baseUrl = System.Label.Donation_Portal_Base_URL;
            System.assert(request.getBody().contains('success_url=' + EncodingUtil.urlEncode(baseUrl + '/thank-you?session_id={CHECKOUT_SESSION_ID}', 'UTF-8')));
            System.assert(request.getBody().contains('cancel_url=' + EncodingUtil.urlEncode(baseUrl + '/', 'UTF-8')));
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"id":"cs_test_123","url":"https://checkout.stripe.test/session"}');
            return response;
        }
    }

    private static PublicDonationController.DonationRequest validRequest(Id campaignId) {
        PublicDonationController.DonationRequest request = new PublicDonationController.DonationRequest();
        request.campaignId = campaignId;
        request.amount = 250;
        request.isAnonymous = false;
        request.wantsRecognition = true;
        request.recognitionName = 'Ana Example';
        request.recognitionImageBase64 = null;
        request.recognitionImageFileName = null;
        request.needsInvoice = true;
        request.donorName = 'Ana Example';
        request.donorEmail = 'ana@example.test';
        request.legalName = 'Ana Example SA de CV';
        request.rfc = 'XAXX010101000';
        request.postalCode = '97000';
        request.taxRegime = '601';
        request.cfdiUse = 'D04';
        request.privacyAccepted = true;
        return request;
    }

    @TestSetup
    static void checkoutFixture() {
        Campaign__c campaign = new Campaign__c(Name = 'Checkout fixture', Goal_Amount__c = 500, Is_Active__c = true);
        insert campaign;
        insert new Donation__c(
            Campaign__c = campaign.Id, Amount__c = 250, Payment_Status__c = 'Pending',
            Donor_Email__c = 'checkout@example.test', Checkout_Reference__c = 'MD-0123456789abcdef0123456789abcdef'
        );
    }

    @IsTest
    static void createsPendingDonationBeforeCheckout() {
        User testUser = DonationTestDataFactory.createTestUser();
        System.runAs(testUser) {
            Campaign__c campaign = new Campaign__c(Name = 'Public campaign', Goal_Amount__c = 500, Is_Active__c = true);
            insert campaign;
            Test.startTest();
            PublicDonationController.CheckoutResponse response = PublicDonationController.prepareDonation(validRequest(campaign.Id));
            Test.stopTest();
            Donation__c donation = [SELECT Payment_Status__c, Stripe_Session_Id__c, RFC__c, Checkout_Reference__c, Recognition_Name__c FROM Donation__c WHERE Checkout_Reference__c = :response.checkoutReference];
            System.assertEquals('Pending', donation.Payment_Status__c);
            System.assertEquals(null, donation.Stripe_Session_Id__c);
            System.assertEquals('XAXX010101000', donation.RFC__c);
            System.assert(donation.Checkout_Reference__c.startsWith('MD-'));
            System.assertEquals('Ana Example', donation.Recognition_Name__c);
            System.assertEquals(null, response.checkoutUrl);
        }
    }

    @IsTest
    static void rejectsInvalidFiscalData() {
        User testUser = DonationTestDataFactory.createTestUser();
        System.runAs(testUser) {
            Campaign__c campaign = new Campaign__c(Name = 'Validation campaign', Goal_Amount__c = 500, Is_Active__c = true);
            insert campaign;
            PublicDonationController.DonationRequest invalidRfc = validRequest(campaign.Id);
            invalidRfc.rfc = 'BAD';
            try {
                PublicDonationController.prepareDonation(invalidRfc);
                System.assert(false, 'Invalid RFC must be rejected.');
            } catch (AuraHandledException expected) { }
        }
    }

    @IsTest
    static void rejectsInactiveCampaignBeforeStripeCallout() {
        Campaign__c campaign = new Campaign__c(Name = 'Inactive campaign', Goal_Amount__c = 500, Is_Active__c = false);
        insert campaign;
        try {
            PublicDonationController.prepareDonation(validRequest(campaign.Id));
            System.assert(false, 'Inactive campaigns must never create a Checkout Session.');
        } catch (AuraHandledException expected) { }
    }
    @IsTest
    static void rejectsAmountBelowStripeMinimum() {
        User testUser = DonationTestDataFactory.createTestUser();
        System.runAs(testUser) {
            Campaign__c campaign = new Campaign__c(Name = 'Min amount campaign', Goal_Amount__c = 500, Is_Active__c = true);
            insert campaign;
            PublicDonationController.DonationRequest lowAmount = validRequest(campaign.Id);
            lowAmount.amount = 9.99;
            try {
                PublicDonationController.prepareDonation(lowAmount);
                System.assert(false, 'Amount below 10 MXN must be rejected.');
            } catch (AuraHandledException expected) { }
        }
    }

    @IsTest
    static void acceptsCustomAmountAtStripeMinimum() {
        User testUser = DonationTestDataFactory.createTestUser();
        System.runAs(testUser) {
            Campaign__c campaign = new Campaign__c(Name = 'Exact min campaign', Goal_Amount__c = 500, Is_Active__c = true);
            insert campaign;
            PublicDonationController.DonationRequest minRequest = validRequest(campaign.Id);
            minRequest.amount = 10.00;
            Test.startTest();
            PublicDonationController.CheckoutResponse response = PublicDonationController.prepareDonation(minRequest);
            Test.stopTest();
            Donation__c donation = [SELECT Amount__c, Payment_Status__c FROM Donation__c WHERE Checkout_Reference__c = :response.checkoutReference];
            System.assertEquals(10.00, donation.Amount__c);
            System.assertEquals('Pending', donation.Payment_Status__c);
        }
    }

    @IsTest
    static void opensCheckoutOnlyForPreparedAttempt() {
        Test.setMock(HttpCalloutMock.class, new StripeMock());
        Test.startTest();
        PublicDonationController.CheckoutResponse response = PublicDonationController.openCheckout('MD-0123456789abcdef0123456789abcdef');
        Test.stopTest();
        System.assertEquals('https://checkout.stripe.test/session', response.checkoutUrl);
        Donation__c donation = [SELECT Stripe_Session_Id__c, Payment_Status__c FROM Donation__c WHERE Checkout_Reference__c = 'MD-0123456789abcdef0123456789abcdef'];
        System.assertEquals('cs_test_123', donation.Stripe_Session_Id__c);
        System.assertEquals('Pending', donation.Payment_Status__c);
    }

    @IsTest
    static void refusesUnknownOrRepeatedCheckoutReference() {
        try {
            PublicDonationController.openCheckout('MD-00000000000000000000000000000000');
            System.assert(false, 'Unknown references must be rejected.');
        } catch (AuraHandledException expected) { }
    }
}
