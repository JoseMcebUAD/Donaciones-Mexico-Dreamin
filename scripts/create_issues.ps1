$gh = "C:\Program Files\GitHub CLI\gh.exe"
$repo = "JoseMcebUAD/Donaciones-Mexico-Dreamin"

# Crear labels
Write-Host "Creando labels..."
& $gh label create "E1" --description "Entrega 1 - 10 noviembre 2026" --color "0075ca" --repo $repo 2>$null
& $gh label create "E2" --description "Entrega 2 - 17 noviembre 2026" --color "e4e669" --repo $repo 2>$null

function New-Issue($title, $label, $body) {
    Write-Host "Creando: $title"
    $tmpFile = [System.IO.Path]::GetTempFileName()
    [System.IO.File]::WriteAllText($tmpFile, $body, [System.Text.Encoding]::UTF8)
    & $gh issue create --repo $repo --title $title --body-file $tmpFile --label $label
    Remove-Item $tmpFile
    Start-Sleep -Milliseconds 500
}

# US-D1
New-Issue "US-D1: Visualizacion publica de campanas y progreso financiero" "E1" @"
## Historia de Usuario
**RF que cubre:** RF-D1a, RF-V1
**Hito:** Entrega 1

**Como** donante potencial (visitante sin login),
**Quiero** elegir una campana activa y ver cuanto lleva recaudado de su meta,
**Para** decidir a cual iniciativa aportar sin requerir crear una cuenta.

---

## Criterios de Aceptacion

**CA1 (Criterio minimo):** Dado que existen al menos dos campanas activas con meta definida en Salesforce, cuando entro al sitio publico sin login, entonces veo cada campana con su nombre, su meta y su avance actual.

**CA2 (Criterio minimo):** Dado que una donacion de una campana pasa a estado Pagada y existe otra en Pendiente, cuando recargo el sitio publico, entonces el avance acumulado de esa campana suma unicamente el importe de la donacion pagada (las donaciones pendientes no cuentan para el avance).

**CA3 (Criterio minimo):** Dado que elegi una campana activa, cuando continuo al flujo de donacion, entonces puedo indicar el monto seleccionando una opcion de una lista de montos sugeridos o capturandolo en la pasarela.

**CA4 (Criterio propio - Salto con campana unica):** Dado que en la org existe unicamente una campana activa, cuando un visitante entra al sitio publico sin login, entonces el sitio omite la vista general de lista y presenta directamente la vista de detalle de esa campana para donar de inmediato.

**CA5 (Criterio propio / Negativo - Campana vencida o cerrada al 100%):** Dado que una campana tiene su fecha limite vencida o alcanzo el 100% de su meta y esta configurada para no admitir fondos adicionales, cuando un visitante intenta donar, entonces el sistema bloquea el formulario de donacion y muestra un mensaje indicando que la campana ya no recibe aportaciones.

---

## Estado
- [ ] Pendiente de implementacion
- Evidencia: [Enlace a demo/captura]
"@

# US-D2
New-Issue "US-D2: Donacion en modalidad Anonima" "E1" @"
## Historia de Usuario
**RF que cubre:** RF-D2, RF-D3, RF-D4
**Hito:** Entrega 1

**Como** donante anonimo,
**Quiero** realizar una aportacion sin que mi nombre aparezca en ningun lugar publico,
**Para** apoyar a los estudiantes protegiendo mi identidad y privacidad.

---

## Criterios de Aceptacion

**CA1 (Criterio minimo):** Dado que marque mi donacion como anonima, cuando reviso el sitio publico (pagina de campanas, muro de reconocimiento y pagina de agradecimiento), entonces mi nombre no aparece publicado y el importe aportado se suma al total acumulado de donantes anonimos (o se lista bajo la etiqueta "Donante anonimo").

**CA2 (Criterio minimo):** Dado que capture mi correo electronico (requerido para ticket) y mi donacion anonima esta en estado Pagada, cuando recibo el comprobante digital por correo, entonces el correo y su comprobante no muestran mi nombre personal y contienen el correo de soporte del programa.

