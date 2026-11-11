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

---

### José Díaz — Frontend & Security Engineer
**Historias implementadas:** US-D1, US-D4, US-C1, US-V2

- Construyó los componentes LWC del portal (catálogo, formulario, agradecimiento, muro de reconocimiento)
- Configuró los permisos mínimos del Guest User y la sharing rule de campañas activas
- Implementó las rutas de retorno desde Stripe sin exponer datos en URL
- Muro de reconocimiento con donantes con consentimiento y conteo agregado de anónimos
- Pruebas unitarias de Apex (6 clases, 92 % de cobertura)

---

### Jesús Méndez — Consultor de Negocio & QA Lead
**Contribución:** análisis de negocio y documentación del proyecto

- Redactó las 10 historias de usuario con criterios Gherkin/INVEST y casos negativos
- Registró los acuerdos con el cliente (sesiones 3 y 6 de noviembre) y refinó el backlog con Q&A
- Documentó el uso de IA en `docs/bitacora_ia.md`
- Actualizó `docs/seguridad.md` y este documento de contribución

---

## Entrega 2 (E2 · 17 nov 2026) — Planificación

| Integrante | Historias | Tareas planificadas |
| :--- | :--- | :--- |
| **José Ceballos** | US-D5, US-S4 | Endpoint REST Apex para webhook Stripe · Idempotencia con `Stripe_Event_Id__c` · Consola de auditoría de avisos rechazados |
| **José Díaz** | US-D1b, US-V3 | Validación de monto mínimo ($10 MXN) · Verificación HMAC SHA-256 de `Stripe-Signature` · Resguardo de secretos en Named Credential |
| **Jesús Méndez** | US-V3, US-S4 | Casos de prueba: webhook apócrifo y firma errónea · Actualización de `docs/seguridad.md` · Preparación de defensa oral |
