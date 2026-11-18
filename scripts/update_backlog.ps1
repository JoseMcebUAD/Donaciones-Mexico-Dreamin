# update_backlog.ps1
# Uso: .\scripts\update_backlog.ps1 [-DryRun]
# Lee el estado de issues 20-33 en GitHub y actualiza el README raiz con % de avance.

param([switch]$DryRun)

$gh     = "C:\Program Files\GitHub CLI\gh.exe"
$repo   = "JoseMcebUAD/Donaciones-Mexico-Dreamin"
$readme = Join-Path $PSScriptRoot "..\README.md"

# -- Historias y subtareas ----------------------------------------------------
$stories = @(
    [PSCustomObject]@{
        Issue   = 20; Id = "US-D1"; Entrega = "E1"
        Title   = "Visualizacion publica de campanas y progreso financiero"
        Subtasks = @(
            "CA1: Campanas con nombre, meta y avance visibles sin login",
            "CA2: Solo donaciones Pagadas suman al avance de la campana",
            "CA3: Seleccion de monto sugerido o libre en pasarela",
            "CA4: Auto-redirect a campana unica si solo hay una activa",
            "CA5: Bloquear formulario si campana vencida o cerrada al 100%"
        )
    }
    [PSCustomObject]@{
        Issue   = 21; Id = "US-D2"; Entrega = "E1"
        Title   = "Donacion en modalidad Anonima"
        Subtasks = @(
            "CA1: Nombre no aparece en sitio publico en modalidad anonima",
            "CA2: Comprobante digital no muestra nombre personal",
            "CA3: Bloqueo de factura sin datos fiscales en modo anonimo",
            "CA4: Donacion anonima identificable por staff en Salesforce"
        )
    }
    [PSCustomObject]@{
        Issue   = 22; Id = "US-D3"; Entrega = "E1"
        Title   = "Registro previo de donacion y control de expiracion"
        Subtasks = @(
            "CA1: Registro en estado Pendiente antes de redirigir a pasarela",
            "CA2: Referencia unica vincula transaccion con donacion en Salesforce",
            "CA3: Donacion pasa a Cancelada/Expirada si se abandona la pasarela"
        )
    }
    [PSCustomObject]@{
        Issue   = 23; Id = "US-D4"; Entrega = "E1"
        Title   = "Retorno y pagina de agradecimiento con contacto de soporte"
        Subtasks = @(
            "CA1: Pagina de agradecimiento al completar pago en Stripe",
            "CA2: Mensaje no afirma pago confirmado definitivamente en E1",
            "CA3: No se expone informacion personal en pagina de retorno",
            "CA4: Correo de soporte institucional visible en pantalla de agradecimiento"
        )
    }
    [PSCustomObject]@{
        Issue   = 24; Id = "US-C1"; Entrega = "E1"
        Title   = "Reconocimiento publico de aportaciones en campana"
        Subtasks = @(
            "CA1: Nombre y monto en muro publico para donaciones Pagadas con credito",
            "CA2: Solo nombre y monto visibles (sin datos personales privados)",
            "CA3: Donaciones Pendientes/Canceladas excluidas del muro"
        )
    }
    [PSCustomObject]@{
        Issue   = 25; Id = "US-F1"; Entrega = "E1"
        Title   = "Captura de datos fiscales CFDI 4.0 y visibilidad"
        Subtasks = @(
            "CA1: Bloqueo al omitir campos CFDI 4.0 obligatorios",
            "CA2: Validacion regex del RFC segun patron del SAT",
            "CA3: No se timbra ni genera CFDI oficial ante el SAT",
            "CA4: Nombre/Razon Social en muro publico por defecto con factura (configurable)"
        )
    }
    [PSCustomObject]@{
        Issue   = 26; Id = "US-S1"; Entrega = "E1"
        Title   = "Gestion interna de campanas y control al 100% de la meta"
        Subtasks = @(
            "CA1: Campana creada aparece visible en sitio publico inmediatamente",
            "CA2: Cambio de meta en Salesforce se refleja en portal publico",
            "CA3: Portal bloquea donaciones si campana al 100% o vencida (salvo configuracion)",
            "CA4: Validacion impide guardar campana con meta <= 0"
        )
    }
    [PSCustomObject]@{
        Issue   = 27; Id = "US-S2"; Entrega = "E1"
        Title   = "Consola de monitoreo y filtro de solicitudes de factura"
        Subtasks = @(
            "CA1: Vista muestra estado, monto, modalidad, campana y referencia de cada donacion",
            "CA2: Registro marcado como Solicita factura con datos fiscales completos",
            "CA3: Filtro/vista muestra exclusivamente aportaciones que requieren factura"
        )
    }
    [PSCustomObject]@{
        Issue   = 28; Id = "US-S3"; Entrega = "E1"
        Title   = "Confirmacion manual de pago y envio de comprobante"
        Subtasks = @(
            "CA1: Accion manual cambia estado a Pagada y suma al avance de campana",
            "CA2: Donante recibe comprobante con todos los datos al confirmar",
            "CA3: Bloqueo de confirmacion duplicada en registros ya Pagados"
        )
    }
    [PSCustomObject]@{
        Issue   = 29; Id = "US-V2"; Entrega = "E1"
        Title   = "Auditoria y prueba de seguridad para Guest User"
        Subtasks = @(
            "CA1: Visitante sin login no puede ver donaciones de terceros",
            "CA2: Visitante sin sesion no puede modificar ni eliminar registros",
            "CA3: Pasos de docs/seguridad.md reproducibles por auditor externo"
        )
    }
    [PSCustomObject]@{
        Issue   = 30; Id = "US-D1b"; Entrega = "E2"
        Title   = "Donacion de monto libre personalizado"
        Subtasks = @(
            "CA1: Monto personalizado valido se cobra exactamente en Stripe y Salesforce",
            "CA2: Bloqueo con advertencia si monto es menor al minimo de Stripe o invalido"
        )
    }
    [PSCustomObject]@{
        Issue   = 31; Id = "US-D5"; Entrega = "E2"
        Title   = "Confirmacion y comprobante automaticos via webhook"
        Subtasks = @(
            "CA1: Donacion pasa a Pagada automaticamente con webhook de Stripe",
            "CA2: Comprobante enviado de forma automatica al pasar a Pagada",
            "CA3: Webhook de expiracion actualiza donacion a Cancelada sin comprobante"
        )
    }
    [PSCustomObject]@{
        Issue   = 32; Id = "US-V3"; Entrega = "E2"
        Title   = "Validacion de autenticidad e idempotencia del Webhook"
        Subtasks = @(
            "CA1: Rechazo HTTP 400/401 si firma HMAC es invalida o ausente",
            "CA2: Segundo webhook del mismo evento procesado como duplicado (idempotencia)",
            "CA3: Signing Secret no expuesto en codigo ni historial de Git"
        )
    }
    [PSCustomObject]@{
        Issue   = 33; Id = "US-S4"; Entrega = "E2"
        Title   = "Auditoria de confirmaciones automaticas y log de avisos descartados"
        Subtasks = @(
            "CA1: Donacion distinguible como confirmada por webhook vs accion manual",
            "CA2: Log de avisos rechazados con fecha/hora y motivo del descarte",
            "CA3: Bitacora no almacena datos de tarjetas ni secretos de pasarela"
        )
    }
)