**CA3 (Criterio minimo / Negativo - Desacoplamiento de factura):** Dado que elegi la modalidad puramente anonima sin capturar datos fiscales, cuando intento solicitar factura, entonces el sistema me impide proceder sin registrar RFC y datos tributarios; por el contrario, si selecciono factura pero marco la casilla independiente de no figurar en el muro publico, mis datos fiscales se guardan unicamente para control interno de tesoreria y mi nombre no se publica.

**CA4 (Criterio minimo):** Dado que existe una donacion anonima registrada en Salesforce, cuando el usuario de staff la consulta, entonces la visualiza claramente identificada bajo la modalidad anonima.

---

## Estado
- [ ] Pendiente de implementacion
- Evidencia: [Enlace a demo/captura]
"@

# US-D3
New-Issue "US-D3: Registro previo de donacion y control de expiracion" "E1" @"
## Historia de Usuario
**RF que cubre:** RF-D3, RF-V1
**Hito:** Entrega 1

**Como** donante en proceso de aportacion,
**Quiero** que mi intencion de donacion quede registrada en Salesforce antes de pagar en la pasarela,
**Para** garantizar la trazabilidad institucional y permitir conciliar el pago en cuanto sea procesado.

---

## Criterios de Aceptacion

**CA1 (Criterio minimo):** Dado que capture mis datos en el formulario publico (incluyendo correo electronico obligatorio) y seleccione una campana, cuando presiono el boton para proceder al pago, entonces se crea en Salesforce un registro de donacion en estado Pendiente con su campana, modalidad y monto antes de redirigir a la pasarela de prueba.

**CA2 (Criterio minimo):** Dado que envie el formulario y se genera la sesion en Stripe, cuando se inspecciona la pasarela, entonces el pago incluye un identificador de referencia univoco que permite a staff y al sistema vincular exactamente la transaccion con la donacion en Salesforce.

**CA3 (Criterio propio / Negativo - Expiracion de donacion abandonada):** Dado que un donante genera un registro en estado Pendiente pero abandona la ventana o la sesion en la pasarela caduca sin autorizacion bancaria, cuando la pasarela marca el intento como expirado o cancelado, entonces la donacion en Salesforce cambia a estado Cancelada/Expirada, evitando permanecer pendiente indefinidamente y sin sumar al avance de la campana.

---

## Estado
- [ ] Pendiente de implementacion
- Evidencia: [Enlace a demo/captura]
"@

# US-D4
New-Issue "US-D4: Retorno y pagina de agradecimiento con contacto de soporte" "E1" @"
## Historia de Usuario
**RF que cubre:** RF-D4
**Hito:** Entrega 1

**Como** donante que finalizo el flujo en la pasarela,
**Quiero** ver una pagina de agradecimiento con el contacto institucional de soporte,
**Para** tener certeza de que mi intento de donacion fue procesado y disponer de un canal de atencion en caso de aclaraciones.

---

## Criterios de Aceptacion

**CA1 (Criterio minimo):** Dado que complete el flujo de pago con tarjeta de prueba en Stripe, cuando la pasarela me devuelve a la pagina del portal, entonces veo una pagina de agradecimiento institucional.

**CA2 (Criterio minimo):** Dado que en la Entrega 1 el pago todavia no se confirma de manera automatica en Salesforce al momento del retorno, cuando veo la pagina de agradecimiento, entonces el mensaje no afirma falsamente que el pago esta confirmado de manera definitiva.

**CA3 (Criterio minimo):** Dado que me encuentro en la pagina de agradecimiento, cuando reviso la pantalla, parametros URL o consola del navegador, entonces no se expone informacion personal ni montos de otros donantes.

