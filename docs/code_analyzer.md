# Reporte de Salesforce Code Analyzer y Justificación de Hallazgos (S14 / C6)

**Proyecto:** Portal de Donaciones para Mexico Dreamin  
**Programa:** SF Vibe Lab (UADY × Salesforce, Mérida)  
**Última actualización:** 18 de noviembre de 2026  
**Herramienta:** Salesforce CLI `code-analyzer@5.15.0` (`npm run code-analyzer` en `salesforce/`)  
**Comando ejecutado:** `sf code-analyzer run --workspace "salesforce/force-app" --rule-selector Recommended --view table`  
**Motores ejecutados:** `retire-js`, `regex`, `eslint`, `apexguru`, `cpd`, `pmd`, `sfge`, `flow`  
**Documentos relacionados:** [README](../README.md) · [Seguridad](seguridad.md) · [Bitácora de IA](bitacora_ia.md)

---

## 1. Resumen Ejecutivo (Antes vs. Después de Remediación)

| Severidad | Corrida Inicial | Corrida Post-Fix | Estado |
| :--- | :---: | :---: | :--- |
| **High (2)** | **10** | **0** | **100% atendidos y resueltos** (`ApexCRUDViolation`) |
| **Moderate (3)** | **26** | **25** | `1` resuelto (`UnusedLocalVariable`); `25` justificados por diseño |
| **Low (4)** | **361** | **361** | Justificados (estilo SLDS2 del portal público, convenciones de tests/docs) |
| **Total** | **397** | **386** | Verificado con `49/49` tests Apex (`0Afbm00000og5EdCAI`) y `17/17` Jest |

> **Aspecto clave:** Los motores `retire-js` (dependencias vulnerables), `regex` (patrones inseguros) y `cpd` (código duplicado) reportaron **0 hallazgos**.

---

## 2. Hallazgos Atendidos (Resueltos en Código y Permisos)

### 2.1 Seguridad CRUD/FLS — 10 hallazgos `High` (`pmd:ApexCRUDViolation`) → **0 restantes**

| Archivo | Hallazgos iniciales | Corrección aplicada | Verificación |
| :--- | :---: | :--- | :--- |
| `CampaignImageService.cls` (líneas 21, 39) | 2 (`insert dist`, `update campaign`) | Se agregó ejecución explícita en modo usuario (`insert as user dist;` y `update as user campaign;`), alineando toda la clase en `WITH USER_MODE`. | `CampaignImageServiceTest` (`3/3` PASS) |
| `DonationManagementService.cls` (líneas 6, 18) | 2 (`SELECT Donation__c`, `update donation`) | Se añadió `WITH USER_MODE` al SOQL y `update as user donation;`, y se completaron permisos de lectura de recibo/CFDI en `Donation_Treasury.permissionset-meta.xml` para que Tesorería pueda operar sin depender de `Donation_Coordination`. | `DonationManagementServiceTest` (`1/1` PASS) |
| `DonationProjectionService.cls` (líneas 11, 50, 82, 84, 87) | 6 (SOQL/DML sin modo explícito) | Se explicitó `WITH SYSTEM_MODE` en ambas consultas y `Database.update` / `Database.upsert` / `Database.delete` con `AccessLevel.SYSTEM_MODE`. Al ser invocado por `DonationProjectionTrigger` incluso desde transacciones del Guest User (0 CRUD/FLS), debe operar explícitamente en `SYSTEM_MODE`. | `DonationProjectionServiceTest` + `PublicDonationControllerTest` (PASS) |

### 2.2 Limpieza de Código — 1 hallazgo `Moderate` (`pmd:UnusedLocalVariable`) → **Resuelto**
* **`PublicDonationCommandServiceTest.cls` (línea 70):** Se eliminó la variable local `Donation__c donation` declarada y no utilizada tras verificar `ContentDocumentLink`.

---

## 3. Análisis y Justificación Técnica de Hallazgos Restantes

### 3.1 Hallazgos `Moderate` (25 restantes)

