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
* **Autor:** Jesús Méndez
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
* **Autor:** Jesús Méndez
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
* **Autor:** Jesús Méndez
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
* **Autor:** Jesús Méndez
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

### Entrada 06: Validación de monto mínimo para Stripe (`$10.00 MXN`, US-D1b)

* **Fecha:** 17 de noviembre de 2026
* **Autor:** Jesús Méndez
* **Herramienta:** Antigravity (Gemini)
* **Historia(s) Relacionada(s):** US-D1b (RF-D1b)
* **Hito:** Entrega 2

#### 1. Qué se pidió
> *"Realiza el cambio del monto mínimo para STRIPE y documenta en `docs/bitacora_ia.md` también"*

#### 2. Qué se obtuvo
* Actualización de `salesforce/force-app/main/default/lwc/donationForm/donationForm.html` para exigir `min="10"`, `step="0.01"` y `message-when-range-underflow="El monto mínimo de donación es de $10.00 MXN."`.
* Actualización de `salesforce/force-app/main/default/classes/PublicDonationController.cls` agregando la constante `MIN_DONATION_AMOUNT_MXN = 10.00` y validando en `validate()` que el importe sea mayor o igual a `$10.00 MXN`.
* Nuevas pruebas unitarias en `PublicDonationControllerTest.cls` (`rejectsAmountBelowStripeMinimum` y `acceptsCustomAmountAtStripeMinimum`) y en `donationForm.test.js`.

#### 3. Qué se verificó y cómo
* Se revisó el diff de los archivos modificados (`donationForm.html`, `donationForm.test.js`, `PublicDonationController.cls`, `PublicDonationControllerTest.cls`) para confirmar la consistencia de la regla `>= $10.00 MXN` en frontend y backend y mensajes en español alineados con `US-D1b`.
* Se intentó ejecutar `npm run lint` y `npm test` en `salesforce/`, constatando que `node_modules` no está instalado en este entorno local (`eslint` no reconocido), por lo que la ejecución de Jest y el deploy/Apex tests en la org quedan pendientes tras `npm install` y `sf org login web`.

#### 4. Qué se corrigió / Errores detectados de la IA
* **Ajuste aplicado:** Se mantuvo intacta la regla de validación de objeto `Amount_Must_Be_Positive` (`Amount__c <= 0`) para no acoplar la restricción de la pasarela Stripe MXN (`$10.00`) a registros internos de `Donation__c`, aplicando la regla en la capa de entrada pública (LWC + controlador Apex).

#### 5. Aceleración estimada
* **Estimación sin IA:** 45 a 60 minutos modificando UI, controlador Apex, pruebas unitarias y bitácora.
* **Tiempo real con IA:** Aproximadamente 5 minutos.
* **Ahorro estimado:** ~90% en implementación y pruebas.

---

### Entrada 07: Pruebas previas al despliegue en sandbox `mi-org` (LWC Jest, ESLint y Apex `RunLocalTests`)

* **Fecha:** 17 de noviembre de 2026
* **Autor:** Jesús Méndez
* **Herramienta:** Antigravity (Gemini)
* **Historia(s) Relacionada(s):** US-01 a US-10, US-D1b (validación integral pre-despliegue)
* **Hito:** Entrega 1 / Entrega 2

#### 1. Qué se pidió
> *"Realiza las pruebas y agrega el prompt a `docs/bitacora_ia.md` con autor 'Jesús Méndez'. Si son exitosas, intenta el despliegue y si funciona también documenta en el archivo bitacora"*

#### 2. Qué se obtuvo
Se ejecutaron las pruebas locales de frontend y la validación con pruebas Apex en la sandbox `mi-org`:
* **ESLint (`npm run lint` en `salesforce/`):** Sin errores (código 0).
* **Pruebas unitarias LWC (`npm test` / `sfdx-lwc-jest`):** **Fallaron** (2 de 2 suites fallidas; 1 prueba pasada, 3 fallidas de 4 totales):
  * `donationForm.test.js`: falló en `clears public recognition and invoice selections when made anonymous` (`TypeError: element.handleChange is not a function`) y en `enforces the Stripe minimum amount of 10 MXN on the amount input` (`amountInput` resultó `null`).
  * `campaignCatalog.test.js`: falló en `shows empty state when no public campaigns are returned` porque la aserción esperaba texto en inglés (`"There are no active campaigns at this time."`) mientras que el componente renderiza el mensaje en español (`"No hay campañas activas por el momento. Vuelve pronto."`).
* **Validación Apex en `mi-org` (`sf project deploy start --dry-run --test-level RunLocalTests --target-org mi-org`, Deploy ID `0Afbm00000oeSTsCAM`):**
  * **Metadatos:** `51/51 (100%)` componentes validados correctamente.
  * **Pruebas Apex:** **Fallaron** (`29` pasaron, `8` fallaron de `37` totales; cobertura promedio `51%`, por debajo del `75%` requerido).
  * **Errores en Apex Tests:**
    * `No such column 'Allow_Additional_Donations__c'` / `'Expiration_Date__c'` en `Campaign__c` y `'Payment_Status__c'` en `Donation__c` (`PublicDonationControllerTest`, `DonationManagementServiceTest`, `PublicCampaignControllerTest`).
    * `Operation failed due to fields being inaccessible on Sobject Campaign__c` (`DonationExpirationServiceTest`).
    * `System.QueryException: Variable does not exist: tmpVar1` en `PublicCampaignController.getRecognizedDonors` línea 71 (`PublicCampaignControllerTest.returnsOnlyRecognizedPaidDonors`).

