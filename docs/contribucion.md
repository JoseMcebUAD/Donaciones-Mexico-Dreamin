# Contribución del Equipo

**Proyecto:** Portal de Donaciones — Mexico Dreamin  
**Equipo:** SF Vibe Lab (UADY)  
**Entrega 1:** 10 nov 2026 · **Entrega 2:** 17 nov 2026

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
- Pruebas unitarias de Apex (6 clases, 92 % de cobertura)
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

## Entrega 2 (E2 · 17 nov 2026) — Avance y Planificación

| Integrante | Historias | Tareas / Avance | Evidencia (commits / bitácora) |
| :--- | :--- | :--- | :--- |
| **Jesús Méndez** | US-D1b, US-D1–US-V2 | Cierre documental de E1 (`backlog.md`, `README.md`), diagnóstico de catálogo público, gap analysis contra lineamientos de E2 e implementación de monto mínimo Stripe (`$10.00 MXN`) en LWC, Apex y tests | `ef7bcac`, `3689be9`, `a35a447` · Entradas 03–06 de `docs/bitacora_ia.md` |
| **José Ceballos** | US-D5, US-S4 | *(Planificado)* Endpoint REST Apex para webhook Stripe · Idempotencia con `Stripe_Event_Id__c` · Consola de auditoría de avisos rechazados | Pendiente |
| **José Díaz** | US-D1b, US-V3 | *(Planificado)* Verificación HMAC SHA-256 de `Stripe-Signature` · Resguardo de secretos en Named Credential · Pruebas en org | Pendiente |
