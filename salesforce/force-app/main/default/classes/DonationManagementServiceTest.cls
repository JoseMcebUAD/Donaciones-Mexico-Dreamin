@IsTest
private class DonationManagementServiceTest {
    @IsTest
    static void confirmsOnlyOnce() {
        Campaign__c campaign = new Campaign__c(Name = 'Staff campaign', Goal_Amount__c = 500, Is_Active__c = true);
        insert campaign;
        Donation__c donation = new Donation__c(Campaign__c = campaign.Id, Amount__c = 500, Payment_Status__c = 'Pending', Donor_Name__c = 'Staff test', Donor_Email__c = 'staff@example.test');
        insert donation;
        Test.startTest();
        DonationManagementService.confirmPayment(donation.Id);
        Test.stopTest();
        System.assertEquals('Paid', [SELECT Payment_Status__c FROM Donation__c WHERE Id = :donation.Id].Payment_Status__c);
        try {
            DonationManagementService.confirmPayment(donation.Id);
            System.assert(false, 'A second confirmation must be rejected.');
        } catch (AuraHandledException expected) { }
    }
}
