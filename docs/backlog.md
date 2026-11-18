# Product Backlog — Portal de Donaciones para Mexico Dreamin

**Programa:** SF Vibe Lab (UADY - Salesforce, Mérida)  
**Equipo:** Consultoría e Implementación SF Vibe Lab  
**Hitos del Proyecto:** Entrega 1 (E1: 10 de noviembre de 2026) y Entrega 2 (E2: 17–18 de noviembre de 2026)  
**Última actualización:** 18 de noviembre de 2026 (validación técnica de Entrega 2, alcance adicional post-feedback/UX/seguridad y enlace al modelo ER)  
**Artefactos relacionados:** [Modelo de Datos y ER](modelo_datos_er.md) · [Seguridad](seguridad.md) · [Contribución](contribucion.md) · [QA US-D1c](qa-us-d1.md)

---

## 1. Resumen y Estado de Avance

| Métrica (Backlog Base RF) | Entrega 1 (E1) | Entrega 2 (E2) |
| :--- | :---: | :---: |
| **Historias base comprometidas** | 10 | 14 (10 de E1 + 4 de E2) |
| **Historias base cumplidas** | 10 | 11 (10/10 E1 · 1/4 E2 base = 25%) |
| **% de Avance (Backlog Base RF)** | **100%** | **79%** |

