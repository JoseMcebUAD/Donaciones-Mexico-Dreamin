public without sharing class WebhookAuditService {

    private static final Integer MAX_REASON_LENGTH   = 1000;
    private static final Integer MAX_PAYLOAD_LENGTH  = 32768;
    private static final Integer MAX_RAW_FALLBACK    = 500;
    private static final Set<String> SENSITIVE_TOKENS = new Set<String>{
        'card', 'payment_method', 'secret', 'token', 'cvc', 'cvv', 'exp'
    };

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
            Map<String, Object> sanitized = sanitizeMap(parsed);
            return truncate(JSON.serialize(sanitized), MAX_PAYLOAD_LENGTH);
        } catch (Exception ex) {
            return truncate(rawBody, MAX_RAW_FALLBACK);
        }
    }

    private static Map<String, Object> sanitizeMap(Map<String, Object> input) {
        Map<String, Object> result = new Map<String, Object>();
        for (String key : input.keySet()) {
            if (isSensitiveKey(key)) {
                continue;
            }
            Object val = input.get(key);
            if (val instanceof Map<String, Object>) {
                result.put(key, sanitizeMap((Map<String, Object>) val));
            } else {
                result.put(key, val);
            }
        }
        return result;
    }

    private static Boolean isSensitiveKey(String key) {
        String lower = key.toLowerCase();
        for (String token : SENSITIVE_TOKENS) {
            if (lower.contains(token)) {
                return true;
            }
        }
        return false;
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
