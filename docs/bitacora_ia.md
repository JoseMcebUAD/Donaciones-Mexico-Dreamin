# Bitácora de Uso de IA

**Proyecto:** Portal de Donaciones para Mexico Dreamin  
**Programa:** SF Vibe Lab (UADY - Salesforce, Mérida)  
**Ruta:** `docs/bitacora_ia.md`  

---

## Implementación de Entrega 1 con Codex

**Fecha:** 10 de noviembre de 2026
**Herramienta:** Codex
**Alcance:** US-01 a US-10

Se usó IA para revisar el backlog, convertir los requisitos en metadata Salesforce DX, proponer controles de mínimo privilegio y generar pruebas. Se revisó especialmente que el avance de campaña sólo agregue donaciones `Paid`, que la combinación anónimo + factura se rechace y que el retorno de Stripe no marque un pago como confirmado.

La IA detectó dos riesgos antes del despliegue: el token de `jDiaz` había expirado y la integración no debía contener una clave Stripe en el repositorio. La corrección fue documentar la reautenticación con `sf org login web --alias jDiaz` y utilizar la Named Credential `Stripe_Test` configurada manualmente en la org. Las pruebas locales y la revisión de secretos deben ejecutarse antes de abrir o aprobar el PR.

## Registro de Interacciones

### Entrada 01: Generación y Refinamiento del Product Backlog (Historias de Usuario)

* **Fecha:** 28 de octubre de 2026
* **Autor:** [Nombre del integrante del equipo]
* **Herramienta:** Google Gemini (Gemini 3 Flash)
* **Historia(s) Relacionada(s):** Todas (US-01 a US-14, cubriendo RF-D1a a RF-D5, RF-C1, RF-F1, RF-F2, RF-S1 a RF-S4, RF-V1, RF-V2, RF-V3a, RF-V3b)
* **Hito:** Entrega 1 / Entrega 2

#### 1. Qué se pidió (Prompt / Resumen)
> *"Lee este proyecto y redacta las historias de usuario necesarias."*  
> (Adjuntando el PDF de lineamientos del proyecto: `Proyecto: Donaciones para Mexico Dreamin — Lineamientos`).  
> 
> *Prompt complementario de contexto y validación:*  
> *"Prepara el archivo en Markdown para github asegurando el cumplimiento de la rúbrica C4: Todos los RF cubiertos, ninguna historia describe el 'how', cada historia tiene al menos un criterio propio además de los mínimos (incluidos casos negativos) y las preguntas al cliente registradas."*

#### 2. Qué se obtuvo
Un archivo completo en Markdown (`docs/backlog.md`) estructurado con:
* Resumen de avance métrico para Entrega 1 y Entrega 2.
* Tabla resumen del backlog con columnas: `ID`, `RF Cubierto`, `Hito`, `Título`, `Estado` y `Evidencia`.
* 14 Historias de Usuario desglosadas en formato estándar (*Como... Quiero... Para...*):
  * 10 historias para el Hito de Entrega 1 (cubriendo modalidades anónima, con crédito, con factura, flujos de staff y seguridad de Guest User).
  * 4 historias para el Hito de Entrega 2 (monto libre, confirmación desatendida vía webhook, validación de firma/idempotencia y bitácora de rechazos).
* Criterios de Aceptación en formato *Dado / Cuando / Entonces* (Gherkin) para cada historia, integrando los criterios mínimos de la guía más criterios propios con casos negativos y validaciones de borde.
* Tabla de registro de preguntas clave y acuerdos con el cliente.

#### 3. Qué se verificó y cómo
Se contrastó el documento generado contra la guía oficial y la rúbrica del proyecto (Criterio C4 y Sección 4):
1. **Verificación de Cobertura de RF:** Se validó que no faltara ningún requerimiento funcional listado en la guía (se cubrieron desde RF-D1a hasta RF-V3b en su totalidad).
2. **Ausencia del "How":** Se revisó la redacción de las 14 historias para comprobar que estuvieran orientadas al rol de negocio (*donante*, *tesorería*, *coordinación*, *visitante*) y al valor obtenido, sin prescribir clases Apex, componentes LWC o URLs en la narrativa.
3. **Criterios Propios y Casos Negativos:** Se comprobó que cada historia incluyera al menos un escenario negativo o validación defensiva (ej. rechazo de campañas vencidas en US-01, incompatibilidad de factura con anonimato en US-02, abandono de checkout en US-03, RFC inválido en US-06, duplicados y firmas apócrifas en US-13).
4. **Acuerdos del Cliente:** Se corroboró que las preguntas abiertas sobre anonimato con factura y caducidad de donaciones pendientes estuvieran reflejadas con acuerdos claros.

