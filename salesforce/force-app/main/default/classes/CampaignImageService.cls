public with sharing class CampaignImageService {

    @AuraEnabled
    public static String publishCoverImage(Id campaignId, Id contentDocumentId) {
        ContentVersion cv = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE ContentDocumentId = :contentDocumentId
                AND IsLatest = true
            WITH USER_MODE
            LIMIT 1
        ];

        ContentDistribution dist = new ContentDistribution();
        dist.Name = 'CampaignCover-' + campaignId;
        dist.ContentVersionId = cv.Id;
        dist.PreferencesAllowOriginalRelatedEntityDownload = true;
        dist.PreferencesLinkLatestVersion = true;
        dist.PreferencesNotifyOnVisit = false;
        dist.PreferencesPasswordRequired = false;
        insert dist;

        dist = [
            SELECT DistributionPublicUrl, ContentDownloadUrl
            FROM ContentDistribution
            WHERE Id = :dist.Id
            WITH USER_MODE
            LIMIT 1
        ];

        String imageUrl = dist.ContentDownloadUrl != null
            ? dist.ContentDownloadUrl
            : dist.DistributionPublicUrl;

        Campaign__c campaign = new Campaign__c(
            Id = campaignId,
            Cover_Image_URL__c = imageUrl
        );
        update campaign;

        return imageUrl;
    }

    @AuraEnabled(cacheable=true)
    public static List<ImageView> getCoverImages(Id campaignId) {
        List<ImageView> result = new List<ImageView>();
        for (ContentDocumentLink link : [
            SELECT ContentDocumentId,
                   ContentDocument.Title,
                   ContentDocument.LatestPublishedVersion.ContentDownloadUrl
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :campaignId
            WITH USER_MODE
            ORDER BY ContentDocument.CreatedDate DESC
        ]) {
            ImageView view = new ImageView();
            view.contentDocumentId = link.ContentDocumentId;
            view.title = link.ContentDocument.Title;
            result.add(view);
        }
        return result;
    }

    public class ImageView {
        @AuraEnabled public Id contentDocumentId;
        @AuraEnabled public String title;
    }
}
