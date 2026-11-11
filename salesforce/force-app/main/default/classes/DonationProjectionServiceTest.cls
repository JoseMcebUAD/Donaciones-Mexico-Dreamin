@IsTest
private class DonationProjectionServiceTest {
    @IsTest
    static void maintainsSafePublicProjectionAndCampaignMetrics() {
        Campaign__c campaign = new Campaign__c(
            Name = 'Projection campaign',
            Goal_Amount__c = 10000,
            Is_Active__c = true
        );
        insert campaign;

        Donation__c publicDonation = new Donation__c(
            Campaign__c = campaign.Id,
            Amount__c = 4000,
            Payment_Status__c = 'Paid',
            Donor_Name__c = 'Demo Foundation',
            Wants_Recognition__c = true,
            Recognition_Name__c = 'Demo Foundation',
            Recognition_Type__c = 'Organization'
        );
        Donation__c anonymousDonation = new Donation__c(
            Campaign__c = campaign.Id,
            Amount__c = 2500,
            Payment_Status__c = 'Paid',
            Is_Anonymous__c = true,
            Wants_Recognition__c = false
        );
        Donation__c pendingDonation = new Donation__c(
            Campaign__c = campaign.Id,
            Amount__c = 1000,
            Payment_Status__c = 'Pending',
            Donor_Name__c = 'Pending donor'
        );
        insert new List<Donation__c>{ publicDonation, anonymousDonation, pendingDonation };

        Campaign__c refreshedCampaign = [
            SELECT Raised_Amount__c, Anonymous_Donor_Count__c
            FROM Campaign__c
            WHERE Id = :campaign.Id
        ];
        System.assertEquals(6500, refreshedCampaign.Raised_Amount__c);
        System.assertEquals(1, refreshedCampaign.Anonymous_Donor_Count__c);
        System.assertEquals(1, [SELECT COUNT() FROM Donor_Recognition__c WHERE Campaign__c = :campaign.Id]);

        publicDonation.Wants_Recognition__c = false;
        update publicDonation;
        System.assertEquals(0, [SELECT COUNT() FROM Donor_Recognition__c WHERE Campaign__c = :campaign.Id]);

        pendingDonation.Payment_Status__c = 'Paid';
        update pendingDonation;
        refreshedCampaign = [SELECT Raised_Amount__c FROM Campaign__c WHERE Id = :campaign.Id];
        System.assertEquals(7500, refreshedCampaign.Raised_Amount__c);

        publicDonation.Wants_Recognition__c = true;
        update publicDonation;
        System.assertEquals(1, [SELECT COUNT() FROM Donor_Recognition__c WHERE Campaign__c = :campaign.Id]);
        delete publicDonation;
        refreshedCampaign = [SELECT Raised_Amount__c FROM Campaign__c WHERE Id = :campaign.Id];
        System.assertEquals(3500, refreshedCampaign.Raised_Amount__c);
        System.assertEquals(0, [SELECT COUNT() FROM Donor_Recognition__c WHERE Campaign__c = :campaign.Id]);
    }
}
