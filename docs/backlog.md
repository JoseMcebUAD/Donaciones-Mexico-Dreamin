# Product Backlog — Portal de Donaciones para Mexico Dreamin
**Programa:** SF Vibe Lab (UADY - Salesforce, Mérida)  
**Equipo:** Consultoría e Implementación SF Vibe Lab  
**Integrantes:** José Ceballos, José Diaz, Jesús Méndez.
**Hitos del Proyecto:** Entrega 1 (E1) y Entrega 2 (E2)  

---

## 1. Resumen y Estado de Avance

| Métrica | Entrega 1 (E1) | Entrega 2 (E2) |
| :--- | :---: | :---: |
| **Historias comprometidas** | 10 | 14 (10 de E1 + 4 de E2) |
| **Historias cumplidas** | 0 | 0 |
| **% de Avance** | **0%** | **0%** |

> *Fórmula de cálculo:*  
> - **Avance E1:** `(Historias cumplidas E1 / Total historias E1) * 100`  
> - **Avance E2:** `(Historias cumplidas totales / Total historias backlog) * 100`

---

## 2. Tablero de Historias de Usuario

| ID | RF Cubierto | Hito | Título / Rol | Estado | Evidencia |
| :--- | :--- | :---: | :--- | :---: | :--- |
| **US-01** | RF-D1a, RF-V1 | E1 | Ver campañas y metas (Donante/Visitante) | Pendiente | - |
| **US-02** | RF-D2, RF-D3 | E1 | Donar de forma anónima (Donante anónimo) | Pendiente | - |
| **US-03** | RF-D3, RF-V1 | E1 | Registro previo al pago (Donante/Sistema) | Pendiente | - |
| **US-04** | RF-D4 | E1 | Redirección a agradecimiento (Donante) | Pendiente | - |
| **US-05** | RF-C1 | E1 | Reconocimiento público de aportación (Donante con crédito) | Pendiente | - |
| **US-06** | RF-F1 | E1 | Captura y validación de RFC/datos (Donante con factura) | Pendiente | - |
| **US-07** | RF-S1 | E1 | Gestión de campañas y metas (Staff Coordinación) | Pendiente | - |
| **US-08** | RF-S2, RF-F2 | E1 | Monitoreo y filtro de solicitudes (Staff Tesorería) | Pendiente | - |
| **US-09** | RF-S3 | E1 | Confirmación manual y comprobante (Staff Tesorería) | Pendiente | - |
| **US-10** | RF-V2, M2 | E1 | Prueba de seguridad Guest User (Staff Coordinación) | Pendiente | `docs/seguridad.md` |
| **US-11** | RF-D1b | E2 | Donación con importe libre (Donante) | Pendiente | - |
| **US-12** | RF-D5, RF-V3a | E2 | Confirmación automática vía webhook (Donante/Sistema) | Pendiente | - |
| **US-13** | RF-V3b | E2 | Verificación de firma e idempotencia (Staff Tesorería) | Pendiente | - |
| **US-14** | RF-S4 | E2 | Auditoría de webhook y fallos (Staff Tesorería) | Pendiente | - |

---

## 3. Especificación Detallada de Historias de Usuario

### Hito: Entrega 1 (E1)

#### US-01: Visualización pública de campañas y progreso financiero
* **ID:** US-01  
* **RF que cubre:** RF-D1a, RF-V1  
* **Hito:** Entrega 1  
* **Historia:**  
  * **Como** donante potencial (visitante sin login),  
  * **Quiero** consultar las campañas activas, su meta económica y el avance recaudado actual,  
  * **Para** decidir a qué iniciativa destinar mi aportación.  
