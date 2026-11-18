# Implementaciones pendientes — Mexico Dreamin

Este archivo documenta las piezas que fueron **eliminadas, bloqueadas o dejadas para después** durante la implementación de E3 (FAQ, Contáctanos, Aviso de Privacidad). Está escrito para que un agente o desarrollador pueda retomarlas sin contexto previo.

---

## 1. SharingGuestRules — BLOQUEADO (archivos listos, excluidos del deploy)

**Qué hace:** Permite que el visitante anónimo (guest user) del portal público lea registros de `Campaign__c` y `Donor_Recognition__c` sin necesitar login.

**Estado:** Los archivos XML existen y están correctos, pero están excluidos del deploy en `.forceignore` porque cuando se crearon, el sitio de Experience Cloud no existía (no había guest user).

**Archivos involucrados:**
- `salesforce/force-app/main/default/sharingRules/Campaign__c.sharingRules-meta.xml`
- `salesforce/force-app/main/default/sharingRules/Donor_Recognition__c.sharingRules-meta.xml`

**Problema pendiente:** Ambos archivos referencian el guest user con el nombre `Donaciones_Mexico_Dreamin`. Ese nombre debe coincidir exactamente con el **URL path** del sitio de Experience Cloud. Si el sitio se creó con un path distinto (ej. `/donaciones`), el nombre del guest user será diferente.

**Pasos para retomar:**
1. En Setup → Digital Experiences → All Sites, abre el sitio y anota su **URL path** (ej. `Donaciones`).
2. El nombre del guest user tiene el formato: `<UrlPath>` (sin espacios, respetando mayúsculas).
3. Si el nombre es diferente a `Donaciones_Mexico_Dreamin`, actualiza el campo `<guestUser>` en ambos archivos XML.
4. En `.forceignore` (ruta: `salesforce/.forceignore`), elimina la línea `**/sharingRules/**`.
5. Ejecuta: `sf project deploy start --source-dir force-app --target-org mi-org-test`

---

## 2. AssignmentRules/Case — BLOQUEADO (archivo listo, excluido del deploy)

**Qué hace:** Asigna automáticamente al coordinador los Cases creados desde el formulario de Contáctanos (Origin = Web).

**Estado:** El archivo XML existe pero está excluido del deploy porque el email de asignación (`a20201556@alumnos.uady.mx`) no se encontró en el sandbox — Salesforce modifica el username al crear sandboxes.

**Archivo involucrado:**
- `salesforce/force-app/main/default/assignmentRules/Case.assignmentRules-meta.xml`

**Problema pendiente:** El username en sandbox tiene el formato `a20201556@resourceful-koala-nxwwid.com`, no `a20201556@alumnos.uady.mx`.

**Pasos para retomar:**
1. Consultar el username real en el sandbox:
   ```
   sf data query --query "SELECT Username FROM User WHERE Email = 'a20201556@alumnos.uady.mx'" --target-org mi-org-test
   ```
2. Actualizar el campo `<assignedTo>` en el XML con el username devuelto.
3. En `.forceignore`, eliminar la línea `**/assignmentRules/**`.
4. Ejecutar: `sf project deploy start --source-dir force-app --target-org mi-org-test`

**Alternativa más robusta:** Usar una Queue en lugar de un User, así no depende del username del sandbox.

---

## 3. AutoResponseRules/Case — ELIMINADO (hay que recrearlo)

**Qué hace:** Envía un correo de confirmación automático al visitante cuando envía el formulario de Contáctanos.

**Estado:** Los archivos fueron eliminados del proyecto porque requieren configuración previa en la org que no estaba disponible. No existe ningún archivo de este tipo en el repositorio.

**Prerrequisito obligatorio:** Configurar una **Org-Wide Email Address** en Setup → Email → Organization-Wide Addresses. Sin esto, el deploy falla con error de dirección `<senderAddress>` no verificada.

