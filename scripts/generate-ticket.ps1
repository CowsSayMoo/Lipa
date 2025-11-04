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

Correte windows versie geinstalleerd 11
Alle updates en drivers geinstalleerd  

Hardware getest:
 - Camera
 - Microfoon
 - Wifi module
 - Voeding (Kabel) 

Lijst van geïnstalleerde pakketten:
$installedPackages

Lokale gebruiker clientadmin beveiligd 
Lokale gebruiker $localUser met installatie rechten

Ingelogd op domein met gebruiker: DOMEINGEBRUIKER

Aangemeld bij MS365: FALSE
Aangemeld bij Outlook: FALSE
Aangemeld bij OneDrive: FALSE
Trend Micro geïnstalleerd en geactiveerd: FALSE

internal

Lokale gebruiker clientadmin -> $clientAdminPassword
Lokale gebruiker $localUser -> $localUserPassword

TODO:
- [ ] Voorzie labels op het toestel en doos
- [ ] Noteer serienummer van producten

- [ ] Update klantendossier -> Lokale wachtwoorden 
- [ ] Update klantendossier -> Trendmicro (Enkel bij nieuwe trendmicro klant)
- [ ] Update klantendossier -> M365 (Enkel bij nieuwe M365 licentie)

- [ ] Test hardware -> Camera
- [ ] Test hardware -> Microphoon
- [ ] Test hardware -> Card reader
- [ ] Test hardware -> Wifi-module

- [ ] Voeg credentials toe aan Keeper (Avepoint, M365, Trendmicro)

- [ ] Voeg Datto toe (als de gebruiker een service contract heeft)

- [ ] Tag sales in het ticket als je klaar bent (Bieke en Leen)

- [ ] Kleef lipa sticker op toestel

- [ ] Ga nog eens over het ticket en klantendosier en keeper

                    _ _ _ _ _ _
                   |   MOO     |
\|/          (__)  |_ _ _ _ _ _|
     `\------(oo) /
       ||    (__)/
       ||w--||     \|/
   \|/
"@

$output | Out-File -FilePath "$env:USERPROFILE\Desktop\autotask entry.txt"