* **Acceptance Criteria (Dado / Cuando / Entonces):**  
  * **CA1 (Criterio mínimo):** Dado que existen al menos dos campañas activas con meta en Salesforce, cuando entro al sitio sin iniciar sesión, entonces veo cada campaña con su meta y su avance.  
  * **CA2 (Criterio mínimo):** Dado que una donación de una campaña pasa a estado "Pagada", cuando vuelvo a cargar el sitio, entonces el avance de esa campaña incluye ese monto (las donaciones pendientes no suman al avance).  
  * **CA3 (Criterio mínimo):** Dado que elegí una campaña, cuando continúo al flujo de donar, entonces puedo seleccionar un monto sugerido de una lista.  
  * **CA4 (Criterio propio - Caso negativo):** Dado que una campaña está marcada como inactiva o finalizada en Salesforce, cuando un visitante abre el sitio público, entonces la campaña no aparece listada ni permite recibir donaciones.  
* **Estado:** Pendiente  
* **Evidencia:** `[Enlace a commit / video demo]`

---

#### US-02: Donación en modalidad anónima
* **ID:** US-02  
* **RF que cubre:** RF-D2, RF-D3, RF-D4  
* **Hito:** Entrega 1  
* **Historia:**  
  * **Como** donante anónimo,  
  * **Quiero** realizar una aportación sin que mi nombre aparezca en ningún medio público,  
  * **Para** apoyar a los estudiantes protegiendo mi privacidad e identidad.  
* **Acceptance Criteria (Dado / Cuando / Entonces):**  
  * **CA1 (Criterio mínimo):** Dado que marqué mi donación como anónima, cuando reviso el sitio público (campañas, muro de donantes y página de agradecimiento), entonces mi nombre no aparece.  
  * **CA2 (Criterio mínimo):** Dado que mi donación anónima está pagada, cuando recibo el comprobante, entonces el comprobante no muestra mi nombre.  
  * **CA3 (Criterio mínimo):** Dado que marqué mi donación como anónima, cuando reviso el formulario, entonces la opción de solicitar factura está bloqueada/deshabilitada (la modalidad anónima no admite factura).  
  * **CA4 (Criterio mínimo):** Dado que existe una donación anónima, cuando staff la consulta internamente en Salesforce, entonces la ve identificada como modalidad anónima.  
  * **CA5 (Criterio propio - Caso negativo):** Dado que un visitante manipula el payload para enviar modalidad anónima con datos de facturación (RFC), cuando el sistema procesa el registro, entonces rechaza la solicitud indicando la incompatibilidad.  
* **Estado:** Pendiente  
* **Evidencia:** `[Enlace a commit / video demo]`

---

#### US-03: Registro previo de donación en estado pendiente
* **ID:** US-03  
* **RF que cubre:** RF-D3, RF-V1  
* **Hito:** Entrega 1  
* **Historia:**  
  * **Como** donante en proceso de pago,  
  * **Quiero** que mi donación quede registrada en Salesforce antes de ser redirigido a la pasarela,  
  * **Para** garantizar la trazabilidad de mi aportación y permitir su posterior conciliación.  
* **Acceptance Criteria (Dado / Cuando / Entonces):**  
  * **CA1 (Criterio mínimo):** Dado que llené mis datos y elegí campaña, cuando envío el formulario, entonces existe en Salesforce una donación en estado "Pendiente" con su campaña, modalidad y monto antes de que se abra la pasarela.  
  * **CA2 (Criterio mínimo):** Dado que envié el formulario, cuando se abre la pasarela de prueba de Stripe, entonces el pago lleva una referencia (`client_reference_id` / metadata) que permite a staff localizar la donación en Salesforce.  
  * **CA3 (Criterio propio - Caso negativo / Abandono):** Dado que un usuario registra una donación pendiente pero cancela o cierra la ventana de Stripe, cuando se revisa el registro en Salesforce, entonces permanece en estado "Pendiente" y no altera el avance público de la campaña.  
* **Estado:** Pendiente  
* **Evidencia:** `[Enlace a commit / video demo]`

---