**CA4 (Criterio propio - Contacto de soporte visible en E1):** Dado que estoy en la pantalla de agradecimiento, cuando busco asistencia, entonces visualizo claramente el correo de soporte institucional del programa para resolver dudas sobre el donativo.

---

## Estado
- [ ] Pendiente de implementacion
- Evidencia: [Enlace a demo/captura]
"@

# US-C1
New-Issue "US-C1: Reconocimiento publico de aportaciones en campana" "E1" @"
## Historia de Usuario
**RF que cubre:** RF-C1
**Hito:** Entrega 1

**Como** donante con credito,
**Quiero** que mi nombre y monto aparezcan en el muro de donantes de la campana,
**Para** que la comunidad reconozca publicamente mi apoyo a los estudiantes.

---

## Criterios de Aceptacion

**CA1 (Criterio minimo):** Dado que solicite credito (o solicite factura con preferencia publica) y mi donacion se encuentra en estado Pagada, cuando cualquier visitante consulta la campana en el sitio publico, entonces ve mi nombre y el monto donado en el muro de reconocimientos de esa campana, ademas de la suma consolidada de donantes anonimos.

**CA2 (Criterio minimo):** Dado que aparezco en el muro publico de reconocimientos, cuando cualquier persona inspecciona la vista, entonces unicamente se muestran mi nombre y el monto aportado (no aparece correo electronico, telefono, RFC ni ningun otro dato personal).

**CA3 (Criterio propio / Negativo - Exclusion de no pagadas):** Dado que una donacion con credito permanece en estado Pendiente o Cancelada/Expirada, cuando un visitante consulta el reconocimiento de la campana, entonces dicho donante no aparece listado hasta que su pago pase a estado Pagada.

---

## Estado
- [ ] Pendiente de implementacion
- Evidencia: [Enlace a demo/captura]
"@

# US-F1
New-Issue "US-F1: Captura de datos fiscales CFDI 4.0 y visibilidad" "E1" @"
## Historia de Usuario
**RF que cubre:** RF-F1
**Hito:** Entrega 1

**Como** donante (persona fisica o moral) que requiere deducir impuestos,
**Quiero** registrar mis datos fiscales obligatorios segun la normativa mexicana y elegir si deseo figurar en el muro publico,
**Para** que la coordinacion cuente con la informacion requerida para el tramite fiscal de mi aportacion.

---

## Criterios de Aceptacion

**CA1 (Criterio minimo - Datos CFDI 4.0 obligatorios):** Dado que elegi solicitar factura en el formulario, cuando intento enviar la solicitud omitiendo Nombre/Razon Social, RFC, Codigo Postal Fiscal, Regimen Fiscal, Uso de CFDI o Correo Electronico, entonces el sistema bloquea el avance y resalta los campos obligatorios pendientes.

**CA2 (Criterio minimo - Validacion Regex del SAT):** Dado que introduzco un RFC en el formulario, cuando lo envio, entonces el sistema valida su estructura mediante expresion regular (patron de letras, fecha y homoclave; 12 caracteres para personas morales y 13 para personas fisicas) y rechaza el valor si no coincide, sin invocar servicios externos del SAT.

**CA3 (Criterio minimo - Alcance no fiscal):** Dado que un donante con factura completa su aportacion en modo de prueba, cuando se audita el sistema en Salesforce, entonces se corrobora que no se timbra ni genera ningun CFDI oficial ante el SAT.

**CA4 (Criterio propio - Visibilidad publica configurable):** Dado que solicite factura, cuando se confirma el pago, entonces mi Nombre/Razon Social y monto aparecen por defecto en el reconocimiento de la campana para respaldar la transparencia del donativo ante fines fiscales, a menos que haya marcado explicitamente la casilla independiente para no figurar publicamente en el sitio.

---

## Estado
- [ ] Pendiente de implementacion
- Evidencia: [Enlace a demo/captura]
"@

# US-S1
New-Issue "US-S1: Gestion interna de campanas y control al 100% de la meta" "E1" @"
## Historia de Usuario
**RF que cubre:** RF-S1
**Hito:** Entrega 1