> **Fórmulas de cálculo de avance:**
>
> $$\text{Avance E1} = \left(\frac{\text{Historias cumplidas E1}}{\text{Total historias E1 (10)}}\right) \times 100$$
>
> $$\text{Avance E2} = \left(\frac{\text{Historias cumplidas totales}}{\text{Total historias backlog (14)}}\right) \times 100$$
>
> *Nota:* Una historia cuenta como cumplida únicamente cuando se demuestran todos sus acceptance criteria con evidencia verificable (demo/video/capturas/pruebas) en modo de prueba sin violar los mínimos obligatorios M1-M3. Las métricas anteriores corresponden exclusivamente a las 14 historias base derivadas de los Requerimientos Funcionales (RF). Las mejoras e historias adicionales implementadas en Entrega 2 (post-feedback, UX y privacidad) se documentan por separado en la [Sección 3.1](#31-alcance-adicional-implementado-en-entrega-2-post-feedback-ux-y-seguridad).

---

## 2. Tablero de Historias de Usuario

| ID | RF Cubierto | Hito | Título / Rol | Estado | Evidencia |
| :--- | :--- | :---: | :--- | :---: | :--- |
| **US-D1** | RF-D1a, RF-V1 | E1 | Ver campañas y avance (Donante / Visitante) | Cumplida | [Video demo E1](https://youtu.be/_o0NqD-dlAc) · [Estado E1](e1-implementation-status.md) |
| **US-D2** | RF-D2, RF-D3, RF-D4 | E1 | Donar de forma anónima (Donante anónimo) | Cumplida | [Video demo E1](https://youtu.be/_o0NqD-dlAc) · [Estado E1](e1-implementation-status.md) |
| **US-D3** | RF-D3, RF-V1 | E1 | Registro previo y expiración (Donante) | Cumplida | [Video demo E1](https://youtu.be/_o0NqD-dlAc) · [Estado E1](e1-implementation-status.md) |
| **US-D4** | RF-D4 | E1 | Página de agradecimiento y soporte (Donante) | Cumplida | [Video demo E1](https://youtu.be/_o0NqD-dlAc) · [Estado E1](e1-implementation-status.md) |
| **US-C1** | RF-C1 | E1 | Reconocimiento público de aportaciones (Donante con crédito) | Cumplida | [Video demo E1](https://youtu.be/_o0NqD-dlAc) · [Estado E1](e1-implementation-status.md) |
| **US-F1** | RF-F1 | E1 | Datos fiscales CFDI 4.0 y visibilidad (Donante con factura) | Cumplida | [Video demo E1](https://youtu.be/_o0NqD-dlAc) · [Estado E1](e1-implementation-status.md) |
| **US-S1** | RF-S1 | E1 | Gestión de campañas y control al 100% (Staff Coordinación) | Cumplida | [Video demo E1](https://youtu.be/_o0NqD-dlAc) · [Estado E1](e1-implementation-status.md) |
| **US-S2** | RF-S2, RF-F2 | E1 | Monitoreo y filtro de facturas (Staff Tesorería) | Cumplida | [Video demo E1](https://youtu.be/_o0NqD-dlAc) · [Estado E1](e1-implementation-status.md) |
| **US-S3** | RF-S3 | E1 | Confirmación manual y comprobante (Staff Tesorería) | Cumplida | [Video demo E1](https://youtu.be/_o0NqD-dlAc) · [Estado E1](e1-implementation-status.md) |
| **US-V2** | RF-V2, M2 | E1 | Prueba de seguridad de Guest User (Staff Coordinación) | Cumplida | [docs/seguridad.md](seguridad.md) · [Video demo E1](https://youtu.be/_o0NqD-dlAc) |
| **US-D1b** | RF-D1b | E2 | Donación con monto libre $\ge \$10.00\text{ MXN}$ (Donante) | Cumplida | Commit `a35a447` · `PublicDonationControllerTest` y `donationForm.test.js` (`8700165`, `b0da3ea`) |
| **US-D5** | RF-D5, RF-V3a | E2 | Confirmación automática vía webhook (Donante) | Pendiente | Sin endpoint `@RestResource` implementado en código |
| **US-V3** | RF-V3b, M3 | E2 | Validación de firma e idempotencia (Staff Tesorería) | Pendiente | Sin verificación HMAC `Stripe-Signature` ni idempotencia en código |
| **US-S4** | RF-S4 | E2 | Auditoría de webhook y avisos descartados (Staff Tesorería) | Pendiente | Sin log de auditoría/avisos rechazados en metadata |

---

## 2.1 Estado técnico de implementación — Cierre Entrega 1 (10 de noviembre de 2026)

Esta sección resume el estado técnico de las historias de Entrega 1 al cierre del hito y conserva la trazabilidad con los artefactos desplegados y documentados.

| Historia | Estado técnico | Evidencia / resultado |
| :--- | :--- | :--- |
| US-D1 | Completada (E1) | Catálogo público (`campaignCatalog`), salto de campaña única y control de vencimiento/capacidad implementados y demostrados. |
| US-D2 | Completada (E1) | Anonimato y desacople de factura implementados y demostrados. |
| US-D3 | Completada (E1) | Registro previo en estado `Pending` y expiración programada (`DonationExpirationService`) implementados. |
| US-D4 | Completada (E1) | Retorno seguro en `donationThankYou` y contacto de soporte implementados. |
| US-C1 | Completada (E1) | Muro de reconocimiento (`donorWall`) y conteo agregado de anónimos implementados. |
| US-F1 | Completada (E1) | Campos CFDI 4.0 y validaciones de RFC implementados. |
| US-S1 | Completada (E1) | Gestión de meta, fecha de vencimiento y permiso de donaciones adicionales implementados. |
| US-S2 | Completada (E1) | Campos fiscales y vistas de seguimiento (`Pending_Donations`, `Invoice_Requests`) implementados. |
| US-S3 | Completada (E1) | Confirmación manual (`DonationManagementService`) y recibo con desglose fiscal implementados. |
| US-V2 | Completada (E1) | Permisos mínimos (`Donation_Public_Guest`), sharing rule de campañas activas y pruebas documentadas en `docs/seguridad.md`. |

---

## 3. Especificación Detallada de Historias de Usuario

### Hito: Entrega 1 (E1)

#### US-D1: Visualización pública de campañas y progreso financiero
* **ID:** US-D1
* **RF que cubre:** RF-D1a, RF-V1
* **Hito:** Entrega 1
* **Historia:**
  * **Como** donante potencial (visitante sin login),
  * **Quiero** elegir una campaña activa y ver cuánto lleva recaudado de su meta,
  * **Para** decidir a cuál iniciativa aportar sin requerir crear una cuenta.
* **Criterios de Aceptación (Gherkin):**
  * **CA1 (Criterio mínimo):** Dado que existen al menos dos campañas activas con meta definida en Salesforce, cuando entro al sitio público sin login, entonces veo cada campaña con su nombre, su meta y su avance actual.
  * **CA2 (Criterio mínimo):** Dado que una donación de una campaña pasa a estado "Pagada" y existe otra en "Pendiente", cuando recargo el sitio público, entonces el avance acumulado de esa campaña suma únicamente el importe de la donación pagada (las donaciones pendientes no cuentan para el avance).
  * **CA3 (Criterio mínimo):** Dado que elegí una campaña activa, cuando continúo al flujo de donación, entonces puedo indicar el monto seleccionando una opción de una lista de montos sugeridos o capturándolo en la pasarela.
  * **CA4 (Criterio propio - Salto con campaña única):** Dado que en la org existe únicamente una campaña activa, cuando un visitante entra al sitio público sin login, entonces el sitio omite la vista general de lista y presenta directamente la vista de detalle de esa campaña para donar de inmediato.
  * **CA5 (Criterio propio / Negativo - Campaña vencida o cerrada al 100%):** Dado que una campaña tiene su fecha límite vencida o alcanzó el 100% de su meta y está configurada para no admitir fondos adicionales, cuando un visitante intenta donar, entonces el sistema bloquea el formulario de donación y muestra un mensaje indicando que la campaña ya no recibe aportaciones.
* **Estado:** Cumplida
* **Evidencia:** [Video demo E1](https://youtu.be/_o0NqD-dlAc) · [Estado técnico E1](e1-implementation-status.md)

---

#### US-D2: Donación en modalidad Anónima
* **ID:** US-D2
* **RF que cubre:** RF-D2, RF-D3, RF-D4
* **Hito:** Entrega 1
* **Historia:**
  * **Como** donante anónimo,
  * **Quiero** realizar una aportación sin que mi nombre aparezca en ningún lugar público,
  * **Para** apoyar a los estudiantes protegiendo mi identidad y privacidad.
* **Criterios de Aceptación (Gherkin):**
  * **CA1 (Criterio mínimo):** Dado que marqué mi donación como anónima, cuando reviso el sitio público (página de campañas, muro de reconocimiento y página de agradecimiento), entonces mi nombre no aparece publicado y el importe aportado se suma al total acumulado de donantes anónimos (o se lista bajo la etiqueta "Donante anónimo").
  * **CA2 (Criterio mínimo):** Dado que capturé mi correo electrónico (requerido para ticket) y mi donación anónima está en estado "Pagada", cuando recibo el comprobante digital por correo, entonces el correo y su comprobante no muestran mi nombre personal y contienen el correo de soporte del programa.
  * **CA3 (Criterio mínimo / Negativo - Desacoplamiento de factura):** Dado que elegí la modalidad puramente anónima sin capturar datos fiscales, cuando intento solicitar factura, entonces el sistema me impide proceder sin registrar RFC y datos tributarios; por el contrario, si selecciono factura pero marco la casilla independiente de no figurar en el muro público, mis datos fiscales se guardan únicamente para control interno de tesorería y mi nombre no se publica.
  * **CA4 (Criterio mínimo):** Dado que existe una donación anónima registrada en Salesforce, cuando el usuario de staff la consulta, entonces la visualiza claramente identificada bajo la modalidad anónima.
* **Estado:** Cumplida
* **Evidencia:** [Video demo E1](https://youtu.be/_o0NqD-dlAc) · [Estado técnico E1](e1-implementation-status.md)

---

#### US-D3: Registro previo de donación y control de expiración
* **ID:** US-D3
* **RF que cubre:** RF-D3, RF-V1
* **Hito:** Entrega 1
* **Historia:**
  * **Como** donante en proceso de aportación,
  * **Quiero** que mi intención de donación quede registrada en Salesforce antes de pagar en la pasarela,
  * **Para** garantizar la trazabilidad institucional y permitir conciliar el pago en cuanto sea procesado.
* **Criterios de Aceptación (Gherkin):**
  * **CA1 (Criterio mínimo):** Dado que capturé mis datos en el formulario público (incluyendo correo electrónico obligatorio) y seleccioné una campaña, cuando presiono el botón para proceder al pago, entonces se crea en Salesforce un registro de donación en estado "Pendiente" con su campaña, modalidad y monto antes de redirigir a la pasarela de prueba.
  * **CA2 (Criterio mínimo):** Dado que envié el formulario y se genera la sesión en Stripe, cuando se inspecciona la pasarela, entonces el pago incluye un identificador de referencia unívoco que permite a staff y al sistema vincular exactamente la transacción con la donación en Salesforce.
  * **CA3 (Criterio propio / Negativo - Expiración de donación abandonada):** Dado que un donante genera un registro en estado "Pendiente" pero abandona la ventana o la sesión en la pasarela caduca sin autorización bancaria, cuando la pasarela marca el intento como expirado o cancelado, entonces la donación en Salesforce cambia a estado "Cancelada / Expirada", evitando permanecer pendiente indefinidamente y sin sumar al avance de la campaña.
* **Estado:** Cumplida
* **Evidencia:** [Video demo E1](https://youtu.be/_o0NqD-dlAc) · [Estado técnico E1](e1-implementation-status.md)

---

#### US-D4: Retorno y página de agradecimiento con contacto de soporte
* **ID:** US-D4
* **RF que cubre:** RF-D4
* **Hito:** Entrega 1
* **Historia:**
  * **Como** donante que finalizó el flujo en la pasarela,
  * **Quiero** ver una página de agradecimiento con el contacto institucional de soporte,
  * **Para** tener certeza de que mi intento de donación fue procesado y disponer de un canal de atención en caso de aclaraciones.
* **Criterios de Aceptación (Gherkin):**
  * **CA1 (Criterio mínimo):** Dado que completé el flujo de pago con tarjeta de prueba en Stripe, cuando la pasarela me devuelve a la página del portal, entonces veo una página de agradecimiento institucional.
  * **CA2 (Criterio mínimo):** Dado que en la Entrega 1 el pago todavía no se confirma de manera automática en Salesforce al momento del retorno, cuando veo la página de agradecimiento, entonces el mensaje no afirma falsamente que el pago está confirmado de manera definitiva.
  * **CA3 (Criterio mínimo):** Dado que me encuentro en la página de agradecimiento, cuando reviso la pantalla, parámetros URL o consola del navegador, entonces no se expone información personal ni montos de otros donantes.
  * **CA4 (Criterio propio - Contacto de soporte visible en E1):** Dado que estoy en la pantalla de agradecimiento, cuando busco asistencia, entonces visualizo claramente el correo de soporte institucional del programa para resolver dudas sobre el donativo.
* **Estado:** Cumplida
* **Evidencia:** [Video demo E1](https://youtu.be/_o0NqD-dlAc) · [Estado técnico E1](e1-implementation-status.md)

---

#### US-C1: Reconocimiento público de aportaciones en campaña
* **ID:** US-C1
* **RF que cubre:** RF-C1
* **Hito:** Entrega 1
* **Historia:**
  * **Como** donante con crédito,
  * **Quiero** que mi nombre y monto aparezcan en el muro de donantes de la campaña,
  * **Para** que la comunidad reconozca públicamente mi apoyo a los estudiantes.
* **Criterios de Aceptación (Gherkin):**
  * **CA1 (Criterio mínimo):** Dado que solicité crédito (o solicité factura con preferencia pública) y mi donación se encuentra en estado "Pagada", cuando cualquier visitante consulta la campaña en el sitio público, entonces ve mi nombre y el monto donado en el muro de reconocimientos de esa campaña, además de la suma consolidada de donantes anónimos.
  * **CA2 (Criterio mínimo):** Dado que aparezco en el muro público de reconocimientos, cuando cualquier persona inspecciona la vista, entonces únicamente se muestran mi nombre y el monto aportado (no aparece correo electrónico, teléfono, RFC ni ningún otro dato personal).
  * **CA3 (Criterio propio / Negativo - Exclusión de no pagadas):** Dado que una donación con crédito permanece en estado "Pendiente" o "Cancelada / Expirada", cuando un visitante consulta el reconocimiento de la campaña, entonces dicho donante no aparece listado hasta que su pago pase a estado "Pagada".
* **Estado:** Cumplida
* **Evidencia:** [Video demo E1](https://youtu.be/_o0NqD-dlAc) · [Estado técnico E1](e1-implementation-status.md)

---

#### US-F1: Captura de datos fiscales CFDI 4.0 y visibilidad
* **ID:** US-F1
* **RF que cubre:** RF-F1
* **Hito:** Entrega 1
* **Historia:**
  * **Como** donante (persona física o moral) que requiere deducir impuestos,
  * **Quiero** registrar mis datos fiscales obligatorios según la normativa mexicana y elegir si deseo figurar en el muro público,
  * **Para** que la coordinación cuente con la información requerida para el trámite fiscal de mi aportación.
* **Criterios de Aceptación (Gherkin):**
  * **CA1 (Criterio mínimo - Datos CFDI 4.0 obligatorios):** Dado que elegí solicitar factura en el formulario, cuando intento enviar la solicitud omitiendo Nombre/Razón Social, RFC, Código Postal Fiscal, Régimen Fiscal, Uso de CFDI o Correo Electrónico, entonces el sistema bloquea el avance y resalta los campos obligatorios pendientes.
  * **CA2 (Criterio mínimo - Validación Regex del SAT):** Dado que introduzco un RFC en el formulario, cuando lo envío, entonces el sistema valida su estructura mediante expresión regular (patrón de letras, fecha y homoclave; 12 caracteres para personas morales y 13 para personas físicas) y rechaza el valor si no coincide, sin invocar servicios externos del SAT.
  * **CA3 (Criterio mínimo - Alcance no fiscal):** Dado que un donante con factura completa su aportación en modo de prueba, cuando se audita el sistema en Salesforce, entonces se corrobora que no se timbra ni genera ningún CFDI oficial ante el SAT.
  * **CA4 (Criterio propio - Visibilidad pública configurable):** Dado que solicité factura, cuando se confirma el pago, entonces mi Nombre/Razón Social y monto aparecen por defecto en el reconocimiento de la campaña para respaldar la transparencia del donativo ante fines fiscales, a menos que haya marcado explícitamente la casilla independiente para no figurar públicamente en el sitio.
* **Estado:** Cumplida
* **Evidencia:** [Video demo E1](https://youtu.be/_o0NqD-dlAc) · [Estado técnico E1](e1-implementation-status.md)

---

#### US-S1: Gestión interna de campañas y control al 100% de la meta
* **ID:** US-S1
* **RF que cubre:** RF-S1
* **Hito:** Entrega 1
* **Historia:**
  * **Como** coordinación del programa,
  * **Quiero** crear y administrar campañas definiendo su meta económica, fecha límite y comportamiento al llegar al 100%,
  * **Para** organizar los fondos de viaje y garantizar que siempre exista al menos una campaña activa disponible para recibir donaciones.
* **Criterios de Aceptación (Gherkin):**
  * **CA1 (Criterio mínimo):** Dado que cuento con permisos de staff en Salesforce, cuando creo una campaña activa con nombre y meta, entonces aparece visible de inmediato en el sitio público.
  * **CA2 (Criterio mínimo):** Dado que existe una campaña activa, cuando staff actualiza el monto de su meta en Salesforce, entonces el sitio público refleja el nuevo valor al recargar.
  * **CA3 (Criterio propio - Regla de meta al 100% y fecha de evento):** Dado que una campaña alcanza el 100% de su meta de recaudación o su fecha límite venció, cuando el sistema evalúa su disponibilidad, entonces el portal público deja de aceptar donaciones a menos que staff haya marcado la casilla de configuración "Permitir donaciones adicionales al superar la meta" en una campaña cuya fecha siga vigente.
  * **CA4 (Criterio propio / Negativo - Validación de meta económica):** Dado que un integrante de staff intenta guardar una campaña con meta menor o igual a cero, cuando intenta guardar el registro, entonces Salesforce arroja una regla de validación impidiendo guardar importes inválidos.
* **Estado:** Cumplida
* **Evidencia:** [Video demo E1](https://youtu.be/_o0NqD-dlAc) · [Estado técnico E1](e1-implementation-status.md)

---

#### US-S2: Consola de monitoreo y filtro de solicitudes de factura
* **ID:** US-S2
* **RF que cubre:** RF-S2, RF-F2
* **Hito:** Entrega 1
* **Historia:**
  * **Como** tesorero del programa,
  * **Quiero** consultar todas las donaciones y filtrar específicamente las que solicitan factura con sus datos fiscales,
  * **Para** mantener el control financiero interno y preparar la atención administrativa correspondiente.
* **Criterios de Aceptación (Gherkin):**
  * **CA1 (Criterio mínimo):** Dado que existen donaciones en múltiples modalidades y estados ("Pendiente", "Pagada", "Cancelada / Expirada"), cuando staff consulta la vista de donaciones en Salesforce, entonces visualiza el estado, monto, modalidad, campaña y referencia de cada registro.
  * **CA2 (Criterio mínimo):** Dado que existen donaciones que solicitaron factura, cuando staff consulta el registro en Salesforce, entonces lo visualiza marcado como "Solicita factura" junto con el Nombre/Razón Social, RFC, Código Postal y Régimen Fiscal capturados.
  * **CA3 (Criterio mínimo):** Dado que existen registros de diversas modalidades, cuando staff selecciona la vista o filtro "Solicitan factura", entonces la lista muestra exclusivamente las aportaciones que requieren factura fiscal.
* **Estado:** Cumplida
* **Evidencia:** [Video demo E1](https://youtu.be/_o0NqD-dlAc) · [Estado técnico E1](e1-implementation-status.md)

---

#### US-S3: Confirmación manual de pago y envío de comprobante
* **ID:** US-S3
* **RF que cubre:** RF-S3
* **Hito:** Entrega 1
* **Historia:**
  * **Como** tesorero del programa,
  * **Quiero** marcar manualmente como pagada una donación pendiente y enviar su comprobante por correo,
  * **Para** acreditar donaciones en caso de que la automatización no esté disponible o se requiera conciliación directa.
* **Criterios de Aceptación (Gherkin):**
  * **CA1 (Criterio mínimo):** Dado que una donación está en estado "Pendiente", cuando staff ejecuta la acción manual de confirmación de pago en Salesforce, entonces el estado del registro cambia a "Pagada" y su importe suma al avance de la campaña.
  * **CA2 (Criterio mínimo):** Dado que staff confirmó el pago, cuando el donante revisa su bandeja de correo, entonces recibe un comprobante/ticket con número de referencia, campaña, fecha, monto, modalidad, datos fiscales (si aplica) y el correo de soporte del programa.
  * **CA3 (Criterio propio / Negativo - Bloqueo de confirmación duplicada):** Dado que una donación ya se encuentra en estado "Pagada", cuando staff intenta accionar nuevamente la confirmación manual, entonces el sistema notifica que el pago ya fue validado y bloquea el reenvío redundante de comprobantes.
* **Estado:** Cumplida
* **Evidencia:** [Video demo E1](https://youtu.be/_o0NqD-dlAc) · [Estado técnico E1](e1-implementation-status.md)

---

#### US-V2: Auditoría y prueba de seguridad para Guest User
* **ID:** US-V2
* **RF que cubre:** RF-V2, M2
* **Hito:** Entrega 1
* **Historia:**
  * **Como** coordinación del programa,
  * **Quiero** evidencia reproducible de que un visitante no autenticado no puede leer ni modificar donaciones ajenas,
  * **Para** proteger los datos personales de los donantes y demostrar el principio de mínimo privilegio.
* **Criterios de Aceptación (Gherkin):**
  * **CA1 (Criterio mínimo):** Dado que existen donaciones de terceros registradas en Salesforce, cuando un visitante sin login intenta consultarlas a través del portal público, APIs del sitio o inspección de red, entonces el sistema devuelve cero registros o acceso denegado.
  * **CA2 (Criterio mínimo / Negativo):** Dado que existen registros de donaciones en la base de datos, cuando un usuario sin sesión intenta modificarlos o eliminarlos mediante llamadas externas, entonces la plataforma rechaza de forma estricta la transacción.
  * **CA3 (Criterio mínimo):** Dado el documento de seguridad (`docs/seguridad.md`), cuando un auditor o el profesor replica los pasos descritos, entonces obtiene exactamente los mismos resultados de bloqueo y denegación.
* **Estado:** Cumplida
* **Evidencia:** [docs/seguridad.md](seguridad.md) · [Video demo E1](https://youtu.be/_o0NqD-dlAc)

---

### Hito: Entrega 2 (E2)

#### US-D1b: Donación de monto libre personalizado
* **ID:** US-D1b
* **RF que cubre:** RF-D1b
* **Hito:** Entrega 2
* **Historia:**
  * **Como** donante,
  * **Quiero** capturar libremente el importe exacto que deseo donar respetando el mínimo procesable por la pasarela,
  * **Para** aportar la cantidad acorde a mis posibilidades sin estar restringido a montos preestablecidos.
* **Criterios de Aceptación (Gherkin):**
  * **CA1 (Criterio mínimo):** Dado que seleccioné una campaña activa, cuando capturo en el formulario un monto personalizado válido mayor o igual al mínimo de Stripe ($\ge \$10.00\text{ MXN}$ o $\ge \$0.50\text{ USD}$), entonces la pasarela de prueba me cobra exactamente esa cantidad y la donación en Salesforce registra idéntico importe.
  * **CA2 (Criterio propio / Negativo - Validación de umbral mínimo de Stripe):** Dado que un donante captura un valor numérico menor a $\$10.00\text{ MXN}$ (o $\$0.50\text{ USD}$ si opera en dicha divisa), un número negativo o cero, cuando intenta avanzar, entonces el formulario bloquea la transición a Stripe y muestra una advertencia indicando el monto mínimo procesable por la pasarela.
* **Estado:** Cumplida
* **Evidencia:** Commit `a35a447` (`PublicDonationController.MIN_DONATION_AMOUNT_MXN = 10.00`, atributo `min="10"` en `donationForm.html`), pruebas Apex `PublicDonationControllerTest.rejectsAmountBelowStripeMinimum` y `acceptsCustomAmountAtStripeMinimum`, y prueba Jest `enforces the Stripe minimum amount of 10 MXN on the amount input` en `donationForm.test.js` (estabilizada en `8700165` / `b0da3ea`, 17/17 pruebas LWC Jest en verde).

---

#### US-D5: Confirmación y comprobante automáticos vía webhook
* **ID:** US-D5
* **RF que cubre:** RF-D5, RF-V3a
* **Hito:** Entrega 2
* **Historia:**
  * **Como** donante,
  * **Quiero** que mi donación se marque automáticamente como pagada al autorizarse en Stripe y recibir mi comprobante por correo al instante,
  * **Para** disponer de la constancia de mi aportación de inmediato sin depender de intervención manual de staff.
* **Criterios de Aceptación (Gherkin):**
  * **CA1 (Criterio mínimo):** Dado que completé un pago exitoso con tarjeta de prueba en Stripe, cuando la pasarela emite su aviso de pago hacia Salesforce, entonces la donación correspondiente transiciona a estado "Pagada" de forma desatendida sin intervención de staff.
  * **CA2 (Criterio mínimo):** Dado que la donación pasó a pagada de forma automática, cuando reviso mi bandeja de entrada, entonces recibo de inmediato el comprobante con los identificadores de la donación, campaña, monto, fecha, desglose fiscal (si aplica) y correo de soporte institucional.
  * **CA3 (Criterio propio / Negativo - Manejo de webhook por sesión expirada):** Dado que un usuario cerró la pasarela y Stripe emite un webhook de expiración (`checkout.session.expired`), cuando Salesforce procesa el evento, entonces actualiza la donación a estado "Cancelada / Expirada" sin detonar comprobante ni sumar a la campaña.
* **Estado:** Pendiente
* **Evidencia / Verificación en código:** Auditoría sobre `salesforce/force-app/main/default/` al commit `19c2f32` confirma que aún **no existe** ninguna clase `@RestResource` / `RestContext` para recepción de webhooks de Stripe.

---

#### US-V3: Validación de autenticidad e idempotencia del Webhook (Nivel 2)
* **ID:** US-V3
* **RF que cubre:** RF-V3b, M3
* **Hito:** Entrega 2
* **Historia:**
  * **Como** tesorero del programa,
  * **Quiero** que el servicio de integración verifique la firma criptográfica de Stripe y prevenga duplicados,
  * **Para** asegurar que solo se procesen avisos legítimos y evitar inconsistencias financieras por reintentos de red.
* **Criterios de Aceptación (Gherkin):**
  * **CA1 (Criterio mínimo / Negativo - Rechazo de avisos falsos):** Dado que un tercero envía un payload simulando un pago pero con firma HMAC inválida o ausente en el header `Stripe-Signature`, cuando la solicitud llega a Salesforce, entonces se rechaza con error HTTP 400/401, el estado de la donación no se altera y la incidencia queda visible para auditoría de staff.
  * **CA2 (Criterio mínimo - Idempotencia ante reintentos):** Dado que Stripe retransmite el mismo evento de pago en dos ocasiones por reintentos de red, cuando ambos mensajes son recibidos en el endpoint, entonces el sistema procesa el primero y detecta el segundo como duplicado, manteniendo una sola donación pagada y emitiendo un único comprobante.
  * **CA3 (Criterio propio - Resguardo de secretos M3):** Dado que se verifica la firma mediante el `Signing Secret`, cuando se audita el código Apex, componentes y el repositorio público de GitHub, entonces se demuestra que la clave no se encuentra expuesta en texto plano ni en el historial de commits, residiendo únicamente en Custom Metadata o Named Credentials protegidas.
* **Estado:** Pendiente
* **Evidencia / Verificación en código:** Auditoría sobre `salesforce/force-app/main/default/` confirma que aún **no existe** verificación HMAC SHA-256 de `Stripe-Signature` ni campo/mecanismo de idempotencia de eventos webhook (`Stripe_Event_Id__c`).

---

#### US-S4: Auditoría de confirmaciones automáticas y log de avisos descartados
* **ID:** US-S4
* **RF que cubre:** RF-S4
* **Hito:** Entrega 2
* **Historia:**
  * **Como** tesorero del programa,
  * **Quiero** distinguir qué donaciones fueron confirmadas por webhook y consultar una bitácora de avisos rechazados,
  * **Para** monitorear la salud de la integración externa sin tener que auditar los registros de forma manual.
* **Criterios de Aceptación (Gherkin):**
  * **CA1 (Criterio mínimo):** Dado que una donación fue confirmada por el webhook de Stripe, cuando staff consulta el registro en Salesforce, entonces distingue claramente que fue validada mediante confirmación automática y no manual.
  * **CA2 (Criterio mínimo):** Dado que un aviso fue descartado (por firma apócrifa, referencia inexistente o error en payload), cuando staff ingresa al registro de avisos rechazados, entonces visualiza la fecha/hora de recepción y el motivo exacto del descarte.
  * **CA3 (Criterio propio - Protección de datos en bitácora):** Dado que se genera un registro de auditoría de integración, cuando staff consulta el log de error, entonces se verifica que la bitácora no almacena datos confidenciales de tarjetas ni secretos de la pasarela.
* **Estado:** Pendiente
* **Evidencia / Verificación en código:** Auditoría sobre `salesforce/force-app/main/default/objects/` confirma que aún **no existe** campo de origen de confirmación ni objeto/bitácora de avisos webhook rechazados.

---

## 3.1 Alcance Adicional Implementado en Entrega 2 (Post-Feedback, UX y Seguridad)

Además del backlog base de RF (`US-D1`–`US-V2` y `US-D1b`–`US-S4`), durante la Entrega 2 se implementaron las siguientes historias derivadas de retroalimentación del producto, experiencia de usuario y cumplimiento de privacidad:

| ID | Título / Alcance | Estado | Artefactos principales | Evidencia (commits / pruebas) |
| :--- | :--- | :---: | :--- | :--- |
| **US-S5** | Carga y visualización de imagen de portada por campaña | Implementada | `Campaign__c.Cover_Image_URL__c`, `CampaignImageService` (`with sharing`, `WITH USER_MODE`), `campaignImageUpload` (`lightning__RecordPage` en `Campaign__c`), renderizado en `campaignCatalog` | Commits `d67bf7e`, `9d2b047`, `b0da3ea`, `f9a3282` (PR `#38` `8fe6427`) · `CampaignImageServiceTest` (3 métodos) |
| **US-D1c** | Botón de compartir campaña en redes/enlace y auto-selección por URL (`?campaign=<id>`) | Implementada | LWC `campaignShare`, reubicación del botón `Apoyar esta causa →` en `.card-body` e integración de `?campaign=` con scroll suave en `campaignCatalog` | Commits `37dcad3`, `771a3d0`, `0d74a21`, `12ee8cd`, `36c12d5`, `9d4fe27` (PR `#46` `19c2f32`) · 10 tests Jest (`campaignShare.test.js`) + 3 tests Jest (`campaignCatalog.test.js`) · [Reporte QA](qa-us-d1.md) |
| **US-R1** | Eliminación del selector `Recognition_Type__c` en el formulario público y muro | Implementada | Simplificación de `donationForm`, `donorWall`, `PublicCampaignController` y `PublicDonationController`; `PublicDonationCommandService` fija `'Individual'` internamente | Commit `f8d766e` (PR `#49` `3e1fd12`) |
| **US-R2** | Carga directa de imagen de reconocimiento (`<= 2 MB`) vía Salesforce Files | Implementada | Selector de archivo Base64 en `donationForm` y publicación en `PublicDonationCommandService.publishDonorImage()` mediante `ContentVersion` + `ContentDistribution` (`ContentDownloadUrl`) | Commits `8977d67`, `b0da3ea` (PR `#49` `3e1fd12`) · `PublicDonationCommandServiceTest` (3 métodos) |
| **US-UX1** | Sección de Preguntas Frecuentes (FAQ) con navegación `HOME` / `FAQ` | Implementada | LWC `faqSection` (acordeón de 3 preguntas frecuentes) y barra de navegación sin recarga en `campaignCatalog` | Commit `b814314` |
| **US-UX2** | Formulario de contacto público (**Contáctanos**) que crea `Case` en Salesforce | Implementada *(con asignación diferida)* | Formulario en `faqSection`, `ContactController` (`with sharing`), `ContactCommandService` (`without sharing`, `AccessLevel.SYSTEM_MODE`), habilitación en `Donation_Public_Guest`, `Case.assignmentRules-meta.xml` | Commits `7d55eb2`, `5920f4f` · `ContactControllerTest` (4 métodos) · *Nota:* `Case.assignmentRules-meta.xml` está excluido temporalmente en `salesforce/.forceignore` (ver `PENDING_IMPLEMENTATIONS.md`) |
| **issue-45** | Aceptación explícita del Aviso de Privacidad (LFPDPPP) en formulario de donación | Implementada | Campo `Donation__c.Privacy_Accepted__c` (`Checkbox`), checkbox obligatorio y aviso LFPDPPP en `donationForm`, validación y persistencia en `PublicDonationController` / `PublicDonationCommandService`, FLS lectura en `Donation_Coordination` | Commit `300f806` + cierre de persistencia en `PublicDonationControllerTest` (`rejectsMissingPrivacyAcceptance` / `createsPendingDonationAndStripeCheckout`) y `PublicDonationCommandServiceTest` |

---

## 4. Registro de Acuerdos y Decisiones con el Cliente

*Documentación de trazabilidad para el cumplimiento de los Criterios C4 y C7 (enlazada con [Modelo de Datos y ER](modelo_datos_er.md) y [Bitácora de IA](bitacora_ia.md)).*  
> **Nota:** El archivo `docs/preguntas_y_reportes.md` (requerido como entregable independiente para preguntas al cliente y reportes) **sigue pendiente de creación** en `docs/`.

| Fecha | Origen / Dudas Planteadas | Respuesta del Cliente / Decisión Acordada | Historias Impactadas |
| :--- | :--- | :--- | :--- |
| **03/11/2026** | **Navegación sin login y campaña única:** ¿Se requiere token? ¿Cómo mostrar campañas si solo hay una activa? | Cualquier visitante debe poder donar directo sin registros ni tokens. Si existe una sola campaña activa, el sitio puede omitir el listado y saltar directo a su vista de donación. | `US-D1`, `US-V2` |
| **03/11/2026** | **Monto mínimo de donación:** ¿Cuál debe ser el monto mínimo permitido? | Lo más bajo posible según la documentación oficial de la pasarela. Tras investigar Stripe México, el mínimo es $\$10.00\text{ MXN}$ (o $\$0.50\text{ USD}$). | `US-D1b` |
| **03/11/2026** | **Datos fiscales mínimos:** ¿Cuáles son los datos obligatorios para donaciones con factura? | Se deben solicitar los datos mínimos reales para deducir impuestos en México (CFDI 4.0): RFC, Nombre/Razón Social, C.P. fiscal, Régimen Fiscal y Uso de CFDI. | `US-F1`, `US-S2` |
| **03/11/2026** | **Correo en donaciones anónimas:** ¿Es obligatorio pedir correo al donante anónimo? | Sí, el ticket/recibo en su correo es el mínimo requerido para cualquier donación. Se pide garantizando que solo se usa para el envío del recibo. | `US-D2` |
| **03/11/2026** | **Expiración de donaciones pendientes:** ¿Qué ocurre con donaciones abandonadas? | No existe "pendiente indefinidamente". El ciclo lo controla la pasarela al caducar la sesión; al expirar sin pago, transiciona a cancelada/expirada. | `US-D3`, `US-D5` |
| **03/11/2026** | **Campañas al 100% o vencidas:** ¿Se siguen aceptando donaciones tras llegar a la meta? | Si la fecha límite ya pasó, no se reciben más aportaciones. Si llega al 100%, se debe poder configurar si la campaña desea seguir recibiendo fondos adicionales o cerrarse. | `US-D1`, `US-S1` |
| **06/11/2026** | **Anonimato y factura independientes:** ¿Un donante con factura puede pedir anonimato público? | Aprobado. Las opciones de visibilidad pública y solicitud de factura son casillas independientes en el formulario. Por defecto quien pide factura es público, salvo que elija anonimato. | `US-D2`, `US-C1`, `US-F1` |
| **06/11/2026** | **Visualización de donaciones anónimas en muro:** ¿Cómo se presentan los donantes anónimos? | Se suman los montos de todos los donantes anónimos y se muestra ese total por separado en la campaña, o se listan con la etiqueta genérica "Donante anónimo". | `US-D2`, `US-C1` |
| **06/11/2026** | **Soporte al donante en Entrega 1:** ¿Dónde se coloca el medio de contacto de ayuda? | Incluir el correo electrónico institucional de soporte tanto en la página de agradecimiento como en el correo del ticket desde la Entrega 1. | `US-D4`, `US-S3`, `US-D5` |
