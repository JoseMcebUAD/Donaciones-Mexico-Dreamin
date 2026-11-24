@IsTest
private class StripeWebhookSecretProviderTest {
    @IsTest
    static void returnsConfiguredSecret() {
        insert new Stripe_Webhook_Config__c(
            Name = 'Stripe_Test',
            Signing_Secret__c = 'test_webhook_secret'
        );
        System.assertEquals('test_webhook_secret', StripeWebhookSecretProvider.getSigningSecret());
    }

    @IsTest
    static void rejectsMissingConfiguration() {
        try {
            StripeWebhookSecretProvider.getSigningSecret();
            System.assert(false, 'A missing signing secret must fail closed.');
        } catch (StripeWebhookService.WebhookSecurityException expected) {
            System.assert(expected.getMessage().contains('not configured'));
        }
    }
}
