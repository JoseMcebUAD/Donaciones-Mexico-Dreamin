# Documento de Seguridad, Permisos y Clasificación de Datos Personales

**Proyecto:** SF Vibe Lab — Portal de Donaciones para Mexico Dreamin  
**Programa:** SF Vibe Lab (UADY × Salesforce, Mérida)  
**Hito:** Entrega 1 y Entrega 2 (18 de noviembre de 2026)  
**Archivo:** `docs/seguridad.md`  
**Documentos relacionados:** [Modelo de Datos y ER](modelo_datos_er.md) · [Backlog](backlog.md) · [Contribución](contribucion.md)  
**Cumplimiento de Lineamientos:** Requisitos RF-V1, RF-V2, M1, M2, M3, OA5, OA6, C5.

1. Habilita My Domain y Digital Experiences y publica el sitio Experience Cloud.
2. Coloca `campaignCatalog` en la página pública principal y `donationThankYou` en la ruta de retorno (`/donaciones/thank-you` en la org `jDiaz`, o equivalente `/thank-you` / `/s/thank-you` según el path del sitio configurado). El Wall of Fame (`donorWall`) y la pestaña `FAQ` / contacto (`faqSection`) se integran dentro de `campaignCatalog`; no agregues un componente de muro separado.
3. Configura la External Credential (`Stripe_Test_External`) y Named Credential `Stripe_Test` hacia `https://api.stripe.com`. Guarda la clave de prueba `sk_test_...` sólo en la credencial protegida de la org.
4. Asigna el principal `Stripe_Test_External-Stripe_Org_Principal` en la org al Guest User del sitio (vía Permission Set `Donation Public Guest` o configuración local de la org) y al usuario interno que realizará pruebas. *(Nota: en `Donation_Public_Guest.permissionset-meta.xml`, el bloque `externalCredentialPrincipalAccesses` fue retirado del XML versionado en el commit `7d55eb2` para permitir despliegues en sandboxes limpias antes de crear la External Credential; debe vincularse manualmente en Setup).* No guardes ni muestres el secreto.
5. Define `Donation_Portal_Base_URL` con la URL pública sin barra final. En la org de E1 (`jDiaz`): `https://empathetic-narwhal-9eroye-dev-ed.trailblaze.my.site.com/donaciones`. En la sandbox de validación E2 (`mi-org`, sitio `Donaciones_Mexico_Dreamin`): `https://orgfarm-4b855452bf-dev-ed.develop.my.site.com/DonacionesMexicoDreaminvforcesite`.
6. No concedas al Guest User permisos directos de objeto (CRUD/FLS) sobre `Campaign__c`, `Donor_Recognition__c`, `Donation__c` ni `Case`. En `Donation_Public_Guest.permissionset-meta.xml` se autorizan **únicamente** las 3 clases Apex públicas: `PublicCampaignController`, `PublicDonationController` y `ContactController`.
7. `PublicCampaignController` expone únicamente campañas activas, meta, monto agregado, portada (`Cover_Image_URL__c`), contador anónimo y reconocimientos consentidos (`RecognizedDonorView`). Nunca consulta `Donation__c`.
8. `PublicDonationController` crea la donación controlada como `Pending` (`>= $10.00 MXN`) delegando en `PublicDonationCommandService`; Stripe recibe retornos construidos por el servidor (`successUrl` = `Donation_Portal_Base_URL + '/thank-you?session_id={CHECKOUT_SESSION_ID}'`), no URLs enviadas por el navegador.

## Patrón Apex público

Las clases `@AuraEnabled` públicas siguen dos variantes controladas según la operación:

- **`PublicCampaignController` y `ContactController`** usan `with sharing` y delegan la lectura/escritura privilegiada a servicios internos de propósito único con `without sharing` y consultas/DML explícitos en `SYSTEM_MODE`: `PublicCampaignReadService` (`WITH SYSTEM_MODE`) y `ContactCommandService` (`AccessLevel.SYSTEM_MODE`).
- **`PublicDonationController`** usa `without sharing` en el límite `@AuraEnabled` y delega las consultas de campaña activa, creación de donación `Pending` y publicación de imagen de reconocimiento a `PublicDonationCommandService` (`without sharing`, `WITH SYSTEM_MODE` y `AccessLevel.SYSTEM_MODE`).
- **Servicios internos de staff y automatización:** `CampaignImageService` (`with sharing`, `WITH USER_MODE`), `DonationManagementService` (`with sharing`) y `DonationExpirationService` (`with sharing`) respetan las reglas de compartición y permisos del usuario interno; por su parte, `DonationProjectionService` (invocado por `DonationProjectionTrigger`) usa `without sharing` para recalcular métricas agregadas en `Campaign__c` y sincronizar `Donor_Recognition__c`.

