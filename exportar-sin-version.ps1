try {
    # Parámetros del flujo
    $flowName = "Archy Hello World"
    $flowType = "inboundcall"
    $outputDir = "C:\Users\JhonJairoRamirezHurt\Desktop\archy\Demo-archy"
    $finalName = "$flowName.yaml"
    $targetFile = Join-Path $outputDir $finalName

    Write-Host "Exportando flujo '$flowName'..."

    # Ejecutar Archy export y capturar salida (texto plano)
    $archyOutput = archy export --flowName "$flowName" --flowType $flowType --exportType yaml --outputDir "$outputDir" --force

    # Buscar línea que contiene la ruta del archivo exportado
    $exportLine = $archyOutput | Where-Object { $_ -match "the flow was exported to '(.+\.yaml)'" }

    if (-not $exportLine) {
        throw "No se encontró la ruta del archivo exportado en la salida de Archy."
    }

    # Extraer ruta usando regex
    if ($exportLine -match "the flow was exported to '(.+\.yaml)'") {
        $exportedFile = $matches[1]
    }
    else {
        throw "No se pudo extraer la ruta del archivo exportado."
    }

    if (-not (Test-Path $exportedFile)) {
        throw "El archivo exportado no existe: $exportedFile"
    }

    # Si ya existe un archivo limpio, lo eliminamos
    if (Test-Path $targetFile) {
        Remove-Item $targetFile -Force
        Write-Host "Archivo existente eliminado: $targetFile"
    }

    # Renombrar el archivo con versión al nombre limpio
    Rename-Item -Path $exportedFile -NewName $finalName -Force
    Write-Host "✅ Flujo exportado y renombrado como: $targetFile"

    # Limpiar otros archivos con versión
    Get-ChildItem -Path $outputDir -Filter "$flowName*_v*.yaml" | ForEach-Object {
        if ($_.FullName -ne $targetFile) {
            Remove-Item $_.FullName -Force
            Write-Host "🗑️  Archivo con versión eliminado: $($_.Name)"
        }
    }
}
catch {
    Write-Host ""
    Write-Host ('[ERROR] ' + $_) -ForegroundColor Red
    Read-Host 'Presiona ENTER para cerrar'
}