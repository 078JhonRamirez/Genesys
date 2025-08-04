try {
    # Parámetros del flujo
    $flowName = "Archy Hello World"
    $flowType = "inboundcall"
    $outputDir = "C:\Users\JhonJairoRamirezHurt\Desktop\archy\Demo-archy"
    $finalName = "$flowName.yaml"

    Write-Host "Exportando flujo '$flowName'..."

    # Ejecutar Archy export y capturar salida
    $archyOutput = archy export --flowName "$flowName" --flowType $flowType --exportType yaml --outputDir "$outputDir" --force

    # Buscar línea que contiene la ruta del archivo exportado
    $exportLine = $archyOutput | Where-Object { $_ -match "the flow was exported to '(.+)'\." }

    if (-not $exportLine) {
        throw "No se encontró la ruta del archivo exportado en la salida de Archy."
    }

    # Extraer la ruta del archivo con regex
    if ($exportLine -match "the flow was exported to '(.+)'\.") {
        $exportedFile = $matches[1]
    }
    else {
        throw "No se pudo extraer la ruta del archivo exportado."
    }

    if (-not (Test-Path $exportedFile)) {
        throw "El archivo exportado no existe: $exportedFile"
    }

    $targetFile = Join-Path $outputDir $finalName

    # Renombrar archivo para quitar versión y usar nombre limpio
    Rename-Item -Path $exportedFile -NewName $finalName -Force

    Write-Host "Flujo exportado y renombrado correctamente como: $targetFile"
}
catch {
     Write-Host ""
     Write-Host ('[ERROR] ' + $_) -ForegroundColor Red
     Read-Host 'Presiona ENTER para cerrar'
}