Este patrón es necesario porque las clases con API reciente aplican CRUD/FLS según el contexto del usuario y el Guest User no recibe permisos CRM directos en `Donation_Public_Guest`. Los servicios públicos seleccionan sólo campos permitidos, nunca exponen registros `Donation__c` ni `Case` al visitante, y devuelven únicamente DTOs sanitizados (`CampaignView`, `RecognizedDonorView`, `CheckoutResponse`) o `void`.
---

## 1. Prueba de Seguridad del Visitante sin Login (RF-V2, M2)

1. Abre `https://empathetic-narwhal-9eroye-dev-ed.trailblaze.my.site.com/donaciones/` en una ventana incógnito nueva.
2. Comprueba que aparecen sólo campañas activas, la meta, el total recaudado, los reconocimientos públicos y el contador anónimo.
3. Confirma en DevTools que `getActiveCampaigns` ya no devuelve HTTP 400 y que la respuesta no contiene RFC, correos, facturas ni registros `Donation__c`.
4. Inicia una donación de prueba. Stripe Test debe abrir y el retorno debe ser `/donaciones/thank-you?session_id=...`.
5. El retorno no confirma pago automáticamente: el registro queda `Pending` hasta la acción interna de Tesorería.
6. Como visitante, intenta acceder a un registro `Donation__c`: debe ser denegado y nunca debe existir un enlace público hacia él.
Esta prueba demuestra formalmente que un usuario visitante anónimo (*Guest User*) **no puede leer ni modificar donaciones de terceros**, cumpliendo con la política de mínimo privilegio (*Least Privilege*) tanto a nivel de interfaz de usuario como por vías programáticas directas.

### 1.1 Pasos para Reproducir la Prueba

Captura catálogo público, Checkout Test, retorno seguro, Wall of Fame, vistas internas y una prueba en incógnito. Nunca captures claves, RFC reales, correos reales ni URLs de sesiones Stripe.
#### Vía A: Interfaz Web Pública (Navegación en Incógnito)
1. Abrir una ventana nueva en modo incógnito en el navegador (sin sesión activa en Salesforce ni credenciales almacenadas).
2. Ingresar a la URL pública del portal Experience Cloud (en `jDiaz`: `/donaciones/`; o ruta equivalente `/s/` según plantilla Aura/LWR de la org).
3. **Verificación de navegación general:**
   * Navegar por el catálogo de campañas activas. Comprobar que solo se muestran los nombres, metas, portadas y montos acumulados de donaciones ya pagadas (`Payment_Status__c = 'Paid'`).
   * No existe ningún enlace, botón o lista en la navegación que permita consultar el historial de donaciones ni la lista de donantes anónimos.
4. **Verificación del Muro de Donantes (`donorWall`):**
   * Inspeccionar la sección de reconocimiento de la campaña.
   * Comprobar que únicamente se muestran los registros proyectados en `Donor_Recognition__c` con `Is_Public__c = true` (generados solo cuando `Payment_Status__c = 'Paid'`, `Wants_Recognition__c = true` e `Is_Anonymous__c = false`).
   * Verificar que solo se exponen el nombre público (`Display_Name__c`), la imagen opcional publicada (`Image_URL__c`) y el importe (`Amount__c`). En ningún elemento del DOM ni del componente se expone correo electrónico, RFC ni datos fiscales.
5. **Verificación de la página de agradecimiento (`/donaciones/thank-you` o `/s/thank-you`):**
   * Intentar navegar directamente a la página de agradecimiento o alterar el parámetro `session_id` en la URL.
   * La página muestra el agradecimiento genérico institucional y el correo de soporte (`soporte@mexicodreamin.com`), sin renderizar registros ajenos ni confirmar pagos no validados por Tesorería.

