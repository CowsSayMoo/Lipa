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
$loggedInUser = "$env:USERDOMAIN\$env:USERNAME"

$installedPackages = @"
- Firefox
- Google Chrome
- Rustdesk
- Adobe Acrobat Reader
- Foxit PDF Reader
- Belgian EID middleware
- Belgian EID viewer
- OpenVPN Connect
- VLC Media player
- HP programmable key
- MS Office 365 Apps
- HP Support Assistant
- HP Image Assistant
- Splashtop
"@

# Format the output
$output = @"
Clean install

Apparaatnaam: $deviceName
Serienummer van het apparaat: $serialNumber

Lijst van geïnstalleerde pakketten:
$installedPackages

Lokaale gebruiker clientadmin beveiligd 
Lokale gebruiker $localUser met installatie rechten

Ingelogd op domein met gebruiker: {vervang}
Aangemeld bij Outlook: OK
Aangemeld bij OneDrive: OK
Trend Micro geïnstalleerd: OK

internal

Lokale gebruiker clientadmin -> $clientAdminPassword
Lokale gebruiker $localUser -> $localUserPassword

TODO:
- [ ] Voeg lokale passwoorden toe aan klantendossier
- [ ] Voeg credentials toe aan Keeper
- [ ] Tag sales in het ticket als je klaar bent
- [ ] Voeg Datto toe als de gebruiker een service contract heeft
"@

$output | Out-File -FilePath "$env:USERPROFILE\Desktop\autotask entry.txt"