**Pasos para implementar:**
1. En Setup → Email → Organization-Wide Addresses, agregar y verificar un email (ej. `noreply@mexicodreamin.com`).
2. Crear el template de email en Salesforce (vía Setup o metadata).
3. Recrear el archivo `salesforce/force-app/main/default/autoResponseRules/Case.autoResponseRules-meta.xml` con esta estructura:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<AutoResponseRules xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Case</fullName>
    <autoResponseRule>
        <fullName>Portal_Contact_AutoResponse</fullName>
        <active>true</active>
        <ruleEntry>
            <criteriaItems>
                <field>Case.Origin</field>
                <operation>equals</operation>
                <value>Web</value>
            </criteriaItems>
            <senderName>Mexico Dreamin</senderName>
            <senderAddress>TU_EMAIL_VERIFICADO_AQUI</senderAddress>
            <template>unfiled$public/CaseAutoResponse</template>
        </ruleEntry>
    </autoResponseRule>
</AutoResponseRules>
```

4. Crear también el template en `salesforce/force-app/main/default/email/unfiled$public/CaseAutoResponse.email` (cuerpo del correo) y su `.email-meta.xml`.
5. Agregar `autoResponseRules/Case` a la lista de metadata del deploy.

---

## 4. Configuración manual del sitio Experience Cloud

**Qué hace:** Conecta el LWC `campaignCatalog` al portal público visible para cualquier visitante.

**Estado:** El sitio de Experience Cloud ya fue creado en el sandbox, pero aún falta configurarlo.

**Pasos pendientes (en Experience Builder):**
1. Abrir el sitio desde Setup → Digital Experiences → All Sites → **Builder**.
2. En la página principal (Home), arrastrar el componente `campaignCatalog` al canvas.
3. Asignar el **Permission Set** `Donation_Public_Guest` al guest user del sitio:
   - Setup → Digital Experiences → All Sites → **Administration** → Members → agregar el permission set.
4. Publicar el sitio con el botón **Publish**.

---

## 5. Lightning App interna para coordinadores — NO IMPLEMENTADO

**Qué hace:** Permite a los coordinadores de Mexico Dreamin crear y gestionar campañas, donaciones y casos desde la interfaz interna de Salesforce (no el portal público).

**Estado:** No existe ningún archivo de Lightning App en el proyecto. Actualmente se accede a los objetos por URL directa (`/lightning/o/Campaign__c/list`).

**Pasos para implementar:**
1. Crear el archivo `salesforce/force-app/main/default/applications/Mexico_Dreamin.app-meta.xml` con este contenido base:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CustomApplication xmlns="http://soap.sforce.com/2006/04/metadata">
    <defaultLandingTab>standard-Campaign__c</defaultLandingTab>
    <description>App interna para coordinadores de Mexico Dreamin</description>
    <isNavAutoTempTabsDisabled>false</isNavAutoTempTabsDisabled>
    <isNavPersonalizationDisabled>false</isNavPersonalizationDisabled>
    <label>Mexico Dreamin Admin</label>
    <navType>Standard</navType>
    <tabs>Campaign__c</tabs>
    <tabs>Donation__c</tabs>
    <tabs>standard-Case</tabs>
    <tabs>Donor_Recognition__c</tabs>
    <uiType>Lightning</uiType>
    <utilityBar>standard-utility-bar</utilityBar>
</CustomApplication>
```

2. Verificar que las tabs `Campaign__c.tab-meta.xml` y `Donation__c.tab-meta.xml` ya están en el proyecto (sí existen en `salesforce/force-app/main/default/tabs/`).
3. Deployar: `sf project deploy start --source-dir force-app --target-org mi-org-test`

---

## Resumen de cambios en .forceignore

Cuando se resuelvan los prerrequisitos de los puntos 1 y 2, eliminar estas dos líneas del archivo `salesforce/.forceignore`:

```
**/sharingRules/**
**/assignmentRules/**
```

Y hacer un deploy normal para que todo quede activo.
