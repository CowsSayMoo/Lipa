Write-Progress-Message "Moving Splashtop File" "Magenta"
    $downloadsPath = "$env:USERPROFILE\Downloads"
    $destinationPath = "$env:USERPROFILE\Desktop\SOS Lipa.exe"

    try {
        $splashtopFile = Get-ChildItem -Path $downloadsPath -Filter "*Splashtop*.exe" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($splashtopFile) {
            Move-Item -Path $splashtopFile.FullName -Destination $destinationPath -Force

            Write-Host "✓ Splashtop file moved to desktop and renamed to SOS Lipa" -ForegroundColor Green
        }
        else {
            Write-Warning "No Splashtop file found in the Downloads folder."
        }
    }
    catch {
        Write-Warning "✗ Failed to move Splashtop file: $_"
    }