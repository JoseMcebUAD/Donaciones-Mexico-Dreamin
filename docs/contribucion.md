# Contribución del Equipo

**Proyecto:** Portal de Donaciones — Mexico Dreamin  
**Equipo:** SF Vibe Lab (UADY)  
**Entrega 1:** 10 nov 2026 · **Entrega 2:** 17–18 nov 2026  
**Documentos relacionados:** [Backlog](backlog.md) · [Modelo de Datos y ER](modelo_datos_er.md) · [Seguridad](seguridad.md) · [Bitácora de IA](bitacora_ia.md)

---

## Integrantes

| Nombre | GitHub | Rol |
| :--- | :--- | :--- |
| José Ceballos | `JoseMcebUAD` | Backend Developer & Salesforce Admin |
| José Díaz | `Josediaz3008` | Frontend Developer & Security Engineer |
| Jesús Méndez | `Jsvela749` | Consultor de Negocio, Docs & QA Lead |

---

## Entrega 1 (E1 · 10 nov 2026)

### José Ceballos — Backend Developer & Admin
**Historias implementadas:** US-D1, US-D2, US-D3, US-F1, US-S1, US-S2, US-S3

- Creó los objetos `Campaign__c` y `Donation__c` con campos CFDI 4.0
- Lógica de donantes anónimos desacoplada de la solicitud de factura
- Validaciones fiscales (RFC, régimen fiscal) y reglas de campaña (capacidad, expiración, redirección)
- Batch programado que expira automáticamente las donaciones pendientes abandonadas
- Comprobante de pago con desglose fiscal y contacto de soporte
- **Evidencia (commits E1):** `76f4d1f`, `31d202e`, `493ee06`, `faf0932`, `ec44101`, `4b67804`, `1b3bff5`, `0ce235d`, `050a0c2`, `b2d07c1`, `5a6a4e9` (merges `da5ce7d`, `b874c6c`, `997305d`) · Entrada 02 de `docs/bitacora_ia.md`

---

### José Díaz — Frontend & Security Engineer
**Historias implementadas:** US-D1, US-D4, US-C1, US-V2

- Construyó los componentes LWC del portal (catálogo, formulario, agradecimiento, muro de reconocimiento)
- Configuró los permisos mínimos del Guest User y la sharing rule de campañas activas
- Implementó las rutas de retorno desde Stripe sin exponer datos en URL
- Muro de reconocimiento con donantes con consentimiento y conteo agregado de anónimos
- Pruebas unitarias de Apex (6 pruebas dirigidas aprobadas con 92 % de cobertura en E1; suite ampliada en E2 a 8 clases `*Test.cls` + `DonationTestDataFactory.cls`)
- **Evidencia (commits E1):** `169f6dc`, `a59c471`, `e826296`, `9fbf202`, `5c9e9b1`, `e749372`, `b178f0c`, `d3c1e80`, `3d6c5e3`, `111ff55`, `9ed1781`, `c56bc09`, `ac10110` · Video demo E1 (`https://youtu.be/_o0NqD-dlAc`)

---

### Jesús Méndez — Consultor de Negocio & QA Lead
**Contribución:** análisis de negocio, QA y documentación del proyecto

- Redactó las 10 historias de usuario con criterios Gherkin/INVEST y casos negativos
- Registró los acuerdos con el cliente (sesiones 3 y 6 de noviembre) y refinó el backlog con Q&A
- Documentó el uso de IA en `docs/bitacora_ia.md` (Entrada 01)
- Actualizó `docs/seguridad.md` y este documento de contribución
- **Evidencia (commits E1):** `a9f20df`, `5efe85d`, `7ed3c00` · Entrada 01 de `docs/bitacora_ia.md`

---

## Entrega 2 (E2 · 17–18 nov 2026) — Avance y Planificación

