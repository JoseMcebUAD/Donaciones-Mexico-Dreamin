# Stripe Test en la sandbox

## Checkout saliente

`StripeCheckoutService` crea sesiones mediante `callout:Stripe_Test/v1/checkout/sessions`. La Named Credential `Stripe_Test` debe apuntar a `https://api.stripe.com` y obtener la clave `sk_test_...` de `Stripe_Test_External`. Ninguna clave se guarda en Git, Apex, Custom Labels ni capturas. El sitio público es `https://uady--class2026a.sandbox.my.site.com/donaciones/s/`.

Cada intento registra una donación `Pending` y una referencia `MD-...`; la Checkout Session devuelve un ID `cs_test_...`. El retorno del navegador no confirma el pago.

## Webhook entrante

1. En el mismo entorno de prueba de Stripe al que pertenece `sk_test_...`, abre **Workbench → Webhooks → Create an event destination**.
2. Elige **Your account** y formato **Snapshot**. Selecciona `checkout.session.completed`, `checkout.session.async_payment_succeeded` y `checkout.session.expired`.
3. Usa esta URL HTTPS:

   `https://uady--class2026a.sandbox.my.salesforce-sites.com/webhook/services/apexrest/stripe/webhook`

4. Guarda el destino y revela su signing secret `whsec_...`. Es distinto de la clave `sk_test_...` y del secreto generado por Stripe CLI. No lo compartas por chat ni lo guardes en un archivo del repositorio.
5. En la sandbox, abre **Stripe Webhook Configs** (`/lightning/o/Stripe_Webhook_Config__c/list`), crea un registro con **Configuration Name** `Stripe_Test` y pega `whsec_...` en **Signing Secret**. Es un campo de texto cifrado en un objeto privado; sólo administradores deben poder administrar estos registros. El antiguo Custom Label `Stripe_Webhook_Secret` ya no se usa.
6. El sitio `Stripe_Webhook` con prefijo `/webhook` debe estar activo y su perfil Guest debe tener acceso Apex a `StripeWebhookController`. No concedas al Guest permisos CRUD/FLS sobre `Donation__c` ni `Stripe_Webhook_Config__c`.

El controlador comprueba la firma HMAC-SHA256 del cuerpo original con tolerancia de cinco minutos. Antes de actualizar una donación, también coteja el ID de sesión, referencia, modo de pago, moneda MXN, entorno Test, importe y estado pagado/expirado. Los reintentos de un evento ya procesado devuelven éxito sin actualizar por segunda vez ni reenviar el comprobante.

## Prueba de extremo a extremo

1. Abre el sitio en incógnito, inicia un donativo pequeño y comprueba que abre Stripe Test Checkout.
2. Completa el pago con la tarjeta de prueba `4242 4242 4242 4242`, fecha futura y cualquier CVC.
3. En Stripe **Workbench → Webhooks → Event deliveries**, comprueba una entrega `checkout.session.completed` con HTTP 200.
4. En Salesforce comprueba que la donación correspondiente cambia de `Pending` a `Paid`, que el avance aumenta sólo por su importe y que el Wall of Fame respeta el consentimiento.
5. Reenvía ese mismo evento desde Stripe: no debe duplicar monto ni correo. Una firma incorrecta debe responder HTTP 400 y registrar `Rejected_Signature` sin alterar la donación.

Abrir la URL del webhook en el navegador devuelve HTTP 405 porque sólo acepta POST. Un evento genérico de prueba puede devolver 400 si no contiene una sesión y referencia existentes en esta org; usa una sesión creada por el portal para la prueba final.

Fuentes: [Stripe Webhooks](https://docs.stripe.com/webhooks), [Stripe Checkout Session](https://docs.stripe.com/api/checkout/sessions/object), [Salesforce: secretos fuera de paquetes administrados](https://developer.salesforce.com/docs/platform/apex-dev/references/apex-dev/apex-customsettings.html).
