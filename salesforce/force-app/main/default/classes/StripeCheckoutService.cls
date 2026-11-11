public class StripeCheckoutService {
    public class CheckoutResult {
        public String id;
        public String url;
    }

    public static CheckoutResult createSession(
        Decimal amount,
        String checkoutReference,
        String successUrl,
        String cancelUrl
    ) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Stripe_Test/v1/checkout/sessions');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(
            'mode=payment' +
            '&success_url=' + EncodingUtil.urlEncode(successUrl, 'UTF-8') +
            '&cancel_url=' + EncodingUtil.urlEncode(cancelUrl, 'UTF-8') +
            '&client_reference_id=' + EncodingUtil.urlEncode(checkoutReference, 'UTF-8') +
            '&metadata[salesforce_reference]=' + EncodingUtil.urlEncode(checkoutReference, 'UTF-8') +
            '&line_items[0][price_data][currency]=mxn' +
            '&line_items[0][price_data][product_data][name]=' + EncodingUtil.urlEncode('Mexico Dreamin donation', 'UTF-8') +
            '&line_items[0][price_data][unit_amount]=' + String.valueOf((Integer)(amount * 100)) +
            '&line_items[0][quantity]=1'
        );
        HttpResponse response = new Http().send(request);
        if (response.getStatusCode() < 200 || response.getStatusCode() >= 300) {
            throw new AuraHandledException('Checkout could not be created. Please try again later.');
        }
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        CheckoutResult result = new CheckoutResult();
        result.id = (String) payload.get('id');
        result.url = (String) payload.get('url');
        return result;
    }
}
