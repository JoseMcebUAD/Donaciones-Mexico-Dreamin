@RestResource(urlMapping='/stripe/webhook')
global without sharing class StripeWebhookController {
    @HttpPost
    global static void doPost() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        try {
            String rawBody = RestContext.request.requestBody != null
                ? RestContext.request.requestBody.toString()
                : '';
            String sigHeader = RestContext.request.headers.get('Stripe-Signature');
            StripeWebhookService.verifySignature(rawBody, sigHeader, System.Label.Stripe_Webhook_Secret);
            StripeWebhookService.processEvent(rawBody);
            res.statusCode = 200;
            res.responseBody = Blob.valueOf('{"received":true}');
        } catch (StripeWebhookService.WebhookSecurityException e) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"error":"invalid_signature"}');
        } catch (Exception e) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"error":"bad_request"}');
        }
    }
}
