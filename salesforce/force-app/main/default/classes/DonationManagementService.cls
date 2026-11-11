public with sharing class DonationManagementService {
    @AuraEnabled
    public static void confirmPayment(Id donationId) {
        Donation__c donation = [SELECT Id, Name, Payment_Status__c, Donor_Email__c, Donor_Name__c, Amount__c FROM Donation__c WHERE Id = :donationId FOR UPDATE];
        if (donation.Payment_Status__c == 'Paid') throw new AuraHandledException('This donation is already paid; no duplicate receipt was sent.');
        donation.Payment_Status__c = 'Paid';
        update donation;
        if (!String.isBlank(donation.Donor_Email__c)) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { donation.Donor_Email__c });
            email.setSubject('Mexico Dreamin donation receipt ' + donation.Name);
            email.setPlainTextBody('Thank you for your donation of $' + donation.Amount__c + '. Your reference is ' + donation.Name + '.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }
}
