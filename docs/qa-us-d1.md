# Plan y Reporte de QA — Rama `feat/US-D1` (`US-D1c` + Regresión `US-D1`)

**Fecha de ejecución:** 17 de noviembre de 2026  
**Rama evaluada:** `origin/feat/US-D1` (commits `37dcad3`, `771a3d0`, `0d74a21`, `12ee8cd` sobre `entrega-2` `8fe6427`)  
**Alcance:**
- **Nuevo (`US-D1c`):** Componente `c-campaign-share` (popup de compartir + copiar enlace + redes sociales/correo), integración en `c-campaign-catalog`, reubicación de botones en la parte superior de `.card-body` y auto-selección por `?campaign=<id>`.
- **Regresión (`US-D1`):** Criterios base de visualización pública de campañas, cálculo Pagada vs Pendiente, flujo de donación, salto de campaña única y bloqueo por vencimiento/meta alcanzada.

---

## Fase 1: Pruebas Automatizadas Locales (Ejecutadas)

Ejecutado desde `salesforce/`:

| # | Verificación | Comando | Resultado | Detalle Observado |
|---|---|---|---|---|
| A1 | Pruebas unitarias focalizadas (`c-campaign-share`) | `npx sfdx-lwc-jest -- --verbose campaignShare` | **PASS** | `1/1` suite, `10/10` tests en verde (`1.383 s`). |
| A2 | Pruebas unitarias LWC (suite completa) | `npm run test:unit` | **FAIL** | Exit code `1`. `campaignShare.test.js` pasa, pero `campaignCatalog.test.js` lanza rechazo no controlado `TypeError: anchor.scrollIntoView is not a function` en `campaignCatalog.js:68:16` (JSDOM no implementa `scrollIntoView`). |
| A3 | Linter ESLint LWC | `npm run lint` | **FAIL** | Exit code `1` (`3` errores, `1` warning):<br>- `campaignCatalog.js:19:18` error `no-unused-vars` (`'_'`)<br>- `campaignCatalog.js:52:9` warning directiva `eslint-disable` sin uso<br>- `campaignShare.js:88:27` error `@lwc/lwc/no-async-operation` (`setTimeout`)<br>- `campaignShare.js:106:18` error `no-unused-vars` (`'_'`) |
| A4 | Formato Prettier | `npm run prettier:verify` | **FAIL** | Exit code `1`. `118` archivos con diferencias de formato en el repositorio, incluidos los archivos nuevos/modificados de `US-D1c`. |

### Hallazgos Técnicos de Fase 1 (Accionables antes de Merge)
1. **[Bloqueante CI] `campaignCatalog.js:68`:** En `_scrollToDonationForm()`, proteger la llamada con `if (typeof anchor.scrollIntoView === 'function')` (o mockear `Element.prototype.scrollIntoView` en `campaignCatalog.test.js`) para que `npm run test:unit` no falle en JSDOM.
2. **[Bloqueante CI] ESLint (`npm run lint`):** Resolver los 3 errores (`catch` sin parámetro o variable usada, y manejo/directiva de `setTimeout` en `campaignShare.js:88`) y eliminar la directiva `eslint-disable` sobrante en `campaignCatalog.js:52`.
3. **[Observación UX/A11y]:** `campaignShare` declara `role="dialog"` y `aria-modal="true"`, pero no implementa cierre con la tecla `Escape`.

---

## Fase 2: Pruebas Manuales Funcionales — `US-D1c` (Experience Cloud / Sitio Público)

> Ejecutar en la org de Salesforce como **visitante anónimo (Guest User)** sin iniciar sesión.

### 2.1 Botón y Popup de Compartir (`c-campaign-share`)

