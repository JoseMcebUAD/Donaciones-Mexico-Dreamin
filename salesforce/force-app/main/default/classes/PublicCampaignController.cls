public without sharing class PublicCampaignController {
    public class CampaignView {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public Decimal goalAmount;
        @AuraEnabled public Decimal raisedAmount;
        @AuraEnabled public Decimal progressPercent;
        @AuraEnabled public Boolean isDonationBlocked;
        @AuraEnabled public String blockedReason;
    }

    public class RecognizedDonorView {
        @AuraEnabled public Id id;
        @AuraEnabled public String displayName;
        @AuraEnabled public String recognitionType;
        @AuraEnabled public String imageUrl;
        @AuraEnabled public Decimal amount;
    }

    @AuraEnabled(cacheable=true)
    public static List<CampaignView> getActiveCampaigns() {
        List<CampaignView> result = new List<CampaignView>();
        List<Campaign__c> campaigns = [
            SELECT Id, Name, Goal_Amount__c, Expiration_Date__c, Allow_Additional_Donations__c
            FROM Campaign__c
            WHERE Is_Active__c = true
            ORDER BY Name
        ];
        Map<Id, Decimal> raisedByCampaign = new Map<Id, Decimal>();
        Set<Id> campaignIds = new Map<Id, Campaign__c>(campaigns).keySet();
        if (!campaignIds.isEmpty()) {
            for (AggregateResult aggregateResult : [
                SELECT Campaign__c campaignId, SUM(Amount__c) raised
                FROM Donation__c
                WHERE Campaign__c IN :campaignIds AND Payment_Status__c = 'Paid'
                GROUP BY Campaign__c
            ]) {
                raisedByCampaign.put(
                    (Id) aggregateResult.get('campaignId'),
                    (Decimal) aggregateResult.get('raised')
                );
            }
        }
        Date today = Date.today();
        for (Campaign__c campaign : campaigns) {
            CampaignView item = new CampaignView();
            item.id = campaign.Id;
            item.name = campaign.Name;
            item.goalAmount = campaign.Goal_Amount__c;
            item.raisedAmount = raisedByCampaign.containsKey(campaign.Id)
                ? raisedByCampaign.get(campaign.Id)
                : 0;
            item.progressPercent = item.goalAmount > 0 ? (item.raisedAmount / item.goalAmount) * 100 : 0;
            Boolean isExpired = campaign.Expiration_Date__c != null && campaign.Expiration_Date__c < today;
            Boolean isFull = item.progressPercent >= 100 && !campaign.Allow_Additional_Donations__c;
            item.isDonationBlocked = isExpired || isFull;
            if (isExpired) {
                item.blockedReason = 'Esta campaña ha cerrado. Gracias por tu interés.';
            } else if (isFull) {
                item.blockedReason = 'Esta campaña alcanzó su meta. ¡Gracias a todos los donantes!';
            }
            result.add(item);
        }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<RecognizedDonorView> getRecognizedDonors(Id campaignId) {
        List<RecognizedDonorView> result = new List<RecognizedDonorView>();
        if (campaignId == null) return result;
        for (Donation__c donation : [
            SELECT Id, Donor_Name__c, Recognition_Name__c, Recognition_Type__c, Recognition_Image_URL__c, Amount__c
            FROM Donation__c
            WHERE Campaign__c = :campaignId
              AND Payment_Status__c = 'Paid'
              AND Wants_Recognition__c = true
              AND Is_Anonymous__c = false
            ORDER BY CreatedDate DESC
            LIMIT 50
        ]) {
            RecognizedDonorView item = new RecognizedDonorView();
            item.id = donation.Id;
            item.displayName = String.isBlank(donation.Recognition_Name__c)
                ? donation.Donor_Name__c
                : donation.Recognition_Name__c;
            item.recognitionType = String.isBlank(donation.Recognition_Type__c)
                ? 'Individual'
                : donation.Recognition_Type__c;
            item.imageUrl = donation.Recognition_Image_URL__c;
            item.amount = donation.Amount__c;
            result.add(item);
        }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static Integer getAnonymousDonorCount(Id campaignId) {
        if (campaignId == null) return 0;
        return [
            SELECT COUNT()
            FROM Donation__c
            WHERE Campaign__c = :campaignId
              AND Payment_Status__c = 'Paid'
              AND Is_Anonymous__c = true
        ];
    }
}
