try {
    # Parámetros
    $flowName = "Archy Hello World"
    $flowType = "inboundcall"
    $outputDir = "C:\Users\JhonJairoRamirezHurt\Desktop\archy\Demo-archy"
    $archiveDir = Join-Path $outputDir "versiones"
    $finalName = "$flowName.yaml"
    $targetFile = Join-Path $outputDir $finalName

    Write-Host "Exportando flujo '$flowName'..."

    # Ejecutar Archy export y capturar salida
    $archyOutput = archy export --flowName "$flowName" --flowType $flowType --exportType yaml --outputDir "$outputDir" --force

    # Buscar línea con el path exportado
    $exportLine = $archyOutput | Where-Object { $_ -match "the flow was exported to '(.+\.yaml)'" }

    if (-not $exportLine) {
        throw "No se encontró la ruta del archivo exportado en la salida de Archy."
    }

    if ($exportLine -match "the flow was exported to '(.+\.yaml)'") {
        $exportedFile = $matches[1]
    } else {
        throw "No se pudo extraer la ruta del archivo exportado."
    }

    if (-not (Test-Path $exportedFile)) {
        throw "El archivo exportado no existe: $exportedFile"
    }

    # Crear carpeta de versiones si no existe
    if (-not (Test-Path $archiveDir)) {
        New-Item -ItemType Directory -Path $archiveDir | Out-Null
        Write-Host "Carpeta de versiones creada: $archiveDir"
    }

    # Mover versión con nombre original a carpeta de versiones
    $versionedName = Split-Path $exportedFile -Leaf
    $archivedVersion = Join-Path $archiveDir $versionedName
    Move-Item -Path $exportedFile -Destination $archivedVersion -Force

    Write-Host "Versión archivada: $archivedVersion"

    # Copiar versión archivada como nombre limpio
    Copy-Item -Path $archivedVersion -Destination $targetFile -Force

    Write-Host "Flujo exportado como: $targetFile"
}
catch {
    Write-Host ""
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "Presiona ENTER para cerrar"
}
