public without sharing class PublicCampaignController {
    public class CampaignView {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public Decimal goalAmount;
        @AuraEnabled public Decimal raisedAmount;
        @AuraEnabled public Decimal progressPercent;
    }

    @AuraEnabled(cacheable=true)
    public static List<CampaignView> getActiveCampaigns() {
        List<CampaignView> result = new List<CampaignView>();
        List<Campaign__c> campaigns = [
            SELECT Id, Name, Goal_Amount__c
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
        for (Campaign__c campaign : campaigns) {
            CampaignView item = new CampaignView();
            item.id = campaign.Id;
            item.name = campaign.Name;
            item.goalAmount = campaign.Goal_Amount__c;
            item.raisedAmount = raisedByCampaign.containsKey(campaign.Id)
                ? raisedByCampaign.get(campaign.Id)
                : 0;
            item.progressPercent = item.goalAmount > 0 ? (item.raisedAmount / item.goalAmount) * 100 : 0;
            result.add(item);
        }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<Donation__c> getRecognizedDonors(Id campaignId) {
        if (campaignId == null) return new List<Donation__c>();
        return [
            SELECT Donor_Name__c, Amount__c
            FROM Donation__c
            WHERE Campaign__c = :campaignId
              AND Payment_Status__c = 'Paid'
              AND Wants_Recognition__c = true
              AND Is_Anonymous__c = false
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];
    }
}