| Integrante | Historias / Alcance | Tareas / Avance | Evidencia (commits / PRs / bitácora) |
| :--- | :--- | :--- | :--- |
| **José Ceballos** (`JoseMcebUAD`) | **Implementado:** `US-S5`, `US-D1c`, `US-R1`, `US-R2`, `US-UX1`, `US-UX2`, `issue-45`<br>**Pendiente / Planificado:** `US-D5`, `US-S4` | **Implementado en E2:**<br>• `US-S5`: carga y visualización de portada de campaña (`CampaignImageService`, `campaignImageUpload`, `Cover_Image_URL__c`).<br>• `feat/US-D1` (`US-D1c` y refactor UI): reubicación del botón `Apoyar esta causa`, componente `campaignShare`, deep-link `?campaign=<id>` y tests Jest.<br>• `refactor/post-feedback` (`US-R1`, `US-R2`): eliminación de `Recognition_Type__c` del formulario/muro y carga directa de imagen `<= 2 MB` (`ContentVersion` + `ContentDistribution`).<br>• `US-UX1`, `US-UX2`, `issue-45`: sección FAQ con navegación `HOME`/`FAQ` (`faqSection`), formulario **Contáctanos** (`ContactController`, `ContactCommandService`, `Case.assignmentRules`), checkbox/aviso LFPDPPP (`Privacy_Accepted__c`), fixes de compatibilidad en sandbox (`f9a3282`), guías/scripts (`5920f4f`) y presentación E2.<br>**Pendiente / Planificado:** Endpoint REST Apex para webhook Stripe · Idempotencia con `Stripe_Event_Id__c` · Auditoría de avisos rechazados. | `d67bf7e`, `9d2b047` (PR `#38` `8fe6427`), `37dcad3`, `771a3d0`, `0d74a21`, `12ee8cd`, `f8d766e`, `8977d67`, `300f806`, `7d55eb2`, `b814314`, `f9a3282`, `5920f4f`, `457300b` |
| **Jesús Méndez** (`Jsvela749`) | **Implementado:** `US-D1b`, QA, bugfixes, validación/despliegue sandbox y documentación E2 (`US-D1`–`US-V2` cierre E1) | **Implementado en E2:**<br>• Cierre documental de E1 (`backlog.md`, `README.md`) y diagnóstico del portal público.<br>• `US-D1b`: restricción de monto mínimo Stripe (`$10.00 MXN`) en `donationForm`, `PublicDonationController` y pruebas Apex/Jest.<br>• Validación de despliegue en sandbox `mi-org` y estabilización de pruebas (`DonationTestDataFactory`, `System.runAs` en tests Apex y actualización de selectores Jest).<br>• QA y reporte [`docs/qa-us-d1.md`](qa-us-d1.md), bugfixes de `scrollIntoView` en JSDOM / ESLint (`US-D1c`), corrección de `ContentDistribution` / SOQL / selector Jest (`US-R2`, `US-S5`), reparación post-merge de `campaignCatalog.html` / `donationForm.js`, corrección de `PublicCampaignControllerTest` / `ContactController`, persistencia de `Privacy_Accepted__c` (`issue-45`) y despliegue verificado `0Afbm00000ofchGCAQ` (`49/49` Apex tests, `85.25%` cobertura).<br>• Revisión y merge de PRs `#46` y `#49`, auditoría documental (`backlog.md`, `seguridad.md`, `contribucion.md`), creación de [`docs/modelo_datos_er.md`](modelo_datos_er.md) y registro en `docs/bitacora_ia.md`. | `ef7bcac`, `3689be9`, `a35a447`, `288e923`, `92128a4`, `4233c8c`, `36c12d5`, `9d4fe27`, `8700165`, `b0da3ea`, `3954c48`, `3e1fd12` (PR `#49`), `19c2f32` (PR `#46`) · Entradas 03–14 de `docs/bitacora_ia.md` |
| **José Díaz** (`Josediaz3008`) | **Implementado (E2):** Soporte multimedia/repo<br>**Pendiente / Planificado:** `US-V3` | **Implementado en E2:** Publicación de video de presentación en GitHub Pages y mantenimiento de rama `entrega-2`.<br>**Pendiente / Planificado:** Verificación HMAC SHA-256 de `Stripe-Signature` · Resguardo de secretos de webhook · Pruebas en org. | `47432f8`, `d8b4c79`, `6de473e`, `0baca2e` *(US-V3: Pendiente)* |
