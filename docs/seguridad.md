# Seguridad, Stripe y Experience Cloud

## Configuración manual en la org

1. Habilita My Domain y Digital Experiences y publica el sitio Experience Cloud.
2. Coloca `campaignCatalog` en la página pública y `donationThankYou` en `/donaciones/thank-you`. El Wall of Fame se presenta dentro de cada campaña; no agregues un componente de muro separado.
3. Configura la External Credential y Named Credential `Stripe_Test` hacia `https://api.stripe.com`. Guarda `sk_test_...` sólo en la credencial protegida de la org.
4. Asigna el principal `Stripe_Test_External-Stripe_Org_Principal` mediante `Donation Public Guest` al Guest User del sitio y al usuario interno que realizará pruebas. No guardes ni muestres el secreto.
5. Define `Donation_Portal_Base_URL` con la URL pública sin barra final. En esta org: `https://empathetic-narwhal-9eroye-dev-ed.trailblaze.my.site.com/donaciones`.
6. No concedas al Guest User permisos directos de objeto sobre `Campaign__c`, `Donor_Recognition__c` o `Donation__c`. Autoriza sólo `PublicCampaignController` y `PublicDonationController`.
7. `PublicCampaignController` expone únicamente campañas activas, meta, monto agregado, contador anónimo y reconocimientos consentidos. Nunca consulta `Donation__c`.
8. `PublicDonationController` crea la donación controlada como `Pending`; Stripe recibe retornos construidos por el servidor, no URLs enviadas por el navegador.

## Patrón Apex público

Las clases `@AuraEnabled` públicas usan `with sharing`. Las lecturas y escrituras que requieren una proyección controlada se realizan en servicios internos de propósito único con `without sharing` y consultas/DML explícitos en `SYSTEM_MODE`. Esto es necesario porque las clases API 67 aplican CRUD/FLS del usuario por defecto; el Guest no recibe permisos CRM directos. Los servicios seleccionan sólo campos permitidos y nunca devuelven `Donation__c`.

## Prueba en incógnito

1. Abre `https://empathetic-narwhal-9eroye-dev-ed.trailblaze.my.site.com/donaciones/` en una ventana incógnito nueva.
2. Comprueba que aparecen sólo campañas activas, la meta, el total recaudado, los reconocimientos públicos y el contador anónimo.
3. Confirma en DevTools que `getActiveCampaigns` ya no devuelve HTTP 400 y que la respuesta no contiene RFC, correos, facturas ni registros `Donation__c`.
4. Inicia una donación de prueba. Stripe Test debe abrir y el retorno debe ser `/donaciones/thank-you?session_id=...`.
5. El retorno no confirma pago automáticamente: el registro queda `Pending` hasta la acción interna de Tesorería.
6. Como visitante, intenta acceder a un registro `Donation__c`: debe ser denegado y nunca debe existir un enlace público hacia él.

## Evidencias

Captura catálogo público, Checkout Test, retorno seguro, Wall of Fame, vistas internas y una prueba en incógnito. Nunca captures claves, RFC reales, correos reales ni URLs de sesiones Stripe.
