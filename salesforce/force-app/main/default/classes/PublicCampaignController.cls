public with sharing class PublicCampaignController {
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
            SELECT Id, Name, Goal_Amount__c, Raised_Amount__c, Expiration_Date__c, Allow_Additional_Donations__c
            FROM Campaign__c
            WHERE Is_Active__c = true
            ORDER BY Name
        ];
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
        for (Donor_Recognition__c recognition : [
            SELECT Id, Display_Name__c, Recognition_Type__c, Image_URL__c, Amount__c
            FROM Donor_Recognition__c
            WHERE Campaign__c = :campaignId AND Is_Public__c = true
            ORDER BY CreatedDate DESC
            LIMIT 50
        ]) {
            RecognizedDonorView item = new RecognizedDonorView();
            item.id = recognition.Id;
            item.displayName = recognition.Display_Name__c;
            item.recognitionType = String.isBlank(recognition.Recognition_Type__c)
                ? 'Individual'
                : recognition.Recognition_Type__c;
            item.imageUrl = recognition.Image_URL__c;
            item.amount = recognition.Amount__c;
            result.add(item);
        }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static Integer getAnonymousDonorCount(Id campaignId) {
        if (campaignId == null) return 0;
        List<Campaign__c> campaigns = [
            SELECT Anonymous_Donor_Count__c
            FROM Campaign__c
            WHERE Id = :campaignId AND Is_Active__c = true
            LIMIT 1
        ];
        return campaigns.isEmpty() || campaigns[0].Anonymous_Donor_Count__c == null
            ? 0
            : Integer.valueOf(campaigns[0].Anonymous_Donor_Count__c);
    }
}
