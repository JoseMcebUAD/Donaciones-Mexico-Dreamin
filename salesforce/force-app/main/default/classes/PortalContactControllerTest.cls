@IsTest
private class PortalContactControllerTest {

    @IsTest
    static void testCreateCase_success() {
        Test.startTest();
        PortalContactController.createCase('María López', 'maria@example.test', 'Quiero más información sobre Mexico Dreamin.');
        Test.stopTest();

        List<Case> cases = [SELECT Subject, SuppliedEmail, SuppliedName, Origin, Status FROM Case LIMIT 1];
        Assert.isTrue(cases.size() == 1, 'Se debió crear exactamente un Case.');
        Assert.areEqual('Contacto desde portal - María López', cases[0].Subject);
        Assert.areEqual('maria@example.test', cases[0].SuppliedEmail);
        Assert.areEqual('María López', cases[0].SuppliedName);
        Assert.areEqual('Web', cases[0].Origin);
        Assert.areEqual('New', cases[0].Status);
    }

    @IsTest
    static void testCreateCase_emptyName() {
        try {
            Test.startTest();
            PortalContactController.createCase('', 'valid@example.test', 'Mensaje válido.');
            Test.stopTest();
            Assert.fail('Se esperaba AuraHandledException por nombre vacío.');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('nombre'), 'El mensaje de error debe mencionar el nombre.');
        }
    }

    @IsTest
    static void testCreateCase_invalidEmail() {
        try {
            Test.startTest();
            PortalContactController.createCase('Juan Pérez', 'correo-invalido', 'Mensaje válido.');
            Test.stopTest();
            Assert.fail('Se esperaba AuraHandledException por email inválido.');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('correo'), 'El mensaje de error debe mencionar el correo.');
        }
    }

    @IsTest
    static void testCreateCase_emptyMessage() {
        try {
            Test.startTest();
            PortalContactController.createCase('Juan Pérez', 'juan@example.test', '');
            Test.stopTest();
            Assert.fail('Se esperaba AuraHandledException por mensaje vacío.');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('mensaje'), 'El mensaje de error debe mencionar el mensaje.');
        }
    }
}
