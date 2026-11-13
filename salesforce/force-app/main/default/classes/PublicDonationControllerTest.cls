@IsTest
private class PublicDonationControllerTest {
    private class StripeMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            System.assertEquals('POST', request.getMethod());
            System.assert(request.getBody().contains('client_reference_id='));
            System.assert(request.getBody().contains('success_url=https%3A%2F%2Fempathetic-narwhal-9eroye-dev-ed.trailblaze.my.site.com%2Fdonaciones%2Fthank-you'));
            System.assert(request.getBody().contains('cancel_url=https%3A%2F%2Fempathetic-narwhal-9eroye-dev-ed.trailblaze.my.site.com%2Fdonaciones%2F'));
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
        request.recognitionType = 'Individual';
        request.recognitionName = 'Ana Example';
        request.recognitionImageUrl = 'https://example.test/ana.png';
        request.needsInvoice = true;
        request.donorName = 'Ana Example';
        request.donorEmail = 'ana@example.test';
        request.legalName = 'Ana Example SA de CV';
        request.rfc = 'XAXX010101000';
        request.postalCode = '97000';
        request.taxRegime = '601';
        request.cfdiUse = 'D04';
        return request;
    }

    @IsTest
    static void createsPendingDonationAndStripeCheckout() {
        Campaign__c campaign = new Campaign__c(Name = 'Public campaign', Goal_Amount__c = 500, Is_Active__c = true);
        insert campaign;
        Test.setMock(HttpCalloutMock.class, new StripeMock());
        Test.startTest();
        PublicDonationController.CheckoutResponse response = PublicDonationController.startDonation(validRequest(campaign.Id));
        Test.stopTest();
        Donation__c donation = [SELECT Payment_Status__c, Stripe_Session_Id__c, RFC__c, Checkout_Reference__c, Recognition_Name__c FROM Donation__c WHERE Id = :response.donationId];
        System.assertEquals('Pending', donation.Payment_Status__c);
        System.assertEquals('cs_test_123', donation.Stripe_Session_Id__c);
        System.assertEquals('XAXX010101000', donation.RFC__c);
        System.assert(donation.Checkout_Reference__c.startsWith('MD-'));
        System.assertEquals('Ana Example', donation.Recognition_Name__c);
        System.assertEquals('https://checkout.stripe.test/session', response.checkoutUrl);
    }

    @IsTest
    static void rejectsInvalidFiscalData() {
        Campaign__c campaign = new Campaign__c(Name = 'Validation campaign', Goal_Amount__c = 500, Is_Active__c = true);
        insert campaign;
        PublicDonationController.DonationRequest invalidRfc = validRequest(campaign.Id);
        invalidRfc.rfc = 'BAD';
        try {
            PublicDonationController.startDonation(invalidRfc);
            System.assert(false, 'Invalid RFC must be rejected.');
        } catch (AuraHandledException expected) { }
    }

    @IsTest
    static void rejectsInactiveCampaignBeforeStripeCallout() {
        Campaign__c campaign = new Campaign__c(Name = 'Inactive campaign', Goal_Amount__c = 500, Is_Active__c = false);
        insert campaign;
        try {
            PublicDonationController.startDonation(validRequest(campaign.Id));
            System.assert(false, 'Inactive campaigns must never create a Checkout Session.');
        } catch (AuraHandledException expected) { }
    }
}