#### 3. Qué se verificó y cómo
* Se verificaron los resultados directamente desde la salida de `npm run lint`, `npm test` (`sfdx-lwc-jest`) y `sf project deploy start --dry-run --test-level RunLocalTests --target-org mi-org`.
* Al no ser exitosas las pruebas (tanto Jest como `RunLocalTests`), **no se ejecutó el despliegue real** a `mi-org`, respetando la condición indicada en el prompt.

#### 4. Qué se corrigió / Errores detectados de la IA
* Sin modificaciones de código en esta interacción; quedaron identificados los bloqueos reales que impiden un despliegue con `RunLocalTests`:
  1. Falta de acceso FLS del usuario administrador que ejecuta los tests en `mi-org` sobre los campos nuevos (o necesidad de desplegar primero objetos/campos y asignar Permission Sets antes de correr tests, además de revisar `tmpVar1` en `PublicCampaignController.cls` línea 71).
  2. Pruebas unitarias Jest desactualizadas respecto al HTML/JS actual de `donationForm` y al texto en español de `campaignCatalog`.

#### 5. Aceleración estimada
* **Estimación sin IA:** 45 a 60 minutos ejecutando suites locales, validando en org, analizando trazas de error y documentando la bitácora.
* **Tiempo real con IA:** Aproximadamente 5 minutos.
* **Ahorro estimado:** ~90% en diagnóstico pre-despliegue y registro documental.

---

### Entrada 08: Corrección de pruebas LWC/Apex y despliegue exitoso en sandbox `mi-org`

* **Fecha:** 17 de noviembre de 2026
* **Autor:** Jesús Méndez
* **Herramienta:** Antigravity (Gemini)
* **Historia(s) Relacionada(s):** US-01 a US-10, US-D1b (despliegue integral y suite de pruebas)
* **Hito:** Entrega 1 / Entrega 2

#### 1. Qué se pidió
> *"/plan Revisa los test y dime cuales serían las correcciones necesarias."*  
> *"Adelante, también documenta los cambios que se tuvieron que hacer para que el despliegue fuese exitoso"*

#### 2. Qué se obtuvo
Se corrigieron las suites de pruebas locales y de Apex, logrando un despliegue exitoso completo en la sandbox `mi-org`:
* **Cambios en configuración de la org destino (`mi-org`):**
  1. Se habilitó **Digital Experiences** y se creó el sitio con el Guest User `Donaciones_Mexico_Dreamin` requerido por `Campaign__c.sharingRules-meta.xml`.
  2. Se cambió el idioma del usuario administrador desplegador de `es_MX` a `en_US` para que la Metadata API aceptara `<value>true</value>` en el criterio booleano de `Campaign__c.Active_Campaigns_for_Guests` (en español exigía `"Verdadero"` / `"Falso"`).
* **Cambios en pruebas LWC Jest:**
  1. `campaignCatalog.test.js`: se actualizó la aserción del estado vacío al mensaje real en español (`"No hay campañas activas por el momento. Vuelve pronto."`).
  2. `donationForm.test.js`: se reescribieron las pruebas para interactuar con el DOM en `shadowRoot` (eventos `change` y búsqueda por `input.name === 'amount'`), alineando la validación de `isAnonymous` con el desacople de factura de E1 v2 (solo desmarca/deshabilita `wantsRecognition` y conserva `needsInvoice`).
* **Cambios en pruebas Apex (tests autocontenidos):**
  1. Se creó `DonationTestDataFactory.cls` (+ `.cls-meta.xml`) para generar un usuario administrador de prueba con los Permission Sets `Donation_Coordination` y `Donation_Treasury` asignados.
  2. Se envolvieron las pruebas de `DonationExpirationServiceTest.cls`, `DonationManagementServiceTest.cls`, `PublicCampaignControllerTest.cls` y `PublicDonationControllerTest.cls` en `System.runAs(testUser)` para garantizar FLS sobre los campos nuevos incluso en orgs limpias.
* **Despliegue real exitoso (`sf project deploy start --test-level RunLocalTests --target-org mi-org`):**
  * **Deploy ID:** `0Afbm00000oemyoCAA`
  * **Estado:** `Succeeded` (`52/52` componentes desplegados).
  * **Pruebas Apex:** `37/37` pasando (`0` fallos).

#### 3. Qué se verificó y cómo
* `npm run lint` en `salesforce/`: 0 errores.
* `npm test` (`sfdx-lwc-jest`) en `salesforce/`: `2/2` suites, `4/4` pruebas pasando.
* `sf project deploy start --dry-run --test-level RunLocalTests --target-org mi-org` (`0Afbm00000oeSbvCAE`): `52/52` componentes y `37/37` pruebas Apex pasando.
* `sf project deploy start --test-level RunLocalTests --target-org mi-org` (`0Afbm00000oemyoCAA`): despliegue real confirmado con `Status: Succeeded`, `52/52` componentes y `37/37` pruebas Apex pasando.

#### 4. Qué se corrigió / Errores detectados de la IA
* En la primera actualización de `DonationExpirationServiceTest.cls` quedó fuera el método `testSchedulable()` sin `System.runAs(testUser)`, fallando en el primer `--dry-run` (`36/37`). Se corrigió agregando `System.runAs(testUser)` también en `testSchedulable()`, alcanzando `37/37`.

#### 5. Aceleración estimada
* **Estimación sin IA:** 3 a 4 horas depurando errores de `SharingGuestRule` por idioma/nickname, reescribiendo tests Jest con stubs LWC, añadiendo `System.runAs` con Permission Sets en Apex y ejecutando el despliegue.
* **Tiempo real con IA:** Aproximadamente 15 minutos.
* **Ahorro estimado:** ~92% en resolución de bloqueos de despliegue y estabilización de pruebas.

---

### Entrada 09: Asignación de Permission Sets y publicación del sitio `Donaciones_Mexico_Dreamin` en `mi-org`

