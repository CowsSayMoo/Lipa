#<#
.SYNOPSIS
    Generates a support ticket summary for a device.

.DESCRIPTION
    This script gathers device information, summarizes installed packages and applied configurations,
    and includes a 'To-Do' section for manual tasks, all formatted for a support ticket.
#>

function Write-TicketSection {
    param (
        [string]$Title,
        [string]$Content
    )
    Write-Host "`n--- $Title ---"
    Write-Host $Content
}

# 1. Gather Device Information
$ComputerInfo = Get-ComputerInfo
$DeviceName = $ComputerInfo.CsName
$ProductName = $ComputerInfo.OsOperatingSystemSKU
$SerialNumber = (Get-CimInstance Win32_Bios).SerialNumber

$DeviceInfo = @"
Device Name: $DeviceName
Product Name: $ProductName
Serial Number: $SerialNumber
"@
Write-TicketSection "Device Information" $DeviceInfo

# 2. Summarize Installed Packages
$SuccessLogPath = "C:\temp\successful_installations.log"
$InstalledPackages = "No packages installed or log file not found."
if (Test-Path $SuccessLogPath) {
    $InstalledPackages = Get-Content $SuccessLogPath | ForEach-Object { $_.Replace("Successfully installed ", "- ") }
    if (-not $InstalledPackages) {
        $InstalledPackages = "No packages successfully installed."
    }
}
Write-TicketSection "Installed Packages" $InstalledPackages

# 3. Summarize Endpoint Configuration (Inferred from endpoint-configuration.ps1)
$EndpointConfigSummary = @"
- Device name configured (if user provided input)
- clientadmin password configured (if user provided input)
- Local admin users added (if user provided input)
- Fast Startup disabled
- Outlook set to classic mode
- Splashtop SOS file moved to public desktop (if found in downloads)
"@
Write-TicketSection "Endpoint Configuration" $EndpointConfigSummary

# 4. To-Do Section
$ToDoSection = @"
- [ ] Purchase and install antivirus license
- [ ] Verify printer setup
- [ ] Configure network shares
- [ ] Install specialized software (e.g., CAD, accounting software)
- [ ] Hardware upgrades (e.g., add RAM, increase storage)
- [ ] ... (Add any other manual post-installation tasks here)
"@
Write-TicketSection "To-Do / Manual Tasks" $ToDoSection

Write-Host "`nTicket generation complete. Please copy the above information into your ticketing system."