#### 4. Qué se corrigió / Errores detectados de la IA
* **Hallazgo / Desvío:** En la primera versión de respuesta se incluyeron bloques explicativos y notas técnicas que mencionaban tecnologías de implementación (*Apex REST, Flow, Experience Cloud*).
* **Corrección:** Se solicitó generar formalmente el archivo Markdown estructurado para GitHub (`docs/backlog.md`), eliminando cualquier contaminación técnica en la descripción de las historias para cumplir al 100% con la restricción de *"no describe el 'how'"*.
* **Ajuste de Codificación (Script de exportación):** Al exportar los issues mediante PowerShell a GitHub, la terminal generó caracteres corruptos por la codificación ANSI de Windows. Se corrigió forzando la consola a UTF-8 (`[Console]::OutputEncoding = [System.Text.Encoding]::UTF8`).

#### 5. Aceleración estimada
* **Estimación sin IA:** 6 a 8 horas de trabajo de equipo para estructurar, desglosar los 14 requerimientos funcionales, escribir 40+ escenarios Gherkin y formatear el Markdown.
* **Tiempo real con IA:** Aproximadamente 45 minutos (generación, revisión rigurosa contra la rúbrica C4 y ajustes de exportación).
* **Ahorro de tiempo estimado:** ~85% de aceleración en la fase inicial de definición del backlog.

---

### Entrada 02: Auditoría del sistema y alineación con backlog refinado (v2)

* **Fecha:** 10 de noviembre de 2026
* **Autor:** José Ceballos
* **Herramienta:** Claude Code (claude-sonnet-4-6) vía Claude Agent SDK
* **Historia(s) Relacionada(s):** US-01 a US-10 (E1); comparación de issues #2–#11 (v1) vs #20–#29 (v2)
* **Hito:** Entrega 1

#### 1. Qué se pidió
> *"Hazme una auditoría del sistema en la carpeta /salesforce y compara los issues existentes del proyecto del 1–15 y del 20–33 para comparar cuáles están hechas con las nuevas, y prepara tareas y un plan de acción para que el sistema sea lo más parecido a las nuevas historias de usuario."*

