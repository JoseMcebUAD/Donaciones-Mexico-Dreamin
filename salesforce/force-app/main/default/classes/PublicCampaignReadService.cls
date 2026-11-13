// Purpose-specific privileged reader. Every selected field is intentionally
// mapped by PublicCampaignController to a public DTO.
public without sharing class PublicCampaignReadService {
    public class CampaignSnapshot {
        public Campaign__c campaign;
        public List<Donor_Recognition__c> recognitions = new List<Donor_Recognition__c>();
    }

    public static List<CampaignSnapshot> fetchActiveCampaigns() {
        List<Campaign__c> campaigns = [
            SELECT Id, Name, Goal_Amount__c, Raised_Amount__c, Anonymous_Donor_Count__c,
                Expiration_Date__c, Allow_Additional_Donations__c
            FROM Campaign__c
            WHERE Is_Active__c = true
            WITH SYSTEM_MODE
            ORDER BY Name
        ];
        Map<Id, CampaignSnapshot> snapshotsByCampaign = new Map<Id, CampaignSnapshot>();
        for (Campaign__c campaign : campaigns) {
            CampaignSnapshot snapshot = new CampaignSnapshot();
            snapshot.campaign = campaign;
            snapshotsByCampaign.put(campaign.Id, snapshot);
        }
        if (!snapshotsByCampaign.isEmpty()) {
            Set<Id> campaignIds = snapshotsByCampaign.keySet();
            for (Donor_Recognition__c recognition : [
                SELECT Campaign__c, Display_Name__c, Recognition_Type__c, Image_URL__c, Amount__c
                FROM Donor_Recognition__c
                WHERE Campaign__c IN :campaignIds AND Is_Public__c = true
                WITH SYSTEM_MODE
                ORDER BY CreatedDate DESC
                LIMIT 250
            ]) {
                CampaignSnapshot snapshot = snapshotsByCampaign.get(recognition.Campaign__c);
                if (snapshot.recognitions.size() < 50) {
                    snapshot.recognitions.add(recognition);
                }
            }
        }
        return snapshotsByCampaign.values();
    }
}
