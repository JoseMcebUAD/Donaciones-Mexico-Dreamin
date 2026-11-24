public without sharing class WebhookAuditService {

    private static final Integer MAX_REASON_LENGTH   = 1000;
    private static final Integer MAX_PAYLOAD_LENGTH = 2000;

    public static void log(String rawBody, String outcome, String rejectionReason) {
        try {
            Webhook_Audit_Log__c entry = new Webhook_Audit_Log__c(
                Received_At__c       = DateTime.now(),
                Outcome__c           = outcome,
                Rejection_Reason__c  = truncate(rejectionReason, MAX_REASON_LENGTH),
                Sanitized_Payload__c = sanitizePayload(rawBody),
                Event_Type__c        = extractEventType(rawBody),
                Checkout_Reference__c = extractCheckoutRef(rawBody)
            );
            Database.insert(entry, AccessLevel.SYSTEM_MODE);
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'WebhookAuditService.log failed: ' + ex.getMessage());
        }
    }

    private static String sanitizePayload(String rawBody) {
        if (String.isBlank(rawBody)) {
            return '';
        }
        try {
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(rawBody);
            Map<String, Object> summary = new Map<String, Object>();
            copyIfPresent(parsed, summary, 'id');
            copyIfPresent(parsed, summary, 'type');
            Map<String, Object> data = (Map<String, Object>) parsed.get('data');
            Map<String, Object> session = data == null ? null : (Map<String, Object>) data.get('object');
            if (session != null) {
                Map<String, Object> publicSession = new Map<String, Object>();
                for (String key : new List<String>{'id', 'client_reference_id', 'amount_total', 'currency', 'status', 'payment_status'}) {
                    copyIfPresent(session, publicSession, key);
                }
                summary.put('session', publicSession);
            }
            return truncate(JSON.serialize(summary), MAX_PAYLOAD_LENGTH);
        } catch (Exception ex) {
            return '';
        }
    }

    private static void copyIfPresent(Map<String, Object> source, Map<String, Object> destination, String key) {
        if (source.containsKey(key)) {
            destination.put(key, source.get(key));
        }
    }

    private static String extractEventType(String rawBody) {
        try {
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(rawBody);
            return (String) parsed.get('type');
        } catch (Exception ex) {
            return null;
        }
    }

    private static String extractCheckoutRef(String rawBody) {
        try {
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(rawBody);
            Map<String, Object> data = (Map<String, Object>) parsed.get('data');
            Map<String, Object> obj  = data != null ? (Map<String, Object>) data.get('object') : null;
            return obj != null ? (String) obj.get('client_reference_id') : null;
        } catch (Exception ex) {
            return null;
        }
    }

    private static String truncate(String value, Integer maxLength) {
        if (value == null) return null;
        return value.length() <= maxLength ? value : value.substring(0, maxLength);
    }
}
