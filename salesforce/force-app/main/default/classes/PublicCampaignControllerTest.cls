@IsTest
private class PublicCampaignControllerTest {
    @TestSetup
    static void makeData() {
        Campaign__c activeCampaign = new Campaign__c(
            Name = 'Active campaign', Goal_Amount__c = 1000, Is_Active__c = true,
            Cover_Image_URL__c = 'https://example.test/cover.jpg'
        );
        Campaign__c inactiveCampaign = new Campaign__c(
            Name = 'Inactive campaign', Goal_Amount__c = 500, Is_Active__c = false
        );
        insert new List<Campaign__c>{ activeCampaign, inactiveCampaign };
        insert new List<Donation__c>{
            new Donation__c(Campaign__c = activeCampaign.Id, Amount__c = 300,
                Payment_Status__c = 'Paid', Donor_Name__c = 'Ana',
                Donor_Email__c = 'ana@example.test', Wants_Recognition__c = true,
                Recognition_Name__c = 'Fundacion Ana',
                Recognition_Image_URL__c = 'https://example.test/logo.png'),
            new Donation__c(Campaign__c = activeCampaign.Id, Amount__c = 100,
                Payment_Status__c = 'Pending', Donor_Name__c = 'Beto',
                Donor_Email__c = 'beto@example.test', Wants_Recognition__c = true),
            new Donation__c(Campaign__c = activeCampaign.Id, Amount__c = 200,
                Payment_Status__c = 'Paid', Donor_Name__c = 'Caro',
                Donor_Email__c = 'caro@example.test', Is_Anonymous__c = true,
                Wants_Recognition__c = false)
        };
    }

    @IsTest
    static void returnsOnlyActiveCampaignsAndPublicFields() {
        Test.startTest();
        List<PublicCampaignController.CampaignView> campaigns = PublicCampaignController.getActiveCampaigns();
        Test.stopTest();

        System.assertEquals(1, campaigns.size());
        PublicCampaignController.CampaignView view = campaigns[0];
        System.assertEquals('Active campaign', view.name);
        System.assertEquals(1000, view.goalAmount);
        System.assertEquals(500, view.raisedAmount);
        System.assertEquals(50, view.progressPercent);
        System.assertEquals(1, view.anonymousDonorCount);
        System.assertEquals(1, view.recognizedDonors.size());
        System.assertEquals('Fundacion Ana', view.recognizedDonors[0].displayName);
        System.assertEquals(300, view.recognizedDonors[0].amount);
        System.assertEquals('https://example.test/logo.png', view.recognizedDonors[0].imageUrl);
        System.assertEquals('https://example.test/cover.jpg', view.coverImageUrl);

        String serialized = JSON.serialize(view);
        System.assert(!serialized.contains('ana@example.test'));
        System.assert(!serialized.contains('beto@example.test'));
        System.assert(!serialized.contains('Caro'));
    }
}
