<#
.SYNOPSIS
    Generates a ticket with system information for a clean install.

.DESCRIPTION
    This script gathers system information, including device details, installed packages,
    and user credentials, and formats it into a ticket layout in Dutch.
#>

# Function to read info from the temp file
function Get-TicketInfoFromTempFile {
    $tempFile = "C:\temp\device_info.txt"
    if (Test-Path $tempFile) {
        $info = @{}
        Get-Content $tempFile | ForEach-Object {
            $key, $value = $_.Split('=', 2)
            $info[$key] = $value
        }
        return $info
    }
    return $null
}

# Get information
$ticketInfo = Get-TicketInfoFromTempFile
$deviceName = $ticketInfo["DEVICENAME"]
$clientAdminPassword = $ticketInfo["CLIENTADMIN_PASSWORD"]
$localUser = $ticketInfo["USER_USERNAME"]
$localUserPassword = $ticketInfo["USER_PASSWORD"]

$serialNumber = (Get-CimInstance Win32_BIOS).SerialNumber
$installedPackages = (Get-Package).Name
$loggedInUser = "$env:USERDOMAIN\$env:USERNAME"

# Format the output
$output = @"
Clean install

Apparaatnaam: $deviceName
Serienummer van het apparaat: $serialNumber

Lijst van geïnstalleerde pakketten:
$($installedPackages -join "`n")

Locale gebruiker clientadmin -> $clientAdminPassword
Locale gebruiker $localUser -> $localUserPassword

Ingelogd op domein met gebruiker: {vervang}
Aangemeld bij Outlook: OK
Aangemeld bij OneDrive: OK
Trend Micro geïnstalleerd: OK

internal

Lokale gebruiker clientadmin -> $clientAdminPassword
Lokale gebruiker $localUser -> $localUserPassword

TODO:
- [ ] Add lokale password to klantendossier
- [ ] Remove old device from trendmicro
- [ ] Tag sales in het ticket als je klaar bent
- [ ] Add credentials to Keeper
- [ ] Add Datto if user has service contract
"@

# Write to console
Write-Host $output