* **Fecha:** 17 de noviembre de 2026
* **Autor:** Jesús Méndez
* **Herramienta:** Antigravity (Gemini)
* **Historia(s) Relacionada(s):** US-D1, US-V2 (RF-D1a, RF-V1, RF-V2, M2)
* **Hito:** Entrega 1 / Entrega 2

#### 1. Qué se pidió
> *"Podrías publicar el sitio por favor y haz los ajustes necesarios para el despliegue, también documenta eso en la bitacora de IA"*

#### 2. Qué se obtuvo
* **Asignación de Permission Sets en `mi-org`:**
  * Se asignó `Donation_Public_Guest` al Guest User del sitio (`donaciones_mexico_dreamin@00dbm0000191y5heau.org.force.com`).
  * Se asignó `Donation_Coordination` al usuario administrador (`jsvela111.cfef96266380@agentforce.com`).
* **Publicación del sitio Experience Cloud:**
  * Se ejecutó `sf community publish --name "Donaciones_Mexico_Dreamin" --target-org mi-org`.
  * **Network Id:** `0DBbm000006ClqvGAC`
  * **Job Id (`SiteTaskPublish`):** `08Pbm00001D0kJWEAZ` (estado `Running` en `BackgroundOperation`).
  * **URL publicada:** `https://orgfarm-4b855452bf-dev-ed.develop.my.site.com/DonacionesMexicoDreaminvforcesite`

#### 3. Qué se verificó y cómo
* Se consultaron `PermissionSetAssignment`, `Network`, `Site` y `BackgroundOperation` mediante `sf data query` en `mi-org` para confirmar la asignación de `Donation_Public_Guest` y el inicio del job `SiteTaskPublish` (`08Pbm00001D0kJWEAZ`).
* Se identificaron los pasos manuales de Experience Workspaces / Builder que quedan por completar en la interfaz web de `mi-org` (ya que el proyecto no versiona `ExperienceBundle`):
  1. Activar el sitio en **Experience Workspaces → Administration → Settings → Activate** (actualmente `UnderConstruction`).
  2. Habilitar **Allow guest users to access public APIs** en **Experience Workspaces → Administration → Preferences** y **Public Access** en Experience Builder.
  3. Colocar los LWC (`campaignCatalog`, `donationConfirmation`, `donationThankYou`) en las páginas correspondientes del sitio y volver a publicar.

#### 4. Qué se corrigió / Errores detectados de la IA
* Sin errores: se validó previamente que existían dos sitios en `mi-org` (`donaciones-dreamin` y `Donaciones_Mexico_Dreamin`), seleccionando `Donaciones_Mexico_Dreamin` por coincidir con la regla `Campaign__c.Active_Campaigns_for_Guests`.

#### 5. Aceleración estimada
* **Estimación sin IA:** 20 a 30 minutos buscando IDs de sitios/Guest Users, asignando permisos y publicando por CLI.
* **Tiempo real con IA:** Aproximadamente 2 minutos.
* **Ahorro estimado:** ~90% en configuración post-despliegue.

---

### Entrada 10: Plan de QA, ejecución automatizada y matriz de pruebas para `feat/US-D1` (`US-D1c`)

* **Fecha:** 17 de noviembre de 2026
* **Autor:** Jesús Méndez
* **Herramienta:** Antigravity (Gemini)
* **Historia(s) Relacionada(s):** US-D1, US-D1c
* **Hito:** Entrega 2

#### 1. Qué se pidió
> *"Genera un plan de QA para validar que la HU está correctamente implementada. Revisa cuál es el nombre de la rama, esa es la HU."*
> *"agrega esto a la bitacora en `docs/bitacora_ia.md`. También si quieres genera el md con las pruebas automatizadas y manuales tal cual la compartes acá"*

#### 2. Qué se obtuvo
* Inspección de la rama `feat/US-D1` (`8fe6427..HEAD`), identificando la implementación de `US-D1c` (`c-campaign-share`, integración en `c-campaign-catalog`, auto-selección por `?campaign=<id>`, refactor UI del botón `Apoyar esta causa` y pruebas Jest).
* Generación del documento `docs/qa-us-d1.md` con:
  * Resultados reales de la **Fase 1 (Pruebas Automatizadas Locales)**.
  * Matriz de pruebas manuales funcionales para **Fase 2 (`US-D1c`)**, **Fase 3 (Regresión `US-D1`)** y **Fase 4 (UI / Responsividad / Navegadores)**.

#### 3. Qué se verificó y cómo
* `npx sfdx-lwc-jest -- --verbose campaignShare` (en `salesforce/`): **PASS** (`10/10` pruebas unitarias en verde).
* `npm run test:unit` (en `salesforce/`): **FAIL** (código de salida `1`). `campaignCatalog.test.js` provoca un rechazo no controlado `TypeError: anchor.scrollIntoView is not a function` en `campaignCatalog.js:68:16` porque JSDOM no implementa `Element.prototype.scrollIntoView` ni existe guarda/mock en el test.
* `npm run lint` (en `salesforce/`): **FAIL** (código de salida `1`, `4` problemas: `3` errores y `1` warning):
  * `campaignCatalog.js:19:18` (`no-unused-vars`: `'_'`) y `52:9` (directiva `eslint-disable` sin uso).
  * `campaignShare.js:88:27` (`@lwc/lwc/no-async-operation`: `setTimeout`) y `106:18` (`no-unused-vars`: `'_'`).
* `npm run prettier:verify` (en `salesforce/`): **FAIL** (código de salida `1`, `118` archivos con diferencias de formato en el repositorio, incluidos los archivos nuevos/modificados de `US-D1c`).