| ID | Caso de Prueba | Pasos | Resultado Esperado | Estado |
|---|---|---|---|---|
| QA-01 | Visibilidad del botón en campaña activa | Abrir el portal público con al menos 1 campaña activa no bloqueada. | Se muestran `Apoyar esta causa →` y `Compartir ↗` en la parte superior de `.card-body`, antes de montos y muro de donantes. | `[ ] Pendiente` |
| QA-02 | Ocultamiento en campaña bloqueada | Configurar una campaña vencida o al 100% (`isDonationBlocked = true`). | Se muestra el mensaje `blockedReason`; NO se renderizan `Apoyar esta causa` ni `Compartir ↗`. | `[ ] Pendiente` |
| QA-03 | Apertura del popup | Hacer clic en `Compartir ↗` de una campaña activa. | Se abre el modal centrado sobre un backdrop oscuro (`z-index: 9999`), mostrando el nombre de la campaña y la URL `<origin><pathname>?campaign=<id>`. | `[ ] Pendiente` |
| QA-04 | Cierre con botón `×` y backdrop | Abrir popup, cerrar con `×`. Reabrir y hacer clic en el fondo oscuro (`.share-backdrop`) y luego dentro del panel (`.share-popup`). | Cierra con `×` y con clic en `.share-backdrop`; permanece abierto al hacer clic dentro de `.share-popup`. | `[ ] Pendiente` |
| QA-05 | Copiar enlace al portapapeles | Abrir popup y pulsar `Copiar enlace`. | El botón cambia a `¡Copiado!` por ~2.5s y regresa a `Copiar enlace`. Al pegar en otra pestaña, la URL coincide exactamente con `?campaign=<id>`. | `[ ] Pendiente` |
| QA-06 | Enlaces de redes sociales y correo | Inspeccionar/abrir Facebook, WhatsApp, X, LinkedIn y Email. | Los 4 enlaces sociales abren en nueva pestaña (`target="_blank"`, `rel="noopener noreferrer"`) con URL codificada y nombre de campaña (WhatsApp/X). Email abre `mailto:` con asunto y cuerpo correctos. | `[ ] Pendiente` |

### 2.2 Auto-selección por URL (`?campaign=<id>`)

| ID | Caso de Prueba | Pasos | Resultado Esperado | Estado |
|---|---|---|---|---|
| QA-07 | Deep-link a campaña activa válida | Navegar a `<url_portal>?campaign=<id_campaña_2>` (existiendo 2+ campañas activas). | La campaña 2 se auto-selecciona, se despliega `c-donation-form` con esa campaña y la página hace scroll suave hacia `.donation-anchor`. | `[ ] Pendiente` |
| QA-08 | Deep-link a campaña bloqueada | Navegar a `<url_portal>?campaign=<id_bloqueada>`. | NO se auto-selecciona ni se abre `c-donation-form`; el catálogo permanece visible. | `[ ] Pendiente` |
| QA-09 | Deep-link con ID inexistente | Navegar a `<url_portal>?campaign=id_invalido_123`. | Sin errores en consola. Con 2+ campañas muestra el catálogo normal; con exactamente 1 campaña activa no bloqueada aplica la regla de campaña única. | `[ ] Pendiente` |
| QA-10 | Caracteres especiales en nombre | Probar compartir una campaña con acentos, `&` o espacios (ej. `Becas Ingeniería & Ciencia`). | Los enlaces de WhatsApp, X, Facebook, LinkedIn y Email codifican correctamente los caracteres sin truncar ni romper la URL. | `[ ] Pendiente` |

---

## Fase 3: Regresión de `US-D1` (Criterios Base del Backlog)

| ID | Criterio (`US-D1`) | Validación | Estado |
|---|---|---|---|
| REG-01 | CA1 — Catálogo sin login | Visitante anónimo visualiza campañas activas con nombre, meta y avance recaudado. | `[ ] Pendiente` |
| REG-02 | CA2 — Cálculo Pagada vs Pendiente | Donaciones en estado `Pendiente` no suman al avance; solo `Pagada` incrementa `Raised_Amount__c`. | `[ ] Pendiente` |
| REG-03 | CA3 — Flujo de donación | Al pulsar `Apoyar esta causa →` se abre `c-donation-form` con montos sugeridos y monto libre (`>= $10.00 MXN`). | `[ ] Pendiente` |
| REG-04 | CA4 — Salto con campaña única | Con exactamente 1 campaña activa no bloqueada y sin `?campaign=`, se selecciona automáticamente. | `[ ] Pendiente` |
| REG-05 | CA5 — Campaña vencida/cerrada | Campaña vencida o al 100% sin fondos adicionales bloquea el formulario y muestra razón. | `[ ] Pendiente` |

---

## Fase 4: UI, Responsividad y Navegadores (Manual)

| ID | Aspecto | Validación | Estado |
|---|---|---|---|
| UI-01 | Móvil (`<= 520px`) | `.share-popup` (`width: calc(100vw - 2rem)`) no desborda horizontalmente; la URL larga se trunca con `text-overflow: ellipsis` y `.share-social-row` hace `flex-wrap`. | `[ ] Pendiente` |
| UI-02 | Desktop | El popup escapa `overflow: hidden` de `.campaign-card` mediante `position: fixed` y cubre toda la pantalla. | `[ ] Pendiente` |
| UI-03 | Teclado / Accesibilidad | Tabulación por botones del popup y verificación de si se requiere cierre con tecla `Escape`. | `[ ] Pendiente` |
