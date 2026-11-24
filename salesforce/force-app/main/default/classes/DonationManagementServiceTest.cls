@IsTest
private class DonationManagementServiceTest {

    private static Campaign__c makeActiveCampaign() {
        Campaign__c c = new Campaign__c(Name = 'Test Campaign', Goal_Amount__c = 1000, Is_Active__c = true);
        insert c;
        return c;
    }

    @IsTest
    static void confirmsOnlyOnce() {
        User testUser = DonationTestDataFactory.createTestUser();
        System.runAs(testUser) {
            Campaign__c campaign = makeActiveCampaign();
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

    @IsTest
    static void sendReceiptEmail_sendsEmailWhenDonorEmailPresent() {
        Campaign__c campaign = makeActiveCampaign();
        Donation__c donation = new Donation__c(
            Campaign__c = campaign.Id, Amount__c = 250,
            Payment_Status__c = 'Paid', Donor_Name__c = 'Ana Test',
            Donor_Email__c = 'ana@example.test', Is_Anonymous__c = false
        );
        insert donation;
        Test.startTest();
        DonationManagementService.sendReceiptEmail(donation.Id);
        System.assert(Limits.getEmailInvocations() > 0, 'Se debio haber enviado un correo.');
        Test.stopTest();
    }

    @IsTest
    static void sendReceiptEmail_skipsEmailWhenNoEmail() {
        Campaign__c campaign = makeActiveCampaign();
        Donation__c donation = new Donation__c(
            Campaign__c = campaign.Id, Amount__c = 100,
            Payment_Status__c = 'Paid', Is_Anonymous__c = true
        );
        insert donation;
        Test.startTest();
        DonationManagementService.sendReceiptEmail(donation.Id);
        Test.stopTest();
        System.assertEquals(0, Limits.getEmailInvocations(), 'No se debe enviar correo si no hay email.');
    }

    @IsTest
    static void sendReceiptEmail_withInvoiceData_doesNotThrow() {
        Campaign__c campaign = makeActiveCampaign();
        Donation__c donation = new Donation__c(
            Campaign__c = campaign.Id, Amount__c = 500,
            Payment_Status__c = 'Paid', Donor_Name__c = 'Empresa SA',
            Donor_Email__c = 'factura@example.test', Is_Anonymous__c = false,
            Needs_Invoice__c = true, Legal_Name__c = 'Empresa SA de CV',
            RFC__c = 'ESA010101AAA', Postal_Code__c = '06600',
            Tax_Regime__c = '601', CFDI_Use__c = 'D04'
        );
        insert donation;
        Test.startTest();
        DonationManagementService.sendReceiptEmail(donation.Id);
        System.assert(Limits.getEmailInvocations() > 0, 'Se debio enviar correo con datos fiscales.');
        Test.stopTest();
    }
}