#### 4. Qué se corrigió / Errores detectados por QA
* **Hallazgos reportados (sin modificar código fuente en esta sesión de QA):**
  1. **Bloqueante en Jest (`campaignCatalog.js:68`):** `anchor.scrollIntoView(...)` rompe la ejecución de `npm run test:unit` en JSDOM; requiere guarda (`if (typeof anchor.scrollIntoView === 'function')`) o mock en `campaignCatalog.test.js`.
  2. **Errores de ESLint:** Uso de `setTimeout` sin directiva en `campaignShare.js` y variables `catch (_)` no permitidas por `no-unused-vars` en `campaignCatalog.js` y `campaignShare.js`.
  3. **Accesibilidad pendiente de validar:** `campaignShare` implementa `role="dialog"` y `aria-modal="true"`, pero no cierra con la tecla `Escape`.

#### 5. Aceleración estimada
* **Estimación sin IA:** 40 a 60 minutos revisando el diff de la rama, ejecutando suites locales y redactando la matriz de pruebas QA + bitácora.
* **Tiempo real con IA:** Aproximadamente 5 minutos.
* **Ahorro estimado:** ~90% en análisis, ejecución automatizada y documentación QA.

---

### Entrada 11: Bugfix de ESLint y `scrollIntoView` en JSDOM para `feat/US-D1` (`US-D1c`)

* **Fecha:** 17 de noviembre de 2026
* **Autor:** Jesús Méndez
* **Herramienta:** Antigravity (Gemini)
* **Historia(s) Relacionada(s):** US-D1, US-D1c
* **Hito:** Entrega 2

#### 1. Qué se pidió
> *"Haz los cambios y genera un commit con el bugfix. ¿Estás 100% seguro de que no es cosa de mi org? Si sí, procede y entonces agrega la entrada a `docs/bitacora_ia.md` del bugfix"*

#### 2. Qué se obtuvo
* Corrección en `salesforce/force-app/main/default/lwc/campaignCatalog/campaignCatalog.js`:
  * Guarda defensiva `if (anchor && typeof anchor.scrollIntoView === 'function')` en `_scrollToDonationForm()` para evitar `TypeError` en JSDOM (`sfdx-lwc-jest`) donde `Element.prototype.scrollIntoView` no existe.
  * Cambio de `catch (_)` a `catch` y eliminación de la directiva `// eslint-disable-next-line @lwc/lwc/no-async-operation` sin uso.
* Corrección en `salesforce/force-app/main/default/lwc/campaignShare/campaignShare.js`:
  * Cambio de `catch (_)` a `catch` en `_fallbackCopy()`.
  * Directiva `// eslint-disable-next-line @lwc/lwc/no-async-operation` sobre `setTimeout` en `_showCopied()` (el temporizador ya se limpia en `closePopup()` y `disconnectedCallback()`).

#### 3. Qué se verificó y cómo
* `npm run lint` (en `salesforce/`): **PASS** (código de salida `0`, `0` errores y `0` warnings).
* `npm run test:unit` (en `salesforce/`):
  * `campaignCatalog.test.js`: **PASS**
  * `campaignShare.test.js`: **PASS**
  * `donationForm.test.js`: **FAIL** (`1` test fallido preexistente fuera de `US-D1c`: `enforces the Stripe minimum amount of 10 MXN on the amount input`, `amountInput` es `null`). Total: `2/3` suites en verde, `16/17` tests en verde.

#### 4. Qué se corrigió / Errores detectados de la IA
* **Confirmación de entorno:** Los fallos no provenían de la org de Salesforce sino del entorno local de pruebas/linting (`JSDOM` sin `scrollIntoView` y reglas estrictas de `@salesforce/eslint-config-lwc`).

#### 5. Aceleración estimada
* **Estimación sin IA:** 20 a 30 minutos diagnosticando, corrigiendo y re-ejecutando Jest/ESLint.
* **Tiempo real con IA:** Aproximadamente 3 minutos.
* **Ahorro estimado:** ~88% en corrección y verificación.

---

### Entrada 12: Validación QA, pruebas automatizadas y corrección de test en `refactor/post-feedback` (`US-R1`, `US-R2`)

* **Fecha:** 17 de noviembre de 2026
* **Autor:** Jesús Méndez
* **Herramienta:** Antigravity (Gemini)
* **Historia(s) Relacionada(s):** US-R1, US-R2
* **Hito:** Entrega 2 (Post-feedback)

#### 1. Qué se pidió
> *"Cambié de HU, válida esta nueva y ejecuta las pruebas automatizadas. Agrega también los resultados a `docs/bitacora_ia.md`"*

#### 2. Qué se obtuvo
* Revisión de los cambios de la rama `refactor/post-feedback` (`8fe6427..HEAD`):
  * `US-R1` (`f8d766e`): eliminación de `recognitionType` en `donationForm`, `donorWall`, `PublicCampaignController` y `PublicDonationController` (fijando `'Individual'` en `PublicDonationCommandService`).
  * `US-R2` (`8977d67`): reemplazo de URL de imagen por carga directa de archivo (`<= 2 MB`, Base64) en `donationForm` y publicación vía `ContentVersion` + `ContentDistribution` (`ContentDownloadUrl`) en `PublicDonationCommandService.publishDonorImage()`.
* Corrección en `salesforce/force-app/main/default/lwc/donationForm/__tests__/donationForm.test.js` del test preexistente `enforces the Stripe minimum amount of 10 MXN on the amount input`, cambiando `querySelector('lightning-input[name="amount"]')` por `querySelectorAll('lightning-input')[0]` tras `await flushPromises()`.

#### 3. Qué se verificó y cómo
* `npm run lint` (en `salesforce/`): **PASS** (`0` errores, `0` warnings).
* `npm run test:unit` (en `salesforce/`):
  * Antes del fix: `1` suite en verde (`campaignCatalog.test.js`) y `1` fallo preexistente en `donationForm.test.js` (`amountInput` era `null` porque el stub de `lightning-input` no refleja `name` como atributo HTML).
  * Después del fix: **PASS** — `2/2` suites (`campaignCatalog.test.js`, `donationForm.test.js`) y `4/4` tests en verde (`1.637 s`).
