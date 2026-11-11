# Portal de Donaciones Mexico Dreamin

Entrega 1 del portal público de donaciones para Mexico Dreamin. Permite consultar campañas activas, iniciar un donativo con Stripe Test Checkout y reconocer donantes pagados con consentimiento. La operación interna se realiza desde Salesforce.

## Alcance de Entrega 1

Se implementan US-01 a US-10: catálogo público, donativo anónimo o con reconocimiento, factura/RFC, intención `Pending`, Stripe Test Checkout, página de agradecimiento segura, muro de reconocimiento, gestión de campañas, revisión de donativos y confirmación manual de pago. US-11 a US-14 quedan para Entrega 2.

## Estructura

```text
salesforce/                         Proyecto Salesforce DX
  force-app/main/default/
    classes/                         Apex y pruebas con HttpCalloutMock
    lwc/                             Componentes públicos y acción de Tesorería
    objects/                         Campaign__c y Donation__c
    permissionsets/                  Permission Sets de operación
docs/
  backlog.md                         Historias de usuario
  seguridad.md                       Configuración manual y pruebas Guest User
  bitacora_ia.md                     Registro de IA
```

## Requisitos y ejecución

- Salesforce CLI, Node.js LTS, My Domain y Digital Experiences.
- Org autorizada localmente como `jDiaz`.
- Stripe Test con una Named Credential `Stripe_Test`; la clave secreta se guarda sólo en la org, jamás en Git.

```powershell
cd salesforce
sf org login web --alias jDiaz
npm install
npm run lint
npm test
sf project deploy validate --target-org jDiaz --source-dir force-app
sf project deploy start --target-org jDiaz --source-dir force-app
```

Tras el despliegue, sigue [docs/seguridad.md](docs/seguridad.md) para crear el sitio Experience Cloud, colocar `campaignCatalog`, `donorWall` y `donationThankYou`, y aplicar el mínimo privilegio de Guest User.

## Seguridad y pagos

Las interfaces públicas retornan sólo campañas activas y créditos autorizados; no aceptan IDs de donaciones para consultar o modificar datos de terceros. Un pago primero crea `Donation__c` como `Pending` y guarda la referencia de Salesforce en Stripe. La página de retorno no afirma pago confirmado. En E1 Tesorería confirma el pago una sola vez mediante **Confirm Payment**; webhook, firma e idempotencia quedan para E2.

## Pruebas

Apex cubre campañas activas/inactivas, suma de sólo pagadas, muro, RFC, anonimato/factura, creación pendiente mediante `HttpCalloutMock` y confirmación duplicada. Jest cubre catálogo, estado vacío y el cambio a anónimo. La validación/despliegue requiere sesión vigente de `jDiaz`; si el refresh token expiró, ejecuta el login anterior.
