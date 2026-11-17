// Public AuraEnabled boundary. It exposes only immutable, non-sensitive DTOs.
public with sharing class PublicCampaignController {
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
        @AuraEnabled public String displayName;
        @AuraEnabled public String recognitionType;
        @AuraEnabled public String imageUrl;
        @AuraEnabled public Decimal amount;
    }

    @AuraEnabled(cacheable=true)
    public static List<CampaignView> getActiveCampaigns() {
        List<CampaignView> result = new List<CampaignView>();
        Date today = Date.today();
        for (PublicCampaignReadService.CampaignSnapshot snapshot : PublicCampaignReadService.fetchActiveCampaigns()) {
            Campaign__c campaign = snapshot.campaign;
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
            item.recognizedDonors = toRecognitionViews(snapshot.recognitions);
            if (isExpired) {
                item.blockedReason = 'Esta campaña ha cerrado. Gracias por tu interés.';
            } else if (isFull) {
                item.blockedReason = 'Esta campaña alcanzó su meta. ¡Gracias a todos los donantes!';
            }
            result.add(item);
        }
        return result;
    }

    private static List<RecognizedDonorView> toRecognitionViews(List<Donor_Recognition__c> recognitions) {
        List<RecognizedDonorView> result = new List<RecognizedDonorView>();
        for (Donor_Recognition__c recognition : recognitions) {
            RecognizedDonorView item = new RecognizedDonorView();
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
}
