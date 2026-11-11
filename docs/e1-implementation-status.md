# Estado de implementación — Entrega 1

| Historias | Estado de código | Evidencia técnica |
| --- | --- | --- |
| US-01 a US-05 | Implementadas, pendientes de validación en org | `Campaign__c`, catálogo LWC, Stripe Test Checkout, retorno seguro y muro |
| US-06 | Implementada, pendiente de validación en org | validaciones de RFC/factura y campos fiscales |
| US-07 a US-09 | Implementadas, pendientes de configuración/despliegue | permission sets, lista de registros y acción Confirm Payment |
| US-10 | Implementación documentada, pendiente de configuración manual | controles Guest User descritos en `seguridad.md` |

La validación técnica y el despliegue base ya se realizaron contra `jDiaz`. Experience Cloud, Stripe Test y envío de correo siguen requiriendo la configuración manual indicada en `seguridad.md`; no se simulan como evidencia de producción.

## Resultado de verificaciones (10-11 nov 2026)

- `sf project convert source --root-dir force-app`: correcto.
- `npm run lint`: correcto.
- `npm test`: sigue pendiente por una dependencia transitoria de Node 24; las pruebas Jest permanecen en el repositorio.
- Modelo de datos desplegado en `jDiaz`: `0Afaj00000r94h0CAA`.
- Código, LWC, pestañas y permission sets desplegados en `jDiaz`: `0Afaj00000r94sKCAQ`.
- Pruebas Apex dirigidas: 6/6 aprobadas; cobertura global reportada: 92% (`707aj00001RLfzzAAD`).
- Validación completa: 38 componentes y 6/6 pruebas aprobadas (`0Afaj00000r93JWCAY`).
