# Software Installation Script using Winget
# Run this script as Administrator

# --- INITIAL SETUP ---
# Log file setup
$logFile = "$env:USERPROFILE\Desktop\lipa_setup_error_logs.txt"
$ticketFile = "$env:USERPROFILE\Desktop\lipa_setup_ticket_entry.txt"
$installedPackages = @() # Array to track successfully installed packages

# Function to log errors to file and console
function Write-ErrorLog {
    param(
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] ERROR: $Message"
    
    # Write to console
    Write-Host "✗ $Message" -ForegroundColor Red
    
    # Write to log file
    Add-Content -Path $logFile -Value $logMessage
}

# --- SCRIPT START ---
# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-ErrorLog -Message "This script must be run as Administrator! Please right-click PowerShell and select 'Run as Administrator'."
    pause
    exit
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Lipa System Configuration Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ========================================
# STEP 1: DETERMINE DEVICE TYPE (DOMAIN OR LOCAL)
# ========================================
$isDomainDevice = Read-Host "Will this device be added to a domain? (Y/N)"
Write-Host ""


# ========================================
# STEP 2: CHANGE DEVICE NAME
# ========================================
$currentComputerName = $env:COMPUTERNAME
Write-Host "Current device name: $currentComputerName" -ForegroundColor Yellow
Write-Host ""

$changeComputerName = Read-Host "Do you want to change the device name? (Y/N)"

if ($changeComputerName -eq "Y" -or $changeComputerName -eq "y") {
    $newComputerName = Read-Host "Enter new device name"
    
    if ($newComputerName -and $newComputerName -ne $currentComputerName) {
        try {
            Rename-Computer -NewName $newComputerName -Force
            Write-Host "✓ Device name will be changed to '$newComputerName' after restart" -ForegroundColor Green
            $requiresRestart = $true
        }
        catch {
            Write-ErrorLog -Message "Error changing device name: $_"
        }
    } elseif ($newComputerName -eq $currentComputerName) {
        Write-Host "Device name is already '$currentComputerName'" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "User Account Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ========================================
# STEP 3: USER ACCOUNT CONFIGURATION
# ========================================

# Configure ClientAdmin account password (for both domain and local devices)
$configureClientAdmin = Read-Host "Do you want to configure the ClientAdmin account password? (Y/N)"

if ($configureClientAdmin -eq "Y" -or $configureClientAdmin -eq "y") {
    Write-Host ""
    Write-Host "Setting password for ClientAdmin account..." -ForegroundColor Cyan
    
    # Check if ClientAdmin account exists
    try {
        $clientAdminExists = Get-LocalUser -Name "ClientAdmin" -ErrorAction SilentlyContinue
        
        if ($clientAdminExists) {
            while ($true) {
                $clientAdminPassword = Read-Host "Enter new password for ClientAdmin" -AsSecureString
                $clientAdminPasswordConfirm = Read-Host "Confirm password" -AsSecureString
                
                $pwd1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientAdminPassword))
                $pwd2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientAdminPasswordConfirm))
                
                if ($pwd1 -eq $pwd2) {
                    Set-LocalUser -Name "ClientAdmin" -Password $clientAdminPassword
                    Write-Host "✓ ClientAdmin password has been updated" -ForegroundColor Green
                    break # Exit the loop
                } else {
                    Write-Host "✗ Passwords do not match. Please try again." -ForegroundColor Yellow
                }
            }
        } else {
            Write-Host "✗ ClientAdmin account does not exist on this system" -ForegroundColor Yellow
        }
    }
    catch {
        Write-ErrorLog -Message "Error configuring ClientAdmin account: $_"
    }
}

Write-Host ""