**Como** coordinacion del programa,
**Quiero** crear y administrar campanas definiendo su meta economica, fecha limite y comportamiento al llegar al 100%,
**Para** organizar los fondos de viaje y garantizar que siempre exista al menos una campana activa disponible para recibir donaciones.

---

## Criterios de Aceptacion

**CA1 (Criterio minimo):** Dado que cuento con permisos de staff en Salesforce, cuando creo una campana activa con nombre y meta, entonces aparece visible de inmediato en el sitio publico.

**CA2 (Criterio minimo):** Dado que existe una campana activa, cuando staff actualiza el monto de su meta en Salesforce, entonces el sitio publico refleja el nuevo valor al recargar.

**CA3 (Criterio propio - Regla de meta al 100% y fecha de evento):** Dado que una campana alcanza el 100% de su meta de recaudacion o su fecha limite vencio, cuando el sistema evalua su disponibilidad, entonces el portal publico deja de aceptar donaciones a menos que staff haya marcado la casilla de configuracion "Permitir donaciones adicionales al superar la meta" en una campana cuya fecha siga vigente.

**CA4 (Criterio propio / Negativo - Validacion de meta economica):** Dado que un integrante de staff intenta guardar una campana con meta menor o igual a cero, cuando intenta guardar el registro, entonces Salesforce arroja una regla de validacion impidiendo guardar importes invalidos.

---

## Estado
- [ ] Pendiente de implementacion
- Evidencia: [Enlace a demo/captura]
"@

# US-S2
New-Issue "US-S2: Consola de monitoreo y filtro de solicitudes de factura" "E1" @"
## Historia de Usuario
**RF que cubre:** RF-S2, RF-F2
**Hito:** Entrega 1

**Como** tesorero del programa,
**Quiero** consultar todas las donaciones y filtrar especificamente las que solicitan factura con sus datos fiscales,
**Para** mantener el control financiero interno y preparar la atencion administrativa correspondiente.

---

## Criterios de Aceptacion

**CA1 (Criterio minimo):** Dado que existen donaciones en multiples modalidades y estados (Pendiente, Pagada, Cancelada/Expirada), cuando staff consulta la vista de donaciones en Salesforce, entonces visualiza el estado, monto, modalidad, campana y referencia de cada registro.

**CA2 (Criterio minimo):** Dado que existen donaciones que solicitaron factura, cuando staff consulta el registro en Salesforce, entonces lo visualiza marcado como "Solicita factura" junto con el Nombre/Razon Social, RFC, Codigo Postal y Regimen Fiscal capturados.

**CA3 (Criterio minimo):** Dado que existen registros de diversas modalidades, cuando staff selecciona la vista o filtro "Solicitan factura", entonces la lista muestra exclusivamente las aportaciones que requieren factura fiscal.

---

## Estado
- [ ] Pendiente de implementacion
- Evidencia: [Enlace a demo/captura]
"@

# US-S3
New-Issue "US-S3: Confirmacion manual de pago y envio de comprobante" "E1" @"
## Historia de Usuario
**RF que cubre:** RF-S3
**Hito:** Entrega 1

**Como** tesorero del programa,
**Quiero** marcar manualmente como pagada una donacion pendiente y enviar su comprobante por correo,
**Para** acreditar donaciones en caso de que la automatizacion no este disponible o se requiera conciliacion directa.

---

## Criterios de Aceptacion

**CA1 (Criterio minimo):** Dado que una donacion esta en estado Pendiente, cuando staff ejecuta la accion manual de confirmacion de pago en Salesforce, entonces el estado del registro cambia a Pagada y su importe suma al avance de la campana.

**CA2 (Criterio minimo):** Dado que staff confirmo el pago, cuando el donante revisa su bandeja de correo, entonces recibe un comprobante/ticket con numero de referencia, campana, fecha, monto, modalidad, datos fiscales (si aplica) y el correo de soporte del programa.