# -- 1. Agregar subtareas a cada issue ----------------------------------------
Write-Host "=== Agregando subtareas ==="
foreach ($s in $stories) {
    Write-Host "[$($s.Id)] Issue #$($s.Issue)..."
    $issueData  = & $gh issue view $s.Issue --repo $repo --json body | ConvertFrom-Json
    $alreadyHas = $issueData.body -match "## Subtareas" -or $issueData.body -match "## Criterios"
    if ($alreadyHas) {
        Write-Host "  ya tiene criterios/subtareas, omitiendo."
        continue
    }
    $block   = "`n`n## Subtareas`n" + (($s.Subtasks | ForEach-Object { "- [ ] $_" }) -join "`n")
    $newBody = $issueData.body + $block
    if ($DryRun) {
        Write-Host "  [DRY-RUN] Se agregarian $($s.Subtasks.Count) subtareas."
    } else {
        $tmp = [System.IO.Path]::GetTempFileName() + ".md"
        [System.IO.File]::WriteAllText($tmp, $newBody, [System.Text.Encoding]::UTF8)
        & $gh issue edit $s.Issue --repo $repo --body-file $tmp | Out-Null
        Remove-Item $tmp
        Write-Host "  $($s.Subtasks.Count) subtareas anadidas."
        Start-Sleep -Milliseconds 400
    }
}