#### Vía B: Vía Programática / Inspección de Red y Llamadas de API
1. En la ventana de incógnito del portal público, abrir las **Herramientas de Desarrollador** del navegador (F12) y dirigirse a la pestaña **Consola** o **Red (Network)**.
2. **Intento de lectura directa de registros de donación vía Lightning Data Service o URL:**
   * Intentar forzar la navegación directa hacia un registro: ingresar en la barra de direcciones `<base_url>/donation/[Donation_Id]` o `<base_url>/detail/[Donation_Id]` (por ejemplo `/donaciones/detail/[Donation_Id]` o `/s/detail/[Donation_Id]`).
   * **Resultado observado:** Redirección a página de error 404 / "Página no encontrada" o acceso denegado.
3. **Intento de consulta/mutación a través del controlador Apex:**
   * Inspeccionar la llamada de red al método Aura `PublicCampaignController.getActiveCampaigns`.
   * En el payload de respuesta JSON, verificar que los objetos retornados corresponden exclusivamente a los DTOs `CampaignView` y `RecognizedDonorView` (anidado en `recognizedDonors`). Campos sensibles como `Donor_Email__c`, `Donor_Name__c`, `RFC__c`, `Postal_Code__c`, `Stripe_Session_Id__c` o `Checkout_Reference__c` no forman parte del tipo de retorno ni viajan en el payload de red.
4. **Intento de modificación no autorizada de donaciones:**
   * Como visitante sin login, intentar invocar cualquier método de modificación de donaciones (ej. marcar una donación como pagada).
   * La única clase de mutación de donaciones autorizada es `PublicDonationController.startDonation`, la cual **únicamente inserta** un nuevo registro en estado `Pending` con importe `>= $10.00 MXN` y campaña activa válida (más una segunda actualización interna inmediata de `Recognition_Image_URL__c` si el mismo donante adjuntó imagen). De forma análoga, `ContactController.createCase` únicamente inserta un `Case` nuevo con `Origin = 'Web'` y no devuelve el registro. No existen métodos expuestos al visitante que reciban un ID de donación existente para actualizar montos o alterar el estado a `Paid`.

### 1.2 Matriz de Resultados de la Prueba

| Vector de Prueba | Intento / Acción | Resultado Esperado | Resultado Obtenido | Estatus |
| :--- | :--- | :--- | :--- | :---: |
| **Lectura UI** | Navegar en portal sin sesión | Ver solo campañas activas y montos pagados. No ver datos de donantes anónimos ni datos privados. | Solo se listan campañas y donantes reconocidos sin datos sensibles. | **PASA** |
| **Lectura URL** | Acceso a `/s/donation/{id}` o detalle | Denegación de acceso / 404. | Salesforce bloquea la página (Guest User no tiene acceso al objeto). | **PASA** |
| **Lectura API** | Inspeccionar payloads Aura/LWC | Ningún campo fiscal, correo o ID privado en el JSON. | Payload contiene únicamente DTOs públicos filtrados. | **PASA** |
| **Modificación UI** | Intentar cambiar estado o donación | Sin controles de edición en la interfaz pública. | Interfaz no contiene formularios de edición. | **PASA** |
| **Modificación API** | Invocación de métodos Apex | Imposibilidad de actualizar registros existentes; `without sharing` restringido solo a `insert` pendiente. | No existe endpoint de actualización expuesto al perfil de invitado. | **PASA** |

---

## 2. Permisos del Visitante — Principio de Menor Privilegio (Least Privilege, S15)

El Permission Set `Donation_Public_Guest` (`Donation_Public_Guest.permissionset-meta.xml`) asignado al Guest User de Experience Cloud se configura bajo la política estricta de mínimo privilegio, sin otorgar permisos directos CRUD ni FLS sobre ningún objeto del modelo de datos:

