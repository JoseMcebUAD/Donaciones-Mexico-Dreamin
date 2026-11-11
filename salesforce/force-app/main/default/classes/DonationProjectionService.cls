public without sharing class DonationProjectionService {
    public static void synchronize(Set<Id> campaignIds) {
        if (campaignIds == null || campaignIds.isEmpty()) {
            return;
        }

        Map<Id, Decimal> raisedByCampaign = new Map<Id, Decimal>();
        Map<Id, Integer> anonymousByCampaign = new Map<Id, Integer>();
        Map<Id, Donation__c> publicDonationsById = new Map<Id, Donation__c>();

        for (Donation__c donation : [
            SELECT Id, Campaign__c, Amount__c, Payment_Status__c, Is_Anonymous__c,
                   Wants_Recognition__c, Donor_Name__c, Recognition_Name__c,
                   Recognition_Type__c, Recognition_Image_URL__c
            FROM Donation__c
            WHERE Campaign__c IN :campaignIds
        ]) {
            if (donation.Payment_Status__c != 'Paid') {
                continue;
            }
            Decimal amount = donation.Amount__c == null ? 0 : donation.Amount__c;
            Decimal currentRaised = raisedByCampaign.containsKey(donation.Campaign__c)
                ? raisedByCampaign.get(donation.Campaign__c)
                : 0;
            raisedByCampaign.put(donation.Campaign__c, currentRaised + amount);

            if (donation.Is_Anonymous__c) {
                Integer currentAnonymous = anonymousByCampaign.containsKey(donation.Campaign__c)
                    ? anonymousByCampaign.get(donation.Campaign__c)
                    : 0;
                anonymousByCampaign.put(donation.Campaign__c, currentAnonymous + 1);
            } else if (donation.Wants_Recognition__c) {
                publicDonationsById.put(donation.Id, donation);
            }
        }

        List<Campaign__c> campaignUpdates = new List<Campaign__c>();
        for (Id campaignId : campaignIds) {
            campaignUpdates.add(new Campaign__c(
                Id = campaignId,
                Raised_Amount__c = raisedByCampaign.containsKey(campaignId) ? raisedByCampaign.get(campaignId) : 0,
                Anonymous_Donor_Count__c = anonymousByCampaign.containsKey(campaignId)
                    ? anonymousByCampaign.get(campaignId)
                    : 0
            ));
        }

        Map<Id, Donor_Recognition__c> existingByDonationId = new Map<Id, Donor_Recognition__c>();
        List<Donor_Recognition__c> recognitionsToDelete = new List<Donor_Recognition__c>();
        for (Donor_Recognition__c recognition : [
            SELECT Id, Source_Donation__c
            FROM Donor_Recognition__c
            WHERE Campaign__c IN :campaignIds
        ]) {
            if (recognition.Source_Donation__c != null) {
                existingByDonationId.put(recognition.Source_Donation__c, recognition);
            } else {
                recognitionsToDelete.add(recognition);
            }
        }

        List<Donor_Recognition__c> recognitionsToSave = new List<Donor_Recognition__c>();
        for (Donation__c donation : publicDonationsById.values()) {
            Donor_Recognition__c recognition = existingByDonationId.containsKey(donation.Id)
                ? existingByDonationId.get(donation.Id)
                : new Donor_Recognition__c(Source_Donation__c = donation.Id);
            recognition.Campaign__c = donation.Campaign__c;
            recognition.Display_Name__c = String.isBlank(donation.Recognition_Name__c)
                ? donation.Donor_Name__c
                : donation.Recognition_Name__c;
            recognition.Recognition_Type__c = String.isBlank(donation.Recognition_Type__c)
                ? 'Individual'
                : donation.Recognition_Type__c;
            recognition.Image_URL__c = donation.Recognition_Image_URL__c;
            recognition.Amount__c = donation.Amount__c;
            recognition.Is_Public__c = true;
            recognitionsToSave.add(recognition);
            existingByDonationId.remove(donation.Id);
        }
        recognitionsToDelete.addAll(existingByDonationId.values());

        update campaignUpdates;
        if (!recognitionsToSave.isEmpty()) {
            upsert recognitionsToSave;
        }
        if (!recognitionsToDelete.isEmpty()) {
            delete recognitionsToDelete;
        }
    }
}
