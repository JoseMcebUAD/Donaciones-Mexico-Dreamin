public with sharing class DonationManagementService {
    private static final String SUPPORT_EMAIL = 'soporte@mexicodreamin.com';

    @AuraEnabled
    public static void confirmPayment(Id donationId) {
        Donation__c donation = [
            SELECT Id, Name, Payment_Status__c, Donor_Email__c, Donor_Name__c, Amount__c,
                   Needs_Invoice__c, Legal_Name__c, RFC__c, Postal_Code__c, Tax_Regime__c, CFDI_Use__c,
                   Is_Anonymous__c, Campaign__r.Name
            FROM Donation__c
            WHERE Id = :donationId
            FOR UPDATE
        ];
        if (donation.Payment_Status__c == 'Paid') {
            throw new AuraHandledException('This donation is already paid; no duplicate receipt was sent.');
        }
        donation.Payment_Status__c = 'Paid';
        update donation;
        if (!String.isBlank(donation.Donor_Email__c)) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { donation.Donor_Email__c });
            email.setSubject('Comprobante de donación Mexico Dreamin — ' + donation.Name);
            email.setPlainTextBody(buildReceiptBody(donation));
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }

    private static String buildReceiptBody(Donation__c donation) {
        String recipientName = donation.Is_Anonymous__c ? 'Donante' : donation.Donor_Name__c;
        String campaignName = donation.Campaign__r != null ? donation.Campaign__r.Name : '';
        String body = 'Estimado/a ' + recipientName + ',\n\n'
            + 'Hemos confirmado tu aportación a Mexico Dreamin. A continuación los detalles:\n\n'
            + '  Folio:         ' + donation.Name + '\n'
            + '  Campaña:       ' + campaignName + '\n'
            + '  Monto:         MXN ' + donation.Amount__c.setScale(2) + '\n';
        if (donation.Needs_Invoice__c) {
            body += '\nDatos para facturación:\n'
                + '  Razón social:  ' + (donation.Legal_Name__c ?? '') + '\n'
                + '  RFC:           ' + (donation.RFC__c ?? '') + '\n'
                + '  Código postal: ' + (donation.Postal_Code__c ?? '') + '\n'
                + '  Régimen:       ' + (donation.Tax_Regime__c ?? '') + '\n'
                + '  Uso del CFDI:  ' + (donation.CFDI_Use__c ?? '') + '\n'
                + '\n  Nota: Este comprobante no es un CFDI oficial ante el SAT.\n';
        }
        body += '\n¿Tienes dudas? Escríbenos a ' + SUPPORT_EMAIL + '\n\n'
            + '¡Gracias por tu apoyo!\n'
            + 'Equipo Mexico Dreamin';
        return body;
    }
}