**CA3 (Criterio propio / Negativo - Bloqueo de confirmacion duplicada):** Dado que una donacion ya se encuentra en estado Pagada, cuando staff intenta accionar nuevamente la confirmacion manual, entonces el sistema notifica que el pago ya fue validado y bloquea el reenvio redundante de comprobantes.

---

## Estado
- [ ] Pendiente de implementacion
- Evidencia: [Enlace a demo/captura]
"@

# US-V2
New-Issue "US-V2: Auditoria y prueba de seguridad para Guest User" "E1" @"
## Historia de Usuario
**RF que cubre:** RF-V2, M2
**Hito:** Entrega 1

**Como** coordinacion del programa,
**Quiero** evidencia reproducible de que un visitante no autenticado no puede leer ni modificar donaciones ajenas,
**Para** proteger los datos personales de los donantes y demostrar el principio de minimo privilegio.

---

## Criterios de Aceptacion

**CA1 (Criterio minimo):** Dado que existen donaciones de terceros registradas en Salesforce, cuando un visitante sin login intenta consultarlas a traves del portal publico, APIs del sitio o inspeccion de red, entonces el sistema devuelve cero registros o acceso denegado.

**CA2 (Criterio minimo / Negativo):** Dado que existen registros de donaciones en la base de datos, cuando un usuario sin sesion intenta modificarlos o eliminarlos mediante llamadas externas, entonces la plataforma rechaza de forma estricta la transaccion.

**CA3 (Criterio minimo):** Dado el documento de seguridad (docs/seguridad.md), cuando un auditor o el profesor replica los pasos descritos, entonces obtiene exactamente los mismos resultados de bloqueo y denegacion.

---

## Estado
- [ ] Pendiente de implementacion
- Evidencia: docs/seguridad.md
"@

# US-D1b
New-Issue "US-D1b: Donacion de monto libre personalizado" "E2" @"
## Historia de Usuario
**RF que cubre:** RF-D1b
**Hito:** Entrega 2

**Como** donante,
**Quiero** capturar libremente el importe exacto que deseo donar respetando el minimo procesable por la pasarela,
**Para** aportar la cantidad acorde a mis posibilidades sin estar restringido a montos preestablecidos.

---

## Criterios de Aceptacion

**CA1 (Criterio minimo):** Dado que seleccione una campana activa, cuando capturo en el formulario un monto personalizado valido mayor o igual al minimo de Stripe (>= $10.00 MXN o >= $0.50 USD), entonces la pasarela de prueba me cobra exactamente esa cantidad y la donacion en Salesforce registra identico importe.

**CA2 (Criterio propio / Negativo - Validacion de umbral minimo de Stripe):** Dado que un donante captura un valor numerico menor a $10.00 MXN (o $0.50 USD si opera en dicha divisa), un numero negativo o cero, cuando intenta avanzar, entonces el formulario bloquea la transicion a Stripe y muestra una advertencia indicando el monto minimo procesable por la pasarela.

---

## Estado
- [ ] Pendiente de implementacion
- Evidencia: [Enlace a demo/captura]
"@

# US-D5
New-Issue "US-D5: Confirmacion y comprobante automaticos via webhook" "E2" @"
## Historia de Usuario
**RF que cubre:** RF-D5, RF-V3a
**Hito:** Entrega 2

**Como** donante,
**Quiero** que mi donacion se marque automaticamente como pagada al autorizarse en Stripe y recibir mi comprobante por correo al instante,
**Para** disponer de la constancia de mi aportacion de inmediato sin depender de intervencion manual de staff.

---

## Criterios de Aceptacion

**CA1 (Criterio minimo):** Dado que complete un pago exitoso con tarjeta de prueba en Stripe, cuando la pasarela emite su aviso de pago hacia Salesforce, entonces la donacion correspondiente transiciona a estado Pagada de forma desatendida sin intervencion de staff.

