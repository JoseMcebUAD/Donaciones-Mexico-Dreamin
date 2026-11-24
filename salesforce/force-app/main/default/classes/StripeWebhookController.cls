@RestResource(urlMapping='/stripe/webhook')
global without sharing class StripeWebhookController {
    @TestVisible private static String webhookSecretOverride;

    @HttpPost
    global static void doPost() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String rawBody = RestContext.request.requestBody != null
            ? RestContext.request.requestBody.toString()
            : '';
        try {
            String sigHeader = RestContext.request.headers.get('Stripe-Signature');
            String secret = webhookSecretOverride != null ? webhookSecretOverride : System.Label.Stripe_Webhook_Secret;
            StripeWebhookService.verifySignature(rawBody, sigHeader, secret);
            StripeWebhookService.processEvent(rawBody);
            WebhookAuditService.log(rawBody, 'Accepted', null);
            res.statusCode = 200;
            res.responseBody = Blob.valueOf('{"received":true}');
        } catch (StripeWebhookService.WebhookSecurityException e) {
            WebhookAuditService.log(rawBody, 'Rejected_Signature', e.getMessage());
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"error":"invalid_signature"}');
        } catch (StripeWebhookService.WebhookReferenceException e) {
            WebhookAuditService.log(rawBody, 'Rejected_Reference', e.getMessage());
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"error":"bad_request"}');
        } catch (Exception e) {
            WebhookAuditService.log(rawBody, 'Rejected_Payload', e.getMessage());
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"error":"bad_request"}');
        }
    }
}