# -- 2. Calcular estados y avance ---------------------------------------------
Write-Host "`n=== Calculando avance ==="
$statusMap = @{}
foreach ($s in $stories) {
    $data       = & $gh issue view $s.Issue --repo $repo --json state,labels | ConvertFrom-Json
    $labelNames = $data.labels | ForEach-Object { $_.name }
    $statusMap[$s.Issue] = if ($data.state -eq "CLOSED") { "done" }
                           elseif ($labelNames -contains "in-progress") { "in-progress" }
                           else { "pending" }
    Write-Host "  #$($s.Issue) $($s.Id) -> $($statusMap[$s.Issue])"
}

$emojiMap = @{ "done" = "OK"; "in-progress" = "WIP"; "pending" = "TODO" }
$labelMap = @{ "done" = "Implementada"; "in-progress" = "En progreso"; "pending" = "Pendiente" }

$e1 = $stories | Where-Object { $_.Entrega -eq "E1" }
$e2 = $stories | Where-Object { $_.Entrega -eq "E2" }

$e1Done    = ($e1 | Where-Object { $statusMap[$_.Issue] -eq "done" }).Count
$e2Done    = ($e2 | Where-Object { $statusMap[$_.Issue] -eq "done" }).Count
$totalDone = $e1Done + $e2Done
$e1Total   = $e1.Count
$e2Total   = $e2.Count
$total     = $stories.Count

$e1Pct    = if ($e1Total -gt 0)  { [int]($e1Done    / $e1Total  * 100) } else { 0 }
$e2Pct    = if ($e2Total -gt 0)  { [int]($e2Done    / $e2Total  * 100) } else { 0 }
$totalPct = if ($total    -gt 0) { [int]($totalDone / $total    * 100) } else { 0 }

# -- 3. Construir bloque para el README ---------------------------------------
$e1Url = "https://github.com/$repo/issues?q=is%3Aissue+label%3AE1"
$e2Url = "https://github.com/$repo/issues?q=is%3Aissue+label%3AE2"

$rows = $stories | ForEach-Object {
    $st  = $statusMap[$_.Issue]
    $url = "https://github.com/$repo/issues/$($_.Issue)"
    $ico = switch ($st) { "done" { "[x]" } "in-progress" { "[ ]" } default { "[ ]" } }
    "| [$($_.Id)]($url) | $($_.Title) | $($_.Entrega) | $($labelMap[$st]) |"
}

$sectionParts = @(
    "<!-- BACKLOG-START -->"
    "[Tablero E1]($e1Url) | [Tablero E2]($e2Url)"
    ""
    "| Entrega | Total | Cumplidas | Avance |"
    "|---------|-------|-----------|--------|"
    "| E1 | $e1Total | $e1Done | ${e1Pct}% ($e1Done/$e1Total) |"
    "| E2 | $e2Total | $e2Done | ${e2Pct}% ($e2Done/$e2Total) |"
    "| **Total** | **$total** | **$totalDone** | **${totalPct}%** |"
    ""
    "> Calculo: issues cerradas en GitHub / total de issues x 100."
    ""
    "| ID | Historia | Entrega | Estado |"
    "|----|----------|---------|--------|"
) + $rows + @("", "<!-- BACKLOG-END -->")

$section = $sectionParts -join "`n"

# -- 4. Actualizar README -----------------------------------------------------
Write-Host "`n=== Actualizando README ==="
$content = [System.IO.File]::ReadAllText($readme, [System.Text.Encoding]::UTF8)

if ($content -match "(?s)<!-- BACKLOG-START -->.*?<!-- BACKLOG-END -->") {
    $newContent = [regex]::Replace($content, "(?s)<!-- BACKLOG-START -->.*?<!-- BACKLOG-END -->", $section)
} else {
    $newContent = $content.TrimEnd() + "`n`n" + $section + "`n"
}

if ($DryRun) {
    Write-Host "[DRY-RUN] README no modificado. Seccion generada:"
    Write-Host $section
} else {
    [System.IO.File]::WriteAllText($readme, $newContent, [System.Text.Encoding]::UTF8)
    Write-Host "README actualizado -- E1: ${e1Pct}% | E2: ${e2Pct}% | Total: ${totalPct}%"
}

Write-Host "Listo."