**CA2 (Criterio minimo):** Dado que la donacion paso a pagada de forma automatica, cuando reviso mi bandeja de entrada, entonces recibo de inmediato el comprobante con los identificadores de la donacion, campana, monto, fecha, desglose fiscal (si aplica) y correo de soporte institucional.

**CA3 (Criterio propio / Negativo - Manejo de webhook por sesion expirada):** Dado que un usuario cerro la pasarela y Stripe emite un webhook de expiracion (checkout.session.expired), cuando Salesforce procesa el evento, entonces actualiza la donacion a estado Cancelada/Expirada sin detonar comprobante ni sumar a la campana.

---

## Estado
- [ ] Pendiente de implementacion
- Evidencia: [Enlace a demo/captura]
"@

# US-V3
New-Issue "US-V3: Validacion de autenticidad e idempotencia del Webhook" "E2" @"
## Historia de Usuario
**RF que cubre:** RF-V3b, M3
**Hito:** Entrega 2

**Como** tesorero del programa,
**Quiero** que el servicio de integracion verifique la firma criptografica de Stripe y prevenga duplicados,
**Para** asegurar que solo se procesen avisos legitimos y evitar inconsistencias financieras por reintentos de red.

---

## Criterios de Aceptacion

**CA1 (Criterio minimo / Negativo - Rechazo de avisos falsos):** Dado que un tercero envia un payload simulando un pago pero con firma HMAC invalida o ausente en el header Stripe-Signature, cuando la solicitud llega a Salesforce, entonces se rechaza con error HTTP 400/401, el estado de la donacion no se altera y la incidencia queda visible para auditoria de staff.

**CA2 (Criterio minimo - Idempotencia ante reintentos):** Dado que Stripe retransmite el mismo evento de pago en dos ocasiones por reintentos de red, cuando ambos mensajes son recibidos en el endpoint, entonces el sistema procesa el primero y detecta el segundo como duplicado, manteniendo una sola donacion pagada y emitiendo un unico comprobante.

**CA3 (Criterio propio - Resguardo de secretos M3):** Dado que se verifica la firma mediante el Signing Secret, cuando se audita el codigo Apex, componentes y el repositorio publico de GitHub, entonces se demuestra que la clave no se encuentra expuesta en texto plano ni en el historial de commits, residiendo unicamente en Custom Metadata o Named Credentials protegidas.

---

## Estado
- [ ] Pendiente de implementacion
- Evidencia: [Enlace a demo/captura]
"@

# US-S4
New-Issue "US-S4: Auditoria de confirmaciones automaticas y log de avisos descartados" "E2" @"
## Historia de Usuario
**RF que cubre:** RF-S4
**Hito:** Entrega 2

**Como** tesorero del programa,
**Quiero** distinguir que donaciones fueron confirmadas por webhook y consultar una bitacora de avisos rechazados,
**Para** monitorear la salud de la integracion externa sin tener que auditar los registros de forma manual.

---

## Criterios de Aceptacion

**CA1 (Criterio minimo):** Dado que una donacion fue confirmada por el webhook de Stripe, cuando staff consulta el registro en Salesforce, entonces distingue claramente que fue validada mediante confirmacion automatica y no manual.

**CA2 (Criterio minimo):** Dado que un aviso fue descartado (por firma apocrifa, referencia inexistente o error en payload), cuando staff ingresa al registro de avisos rechazados, entonces visualiza la fecha/hora de recepcion y el motivo exacto del descarte.

**CA3 (Criterio propio - Proteccion de datos en bitacora):** Dado que se genera un registro de auditoria de integracion, cuando staff consulta el log de error, entonces se verifica que la bitacora no almacena datos confidenciales de tarjetas ni secretos de la pasarela.

---

## Estado
- [ ] Pendiente de implementacion
- Evidencia: [Enlace a demo/captura]
"@

Write-Host ""
Write-Host "Listo. Issues creados en https://github.com/$repo/issues"
