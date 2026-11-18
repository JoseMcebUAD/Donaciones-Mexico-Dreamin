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
        return result.getId();
    }
}