#### US-04: Página de agradecimiento al finalizar pago
* **ID:** US-04  
* **RF que cubre:** RF-D4  
* **Hito:** Entrega 1  
* **Historia:**  
  * **Como** donante que pagó en la pasarela,  
  * **Quiero** ver una página de agradecimiento al regresar al sitio,  
  * **Para** tener certeza visual de que el proceso concluyó de manera ordenada.  
* **Acceptance Criteria (Dado / Cuando / Entonces):**  
  * **CA1 (Criterio mínimo):** Dado que completé el pago con una tarjeta de prueba, cuando la pasarela me regresa al sitio, entonces veo una página de agradecimiento.  
  * **CA2 (Criterio mínimo):** Dado que el pago aún no está confirmado internamente en Salesforce (flujo manual en E1), cuando veo la página de agradecimiento, entonces la página no afirma falsamente que el pago está confirmado.  
  * **CA3 (Criterio mínimo):** Dado que estoy en la página de agradecimiento, cuando reviso el contenido y parámetros, entonces no muestra datos de otros donantes ni claves del sistema.  
  * **CA4 (Criterio propio - Caso negativo):** Dado que un usuario accede directamente a la URL de agradecimiento sin haber pasado por un intento de donación, cuando carga la página, entonces se muestra un mensaje informativo invitando a explorar las campañas activas sin generar errores de sistema.  
* **Estado:** Pendiente  
* **Evidencia:** `[Enlace a commit / video demo]`

---

#### US-05: Reconocimiento público de donante con crédito
* **ID:** US-05  
* **RF que cubre:** RF-C1  
* **Hito:** Entrega 1  
* **Historia:**  
  * **Como** donante con crédito,  
  * **Quiero** que mi nombre y monto aparezcan en el muro de donantes de la campaña,  
  * **Para** recibir reconocimiento público por respaldar a los estudiantes.  
* **Acceptance Criteria (Dado / Cuando / Entonces):**  
  * **CA1 (Criterio mínimo):** Dado que solicité crédito y mi donación está en estado "Pagada", cuando cualquier visitante abre la campaña, entonces ve mi nombre y el monto en el reconocimiento de donantes de esa campaña.  
  * **CA2 (Criterio mínimo):** Dado que solicité crédito, cuando se revisa el reconocimiento público, entonces solo aparecen mi nombre y el monto (no aparece correo ni ningún otro dato personal).  
  * **CA3 (Criterio propio - Caso negativo):** Dado que un donante solicitó crédito pero su donación permanece en estado "Pendiente", cuando un visitante consulta la campaña, entonces el donante no aparece en la lista pública hasta que el pago sea confirmado.  
* **Estado:** Pendiente  
* **Evidencia:** `[Enlace a commit / video demo]`

---

#### US-06: Captura y validación de RFC para donante con factura
* **ID:** US-06  
* **RF que cubre:** RF-F1  
* **Hito:** Entrega 1  
* **Historia:**  
  * **Como** donante que requiere comprobante fiscal,  
  * **Quiero** capturar mi Razón Social/Nombre y mi RFC con validación de estructura SAT,  
  * **Para** proporcionar los datos necesarios para mi solicitud de facturación.  
* **Acceptance Criteria (Dado / Cuando / Entonces):**  
  * **CA1 (Criterio mínimo):** Dado que elegí solicitar factura, cuando intento enviar el formulario sin nombre/razón social o sin RFC, entonces no puedo enviarlo y el sistema resalta los campos faltantes.  
  * **CA2 (Criterio mínimo):** Dado que capturé un RFC, cuando lo envío, entonces el sistema lo valida contra el patrón del SAT (12 caracteres para persona moral o 13 para persona física con homoclave) y rechaza el que no lo cumpla, sin consultar externamente al SAT.  
  * **CA3 (Criterio mínimo):** Dado que se completó una donación con factura, cuando se audita el sistema, entonces se constata que no se emite ningún comprobante fiscal oficial (CFDI).  
  * **CA4 (Criterio propio - Caso negativo):** Dado que un usuario ingresa caracteres especiales o minúsculas en el RFC, cuando el formulario procesa la entrada, entonces normaliza a mayúsculas o notifica formato inválido antes de bloquear la transacción.  