#### 2. Qué se obtuvo
- Mapa estructural completo del proyecto (7 clases Apex, 5 LWC, 2 objetos, 15 campos en `Donation__c`).
- Comparación directa de 24 issues GitHub (v1 vs v2) identificando los cambios de la sesión de Q&A (#17).
- Gap analysis con 16 brechas por capa: datos, lógica Apex, UI LWC y configuración.
- Plan de 11 tareas aprobado por el equipo e implementado en la misma sesión.

#### 3. Cambios implementados
| Tarea | Descripción |
| --- | --- |
| T-01 | Campos CFDI 4.0: `Postal_Code__c`, `Tax_Regime__c`, `CFDI_Use__c` en `Donation__c` |
| T-02 | Desacople anonimato/factura: desactivar `Anonymous_Cannot_Invoice`, actualizar `donationForm` |
| T-03 | Contador de donantes anónimos en `donorWall` y `PublicCampaignController` |
| T-04 | Campos `Expiration_Date__c` y `Allow_Additional_Donations__c` en `Campaign__c` + lógica de bloqueo en Apex |
| T-05 | Auto-redirect en `campaignCatalog` cuando hay una sola campaña activa |
| T-06 | Email de soporte en `donationThankYou`; desglose fiscal CFDI 4.0 en recibo de `DonationManagementService` |
| T-07 | Nuevo `DonationExpirationService` (Schedulable + Batchable) para cancelar donaciones pendientes viejas |
| T-08 | `docs/backlog.md` actualizado con estados Cumplida/En Progreso y evidencias de commit |
| T-09 | `README.md` con tabla de progreso E1/E2 y enlace al backlog |

#### 4. Hallazgos relevantes
- **Cambio más significativo entre v1 y v2:** La independencia entre anonimato público y datos fiscales (US-D2/US-F1). La v1 los hace mutuamente excluyentes; la v2 los desacopla. La validation rule `Anonymous_Cannot_Invoice` fue desactivada.
- **Cambio de datos más grande:** US-F1 escala de 2 campos (RFC, Razón Social) a 5 campos CFDI 4.0, requiriendo 3 campos nuevos en `Donation__c`.
- **Cambio de lógica de campaña:** US-S1 agrega control de expiración y de meta al 100% con flag de override; `Campaign__c` recibió 2 campos nuevos.
- Se excluyeron del plan las historias de E2 relacionadas con integración de pagos (webhooks) por instrucción explícita del equipo.

#### 5. Aceleración estimada
* **Estimación sin IA:** 10–14 horas para auditoría manual + implementación de todos los cambios.
* **Tiempo real con IA:** Aproximadamente 45 minutos (auditoría, plan e implementación completa).
* **Ahorro estimado:** ~95% en la fase de auditoría y alineación de backlog.

---

### Entrada 03: Diagnóstico de visibilidad de campañas en el sitio público de Salesforce

* **Fecha:** 17 de noviembre de 2026
* **Autor:** José Ceballos
* **Herramienta:** Antigravity (Gemini)
* **Historia(s) Relacionada(s):** US-D1, US-V2 (RF-D1a, RF-V1, RF-V2, M2)
* **Hito:** Entrega 1

#### 1. Qué se pidió
> *"Revisa este codigo y dime por qué no se ven las campañas en la página publica desplegada en Salesforce?"*

#### 2. Qué se obtuvo
Diagnóstico detallado de la capa LWC, Apex, permisos y metadatos del sitio público:
* Revisión de `PublicCampaignController.cls`, `campaignCatalog.js`, `campaignCatalog.html`, `Donation_Public_Guest.permissionset-meta.xml`, `Campaign__c.sharingRules-meta.xml` y `Campaign__c.object-meta.xml`.
* Identificación de las causas posibles según el mensaje mostrado en pantalla: falta de asignación del Permission Set `Donation_Public_Guest` / acceso Apex al Guest User del sitio, confusión entre el objeto estándar `Campaign` y el objeto personalizado `Campaign__c`, configuración manual pendiente en Experience Builder (*Public Access* y *Publish*), FLS incompleto en `Donation_Public_Guest`, regla de compartición atada al nombre `Donaciones_Mexico_Dreamin` y `manifest/package.xml` desactualizado.

#### 3. Qué se verificó y cómo
* Se contrastaron los hallazgos directamente contra los archivos de metadatos en `salesforce/force-app/` y contra `docs/seguridad.md` y `docs/e1-implementation-status.md`.
* Posteriormente, al revisar `ai-backlog-10-11-2026.md`, se confirmó que la causa exacta observada en la org era el bloqueo HTTP 400 en `/webruntime/api/apex/execute` por faltar habilitar **Allow guest users to access public APIs** en *Experience Workspaces → Administration → Preferences*.

#### 4. Qué se corrigió / Errores detectados de la IA
* **Hallazgo:** La primera revisión se enfocó únicamente en código/metadatos dentro de `salesforce/force-app/` sin haber leído aún `ai-backlog-10-11-2026.md` en la raíz del repositorio.
* **Corrección:** Al incorporar la lectura de `ai-backlog-10-11-2026.md` en el siguiente paso, se precisó el diagnóstico con la evidencia del trace de navegador (HTTP 400 y la preferencia faltante en Experience Workspaces).

#### 5. Aceleración estimada
* **Estimación sin IA:** 1.5 a 2 horas de revisión cruzada entre LWC, Apex, Permission Sets, Sharing Rules y documentación.
* **Tiempo real con IA:** Aproximadamente 5 minutos.
* **Ahorro estimado:** ~95% en la fase de diagnóstico.

---

### Entrada 04: Análisis de brechas para Entrega 2 contra el PDF de lineamientos

* **Fecha:** 17 de noviembre de 2026
* **Autor:** José Ceballos
* **Herramienta:** Antigravity (Gemini)
* **Historia(s) Relacionada(s):** US-D1b, US-D5, US-V3, US-S4 (RF-D1b, RF-D5, RF-S4, RF-V3a, RF-V3b, M1–M3, C1–C9)
* **Hito:** Entrega 2

#### 1. Qué se pidió
> *"¿Y cuáles serían los puntos para completar la entrega 2? Valida el archivo `Proyecto_ Donaciones para Mexico Dreamin — Lineamientos.pdf`"*

#### 2. Qué se obtuvo
Inventario completo de brechas técnicas y documentales para completar la Entrega 2:
* **Pendientes operativos de E1:** habilitar *Allow guest users to access public APIs*, configurar `Stripe_Test` y el envío de correos.
* **Pendientes técnicos de E2:** validación de monto mínimo ($10.00 MXN) en `donationForm` y `PublicDonationController`, creación de endpoint `@RestResource` para webhooks de Stripe (`RF-V3a` / `RF-D5`), verificación HMAC-SHA256 de `Stripe-Signature` e idempotencia (`RF-V3b`), registro de fuente de confirmación y bitácora de avisos rechazados (`RF-S4`), pruebas Apex y ejecución de Salesforce Code Analyzer (`C6`).
* **Pendientes documentales y de entrega:** actualización de `README.md`, `docs/backlog.md`, `docs/seguridad.md`, `docs/bitacora_ia.md`, `docs/contribucion.md`, creación de `docs/preguntas_y_reportes.md`, etiqueta `entrega-2` y preparación de defensa oral.

#### 3. Qué se verificó y cómo
* Se revisó íntegramente el PDF de 20 páginas (`Proyecto_ Donaciones para Mexico Dreamin — Lineamientos.pdf`), incluyendo la tabla de requisitos funcionales, mínimos obligatorios (M1–M3), formatos mínimos de entregables y la rúbrica (C1–C9).
* Se validó cada punto contra los archivos reales existentes en `docs/` y `salesforce/force-app/`.

#### 4. Qué se corrigió / Errores detectados de la IA
* Sin errores detectados: se identificó que `docs/preguntas_y_reportes.md` aún no existía en `docs/` y que en `README.md` figuraba con un nombre distinto (`docs/registro_preguntas.md`).

#### 5. Aceleración estimada
* **Estimación sin IA:** 2 a 3 horas de auditoría manual entre el PDF de lineamientos, la rúbrica y todo el repositorio.
* **Tiempo real con IA:** Aproximadamente 10 minutos.
* **Ahorro estimado:** ~93% en la planificación y detección de brechas de E2.

---

### Entrada 05: Cierre documental de Entrega 1 en `docs/backlog.md` y `README.md`

* **Fecha:** 17 de noviembre de 2026
* **Autor:** José Ceballos
* **Herramienta:** Antigravity (Gemini)
* **Historia(s) Relacionada(s):** US-D1 a US-V2 (E1)
* **Hito:** Entrega 1

#### 1. Qué se pidió
> *"Actualiza `docs/backlog.md` con los cambios necesarios para que se vea que concluimos la entrega 1"*  
> *"Actualiza el `README.md`"*

#### 2. Qué se obtuvo
* En `docs/backlog.md`: actualización del resumen de avance (`10/10` = `100%` en E1 y `10/14` = `71%` acumulado), cambio de estado de `Pendiente` / `En progreso` a `Cumplida` / `Completada (E1)` en el tablero, estado técnico y especificaciones de `US-D1` a `US-V2`, con enlaces reales al video demo (`https://youtu.be/_o0NqD-dlAc`), `docs/e1-implementation-status.md` y `docs/seguridad.md`.
* En `README.md`: incorporación de la URL pública del sitio Experience Cloud, enlace directo a la sección de clasificación de datos personales en `docs/seguridad.md` y corrección de la referencia al archivo `docs/preguntas_y_reportes.md`.

#### 3. Qué se verificó y cómo
* Se ejecutó `git diff` sobre `docs/backlog.md` y `README.md` para comprobar la consistencia de porcentajes (`100%` E1, `71%` total) y que todos los enlaces apuntaran a archivos o URLs reales del proyecto.

#### 4. Qué se corrigió / Errores detectados de la IA
* **Ajuste aplicado:** Se evitó crear un enlace roto en `README.md` hacia `docs/registro_preguntas.md` y se dejó explicitado que `docs/preguntas_y_reportes.md` (nombre exigido por el PDF) queda pendiente de creación para E2.

#### 5. Aceleración estimada
* **Estimación sin IA:** 30 a 45 minutos editando manualmente las 10 historias y validando enlaces entre documentos.
* **Tiempo real con IA:** Aproximadamente 5 minutos.
* **Ahorro estimado:** ~88% en la actualización documental.

---
