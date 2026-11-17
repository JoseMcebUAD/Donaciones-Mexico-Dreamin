// Purpose-specific privileged writer. It never returns Donation__c records.
public without sharing class PublicDonationCommandService {
    public static Campaign__c findActiveCampaign(Id campaignId) {
        List<Campaign__c> campaigns = [
            SELECT Id, Goal_Amount__c, Raised_Amount__c, Allow_Additional_Donations__c, Expiration_Date__c
            FROM Campaign__c
            WHERE Id = :campaignId AND Is_Active__c = true
            WITH SYSTEM_MODE
            LIMIT 1
        ];
        if (campaigns.isEmpty()) {
            throw new AuraHandledException('Select an active campaign and a positive amount.');
        }
        return campaigns[0];
    }

    public static Id createPendingDonation(
        PublicDonationController.DonationRequest request,
        Id campaignId,
        String checkoutReference,
        String stripeSessionId
    ) {
        Donation__c donation = new Donation__c(
            Campaign__c = campaignId,
            Amount__c = request.amount,
            Payment_Status__c = 'Pending',
            Is_Anonymous__c = request.isAnonymous,
            Wants_Recognition__c = request.isAnonymous ? false : request.wantsRecognition,
            Recognition_Type__c = request.wantsRecognition ? request.recognitionType : null,
            Recognition_Name__c = request.wantsRecognition ? request.recognitionName.trim() : null,
            Recognition_Image_URL__c = request.wantsRecognition && !String.isBlank(request.recognitionImageUrl)
                ? request.recognitionImageUrl.trim()
                : null,
            Needs_Invoice__c = request.needsInvoice,
            Donor_Name__c = request.isAnonymous ? null : request.donorName,
            Donor_Email__c = request.donorEmail,
            Legal_Name__c = request.legalName,
            RFC__c = request.rfc == null ? null : request.rfc.trim().toUpperCase(),
            Postal_Code__c = request.postalCode,
            Tax_Regime__c = request.taxRegime,
            CFDI_Use__c = request.cfdiUse,
            Checkout_Reference__c = checkoutReference,
            Stripe_Session_Id__c = stripeSessionId
        );
        Database.SaveResult saveResult = Database.insert(donation, AccessLevel.SYSTEM_MODE);
        if (!saveResult.isSuccess()) {
            throw new AuraHandledException('Checkout could not be recorded. Please try again later.');
        }
        return saveResult.getId();
    }
}
