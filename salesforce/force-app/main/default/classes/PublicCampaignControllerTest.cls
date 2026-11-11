@IsTest
private class PublicCampaignControllerTest {
    @TestSetup
    static void makeData() {
        Campaign__c activeCampaign = new Campaign__c(Name = 'Active campaign', Goal_Amount__c = 1000, Is_Active__c = true);
        Campaign__c inactiveCampaign = new Campaign__c(Name = 'Inactive campaign', Goal_Amount__c = 500, Is_Active__c = false);
        insert new List<Campaign__c>{ activeCampaign, inactiveCampaign };
        insert new List<Donation__c>{
            new Donation__c(Campaign__c = activeCampaign.Id, Amount__c = 300, Payment_Status__c = 'Paid', Donor_Name__c = 'Ana', Donor_Email__c = 'ana@example.test', Wants_Recognition__c = true),
            new Donation__c(Campaign__c = activeCampaign.Id, Amount__c = 100, Payment_Status__c = 'Pending', Donor_Name__c = 'Beto', Donor_Email__c = 'beto@example.test', Wants_Recognition__c = true),
            new Donation__c(Campaign__c = activeCampaign.Id, Amount__c = 200, Payment_Status__c = 'Paid', Donor_Name__c = 'Caro', Donor_Email__c = 'caro@example.test', Is_Anonymous__c = true, Wants_Recognition__c = false)
        };
    }

    @IsTest
    static void returnsOnlyActiveCampaignsAndPaidProgress() {
        Test.startTest();
        List<PublicCampaignController.CampaignView> campaigns = PublicCampaignController.getActiveCampaigns();
        Test.stopTest();
        System.assertEquals(1, campaigns.size());
        System.assertEquals('Active campaign', campaigns[0].name);
        System.assertEquals(300, campaigns[0].raisedAmount);
        System.assertEquals(30, campaigns[0].progressPercent);
    }

    @IsTest
    static void returnsOnlyRecognizedPaidDonors() {
        Id campaignId = [SELECT Id FROM Campaign__c WHERE Name = 'Active campaign'].Id;
        List<Donation__c> donors = PublicCampaignController.getRecognizedDonors(campaignId);
        System.assertEquals(1, donors.size());
        System.assertEquals('Ana', donors[0].Donor_Name__c);
    }
}