| Componente / Objeto | Permiso en `Donation_Public_Guest` | Tipo de Acceso | Justificación Técnica |
| :--- | :---: | :--- | :--- |
| **Objeto `Campaign__c`** | **Ninguno (`None`)** | **0 CRUD / 0 FLS** en el Permission Set | La lectura pública se canaliza exclusivamente a través de `PublicCampaignController` -> `PublicCampaignReadService` (`without sharing`, `WITH SYSTEM_MODE`), exponiendo solo el DTO `CampaignView`. *(Existe `Campaign__c.sharingRules-meta.xml`, actualmente excluido en `.forceignore`).* |
| **Objeto `Donor_Recognition__c`** | **Ninguno (`None`)** | **0 CRUD / 0 FLS** en el Permission Set | La lectura del muro se canaliza vía `PublicCampaignReadService` (`WITH SYSTEM_MODE`), proyectando únicamente `RecognizedDonorView` (`displayName`, `imageUrl`, `amount`) sin exponer `Source_Donation__c`. *(Existe `Donor_Recognition__c.sharingRules-meta.xml`, excluido en `.forceignore`).* |
| **Objeto `Donation__c`** | **Ninguno (`None`)** | **0 CRUD / 0 FLS** en el Permission Set | Protege la integridad de las aportaciones y datos fiscales. La creación controlada en estado `Pending` se delega exclusivamente a `PublicDonationController` -> `PublicDonationCommandService` (`without sharing`, `AccessLevel.SYSTEM_MODE`). |
| **Objeto `Case`** | **Ninguno (`None`)** | **0 CRUD / 0 FLS** en el Permission Set | El visitante nunca puede leer ni editar casos. El formulario de contacto inserta un `Case` nuevo (`Origin = 'Web'`, `Status = 'New'`) vía `ContactController` -> `ContactCommandService` (`AccessLevel.SYSTEM_MODE`). |
| **Apex Class: `PublicCampaignController`** | **Habilitada** | Invocable por Guest User | Retorna DTOs sanitizados de campañas activas (`CampaignView`) y donantes reconocidos (`RecognizedDonorView`). |
| **Apex Class: `PublicDonationController`** | **Habilitada** | Invocable por Guest User | Valida montos (`>= $10.00 MXN`), vigencia/capacidad de campaña, datos fiscales, crea sesión en Stripe Checkout y registra la intención `Pending` (con imagen opcional vía `ContentVersion`/`ContentDistribution`). |
| **Apex Class: `ContactController`** | **Habilitada** | Invocable por Guest User | Valida nombre, correo (regex) y mensaje del formulario **Contáctanos** y delega la inserción del `Case` a `ContactCommandService`. |
| **Apex Class: `CampaignImageService`** | **Denegada** | Sin acceso a Guest User | Uso interno exclusivo de staff en `lightning__RecordPage` de `Campaign__c` (`with sharing`, `WITH USER_MODE`) para publicar imágenes de portada (`US-S5`). |
| **Apex Class: `DonationManagementService`** | **Denegada** | Sin acceso a Guest User | Uso interno exclusivo del staff (`with sharing`; confirmación manual de pago por Tesorería y emisión de comprobantes). |
| **Apex Class: `DonationExpirationService`** | **Denegada** | Sin acceso a Guest User | Proceso batch/schedulable interno (`with sharing`) para cancelar donaciones `Pending` con más de 24 horas. |
| **Servicios internos (`PublicCampaignReadService`, `PublicDonationCommandService`, `ContactCommandService`, `DonationProjectionService`)** | **Denegada** | Sin acceso directo desde `@AuraEnabled` / Guest | Clases de servicio internas invocadas únicamente desde controladores autorizados o desde `DonationProjectionTrigger`. |

### 2.1 Servicios Privilegiados, Sharing Rules y Exclusiones en `.forceignore`

