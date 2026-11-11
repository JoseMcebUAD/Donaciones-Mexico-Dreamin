public with sharing class DonationExpirationService implements Schedulable, Database.Batchable<SObject> {
    private static final Integer EXPIRATION_HOURS = 24;

    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new DonationExpirationService(), 200);
    }

    public Database.QueryLocator start(Database.BatchableContext ctx) {
        DateTime cutoff = DateTime.now().addHours(-EXPIRATION_HOURS);
        return Database.getQueryLocator([
            SELECT Id
            FROM Donation__c
            WHERE Payment_Status__c = 'Pending'
              AND CreatedDate < :cutoff
        ]);
    }

    public void execute(Database.BatchableContext ctx, List<Donation__c> scope) {
        for (Donation__c d : scope) {
            d.Payment_Status__c = 'Cancelled';
        }
        update scope;
    }

    public void finish(Database.BatchableContext ctx) {}
}
