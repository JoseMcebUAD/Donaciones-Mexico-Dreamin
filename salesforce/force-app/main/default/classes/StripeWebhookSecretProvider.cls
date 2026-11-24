public without sharing class StripeWebhookSecretProvider {
    public static String getSigningSecret() {
        List<Stripe_Webhook_Config__c> configs = [
            SELECT Signing_Secret__c
            FROM Stripe_Webhook_Config__c
            WHERE Name = 'Stripe_Test'
            WITH SYSTEM_MODE
            LIMIT 1
        ];
        if (configs.isEmpty() || String.isBlank(configs[0].Signing_Secret__c)) {
            throw new StripeWebhookService.WebhookSecurityException('Webhook signing secret is not configured.');
        }
        return configs[0].Signing_Secret__c;
    }
}
