// This is the only public read boundary. It exposes an explicit DTO allow-list
// and never queries Donation__c, so the Guest User receives no donor records.
public without sharing class PublicCampaignController {
    public class CampaignView {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public Decimal goalAmount;
        @AuraEnabled public Decimal raisedAmount;
        @AuraEnabled public Decimal progressPercent;
        @AuraEnabled public Boolean isDonationBlocked;
        @AuraEnabled public String blockedReason;
        @AuraEnabled public Integer anonymousDonorCount;
        @AuraEnabled public List<RecognizedDonorView> recognizedDonors;
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
            SELECT Id, Name, Goal_Amount__c, Raised_Amount__c, Anonymous_Donor_Count__c, Expiration_Date__c, Allow_Additional_Donations__c
            FROM Campaign__c
            WHERE Is_Active__c = true
            ORDER BY Name
        ];
        Set<Id> campaignIds = new Map<Id, Campaign__c>(campaigns).keySet();
        Map<Id, List<RecognizedDonorView>> recognitionsByCampaign = new Map<Id, List<RecognizedDonorView>>();
        for (Id campaignId : campaignIds) {
            recognitionsByCampaign.put(campaignId, new List<RecognizedDonorView>());
        }
        for (Donor_Recognition__c recognition : [
            SELECT Campaign__c, Display_Name__c, Recognition_Type__c, Image_URL__c, Amount__c
            FROM Donor_Recognition__c
            WHERE Campaign__c IN :campaignIds AND Is_Public__c = true
            ORDER BY CreatedDate DESC
            LIMIT 250
        ]) {
            List<RecognizedDonorView> campaignRecognitions = recognitionsByCampaign.get(recognition.Campaign__c);
            if (campaignRecognitions.size() >= 50) continue;
            RecognizedDonorView donor = new RecognizedDonorView();
            donor.displayName = recognition.Display_Name__c;
            donor.recognitionType = String.isBlank(recognition.Recognition_Type__c) ? 'Individual' : recognition.Recognition_Type__c;
            donor.imageUrl = recognition.Image_URL__c;
            donor.amount = recognition.Amount__c;
            campaignRecognitions.add(donor);
        }
        Date today = Date.today();
        for (Campaign__c campaign : campaigns) {
            CampaignView item = new CampaignView();
            item.id = campaign.Id;
            item.name = campaign.Name;
            item.goalAmount = campaign.Goal_Amount__c;
            item.raisedAmount = campaign.Raised_Amount__c == null ? 0 : campaign.Raised_Amount__c;
            item.progressPercent = item.goalAmount > 0 ? (item.raisedAmount / item.goalAmount) * 100 : 0;
            Boolean isExpired = campaign.Expiration_Date__c != null && campaign.Expiration_Date__c < today;
            Boolean isFull = item.progressPercent >= 100 && !campaign.Allow_Additional_Donations__c;
            item.isDonationBlocked = isExpired || isFull;
            item.anonymousDonorCount = campaign.Anonymous_Donor_Count__c == null
                ? 0
                : Integer.valueOf(campaign.Anonymous_Donor_Count__c);
            item.recognizedDonors = recognitionsByCampaign.get(campaign.Id);
            if (isExpired) {
                item.blockedReason = 'Esta campaña ha cerrado. Gracias por tu interés.';
            } else if (isFull) {
                item.blockedReason = 'Esta campaña alcanzó su meta. ¡Gracias a todos los donantes!';
            }
            result.add(item);
        }
        return result;
    }

}