* `sf project deploy start -o mi-org --dry-run --test-level RunLocalTests --source-dir force-app` (Deploy ID `0Afbm00000oeoHTCAY` contra `mi-org` / `jsvela111.cfef96266380@agentforce.com`): **FAIL en compilación (9 componentes)**, por lo que las pruebas Apex no llegaron a ejecutarse (`Passing: 0, Failing: 0, Total: 0`):
  * **Fallo en `US-R2` (`PublicDonationCommandService.cls:71:14`):** `Variable does not exist: PreferencesAllowOriginalRelatedEntityDownload` (bloquea en cascada `PublicDonationCommandServiceTest`, `PublicDonationController` y `PublicDonationControllerTest`).
  * **Fallos preexistentes de `US-S5` (`CampaignImageService.cls`):** `Variable does not exist: PreferencesAllowOriginalRelatedEntityDownload (17:14)` y `No such column 'ContentDownloadUrl' on entity 'ContentVersion' (47:41)` (bloquea `CampaignImageServiceTest` y `campaignImageUpload`).
  * **Fallo preexistente de configuración (`Donation_Public_Guest`):** `Unable to find ExternalCredentialPrincipal: Stripe_Test_External-Stripe_Org_Principal`.

#### 4. Qué se corrigió / Errores detectados de la IA
* **Ajuste aplicado:** Se mantuvo sin cambios `handleImageChange` en `donationForm.js` al no presentar fallos en las pruebas y se corrigió únicamente el selector del stub en `donationForm.test.js`.

#### 5. Aceleración estimada
* **Estimación sin IA:** 30 a 45 minutos analizando el diff, ejecutando Jest/ESLint, corrigiendo el test y documentando en bitácora.
* **Tiempo real con IA:** Aproximadamente 4 minutos.
* **Ahorro estimado:** ~88% en validación QA y documentación.

---

### Entrada 13: Bugfix de `ContentDistribution` / SOQL y despliegue validado en `mi-org` (`refactor/post-feedback`)

* **Fecha:** 17 de noviembre de 2026
* **Autor:** Jesús Méndez
* **Herramienta:** Antigravity (Gemini)
* **Historia(s) Relacionada(s):** US-R1, US-R2, US-S5
* **Hito:** Entrega 2 (Post-feedback)

#### 1. Qué se pidió
> *"Realiza los cambios necesarios en el código y en mi org. Valida bien antes de todo y si funciona, genera el commit como bugfix y agrega a la `docs/bitacora_ia.md`"*

#### 2. Qué se obtuvo
* Corrección en `salesforce/force-app/main/default/classes/PublicDonationCommandService.cls` (línea 71): reemplazo de `PreferencesAllowOriginalRelatedEntityDownload` por `PreferencesAllowOriginalDownload` en `ContentDistribution`.
* Corrección en `salesforce/force-app/main/default/classes/CampaignImageService.cls`:
  * Línea 17: reemplazo de `PreferencesAllowOriginalRelatedEntityDownload` por `PreferencesAllowOriginalDownload`.
  * Líneas 47–50: eliminación de `ContentDocument.LatestPublishedVersion.ContentDownloadUrl` en el SOQL de `getCoverImages()` (campo no existente en `ContentVersion` y no utilizado en `ImageView`).
* Configuración en `mi-org` (`jsvela111.cfef96266380@agentforce.com`): creación de la `ExternalCredential` `Stripe_Test_External` con el principal `Stripe_Org_Principal` (Deploy ID `0Afbm00000ofdS1CAI`) para habilitar el despliegue de `Donation_Public_Guest`, seguida del despliegue de `force-app` (Deploy ID `0Afbm00000oeSwuCAE`).

#### 3. Qué se verificó y cómo
* `sf project deploy start -o mi-org --dry-run --test-level RunLocalTests --source-dir force-app` (Deploy ID `0Afbm00000ofFpWCAU`): **PASS** — `45/45` pruebas Apex locales en verde (`0` fallos).
* `sf project deploy start -o mi-org --source-dir force-app` (Deploy ID `0Afbm00000oeSwuCAE`): **Succeeded** (`100%`).
* `sf apex run test -o mi-org -n PublicDonationCommandServiceTest -n PublicCampaignControllerTest -n PublicDonationControllerTest -r human -w 10` (Test Run ID `707bm00001XCGHg`): **PASS** — `11/11` pruebas (`100%`).
* `npm run test:unit` y `npm run lint` (en `salesforce/`): **PASS** — `2/2` suites (`4/4` tests LWC Jest) y `0` errores de ESLint.

#### 4. Qué se corrigió / Errores detectados de la IA
* **Hallazgos corregidos:** `PreferencesAllowOriginalRelatedEntityDownload` no existe en `ContentDistribution` (el campo correcto es `PreferencesAllowOriginalDownload`) y `ContentDownloadUrl` pertenece a `ContentDistribution`, no a `ContentVersion`.

#### 5. Aceleración estimada
* **Estimación sin IA:** 40 a 60 minutos diagnosticando errores de metadata/SOQL, creando la External Credential en la org, desplegando y ejecutando todas las suites Apex y LWC.
* **Tiempo real con IA:** Aproximadamente 5 minutos.
* **Ahorro estimado:** ~90% en corrección, despliegue y validación integral.

---

### Entrada 14: Auditoría documental, diagrama ER, remediación de merge y corrida integral de QA (`feat-FAQ`)