1. **`ContactCommandService` (`without sharing`, `AccessLevel.SYSTEM_MODE`):** Inserta registros `Case` generados desde el LWC `faqSection` con `Subject = 'Contacto desde portal - ' + name`, `Origin = 'Web'` y `Status = 'New'`, sin requerir permisos CRUD/FLS sobre `Case` en el Guest User.
2. **`PublicDonationCommandService.publishDonorImage` (`without sharing`, `AccessLevel.SYSTEM_MODE`):** Al subir una imagen de reconocimiento (`US-R2`, `<= 2 MB`), crea un `ContentVersion` con `FirstPublishLocationId = donationId` y un `ContentDistribution` (`PreferencesAllowOriginalDownload = true`, `PreferencesPasswordRequired = false`), guardando únicamente la URL pública (`ContentDownloadUrl` o `DistributionPublicUrl`) en `Donation__c.Recognition_Image_URL__c`.
3. **`CampaignImageService` (`with sharing`, `WITH USER_MODE`):** Exclusivo para coordinadores internos desde `campaignImageUpload` (`lightning__RecordPage` en `Campaign__c`); consulta `ContentVersion` / `ContentDocumentLink`, crea `ContentDistribution` y actualiza `Campaign__c.Cover_Image_URL__c`.
4. **`DonationProjectionService` (`without sharing`):** Invocado por `DonationProjectionTrigger` (`after insert, after update, after delete, after undelete` en `Donation__c`). Recalcula `Raised_Amount__c` y `Anonymous_Donor_Count__c` en `Campaign__c` y sincroniza `Donor_Recognition__c` exclusivamente para donaciones con `Payment_Status__c = 'Paid'`.
5. **Reglas de compartición (`sharingRules`) y exclusiones en `salesforce/.forceignore`:**
   * `Campaign__c.sharingRules-meta.xml` (`Active_Campaigns_for_Guests`: comparte lectura donde `Is_Active__c = true` con `<guestUser>Donaciones_Mexico_Dreamin</guestUser>`).
   * `Donor_Recognition__c.sharingRules-meta.xml` (`Public_Recognitions_for_Guests`: comparte lectura donde `Is_Public__c = true` con `<guestUser>Donaciones_Mexico_Dreamin</guestUser>`).
   * `Case.assignmentRules-meta.xml` (`Portal_Contact_Assignment`: asigna casos con `Case.Origin = Web` al coordinador).
   * **Exclusiones actuales en `salesforce/.forceignore`:** `**/sharingRules/**` y `**/assignmentRules/**` están excluidos del despliegue automático hasta que en la org destino existan el sitio Experience Cloud (cuyo path determine el `<guestUser>` exacto) y el username real de sandbox (documentado en `PENDING_IMPLEMENTATIONS.md`). Mientras permanezcan excluidas, la lectura del portal público continúa operando de forma segura a través de `PublicCampaignReadService` (`WITH SYSTEM_MODE`).

---

## 3. Resguardo de Secretos de la Pasarela de Pago (Mínimo M3)

Para garantizar que ninguna clave secreta quede expuesta en el frontend, en el repositorio ni en el historial de control de versiones:

1. **Uso de Named Credentials / External Credentials en Salesforce:**
   * La clave secreta de prueba de Stripe (`sk_test_...`) reside **exclusivamente** dentro de la configuración protegida de Salesforce:
     * Nombre de la Credencial Externa / Named Credential: `Stripe_Test`
     * Endpoint seguro configurado: `https://api.stripe.com`
     * Autenticación: Cabecera HTTP `Authorization: Bearer {!$Credential.Password}` resguardada en el backend cifrado de Salesforce.
2. **Consumo seguro en Apex (`callout`):**
   * El servicio de llamada a la API (`StripeCheckoutService.cls`) invoca el endpoint abstracto:
     ```apex
     request.setEndpoint('callout:Stripe_Test/v1/checkout/sessions');
     ```
   * En ninguna línea de código Apex, archivo de metadatos versionado (`.xml`), variable JavaScript ni componente LWC se escribe o referencia la clave de Stripe.
3. **Comprobación de no exposición en el repositorio de Git:**
   * Se realizó una auditoría en código, metadatos y el historial de commits mediante escaneo de patrones (`git grep -n -E "sk_test_[0-9A-Za-z]{8,}|sk_live_|whsec_[0-9A-Za-z]{8,}"` y `git log -S "sk_test"`).
   * **Resultado:** Cero tokens reales expuestos (`NO_REAL_KEYS_FOUND`). La cadena `sk_test` únicamente aparece como marcador de ejemplo (`sk_test_...`) en archivos de documentación (`README.md`, `docs/seguridad.md`, `docs/bitacora_ia.md`). El repositorio público se encuentra 100 % libre de secretos reales de API.

---

## 4. Clasificación y Tratamiento de Datos Personales (OA6)

En apego a las buenas prácticas de privacidad (LFPDPPP) y los lineamientos del proyecto, se clasifican los datos recopilados durante los flujos públicos de donación y contacto (ver esquema completo en [Modelo de Datos y ER](modelo_datos_er.md)):

