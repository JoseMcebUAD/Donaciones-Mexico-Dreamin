trigger DonationProjectionTrigger on Donation__c (after insert, after update, after delete, after undelete) {
    Set<Id> campaignIds = new Set<Id>();
    List<Donation__c> donations = Trigger.isDelete ? Trigger.old : Trigger.new;
    for (Donation__c donation : donations) {
        if (donation.Campaign__c != null) {
            campaignIds.add(donation.Campaign__c);
        }
    }
    if (Trigger.isUpdate) {
        for (Donation__c donation : Trigger.old) {
            if (donation.Campaign__c != null) {
                campaignIds.add(donation.Campaign__c);
            }
        }
    }
    DonationProjectionService.synchronize(campaignIds);
}