* **Fecha:** 18 de noviembre de 2026
* **Autor:** Jesús Méndez
* **Herramienta:** Antigravity (Gemini + subagentes `sf-qa-validator` y `doc-er-auditor`)
* **Historia(s) Relacionada(s):** Todas (E1 y E2: `US-D1`–`US-S4`, `US-S5`, `US-D1c`, `US-R1`, `US-R2`, `US-UX1`, `US-UX2`, `issue-45`)
* **Hito:** Entrega 2

#### 1. Qué se pidió
> *"/plan Valida que toda la documentación sea correcta `docs/backlog.md`, `docs/seguridad.md`, `docs/bitacora_ia.md` y `docs/contribucion.md`. Así también realiza una vez más las pruebas de QA y mantén registro de ello en la `docs/bitacora_ia.md`. Así también analiza el proyecto y genera un diagrama ER. Si necesitas subagentes o skills para completar las tareas, genera la propuesta en el plan."*

#### 2. Qué se obtuvo
* **Remediación de regresiones post-merge y estabilización Apex/LWC en `feat-FAQ`:**
  * `salesforce/force-app/main/default/lwc/campaignCatalog/campaignCatalog.html`: corrección de etiquetas `<template>` / `<div>` / `<article>` duplicadas/desbalanceadas tras el merge `19c2f32` y restauración del estado vacío y `<c-donation-form>` junto con portada (`US-S5`), botón/popup `c-campaign-share` (`US-D1c`) y navegación `HOME`/`FAQ` (`US-UX1`).
  * `salesforce/force-app/main/default/lwc/donationForm/donationForm.js`: eliminación de los getters huérfanos `recognitionTypeOptions()` y `recognitionNameLabel()` (`RECOGNITION_TYPE_OPTIONS` eliminado en `US-R1`) y envío de `privacyAccepted` en `startDonation()`.
  * `salesforce/force-app/main/default/classes/PublicCampaignControllerTest.cls`: restauración de `Cover_Image_URL__c = 'https://example.test/cover.jpg'` en `@TestSetup`.
  * `salesforce/force-app/main/default/classes/ContactController.cls`: incorporación de helper `throwAuraException` con `ex.setMessage(message)` para que `AuraHandledException` exponga el mensaje exacto en pruebas unitarias Apex.
  * Persistencia completa de `Privacy_Accepted__c` (`issue-45`): agregado en `PublicDonationController.DonationRequest` / `validate()`, `PublicDonationCommandService.createPendingDonation()`, `Donation_Coordination.permissionset-meta.xml`, `PublicDonationControllerTest` (`rejectsMissingPrivacyAcceptance`) y `PublicDonationCommandServiceTest`.
* **Diagrama ER y diccionario de datos:** creación de `docs/modelo_datos_er.md` con diagrama Mermaid `erDiagram` verificado 1:1 contra los metadatos XML (`Campaign__c`, `Donation__c`, `Donor_Recognition__c`, `Case`, `ContentDocument`, `ContentVersion`, `ContentDocumentLink`, `ContentDistribution`), reglas de validación, trigger `DonationProjectionTrigger` y matriz OWD/Sharing.
* **Auditoría y alineación documental:**
  * `docs/backlog.md`: actualización de fecha, evidencias de `US-D1b`, confirmación de `US-D5`/`US-V3`/`US-S4` como pendientes (`11/14 = 79%` base RF) e incorporación de sección aparte (`3.1`) para funcionalidades adicionales implementadas en E2 (`US-S5`, `US-D1c`, `US-R1`, `US-R2`, `US-UX1`, `US-UX2`, `issue-45`).
  * `docs/seguridad.md`: corrección del patrón `with sharing` vs `without sharing` (`PublicDonationController`), corrección de permisos de `Donation_Public_Guest` (0 CRUD/FLS, 3 clases Apex incluyendo `ContactController`), inclusión de `Case`, `ContentDistribution` (`US-R2`), `CampaignImageService`, `DonationProjectionService`, `Privacy_Accepted__c` y exclusiones de `.forceignore`.
  * `docs/contribucion.md`: actualización a 8 clases Apex de prueba + `DonationTestDataFactory`, consolidación de cambios recientes bajo Entrega 2 y atribución correcta (`JoseMcebUAD` en `feat/US-D1` y `refactor/post-feedback`; `Jsvela749` en QA, bugfixes, merges `#46`/`#49`, `US-D1b`, documentación y diagrama ER).
  * `docs/bitacora_ia.md`: reconstrucción cronológica y renumeración completa de Entradas 07–14 eliminando los empalmes de merge previos.

#### 3. Qué se verificó y cómo
* **Línea base previa a los fixes (sobre `19c2f32`):**
  * `npm run lint` (`salesforce/`): **FAIL** (`donationForm.js:59:16` — `'RECOGNITION_TYPE_OPTIONS' is not defined`, `no-undef`).
  * `npm run test:unit` (`salesforce/`): **FAIL** (`campaignCatalog.test.js` no compiló por `LWC1058: Invalid HTML syntax`; `2/3` suites y `12/12` tests en las dos restantes).
  * `sf project deploy start --dry-run --test-level RunLocalTests --target-org mi-org --source-dir force-app` (Deploy ID `0Afbm00000ofs1FCAQ`): **FAIL** (`78/78` metadatos compilados; `44/48` pruebas Apex, `85.1%` cobertura — 4 fallos preexistentes en `PublicCampaignControllerTest` y `ContactControllerTest`).