| Dato del Visitante / Donante | ¿Es Dato Personal? | ¿Se Guarda en Salesforce? | Justificación del Almacenamiento | ¿Quién Tiene Acceso? |
| :--- | :---: | :---: | :--- | :--- |
| **Nombre del donante (`Donation__c.Donor_Name__c`)** | **Sí** | Sí (salvo donación anónima) | Identificación de la aportación para emisión del comprobante y auditoría interna. En donaciones anónimas (`Is_Anonymous__c = true`), el campo queda vacío (`null`). | Coordinación y Tesorería en vista interna. Público solo si `Wants_Recognition__c = true` (proyectado en `Donor_Recognition__c.Display_Name__c`). |
| **Correo electrónico (`Donation__c.Donor_Email__c`)** | **Sí** | Sí | Canal indispensable para el envío del comprobante/recibo digital de la donación y contacto de soporte. | Coordinación y Tesorería interna. **Nunca** visible al visitante sin login. |
| **Nombre para reconocimiento (`Donation__c.Recognition_Name__c`)** | **Sí** | Sí (opcional) | Permitir al donante usar un seudónimo, nombre corporativo o nombre público para aparecer en el muro de donantes. | Público en el muro de reconocimiento (`Donor_Recognition__c.Display_Name__c`) si la donación está `Paid`. |
| **Imagen de reconocimiento (`Donation__c.Recognition_Image_URL__c`, `US-R2`)** | No sensible / Imagen | Sí (opcional, archivo `<= 2 MB`) | Sustituye la captura de URL externa (`US-R2`): el archivo subido en `donationForm` se guarda como `ContentVersion` ligado a la donación y se expone mediante `ContentDistribution.ContentDownloadUrl`. *(Nota `US-R1`: el campo `Recognition_Type__c` fue retirado del formulario público y del muro; internamente se fija en `'Individual'`).* | Público en el muro de reconocimiento (`Donor_Recognition__c.Image_URL__c`) si la donación está `Paid` y con consentimiento. |
| **Aceptación de aviso de privacidad (`Donation__c.Privacy_Accepted__c`, `issue-45`)** | Trazabilidad de consentimiento | Sí | Requisito LFPDPPP: `donationForm` exige marcar la casilla antes de avanzar a Stripe y muestra el aviso con derechos ARCO (`contactanos@mexicodreamin.com`). Se valida tanto en cliente (`donationForm.js`) como en servidor (`PublicDonationController.validate()`) y se persiste en `Donation__c.Privacy_Accepted__c` vía `PublicDonationCommandService`. | Coordinación y Tesorería interna (lectura en `Donation_Coordination`). |
| **Razón Social (`Donation__c.Legal_Name__c`)** | **Sí** | Sí (solo si solicita factura) | Requisito indispensable para la emisión de la factura fiscal simulada (CFDI 4.0). | Staff interno (Tesorería y Coordinación). Nunca público. |
| **RFC (`Donation__c.RFC__c`)** | **Sí** | Sí (solo si solicita factura) | Requisito de validez fiscal ante el SAT para la persona física o moral que solicita comprobante. | Staff interno (Tesorería y Coordinación). Nunca público. |
| **Código Postal fiscal (`Donation__c.Postal_Code__c`)** | **Sí** | Sí (solo si solicita factura) | Campo obligatorio según el estándar CFDI 4.0 para validación de domicilio fiscal. | Staff interno (Tesorería). Nunca público. |
| **Régimen Fiscal (`Donation__c.Tax_Regime__c`)** | No sensible | Sí (solo si solicita factura) | Catálogo fiscal del SAT aplicable a la persona física o moral para efectos de facturación. | Staff interno (Tesorería). |
| **Uso de CFDI (`Donation__c.CFDI_Use__c`)** | No sensible | Sí (solo si solicita factura) | Especificación del destino tributario del comprobante (ej. `D04 - Donativos`). | Staff interno (Tesorería). |
| **Contacto desde FAQ (`Case`: `SuppliedName`, `SuppliedEmail`, `Description`, `US-UX2`)** | **Sí** | Sí (al enviar formulario **Contáctanos**) | Atender dudas del visitante generando un caso interno (`Subject`, `Origin = 'Web'`, `Status = 'New'`). | Staff interno de coordinación/soporte. **Nunca** accesible al Guest User. |
| **Número de Tarjeta, CVC y Fecha de Vencimiento** | **Dato Financiero Crítico** | **NO (Nunca)** | **Principio de PCI-DSS:** Salesforce nunca captura ni almacena datos de tarjeta. El pago se procesa 100 % en la pasarela externa de Stripe mediante Stripe Checkout hosted page. | Exclusivo de Stripe (en modo de prueba). Inaccesible para Salesforce y desarrolladores. |

---

## 5. Riesgos Conocidos y Estrategias de Mitigación

