public without sharing class ContactCommandService {
    public static Id insertCase(String name, String email, String message) {
        Case c = new Case(
            Subject = 'Contacto desde portal - ' + name,
            Description = message,
            SuppliedName = name,
            SuppliedEmail = email,
            Origin = 'Web',
            Status = 'New'
        );
        Database.SaveResult result = Database.insert(c, AccessLevel.SYSTEM_MODE);
        if (!result.isSuccess()) {
            throw new AuraHandledException('No se pudo registrar tu mensaje. Intenta de nuevo más tarde.');
        }
        Case inserted = [SELECT CaseNumber FROM Case WHERE Id = :result.getId() WITH SYSTEM_MODE LIMIT 1];
        sendEmails(name, email, message, inserted.CaseNumber);
        return result.getId();
    }

    private static void sendEmails(String visitorName, String visitorEmail, String message, String caseNumber) {
        try {
            List<PortalConfig__mdt> configs = [
                SELECT Support_Email__c FROM PortalConfig__mdt
                WHERE DeveloperName = 'Default' LIMIT 1
            ];
            String supportEmail = configs.isEmpty() ? null : configs[0].Support_Email__c;

            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

            if (String.isNotBlank(supportEmail)) {
                Messaging.SingleEmailMessage notif = new Messaging.SingleEmailMessage();
                notif.setToAddresses(new List<String>{ supportEmail });
                notif.setSubject('[Caso #' + caseNumber + '] Nuevo contacto: ' + visitorName);
                notif.setPlainTextBody(
                    'Se recibió un nuevo mensaje desde el portal.\n\n' +
                    'Nombre: ' + visitorName + '\n' +
                    'Correo: ' + visitorEmail + '\n\n' +
                    'Mensaje:\n' + message + '\n\n' +
                    'Puedes responder directamente desde Salesforce en el Caso #' + caseNumber + '.'
                );
                notif.setSaveAsActivity(false);
                emails.add(notif);
            }

            Messaging.SingleEmailMessage ack = new Messaging.SingleEmailMessage();
            ack.setToAddresses(new List<String>{ visitorEmail });
            ack.setSubject('Recibimos tu mensaje [Caso #' + caseNumber + '] — Mexico Dreamin');
            ack.setPlainTextBody(
                'Hola ' + visitorName + ',\n\n' +
                'Gracias por contactarnos. Hemos recibido tu mensaje y te responderemos a la brevedad.\n\n' +
                'Número de caso: #' + caseNumber + '\n\n' +
                '— Equipo Mexico Dreamin'
            );
            ack.setSaveAsActivity(false);
            emails.add(ack);

            Messaging.sendEmail(emails);
        } catch (Exception e) {
            // El fallo de email no cancela la creación del caso
        }
    }
}