* **Ejecución QA final y despliegue real en `mi-org` (post-fix):**
  * `npm run lint` (`salesforce/`): **PASS** (exit code `0`, `0` errores).
  * `npm run test:unit` (`salesforce/`): **PASS** — `3/3` suites (`campaignShare.test.js`, `donationForm.test.js`, `campaignCatalog.test.js`), `17/17` tests pasando (`1.916 s`).
  * `npm run prettier:verify` (`salesforce/`): **FAIL** (exit code `1`, `134` archivos con diferencias de formato preexistentes en el repositorio).
  * `sf project deploy start --dry-run --test-level RunLocalTests --target-org mi-org --source-dir force-app` (Deploy ID `0Afbm00000ofvK6CAI`): **PASS** — `78/78` componentes validados, **`49/49` pruebas Apex aprobadas** (`0` fallos, `30274 ms`).
  * `sf project deploy start --test-level RunLocalTests --target-org mi-org --source-dir force-app` (Deploy ID `0Afbm00000ofchGCAQ`, `2026-11-18T06:40:17.000Z`): **Succeeded** — `78/78` componentes desplegados (`97` archivos, `0` errores de componente), **`49/49` pruebas Apex aprobadas** (`22966 ms`), **cobertura global `85.25%`** (clases del proyecto entre `79.31%` y `100%`).
  * **Auditoría de secretos:** `git grep -i -E "sk_test_|sk_live_|whsec_"` y `git log -S "sk_test_" --oneline` → **PASS** (`0` claves reales expuestas; únicamente placeholders `sk_test_...` en documentación).

#### 4. Qué se corrigió / Errores detectados por QA
* Se repararon los bloqueantes de LWC (`campaignCatalog.html`, `donationForm.js`), los 4 fallos de Apex tests (`PublicCampaignControllerTest`, `ContactController`) y la persistencia de `Privacy_Accepted__c`, logrando validación y despliegue real exitoso al 100% en `mi-org`.
* Quedan únicamente como entregables funcionales/documentales de cierre E2: la creación de `docs/preguntas_y_reportes.md` y la implementación de `US-D5`, `US-V3` y `US-S4`.

#### 5. Aceleración estimada
* **Estimación sin IA:** 4 a 5 horas auditando metadatos, reparando merges en LWC/bitácora, ejecutando suites locales + SFDX dry-run, generando el diagrama ER y alineando 4 documentos.
* **Tiempo real con IA:** Aproximadamente 10 minutos (mediante orquestación paralela con 2 subagentes).
* **Ahorro estimado:** ~96% en auditoría documental, modelado ER y validación QA integral.

---

### Entrada 15: Publicación en `mi-org`, comparativa contra `entrega-2` y diagrama de infraestructura en `README.md` y `docs/modelo_datos_er.md`

* **Fecha:** 18 de noviembre de 2026
* **Autor:** Jesús Méndez
* **Herramienta:** Antigravity (Gemini)
* **Historia(s) Relacionada(s):** Todas (`feat-FAQ` / Entrega 2: `US-D1`–`US-V2`, `US-D1b`, `US-S5`, `US-D1c`, `US-R1`, `US-R2`, `US-UX1`, `US-UX2`, `issue-45`)
* **Hito:** Entrega 2

#### 1. Qué se pidió
> *"¿Está desplegado correctamente en mi-org? Sigo viendo la pantalla antigua"*  
> *"Valida `docs/modelo_datos_er.md` y hazlo más como un diagrama a grandes rasgos, pero que muestre la infraestructura completa, así como los puntos más importantes de cada elemento. Incluyendo el API de Stripe... también pon si son custom objects o objetos propios de salesforce"*  
> *"Mantenlo mejor en .md y agrega solo si son custom objects o objetos propios de salesforce"*  
> *"Incrusta el diagrama simplificado en el README.md y agrega la entrada en la bitacora de IA"*

#### 2. Qué se obtuvo
* **Diagnóstico y republicación de Experience Cloud en `mi-org`:**
  * Se comprobó que los bundles LWC (`campaignCatalog`, `campaignShare`, `donationForm`, `faqSection`) tenían `LastModifiedDate: 2026-11-18T06:39:44Z`, pero la última publicación del sitio (`08Pbm00001D0kJWEAZ`) era anterior (`04:05:52Z`).
  * Se ejecutó `sf community publish --name "Donaciones_Mexico_Dreamin" --target-org mi-org`, completando el job `08Pbm00001D2Rm3EAF` (`Status: Complete`, `2026-11-18T06:52:05Z`) sobre la URL `https://orgfarm-4b855452bf-dev-ed.develop.my.site.com/DonacionesMexicoDreaminvforcesite`.
* **Comparativa de ramas (`feat-FAQ` `0165f0f` vs `origin/entrega-2` `09c7afb`):**
  * Se identificó que `feat-FAQ` contiene 38 archivos bajo `salesforce/` (`+1,096 / -189` líneas) ausentes en `origin/entrega-2` (`US-D1c`, `US-R1`, `US-R2`, `US-UX1`, `US-UX2`, `issue-45`, fixes de sandbox y documentación validada), mientras que `origin/entrega-2` únicamente conserva `docs/index.html` y el enlace de la presentación E2.
* **Refinamiento del diagrama de infraestructura/ER y actualización de `README.md`:**
  * Se simplificó `docs/modelo_datos_er.md` incorporando un diagrama general Mermaid `flowchart LR` de extremo a extremo (Experience Cloud, Staff Interno, Capa Apex, `Named Credential: Stripe_Test` + Stripe Checkout API, y capa de datos con etiquetas explícitas `[Custom Object]` vs `[Objeto propio de Salesforce]`) junto al UML ER compacto (`Sección 1.1`) y la guía explicativa en 5 puntos.
  * Se incrustó dicho diagrama general en `README.md` (sección `## Arquitectura e Infraestructura`) y se actualizó `docs/stripe-test-setup.md` y la validación cruzada de enlaces en `README.md` y `docs/*.md`.

