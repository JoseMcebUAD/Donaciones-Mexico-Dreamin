public with sharing class PortalContactController {
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
        '^[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$'
    );

    @AuraEnabled
    public static void createCase(String name, String email, String message) {
        if (String.isBlank(name)) {
            throwAuraException('El nombre es obligatorio.');
        }
        if (String.isBlank(email) || !EMAIL_PATTERN.matcher(email).matches()) {
            throwAuraException('Ingresa un correo electrónico válido.');
        }
        if (String.isBlank(message)) {
            throwAuraException('El mensaje no puede estar vacío.');
        }
        ContactCommandService.insertCase(name.trim(), email.trim(), message.trim());
    }

    private static void throwAuraException(String message) {
        AuraHandledException ex = new AuraHandledException(message);
        ex.setMessage(message);
        throw ex;
    }
}