# For local (non-domain) devices, create an additional local user
if ($isDomainDevice -ne "Y" -and $isDomainDevice -ne "y") {
    Write-Host "Local Device - Additional User Account" -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    
    $createLocalUser = Read-Host "Do you want to create an additional local user account? (Y/N)"

    if ($createLocalUser -eq "Y" -or $createLocalUser -eq "y") {
        Write-Host ""
        $newUsername = Read-Host "Enter username for the new local user"
        
        if ($newUsername) {
            try {
                # Check if user already exists
                $userExists = Get-LocalUser -Name $newUsername -ErrorAction SilentlyContinue
                
                if ($userExists) {
                    Write-Host "✗ User '$newUsername' already exists" -ForegroundColor Yellow
                } else {
                    while ($true) {
                        $newUserPassword = Read-Host "Enter password for $newUsername" -AsSecureString
                        $newUserPasswordConfirm = Read-Host "Confirm password" -AsSecureString
                        
                        $newPwd1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($newUserPassword))
                        $newPwd2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($newUserPasswordConfirm))
                        
                        if ($newPwd1 -eq $newPwd2) {
                            # Create the user
                            New-LocalUser -Name $newUsername -Password $newUserPassword -FullName $newUsername -Description "Local User Account"
                            Write-Host "✓ User '$newUsername' has been created" -ForegroundColor Green
                            
                            # Add to Administrators group
                            Add-LocalGroupMember -Group "Administrators" -Member $newUsername
                            Write-Host "✓ User '$newUsername' has been added to the Administrators group" -ForegroundColor Green
                            break # Exit the loop
                        } else {
                            Write-Host "✗ Passwords do not match. Please try again." -ForegroundColor Yellow
                        }
                    }
                }
            }
            catch {
                Write-ErrorLog -Message "Error creating user account: $_"
            }
        }
    }
} else {
    Write-Host "Domain Device - No additional local user needed" -ForegroundColor Yellow
    Write-Host "Domain users will be configured after joining the device to the domain" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "System Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ========================================
# STEP 4: DISABLE FAST STARTUP
# ========================================

Write-Host "Disabling Fast Startup..." -ForegroundColor Cyan

try {
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
    $regName = "HiberbootEnabled"
    
    Set-ItemProperty -Path $regPath -Name $regName -Value 0 -Type DWord
    
    Write-Host "✓ Fast Startup has been disabled" -ForegroundColor Green
    Write-Host "  (Change will take effect after restart)" -ForegroundColor Yellow
}
catch {
    Write-ErrorLog -Message "Error disabling Fast Startup: $_"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Software Installation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ========================================
# STEP 5: ENABLE WINGET HASH OVERRIDE
# ========================================

Write-Host "Enabling Winget InstallerHashOverride..." -ForegroundColor Cyan

try {
    # Path to Winget settings file
    $wingetSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"

    # Check if the settings file exists
    if (Test-Path $wingetSettingsPath) {
        # Read and decode the settings file
        $settings = Get-Content $wingetSettingsPath | ConvertFrom-Json

        # Enable the hash override setting
        $settings.installerHashOverride = $true

        # Encode the settings back to JSON and write to the file
        $settings | ConvertTo-Json | Set-Content -Path $wingetSettingsPath
        
        Write-Host "✓ Winget InstallerHashOverride has been enabled" -ForegroundColor Green
    } else {
        # If the file doesn't exist, create it with the setting
        $settings = @{
            "installerHashOverride" = $true
        }
        $settings | ConvertTo-Json | Set-Content -Path $wingetSettingsPath
        Write-Host "✓ Winget settings file created and InstallerHashOverride enabled" -ForegroundColor Green
    }
}
catch {
    Write-ErrorLog -Message "Error enabling Winget InstallerHashOverride: $_"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Software Installation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ========================================
# STEP 6: INSTALL SOFTWARE PACKAGES
# ========================================

# Define base packages to install with their Winget IDs
$packages = @(
    @{Name="RustDesk"; ID="RustDesk.RustDesk"},
    @{Name="Mozilla Firefox"; ID="Mozilla.Firefox"},
    @{Name="Google Chrome"; ID="Google.Chrome"},
    @{Name="Foxit PDF Reader"; ID="Foxit.FoxitReader"},
    @{Name="Adobe Acrobat Reader"; ID="Adobe.Acrobat.Reader.64-bit"},
    @{Name="HP Image Assistant"; ID="HP.ImageAssistant"},
    @{Name="HP Programmable Key"; ID="9MW15F21R5G8"},
    @{Name="Belgium e-ID viewer"; ID="BelgianGovernment.eIDViewer"},
    @{Name="Belgium e-ID middleware"; ID="BelgianGovernment.eIDmiddleware"},
    @{Name="MS365 Apps"; ID="Microsoft.Office"}
)

# Add domain-specific packages
if ($isDomainDevice -eq "Y" -or $isDomainDevice -eq "y") {
    $packages += @{Name="OpenVPN Connect"; ID="OpenVPNTechnologies.OpenVPNConnect"}
}




# Install each package
foreach ($pkg in $packages) {
    Write-Host "Installing $($pkg.Name)..." -ForegroundColor Cyan
    
    try {
        if ($pkg.ID -eq "Google.Chrome") {
            winget install --id $($pkg.ID) --silent --accept-package-agreements --accept-source-agreements --force
        } else {
            winget install --id $($pkg.ID) --silent --accept-package-agreements --accept-source-agreements
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ $($pkg.Name) installed successfully" -ForegroundColor Green
            $installedPackages += $pkg.Name
        } else {
            Write-Host "✗ $($pkg.Name) installation failed or was already installed" -ForegroundColor Yellow
            
        }
    }
    catch {
        Write-ErrorLog -Message "Error installing $($pkg.Name): $_"
    }
    
    Write-Host ""
}

Write-Host "Software installation completed!" -ForegroundColor Green
Write-Host ""

# ========================================
# STEP 7: WINDOWS UPDATES
# ========================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Windows Updates" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$installUpdates = Read-Host "Do you want to install Windows Updates now? (Y/N)"

if ($installUpdates -eq "Y" -or $installUpdates -eq "y") {
    Write-Host ""
    Write-Host "Checking for Windows Updates..." -ForegroundColor Cyan
    Write-Host "This may take several minutes..." -ForegroundColor Yellow
    Write-Host ""
    
    try {
        # Set execution policy for current process to allow module import
        Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
        
        # Trust the PSGallery repository to avoid security prompts
        Write-Host "Setting PSGallery repository to 'Trusted' to avoid prompts..." -ForegroundColor Yellow
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
        
        # Install PSWindowsUpdate module, which will also handle the NuGet provider dependency
        if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
            Write-Host "Installing PSWindowsUpdate module (and dependencies like NuGet)..." -ForegroundColor Cyan
            Install-Module -Name PSWindowsUpdate -Force -SkipPublisherCheck -Confirm:$false
            Write-Host "✓ PSWindowsUpdate module installed" -ForegroundColor Green
            Write-Host ""
        }
        
        # Import the module
        Import-Module PSWindowsUpdate -Force
        
        # Get available updates
        Write-Host "Scanning for available updates..." -ForegroundColor Cyan
        $updates = Get-WindowsUpdate
        
        if ($updates.Count -eq 0) {
            Write-Host "✓ No updates available. System is up to date!" -ForegroundColor Green
        } else {
            Write-Host "Found $($updates.Count) update(s)" -ForegroundColor Yellow
            Write-Host ""
            
            # Install updates
            Write-Host "Installing updates..." -ForegroundColor Cyan
            Write-Host "NOTE: This process may take a while depending on the number and size of updates" -ForegroundColor Yellow
            Write-Host ""
            
            $installResult = Install-WindowsUpdate -AcceptAll -AutoReboot:$false -Verbose
            $failedUpdates = $installResult | Where-Object { $_.Status -eq 'Failed' }

            if ($failedUpdates) {
                Write-ErrorLog -Message "One or more Windows updates failed to install:"
                foreach ($update in $failedUpdates) {
                    Write-ErrorLog -Message "  - $($update.Title) (KB: $($update.KB))"
                }
            } else {
                Write-Host ""
                Write-Host "✓ Windows Updates installed successfully" -ForegroundColor Green
            }
            
            # Check if restart is required
            if ((Get-WUInstallerStatus).IsRebootRequired) {
                Write-Host "⚠ A restart is required to complete the updates" -ForegroundColor Yellow
                $requiresRestart = $true
            }
        }
    }
    catch {
        Write-ErrorLog -Message "Error installing Windows Updates: $_"
        Write-Host ""
        Write-Host "You can manually check for updates in Windows Settings > Update & Security > Windows Update" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

# ========================================
# STEP 8: HP IMAGE ASSISTANT
# ========================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "HP Image Assistant" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$runHPIA = Read-Host "Do you want to run HP Image Assistant to install HP drivers and updates? (Y/N)"

if ($runHPIA -eq "Y" -or $runHPIA -eq "y") {
    Write-Host ""
    Write-Host "Locating HP Image Assistant..." -ForegroundColor Cyan
    
    try {
        # Standard installation path for HP Image Assistant
        $hpiaPath = "C:\SWSetup\HPImageAssistant\HPImageAssistant.exe"
        
        if (Test-Path $hpiaPath) {
            Write-Host "✓ Found HP Image Assistant at: $hpiaPath" -ForegroundColor Green
            Write-Host ""
            Write-Host "Launching HP Image Assistant..." -ForegroundColor Cyan
            Write-Host "Please complete the driver installation in the HP Image Assistant window" -ForegroundColor Yellow
            Write-Host ""
            
            # Run HP Image Assistant
            Start-Process -FilePath $hpiaPath -Wait
            
            Write-Host ""
            Write-Host "✓ HP Image Assistant completed" -ForegroundColor Green
        } else {
            Write-ErrorLog -Message "HP Image Assistant executable not found at: $hpiaPath"
            Write-Host "Please ensure HP Image Assistant was installed correctly" -ForegroundColor Yellow
            Write-Host "You can run it manually from the Start Menu" -ForegroundColor Yellow
        }
    }
    catch {
        Write-ErrorLog -Message "Error running HP Image Assistant: $_"
    }
    
    Write-Host ""
}

# ========================================
# STEP 9: JOIN DOMAIN (if applicable)
# ========================================

if ($isDomainDevice -eq "Y" -or $isDomainDevice -eq "y") {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Join Domain" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    $joinDomain = Read-Host "Do you want to join this device to a domain now? (Y/N)"
    if ($joinDomain -eq 'Y' -or $joinDomain -eq 'y') {
        $domainName = Read-Host "Enter the domain name to join"
        if ($domainName) {
            try {
                $credential = Get-Credential
                Add-Computer -DomainName $domainName -Credential $credential
                Write-Host "✓ Computer will be joined to domain '$domainName' after restart." -ForegroundColor Green
                $requiresRestart = $true
            }
            catch {
                Write-ErrorLog -Message "Failed to join domain $_"
            }
        }
    }
}


# ========================================
# STEP 10: CREATE SUMMARY FILE AND RESTART
# ========================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Creating Summary File..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($newComputerName) {
    $deviceName = $newComputerName
} else {
    $deviceName = $env:COMPUTERNAME
}

$summaryLines = @(
    "========================================"
    "Lipa Setup Ticket Entry"
    "========================================"
    ""
    "Device Name: $deviceName"
    ""
    "--- User Accounts ---"
)

if ($clientAdminPassword) {
    $clientAdminPwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientAdminPassword))
    $summaryLines += "ClientAdmin: $clientAdminPwd"
}

if ($newUserPassword) {
    $localUserPwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($newUserPassword))
    $summaryLines += "${newUsername}: $localUserPwd"
}

$summaryLines += @(
    ""
    "--- Installed Packages ---"
)
foreach ($pkgName in $installedPackages) {
    $summaryLines += "- $pkgName"
}

$summaryLines += @(
    ""
    "========================================"
)

$summaryContent = $summaryLines -join "`n"

try {
    Set-Content -Path $ticketFile -Value $summaryContent
    Write-Host "✓ Summary file created at: $ticketFile" -ForegroundColor Green
}
catch {
    Write-ErrorLog -Message "Failed to create summary file: $_"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "All Tasks Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($requiresRestart) {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "RESTART REQUIRED" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "A restart is required to apply some changes." -ForegroundColor Yellow
    Write-Host ""
    
    $restartNow = Read-Host "Would you like to restart now? (Y/N)"
    if ($restartNow -eq "Y" -or $restartNow -eq "y") {
        Write-Host "Restarting in 10 seconds..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    }
}

pause