* **Estado:** Pendiente  
* **Evidencia:** `[Enlace a commit / video demo]`

---

#### US-07: Administración interna de campañas
* **ID:** US-07  
* **RF que cubre:** RF-S1  
* **Hito:** Entrega 1  
* **Historia:**  
  * **Como** integrante de la coordinación del programa,  
  * **Quiero** crear y editar campañas con su meta económica en Salesforce,  
  * **Para** organizar la recaudación de fondos de los estudiantes.  
* **Acceptance Criteria (Dado / Cuando / Entonces):**  
  * **CA1 (Criterio mínimo):** Dado que tengo permisos de staff, cuando creo una campaña con nombre y meta, entonces aparece reflejada en el sitio público.  
  * **CA2 (Criterio mínimo):** Dado que existe una campaña activa, cuando staff modifica su meta económica, entonces el sitio público muestra la meta actualizada.  
  * **CA3 (Criterio propio - Caso negativo):** Dado que un miembro de staff intenta asignar una meta con valor cero o negativo, cuando guarda el registro en Salesforce, entonces el sistema arroja una regla de validación impidiendo guardar importes inválidos.  
* **Estado:** Pendiente  
* **Evidencia:** `[Enlace a commit / video demo]`

---

#### US-08: Visualización y filtrado de donaciones para Tesorería
* **ID:** US-08  
* **RF que cubre:** RF-S2, RF-F2  
* **Hito:** Entrega 1  
* **Historia:**  
  * **Como** tesorero del programa,  
  * **Quiero** consultar todas las donaciones y filtrar de manera específica aquellas que solicitan factura,  
  * **Para** mantener el control contable e identificar a los donantes que requieren atención fiscal.  
* **Acceptance Criteria (Dado / Cuando / Entonces):**  
  * **CA1 (Criterio mínimo):** Dado que existen donaciones en distintos estados y modalidades, cuando staff consulta el listado en Salesforce, entonces visualiza de cada una su estado, monto, modalidad y campaña.  
  * **CA2 (Criterio mínimo):** Dado que existen donaciones con factura, cuando staff filtra por modalidad con factura, entonces ve la lista acotada mostrando el nombre/razón social y el RFC capturados.  
  * **CA3 (Criterio propio):** Dado que existen múltiples donaciones históricas, cuando staff busca por folio de referencia o filtra por campaña, entonces la vista responde de forma ágil sin exceder límites de visualización.  
* **Estado:** Pendiente  
* **Evidencia:** `[Enlace a commit / video demo]`

---

#### US-09: Confirmación manual de pago y envío de comprobante
* **ID:** US-09  
* **RF que cubre:** RF-S3  
* **Hito:** Entrega 1  
* **Historia:**  
  * **Como** tesorero del programa,  
  * **Quiero** confirmar manualmente el pago de una donación pendiente,  
  * **Para** asegurar que el donante reciba su comprobante aunque la automatización falle o no esté activa.  
* **Acceptance Criteria (Dado / Cuando / Entonces):**  
  * **CA1 (Criterio mínimo):** Dado que una donación está en estado "Pendiente", cuando staff confirma manualmente su pago en Salesforce, entonces pasa a estado "Pagada".  
  * **CA2 (Criterio mínimo):** Dado que staff confirmó el pago, cuando el donante revisa su correo electrónico capturado, entonces recibe un comprobante digital identificando su donación.  
  * **CA3 (Criterio propio - Caso negativo):** Dado que una donación ya se encuentra en estado "Pagada", cuando staff intenta marcarla como pagada nuevamente, entonces el sistema bloquea la acción o previene el envío redundante de correos.  
* **Estado:** Pendiente  
* **Evidencia:** `[Enlace a commit / video demo]`

---

