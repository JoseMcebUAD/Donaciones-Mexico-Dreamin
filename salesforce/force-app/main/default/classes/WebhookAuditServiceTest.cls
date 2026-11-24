@IsTest
private class WebhookAuditServiceTest {

    private static String buildValidBody(String eventType, String clientRef) {
        return '{"id":"evt_test","type":"' + eventType + '","data":{"object":{"id":"cs_test","client_reference_id":"' + clientRef + '"}}}';
    }

    @IsTest
    static void log_accepted_createsLogWithCorrectOutcome() {
        String body = buildValidBody('checkout.session.completed', 'MD-ref001');
        Test.startTest();
        WebhookAuditService.log(body, 'Accepted', null);
        Test.stopTest();

        List<Webhook_Audit_Log__c> logs = [SELECT Outcome__c, Event_Type__c, Checkout_Reference__c FROM Webhook_Audit_Log__c];
        System.assertEquals(1, logs.size(), 'Se debe crear un registro de log.');
        System.assertEquals('Accepted', logs[0].Outcome__c);
        System.assertEquals('checkout.session.completed', logs[0].Event_Type__c);
        System.assertEquals('MD-ref001', logs[0].Checkout_Reference__c);
    }

    @IsTest
    static void log_rejectedSignature_storesReason() {
        String body = buildValidBody('checkout.session.completed', 'MD-ref002');
        Test.startTest();
        WebhookAuditService.log(body, 'Rejected_Signature', 'Signature mismatch.');
        Test.stopTest();

        Webhook_Audit_Log__c entry = [SELECT Outcome__c, Rejection_Reason__c FROM Webhook_Audit_Log__c LIMIT 1];
        System.assertEquals('Rejected_Signature', entry.Outcome__c);
        System.assertEquals('Signature mismatch.', entry.Rejection_Reason__c);
    }

    @IsTest
    static void log_invalidJson_storesTruncatedRaw() {
        String badBody = 'NOT_JSON {{{';
        Test.startTest();
        WebhookAuditService.log(badBody, 'Rejected_Payload', 'parse error');
        Test.stopTest();

        Webhook_Audit_Log__c entry = [SELECT Sanitized_Payload__c, Event_Type__c FROM Webhook_Audit_Log__c LIMIT 1];
        System.assert(entry.Sanitized_Payload__c.startsWith('NOT_JSON'), 'Debe contener el raw body al fallar parseo.');
        System.assertEquals(null, entry.Event_Type__c, 'Event_Type debe ser null con JSON invalido.');
    }

    @IsTest
    static void log_sanitizesCardData() {
        String body = '{"id":"evt_01","type":"checkout.session.completed","card_number":"4111111111111111","client_reference_id":"MD-ref003","data":{"object":{"client_reference_id":"MD-ref003"}}}';
        Test.startTest();
        WebhookAuditService.log(body, 'Accepted', null);
        Test.stopTest();

        Webhook_Audit_Log__c entry = [SELECT Sanitized_Payload__c FROM Webhook_Audit_Log__c LIMIT 1];
        System.assert(!entry.Sanitized_Payload__c.contains('card_number'), 'card_number debe eliminarse del payload.');
        System.assert(entry.Sanitized_Payload__c.contains('client_reference_id'), 'client_reference_id debe preservarse.');
    }

    @IsTest
    static void log_emptyBody_doesNotThrow() {
        Test.startTest();
        WebhookAuditService.log('', 'Rejected_Payload', 'Empty body');
        Test.stopTest();

        List<Webhook_Audit_Log__c> logs = [SELECT Id FROM Webhook_Audit_Log__c];
        System.assertEquals(1, logs.size(), 'Se debe crear log incluso con body vacio.');
    }

    @IsTest
    static void log_neverThrowsException() {
        String largeBody = 'x'.repeat(40000);
        Test.startTest();
        WebhookAuditService.log(largeBody, 'Rejected_Payload', 'too large');
        Test.stopTest();

        List<Webhook_Audit_Log__c> logs = [SELECT Id FROM Webhook_Audit_Log__c];
        System.assertEquals(1, logs.size(), 'Debe crear log incluso con payload muy grande.');
    }
}
