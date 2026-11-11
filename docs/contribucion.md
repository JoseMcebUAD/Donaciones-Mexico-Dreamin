# Bitácora de Contribución por Integrante

**Proyecto:** SF Vibe Lab — Portal de Donaciones para Mexico Dreamin  
**Equipo:** Consultoría e Implementación SF Vibe Lab  
**Hitos:** Entrega 1 (E1 - 10 nov 2026) / Entrega 2 (E2 - 17 nov 2026)  
**Archivo:** `docs/contribucion.md`

---

## 1. Roles del Equipo

* **José Ceballos (`JoseMcebUAD`): Backend Developer, Salesforce Admin & Release Manager**
  * Modelo de datos (CFDI 4.0, Picklists), reglas de validación, batch de expiración, lógica de campañas y gestión de releases.
* **José Díaz (`Josediaz3008`): Frontend Developer & Security Engineer**
  * Portal público en Experience Cloud, permisos mínimos de Guest User, rutas de retorno y pruebas unitarias en Apex.
* **Jesús Méndez (`Jsvela749`): Consultor de Negocio, Documentación & QA Lead**
  * Definición de requisitos, diseño del backlog (Gherkin/INVEST), registro de acuerdos con el cliente y bitácora de IA.

---

## 2. Contribución — Entrega 1 (Hito E1: 10 nov 2026)

| Integrante | Rol Principal | Historias | Tareas Realizadas | Evidencia (Commits / PRs) | Horas |
| :--- | :--- | :--- | :--- | :--- | :---: |
| **José Ceballos** (`JoseMcebUAD`) | Backend Developer & Admin | `US-D1`–`US-D3`, `US-F1`, `US-S1`–`US-S3` | • Modelo de datos y campos CFDI 4.0.<br>• Lógica de donantes anónimos y capacidad al 100%.<br>• Validación fiscal (`Invoice_Data_Required`).<br>• Batch programado de expiración de donaciones. | • `76f4d1f`, `31d202e`: *Structure*<br>• `493ee06`: *CFDI 4.0 fiscal fields*<br>• `faf0932`: *anonymous donor aggregate*<br>• `ec44101`: *campaign capacity/expiration*<br>• `4b67804`: *receipt breakdown*<br>• `1b3bff5`: *scheduled batch expiry*<br>• `050a0c2`: *fix picklist validation*<br>• PR #1, PR #16 | 19 h |
| **José Díaz** (`Josediaz3008`) | Frontend & Security Engineer | `US-D1`, `US-D4`, `US-C1`, `US-V2` | • Portal público en Experience Cloud / LWR.<br>• Permisos mínimos y sharing rules de Guest User.<br>• Rediseño responsivo y rutas post-pago.<br>• Pruebas unitarias de Apex (`DonationTest`). | • `169f6dc`: *implement donations portal*<br>• `e826296`: *redesign public experience*<br>• `9fbf202`: *minimal guest access*<br>• `5c9e9b1`: *return path fix*<br>• `e749372`: *campaign guest sharing*<br>• `3d6c5e3`: *align donation tests*<br>• `a59c471`, `b178f0c`, `d3c1e80` | 18 h |
| **Jesús Méndez** (`Jsvela749`) | Consultor de Negocio & QA Lead | `US-D1` a `US-S3`, `US-V2` | • Redacción de HU con criterios mínimos y casos negativos.<br>• Documentación en `docs/bitacora_ia.md`.<br>• Registro de acuerdos de negocio del 3 y 6 de nov. | • `a9f20df`: *backlog added with project HU's*<br>• `5efe85d`: *bitacora de ia anexada a la doc*<br>• PR #1 (`dev-Jsvela`) | 14 h |

---

## 3. Planificación — Entrega 2 (Hito E2: 17 nov 2026)

| Integrante | Rol E2 | Historias | Tareas Planificadas | Horas Est. |
| :--- | :--- | :--- | :--- | :---: |
| **Jesús Méndez** (`Jsvela749`) | QA Lead & Integration Tester | `US-V3`, `US-S4` | • Casos de prueba de webhook apócrifo y firma errónea.<br>• Actualización de `docs/seguridad.md`.<br>• Preparación y ensayo de defensa oral. | 15 h |
| **José Ceballos** (`JoseMcebUAD`) | Backend & Webhook Lead | `US-D5`, `US-S4` | • Endpoint REST Apex (`@RestResource`) para webhook.<br>• Idempotencia con `Stripe_Event_Id__c` único.<br>• Objeto y consola de auditoría de avisos rechazados. | 17 h |
| **José Díaz** (`Josediaz3008`) | Fullstack & Security Engineer | `US-D1b`, `US-V3` | • Validación frontend de monto mínimo Stripe ($10 MXN).<br>• Validación criptográfica `Stripe-Signature` (HMAC SHA-256).<br>• Resguardo de secretos en Custom Metadata/Named Credential. | 16 h |
