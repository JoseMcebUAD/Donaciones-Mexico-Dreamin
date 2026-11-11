# Portal de Donaciones Mexico Dreamin

## Entregables E1

### (1) Sitio público

> **TODO: pegar URL del sitio Experience Cloud**

### (2) Video demo

> **TODO: pegar enlace al video demo (5 min)**

### (3) Tablero de backlog

[Tablero del proyecto](https://github.com/users/JoseMcebUAD/projects/8) | [Backlog completo](docs/backlog.md)

<!-- BACKLOG-START -->
[Tablero E1](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues?q=is%3Aissue+label%3AE1) | [Tablero E2](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues?q=is%3Aissue+label%3AE2)

| Entrega | Total | Cumplidas | Avance |
|---------|-------|-----------|--------|
| E1 | 10 | 10 | 100% (10/10) |
| E2 | 4 | 0 | 0% (0/4) |
| **Total** | **14** | **10** | **71%** |

> Calculo: issues cerradas en GitHub / total de issues x 100.

| ID | Historia | Entrega | Estado |
|----|----------|---------|--------|
| [US-D1](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/20) | Visualizacion publica de campanas y progreso financiero | E1 | Implementada |
| [US-D2](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/21) | Donacion en modalidad Anonima | E1 | Implementada |
| [US-D3](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/22) | Registro previo de donacion y control de expiracion | E1 | Implementada |
| [US-D4](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/23) | Retorno y pagina de agradecimiento con contacto de soporte | E1 | Implementada |
| [US-C1](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/24) | Reconocimiento publico de aportaciones en campana | E1 | Implementada |
| [US-F1](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/25) | Captura de datos fiscales CFDI 4.0 y visibilidad | E1 | Implementada |
| [US-S1](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/26) | Gestion interna de campanas y control al 100% de la meta | E1 | Implementada |
| [US-S2](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/27) | Consola de monitoreo y filtro de solicitudes de factura | E1 | Implementada |
| [US-S3](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/28) | Confirmacion manual de pago y envio de comprobante | E1 | Implementada |
| [US-V2](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/29) | Auditoria y prueba de seguridad para Guest User | E1 | Implementada |
| [US-D1b](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/30) | Donacion de monto libre personalizado | E2 | Pendiente |
| [US-D5](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/31) | Confirmacion y comprobante automaticos via webhook | E2 | Pendiente |
| [US-V3](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/32) | Validacion de autenticidad e idempotencia del Webhook | E2 | Pendiente |
| [US-S4](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/33) | Auditoria de confirmaciones automaticas y log de avisos descartados | E2 | Pendiente |

<!-- BACKLOG-END -->

### (4) Seguridad y datos personales

- [Seguridad, Stripe y Experience Cloud](docs/seguridad.md)
- Datos personales: **TODO: pegar enlace o crear `docs/datos-personales.md`**

### (5) Metadata respaldada

Toda la metadata desplegada en la org está versionada en [`salesforce/force-app/`](salesforce/force-app/). Para reproducir el estado de la org:

```powershell
cd salesforce
sf project deploy start --target-org jDiaz --source-dir force-app
```

### (6) Bitácoras y registros

- [Bitácora de IA](docs/bitacora_ia.md)
- [Bitácora de contribución](docs/contribucion.md)
- Registro de preguntas y reportes: **TODO: pegar enlace o crear `docs/registro_preguntas.md`**

---

Portal público de donaciones para Mexico Dreamin. Permite consultar campañas activas, iniciar un donativo con Stripe Test Checkout y reconocer donantes pagados con consentimiento. La operación interna se realiza desde Salesforce.

## Alcance

**Entrega 1** — issues [#20](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/20)–[#29](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/29):

| Issue | Historia |
| :---: | :--- |
| [#20](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/20) | US-D1 — Visualización pública de campañas y progreso financiero |
| [#21](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/21) | US-D2 — Donación en modalidad anónima |
| [#22](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/22) | US-D3 — Registro previo de donación y control de expiración |
| [#23](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/23) | US-D4 — Retorno y página de agradecimiento con contacto de soporte |
| [#24](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/24) | US-C1 — Reconocimiento público de aportaciones en campaña |
| [#25](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/25) | US-F1 — Captura de datos fiscales CFDI 4.0 y visibilidad |
| [#26](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/26) | US-S1 — Gestión interna de campañas y control al 100% de la meta |
| [#27](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/27) | US-S2 — Consola de monitoreo y filtro de solicitudes de factura |
| [#28](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/28) | US-S3 — Confirmación manual de pago y envío de comprobante |
| [#29](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/29) | US-V2 — Auditoría y prueba de seguridad para Guest User |

**Entrega 2** — issues [#30](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/30)–[#33](https://github.com/JoseMcebUAD/Donaciones-Mexico-Dreamin/issues/33): monto libre, confirmación automática vía webhook, validación de firma e idempotencia, auditoría de eventos rechazados.

## Estructura

```text
salesforce/
  force-app/main/default/
    classes/
      PublicCampaignController       Campañas activas para el sitio público
      PublicDonationController       Creación de donaciones y sesión Stripe
      DonationManagementService      Confirmación de pago, comprobante, muro
      DonationExpirationService      Batch que expira donaciones abandonadas
      StripeCheckoutService          Callout a Stripe Test Checkout API
      *Test.cls                      Pruebas Apex (6/6 aprobadas, 92% cobertura)
    lwc/
      campaignCatalog                Catálogo público con auto-redirect
      donationForm                   Formulario: anónimo, crédito, factura CFDI 4.0
      donationConfirmation           Acción de Tesorería — Confirm Payment
      donationThankYou               Página de agradecimiento segura
      donorWall                      Muro de reconocimiento público
    objects/
      Campaign__c                    Meta, fecha de expiración, donaciones adicionales
      Donation__c                    Estado, modalidad, campos fiscales RFC/CFDI 4.0
    permissionsets/
      Donation_Coordination          Acceso de coordinación
      Donation_Treasury              Acceso de tesorería
      Donation_Public_Guest          Mínimo privilegio para Guest User
    tabs/                            Tabs de Campaign__c y Donation__c
    sharingRules/                    Reglas de compartición de Campaign__c
docs/
  backlog.md                         Historias de usuario y criterios de aceptación
  seguridad.md                       Configuración Experience Cloud y pruebas Guest User
  e1-implementation-status.md        IDs de deploy y resultados de verificación
  bitacora_ia.md                     Bitácora de uso de IA
scripts/
  create_issues.ps1                  Crea los issues del backlog en GitHub
  update_backlog.ps1                 Actualiza subtareas y % de avance en README
```

## Requisitos y ejecución

- Salesforce CLI (`sf`), Node.js LTS.
- Org autorizada localmente: `sf org login web --alias jDiaz`.
- My Domain y Digital Experiences habilitados en la org.
- Named Credential `Stripe_Test` apuntando a `https://api.stripe.com` con la clave `sk_test_...` guardada solo en la org, nunca en Git.

```powershell
cd salesforce
npm install
npm run lint
npm test
sf project deploy start --target-org jDiaz --source-dir force-app
```

Tras el despliegue, sigue [docs/seguridad.md](docs/seguridad.md) para publicar el sitio Experience Cloud, colocar los LWC y aplicar el mínimo privilegio de Guest User.

## Pruebas

6/6 clases Apex aprobadas con 92% de cobertura global. Cubren: campañas activas/inactivas, suma solo de pagadas, muro con consentimiento, validación RFC, desacoplamiento anónimo/factura, registro pendiente con `HttpCalloutMock`, expiración de donaciones abandonadas y bloqueo de confirmación duplicada. Jest cubre catálogo, estado vacío y cambio a anónimo. Ver IDs de verificación en [docs/e1-implementation-status.md](docs/e1-implementation-status.md).