| Regla / Motor | Cantidad | Archivos | Análisis y Justificación |
| :--- | :---: | :--- | :--- |
| `pmd:MethodNamingConventions` | 7 | `CampaignImageServiceTest.cls` (3), `ContactControllerTest.cls` (4) | Los métodos siguen la convención estándar de pruebas unitarias `metodo_escenario` (ej. `testCreateCase_success`, `publishCoverImage_updatesCampaignUrl`), ampliamente usada en Apex para legibilidad de suites de QA. No afecta ejecución ni seguridad. |
| `eslint:@salesforce-ux/slds/lwc-token-to-slds-hook` | 5 | `faqSection.css` (líneas 23, 32, 52, 62, 85) | Usa tokens `--lwc-brandAccessible`, `--lwc-colorBorderSeparator` y `--lwc-colorBackgroundAlt` con valores fallback estándar para mantener compatibilidad visual en Experience Cloud Aura/LWR sin romper temas existentes. Se puede migrar a `--slds-g-color-*` en un refactor visual futuro. |
| `pmd:CyclomaticComplexity` / `pmd:CognitiveComplexity` / `pmd:NcssCount` | 7 (4+2+1) | `PublicDonationController.cls` (1 clase + `validate`), `DonationProjectionService.cls` (`synchronize`), `PublicDonationCommandService.cls` (`createPendingDonation`) | Responden a reglas de negocio reales concentradas en un solo punto de validación/sincronización:<br>• `validate(DonationRequest)` valida campaña, monto mínimo (`$10 MXN`), correo, anonimato, reconocimiento, 5 campos CFDI 4.0 + regex SAT y privacidad.<br>• `synchronize(Set<Id>)` agrega montos pagados, conteo anónimo y sincroniza `Donor_Recognition__c` de forma bulkificada (sin SOQL/DML en bucles). |
| `pmd:ExcessiveParameterList` | 2 | `PublicDonationCommandService.createPendingDonation` (4 params), `StripeCheckoutService.createSession` (5 params) | Métodos de servicio internos de propósito único; en `createPendingDonation` los campos principales ya vienen encapsulados en el DTO `DonationRequest`. Refactorizable a objeto de parámetros si crece el webhook de E2. |
| `pmd:TooManyFields` | 1 | `PublicDonationController.DonationRequest` | DTO de entrada `@AuraEnabled` que encapsula en una sola llamada de red todos los campos del formulario público (monto, donante, anonimato, reconocimiento + imagen Base64, CFDI 4.0 y privacidad). Dividirlo complicaría la firma pública sin beneficio técnico. |
| `pmd:AvoidLogicInTrigger` | 1 | `DonationProjectionTrigger.trigger` | El trigger únicamente recopila los `Campaign__c` de `Trigger.new`/`Trigger.old` y delega toda la lógica a `DonationProjectionService.synchronize(campaignIds)`. Es el patrón mínimo recomendado sin handler framework externo. |
| `pmd:EmptyStatementBlock` | 1 | `DonationExpirationService.cls` (línea 25) | Método `finish(Database.BatchableContext ctx) {}` exigido obligatoriamente por la interfaz `Database.Batchable<SObject>` de Apex. |
| `eslint:@lwc/lwc-platform/no-inline-disable` | 1 | `campaignShare.js` (línea 88) | Directiva `// eslint-disable-next-line @lwc/lwc/no-async-operation` necesaria para que `npm run lint` permita `setTimeout` en el feedback temporal `"¡Copiado!"` (`2.5s`). El temporizador se limpia de forma segura con `clearTimeout` en `closePopup()` y `disconnectedCallback()`. |

### 3.2 Hallazgos `Low` (361 restantes)

| Regla / Motor | Cantidad | Análisis y Justificación |
| :--- | :---: | :--- |
| `eslint:@salesforce-ux/slds/no-hardcoded-values-slds2` | 307 | CSS personalizado del portal público (`campaignCatalog.css`, `campaignShare.css`, `donationForm.css`, `donorWall.css`, `faqSection.css`) con identidad visual propia de Mexico Dreamin (colores, espaciados y radios fijos). Es un portal público de marca propia, no una pantalla interna estándar de Lightning Experience. |
| `eslint:@salesforce-ux/slds/no-slds-namespace-for-custom-hooks` | 1 | `campaignCatalog.css:28` usa `--slds-c-progress-bar-color-background-fill` para estilizar `lightning-progress-bar` con el hook de componente SLDS documentado. |
| `pmd:ApexDoc` | 36 | Comentarios Javadoc `/** ... */` omitidos en métodos/clases cortas de propósito evidente; el código cuenta con comentarios explicativos de arquitectura en límites públicos/privilegiados. |
| `pmd:ApexUnitTestClassShouldHaveRunAs` | 13 | Métodos de prueba unitaria en servicios internos (`CampaignImageServiceTest`, `ContactControllerTest`, `DonationProjectionServiceTest`, `PublicDonationCommandServiceTest`) y escenarios negativos sin usuario dedicado. Las pruebas críticas de permisos y flujo completo sí emplean `DonationTestDataFactory.createTestUser()` con `System.runAs(testUser)`. |
| `pmd:AnnotationsNamingConventions` | 4 | Uso de `@IsTest` (PascalCase) aceptado por el compilador Apex en lugar de `@isTest`. |

---

## 4. Punto de Vista de Ingeniería y Verificación Final

* **Valor real obtenido:** Code Analyzer permitió detectar y corregir **4 vulnerabilidades reales de cumplimiento CRUD/FLS en contexto `with sharing`** (`CampaignImageService` y `DonationManagementService`, incluyendo una brecha de FLS faltante en `Donation_Treasury` para leer campos fiscales/correo al emitir el comprobante) y **6 operaciones en `DonationProjectionService`** que debían declararse explícitamente en `SYSTEM_MODE` por arquitectura de Guest User.
* **Cierre verificado en `mi-org` tras los ajustes:**
  * `npm run code-analyzer` (`salesforce/`): **`0` High**, `25` Moderate, `361` Low (`386` total).
  * `npm run lint` (`salesforce/`): **PASS** (`0` errores).
  * `npm run test:unit` (`salesforce/`): **PASS** (`3/3` suites, `17/17` tests en `20.268 s`).
  * `sf project deploy start --test-level RunLocalTests --target-org mi-org --source-dir force-app` (Deploy ID `0Afbm00000og5EdCAI`): **Succeeded** — `78/78` componentes desplegados, **`49/49` pruebas Apex aprobadas** (`0` fallos, `32540 ms`).
