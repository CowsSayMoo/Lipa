<#
.SYNOPSIS
    Installs a list of packages using a fallback chain of installation methods.

.DESCRIPTION
    This script installs a list of packages from a given array. For each package, it attempts to install using winget,
then falls back to chocolatey, and finally to a direct download if the previous methods fail.
    It logs successful and failed installations to separate files.
#>

# Packages to install
$Packages = @(
    @{ Name = "Firefox"; WingetId = "Mozilla.Firefox"; ChocolateyId = "firefox" },
    @{ Name = "Google Chrome"; WingetId = "Google.Chrome"; ChocolateyId = "googlechrome" },
    @{ Name = "Rustdesk"; WingetId = "Rustdesk.Rustdesk"; ChocolateyId = "rustdesk" },
    @{ Name = "Adobe Acrobat Reader"; WingetId = "Adobe.AcrobatReaderDC"; ChocolateyId = "adobereader" },
    @{ Name = "Foxit PDF Reader"; WingetId = "Foxit.FoxitReader"; ChocolateyId = "foxitreader" },
    @{ Name = "Belgian EID middleware"; WingetId = "eid.belgium"; ChocolateyId = "eid-mw" },
    @{ Name = "Belgian EID viewer"; WingetId = "eid.belgium"; ChocolateyId = "eid-viewer" },
    @{ Name = "OpenVPN Connect"; WingetId = "OpenVPN.OpenVPNConnect"; ChocolateyId = "openvpn-connect" },
    @{ Name = "MS Office 365 Apps"; WingetId = "Microsoft.Office"; ChocolateyId = "office365business" },
    @{ Name = "HP Support Assistant"; ChocolateyId = "hpsupportassistant" },
    @{ Name = "HP Image Assistant"; ChocolateyId = "hpimageassistant" },
    @{ Name = "Splashtop"; DownloadUrl = "https://my.splashtop.eu/sos/packages/download/XW2PS2PZ5KSKEU" }
)

# Log files
$SuccessLog = "C:\temp\successful_installations.log"
$FailureLog = "C:\temp\failed_installations.log"

# Ensure log directory exists
$LogDir = Split-Path -Path $SuccessLog -Parent
if (-not (Test-Path -Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

function Install-WithWinget {
    param (
        [string]$PackageName,
        [string]$PackageId
    )
    
    Write-Host "Attempting to install $PackageName using winget..."
    winget install --id $PackageId --accept-source-agreements --accept-package-agreements
    
    if ($LASTEXITCODE -ne 0) {
        throw "winget install failed with exit code $LASTEXITCODE"
    }
}

function Install-WithChocolatey {
    param (
        [string]$PackageName,
        [string]$PackageId
    )

    Write-Host "Attempting to install $PackageName using chocolatey..."
    choco install $PackageId -y

    if ($LASTEXITCODE -ne 0) {
        throw "chocolatey install failed with exit code $LASTEXITCODE"
    }
}

function Install-FromDownload {
    param (
        [string]$PackageName,
        [string]$DownloadUrl
    )

    Write-Host "Attempting to download $PackageName from $DownloadUrl..."
    $tempFile = Join-Path -Path $env:TEMP -ChildPath "$PackageName-installer.exe"

    try {
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $tempFile -ErrorAction Stop
    }
    catch {
        throw "Failed to download $PackageName from $DownloadUrl: $_"
    }

    Write-Host "Attempting to install $PackageName from $tempFile..."
    $process = Start-Process -FilePath $tempFile -Wait -PassThru

    if ($process.ExitCode -ne 0) {
        throw "Installation of $PackageName failed with exit code $($process.ExitCode)"
    }
    else {
        Remove-Item -Path $tempFile -Force
    }
}

# Main installation logic
foreach ($package in $Packages) {
    $name = $package.Name
    $installed = $false

    # Try Winget
    if ($package.WingetId) {
        try {
            Install-WithWinget -PackageName $name -PackageId $package.WingetId
            "Successfully installed $name using winget" | Out-File -FilePath $SuccessLog -Append
            $installed = true
        }
        catch {
            Write-Warning "Winget installation for $name failed: $($_.ToString())"
        }
    }

    # Try Chocolatey if Winget failed
    if (-not $installed -and $package.ChocolateyId) {
        try {
            Install-WithChocolatey -PackageName $name -PackageId $package.ChocolateyId
            "Successfully installed $name using chocolatey" | Out-File -FilePath $SuccessLog -Append
            $installed = true
        }
        catch {
            Write-Warning "Chocolatey installation for $name failed: $($_.ToString())"
        }
    }

    # Try Download if Chocolatey failed
    if (-not $installed -and $package.DownloadUrl) {
        try {
            Install-FromDownload -PackageName $name -DownloadUrl $package.DownloadUrl
            "Successfully installed $name from download" | Out-File -FilePath $SuccessLog -Append
            $installed = true
        }
        catch {
            Write-Warning "Download installation for $name failed: $($_.ToString())"
        }
    }

    if (-not $installed) {
        "Failed to install $name using all available methods." | Out-File -FilePath $FailureLog -Append
    }
}
