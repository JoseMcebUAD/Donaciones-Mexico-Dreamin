# Seguridad, Stripe y Experience Cloud

## Configuración manual en la org

1. Habilita My Domain y Digital Experiences; crea y publica un sitio Experience Cloud.
2. Coloca `campaignCatalog` en la página pública, `donationThankYou` en `/s/thank-you` y, si procede, `donorWall` con su `campaignId` en Experience Builder.
3. Configura un External Credential/Named Credential `Stripe_Test` hacia `https://api.stripe.com`. Guarda `sk_test_...` exclusivamente en la credencial protegida de la org.
4. Configura Stripe Test con la URL publicada del sitio. El formulario usa `/s/thank-you?session_id={CHECKOUT_SESSION_ID}` como retorno exitoso.
5. Autoriza al Guest User sólo para las clases `PublicCampaignController` y `PublicDonationController` si el administrador aprueba la exposición. Nunca autorices `DonationManagementService`.
6. Concede Guest User sólo lectura de `Campaign__c` y campos públicos. No concedas lectura, edición, borrado, View All ni Modify All de `Donation__c`: la creación controlada ocurre sólo en Apex.
7. Asigna `Donation Coordination` a Coordinación y `Donation Treasury` a Tesorería; agrega **Confirm Payment** al layout de `Donation__c`.

## Prueba en incógnito

1. En incógnito, sólo se muestran campañas activas.
2. Prueba donativo normal, anónimo y con factura; anónimo + factura y RFC inválido deben fallar.
3. Completa Stripe Test y comprueba que vuelve a agradecimiento sin afirmar pago confirmado y que el registro queda `Pending`.
4. Como Tesorería, confirma una vez: debe cambiar a `Paid`, enviar comprobante cuando haya correo y rechazar repetición.
5. El muro debe mostrar sólo donativos pagados, no anónimos y con consentimiento.
6. Un visitante no debe poder consultar, editar ni borrar una donación ajena mediante URL o ID.

## Evidencias

Captura catálogo, validaciones, Stripe Test Checkout, retorno seguro, muro, vistas internas, acción de confirmación y prueba incógnito. Nunca captures claves, RFC reales ni URLs secretas.
