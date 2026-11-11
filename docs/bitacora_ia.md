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