#### 3. Qué se verificó y cómo
* `sf data query` en `mi-org` (`Network`, `Site`, `LightningComponentBundle`, `BackgroundOperation` y `PermissionSetAssignment` del Guest User `005bm00000c5ly5AAA` con `Donation_Public_Guest`): confirmado `Live` y `Complete` tras la republicación `08Pbm00001D2Rm3EAF`.
* Validación de enlaces relativos Markdown en `README.md` y `docs/*.md`: `0` enlaces rotos.
* `git status -s` y `git diff --stat origin/entrega-2..HEAD -- salesforce/`: confirmada la consistencia de todos los archivos Markdown y eliminación del archivo temporal `.excalidraw`.

#### 4. Qué se corrigió / Errores detectados de la IA
* **Ajuste de formato y alcance:** Se generó inicialmente un archivo `.excalidraw` externo y se retiró de inmediato a solicitud del usuario para mantener la documentación de arquitectura 100 % en `.md` renderizable nativamente en GitHub.

#### 5. Aceleración estimada
* **Estimación sin IA:** 1.5 a 2 horas diagnosticando el caché de publicación en Experience Cloud, comparando ramas, diseñando el diagrama de infraestructura Mermaid y actualizando `README.md` + `docs/`.
* **Tiempo real con IA:** Aproximadamente 8 minutos.
* **Ahorro estimado:** ~92% en diagnóstico en org, arquitectura visual y documentación.

---

### Entrada 16: Auditoría contra lineamientos PDF, ejecución de Salesforce Code Analyzer y remediación de hallazgos `High` (`S14` / `C6`)

* **Fecha:** 18 de noviembre de 2026
* **Autor:** Jesús Méndez
* **Herramienta:** Antigravity (Gemini)
* **Historia(s) Relacionada(s):** Calidad técnica transversal (`S14`, `C6`, `C9`, `M2`) — `CampaignImageService`, `DonationManagementService`, `DonationProjectionService`, `Donation_Treasury`
* **Hito:** Entrega 2

#### 1. Qué se pidió
> *"Valida también `docs/contribucion.md` y valida si se cumplen todos los puntos establecidos en `Proyecto_ Donaciones para Mexico Dreamin — Lineamientos.pdf`, revisa si nos faltan documentos o funcionalidades"*  
> *"¿Podrías implementar el Code Analyzer y dar tus puntos de vista sobre los hallazgos? Genera lo que se solicita en el documento y agrega en la `docs/bitacora_ia.md`"*

#### 2. Qué se obtuvo
* **Auditoría completa contra el PDF de lineamientos:** identificación de brechas pendientes (`docs/preguntas_y_reportes.md` para E6/C7, tabla + horas en `docs/contribucion.md` para E4/C9, entradas de los 3 integrantes en `docs/bitacora_ia.md` para C3, etiqueta/video E2 y funcionalidades `RF-D5`/`RF-V3a`/`RF-V3b`/`RF-S4`).
* **Integración de Salesforce Code Analyzer (`code-analyzer@5.15.0`):**
  * Incorporación del script `"code-analyzer": "sf code-analyzer run --workspace force-app --rule-selector Recommended --view table"` en `salesforce/package.json`.
  * Creación de `docs/code_analyzer.md` con el inventario completo de hallazgos, remediaciones aplicadas y justificación técnica de cada regla pendiente (`S14` / `C6`).
* **Remediación de los 10 hallazgos `High` (`ApexCRUDViolation`) y 1 `Moderate` (`UnusedLocalVariable`):**
  * `CampaignImageService.cls`: añadidos `insert as user dist;` y `update as user campaign;` para consistencia total en `USER_MODE`.
  * `DonationManagementService.cls` y `Donation_Treasury.permissionset-meta.xml`: añadidos `WITH USER_MODE` / `update as user donation;` junto con la FLS de lectura de datos de recibo/CFDI para Tesorería.
  * `DonationProjectionService.cls`: explicitados `WITH SYSTEM_MODE` en consultas SOQL y `AccessLevel.SYSTEM_MODE` en operaciones DML del trigger.
  * `PublicDonationCommandServiceTest.cls`: eliminada variable local sin uso `donation`.

#### 3. Qué se verificó y cómo
* **Corrida inicial Code Analyzer:** `397` violaciones en `27` archivos (`10` High, `26` Moderate, `361` Low; `0` hallazgos en `retire-js`, `regex` y `cpd`).
* **Corrida post-fix Code Analyzer:** **`386` violaciones en `27` archivos (`0` High, `25` Moderate, `361` Low)**.
* `npm run lint` (`salesforce/`): **PASS** (`0` errores).
* `npm run test:unit` (`salesforce/`): **PASS** (`3/3` suites, `17/17` tests en `20.268 s`).
* `sf project deploy start --test-level RunLocalTests --target-org mi-org --source-dir force-app` (Deploy ID `0Afbm00000og5EdCAI`): **Succeeded** — `78/78` componentes desplegados y **`49/49` pruebas Apex aprobadas** (`0` fallos, `32540 ms`).

#### 4. Qué se corrigió / Errores detectados de la IA
* Sin errores de ejecución: al revisar el impacto de agregar `WITH USER_MODE` en `DonationManagementService.cls`, se detectó preventivamente que `Donation_Treasury.permissionset-meta.xml` carecía de FLS de lectura sobre los campos de correo/CFDI del comprobante, corrigiendo ambos archivos en conjunto para no romper el flujo real de Tesorería en orgs sin `Donation_Coordination`.

#### 5. Aceleración estimada
* **Estimación sin IA:** 2 a 3 horas configurando Code Analyzer, analizando 397 hallazgos, remediando modos CRUD/FLS + Permission Set, redactando justificaciones y validando el despliegue con `RunLocalTests`.
* **Tiempo real con IA:** Aproximadamente 6 minutos.
* **Ahorro estimado:** ~95% en análisis estático, remediación de seguridad y documentación `S14`.

---
