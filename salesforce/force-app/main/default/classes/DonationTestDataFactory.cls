@IsTest
public class DonationTestDataFactory {
    /**
     * Creates a System Administrator test user with Donation_Coordination and
     * Donation_Treasury Permission Sets assigned so FLS is available even
     * during dry-run validations against a fresh org.
     */
    public static User createTestUser() {
        Profile adminProfile = [
            SELECT Id
            FROM Profile
            WHERE Name IN ('System Administrator', 'Administrador del sistema')
            LIMIT 1
        ];
        String uniqueSuffix = String.valueOf(DateTime.now().getTime()) + String.valueOf(Crypto.getRandomInteger());
        User testUser = new User(
            Alias = 'dtest',
            Email = 'donation.test@example.org',
            EmailEncodingKey = 'UTF-8',
            LastName = 'DonationTest',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Mexico_City',
            Username = 'donation.test.' + uniqueSuffix + '@example.org'
        );
        insert testUser;

        List<PermissionSet> permSets = [
            SELECT Id
            FROM PermissionSet
            WHERE Name IN ('Donation_Coordination', 'Donation_Treasury')
        ];
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        for (PermissionSet ps : permSets) {
            assignments.add(new PermissionSetAssignment(
                AssigneeId = testUser.Id,
                PermissionSetId = ps.Id
            ));
        }
        if (!assignments.isEmpty()) {
            insert assignments;
        }
        return testUser;
    }
}