1. **Riesgo de Spam y Aportaciones Maliciosas en Formulario Público:**
   * **Riesgo:** Un bot o usuario malintencionado podría enviar solicitudes automatizadas al formulario para saturar la base de datos de Salesforce con donaciones falsas.
   * **Mitigación documentada:** 
     * Las donaciones creadas desde el sitio nacen con estatus `Pending` y **no alteran** los fondos recaudados ni el porcentaje de avance de las campañas.
     * Se implementó el servicio programado `DonationExpirationService` (Schedulable Batch) que identifica periódicamente donaciones pendientes no pagadas que exceden la ventana de validez y las cancela automáticamente.
     * En el frontend se valida client-side y server-side que el monto sea un número estrictamente positivo y que el correo cuente con formato válido antes de procesar el callout hacia Stripe.
2. **Riesgo de Manipulación de Montos en Tránsito:**
   * **Riesgo:** Que un usuario intente alterar el importe a cobrar interceptando el parámetro de pago.
   * **Mitigación:** La sesión de pago de Stripe se crea en el servidor de Salesforce vía Apex con el monto exacto validado (`unit_amount`). El cliente solo recibe la URL de checkout generada por Stripe, impidiendo la manipulación del importe.
3. **Riesgo de Duplicidad en Confirmación Manual:**
   * **Riesgo:** Que staff de Tesorería confirme dos veces el mismo pago por error.
   * **Mitigación:** El método `confirmPayment` en `DonationManagementService` verifica previamente el estado; si la donación ya se encuentra `Paid`, lanza una excepción impidiendo duplicar el comprobante o sumar dos veces el monto a la campaña.

---

## 6. Configuración Manual en la Organización (Guía de Despliegue)

1. **Digital Experiences y Dominio:**
   * Habilitar My Domain y Digital Experiences en la org destino (`jDiaz` en E1 o sandbox `mi-org` en E2).
   * Crear y publicar el sitio Experience Cloud (`Donaciones_Mexico_Dreamin`, habilitando **Allow guest users to access public APIs** en *Experience Workspaces → Administration → Preferences* y **Public Access** en Experience Builder).
   * Ajustar el Custom Label `Donation_Portal_Base_URL` al dominio/path real del sitio publicado en esa org (sin barra final).
2. **Disposición de Componentes LWC:**
   * **Portal público — Página Principal (`/`):** colocar `campaignCatalog` (incluye `donorWall`, `campaignShare`, `donationForm` y `faqSection`).
   * **Portal público — Página de Retorno (`/donaciones/thank-you` en `jDiaz`, o `/thank-you` bajo el base path configurado en `Donation_Portal_Base_URL`):** colocar `donationThankYou`.
   * **Interfaz interna de Staff — Lightning Record Page de `Campaign__c`:** colocar `campaignImageUpload` (`US-S5`).
   * **Interfaz interna de Staff — Lightning Record Page de `Donation__c`:** añadir la acción rápida `donationConfirmation` (**Confirm Payment**).
3. **Configuración de External Credential y Named Credential `Stripe_Test`:**
   * La sandbox usa `Stripe_Test_External` (principal `Stripe_Org_Principal`) y `Stripe_Test` apuntando a `https://api.stripe.com`. La clave de prueba `sk_test_...` vive en un parámetro protegido de la External Credential; su cabecera HTTP Basic se genera con una fórmula, nunca se escribe en Apex ni en un Custom Label. El webhook entrante usa una configuración cifrada independiente, descrita en [stripe-test-setup.md](stripe-test-setup.md).
4. **Configuración del Guest User del Sitio (`Donation_Public_Guest`):**
   * Asignar el Permission Set `Donation_Public_Guest` al Guest User del sitio (sin permisos CRUD/FLS sobre objetos; habilita únicamente `PublicCampaignController`, `PublicDonationController` y `ContactController`).
   * Vincular manualmente en la org el principal de `Stripe_Test_External` al Permission Set o perfil necesario para invocar `callout:Stripe_Test`.
   * Cuando el sitio esté creado en la org, seguir los pasos de `PENDING_IMPLEMENTATIONS.md` para retirar `**/sharingRules/**` y `**/assignmentRules/**` de `salesforce/.forceignore` y desplegar las reglas restantes.
5. **Configuración de Permisos Internos de Staff:**
   * Asignar el Permission Set `Donation Coordination` (`Donation_Coordination`) al equipo de Coordinación.
   * Asignar el Permission Set `Donation Treasury` (`Donation_Treasury`) al equipo de Tesorería.