#### US-10: Auditoría de seguridad y mínimos privilegios para Guest User
* **ID:** US-10  
* **RF que cubre:** RF-V2, M2  
* **Hito:** Entrega 1  
* **Historia:**  
  * **Como** coordinador del programa,  
  * **Quiero** evidencia verificable de que un visitante no autenticado no puede leer ni modificar donaciones ajenas,  
  * **Para** garantizar la protección estricta de la información de los donantes.  
* **Acceptance Criteria (Dado / Cuando / Entonces):**  
  * **CA1 (Criterio mínimo):** Dado que existen donaciones registradas por terceros, cuando un visitante sin login intenta consultarlas por la interfaz o endpoints del sitio, entonces no obtiene ningún dato.  
  * **CA2 (Criterio mínimo):** Dado que existen donaciones en la base de datos, cuando un visitante sin login intenta modificar o eliminar registros ajenos, entonces el intento falla y es denegado por la plataforma.  
  * **CA3 (Criterio mínimo):** Dado el archivo `docs/seguridad.md`, cuando un auditor sigue las instrucciones paso a paso, entonces puede reproducir la prueba y obtener los mismos resultados de denegación.  
  * **CA4 (Criterio propio):** Dado el repositorio de código y metadata de la org, cuando se auditan perfiles y permission sets, entonces el usuario Guest cuenta únicamente con permisos estrictamente necesarios para ver campañas y crear su propio intento de donación.  
* **Estado:** Pendiente  
* **Evidencia:** `docs/seguridad.md`

---

### Hito: Entrega 2 (E2)

#### US-11: Aportación con monto libre personalizado
* **ID:** US-11  
* **RF que cubre:** RF-D1b  
* **Hito:** Entrega 2  
* **Historia:**  
  * **Como** donante,  
  * **Quiero** ingresar un monto libre en el formulario en lugar de usar importes predefinidos,  
  * **Para** donar exactamente la cantidad que se ajusta a mi capacidad económica.  
* **Acceptance Criteria (Dado / Cuando / Entonces):**  
  * **CA1 (Criterio mínimo):** Dado que seleccioné una campaña, cuando capturo un importe numérico mayor a cero en el sitio, entonces la pasarela de prueba me cobra esa cantidad exacta y Salesforce registra ese mismo monto.  
  * **CA2 (Criterio propio - Caso negativo):** Dado que introduzco un valor en cero, negativo o caracteres no válidos, cuando intento proceder al checkout, entonces el formulario muestra un error de validación y bloquea el avance hacia Stripe.  
* **Estado:** Pendiente  
* **Evidencia:** `[Enlace a commit / video demo]`

---

#### US-12: Confirmación automática de pago vía webhook
* **ID:** US-12  
* **RF que cubre:** RF-D5, RF-V3a  
* **Hito:** Entrega 2  
* **Historia:**  
  * **Como** donante,  
  * **Quiero** que mi aportación se confirme y recibir mi comprobante de inmediato al pagar en Stripe,  
  * **Para** contar con la constancia al instante sin depender de la revisión manual del staff.  
* **Acceptance Criteria (Dado / Cuando / Entonces):**  
  * **CA1 (Criterio mínimo):** Dado que pagué exitosamente con tarjeta de prueba en Stripe, cuando la pasarela emite su aviso de pago hacia Salesforce, entonces la donación correspondiente pasa a "Pagada" de forma desatendida.  
  * **CA2 (Criterio mínimo):** Dado que la donación se confirmó automáticamente, cuando reviso el correo electrónico capturado, entonces recibo un comprobante detallado con mi número de folio y datos de la donación.  
  * **CA3 (Criterio propio - Caso negativo):** Dado que se recibe un aviso con un identificador de donación que no existe en Salesforce, cuando el servicio procesa la solicitud, entonces la transacción responde controladamente sin generar excepciones no controladas en el endpoint.  
* **Estado:** Pendiente  
* **Evidencia:** `[Enlace a commit / video demo]`

---

