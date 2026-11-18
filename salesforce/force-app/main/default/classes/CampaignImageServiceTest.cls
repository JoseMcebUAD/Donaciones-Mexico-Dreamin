@IsTest
private class CampaignImageServiceTest {

    @TestSetup
    static void setup() {
        Campaign__c campaign = new Campaign__c(
            Name = 'Test Campaign',
            Goal_Amount__c = 10000
        );
        insert campaign;
    }

    @IsTest
    static void getCoverImages_returnsEmptyListWhenNoneLinked() {
        Campaign__c campaign = [SELECT Id FROM Campaign__c LIMIT 1];

        Test.startTest();
        List<CampaignImageService.ImageView> images =
            CampaignImageService.getCoverImages(campaign.Id);
        Test.stopTest();

        Assert.areEqual(0, images.size(), 'Expected no images for a fresh campaign');
    }

    @IsTest
    static void getCoverImages_returnsLinkedFiles() {
        Campaign__c campaign = [SELECT Id FROM Campaign__c LIMIT 1];

        ContentVersion cv = new ContentVersion(
            Title = 'campaign-cover.jpg',
            PathOnClient = 'campaign-cover.jpg',
            VersionData = Blob.valueOf('fake-image-data'),
            IsMajorVersion = true
        );
        insert cv;
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        ContentDocumentLink link = new ContentDocumentLink(
            LinkedEntityId = campaign.Id,
            ContentDocumentId = cv.ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert link;

        Test.startTest();
        List<CampaignImageService.ImageView> images =
            CampaignImageService.getCoverImages(campaign.Id);
        Test.stopTest();

        Assert.areEqual(1, images.size(), 'Expected one linked image');
        Assert.areEqual(cv.ContentDocumentId, images[0].contentDocumentId);
        Assert.areEqual('campaign-cover.jpg', images[0].title);
    }

    @IsTest
    static void publishCoverImage_updatesCampaignUrl() {
        Campaign__c campaign = [SELECT Id FROM Campaign__c LIMIT 1];

        ContentVersion cv = new ContentVersion(
            Title = 'cover.png',
            PathOnClient = 'cover.png',
            VersionData = Blob.valueOf('fake-image-data'),
            IsMajorVersion = true
        );
        insert cv;
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        ContentDocumentLink link = new ContentDocumentLink(
            LinkedEntityId = campaign.Id,
            ContentDocumentId = cv.ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert link;

        Test.startTest();
        String url = CampaignImageService.publishCoverImage(campaign.Id, cv.ContentDocumentId);
        Test.stopTest();

        Campaign__c updated = [SELECT Cover_Image_URL__c FROM Campaign__c WHERE Id = :campaign.Id];
        Assert.isNotNull(url, 'Expected a distribution URL');
        Assert.areEqual(url, updated.Cover_Image_URL__c, 'Campaign URL must match distribution URL');
    }
}
