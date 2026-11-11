@isTest
private class DonationExpirationServiceTest {
    @TestSetup
    static void setup() {
        Campaign__c campaign = new Campaign__c(
            Name = 'Test Campaign',
            Goal_Amount__c = 5000,
            Is_Active__c = true
        );
        insert campaign;

        List<Donation__c> donations = new List<Donation__c>();
        donations.add(new Donation__c(
            Campaign__c = campaign.Id,
            Amount__c = 100,
            Payment_Status__c = 'Pending',
            Donor_Email__c = 'test@example.com'
        ));
        donations.add(new Donation__c(
            Campaign__c = campaign.Id,
            Amount__c = 200,
            Payment_Status__c = 'Paid',
            Donor_Email__c = 'paid@example.com'
        ));
        insert donations;
    }

    @isTest
    static void testExpiresPendingDonations() {
        Test.startTest();
        Database.executeBatch(new DonationExpirationService(), 200);
        Test.stopTest();

        List<Donation__c> pending = [SELECT Payment_Status__c FROM Donation__c WHERE Donor_Email__c = 'test@example.com'];
        System.assertEquals('Cancelled', pending[0].Payment_Status__c, 'Pending donation should be cancelled');
    }

    @isTest
    static void testDoesNotAffectPaidDonations() {
        Test.startTest();
        Database.executeBatch(new DonationExpirationService(), 200);
        Test.stopTest();

        List<Donation__c> paid = [SELECT Payment_Status__c FROM Donation__c WHERE Donor_Email__c = 'paid@example.com'];
        System.assertEquals('Paid', paid[0].Payment_Status__c, 'Paid donation should remain paid');
    }

    @isTest
    static void testSchedulable() {
        Test.startTest();
        String jobId = System.schedule(
            'Test DonationExpirationService',
            '0 0 2 * * ?',
            new DonationExpirationService()
        );
        Test.stopTest();
        System.assertNotEquals(null, jobId, 'Scheduled job should be created');
    }
}
