# Documento de Seguridad, Permisos y Clasificación de Datos Personales

**Proyecto:** SF Vibe Lab — Portal de Donaciones para Mexico Dreamin  
**Programa:** SF Vibe Lab (UADY × Salesforce, Mérida)  
**Hito:** Entrega 1 (E1 - 10 de noviembre de 2026)  
**Archivo:** `docs/seguridad.md`  
**Cumplimiento de Lineamientos:** Requisitos RF-V1, RF-V2, M1, M2, M3, OA5, OA6, C5.

---

## 1. Prueba de Seguridad del Visitante sin Login (RF-V2, M2)

Esta prueba demuestra formalmente que un usuario visitante anónimo (*Guest User*) **no puede leer ni modificar donaciones de terceros**, cumpliendo con la política de mínimo privilegio (*Least Privilege*) tanto a nivel de interfaz de usuario como por vías programáticas directas.

### 1.1 Pasos para Reproducir la Prueba

#### Vía A: Interfaz Web Pública (Navegación en Incógnito)
1. Abrir una ventana nueva en modo incógnito en el navegador (sin sesión activa en Salesforce ni credenciales almacenadas).
2. Ingresar a la URL pública del portal Experience Cloud (`/s/`).
3. **Verificación de navegación general:**
   * Navegar por el catálogo de campañas activas. Comprobar que solo se muestran los nombres, metas y montos acumulados de donaciones ya pagadas (`Payment_Status__c = 'Paid'`).
   * No existe ningún enlace, botón o lista en la navegación que permita consultar el historial de donaciones ni la lista de donantes anónimos.
4. **Verificación del Muro de Donantes (`donorWall`):**
   * Inspeccionar la sección de reconocimiento de la campaña.
   * Comprobar que únicamente se muestran los registros con `Payment_Status__c = 'Paid'`, `Wants_Recognition__c = true` e `Is_Anonymous__c = false`.
   * Verificar que solo se exponen el nombre público (`Recognition_Name__c` o `Donor_Name__c`) y el importe. En ningún elemento del DOM ni del componente se expone correo electrónico, RFC ni datos fiscales.
5. **Verificación de la página de agradecimiento (`/s/thank-you`):**
   * Intentar navegar directamente a `/s/thank-you` o alterar el parámetro `session_id` en la URL.
   * La página muestra el agradecimiento genérico institucional y el correo de soporte, sin renderizar registros ajenos ni confirmar pagos no validados por Tesorería.

#### Vía B: Vía Programática / Inspección de Red y Llamadas de API
1. En la ventana de incógnito del portal público, abrir las **Herramientas de Desarrollador** del navegador (F12) y dirigirse a la pestaña **Consola** o **Red (Network)**.
2. **Intento de lectura directa de registros de donación vía Lightning Data Service o URL:**
   * Intentar forzar la navegación directa hacia un registro: ingresar en la barra de direcciones `https://empathetic-narwhal-9eroye-dev-ed.trailblaze.my.site.com/s/donation/[Donation_Id]` o `https://empathetic-narwhal-9eroye-dev-ed.trailblaze.my.site.com/s/detail/[Donation_Id]`.
   * **Resultado observado:** Redirección a página de error 404 / "Página no encontrada" o acceso denegado.
3. **Intento de consulta/mutación a través del controlador Apex:**
   * Inspeccionar las llamadas de red a los métodos Aura (`PublicCampaignController.getActiveCampaigns`, `PublicCampaignController.getRecognizedDonors`).
   * En el payload de respuesta JSON, verificar que los objetos retornados corresponden exclusivamente a los DTOs `CampaignView` y `RecognizedDonorView`. Campos sensibles como `Donor_Email__c`, `RFC__c`, `Postal_Code__c`, `Stripe_Session_Id__c` o `Checkout_Reference__c` no forman parte del tipo de retorno ni viajan en el payload de red.
4. **Intento de modificación no autorizada de donaciones:**
   * Como visitante sin login, intentar invocar cualquier método de modificación de donaciones (ej. marcar una donación como pagada).
   * La única clase de mutación autorizada es `PublicDonationController.startDonation`, la cual **únicamente inserta** un nuevo registro en estado `Pending` con importe positivo y campaña activa válida. No existen métodos expuestos al visitante que reciban un ID existente para actualizar montos o alterar el estado a `Paid`.

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

El perfil de invitado de Experience Cloud (*Site Guest User*) se configura bajo la política estricta de mínimo privilegio indispensable para operar la donación pública:

| Componente / Objeto | Permiso Otorgado | Tipo de Acceso | Justificación Técnica |
| :--- | :---: | :---: | :--- |
| **Objeto `Campaign__c`** | Lectura (`Read`) | FLS en campos públicos: `Name`, `Goal_Amount__c`, `Expiration_Date__c`, `Allow_Additional_Donations__c`, `Is_Active__c`. | Necesario para que el visitante conozca las causas activas y su meta antes de aportar. No se otorga Create, Edit ni Delete. |
| **Objeto `Donation__c`** | **Ninguno (`None`)** | Sin permisos CRUD (ni Read, ni Create, ni Edit, ni Delete). FLS denegado para todos los campos. | Protege la integridad de las aportaciones y datos fiscales. La creación de la donación inicial en estado `Pending` se delega exclusivamente a la lógica controlada del controlador Apex. |
| **Apex Class: `PublicCampaignController`** | Habilitada | Invocable por Guest User | Retorna DTOs sanitizados de campañas activas y donantes con consentimiento público (`getRecognizedDonors`). |
| **Apex Class: `PublicDonationController`** | Habilitada | Invocable por Guest User | Ejecuta la validación de montos, verificación de vigencia de campaña, registro de la intención `Pending` y redirección a Stripe Checkout. |
| **Apex Class: `DonationManagementService`** | **Denegada** | Sin acceso a Guest User | Uso interno exclusivo del staff (confirmación manual de pago por Tesorería y emisión de comprobantes). |
| **Apex Class: `DonationExpirationService`** | **Denegada** | Sin acceso a Guest User | Proceso batch desatendido del sistema para cancelar donaciones no pagadas. |

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
   * Se realizó una auditoría en el historial de commits mediante escaneo de patrones (`git log -S "sk_test"`, `git grep -i "sk_test"` y expresiones regulares de tokens de Stripe).
   * **Resultado:** Cero coincidencias. El historial del repositorio público en GitHub se encuentra 100% libre de secretos o tokens de API.

