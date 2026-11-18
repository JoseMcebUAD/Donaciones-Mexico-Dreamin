# Configuración segura de Stripe Test

## Flujo implementado

`StripeCheckoutService` crea una Checkout Session mediante `callout:Stripe_Test/v1/checkout/sessions`. La clave `sk_test_...` vive exclusivamente en la External Credential de Salesforce; nunca aparece en Apex, LWC, Git, evidencias ni chat.

Cada intento usa una referencia `MD-...` en `client_reference_id` y `metadata[salesforce_reference]`. Salesforce crea el registro como `Pending` sólo después de recibir una sesión válida de Stripe.

## Configuración

1. Configura `Stripe_Test` con URL `https://api.stripe.com` y la External Credential `Stripe_Test_External`.
2. Usa un principal de Named Principal con el encabezado Basic requerido por Stripe, construido desde el secreto almacenado en Salesforce.
3. Vincula manualmente en Setup el principal `Stripe_Test_External-Stripe_Org_Principal` al perfil/Guest User o Permission Set correspondiente para `callout:Stripe_Test` (retirado de `Donation_Public_Guest.permissionset-meta.xml` en E2 para permitir despliegues en sandboxes limpias).
4. Asigna `Donation Public Guest` al Guest User del sitio y al usuario interno que prueba Checkout. Este permission set no concede acceso directo a objetos de campaña, reconocimiento o donación (`0` CRUD/FLS; habilita únicamente `PublicCampaignController`, `PublicDonationController` y `ContactController`).
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

Sólo donaciones `Paid`, no anónimas y con consentimiento generan `Donor_Recognition__c` (proyectado por `DonationProjectionTrigger` / `DonationProjectionService`). El portal recibe únicamente nombre de reconocimiento, monto y URL pública generada internamente por `ContentDistribution` cuando el donante adjunta imagen (`<= 2 MB`, `US-R2`); nunca RFC, correo, datos fiscales ni identificadores de donación.

El Payment Link compartido de Stripe puede servir para comprobar la cuenta Test, pero no es el flujo principal porque no conserva el monto ni la referencia única por intento de Salesforce.
