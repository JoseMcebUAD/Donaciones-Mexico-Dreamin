public with sharing class ContactController {
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
        '^[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$'
    );

    @AuraEnabled
    public static void createCase(String name, String email, String message) {
        if (String.isBlank(name)) {
            throw new AuraHandledException('El nombre es obligatorio.');
        }
        if (String.isBlank(email) || !EMAIL_PATTERN.matcher(email).matches()) {
            throw new AuraHandledException('Ingresa un correo electrónico válido.');
        }
        if (String.isBlank(message)) {
            throw new AuraHandledException('El mensaje no puede estar vacío.');
        }
        ContactCommandService.insertCase(name.trim(), email.trim(), message.trim());
    }
}
