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
            Recognition_Type__c = request.wantsRecognition ? 'Individual' : null,
            Recognition_Name__c = request.wantsRecognition ? request.recognitionName.trim() : null,
            Recognition_Image_URL__c = null,
            Needs_Invoice__c = request.needsInvoice,
            Donor_Name__c = request.isAnonymous ? null : request.donorName,
            Donor_Email__c = request.donorEmail,
            Legal_Name__c = request.legalName,
            RFC__c = request.rfc == null ? null : request.rfc.trim().toUpperCase(),
            Postal_Code__c = request.postalCode,
            Tax_Regime__c = request.taxRegime,
            CFDI_Use__c = request.cfdiUse,
            Checkout_Reference__c = checkoutReference,
            Stripe_Session_Id__c = stripeSessionId,
            Privacy_Accepted__c = request.privacyAccepted == true
        );
        Database.SaveResult saveResult = Database.insert(donation, AccessLevel.SYSTEM_MODE);
        if (!saveResult.isSuccess()) {
            throw new AuraHandledException('Checkout could not be recorded. Please try again later.');
        }
        Id donationId = saveResult.getId();
        if (request.wantsRecognition && !String.isBlank(request.recognitionImageBase64)) {
            String imageUrl = publishDonorImage(donationId, request.recognitionImageBase64, request.recognitionImageFileName);
            Database.update(new Donation__c(Id = donationId, Recognition_Image_URL__c = imageUrl), AccessLevel.SYSTEM_MODE);
        }
        return donationId;
    }

    public static Donation__c findPendingDonation(String checkoutReference) {
        if (String.isBlank(checkoutReference) || !Pattern.matches('MD-[0-9a-f]{32}', checkoutReference)) {
            throw new AuraHandledException('No se encontró un intento de pago válido.');
        }
        List<Donation__c> donations = [
            SELECT Id, Campaign__c, Amount__c, Donor_Email__c
            FROM Donation__c
            WHERE Checkout_Reference__c = :checkoutReference
                AND Payment_Status__c = 'Pending'
                AND Stripe_Session_Id__c = null
                AND CreatedDate = LAST_N_DAYS:1
            WITH SYSTEM_MODE
            LIMIT 1
        ];
        if (donations.isEmpty()) {
            throw new AuraHandledException('Este intento de pago ya no está disponible.');
        }
        return donations[0];
    }

    public static Donation__c findDonationByCheckoutReference(String checkoutReference) {
        if (String.isBlank(checkoutReference)) {
            return null;
        }
        List<Donation__c> rows = [
            SELECT Id, Payment_Status__c, Stripe_Session_Id__c, Amount__c
            FROM Donation__c
            WHERE Checkout_Reference__c = :checkoutReference
              AND Payment_Status__c = 'Pending'
            WITH SYSTEM_MODE
            LIMIT 1
            FOR UPDATE
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    public static void attachCheckoutSession(Id donationId, String stripeSessionId) {
        if (String.isBlank(stripeSessionId) || !stripeSessionId.startsWith('cs_test_')) {
            throw new AuraHandledException('La pasarela devolvió una sesión inválida.');
        }
        Database.update(new Donation__c(Id = donationId, Stripe_Session_Id__c = stripeSessionId), AccessLevel.SYSTEM_MODE);
    }

    private static String publishDonorImage(Id donationId, String base64Data, String fileName) {
        String rawBase64 = base64Data.contains(',') ? base64Data.substringAfter(',') : base64Data;
        String safeFileName = String.isBlank(fileName) ? 'donor-image.jpg' : fileName;

        ContentVersion cv = new ContentVersion();
        cv.Title = safeFileName;
        cv.PathOnClient = safeFileName;
        cv.VersionData = EncodingUtil.base64Decode(rawBase64);
        cv.FirstPublishLocationId = donationId;
        Database.insert(cv, AccessLevel.SYSTEM_MODE);

        cv = [SELECT Id FROM ContentVersion WHERE Id = :cv.Id WITH SYSTEM_MODE LIMIT 1];

        ContentDistribution dist = new ContentDistribution();
        dist.Name = 'DonorImage-' + donationId;
        dist.ContentVersionId = cv.Id;
        dist.PreferencesAllowOriginalDownload = true;
        dist.PreferencesLinkLatestVersion = true;
        dist.PreferencesNotifyOnVisit = false;
        dist.PreferencesPasswordRequired = false;
        Database.insert(dist, AccessLevel.SYSTEM_MODE);

        dist = [SELECT DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution WHERE Id = :dist.Id WITH SYSTEM_MODE LIMIT 1];
        return dist.ContentDownloadUrl != null ? dist.ContentDownloadUrl : dist.DistributionPublicUrl;
    }
}