#### US-13: Validación criptográfica de firma e idempotencia de webhook (Nivel 2)
* **ID:** US-13  
* **RF que cubre:** RF-V3b  
* **Hito:** Entrega 2  
* **Historia:**  
  * **Como** tesorero del programa,  
  * **Quiero** que el sistema rechace avisos falsos y gestione reintentos duplicados de la pasarela,  
  * **Para** garantizar que nadie marque donaciones como pagadas indebidamente ni se dupliquen registros o comprobantes.  
* **Acceptance Criteria (Dado / Cuando / Entonces):**  
  * **CA1 (Criterio mínimo):** Dado que un tercero ajeno envía un aviso sin firma válida de Stripe, cuando llega a Salesforce, entonces se rechaza de inmediato, la donación no se modifica y el intento fallido queda visible para staff.  
  * **CA2 (Criterio mínimo):** Dado que la pasarela retransmite dos veces el mismo evento de pago, cuando ambos llegan al endpoint, entonces se procesa solo uno, manteniéndose una sola donación pagada y un solo comprobante emitido.  
  * **CA3 (Criterio propio):** Dado que se gestiona el secreto de firma (`webhook signing secret`), cuando se revisa el código fuente y el historial de commits, entonces se comprueba que el secreto reside exclusivamente en configuración protegida (Named Credential o Custom Metadata) y nunca en el repositorio público (cumplimiento M3).  
* **Estado:** Pendiente  
* **Evidencia:** `[Enlace a commit / video demo]`

---

#### US-14: Registro de auditoría y monitoreo de avisos de pasarela
* **ID:** US-14  
* **RF que cubre:** RF-S4  
* **Hito:** Entrega 2  
* **Historia:**  
  * **Como** tesorero del programa,  
  * **Quiero** auditar qué donaciones se confirmaron automáticamente y consultar los eventos rechazados con su motivo,  
  * **Para** tener certidumbre del comportamiento de la integración sin inspeccionar registro por registro.  
* **Acceptance Criteria (Dado / Cuando / Entonces):**  
  * **CA1 (Criterio mínimo):** Dado que una donación fue confirmada por el webhook de Stripe, cuando staff la consulta, entonces se distingue claramente que fue procesada por aviso automático y no de forma manual.  
  * **CA2 (Criterio mínimo):** Dado que un aviso fue rechazado (por firma, formato o error de procesamiento), cuando staff revisa la bitácora de eventos, entonces visualiza la fecha/hora y el motivo técnico del descarte.  
  * **CA3 (Criterio propio):** Dado el registro del log de rechazos, cuando se examina la información guardada, entonces se comprueba que no almacena números de tarjeta ni datos confidenciales que vulneren la privacidad.  
* **Estado:** Pendiente  
* **Evidencia:** `[Enlace a commit / video demo]`

---

## 4. Registro de Preguntas Abiertas y Acuerdos con el Cliente

*Documentación requerida para el cumplimiento de los criterios C4 y C7 (enlazado con `docs/preguntas_y_reportes.md`).*

| Fecha | Pregunta al Cliente / Asesor | Decisión / Respuesta Acordada | Impacto en Backlog |
| :---: | :--- | :--- | :--- |
| **28/10/2026** | ¿Un donante con factura puede elegir aparecer o no en el muro de agradecimientos? | **Acuerdo:** Por defecto, los donantes con factura no aparecen en el muro público a menos que marquen explícitamente una casilla de consentimiento de crédito. | Definido en US-06 y US-05 |
| **28/10/2026** | ¿Qué vigencia tiene una donación en estado "Pendiente" que nunca se pagó en Stripe? | **Acuerdo:** Las donaciones pendientes no se eliminan para conservar la trazabilidad, pero se excluyen de métricas de recaudación activa. | Definido en US-01 y US-03 |
| **04/11/2026** | Si Stripe Test presenta incidencias con cobros en MXN, ¿se admite configurar USD? | **Acuerdo:** Sí, siempre que se registre la justificación técnica en la bitácora de entrega. | Considerado en US-03 y US-11 |