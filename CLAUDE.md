# CLAUDE.md — Donaciones Mexico Dreamin

Este archivo define el flujo de trabajo obligatorio para implementar cualquier funcionalidad nueva en este proyecto. Seguirlo en orden es obligatorio; no saltar pasos ni implementar sin autorización explícita del usuario.

---

## Proyecto

Portal de donaciones para Mexico Dreamin construido sobre Salesforce (LWC + Apex).

- **Repositorio:** `JoseMcebUAD/Donaciones-Mexico-Dreamin`
- **Rama principal:** `main`
- **Rama de trabajo activa:** ver `git branch`
- **Issues de GitHub:** etiquetas `E1`, `E2`, etc. por épica

### Objetos principales

| Objeto | Propósito |
|---|---|
| `Campaign__c` | Campañas de donación activas |
| `Donation__c` | Registro de cada donativo |
| `Donor_Recognition__c` | Muro de reconocimiento público |

### Permission Sets

| Nombre | Aplica a |
|---|---|
| `Donation_Coordination` | Coordinadores internos |
| `Donation_Public_Guest` | Visitantes del portal público |

### Capas de código

- **`PublicCampaignReadService`** — SOQL con `WITH SYSTEM_MODE` para el portal público
- **`PublicCampaignController`** — DTO `CampaignView` expuesto al LWC público
- **`campaignCatalog`** — LWC raíz del portal público
- **`donationForm`** / **`donorWall`** — LWCs hijos del catálogo

---

## Flujo obligatorio para nuevas funcionalidades

### Paso 1 — Aclaración

Antes de cualquier análisis o código, pregunta si el usuario tiene dudas sobre el alcance, restricciones técnicas o dependencias con otras historias. No continúes si quedan ambigüedades importantes.

### Paso 2 — Historia de usuario

Construye la historia con este formato exacto:

```
Como <rol>,
quiero <acción>,
para que <beneficio>.
```

**Criterios de aceptación** — uno por comportamiento observable, formato:

```
Dado que soy <usuario>, cuando <acción>, entonces <resultado esperado>.
```

Reglas:
- Lenguaje de usuario final, sin mencionar campos, clases, objetos Salesforce ni detalles técnicos.
- Mínimo 5 criterios, máximo 10.
- No continúes al paso 3 sin que el usuario valide la historia.

### Paso 3 — Plan de implementación

Usa el agente `Plan` para generar el plan. El plan debe incluir:

- Archivos a **crear** (con propósito)
- Archivos a **modificar** (con el cambio específico)
- Orden de implementación numerado
- Notas de diseño relevantes (seguridad, acceso guest, sharing model)

No continúes al paso 4 sin confirmación explícita del usuario (`"continúa"`, `"aprobado"`, `"implementa"` o equivalente).

### Paso 4 — Pruebas

Antes de implementar, define qué pruebas Apex y/o Jest se crearán:

- Clases Apex: mínimo 3 métodos de test por servicio nuevo
- Cobertura mínima esperada: 85%
- Nombrado: `<ClaseProbada>Test.cls`

Incluir en el plan los casos positivos, negativos y de borde relevantes.

### Paso 5 — Autorización e implementación

**Esperar confirmación explícita del usuario antes de escribir cualquier archivo.**

Una vez autorizado:
- Implementar en el orden definido en el plan
- Marcar cada tarea completada al terminarla (no al final)
- No agregar lógica, campos ni componentes fuera del alcance aprobado

### Paso 6 — GitHub

Al terminar la implementación:

1. Crear o actualizar el issue en GitHub con la historia del Paso 2 (formato `US-<ID>: <título>`)
2. Etiqueta con la épica correspondiente (`E1`, `E2`, etc.)
3. Proporcionar al usuario el mensaje de commit siguiendo la convención:

```
<tipo>(US-<ID>): <descripción corta en inglés>

<descripción larga opcional explicando el por qué>
```

Tipos válidos: `feat`, `fix`, `refactor`, `test`, `chore`.

**No hacer push ni commit sin que el usuario lo solicite explícitamente.**

---

## Restricciones permanentes

- Nunca modificar el flujo de donación (`donationForm`, `Donation__c`, Stripe) sin confirmar con el usuario.
- Nunca exponer un LWC interno (`lightning__RecordPage`) en el portal público y viceversa.
- El portal público solo lee datos vía `PublicCampaignController` — nunca acceso directo desde el LWC.
- Siempre verificar que los cambios en `PublicCampaignReadService` no rompan el acceso guest (usar `WITH SYSTEM_MODE`).
- No agregar permisos al permission set `Donation_Public_Guest` sin análisis de seguridad explícito.
