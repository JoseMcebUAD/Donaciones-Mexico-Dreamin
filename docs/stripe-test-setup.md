# Configuración segura de Stripe Test

## Flujo implementado

`StripeCheckoutService` crea una Checkout Session mediante `callout:Stripe_Test/v1/checkout/sessions`. La clave `sk_test_...` vive exclusivamente en la External Credential de Salesforce; nunca aparece en Apex, LWC, Git, evidencias ni chat.

Cada intento usa una referencia `MD-...` en `client_reference_id` y `metadata[salesforce_reference]`. Salesforce crea el registro como `Pending` sólo después de recibir una sesión válida de Stripe.

## Configuración

1. Configura `Stripe_Test` con URL `https://api.stripe.com` y la External Credential `Stripe_Test_External`.
2. Usa un principal de Named Principal con el encabezado Basic requerido por Stripe, construido desde el secreto almacenado en Salesforce.
3. Asigna `Stripe_Test_External-Stripe_Org_Principal` en el permission set `Donation Public Guest`.
4. Asigna ese permission set al Guest User del sitio y al usuario interno que prueba Checkout. Este permission set no concede acceso directo a objetos de campaña, reconocimiento o donación.
5. Configura `Donation_Portal_Base_URL` a `https://empathetic-narwhal-9eroye-dev-ed.trailblaze.my.site.com/donaciones`.

El servidor, y no el navegador, genera estas rutas:

- Éxito: `/donaciones/thank-you?session_id={CHECKOUT_SESSION_ID}`
- Cancelación: `/donaciones/`

## Prueba esperada

1. El visitante elige campaña, monto y preferencias de reconocimiento.
2. Salesforce crea una Checkout Session Test y una donación `Pending`.
3. Stripe recibe el correo, el monto y la referencia de Salesforce, y muestra Checkout Test.
4. Stripe regresa a agradecimiento sin afirmar que el pago está confirmado.
5. Tesorería confirma el pago de forma controlada en E1.

## Wall of Fame

Sólo donaciones `Paid`, no anónimas y con consentimiento generan `Donor_Recognition__c`. El portal recibe únicamente nombre de reconocimiento, tipo, monto y URL HTTPS opcional de logo/foto; nunca RFC, correo, datos fiscales ni identificadores de donación.

El Payment Link compartido de Stripe puede servir para comprobar la cuenta Test, pero no es el flujo principal porque no conserva el monto ni la referencia única por intento de Salesforce.
