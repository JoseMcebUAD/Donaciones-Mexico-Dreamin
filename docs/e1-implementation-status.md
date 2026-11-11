# Estado de implementación — Entrega 1

| Historias | Estado de código | Evidencia técnica |
| --- | --- | --- |
| US-01 a US-05 | Implementadas, pendientes de validación en org | `Campaign__c`, catálogo LWC, Stripe Test Checkout, retorno seguro y muro |
| US-06 | Implementada, pendiente de validación en org | validaciones de RFC/factura y campos fiscales |
| US-07 a US-09 | Implementadas, pendientes de configuración/despliegue | permission sets, lista de registros y acción Confirm Payment |
| US-10 | Implementación documentada, pendiente de configuración manual | controles Guest User descritos en `seguridad.md` |

La validación técnica contra `jDiaz` está bloqueada hasta reautenticar la org. Experience Cloud, Stripe Test y envío de correo requieren la configuración manual indicada en `seguridad.md`; no se simulan como evidencia de producción.

## Resultado de verificaciones locales (10 nov 2026)

- `sf project convert source --root-dir force-app`: correcto.
- `npm run lint`: correcto.
- `npm test`: bloqueado por la dependencia transitoria `@nodelib/fs.scandir` faltante bajo Node 24 (`Cannot find module './providers/async'`). Reinstalar las dependencias con una versión LTS compatible antes de aceptar el PR.
- `sf project deploy validate --target-org jDiaz`: bloqueado por refresh token expirado; requiere `sf org login web --alias jDiaz`.