---

## 4. Clasificación y Tratamiento de Datos Personales (OA6)

En apego a las buenas prácticas de privacidad y los lineamientos del proyecto, se clasifican los datos recopilados durante el flujo de donación:

| Dato del Donante | ¿Es Dato Personal? | ¿Se Guarda en Salesforce? | Justificación del Almacenamiento | ¿Quién Tiene Acceso? |
| :--- | :---: | :---: | :--- | :--- |
| **Nombre del donante (`Donor_Name__c`)** | **Sí** | Sí (salvo donación anónima) | Identificación de la aportación para emisión del comprobante y auditoría interna. En donaciones anónimas (`Is_Anonymous__c = true`), el campo queda vacío (`null`). | Coordinación y Tesorería en vista interna. Público solo si `Wants_Recognition__c = true`. |
| **Correo electrónico (`Donor_Email__c`)** | **Sí** | Sí | Canal indispensable para el envío del comprobante/recibo digital de la donación y contacto de soporte. | Coordinación y Tesorería interna. **Nunca** visible al visitante sin login. |
| **Nombre para reconocimiento (`Recognition_Name__c`)** | **Sí** | Sí (opcional) | Permitir al donante usar un seudónimo, nombre corporativo o nombre público para aparecer en el muro de donantes. | Público en el muro de reconocimiento si la donación está pagada. |
| **Tipo de reconocimiento e imagen URL** | No sensible | Sí (opcional) | Agrupar por categoría (Individual / Empresa) y mostrar avatar corporativo en el muro. | Público en el muro de reconocimiento de la campaña. |
| **Razón Social (`Legal_Name__c`)** | **Sí** | Sí (solo si solicita factura) | Requisito indispensable para la emisión de la factura fiscal simulada (CFDI 4.0). | Staff interno (Tesorería y Coordinación). Nunca público. |
| **RFC (`RFC__c`)** | **Sí** | Sí (solo si solicita factura) | Requisito de validez fiscal ante el SAT para la persona física o moral que solicita comprobante. | Staff interno (Tesorería y Coordinación). Nunca público. |
| **Código Postal fiscal (`Postal_Code__c`)** | **Sí** | Sí (solo si solicita factura) | Campo obligatorio según el estándar CFDI 4.0 para validación de domicilio fiscal. | Staff interno (Tesorería). Nunca público. |
| **Régimen Fiscal (`Tax_Regime__c`)** | No sensible | Sí (solo si solicita factura) | Catálogo fiscal del SAT aplicable a la persona física o moral para efectos de facturación. | Staff interno (Tesorería). |
| **Uso de CFDI (`CFDI_Use__c`)** | No sensible | Sí (solo si solicita factura) | Especificación del destino tributario del comprobante (ej. Donativos, Gastos en general). | Staff interno (Tesorería). |
| **Número de Tarjeta, CVC y Fecha de Vencimiento** | **Dato Financiero Crítico** | **NO (Nunca)** | **Principio de PCI-DSS:** Salesforce nunca captura ni almacena datos de tarjeta. El pago se procesa 100% en la pasarela externa de Stripe mediante Stripe Checkout hosted page. | Exclusivo de Stripe (en modo de prueba). Inaccesible para Salesforce y desarrolladores. |

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
   * Habilitar My Domain y Digital Experiences en la org `jDiaz`.
   * Crear y publicar un sitio Experience Cloud (plantilla Build Your Own / LWR o Aura).
2. **Disposición de Componentes LWC en Experience Builder:**
   * Página Principal (`/`): colocar el componente `campaignCatalog`.
   * Página de Retorno (`/s/thank-you`): colocar el componente `donationThankYou`.
   * Página de Detalle o Sección de Campaña: colocar el componente `donorWall`.
3. **Configuración de Named Credential `Stripe_Test`:**
   * Crear Named Credential apuntando a `https://api.stripe.com` con la cabecera de autenticación Bearer Token conteniendo la clave de prueba de Stripe.
4. **Configuración del Perfil Guest User del Sitio:**
   * Conceder acceso de lectura al objeto `Campaign__c` y campos públicos.
   * No otorgar ningún permiso sobre `Donation__c`.
   * Otorgar acceso a las clases Apex `PublicCampaignController` y `PublicDonationController`.
5. **Configuración de Permisos Internos de Staff:**
   * Asignar el Permission Set `Donation Coordination` al equipo de Coordinación.
   * Asignar el Permission Set `Donation Treasury` al equipo de Tesorería.
   * Añadir el botón/acción rápida **Confirm Payment** en el Page Layout de `Donation__c`.
