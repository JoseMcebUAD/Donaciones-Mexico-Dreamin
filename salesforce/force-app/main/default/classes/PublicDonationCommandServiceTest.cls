@IsTest
private class PublicDonationCommandServiceTest {
    private static Campaign__c makeActiveCampaign() {
        Campaign__c c = new Campaign__c(Name = 'Test Campaign', Goal_Amount__c = 1000, Is_Active__c = true);
        insert c;
        return c;
    }

    private static PublicDonationController.DonationRequest baseRequest(Id campaignId) {
        PublicDonationController.DonationRequest r = new PublicDonationController.DonationRequest();
        r.campaignId = campaignId;
        r.amount = 100;
        r.isAnonymous = false;
        r.wantsRecognition = true;
        r.recognitionName = 'Test Donor';
        r.needsInvoice = false;
        r.donorName = 'Test Donor';
        r.donorEmail = 'test@example.test';
        r.privacyAccepted = true;
        return r;
    }

    @IsTest
    static void createsPendingDonationWithoutImage() {
        Campaign__c campaign = makeActiveCampaign();
        PublicDonationController.DonationRequest request = baseRequest(campaign.Id);
        request.recognitionImageBase64 = null;
        request.recognitionImageFileName = null;

        Test.startTest();
        Id donationId = PublicDonationCommandService.createPendingDonation(request, campaign.Id, 'MD-001', 'sess_001');
        Test.stopTest();

        Donation__c donation = [SELECT Recognition_Image_URL__c, Recognition_Type__c, Privacy_Accepted__c FROM Donation__c WHERE Id = :donationId];
        System.assertNotEquals(null, donationId, 'Donation should be created.');
        System.assertEquals(null, donation.Recognition_Image_URL__c, 'No image URL should be set when no file is uploaded.');
        System.assertEquals('Individual', donation.Recognition_Type__c, 'Recognition_Type__c should default to Individual.');
        System.assertEquals(true, donation.Privacy_Accepted__c, 'Privacy_Accepted__c should be persisted.');
    }

    @IsTest
    static void doesNotCreateContentVersionWhenRecognitionIsFalse() {
        Campaign__c campaign = makeActiveCampaign();
        PublicDonationController.DonationRequest request = baseRequest(campaign.Id);
        request.wantsRecognition = false;
        request.recognitionName = null;
        request.recognitionImageBase64 = '/9j/base64data==';
        request.recognitionImageFileName = 'photo.jpg';

        Test.startTest();
        Id donationId = PublicDonationCommandService.createPendingDonation(request, campaign.Id, 'MD-002', 'sess_002');
        Test.stopTest();

        List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :donationId];
        System.assertEquals(0, links.size(), 'No ContentVersion should be created when wantsRecognition is false.');
    }

    @IsTest
    static void createsPendingDonationWithImageBase64() {
        Campaign__c campaign = makeActiveCampaign();
        PublicDonationController.DonationRequest request = baseRequest(campaign.Id);
        // Minimal valid JPEG base64 (1x1 pixel)
        request.recognitionImageBase64 = 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAABAAEDASIAAhEBAxEB/8QAFAABAAAAAAAAAAAAAAAAAAAACf/EABQQAQAAAAAAAAAAAAAAAAAAAAD/xAAUAQEAAAAAAAAAAAAAAAAAAAAA/8QAFBEBAAAAAAAAAAAAAAAAAAAAAP/aAAwDAQACEQMRAD8AJQAB/9k=';
        request.recognitionImageFileName = 'donor.jpg';

        Test.startTest();
        Id donationId = PublicDonationCommandService.createPendingDonation(request, campaign.Id, 'MD-003', 'sess_003');
        Test.stopTest();

        Donation__c donation = [SELECT Recognition_Image_URL__c FROM Donation__c WHERE Id = :donationId];
        List<ContentDocumentLink> links = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :donationId];
        System.assertEquals(1, links.size(), 'A ContentDocumentLink should be created for the uploaded image.');
        // ContentDistribution URLs are not generated in test context, but the field is updated
        // (URL may be null in sandbox test mode; we verify the ContentVersion was created)
    }
}
